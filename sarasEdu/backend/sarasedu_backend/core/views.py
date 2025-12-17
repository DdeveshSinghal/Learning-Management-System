from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.decorators import api_view, permission_classes, throttle_classes
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.views import TokenObtainPairView
from django.contrib.auth import get_user_model
from django.contrib.auth.tokens import PasswordResetTokenGenerator
from django.utils.http import urlsafe_base64_encode, urlsafe_base64_decode
from django.utils.encoding import force_bytes, force_str
from django.core.mail import send_mail
from django.core.files.storage import default_storage
from django.conf import settings
from django.utils import timezone
from .serializers import RegisterSerializer, UserSerializer, AssignmentSubmissionSerializer
from .models import Course, Assignment, AssignmentSubmission
from .throttles import AIChatRateThrottle
from .permissions import IsTeacherOrAdmin
import os
import socket
import requests
from urllib.parse import urlparse
import base64
import io
import time
from django.http import StreamingHttpResponse, HttpResponse
from django.views.decorators.csrf import csrf_exempt
from django.utils.decorators import method_decorator
from django.http import HttpResponseForbidden
from django.db import transaction
from django.db.models import F
from huggingface_hub import InferenceClient
try:
    import openai
except Exception:
    openai = None

User = get_user_model()
class RegisterView(generics.CreateAPIView):
    serializer_class = RegisterSerializer
    permission_classes = (permissions.AllowAny,)

    def create(self, request, *args, **kwargs):
        resp = super().create(request, *args, **kwargs)
        user = User.objects.get(id=resp.data['id'])
        refresh = RefreshToken.for_user(user)
        data = {
            'token': str(refresh.access_token),
            'user': UserSerializer(user).data
        }
        return Response(data, status=201)


@api_view(['GET', 'PUT', 'PATCH'])
@permission_classes([permissions.IsAuthenticated])
def me(request):
    if request.method == 'GET':
        serializer = UserSerializer(request.user)
        return Response(serializer.data)
    
    elif request.method in ['PUT', 'PATCH']:
        user = request.user
        partial = request.method == 'PATCH'
        serializer = UserSerializer(user, data=request.data, partial=partial)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class CustomTokenObtainPairView(TokenObtainPairView):
    """Return token pair and user details on login."""

    def post(self, request, *args, **kwargs):
        response = super().post(request, *args, **kwargs)
        if response.status_code == 200 and 'access' in response.data:
            # attach user info and update last_login
            user = get_user_model().objects.filter(username=request.data.get('username') or request.data.get('email')).first()
            if user:
                # Update last_login timestamp
                user.last_login = timezone.now()
                user.save(update_fields=['last_login'])
                
                response.data['user'] = UserSerializer(user).data
        return response


class PasswordResetRequestView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request, *args, **kwargs):
        serializer = None
        try:
            from .serializers import PasswordResetRequestSerializer
            serializer = PasswordResetRequestSerializer(data=request.data)
            serializer.is_valid(raise_exception=True)
        except Exception:
            return Response({'detail': 'Invalid input'}, status=status.HTTP_400_BAD_REQUEST)

        email = serializer.validated_data['email']
        user = User.objects.filter(email=email).first()
        if not user:
            # don't reveal whether email exists
            return Response({'detail': 'If that email exists, a reset link was sent.'}, status=status.HTTP_200_OK)

        token = PasswordResetTokenGenerator().make_token(user)
        uid = urlsafe_base64_encode(force_bytes(user.pk))
        frontend = os.environ.get('FRONTEND_RESET_URL') or os.environ.get('FRONTEND_URL') or 'http://localhost:5173'
        reset_link = f"{frontend.rstrip('/')}/auth/reset-password?uid={uid}&token={token}"
        subject = 'Password reset for SarasEdu'
        message = f'Use the following link to reset your password: {reset_link}\nIf you did not request this, ignore.'
        from_email = os.environ.get('EMAIL_FROM', 'noreply@sarasedu.local')
        try:
            send_mail(subject, message, from_email, [email], fail_silently=False)
        except Exception:
            # fall back to logging the link in server logs for dev
            print('Password reset link for', email, reset_link)

        return Response({'detail': 'If that email exists, a reset link was sent.'}, status=status.HTTP_200_OK)


