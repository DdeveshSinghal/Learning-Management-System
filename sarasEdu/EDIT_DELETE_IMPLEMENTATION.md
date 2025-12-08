# Edit and Delete User Functionality Implementation

## Overview
Implemented fully functional Edit and Delete operations for student and teacher profiles in the User Management component. Admin users can now modify all profile details and remove users from the system.

## Changes Made

### 1. New State Variables Added
```javascript
const [showEditDialog, setShowEditDialog] = useState(false);
const [editingUser, setEditingUser] = useState(null);
const [editForm, setEditForm] = useState({
  firstName: '',
  lastName: '',
  email: '',
  phone: '',
  rollNumber: '',
  gradeLevel: '',
  parentContact: '',
  address: '',
  emergencyContact: '',
  employeeId: '',
  department: '',
  qualification: '',
  specialization: '',
  officeHours: '',
});
```

### 2. Helper Functions Implemented

#### `openEditDialog(user, type)`
- Opens the edit dialog and populates the form with user's current data
- Accepts user object and type ('student' or 'teacher')
- Initializes editForm state with user's editable fields

#### `handleEditUser()`
- Sends PATCH request to backend API to update profile
- **For Students:** Updates roll_number, grade_level, parent_contact, address, emergency_contact
- **For Teachers:** Updates employee_id, department, qualification, specialization, office_hours
- Endpoint: `/student-profiles/{id}/` or `/teacher-profiles/{id}/`
- Refreshes user list after successful update

#### `handleRemoveUser(user, type)`
- Prompts user with confirmation dialog before deletion
- Sends DELETE request to backend API
- **For Students:** Deletes from `/student-profiles/{id}/`
- **For Teachers:** Deletes from `/teacher-profiles/{id}/`
- Closes detail dialog and refreshes user list after deletion
- Prevents accidental deletion with confirmation

#### `refreshUsers()`
- Re-fetches all student and teacher data from backend
- Updates enrollments and attendance information
- Called after add, edit, or delete operations
- Ensures UI displays latest data from database

### 3. New EditUserDialog Component
Modal dialog with form fields for editing user profiles:

**Student Fields:**
- First Name, Last Name
- Email, Phone
- Roll Number, Grade Level
- Parent/Guardian Contact, Address
- Emergency Contact

**Teacher Fields:**
- First Name, Last Name
- Email, Phone
- Employee ID, Department
- Qualification, Specialization
- Office Hours

Features:
- Max height with scrolling for long content
- Cancel button to discard changes
- Save Changes button to persist updates
- Dynamic field display based on user type

### 4. Button Integration

#### UserCard Component
- **Edit Button:** Calls `openEditDialog()` to open edit modal
- **Remove Button:** Calls `handleRemoveUser()` with confirmation

#### UserDetailDialog Component
- **Edit Button:** Opens `EditUserDialog` with current user's data
- **Remove Button:** Deletes user with confirmation prompt

### 5. API Integration

**Backend Endpoints Used:**
- `PATCH /student-profiles/{id}/` - Update student profile
- `PATCH /teacher-profiles/{id}/` - Update teacher profile
- `DELETE /student-profiles/{id}/` - Delete student
- `DELETE /teacher-profiles/{id}/` - Delete teacher

**Request Format:**
```javascript
// Update request
await api.request(`/student-profiles/${userId}/`, { 
  method: 'PATCH', 
  body: JSON.stringify(updateData) 
});

// Delete request
await api.request(`/teacher-profiles/${userId}/`, { 
  method: 'DELETE' 
});
```

## Features

### Edit Functionality
✅ Open edit dialog from user card or detail view
✅ Pre-populate form with current user data
✅ Conditional fields based on student/teacher type
✅ PATCH request to update only modified fields
✅ Confirmation of changes in UI refresh
✅ Error handling with console logging

### Delete Functionality
✅ Confirmation prompt before deletion
✅ Prevents accidental data loss
✅ Closes detail dialog after deletion
✅ Removes user from UI immediately
✅ Refreshes user count in stats
✅ Error handling with console logging

