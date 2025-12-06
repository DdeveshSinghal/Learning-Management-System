# User Profile Component - Database Integration

## Overview
The `user-profile.jsx` component has been fully connected to the backend database through REST API endpoints. All profile data is now fetched from and saved to the database.

## Connected Fields by User Role

### Common Fields (All Users)
- **name**: User's full name
- **email**: User's email address (read-only)
- **phone**: User's phone number
- **address**: User's address
- **bio**: User's biography
- **avatar**: User's profile picture
- **joinDate**: Account creation date (read-only)

### Student Profile Fields
Connected to `StudentProfile` model:
- **studentId**: Student ID (read-only)
- **grade**: Grade/Class level
- **rollNumber**: Student roll number
- **parentName**: Parent/Guardian name
- **parentPhone**: Parent/Guardian phone number
- **dateOfBirth**: Date of birth
- **stats.currentGPA**: Average grade from database
- **stats.coursesEnrolled**: Number of enrolled courses
- **stats.assignmentsCompleted**: Completed assignments count
- **stats.testsCompleted**: Completed tests count
- **stats.attendanceRate**: Attendance percentage
- **achievements**: List of earned achievements

### Teacher Profile Fields
Connected to `TeacherProfile` model:
- **employeeId**: Employee ID (read-only)
- **department**: Department name
- **qualification**: Academic qualification
- **specialization**: Subject specialization
- **officeHours**: Office hours
- **stats.avgClassRating**: Average rating from database
- **stats.coursesTeaching**: Number of courses teaching
- **stats.totalStudents**: Total students taught
- **stats.materialsUploaded**: Count of uploaded materials
- **stats.testsCreated**: Count of created tests
- **stats.assignmentsGiven**: Count of assignments given
- **courses**: List of teaching courses

### Admin Profile Fields
Connected to `AdminProfile` model:
- **employeeId**: Employee ID (read-only)
- **position**: Admin position
- **department**: Department
- **accessLevel**: Access level (read-only)
- **stats.totalUsers**: Total users in system
- **stats.activeCourses**: Active courses count
- **stats.systemUptime**: System uptime percentage
- **systemInfo**: Server/Database/Backup/Security status

## API Endpoints Used

### User Profile API
- `GET /auth/me` - Fetch current user profile
- `PATCH /auth/me` - Update user profile (phone, bio, avatar_url)
- `POST /auth/change-password` - Change user password

### Student Profile API
- `GET /student-profiles/{userId}/` - Fetch student profile
- `PATCH /student-profiles/{userId}/` - Update student profile

### Teacher Profile API
- `GET /teacher-profiles/{userId}/` - Fetch teacher profile
- `PATCH /teacher-profiles/{userId}/` - Update teacher profile

### Admin Profile API
- `GET /admin-profiles/{userId}/` - Fetch admin profile
- `PATCH /admin-profiles/{userId}/` - Update admin profile

## Data Flow

### On Component Mount
1. Component fetches base user data using `userId` and `userRole` props
2. Specific role profile is fetched from the corresponding endpoint
3. Data is merged and stored in `userData` state
4. Form state is synchronized with `userData`

### On Edit & Save
1. User clicks "Edit" button to enable editing mode
2. Changes are made to `formData` state
3. User clicks "Save" button
4. Only modified fields are sent to the API
5. Separate update calls are made for base user and role-specific profiles
6. Success/error notifications are displayed via `toast`
7. Component automatically refreshes on successful save

### Password Change Flow
1. User enters current and new passwords in Security tab
2. Validates password length (minimum 8 characters)
3. Confirms passwords match
4. Sends request to `/auth/change-password` endpoint
5. Shows appropriate success/error message

## Features Implemented

### ✅ Profile Fetching
- Automatic fetch on component load
- Role-specific data loading
- Error handling with fallback values
- Loading state indicators

### ✅ Profile Editing
- Edit mode toggle
- Real-time form validation
- Selective field updates (only changed fields sent)
- Loading state during save
- Success/error notifications

### ✅ Password Management
- Current password verification
- Password confirmation matching
- Minimum length validation
- Secure API communication

### ✅ User Experience
- Loading spinners during API calls
- Toast notifications for success/error
- Disabled buttons during loading
- Read-only fields for immutable data (email, IDs, access level)
- Responsive design with role-specific information

## Database Models Referenced

### User (Base Model)
```python
class User(AbstractUser):
    role = CharField(choices=['student', 'teacher', 'admin'])
    avatar_url = TextField(blank=True, null=True)
    bio = TextField(blank=True, null=True)
    phone = CharField(max_length=20, blank=True, null=True)
```

### StudentProfile
```python
class StudentProfile(models.Model):
    user = OneToOneField('core.User', primary_key=True)
    roll_number = CharField(max_length=50, unique=True)
    grade_level = CharField(max_length=20)
    parent_contact = CharField(max_length=20)
    date_of_birth = DateField()
    address = TextField()
    average_grade = DecimalField(max_digits=5, decimal_places=2)
```

### TeacherProfile
```python
class TeacherProfile(models.Model):
    user = OneToOneField('core.User', primary_key=True)
    employee_id = CharField(max_length=50, unique=True)
    department = CharField(max_length=100)
    qualification = CharField(max_length=255)
    specialization = CharField(max_length=255)
    office_hours = CharField(max_length=255)
    average_rating = DecimalField(max_digits=3, decimal_places=2)
```

### AdminProfile
```python
class AdminProfile(models.Model):
    user = OneToOneField('core.User', primary_key=True)
    employee_id = CharField(max_length=50, unique=True)
    position = CharField(max_length=100)
    access_level = CharField(max_length=50)
    department = CharField(max_length=100)
```

## Usage

### Basic Usage
```jsx
import { UserProfile } from './components/user-profile';

// In your component
<UserProfile 
  userRole="student"  // 'student', 'teacher', or 'admin'
  userId={123}        // User ID from authentication
  userName="John Doe" // User's full name
/>
```

### With Authentication Context
```jsx
const { user } = useAuth(); // Assuming auth context exists

<UserProfile 
  userRole={user.role}
  userId={user.id}
  userName={user.name}
/>
```

## Error Handling

The component includes comprehensive error handling:
- API request failures show toast notifications
- Graceful fallback to empty/default values if profile doesn't exist
- Password change errors are clearly communicated
- Network errors are caught and displayed to the user

## Security Considerations

✅ **Implemented**
- Authentication tokens automatically attached to requests
- Read-only fields for sensitive data (email, IDs, access level)
- Proper error messages that don't expose system details
- Current password requirement for password changes
- Password length validation

## Future Enhancements

- [ ] Avatar upload functionality
- [ ] Notification preferences API integration
- [ ] 2FA setup and management
- [ ] Login activity history from API
- [ ] File export/import functionality
- [ ] Batch profile updates
- [ ] Profile picture cropping tool
- [ ] Integration with enrollment statistics
- [ ] Real-time sync with other users' changes