class PasswordResetConfirmView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request, *args, **kwargs):
        try:
            from .serializers import PasswordResetConfirmSerializer
            serializer = PasswordResetConfirmSerializer(data=request.data)
            serializer.is_valid(raise_exception=True)
        except Exception:
            return Response({'detail': 'Invalid input'}, status=status.HTTP_400_BAD_REQUEST)

        uid = serializer.validated_data['uid']
        token = serializer.validated_data['token']
        new_password = serializer.validated_data['new_password']

        try:
            uid_decoded = force_str(urlsafe_base64_decode(uid))
            user = User.objects.get(pk=uid_decoded)
        except Exception:
            return Response({'detail': 'Invalid uid'}, status=status.HTTP_400_BAD_REQUEST)

        if not PasswordResetTokenGenerator().check_token(user, token):
            return Response({'detail': 'Invalid or expired token.'}, status=status.HTTP_400_BAD_REQUEST)

        user.set_password(new_password)
        user.save()
        return Response({'detail': 'Password has been reset.'}, status=status.HTTP_200_OK)


class ChangePasswordView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        from .serializers import ChangePasswordSerializer
        serializer = ChangePasswordSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        user = request.user
        old_password = serializer.validated_data['old_password']
        new_password = serializer.validated_data['new_password']

        # Verify old password
        if not user.check_password(old_password):
            return Response({'detail': 'Invalid current password.'}, status=status.HTTP_400_BAD_REQUEST)

        # Set new password
        user.set_password(new_password)
        user.save()
        return Response({'detail': 'Password has been changed successfully.'}, status=status.HTTP_200_OK)


class AIChatView(APIView):
    # Allow any so local dev can call without auth; enforce auth in production
    permission_classes = [permissions.AllowAny]
    throttle_classes = [AIChatRateThrottle]

    def post(self, request, *args, **kwargs):
        message = request.data.get('message')
        if not message:
            return Response({'detail': 'message required'}, status=status.HTTP_400_BAD_REQUEST)

        # In production require authenticated user
        if not getattr(settings, 'DEBUG', False):
            if not (request.user and request.user.is_authenticated):
                return Response({'detail': 'Authentication required.'}, status=status.HTTP_401_UNAUTHORIZED)
        # Use only OpenRouter as requested
        openrouter_key = os.environ.get('OPENROUTER_API_KEY')

        # No OpenRouter key configured -> error
        if not openrouter_key:
            return Response({'detail': 'OPENROUTER_API_KEY not configured on server.'}, status=status.HTTP_503_SERVICE_UNAVAILABLE)

        # Build the chat payload
        messages = [{"role": "user", "content": message}]

        # Base URL for OpenRouter; allow overriding via env for flexibility
        openrouter_base = os.environ.get('OPENROUTER_API_URL', 'https://openrouter.ai/api').rstrip('/')

        # Helper: call OpenRouter (OpenRouter uses OpenAI-compatible shape)
        def call_openrouter_api(key):
            url = f"{openrouter_base}/v1/chat/completions"
            headers = {'Authorization': f'Bearer {key}', 'Content-Type': 'application/json'}
            payload = {
                'model': os.environ.get('AI_MODEL', 'gpt-4o-mini'),
                'messages': messages,
                'temperature': float(os.environ.get('AI_TEMPERATURE', '0.2')),
                'max_tokens': int(os.environ.get('AI_MAX_TOKENS', '800')),
            }
            try:
                r = requests.post(url, headers=headers, json=payload, timeout=30)
                r.raise_for_status()
                data = r.json()
                content = None
                if isinstance(data, dict):
                    choices = data.get('choices') or []
                    if len(choices) > 0:
                        msg = choices[0].get('message') or {}
                        content = msg.get('content') or choices[0].get('text')
                return content, data
            except Exception:
                raise
        # Call OpenRouter and return its content
        try:
            content, raw = call_openrouter_api(openrouter_key)
        except Exception as e:
            return Response({'detail': 'OpenRouter request failed', 'error': str(e)}, status=status.HTTP_502_BAD_GATEWAY)

        if not content:
            return Response({'detail': 'OpenRouter returned empty response', 'raw': raw}, status=status.HTTP_502_BAD_GATEWAY)

        return Response({'content': content})


