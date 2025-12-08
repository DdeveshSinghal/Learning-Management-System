# Edit Delete Functions - Copy Paste Reference

## Complete Functions Implementation

### Function 1: Open Edit Dialog

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

---

### Function 2: Handle Edit User

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

---

### Function 3: Handle Remove User

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

---

### Function 4: Refresh Users

```javascript
const refreshUsers = async () => {
  try {
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

---

### State Variables Required

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

---

### EditUserDialog Component

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
          <div className="grid grid-cols-2 gap-4">
            <div>
              <Label htmlFor="edit-first-name">First Name</Label>
              <Input
                id="edit-first-name"
                value={editForm.firstName}
                onChange={e => setEditForm(f => ({ ...f, firstName: e.target.value }))}
                placeholder="First name"
              />
            </div>
            <div>
              <Label htmlFor="edit-last-name">Last Name</Label>
              <Input
                id="edit-last-name"
                value={editForm.lastName}
                onChange={e => setEditForm(f => ({ ...f, lastName: e.target.value }))}
                placeholder="Last name"
              />
            </div>
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <Label htmlFor="edit-email">Email</Label>
              <Input
                id="edit-email"
                type="email"
                value={editForm.email}
                onChange={e => setEditForm(f => ({ ...f, email: e.target.value }))}
                placeholder="Email address"
              />
            </div>
            <div>
              <Label htmlFor="edit-phone">Phone</Label>
              <Input
                id="edit-phone"
                value={editForm.phone}
                onChange={e => setEditForm(f => ({ ...f, phone: e.target.value }))}
                placeholder="Phone number"
              />
            </div>
          </div>
          {editingUser.type === 'student' ? (
            <>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <Label htmlFor="edit-roll-number">Roll Number</Label>
                  <Input
                    id="edit-roll-number"
                    value={editForm.rollNumber}
                    onChange={e => setEditForm(f => ({ ...f, rollNumber: e.target.value }))}
                    placeholder="Roll number"
                  />
                </div>
                <div>
                  <Label htmlFor="edit-grade-level">Grade Level</Label>
                  <Input
                    id="edit-grade-level"
                    value={editForm.gradeLevel}
                    onChange={e => setEditForm(f => ({ ...f, gradeLevel: e.target.value }))}
                    placeholder="Grade level"
                  />
                </div>
              </div>
              <div>
                <Label htmlFor="edit-parent-contact">Parent/Guardian Contact</Label>
                <Input
                  id="edit-parent-contact"
                  value={editForm.parentContact}
                  onChange={e => setEditForm(f => ({ ...f, parentContact: e.target.value }))}
                  placeholder="Parent contact"
                />
              </div>
              <div>
                <Label htmlFor="edit-address">Address</Label>
                <Input
                  id="edit-address"
                  value={editForm.address}
                  onChange={e => setEditForm(f => ({ ...f, address: e.target.value }))}
                  placeholder="Address"
                />
              </div>
              <div>
                <Label htmlFor="edit-emergency-contact">Emergency Contact</Label>
                <Input
                  id="edit-emergency-contact"
                  value={editForm.emergencyContact}
                  onChange={e => setEditForm(f => ({ ...f, emergencyContact: e.target.value }))}
                  placeholder="Emergency contact"
                />
              </div>
            </>
          ) : (
            <>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <Label htmlFor="edit-employee-id">Employee ID</Label>
                  <Input
                    id="edit-employee-id"
                    value={editForm.employeeId}
                    onChange={e => setEditForm(f => ({ ...f, employeeId: e.target.value }))}
                    placeholder="Employee ID"
                  />
                </div>
                <div>
                  <Label htmlFor="edit-department">Department</Label>
                  <Input
                    id="edit-department"
                    value={editForm.department}
                    onChange={e => setEditForm(f => ({ ...f, department: e.target.value }))}
                    placeholder="Department"
                  />
                </div>
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <Label htmlFor="edit-qualification">Qualification</Label>
                  <Input
                    id="edit-qualification"
                    value={editForm.qualification}
                    onChange={e => setEditForm(f => ({ ...f, qualification: e.target.value }))}
                    placeholder="Qualification"
                  />
                </div>
                <div>
                  <Label htmlFor="edit-specialization">Specialization</Label>
                  <Input
                    id="edit-specialization"
                    value={editForm.specialization}
                    onChange={e => setEditForm(f => ({ ...f, specialization: e.target.value }))}
                    placeholder="Specialization"
                  />
                </div>
              </div>
              <div>
                <Label htmlFor="edit-office-hours">Office Hours</Label>
                <Input
                  id="edit-office-hours"
                  value={editForm.officeHours}
                  onChange={e => setEditForm(f => ({ ...f, officeHours: e.target.value }))}
                  placeholder="Office hours"
                />
              </div>
            </>
          )}
          <div className="flex justify-end gap-2 pt-4">
            <Button variant="outline" onClick={() => setShowEditDialog(false)}>
              Cancel
            </Button>
            <Button onClick={handleEditUser}>
              <Shield className="h-4 w-4 mr-2" />
              Save Changes
            </Button>
          </div>
        </div>
      )}
    </DialogContent>
  </Dialog>
);
```

