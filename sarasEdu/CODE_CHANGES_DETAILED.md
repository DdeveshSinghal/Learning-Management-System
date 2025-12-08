# Code Changes Summary

## Backend Serializer Update

**File:** `backend/sarasedu_backend/core/serializers.py`

### Before
```python
class StudentProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = StudentProfile
        fields = '__all__'


class TeacherProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = TeacherProfile
        fields = '__all__'
```

### After
```python
class StudentProfileSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)  # ← Added this line
    
    class Meta:
        model = StudentProfile
        fields = '__all__'


class TeacherProfileSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)  # ← Added this line
    
    class Meta:
        model = TeacherProfile
        fields = '__all__'
```

**Impact:** API responses now include nested user data (first_name, last_name, email, phone, date_joined, etc.)

---

## Frontend Component Update

**File:** `frontend/src/components/user-management.jsx`

### 1. Added New State Variables

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

### 2. Added Four Helper Functions

#### Function 1: openEditDialog
```javascript
const openEditDialog = (user, type) => {
  setEditingUser({ ...user, type });
  setEditForm({
    firstName: user.firstName || '',
    lastName: user.lastName || '',
    email: user.email || '',
    phone: user.phone || '',
    rollNumber: user.rollNumber || '',
    gradeLevel: user.gradeLevel || '',
    parentContact: user.parentContact || '',
    address: user.address || '',
    emergencyContact: user.emergencyContact || '',
    employeeId: user.employeeId || '',
    department: user.department || '',
    qualification: user.qualification || '',
    specialization: user.specialization || '',
    officeHours: user.officeHours || '',
  });
  setShowEditDialog(true);
};
```

#### Function 2: handleEditUser
```javascript
const handleEditUser = async () => {
  try {
    const type = editingUser.type;
    const userId = editingUser.id;
    
    if (type === 'student') {
      const updateData = {
        roll_number: editForm.rollNumber,
        grade_level: editForm.gradeLevel,
        parent_contact: editForm.parentContact,
        address: editForm.address,
        emergency_contact: editForm.emergencyContact,
      };
      await api.request(`/student-profiles/${userId}/`, { 
        method: 'PATCH', 
        body: JSON.stringify(updateData) 
      });
    } else {
      const updateData = {
        employee_id: editForm.employeeId,
        department: editForm.department,
        qualification: editForm.qualification,
        specialization: editForm.specialization,
        office_hours: editForm.officeHours,
      };
      await api.request(`/teacher-profiles/${userId}/`, { 
        method: 'PATCH', 
        body: JSON.stringify(updateData) 
      });
    }
    
    setShowEditDialog(false);
    setEditingUser(null);
    setEditForm({});
    await refreshUsers();
  } catch (err) {
    console.error('Error updating user:', err);
  }
};
```

#### Function 3: handleRemoveUser
```javascript
const handleRemoveUser = async (user, type) => {
  if (!window.confirm(`Are you sure you want to delete this ${type}? This action cannot be undone.`)) {
    return;
  }
  try {
    if (type === 'student') {
      await api.request(`/student-profiles/${user.id}/`, { method: 'DELETE' });
    } else {
      await api.request(`/teacher-profiles/${user.id}/`, { method: 'DELETE' });
    }
    setSelectedUser(null);
    await refreshUsers();
  } catch (err) {
    console.error('Error deleting user:', err);
  }
};
```