class AIHealthView(APIView):
    """Simple health/diagnostic endpoint for AI provider connectivity.

    GET /api/ai/health
    Returns JSON with whether `OPENROUTER_API_KEY` is set, DNS resolution for api.openrouter.ai,
    and a short response from the OpenRouter models endpoint (or error details).
    """
    permission_classes = [permissions.AllowAny]

    def get(self, request, *args, **kwargs):
        openrouter_key = os.environ.get('OPENROUTER_API_KEY')
        # use OPENROUTER_API_URL when present, fall back to openrouter.ai/api
        openrouter_base = os.environ.get('OPENROUTER_API_URL', 'https://openrouter.ai/api').rstrip('/')
        parsed = urlparse(openrouter_base)
        host = parsed.netloc or parsed.path
        result = {'openrouter_key_present': bool(openrouter_key), 'openrouter_base': openrouter_base}

        # DNS resolution for the API host
        try:
            ip = socket.gethostbyname(host)
            result['dns'] = {'host': host, 'ip': ip}
        except Exception as e:
            result['dns_error'] = str(e)
        if not openrouter_key:
            return Response(result, status=status.HTTP_503_SERVICE_UNAVAILABLE)

        # Try a lightweight HTTP call to the OpenRouter models endpoint
        try:
            headers = {'Authorization': f'Bearer {openrouter_key}'}
            # call the models endpoint on the configured base URL
            resp = requests.get(f'{openrouter_base}/v1/models', headers=headers, timeout=10)
            try:
                data = resp.json()
            except Exception:
                data = resp.text
            result['http_status'] = resp.status_code
            result['http_response'] = data
            if resp.status_code >= 400:
                return Response(result, status=status.HTTP_502_BAD_GATEWAY)
            return Response(result)
        except Exception as e:
            result['http_error'] = str(e)
            return Response(result, status=status.HTTP_502_BAD_GATEWAY)

from rest_framework import generics
from .serializers import LectureSerializer, LibraryItemSerializer, AssignmentSubmissionSerializer
from .models import Lecture, LibraryItem
from django.http import StreamingHttpResponse, HttpResponse
from urllib.parse import urlparse
from django.views.decorators.csrf import csrf_exempt
from django.utils.decorators import method_decorator
from django.http import HttpResponseForbidden
from django.db import transaction
from django.db.models import F
import base64
import io
import time

class CourseLecturesView(generics.ListAPIView):
    """List lectures for a given course (compat endpoint)."""
    serializer_class = LectureSerializer
    permission_classes = [permissions.AllowAny]

    def get_queryset(self):
        course_id = self.kwargs.get('id')
        return Lecture.objects.filter(course_id=course_id).order_by('order_index')


class UserListView(generics.ListAPIView):
    """List all users from core_user table."""
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated]
    queryset = get_user_model().objects.all().order_by('id')


class UserDetailView(generics.RetrieveAPIView):
    serializer_class = UserSerializer
    permission_classes = [permissions.AllowAny]
    lookup_field = 'id'
    queryset = get_user_model().objects.all()


class LibraryListCreateView(generics.ListCreateAPIView):
    """List and create library items.

    - Uses a generic view for list/create.
    - Allows anonymous reads/writes in DEBUG for local dev convenience.
    - In production (DEBUG=False) POST requires authentication.
    """
    queryset = LibraryItem.objects.all().order_by('-upload_date')
    serializer_class = LibraryItemSerializer
    # AllowAny so we can enforce auth checks manually in create() depending on DEBUG
    permission_classes = [permissions.AllowAny]

    def get_queryset(self):
        qs = LibraryItem.objects.all().order_by('-upload_date')
        user = getattr(self.request, 'user', None)
        # Teachers should see only items they uploaded
        if user and user.is_authenticated and getattr(user, 'role', None) == 'teacher':
            return qs.filter(uploaded_by=user)
        # Students and admins see default list
        return qs

    def create(self, request, *args, **kwargs):
        # Validate input
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        # Require authentication in production for POST
        if not getattr(settings, 'DEBUG', False):
            if not (request.user and request.user.is_authenticated):
                return Response({'detail': 'Authentication required.'}, status=status.HTTP_401_UNAUTHORIZED)

        # allow anonymous uploads in DEBUG for local development convenience
        uploaded_by = request.user if (request.user and request.user.is_authenticated) else None
        serializer.save(uploaded_by=uploaded_by)
        headers = self.get_success_headers(serializer.data)
        return Response(serializer.data, status=status.HTTP_201_CREATED, headers=headers)


