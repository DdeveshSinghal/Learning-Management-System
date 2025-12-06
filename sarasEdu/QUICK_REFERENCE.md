# User Profile Component - Quick Reference Guide

## Component Location
`sarasEdu/frontend/src/components/user-profile.jsx`

## Component Props
```jsx
<UserProfile 
  userRole="student"   // Required: 'student' | 'teacher' | 'admin'
  userId={123}        // Required: User ID (number)
  userName="John Doe" // Required: User's full name (string)
/>
```

## Features at a Glance

### 📋 Personal Info Tab
**Student Fields:**
- Full Name, Email, Phone, Address, Bio
- Date of Birth, Roll Number, Grade, Parent Name, Parent Phone

**Teacher Fields:**
- Full Name, Email, Phone, Address, Bio
- Department, Employee ID, Qualification, Specialization, Office Hours

**Admin Fields:**
- Full Name, Email, Phone, Address, Bio
- Position, Department, Employee ID, Access Level

### 📊 Statistics Tab
**Student Stats:**
- Courses Enrolled, Current GPA, Attendance Rate, Class Rank
- Academic Progress (assignments, tests, attendance bars)
- Recent Achievements

**Teacher Stats:**
- Courses Teaching, Total Students, Average Class Rating
- Teaching Statistics (materials, tests, assignments)
- Course Performance List

**Admin Stats:**
- Total Users, Active Courses, System Uptime
- System Health (Server, Database, Backup, Security)

### 🔐 Security Tab
- Change Password with validation
- Two-Factor Authentication (placeholder)
- Login Activity History

### ⚙️ Preferences Tab
- Notification Preferences Checkboxes

## API Requests Made

### On Component Load
```
GET /student-profiles/{userId}/     (if student)
GET /teacher-profiles/{userId}/     (if teacher)
GET /admin-profiles/{userId}/       (if admin)
```

### On Save
```
PATCH /auth/me                      (phone, bio, avatar)
PATCH /student-profiles/{userId}/   (if student)
PATCH /teacher-profiles/{userId}/   (if teacher)
PATCH /admin-profiles/{userId}/     (if admin)
```

### On Password Change
```
POST /auth/change-password
```

## State Variables

```javascript
const [isEditing, setIsEditing]         // Toggle edit mode
const [showPassword, setShowPassword]   // Toggle password visibility
const [loading, setLoading]             // Loading indicator
const [userData, setUserData]           // Fetched data
const [formData, setFormData]           // Form state (for editing)
```

## Key Functions

### fetchUserProfile()
- Fetches all user data on component mount
- Handles role-specific profile loading
- Sets loading states
- Shows error notifications

### handleInputChange(field, value)
- Updates formData state
- Enables real-time form updates

### handleSave()
- Validates data
- Sends only changed fields to API
- Shows success/error toast
- Refreshes UI

### handlePasswordChange()
- Validates passwords
- Sends to API
- Clears form on success

## Database Field Mapping

### User → API
| Frontend | Database |
|----------|----------|
| phone | phone |
| bio | bio |
| avatar | avatar_url |

### Student → API
| Frontend | Database |
|----------|----------|
| dateOfBirth | date_of_birth |
| parentPhone | parent_contact |
| rollNumber | roll_number |
| grade | grade_level |
| stats.currentGPA | average_grade |

### Teacher → API
| Frontend | Database |
|----------|----------|
| officeHours | office_hours |
| stats.avgClassRating | average_rating |

## Error Handling

✅ Network errors → Toast notification
✅ API errors → Toast notification
✅ Validation errors → Toast notification
✅ Loading state → Shows spinner
✅ API failures → Graceful fallbacks

## Loading States

1. **Initial Load**: Spinner + "Loading profile..." message
2. **Saving**: Buttons disabled, spinner on Save button
3. **Success**: Toast notification, form hidden
4. **Error**: Toast notification, data preserved

## Validation Rules

### Passwords
- Minimum 8 characters
- Must match confirmation
- Current password required
- Alphanumeric + special chars recommended

### Form Fields
- Email: Read-only (from database)
- IDs: Read-only (unique identifiers)
- Phone: Max 20 characters
- Text fields: Can be empty (optional)

## Important Notes

⚠️ **Email is read-only** - Cannot be changed in profile
⚠️ **IDs are read-only** - Unique database identifiers
⚠️ **Access Level is read-only** - Admin-only setting
⚠️ **Join Date is read-only** - Set at registration

## Common Issues & Solutions

### Issue: Profile not loading
**Solution**: Check userId prop and API endpoint availability

### Issue: Changes not saving
**Solution**: Check network tab, verify API response, check authentication

### Issue: Password change fails
**Solution**: Verify current password is correct, check password meets requirements

### Issue: Stats showing empty
**Solution**: Stats fields may not exist in database, check API response

## Testing Checklist

- [ ] Profile loads on component mount
- [ ] All fields display correct data
- [ ] Edit mode toggles correctly
- [ ] Form changes are tracked
- [ ] Save sends only changed fields
- [ ] Success notification appears on save
- [ ] Error notification appears on API failure
- [ ] Loading states work correctly
- [ ] Password validation works
- [ ] Password change succeeds with valid data
- [ ] Read-only fields cannot be edited
- [ ] Role-specific fields appear correctly

## Browser DevTools Tips

1. **Network Tab**: Monitor API calls to verify endpoints
2. **Application Tab**: Check localStorage for tokens and user data
3. **Console**: Look for error messages and logs
4. **React DevTools**: Inspect component state and props

## Version Info
- React: 16.8+ (hooks required)
- UI Library: shadcn/ui components
- API: REST API (backend required)
- Styling: Tailwind CSS