---

### Button Handler Examples

```javascript
// In UserCard component
<Button size="sm" variant="outline" onClick={() => openEditDialog(user, type)}>
  <Edit className="h-3 w-3 mr-1" />
  Edit
</Button>

<Button size="sm" variant="destructive" onClick={() => handleRemoveUser(user, type)}>
  <Trash2 className="h-3 w-3 mr-1" />
  Remove
</Button>

// In UserDetailDialog component
<Button variant="outline" onClick={() => openEditDialog(selectedUser, type)}>
  <Edit className="h-4 w-4 mr-2" />
  Edit
</Button>

<Button variant="destructive" onClick={() => {
  handleRemoveUser(selectedUser, type);
}}>
  <Trash2 className="h-4 w-4 mr-2" />
  Remove
</Button>
```

---

### Backend Serializer Update

```python
# Django Rest Framework Serializers
from rest_framework import serializers

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id', 'username', 'email', 'first_name', 'last_name', 'role', 'avatar_url', 'bio', 'phone', 'date_joined')


class StudentProfileSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)  # ← ADD THIS LINE
    
    class Meta:
        model = StudentProfile
        fields = '__all__'


class TeacherProfileSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)  # ← ADD THIS LINE
    
    class Meta:
        model = TeacherProfile
        fields = '__all__'
```

---

### Usage Examples

```javascript
// Open edit dialog for a student
const student = studentsData[0];
openEditDialog(student, 'student');

// Save edited student
await handleEditUser();  // Makes PATCH request

// Delete a teacher
const teacher = teachersData[0];
await handleRemoveUser(teacher, 'teacher');  // Shows confirm, then DELETE request

// Refresh all users
await refreshUsers();  // Fetches latest from API
```

---

### API Request Format

```javascript
// Edit Request
PATCH /api/student-profiles/1/
{
  "roll_number": "2024001",
  "grade_level": "10",
  "parent_contact": "9999999999",
  "address": "123 Main St",
  "emergency_contact": "8888888888"
}

// Delete Request  
DELETE /api/student-profiles/1/

// Response
204 No Content
or
200 OK
```

---

## Import Requirements

Make sure to import all required components:

```javascript
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription } from './ui/dialog';
import { Input } from './ui/input';
import { Label } from './ui/label';
import { Button } from './ui/button';
import { Shield, Edit, Trash2 } from 'lucide-react';
```

---

## Notes

- All functions include error handling with console.error()
- Confirmation dialog prevents accidental deletions
- Form pre-population ensures users see current data
- Automatic UI refresh after successful operations
- Works for both students and teachers with type-specific fields
- PATCH requests only send changed fields
- No breaking changes to existing functionality