class AssignmentSubmitView(generics.CreateAPIView):
    """Accept a student submission via the compatibility endpoint."""
    serializer_class = AssignmentSubmissionSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        # serializer is expected to handle assignment and file fields
        serializer.save(student=self.request.user)


class CourseLecturesView(APIView):
    permission_classes = [permissions.AllowAny]

    def get(self, request, id, *args, **kwargs):
        from .models import Lecture
        from .serializers import LectureSerializer
        lectures = Lecture.objects.filter(course_id=id).order_by('order_index')
        serializer = LectureSerializer(lectures, many=True)
        return Response(serializer.data)


class UserDetailView(APIView):
    permission_classes = [permissions.AllowAny]

    def get(self, request, id, *args, **kwargs):
        try:
            user = User.objects.get(id=id)
        except User.DoesNotExist:
            return Response({'detail': 'Not found'}, status=status.HTTP_404_NOT_FOUND)
        serializer = UserSerializer(user)
        return Response(serializer.data)


    # NOTE: Duplicate APIView removed. List/create is handled by the generic view above.

class LibraryDetailView(APIView):
    """Compatibility detail endpoint for frontend: /library/<id>

    Supports GET, PUT and DELETE so clients that call `/api/library/<id>`
    will be able to read/update/delete items.
    """
    # AllowAny but enforce auth for write methods when not in DEBUG.
    permission_classes = [permissions.AllowAny]

    def get_object(self, id):
        try:
            return LibraryItem.objects.get(id=id)
        except LibraryItem.DoesNotExist:
            return None

    def get(self, request, id, *args, **kwargs):
        obj = self.get_object(id)
        if not obj:
            return Response({'detail': 'Not found'}, status=status.HTTP_404_NOT_FOUND)
        serializer = LibraryItemSerializer(obj)
        return Response(serializer.data)

    def put(self, request, id, *args, **kwargs):
        obj = self.get_object(id)
        if not obj:
            return Response({'detail': 'Not found'}, status=status.HTTP_404_NOT_FOUND)

        user = request.user
        # Require authentication in production for updates; in DEBUG allow unauthenticated edits.
        if not getattr(settings, 'DEBUG', False):
            if not (user and user.is_authenticated):
                return Response({'detail': 'Authentication required.'}, status=status.HTTP_401_UNAUTHORIZED)
            # only the uploader or admin may update
            if getattr(user, 'role', None) not in ('admin',):
                if getattr(obj, 'uploaded_by', None) and obj.uploaded_by != user:
                    return Response({'detail': 'Permission denied'}, status=status.HTTP_403_FORBIDDEN)

        serializer = LibraryItemSerializer(obj, data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, id, *args, **kwargs):
        obj = self.get_object(id)
        if not obj:
            return Response({'detail': 'Not found'}, status=status.HTTP_404_NOT_FOUND)

        user = request.user
        # Require auth in production; in DEBUG allow deletion without auth if needed.
        if not getattr(settings, 'DEBUG', False):
            if not (user and user.is_authenticated):
                return Response({'detail': 'Authentication required.'}, status=status.HTTP_401_UNAUTHORIZED)
            if not (getattr(user, 'role', None) == 'admin' or (getattr(obj, 'uploaded_by', None) and obj.uploaded_by == user)):
                return Response({'detail': 'Permission denied'}, status=status.HTTP_403_FORBIDDEN)

        obj.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


