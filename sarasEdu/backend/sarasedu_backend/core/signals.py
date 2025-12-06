from django.db.models.signals import post_save
from django.dispatch import receiver
from django.contrib.auth import get_user_model

from .models import StudentProfile, TeacherProfile, AdminProfile

User = get_user_model()

@receiver(post_save, sender=User)
def create_user_profile(sender, instance, created, **kwargs):
    """Auto-create a profile row for a user when it's created based on role."""
    if not created:
        return
    try:
        if instance.role == 'student':
            StudentProfile.objects.get_or_create(user=instance)
        elif instance.role == 'teacher':
            TeacherProfile.objects.get_or_create(user=instance)
        elif instance.role == 'admin':
            AdminProfile.objects.get_or_create(user=instance)
    except Exception:
        # avoid raising errors at save-time; log to stdout for dev environments
        try:
            print(f'Failed to create profile for user {instance.id}')
        except Exception:
            pass