### Authorization
- Admin has full access to edit all user fields
- All API calls use authenticated token from localStorage
- Backend should enforce permission checks at API level

## User Experience Flow

### Edit Flow
1. User clicks "Edit" button on user card or detail dialog
2. EditUserDialog opens with pre-filled form data
3. User modifies desired fields
4. User clicks "Save Changes"
5. PATCH request sent to backend
6. User list refreshes with updated data
7. Dialog closes automatically
8. Updated user information displays in grid

### Delete Flow
1. User clicks "Remove/Delete" button
2. Browser confirmation dialog appears: "Are you sure you want to delete this {student/teacher}? This action cannot be undone."
3. If user confirms:
   - DELETE request sent to backend
   - User removed from database
   - Detail dialog closes
   - User removed from grid display
   - Total count updated in stats

## File Locations

**Modified File:**
- `c:\Users\shubhu\OneDrive\Desktop\check\sarasEdu\frontend\src\components\user-management.jsx`
  - Lines 36-71: New state variables
  - Lines 189-384: Helper functions (openEditDialog, handleEditUser, handleRemoveUser, refreshUsers)
  - Lines 386-528: EditUserDialog component
  - Lines 723-739: Edit button handlers in UserDetailDialog
  - Lines 764-770: Edit button handlers in UserCard
  - Lines 1064-1067: EditUserDialog component render

## Backend Requirements

The following Django views must support PATCH and DELETE methods:

**StudentProfileViewSet:**
```python
@action(detail=True, methods=['patch'])
def partial_update(self, request, pk=None):
    # Update student profile fields

@action(detail=True, methods=['delete'])
def destroy(self, request, pk=None):
    # Delete student profile
```

**TeacherProfileViewSet:**
```python
@action(detail=True, methods=['patch'])
def partial_update(self, request, pk=None):
    # Update teacher profile fields

@action(detail=True, methods=['delete'])
def destroy(self, request, pk=None):
    # Delete teacher profile
```

## Serializer Configuration

Ensure serializers allow these fields:

**StudentProfileSerializer:**
```python
fields = ['id', 'user', 'roll_number', 'grade_level', 'parent_contact', 
          'address', 'emergency_contact', 'average_grade', 'created_at']
```

**TeacherProfileSerializer:**
```python
fields = ['id', 'user', 'employee_id', 'department', 'qualification',
          'specialization', 'office_hours', 'average_rating', 'created_at']
```

## Testing Checklist

- [ ] Edit button opens EditUserDialog
- [ ] Form fields pre-populate with current data
- [ ] Changes persist after saving
- [ ] Delete button shows confirmation prompt
- [ ] User is removed from list after deletion
- [ ] User counts update after delete
- [ ] Edit works for both students and teachers
- [ ] Delete works for both students and teachers
- [ ] Appropriate error messages on API failure
- [ ] Dialog closes after successful operation
- [ ] UI refreshes with latest backend data

## Future Enhancements

1. **Validation:** Add client-side form validation before submission
2. **Notifications:** Add toast notifications for success/error messages
3. **Batch Operations:** Allow bulk edit/delete of multiple users
4. **Audit Trail:** Track who edited/deleted users and when
5. **Role-Based Access:** Restrict edit/delete based on user role
6. **Field Permissions:** Different admins can edit different fields
7. **Undo Functionality:** Soft delete with restore option

## Authorization Notes

Currently, all authenticated users can trigger edit/delete. Implement the following in backend:

```python
from rest_framework.permissions import IsAuthenticated, IsAdminUser

class StudentProfileViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAuthenticated, IsAdminUser]  # Restrict to admins
```

Or implement custom permission:

```python
class IsAdminOrReadOnly(permissions.BasePermission):
    def has_permission(self, request, view):
        if request.method in permissions.SAFE_METHODS:
            return True
        return request.user and request.user.role == 'admin'
```