class AssignmentSubmitView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, id, *args, **kwargs):
        # allow students to submit file and text for assignment with id
        try:
            assignment = Assignment.objects.get(id=id)
        except Assignment.DoesNotExist:
            return Response({'detail': 'assignment not found.'}, status=status.HTTP_404_NOT_FOUND)

        user = request.user
        if not getattr(user, 'role', None) == 'student':
            return Response({'detail': 'Only students may submit assignments.'}, status=status.HTTP_403_FORBIDDEN)

        file = request.FILES.get('file')
        submitted_file_url = None
        if file:
            path = default_storage.save(file.name, file)
            submitted_file_url = default_storage.url(path)

        submission = AssignmentSubmission.objects.create(
            assignment=assignment,
            student=user,
            submitted_file_url=submitted_file_url,
            submission_text=request.data.get('submission_text', ''),
            status='submitted'
        )
        serializer = AssignmentSubmissionSerializer(submission)
        return Response(serializer.data, status=status.HTTP_201_CREATED)


@method_decorator(csrf_exempt, name='dispatch')
class DriveProxyView(APIView):
    """Simple proxy for Google Drive files.

    - Only allows Google Drive / docs hosts.
    - Forwards Range requests and streams content back to client.
    - Adds CORS header so the frontend can load media from the proxy.
    """
    permission_classes = []

    def get(self, request, *args, **kwargs):
        url = request.query_params.get('url')
        if not url:
            return HttpResponse(status=400)

        # basic validation: only allow drive hosts
        try:
            up = urlparse(url)
            host = (up.netloc or '').lower()
        except Exception:
            return HttpResponse(status=400)

        allowed_hosts = ('drive.google.com', 'docs.google.com', 'lh3.googleusercontent.com')
        if not any(h in host for h in allowed_hosts):
            return HttpResponseForbidden('Host not allowed')

        headers = {}
        # forward Range header if present
        incoming_range = request.META.get('HTTP_RANGE')
        if incoming_range:
            headers['Range'] = incoming_range

        try:
            upstream = requests.get(url, headers=headers, stream=True, allow_redirects=True, timeout=15)
        except requests.RequestException as e:
            return HttpResponse(str(e), status=502)

        status_code = upstream.status_code
        content_type = upstream.headers.get('Content-Type', 'application/octet-stream')
        content_length = upstream.headers.get('Content-Length')

        # generator to stream chunks
        def stream_gen():
            try:
                for chunk in upstream.iter_content(chunk_size=8192):
                    if chunk:
                        yield chunk
            finally:
                try:
                    upstream.close()
                except Exception:
                    pass

        resp = StreamingHttpResponse(stream_gen(), status=status_code, content_type=content_type)
        # copy important headers
        if content_length:
            resp['Content-Length'] = content_length
        if 'Content-Range' in upstream.headers:
            resp['Content-Range'] = upstream.headers['Content-Range']
        # indicate we accept range requests
        resp['Accept-Ranges'] = 'bytes'
        # allow CORS for frontend (adjust in production to specific origin)
        resp['Access-Control-Allow-Origin'] = '*'
        resp['Access-Control-Expose-Headers'] = 'Content-Length,Content-Range'
        return resp


class LibraryDownloadView(APIView):
    """Record a download for a library item and increment its total_downloads counter.

    POST /api/library/<id>/download
    Returns: { total_downloads: int }
    """
    permission_classes = [permissions.AllowAny]

    def post(self, request, id, *args, **kwargs):
        try:
            item = LibraryItem.objects.get(id=id)
        except LibraryItem.DoesNotExist:
            return Response({'detail': 'Not found'}, status=status.HTTP_404_NOT_FOUND)

        # create a LibraryDownload record if model exists
        try:
            from .models import LibraryDownload
            LibraryDownload.objects.create(
                user=request.user if (request.user and request.user.is_authenticated) else None,
                library_item=item
            )
        except Exception:
            # ignore if model or create fails; still increment counter
            pass

        # atomic increment
        try:
            with transaction.atomic():
                LibraryItem.objects.filter(id=item.id).update(total_downloads=F('total_downloads') + 1)
                item.refresh_from_db()
        except Exception:
            # fallback: increment and save
            try:
                item.total_downloads = (item.total_downloads or 0) + 1
                item.save()
            except Exception:
                pass

        return Response({'total_downloads': item.total_downloads})


