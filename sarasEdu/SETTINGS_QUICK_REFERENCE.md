# Settings Panel - Quick Reference Guide

## Overview
The Settings Panel provides a comprehensive interface for users to manage their preferences across profile, appearance, notifications, privacy, and role-specific settings.

## Setup Instructions

### 1. Database Setup
```bash
# Navigate to backend directory
cd sarasEdu/backend/sarasedu_backend

# Run migrations (when database is running)
python manage.py migrate

# The UserSettings table will be created automatically
```

### 2. Automatic Settings Creation
- UserSettings are automatically created for new users via Django signals
- Existing users will have settings created on first access to `/api/user-settings/me/`

## API Usage

### Frontend Import
```javascript
import { getUserSettings, updateUserSettings } from '../services/api';
```

### Fetch Settings
```javascript
try {
  const settings = await getUserSettings();
  console.log(settings);
} catch (error) {
  console.error('Failed to load settings:', error);
}
```

### Update Settings
```javascript
try {
  const updatedSettings = await updateUserSettings({
    theme: 'dark',
    email_notifications: false,
    language: 'es'
  });
  console.log('Settings saved:', updatedSettings);
} catch (error) {
  console.error('Failed to save settings:', error);
}
```

## Component Usage

### Basic Implementation
```jsx
import { SettingsPanel } from './components/settings-panel';

function App() {
  const user = getCurrentUser(); // Your user object
  
  return (
    <SettingsPanel 
      userRole={user.role}
      userId={user.id}
      userName={user.username}
    />
  );
}
```

### Props
- `userRole`: string - User's role ('student', 'teacher', or 'admin')
- `userId`: number - User's ID for API calls
- `userName`: string - User's display name

## Settings Categories

### 1. Profile Settings
- Full Name
- Email Address
- Phone Number
- Bio
- Avatar Upload

**Updates:** User model fields via `updateUserProfile()`

### 2. Appearance Settings
- Theme (Light/Dark)
- Language (English, Spanish, French, German)
- Timezone
- Default Dashboard View

**Updates:** UserSettings model via `updateUserSettings()`

### 3. Notification Settings
- **Delivery Methods:**
  - Email Notifications
  - In-App Notifications
  - SMS Notifications

- **Notification Types:**
  - Assignment Due Dates
  - Grade Updates
  - Announcements
  - Course Reminders
  - Discussion Replies (Teachers only)
  - Student Submissions (Teachers only)

**Updates:** UserSettings model

### 4. Privacy & Security Settings
- Profile Visibility (Public/Students/Teachers/Private)
- Show Email Address
- Show Phone Number
- Allow Direct Messages
- Two-Factor Authentication
- Change Password
- Manage Connected Devices

**Updates:** UserSettings model

### 5. Course/Teaching Settings

**For Students:**
- Auto-Enrollment Confirmation
- Deadline Reminders
- Late Submission Warnings

**For Teachers:**
- Default Grading Scheme (Percentage/Letter/Points)
- Late Submission Policy
- Default Course Visibility
- Enable Plagiarism Check
- Allow Student-to-Student Messaging

**Updates:** UserSettings model

### 6. Admin Settings (Admin users only)
- **User Management:**
  - Enable Self-Registration
  - Course Approval Required

- **System Settings:**
  - Backup Frequency (Hourly/Daily/Weekly)
  - Password Policy (Basic/Medium/Strong)
  - Maintenance Mode

**Updates:** UserSettings model

## Backend Model Fields

### UserSettings Model
```python
class UserSettings(models.Model):
    user = OneToOneField(User)
    
    # Appearance
    theme = CharField(default='light')
    language = CharField(default='en')
    timezone = CharField(default='UTC-5')
    dashboard_view = CharField(default='default')
    
    # Notifications
    email_notifications = BooleanField(default=True)
    inapp_notifications = BooleanField(default=True)
    sms_notifications = BooleanField(default=False)
    notify_assignments = BooleanField(default=True)
    notify_grades = BooleanField(default=True)
    notify_announcements = BooleanField(default=True)
    notify_reminders = BooleanField(default=True)
    notify_discussion_replies = BooleanField(default=False)
    notify_student_submissions = BooleanField(default=False)
    
    # Privacy
    profile_visibility = CharField(default='public')
    email_visible = BooleanField(default=False)
    phone_visible = BooleanField(default=False)
    allow_messaging = BooleanField(default=True)
    two_factor_auth = BooleanField(default=False)
    
    # Student preferences
    auto_enrollment = BooleanField(default=False)
    deadline_reminders = BooleanField(default=True)
    late_submission_warning = BooleanField(default=True)
    
    # Teacher preferences
    default_grading_scheme = CharField(default='percentage')
    late_submission_policy = CharField(default='partial_credit')
    course_visibility = CharField(default='public')
    plagiarism_check = BooleanField(default=True)
    student_messaging = BooleanField(default=True)
    
    # Admin settings
    user_registration = BooleanField(default=True)
    course_approval = BooleanField(default=False)
    system_maintenance = BooleanField(default=False)
    backup_frequency = CharField(default='daily')
    password_policy = CharField(default='strong')
```

## Testing

### Manual Testing Steps
1. Log in to the application
2. Navigate to Settings page
3. Verify all tabs load correctly (Profile, Appearance, Notifications, Privacy, Course/Teaching, Admin if admin)
4. Modify some settings in each tab
5. Click "Save Changes"
6. Verify success toast appears
7. Refresh the page
8. Verify settings persisted

### API Testing with cURL
```bash
# Get settings
curl -X GET http://localhost:8000/api/user-settings/me/ \
  -H "Authorization: Bearer YOUR_TOKEN"

# Update settings
curl -X PATCH http://localhost:8000/api/user-settings/me/ \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"theme": "dark", "language": "es"}'
```

## Troubleshooting

### Settings not loading
- Check browser console for errors
- Verify user is authenticated
- Check API endpoint is accessible
- Ensure migrations have been run

### Settings not saving
- Check browser console for errors
- Verify correct field names (snake_case for backend)
- Check user has permission to update settings
- Verify database connection

### Missing settings for existing users
Settings are created automatically on first access. If missing:
```python
# Django shell
from django.contrib.auth import get_user_model
from core.models import UserSettings

User = get_user_model()
users_without_settings = User.objects.filter(settings__isnull=True)

for user in users_without_settings:
    UserSettings.objects.create(user=user)
```

## Migration Command

When database is available:
```bash
cd sarasEdu/backend/sarasedu_backend
python manage.py migrate
```

This will create the `core_usersettings` table with all the necessary fields.

## Files Modified

### Backend
- `core/models.py` - Added UserSettings model
- `core/serializers.py` - Added UserSettingsSerializer
- `core/viewsets.py` - Added UserSettingsViewSet
- `core/urls.py` - Registered user-settings route
- `core/admin.py` - Registered UserSettings in admin
- `core/signals.py` - Auto-create settings for new users

### Frontend
- `services/api.js` - Added getUserSettings and updateUserSettings
- `components/settings-panel.jsx` - Added data fetching and saving logic

## Security Considerations

- Users can only access their own settings (enforced by viewset)
- Settings are user-specific and isolated
- Two-factor authentication setting is available but requires backend implementation
- Profile visibility controls who can see user information
- Admin settings only visible to admin users