#### Function 4: refreshUsers
```javascript
const refreshUsers = async () => {
  try {
    // Fetch students with detailed mapping
    const studentsRes = await api.request('/student-profiles/');
    const students = (studentsRes.results || studentsRes || []).map(s => {
      const user = s.user || s;
      return {
        id: s.id || user.id,
        username: user.username || s.username,
        firstName: user.first_name || s.first_name,
        lastName: user.last_name || s.last_name,
        email: user.email || s.email,
        name: `${user.first_name || s.first_name || ''} ${user.last_name || s.last_name || ''}`.trim() || user.username || s.username,
        phone: user.phone || s.phone,
        avatarUrl: user.avatar_url || s.avatar_url,
        dateJoined: user.date_joined || s.date_joined,
        lastLogin: user.last_login || s.last_login,
        rollNumber: s.roll_number,
        gradeLevel: s.grade_level,
        dateOfBirth: s.date_of_birth,
        parentContact: s.parent_contact,
        address: s.address,
        emergencyContact: s.emergency_contact,
        averageGrade: parseFloat(s.average_grade) || 0,
        createdAt: s.created_at,
        totalCourses: 0,
        coursesEnrolled: [],
        attendance: 0,
        status: 'active',
      };
    });

    // Fetch teachers with detailed mapping
    const teachersRes = await api.request('/teacher-profiles/');
    const teachers = (teachersRes.results || teachersRes || []).map(t => {
      const user = t.user || t;
      return {
        id: t.id || user.id,
        username: user.username || t.username,
        firstName: user.first_name || t.first_name,
        lastName: user.last_name || t.last_name,
        email: user.email || t.email,
        name: `${user.first_name || t.first_name || ''} ${user.last_name || t.last_name || ''}`.trim() || user.username || t.username,
        phone: user.phone || t.phone,
        avatarUrl: user.avatar_url || t.avatar_url,
        dateJoined: user.date_joined || t.date_joined,
        lastLogin: user.last_login || t.last_login,
        employeeId: t.employee_id,
        department: t.department,
        qualification: t.qualification,
        specialization: t.specialization,
        hireDate: t.hire_date,
        officeHours: t.office_hours,
        averageRating: parseFloat(t.average_rating) || 0,
        createdAt: t.created_at,
        totalStudents: 0,
        coursesTeaching: [],
        status: 'active',
      };
    });

    // Fetch and attach enrollments
    try {
      const enrollmentsRes = await api.request('/enrollments/');
      const enrollments = enrollmentsRes.results || enrollmentsRes || [];
      students.forEach(student => {
        const studentEnrollments = enrollments.filter(e => e.student === student.id);
        student.totalCourses = studentEnrollments.length;
        student.coursesEnrolled = studentEnrollments.map(e => ({
          id: e.id,
          courseId: e.course,
          courseName: e.course_title || 'Unknown Course',
          status: e.status,
          progressPercentage: e.progress_percentage,
          enrollmentDate: e.enrollment_date,
        }));
      });
    } catch (err) {
      console.warn('Failed to fetch enrollments:', err);
    }

    // Fetch and calculate attendance
    try {
      const attendanceRes = await api.request('/attendance/');
      const records = attendanceRes.results || attendanceRes || [];
      students.forEach(student => {
        const studentAttendance = records.filter(r => r.student === student.id);
        if (studentAttendance.length > 0) {
          const presentCount = studentAttendance.filter(r => r.status === 'present').length;
          student.attendance = Math.round((presentCount / studentAttendance.length) * 100);
        }
      });
    } catch (err) {
      console.warn('Failed to fetch attendance:', err);
    }

    setStudentsData(students);
    setTeachersData(teachers);
  } catch (err) {
    console.error('Error refreshing users:', err);
  }
};
```

### 3. Added New EditUserDialog Component

```javascript
const EditUserDialog = () => (
  <Dialog open={showEditDialog} onOpenChange={setShowEditDialog}>
    <DialogContent className="max-w-2xl">
      <DialogHeader>
        <DialogTitle>Edit {editingUser?.type === 'student' ? 'Student' : 'Teacher'} Profile</DialogTitle>
        <DialogDescription>
          Update {editingUser?.type === 'student' ? 'student' : 'teacher'} information and details.
        </DialogDescription>
      </DialogHeader>
      {editingUser && (
        <div className="space-y-4 max-h-[60vh] overflow-y-auto">
          {/* Form fields for First Name, Last Name, Email, Phone */}
          {/* Conditional fields for Student OR Teacher */}
          {/* Save Changes and Cancel buttons */}
        </div>
      )}
    </DialogContent>
  </Dialog>
);
```

### 4. Updated handleAddUser Function

```javascript
const handleAddUser = async () => {
  try {
    if (activeTab === 'students') {
      await api.register({
        name: addForm.name,
        email: addForm.email,
        password: 'changeme123',
        role: 'student',
      });
    } else {
      await api.register({
        name: addForm.name,
        email: addForm.email,
        password: 'changeme123',
        role: 'teacher',
      });
    }
    setShowAddDialog(false);
    setAddForm({ name: '', email: '', id: '', phone: '', department: '' });
    await refreshUsers();  // ← Changed from manual fetch to refreshUsers()
  } catch (err) {
    console.error('Error adding user:', err);
  }
};
```

### 5. Updated Edit Button in UserCard Component

**Before:**
```javascript
<Button size="sm" variant="outline">
  <Edit className="h-3 w-3 mr-1" />
  Edit
</Button>
```

**After:**
```javascript
<Button size="sm" variant="outline" onClick={() => openEditDialog(user, type)}>
  <Edit className="h-3 w-3 mr-1" />
  Edit
</Button>
```

### 6. Updated Edit Button in UserDetailDialog Component

**Before:**
```javascript
<Button variant="outline">
  <Edit className="h-4 w-4 mr-2" />
  Edit
</Button>
```

**After:**
```javascript
<Button variant="outline" onClick={() => openEditDialog(selectedUser, type)}>
  <Edit className="h-4 w-4 mr-2" />
  Edit
</Button>
```