class AIImageView(APIView):
    """Analyze an uploaded image (base64 data or multipart file) using Hugging Face Inference API.

    Request:
      - JSON { "image": "data:image/png;base64,..." }
      - or multipart/form-data with file field `file`

    Response: { "description": "..." }
    """
    permission_classes = [permissions.AllowAny]

    def post(self, request, *args, **kwargs):
        # Require auth in production
        if not getattr(settings, 'DEBUG', False):
            if not (request.user and request.user.is_authenticated):
                return Response({'detail': 'Authentication required.'}, status=status.HTTP_401_UNAUTHORIZED)

        # get image bytes
        image_bytes = None
        # multipart upload
        if request.FILES.get('file'):
            f = request.FILES['file']
            image_bytes = f.read()
        else:
            img_data = request.data.get('image') or request.data.get('imageData')
            if not img_data:
                return Response({'detail': 'image required (file upload or base64 image)'} , status=status.HTTP_400_BAD_REQUEST)
            # handle data URL
            if isinstance(img_data, str) and img_data.startswith('data:'):
                try:
                    header, b64 = img_data.split(',', 1)
                    image_bytes = base64.b64decode(b64)
                except Exception:
                    return Response({'detail': 'invalid data URL'}, status=status.HTTP_400_BAD_REQUEST)
            else:
                # assume plain base64
                try:
                    image_bytes = base64.b64decode(img_data)
                except Exception:
                    return Response({'detail': 'invalid base64 image'}, status=status.HTTP_400_BAD_REQUEST)

        # Try OpenRouter first (more reliable), fall back to Hugging Face
        openrouter_key = os.environ.get('OPENROUTER_API_KEY')
        hf_key = os.environ.get('HUGGINGFACE_API_KEY')
        
        if not openrouter_key and not hf_key:
            return Response({'detail': 'No AI API key configured'}, status=status.HTTP_502_BAD_GATEWAY)

        try:
            # Use OpenRouter with a vision-capable model (GPT-4 Vision or similar)
            if openrouter_key:
                # Convert image bytes to base64 for OpenRouter
                img_b64 = base64.b64encode(image_bytes).decode('utf-8')
                # Determine image type from first few bytes
                img_type = 'jpeg'  # default
                if image_bytes.startswith(b'\x89PNG'):
                    img_type = 'png'
                elif image_bytes.startswith(b'GIF'):
                    img_type = 'gif'
                
                data_url = f'data:image/{img_type};base64,{img_b64}'
                
                url = 'https://openrouter.ai/api/v1/chat/completions'
                headers = {
                    'Authorization': f'Bearer {openrouter_key}',
                    'Content-Type': 'application/json',
                }
                payload = {
                    'model': 'openai/gpt-4o-mini',  # Vision-capable model that works well
                    'messages': [
                        {
                            'role': 'user',
                            'content': [
                                {
                                    'type': 'text',
                                    'text': 'Describe this image in one sentence.'
                                },
                                {
                                    'type': 'image_url',
                                    'image_url': {
                                        'url': data_url
                                    }
                                }
                            ]
                        }
                    ],
                    'max_tokens': 150
                }
                
                response = requests.post(url, headers=headers, json=payload, timeout=60)
                
                if response.status_code == 200:
                    data = response.json()
                    description = data.get('choices', [{}])[0].get('message', {}).get('content', '').strip()
                    if description:
                        return Response({'description': description})
            
            # Fallback: Return a message that the service is unavailable
            return Response({
                'detail': 'Image analysis service is temporarily unavailable. Hugging Face free tier has been deprecated. Please configure OpenRouter API or use a paid Hugging Face tier.'
            }, status=status.HTTP_503_SERVICE_UNAVAILABLE)
            
        except requests.RequestException as e:
            return Response({
                'detail': f'Request to AI service failed: {str(e)}'
            }, status=status.HTTP_502_BAD_GATEWAY)
        except Exception as e:
            return Response({
                'detail': f'Image analysis failed: {str(e)}'
            }, status=status.HTTP_502_BAD_GATEWAY)


