# Backend Notification Implementation Guide

## Django Models

Add this to your `core/models.py`:

```python
from django.db import models
from django.contrib.auth.models import User

class Notification(models.Model):
    """User notification model for system-wide messages"""
    
    NOTIFICATION_TYPES = [
        ('success', 'Success'),
        ('alert', 'Alert'),
        ('info', 'Information'),
    ]
    
    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='notifications',
        help_text='User who receives this notification'
    )
    title = models.CharField(
        max_length=255,
        help_text='Short notification title'
    )
    message = models.TextField(
        help_text='Detailed notification message'
    )
    notification_type = models.CharField(
        max_length=20,
        choices=NOTIFICATION_TYPES,
        default='info',
        help_text='Type of notification (affects UI styling)'
    )
    is_read = models.BooleanField(
        default=False,
        help_text='Whether user has read this notification'
    )
    created_at = models.DateTimeField(
        auto_now_add=True,
        help_text='When notification was created'
    )
    updated_at = models.DateTimeField(
        auto_now=True,
        help_text='Last update timestamp'
    )
    
    class Meta:
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['user', '-created_at']),
            models.Index(fields=['user', 'is_read']),
        ]
    
    def __str__(self):
        return f"{self.title} - {self.user.username}"
    
    def mark_as_read(self):
        """Mark notification as read"""
        if not self.is_read:
            self.is_read = True
            self.save(update_fields=['is_read'])
```

## Serializers

Add this to your `core/serializers.py`:

```python
from rest_framework import serializers
from core.models import Notification

class NotificationSerializer(serializers.ModelSerializer):
    """Serializer for Notification model"""
    
    class Meta:
        model = Notification
        fields = [
            'id',
            'title',
            'message',
            'notification_type',
            'is_read',
            'created_at',
            'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']
```

## ViewSets

Add this to your `core/viewsets.py`:

```python
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework.pagination import PageNumberPagination
from core.models import Notification
from core.serializers import NotificationSerializer
from django.db.models import Q

class NotificationPagination(PageNumberPagination):
    """Custom pagination for notifications"""
    page_size = 50
    page_size_query_param = 'limit'
    max_page_size = 100

class NotificationViewSet(viewsets.ModelViewSet):
    """
    ViewSet for managing user notifications
    
    list: Get all notifications for current user
    retrieve: Get specific notification
    mark_as_read: Mark single notification as read
    mark_all_as_read: Mark all notifications as read
    delete: Delete specific notification
    delete_all: Delete all notifications
    """
    
    serializer_class = NotificationSerializer
    permission_classes = [IsAuthenticated]
    pagination_class = NotificationPagination
    
    def get_queryset(self):
        """Get notifications for current user only"""
        user = self.request.user
        queryset = Notification.objects.filter(user=user)
        
        # Optional filtering by read status
        is_read = self.request.query_params.get('is_read', None)
        if is_read is not None:
            is_read = is_read.lower() == 'true'
            queryset = queryset.filter(is_read=is_read)
        
        return queryset
    
    @action(detail=True, methods=['post'])
    def mark_as_read(self, request, pk=None):
        """Mark a single notification as read"""
        notification = self.get_object()
        notification.mark_as_read()
        serializer = self.get_serializer(notification)
        return Response(serializer.data)
    
    @action(detail=False, methods=['post'])
    def mark_all_as_read(self, request):
        """Mark all notifications for current user as read"""
        updated_count = self.get_queryset().filter(
            is_read=False
        ).update(is_read=True)
        return Response({
            'status': 'success',
            'message': f'{updated_count} notifications marked as read'
        })
    
    @action(detail=False, methods=['delete'])
    def delete_all(self, request):
        """Delete all notifications for current user"""
        deleted_count, _ = self.get_queryset().delete()
        return Response({
            'status': 'success',
            'message': f'{deleted_count} notifications deleted'
        })
    
    def destroy(self, request, *args, **kwargs):
        """Delete a single notification"""
        instance = self.get_object()
        self.perform_destroy(instance)
        return Response(
            {'status': 'success', 'message': 'Notification deleted'},
            status=status.HTTP_204_NO_CONTENT
        )
```

## URL Configuration

Add this to your `core/urls.py`:

```python
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from core.viewsets import NotificationViewSet

router = DefaultRouter()
router.register(r'notifications', NotificationViewSet, basename='notification')

urlpatterns = [
    path('', include(router.urls)),
]
```

And include in your main `urls.py`:

```python
from django.urls import path, include

urlpatterns = [
    path('api/', include('core.urls')),
]
```

## Helper Functions

Add these utility functions to `core/models.py` or a new `core/notifications.py`:

```python
from core.models import Notification
from django.contrib.auth.models import User

def create_notification(user, title, message, notification_type='info'):
    """Helper function to create a notification"""
    return Notification.objects.create(
        user=user,
        title=title,
        message=message,
        notification_type=notification_type
    )

def notify_user(user_id, title, message, notification_type='info'):
    """Create notification by user ID"""
    try:
        user = User.objects.get(id=user_id)
        return create_notification(user, title, message, notification_type)
    except User.DoesNotExist:
        return None

def notify_multiple_users(user_ids, title, message, notification_type='info'):
    """Create notifications for multiple users"""
    notifications = [
        Notification(
            user_id=user_id,
            title=title,
            message=message,
            notification_type=notification_type
        )
        for user_id in user_ids
    ]
    return Notification.objects.bulk_create(notifications)

def notify_course_students(course, title, message, notification_type='info'):
    """Notify all students in a course"""
    student_ids = course.students.values_list('user_id', flat=True)
    return notify_multiple_users(student_ids, title, message, notification_type)

def get_unread_count(user):
    """Get unread notification count for user"""
    return user.notifications.filter(is_read=False).count()
```

## Usage Examples

### 1. Notify on Assignment Submission

```python
from core.notifications import create_notification

def submit_assignment(assignment_submission):
    # ... submit logic ...
    
    # Notify student
    create_notification(
        user=assignment_submission.student.user,
        title='Assignment Submitted',
        message=f'Your submission for "{assignment_submission.assignment.title}" has been received.',
        notification_type='success'
    )
    
    # Notify teacher
    create_notification(
        user=assignment_submission.assignment.course.teacher.user,
        title='New Assignment Submission',
        message=f'{assignment_submission.student.user.get_full_name()} submitted "{assignment_submission.assignment.title}"',
        notification_type='info'
    )
```

### 2. Notify on Grade Release

```python
def release_grades(test_submission):
    # ... grading logic ...
    
    create_notification(
        user=test_submission.student.user,
        title='Grade Released',
        message=f'Your grade for "{test_submission.test.title}" is now available: {test_submission.score}%',
        notification_type='alert' if test_submission.score < 50 else 'success'
    )
```

### 3. Notify on Announcement

```python
def post_announcement(announcement):
    # ... create announcement ...
    
    notify_course_students(
        course=announcement.course,
        title='New Announcement',
        message=f'{announcement.title}: {announcement.content[:100]}...',
        notification_type='info'
    )
```

### 4. Deadline Reminder (Celery Task)

```python
from celery import shared_task
from django.utils import timezone
from datetime import timedelta
from core.notifications import notify_multiple_users
from core.models import Assignment

@shared_task
def send_deadline_reminders():
    """Send reminders for assignments due in 24 hours"""
    tomorrow = timezone.now() + timedelta(days=1)
    upcoming_assignments = Assignment.objects.filter(
        due_date__date=tomorrow.date()
    )
    
    for assignment in upcoming_assignments:
        student_ids = assignment.course.students.values_list('user_id', flat=True)
        notify_multiple_users(
            student_ids=student_ids,
            title='Assignment Due Tomorrow',
            message=f'Remember: "{assignment.title}" is due tomorrow at {assignment.due_date.strftime("%H:%M")}',
            notification_type='alert'
        )
```

## Admin Interface

Add to `core/admin.py`:

```python
from django.contrib import admin
from core.models import Notification

@admin.register(Notification)
class NotificationAdmin(admin.ModelAdmin):
    list_display = ['title', 'user', 'notification_type', 'is_read', 'created_at']
    list_filter = ['notification_type', 'is_read', 'created_at']
    search_fields = ['title', 'message', 'user__username']
    readonly_fields = ['created_at', 'updated_at']
    
    fieldsets = (
        ('Basic Info', {
            'fields': ('user', 'title', 'message')
        }),
        ('Settings', {
            'fields': ('notification_type', 'is_read')
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )
```

## Migration

Run these commands:

```bash
python manage.py makemigrations
python manage.py migrate
```

## Testing

```python
from django.test import TestCase
from django.contrib.auth.models import User
from core.models import Notification

class NotificationTestCase(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            username='testuser',
            password='testpass'
        )
    
    def test_create_notification(self):
        notif = Notification.objects.create(
            user=self.user,
            title='Test',
            message='Test message',
            notification_type='info'
        )
        self.assertEqual(notif.user, self.user)
        self.assertFalse(notif.is_read)
    
    def test_mark_as_read(self):
        notif = Notification.objects.create(
            user=self.user,
            title='Test',
            message='Test message'
        )
        notif.mark_as_read()
        self.assertTrue(notif.is_read)
```
