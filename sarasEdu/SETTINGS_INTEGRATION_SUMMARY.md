# Settings Panel Database Integration Summary

## Overview
Successfully integrated the `settings-panel.jsx` component with the database backend, enabling full CRUD operations for user settings.

## Backend Changes

### 1. Database Model (`core/models.py`)
Created `UserSettings` model with the following fields:

**Appearance Settings:**
- `theme` (light/dark)
- `language` (en/es/fr/de)
- `timezone`
- `dashboard_view` (default/courses/calendar/analytics)

**Notification Settings:**
- `email_notifications`
- `inapp_notifications`
- `sms_notifications`
- `notify_assignments`
- `notify_grades`
- `notify_announcements`
- `notify_reminders`
- `notify_discussion_replies`
- `notify_student_submissions`

**Privacy Settings:**
- `profile_visibility` (public/students/teachers/private)
- `email_visible`
- `phone_visible`
- `allow_messaging`
- `two_factor_auth`

**Student Course Preferences:**
- `auto_enrollment`
- `deadline_reminders`
- `late_submission_warning`

**Teacher Preferences:**
- `default_grading_scheme` (percentage/letter/points)
- `late_submission_policy` (no_penalty/partial_credit/no_credit)
- `course_visibility` (public/unlisted/private)
- `plagiarism_check`
- `student_messaging`

**Admin Settings:**
- `user_registration`
- `course_approval`
- `system_maintenance`
- `backup_frequency` (hourly/daily/weekly)
- `password_policy` (weak/medium/strong)

### 2. Serializer (`core/serializers.py`)
- Created `UserSettingsSerializer` to handle serialization/deserialization
- Marked `user`, `created_at`, and `updated_at` as read-only fields

### 3. ViewSet (`core/viewsets.py`)
Created `UserSettingsViewSet` with:
- Permission control (users can only access their own settings)
- Custom `/user-settings/me/` endpoint for GET/PUT/PATCH operations
- Automatic creation of settings if they don't exist

### 4. URL Routes (`core/urls.py`)
- Registered `user-settings` endpoint at `/api/user-settings/`
- Added custom endpoint `/api/user-settings/me/` for current user

### 5. Admin Interface (`core/admin.py`)
- Registered `UserSettings` model in Django admin
- Display settings for theme, language, profile visibility, and email notifications
- Added search and filter capabilities

### 6. Signals (`core/signals.py`)
- Auto-create `UserSettings` record when a new user is created
- Ensures every user has default settings

### 7. Database Migration
- Created migration file: `0008_usersettings_remove_liveclass_max_participants_and_more.py`
- Ready to run when database is available

## Frontend Changes

### 1. API Service (`services/api.js`)
Added two new functions:
- `getUserSettings()` - Fetch current user's settings
- `updateUserSettings(payload)` - Update current user's settings

### 2. Settings Panel Component (`components/settings-panel.jsx`)
Enhanced with:
- **State Management:**
  - Added `loading` state for initial data fetch
  - Added `saving` state for save operations
  
- **Data Fetching:**
  - `useEffect` hook to fetch user profile and settings on component mount
  - Maps backend field names (snake_case) to frontend state (camelCase)
  
- **Save Functionality:**
  - `handleSaveSettings()` function to save all settings
  - Updates both user profile (name, email, phone, bio) and settings
  - Displays success/error toasts
  
- **UI Enhancements:**
  - Loading state indicator
  - Disabled save button while loading or saving
  - Real-time save status feedback

## API Endpoints

### Get Current User Settings
```
GET /api/user-settings/me/
Authorization: Bearer <token>

Response:
{
  "theme": "light",
  "language": "en",
  "timezone": "UTC-5",
  "dashboard_view": "default",
  "email_notifications": true,
  ...
}
```

### Update Current User Settings
```
PATCH /api/user-settings/me/
Authorization: Bearer <token>
Content-Type: application/json

{
  "theme": "dark",
  "email_notifications": false,
  ...
}

Response: Updated settings object
```

## Data Flow

1. **Component Mount:**
   - Component loads → Shows loading state
   - Fetches user profile via `me()` API
   - Fetches user settings via `getUserSettings()` API
   - Maps backend data to frontend state
   - Displays settings in UI

2. **User Updates Settings:**
   - User modifies settings in UI
   - State updates locally
   - User clicks "Save Changes"

3. **Save Operation:**
   - Disables save button
   - Splits profile data (name, email, phone, bio) from settings
   - Calls `updateUserProfile()` for profile fields
   - Calls `updateUserSettings()` for all other settings
   - Shows success/error toast
   - Re-enables save button

## Field Mapping (Backend ↔ Frontend)

### Backend (Snake Case) → Frontend (Camel Case)
- `dashboard_view` → `dashboardView`
- `email_notifications` → `notifications.email`
- `inapp_notifications` → `notifications.inApp`
- `notify_assignments` → `notifications.assignments`
- `profile_visibility` → `privacy.profileVisibility`
- `email_visible` → `privacy.emailVisible`
- `two_factor_auth` → `privacy.twoFactorAuth`
- `default_grading_scheme` → `teaching.defaultGradingScheme`
- `late_submission_policy` → `teaching.lateSubmissionPolicy`
- ... and more

## Testing Checklist

When database is running, test:
- [ ] Settings load correctly on component mount
- [ ] Profile settings (name, email, phone, bio) save correctly
- [ ] Appearance settings update and persist
- [ ] Notification preferences save properly
- [ ] Privacy settings work as expected
- [ ] Role-specific settings (student/teacher/admin) function correctly
- [ ] Error handling displays appropriate messages
- [ ] Loading states display correctly
- [ ] Toast notifications appear on save/error

## Next Steps

1. **Start Database:** Run Docker compose to start the MySQL database
2. **Run Migration:** Execute `python manage.py migrate` to create the UserSettings table
3. **Test Integration:** Log in and test the settings panel functionality
4. **Create Test Data:** Verify settings persist across sessions

## Notes

- Settings are automatically created for new users via Django signals
- Each user has one-to-one relationship with UserSettings
- Settings are user-specific and isolated (users can't see others' settings)
- Profile data (name, email, phone, bio) stored in User model
- All other preferences stored in UserSettings model
- Frontend gracefully handles missing settings via default values