class AITranscribeView(APIView):
    """Accepts an audio file upload and returns transcription text using AssemblyAI.

    Expects multipart/form-data with `file` field.
    Returns: { "text": "transcribed text" }
    """
    permission_classes = [permissions.AllowAny]

    def post(self, request, *args, **kwargs):
        # Require auth in production
        if not getattr(settings, 'DEBUG', False):
            if not (request.user and request.user.is_authenticated):
                return Response({'detail': 'Authentication required.'}, status=status.HTTP_401_UNAUTHORIZED)

        f = request.FILES.get('file')
        if not f:
            return Response({'detail': 'file required'}, status=status.HTTP_400_BAD_REQUEST)

        assembly_key = os.environ.get('ASSEMBLY_API_KEY')
        if not assembly_key:
            return Response({'detail': 'AssemblyAI API key not configured'}, status=status.HTTP_502_BAD_GATEWAY)

        # Upload to AssemblyAI
        upload_url = 'https://api.assemblyai.com/v2/upload'
        headers = {'Authorization': assembly_key}

        try:
            upload_resp = requests.post(upload_url, headers=headers, data=f.read())
        except requests.RequestException as e:
            return Response({'detail': f'AssemblyAI upload failed: {str(e)}'}, status=status.HTTP_502_BAD_GATEWAY)

        if upload_resp.status_code != 200 and upload_resp.status_code != 201:
            return Response({'detail': 'AssemblyAI upload error', 'error': upload_resp.text}, status=status.HTTP_502_BAD_GATEWAY)

        try:
            upload_data = upload_resp.json()
            audio_url = upload_data.get('upload_url') or upload_data.get('url')
        except Exception:
            return Response({'detail': 'Invalid upload response from AssemblyAI', 'raw': upload_resp.text}, status=status.HTTP_502_BAD_GATEWAY)

        if not audio_url:
            return Response({'detail': 'AssemblyAI did not return upload URL', 'raw': upload_data}, status=status.HTTP_502_BAD_GATEWAY)

        # Create transcription
        transcript_url = 'https://api.assemblyai.com/v2/transcript'
        payload = {'audio_url': audio_url}

        try:
            create_resp = requests.post(transcript_url, headers=headers, json=payload)
        except requests.RequestException as e:
            return Response({'detail': f'AssemblyAI transcription create failed: {str(e)}'}, status=status.HTTP_502_BAD_GATEWAY)

        if create_resp.status_code not in (200, 201):
            return Response({'detail': 'AssemblyAI transcript creation failed', 'error': create_resp.text}, status=status.HTTP_502_BAD_GATEWAY)

        try:
            create_data = create_resp.json()
            tid = create_data.get('id')
        except Exception:
            return Response({'detail': 'Invalid transcript create response', 'raw': create_resp.text}, status=status.HTTP_502_BAD_GATEWAY)

        if not tid:
            return Response({'detail': 'AssemblyAI did not return transcript id', 'raw': create_data}, status=status.HTTP_502_BAD_GATEWAY)

        # Poll until completed or failed
        poll_url = f'https://api.assemblyai.com/v2/transcript/{tid}'
        timeout = 120
        interval = 2
        elapsed = 0
        while elapsed < timeout:
            try:
                poll_resp = requests.get(poll_url, headers=headers)
            except requests.RequestException as e:
                return Response({'detail': f'AssemblyAI polling failed: {str(e)}'}, status=status.HTTP_502_BAD_GATEWAY)

            if poll_resp.status_code != 200:
                return Response({'detail': 'AssemblyAI polling returned error', 'error': poll_resp.text}, status=status.HTTP_502_BAD_GATEWAY)

            poll_data = poll_resp.json()
            status_text = poll_data.get('status')
            if status_text == 'completed':
                return Response({'text': poll_data.get('text', '')})
            if status_text == 'failed':
                return Response({'detail': 'Transcription failed', 'error': poll_data.get('error')}, status=status.HTTP_502_BAD_GATEWAY)

            time.sleep(interval)
            elapsed += interval

        return Response({'detail': 'Transcription timed out'}, status=status.HTTP_504_GATEWAY_TIMEOUT)


