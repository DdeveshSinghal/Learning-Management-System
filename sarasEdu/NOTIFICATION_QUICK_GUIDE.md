# Notification System - Quick Reference Guide

## Quick Start

The notification system is already integrated into the dashboard header. No additional setup needed for basic functionality.

## For Developers

### 1. Testing the Notification Center

The notification center is located in the header (top-right corner) of every dashboard page.

Click the bell icon to open the notification dialog.

### 2. API Integration Status

✅ **Implemented APIs:**
- `getNotifications()` - Fetch notifications
- `markNotificationAsRead(id)` - Mark single as read
- `markAllNotificationsAsRead()` - Mark all as read
- `deleteNotification(id)` - Delete single
- `deleteAllNotifications()` - Delete all

### 3. Customizing Notifications

To modify how notifications appear, edit `notification-center.jsx`:

**Change notification type colors:**
```javascript
const getNotificationIcon = (type) => {
  switch (type) {
    case 'success':
      return <CheckCircle className="h-5 w-5 text-green-500" />;
    case 'alert':
      return <AlertCircle className="h-5 w-5 text-red-500" />;
    case 'info':
      return <Info className="h-5 w-5 text-blue-500" />;
    // Add more types here
  }
};
```

**Change notification limit:**
```javascript
const data = await getNotifications({ limit: 100 }); // Was 50
```

### 4. Backend Setup

Your Django backend needs these models and viewsets:

**Model Example:**
```python
from django.db import models
from django.contrib.auth.models import User

class Notification(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='notifications')
    title = models.CharField(max_length=255)
    message = models.TextField()
    notification_type = models.CharField(
        max_length=20,
        choices=[
            ('success', 'Success'),
            ('alert', 'Alert'),
            ('info', 'Info'),
        ],
        default='info'
    )
    is_read = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['-created_at']
```

**ViewSet Example:**
```python
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated

class NotificationViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAuthenticated]
    serializer_class = NotificationSerializer
    
    def get_queryset(self):
        return self.request.user.notifications.all()
    
    @action(detail=True, methods=['post'])
    def mark_as_read(self, request, pk=None):
        notification = self.get_object()
        notification.is_read = True
        notification.save()
        return Response({'status': 'marked as read'})
    
    @action(detail=False, methods=['post'])
    def mark_all_as_read(self, request):
        self.get_queryset().update(is_read=True)
        return Response({'status': 'all marked as read'})
    
    @action(detail=False, methods=['delete'])
    def delete_all(self, request):
        self.get_queryset().delete()
        return Response({'status': 'all deleted'})
```

**URLs Configuration:**
```python
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import NotificationViewSet

router = DefaultRouter()
router.register(r'notifications', NotificationViewSet, basename='notification')

urlpatterns = [
    path('', include(router.urls)),
]
```

### 5. Triggering Notifications from Backend

Example of creating a notification when an assignment is submitted:

```python
from core.models import Notification

def create_assignment_submitted_notification(assignment_submission):
    Notification.objects.create(
        user=assignment_submission.student.user,
        title='Assignment Submitted',
        message=f'Your submission for "{assignment_submission.assignment.title}" has been recorded.',
        notification_type='success'
    )
```

### 6. Common Issues & Solutions

**Problem:** Notifications not showing
- Check that your backend has the `/api/notifications/` endpoint
- Verify API response format matches expected structure
- Check browser console for error messages

**Problem:** "Mark as read" not working
- Ensure `markNotificationAsRead` endpoint exists on backend
- Check that notification ID is being passed correctly

**Problem:** Dialog won't open
- Verify Dialog component is properly imported from `ui/dialog`
- Check browser console for JavaScript errors

### 7. Future Enhancement Ideas

1. **Notification Bell Polling:**
```javascript
// Auto-refresh unread count every 30 seconds
useEffect(() => {
  const interval = setInterval(() => {
    if (!isOpen) fetchNotifications(); // Only when dialog is closed
  }, 30000);
  return () => clearInterval(interval);
}, []);
```

2. **WebSocket Real-time Updates:**
```javascript
useEffect(() => {
  const ws = new WebSocket('ws://localhost:8000/ws/notifications/');
  ws.onmessage = (event) => {
    const notification = JSON.parse(event.data);
    setNotifications(prev => [notification, ...prev]);
  };
  return () => ws.close();
}, []);
```

3. **Sound Notifications:**
```javascript
const playNotificationSound = () => {
  const audio = new Audio('/notification-sound.mp3');
  audio.play();
};
```

4. **Browser Notifications:**
```javascript
const showBrowserNotification = (title, message) => {
  if ('Notification' in window) {
    new Notification(title, { body: message });
  }
};
```

## Files Modified

1. `src/services/api.js` - Added notification API functions
2. `src/components/notification-center.jsx` - Updated to use real API
3. `src/components/optimized-lms-dashboard.jsx` - Integrated NotificationCenter

## Testing Checklist

- [ ] Bell icon appears in header
- [ ] Clicking bell opens dialog
- [ ] Dialog displays notifications from API
- [ ] Unread count badge shows correctly
- [ ] Mark as read works
- [ ] Mark all as read works
- [ ] Delete individual notification works
- [ ] Clear all works
- [ ] Error handling displays retry button
- [ ] Loading state shows spinner
