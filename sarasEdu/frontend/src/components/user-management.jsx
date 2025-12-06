import React, { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Input } from './ui/input';
import { Label } from './ui/label';
import { Badge } from './ui/badge';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from './ui/select';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger, DialogDescription } from './ui/dialog';
import { Tabs, TabsContent, TabsList, TabsTrigger } from './ui/tabs';
import { Avatar, AvatarFallback } from './ui/avatar';
import { 
  Users,
  Plus,
  Search,
  Filter,
  Edit,
  Trash2,
  UserCheck,
  UserX,
  Mail,
  Phone,
  Calendar,
  BookOpen,
  Clock,
  Eye,
  Download,
  Upload,
  Shield,
  GraduationCap,
  Users as TeacherIcon
} from 'lucide-react';

// Props/types removed for JS build. Fetch users from API in production.
export function UserManagement({ userType, onSelectStudent }) {
  const [activeTab, setActiveTab] = useState(userType === 'teacher' ? 'teachers' : 'students');
  const [searchQuery, setSearchQuery] = useState('');
  const [showAddDialog, setShowAddDialog] = useState(false);
  const [selectedUser, setSelectedUser] = useState(null);

  // Users data should be fetched from an API in production. Removed demo/sample users.
  const studentsData = [];

  // Teachers data should be fetched from an API in production. Removed demo/sample teachers.
  const teachersData = [];

  const getStatusColor = (status) => {
    switch (status) {
      case 'active': return 'bg-green-100 text-green-800';
      case 'inactive': return 'bg-red-100 text-red-800';
      case 'on_leave': return 'bg-yellow-100 text-yellow-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const getStatusIcon = (status) => {
    switch (status) {
      case 'active': return UserCheck;
      case 'inactive': return UserX;
      default: return Users;
    }
  };

  const filteredStudents = studentsData.filter(student =>
    student.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
    student.email.toLowerCase().includes(searchQuery.toLowerCase()) ||
    student.rollNumber.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const filteredTeachers = teachersData.filter(teacher =>
    teacher.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
    teacher.email.toLowerCase().includes(searchQuery.toLowerCase()) ||
    teacher.department.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const AddUserDialog = () => (
    <Dialog open={showAddDialog} onOpenChange={setShowAddDialog}>
      <DialogContent className="max-w-2xl">
        <DialogHeader>
          <DialogTitle>Add New {activeTab === 'students' ? 'Student' : 'Teacher'}</DialogTitle>
          <DialogDescription>
            Add a new {activeTab === 'students' ? 'student' : 'teacher'} to the platform with their basic information.
          </DialogDescription>
        </DialogHeader>
        <div className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <Label htmlFor="name">Full Name</Label>
              <Input id="name" placeholder="Enter full name" />
            </div>
            <div>
              <Label htmlFor="email">Email Address</Label>
              <Input id="email" type="email" placeholder="Enter email" />
            </div>
          </div>
          
          <div className="grid grid-cols-2 gap-4">
            <div>
              <Label htmlFor="id">
                {activeTab === 'students' ? 'Roll Number' : 'Employee ID'}
              </Label>
              <Input id="id" placeholder={`Enter ${activeTab === 'students' ? 'roll number' : 'employee ID'}`} />
            </div>
            <div>
              <Label htmlFor="phone">Phone Number</Label>
              <Input id="phone" placeholder="Enter phone number" />
            </div>
          </div>
          
          {activeTab === 'teachers' && (
            <div>
              <Label htmlFor="department">Department</Label>
              <Select>
                <SelectTrigger>
                  <SelectValue placeholder="Select department" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="mathematics">Mathematics</SelectItem>
                  <SelectItem value="physics">Physics</SelectItem>
                  <SelectItem value="computer-science">Computer Science</SelectItem>
                  <SelectItem value="chemistry">Chemistry</SelectItem>
                </SelectContent>
              </Select>
            </div>
          )}
          
          <div className="flex justify-end gap-2">
            <Button variant="outline" onClick={() => setShowAddDialog(false)}>
              Cancel
            </Button>
            <Button>
              <Plus className="h-4 w-4 mr-2" />
              Add {activeTab === 'students' ? 'Student' : 'Teacher'}
            </Button>
          </div>
        </div>
      </DialogContent>
    </Dialog>
  );

  const UserDetailDialog = ({ user, type }) => (
    <Dialog open={!!selectedUser} onOpenChange={() => setSelectedUser(null)}>
      <DialogContent className="max-w-3xl max-h-[80vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>{type === 'student' ? 'Student' : 'Teacher'} Details</DialogTitle>
          <DialogDescription>
            View detailed information about this {type === 'student' ? 'student' : 'teacher'} including their profile and activity.
          </DialogDescription>
        </DialogHeader>
        {selectedUser && (
          <div className="space-y-6">
            <div className="flex items-start gap-4">
              <Avatar className="h-16 w-16">
                <AvatarFallback>{selectedUser.name?.split(' ').map((n) => n[0]).join('')}</AvatarFallback>
              </Avatar>
              <div className="flex-1">
                <h3 className="text-xl font-semibold">{selectedUser.name}</h3>
                <p className="text-muted-foreground">{selectedUser.email}</p>
                <Badge className={`mt-2 ${getStatusColor(selectedUser.status)}`}>
                  {selectedUser.status}
                </Badge>
              </div>
            </div>
            
            <div className="grid grid-cols-2 gap-6">
              <div>
                <h4 className="font-semibold mb-3">Basic Information</h4>
                <div className="space-y-2">
                  <div className="flex items-center gap-2">
                    <Mail className="h-4 w-4 text-muted-foreground" />
                    <span className="text-sm">{selectedUser.email}</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <Phone className="h-4 w-4 text-muted-foreground" />
                    <span className="text-sm">{selectedUser.phone}</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <Calendar className="h-4 w-4 text-muted-foreground" />
                    <span className="text-sm">Joined: {new Date(selectedUser.joinDate).toLocaleDateString()}</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <Clock className="h-4 w-4 text-muted-foreground" />
                    <span className="text-sm">Last Login: {new Date(selectedUser.lastLogin).toLocaleString()}</span>
                  </div>
                </div>
              </div>
              
              <div>
                <h4 className="font-semibold mb-3">
                  {type === 'student' ? 'Academic Information' : 'Teaching Information'}
                </h4>
                <div className="space-y-2">
                  {type === 'student' ? (
                    <>
                      <div className="flex items-center gap-2">
                        <BookOpen className="h-4 w-4 text-muted-foreground" />
                        <span className="text-sm">Courses: {selectedUser.totalCourses}</span>
                      </div>
                      <div className="flex items-center gap-2">
                        <UserCheck className="h-4 w-4 text-muted-foreground" />
                        <span className="text-sm">Attendance: {selectedUser.attendance}%</span>
                      </div>
                      <div className="flex items-center gap-2">
                        <GraduationCap className="h-4 w-4 text-muted-foreground" />
                        <span className="text-sm">Avg Grade: {selectedUser.averageGrade}%</span>
                      </div>
                    </>
                  ) : (
                    <>
                      <div className="flex items-center gap-2">
                        <TeacherIcon className="h-4 w-4 text-muted-foreground" />
                        <span className="text-sm">Department: {selectedUser.department}</span>
                      </div>
                      <div className="flex items-center gap-2">
                        <Users className="h-4 w-4 text-muted-foreground" />
                        <span className="text-sm">Students: {selectedUser.totalStudents}</span>
                      </div>
                      <div className="flex items-center gap-2">
                        <GraduationCap className="h-4 w-4 text-muted-foreground" />
                        <span className="text-sm">Rating: {selectedUser.averageRating}/5</span>
                      </div>
                    </>
                  )}
                </div>
              </div>
            </div>
            
            <div>
              <h4 className="font-semibold mb-3">
                {type === 'student' ? 'Enrolled Courses' : 'Teaching Courses'}
              </h4>
              <div className="flex flex-wrap gap-2">
                {(type === 'student' ? selectedUser.coursesEnrolled : selectedUser.coursesTeaching).map((course, index) => (
                  <Badge key={index} variant="outline">{course}</Badge>
                ))}
              </div>
            </div>
            
            <div className="flex justify-end gap-2">
              <Button variant="outline">
                <Edit className="h-4 w-4 mr-2" />
                Edit
              </Button>
              <Button variant="outline">
                <Mail className="h-4 w-4 mr-2" />
                Send Message
              </Button>
              <Button variant="destructive">
                <Trash2 className="h-4 w-4 mr-2" />
                Remove
              </Button>
            </div>
          </div>
        )}
      </DialogContent>
    </Dialog>
  );

  const UserCard = ({ user, type }) => {
    const StatusIcon = getStatusIcon(user.status);
    
    return (
      <Card className="hover:shadow-lg transition-shadow">
        <CardContent className="p-4">
          <div className="flex items-start gap-3">
            <Avatar className="h-12 w-12">
              <AvatarFallback>{user.name.split(' ').map((n) => n[0]).join('')}</AvatarFallback>
            </Avatar>
            
            <div className="flex-1 min-w-0">
              <div className="flex items-center justify-between">
                <h3 className="font-semibold truncate">{user.name}</h3>
                <Badge className={getStatusColor(user.status)}>
                  <StatusIcon className="h-3 w-3 mr-1" />
                  {user.status}
                </Badge>
              </div>
              
              <p className="text-sm text-muted-foreground truncate">{user.email}</p>
              <p className="text-sm text-muted-foreground">
                {type === 'student' ? `Roll: ${user.rollNumber}` : `Dept: ${user.department}`}
              </p>
              
              <div className="flex items-center gap-4 mt-3 text-xs text-muted-foreground">
                <span>
                  {type === 'student' ? `${user.totalCourses} courses` : `${user.totalStudents} students`}
                </span>
                <span>
                  {type === 'student' ? `${user.attendance}% attendance` : `${user.averageRating}★ rating`}
                </span>
              </div>
              
              <div className="flex gap-2 mt-3">
                <Button 
                  size="sm" 
                  variant="outline" 
                  onClick={() => {
                    if (type === 'student' && onSelectStudent) {
                      onSelectStudent(user.id.toString());
                    } else {
                      setSelectedUser(user);
                    }
                  }}
                >
                  <Eye className="h-3 w-3 mr-1" />
                  View {type === 'student' && onSelectStudent ? 'Details' : ''}
                </Button>
                <Button size="sm" variant="outline">
                  <Edit className="h-3 w-3 mr-1" />
                  Edit
                </Button>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>
    );
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-3xl font-bold">User Management</h2>
          <p className="text-muted-foreground">Manage students, teachers, and their information</p>
        </div>
        
        <div className="flex items-center gap-2">
          <Button variant="outline">
            <Download className="h-4 w-4 mr-2" />
            Export
          </Button>
          <Button onClick={() => setShowAddDialog(true)}>
            <Plus className="h-4 w-4 mr-2" />
            Add {activeTab === 'students' ? 'Student' : 'Teacher'}
          </Button>
        </div>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <Card>
          <CardContent className="p-4">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-full bg-blue-100 flex items-center justify-center">
                <GraduationCap className="h-5 w-5 text-blue-600" />
              </div>
              <div>
                <p className="text-sm text-muted-foreground">Total Students</p>
                <p className="text-2xl font-bold">{studentsData.length}</p>
                <p className="text-xs text-green-600">N/A this month</p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-4">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-full bg-green-100 flex items-center justify-center">
                <TeacherIcon className="h-5 w-5 text-green-600" />
              </div>
              <div>
                <p className="text-sm text-muted-foreground">Total Teachers</p>
                <p className="text-2xl font-bold">{teachersData.length}</p>
                <p className="text-xs text-blue-600">N/A this month</p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-4">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-full bg-emerald-100 flex items-center justify-center">
                <UserCheck className="h-5 w-5 text-emerald-600" />
              </div>
              <div>
                <p className="text-sm text-muted-foreground">Active Users</p>
                <p className="text-2xl font-bold">
                  {[...studentsData, ...teachersData].filter(u => u.status === 'active').length}
                </p>
                <p className="text-xs text-green-600">0 active rate</p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-4">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-full bg-purple-100 flex items-center justify-center">
                <BookOpen className="h-5 w-5 text-purple-600" />
              </div>
              <div>
                <p className="text-sm text-muted-foreground">Total Enrollments</p>
                <p className="text-2xl font-bold">
                  {studentsData.reduce((sum, s) => sum + s.totalCourses, 0)}
                </p>
                <p className="text-xs text-muted-foreground">Course enrollments</p>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
        <div className="flex items-center justify-between">
          <TabsList>
            {userType !== 'teacher' && (
              <TabsTrigger value="students">Students ({studentsData.length})</TabsTrigger>
            )}
            {userType !== 'student' && (
              <TabsTrigger value="teachers">Teachers ({teachersData.length})</TabsTrigger>
            )}
          </TabsList>
          
          <div className="flex items-center gap-2">
            <div className="relative">
              <Search className="h-4 w-4 absolute left-3 top-1/2 transform -translate-y-1/2 text-muted-foreground" />
              <Input
                placeholder="Search users..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="w-64 pl-10"
              />
            </div>
            <Button variant="outline">
              <Filter className="h-4 w-4 mr-2" />
              Filter
            </Button>
          </div>
        </div>

        <TabsContent value="students" className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {filteredStudents.map((student) => (
              <UserCard key={student.id} user={student} type="student" />
            ))}
          </div>
          
          {filteredStudents.length === 0 && (
            <div className="text-center py-12">
              <GraduationCap className="h-12 w-12 text-muted-foreground mx-auto mb-4" />
              <h3 className="text-lg font-semibold mb-2">No Students Found</h3>
              <p className="text-muted-foreground mb-4">Try adjusting your search criteria</p>
            </div>
          )}
        </TabsContent>

        <TabsContent value="teachers" className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {filteredTeachers.map((teacher) => (
              <UserCard key={teacher.id} user={teacher} type="teacher" />
            ))}
          </div>
          
          {filteredTeachers.length === 0 && (
            <div className="text-center py-12">
              <TeacherIcon className="h-12 w-12 text-muted-foreground mx-auto mb-4" />
              <h3 className="text-lg font-semibold mb-2">No Teachers Found</h3>
              <p className="text-muted-foreground mb-4">Try adjusting your search criteria</p>
            </div>
          )}
        </TabsContent>
      </Tabs>

      <AddUserDialog />
      <UserDetailDialog user={selectedUser} type={activeTab === 'students' ? 'student' : 'teacher'} />
    </div>
  );
}