### 7. Updated Delete Button in UserDetailDialog Component

**Before:**
```javascript
<Button variant="destructive">
  <Trash2 className="h-4 w-4 mr-2" />
  Remove
</Button>
```

**After:**
```javascript
<Button variant="destructive" onClick={() => {
  handleRemoveUser(selectedUser, type);
}}>
  <Trash2 className="h-4 w-4 mr-2" />
  Remove
</Button>
```

### 8. Updated Return Statement

**Before:**
```javascript
return (
  <div className="space-y-6">
    {/* ... JSX ... */}
    <AddUserDialog />
    <UserDetailDialog user={selectedUser} type={activeTab === 'students' ? 'student' : 'teacher'} />
  </div>
);
```

**After:**
```javascript
return (
  <div className="space-y-6">
    {/* ... JSX ... */}
    <AddUserDialog />
    <EditUserDialog />  {/* ← Added this line */}
    <UserDetailDialog user={selectedUser} type={activeTab === 'students' ? 'student' : 'teacher'} />
  </div>
);
```

---

## Summary of Changes

| Change | Type | File | Lines | Impact |
|--------|------|------|-------|--------|
| Add nested user data | Backend | serializers.py | 2 | API returns complete user info |
| Add state variables | Frontend | user-management.jsx | 30 | Track edit dialog & form state |
| Add openEditDialog() | Frontend | user-management.jsx | 20 | Open edit dialog functionality |
| Add handleEditUser() | Frontend | user-management.jsx | 30 | PATCH update functionality |
| Add handleRemoveUser() | Frontend | user-management.jsx | 20 | DELETE with confirmation |
| Add refreshUsers() | Frontend | user-management.jsx | 130 | Refresh user list after changes |
| Add EditUserDialog | Frontend | user-management.jsx | 140 | Edit form modal |
| Update Edit buttons | Frontend | user-management.jsx | 3 | Wire up click handlers |
| Update Delete buttons | Frontend | user-management.jsx | 2 | Wire up click handlers |
| Add EditUserDialog render | Frontend | user-management.jsx | 1 | Mount dialog component |

**Total Changes:**
- Backend: 2 lines (serializer update)
- Frontend: ~370 lines (new functions, components, handlers)
- Total: ~372 lines of code

---

## Testing the Changes

### Manual Testing
1. Navigate to User Management page
2. Click "Edit" on any user card
3. Modify fields and click "Save Changes"
4. Verify user list updates
5. Click "Remove" on user card
6. Confirm deletion in browser dialog
7. Verify user is removed

### Automated Testing (if applicable)
```javascript
// Test openEditDialog
const user = { id: 1, firstName: 'John', type: 'student' };
openEditDialog(user, 'student');
// Assert: showEditDialog === true
// Assert: editingUser === user

// Test handleEditUser
await handleEditUser();
// Assert: api.request was called with PATCH
// Assert: showEditDialog === false

// Test handleRemoveUser
await handleRemoveUser(user, 'student');
// Assert: window.confirm was called
// Assert: api.request was called with DELETE
```

---

## Deployment Steps

1. **Update Backend Serializers**
   - Edit `backend/sarasedu_backend/core/serializers.py`
   - Add `user = UserSerializer(read_only=True)` to StudentProfileSerializer and TeacherProfileSerializer
   - Restart Django server

2. **Update Frontend Component**
   - Replace `frontend/src/components/user-management.jsx` with updated version
   - Vite will hot-reload
   - No need to restart if HMR is enabled

3. **Verify API Responses**
   - Test GET /api/student-profiles/
   - Verify nested user data is present

4. **Test Functionality**
   - Open frontend application
   - Test edit and delete operations
   - Check browser console for errors

---

## Rollback Instructions

If you need to revert changes:

**Backend:**
```python
# Revert serializers.py
class StudentProfileSerializer(serializers.ModelSerializer):
    # Remove: user = UserSerializer(read_only=True)
    class Meta:
        model = StudentProfile
        fields = '__all__'
```

**Frontend:**
- Remove all changes from user-management.jsx
- Restore original version from git: `git checkout frontend/src/components/user-management.jsx`
- Vite will hot-reload

---

## Support & Troubleshooting

### Issue: API returns "Method not allowed"
- Ensure backend ViewSet has proper permissions
- Check that viewset extends ModelViewSet or has create/update/destroy actions

### Issue: Changes don't persist
- Check network tab in DevTools
- Verify PATCH/DELETE requests are being sent
- Check backend logs for errors

### Issue: Edit dialog won't open
- Check browser console for errors
- Verify openEditDialog() is being called
- Check showEditDialog state

### Issue: Delete confirmation doesn't work
- Check window.confirm() is showing
- Verify browser allows JavaScript alerts
- Check browser console for errors
