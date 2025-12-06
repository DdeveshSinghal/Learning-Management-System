import React, { useState } from 'react';
import { Button } from './ui/button';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Input } from './ui/input';
import { Label } from './ui/label';
import { Textarea } from './ui/textarea';
import { Badge } from './ui/badge';
import { Avatar, AvatarFallback, AvatarImage } from './ui/avatar';
import { Progress } from './ui/progress';
import { Tabs, TabsContent, TabsList, TabsTrigger } from './ui/tabs';
import { 
  User, 
  Mail, 
  Phone, 
  MapPin, 
  Calendar, 
  Edit, 
  Save, 
  Camera, 
  Award, 
  BookOpen, 
  Clock, 
  Star,
  Shield,
  Settings,
  Bell,
  Lock,
  Eye,
  EyeOff,
  Download,
  Upload,
  Trophy,
  Target,
  TrendingUp,
  Users,
  Briefcase,
  GraduationCap
} from 'lucide-react'; 

// Props/types removed for JS build. User data should be fetched from API based on userId and userRole.

export function UserProfile({ userRole, userId, userName }) {
  const [isEditing, setIsEditing] = useState(false);
  const [showPassword, setShowPassword] = useState(false);

  // User data should be fetched from API based on userId and userRole. Removed all demo/sample user data.
  const getUserData = () => {
    const baseData = {
      id: userId,
      name: userName || '',
      email: '',
      phone: '',
      address: '',
      joinDate: '',
      avatar: null,
      bio: ''
    };

    switch (userRole) {
      case 'student':
        return {
          ...baseData,
          studentId: '',
          grade: '',
          section: '',
          rollNumber: '',
          parentName: '',
          parentPhone: '',
          dateOfBirth: '',
          stats: {
            coursesEnrolled: 0,
            assignmentsCompleted: 0,
            testsCompleted: 0,
            currentGPA: 0,
            attendanceRate: 0,
            rank: 0,
            totalPoints: 0
          },
          achievements: []
        };

      case 'teacher':
        return {
          ...baseData,
          employeeId: '',
          department: '',
          qualification: '',
          experience: '',
          specialization: '',
          officeHours: '',
          stats: {
            coursesTeaching: 0,
            totalStudents: 0,
            avgClassRating: 0,
            materialsUploaded: 0,
            testsCreated: 0,
            assignmentsGiven: 0
          },
          courses: []
        };

      case 'admin':
        return {
          ...baseData,
          employeeId: '',
          position: '',
          department: '',
          accessLevel: '',
          lastLogin: '',
          stats: {
            totalUsers: 0,
            activeCourses: 0,
            systemUptime: 0,
            dataBackups: 0,
            securityScans: 0,
            supportTickets: 0
          },
          systemInfo: {
            serverStatus: '',
            databaseStatus: '',
            backupStatus: '',
            securityStatus: ''
          }
        };

      default:
        return baseData;
    }
  };

  const userData = getUserData();

  const PersonalInfoTab = () => (
    <div className="space-y-6">
      <Card>
        <CardHeader>
          <div className="flex items-center justify-between">
            <CardTitle>Personal Information</CardTitle>
            <Button
              variant="outline"
              onClick={() => setIsEditing(!isEditing)}
            >
              {isEditing ? <Save className="h-4 w-4 mr-2" /> : <Edit className="h-4 w-4 mr-2" />}
              {isEditing ? 'Save' : 'Edit'}
            </Button>
          </div>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="flex items-center gap-6">
            <div className="relative">
              <Avatar className="h-24 w-24">
                <AvatarImage src={userData.avatar} />
                <AvatarFallback className="text-2xl">{userName?.[0] || 'U'}</AvatarFallback>
              </Avatar>
              {isEditing && (
                <Button size="sm" className="absolute -bottom-2 -right-2 rounded-full">
                  <Camera className="h-3 w-3" />
                </Button>
              )}
            </div>
            <div className="flex-1">
              <h3 className="text-2xl font-bold">{userData.name}</h3>
              <p className="text-muted-foreground">
                {userRole === 'student' && `${userData.grade} - Section ${userData.section}`}
                {userRole === 'teacher' && `${userData.department} Department`}
                {userRole === 'admin' && userData.position}
              </p>
              <div className="flex items-center gap-4 mt-2 text-sm text-muted-foreground">
                <span className="flex items-center gap-1">
                  <Calendar className="h-3 w-3" />
                  Joined {userData.joinDate}
                </span>
                {userRole === 'student' && userData.studentId && (
                  <span>ID: {userData.studentId}</span>
                )}
                {userRole === 'teacher' && userData.employeeId && (
                  <span>ID: {userData.employeeId}</span>
                )}
              </div>
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <Label>Full Name</Label>
              <Input 
                value={userData.name} 
                readOnly={!isEditing}
                className={!isEditing ? 'bg-muted' : ''}
              />
            </div>
            <div>
              <Label>Email Address</Label>
              <Input 
                value={userData.email} 
                readOnly={!isEditing}
                className={!isEditing ? 'bg-muted' : ''}
              />
            </div>
            <div>
              <Label>Phone Number</Label>
              <Input 
                value={userData.phone} 
                readOnly={!isEditing}
                className={!isEditing ? 'bg-muted' : ''}
              />
            </div>
            {userRole === 'student' && userData.dateOfBirth && (
              <div>
                <Label>Date of Birth</Label>
                <Input 
                  type="date"
                  value={userData.dateOfBirth} 
                  readOnly={!isEditing}
                  className={!isEditing ? 'bg-muted' : ''}
                />
              </div>
            )}
            {userRole === 'teacher' && userData.qualification && (
              <div>
                <Label>Qualification</Label>
                <Input 
                  value={userData.qualification} 
                  readOnly={!isEditing}
                  className={!isEditing ? 'bg-muted' : ''}
                />
              </div>
            )}
            {userRole === 'admin' && userData.accessLevel && (
              <div>
                <Label>Access Level</Label>
                <Input 
                  value={userData.accessLevel} 
                  readOnly={!isEditing}
                  className={!isEditing ? 'bg-muted' : ''}
                />
              </div>
            )}
          </div>

          <div>
            <Label>Address</Label>
            <Textarea 
              value={userData.address} 
              readOnly={!isEditing}
              className={!isEditing ? 'bg-muted' : ''}
            />
          </div>

          <div>
            <Label>Bio</Label>
            <Textarea 
              value={userData.bio} 
              readOnly={!isEditing}
              className={!isEditing ? 'bg-muted' : ''}
              placeholder="Tell us about yourself..."
            />
          </div>

          {/* Role-specific fields */}
          {userRole === 'student' && userData.parentName && (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <Label>Parent/Guardian Name</Label>
                <Input 
                  value={userData.parentName} 
                  readOnly={!isEditing}
                  className={!isEditing ? 'bg-muted' : ''}
                />
              </div>
              <div>
                <Label>Parent/Guardian Phone</Label>
                <Input 
                  value={userData.parentPhone} 
                  readOnly={!isEditing}
                  className={!isEditing ? 'bg-muted' : ''}
                />
              </div>
            </div>
          )}

          {userRole === 'teacher' && (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <Label>Experience</Label>
                <Input 
                  value={userData.experience} 
                  readOnly={!isEditing}
                  className={!isEditing ? 'bg-muted' : ''}
                />
              </div>
              <div>
                <Label>Specialization</Label>
                <Input 
                  value={userData.specialization} 
                  readOnly={!isEditing}
                  className={!isEditing ? 'bg-muted' : ''}
                />
              </div>
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );

  const StatsTab = () => (
    <div className="space-y-6">
      {userRole === 'student' && userData.stats && (
        <>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            <Card>
              <CardContent className="p-4 text-center">
                <div className="text-2xl font-bold text-blue-600">{userData.stats.coursesEnrolled}</div>
                <div className="text-sm text-muted-foreground">Courses Enrolled</div>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="p-4 text-center">
                <div className="text-2xl font-bold text-green-600">{userData.stats.currentGPA}</div>
                <div className="text-sm text-muted-foreground">Current GPA</div>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="p-4 text-center">
                <div className="text-2xl font-bold text-purple-600">{userData.stats.attendanceRate}%</div>
                <div className="text-sm text-muted-foreground">Attendance Rate</div>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="p-4 text-center">
                <div className="text-2xl font-bold text-yellow-600">#{userData.stats.rank}</div>
                <div className="text-sm text-muted-foreground">Class Rank</div>
              </CardContent>
            </Card>
          </div>

          <Card>
            <CardHeader>
              <CardTitle>Academic Progress</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div>
                <div className="flex justify-between mb-2">
                  <span>Assignments Completed</span>
                  <span>{userData.stats.assignmentsCompleted}/50</span>
                </div>
                <Progress value={(userData.stats.assignmentsCompleted / 50) * 100} />
              </div>
              <div>
                <div className="flex justify-between mb-2">
                  <span>Tests Completed</span>
                  <span>{userData.stats.testsCompleted}/15</span>
                </div>
                <Progress value={(userData.stats.testsCompleted / 15) * 100} />
              </div>
              <div>
                <div className="flex justify-between mb-2">
                  <span>Attendance Rate</span>
                  <span>{userData.stats.attendanceRate}%</span>
                </div>
                <Progress value={userData.stats.attendanceRate} />
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Recent Achievements</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-3">
                {userData.achievements.map((achievement, index) => (
                  <div key={index} className="flex items-center justify-between p-3 bg-green-50 border border-green-200 rounded">
                    <div>
                      <h4 className="font-medium">{achievement.title}</h4>
                      <p className="text-sm text-muted-foreground">{achievement.date}</p>
                    </div>
                    <Badge className="bg-green-600">+{achievement.points} pts</Badge>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </>
      )}

      {userRole === 'teacher' && userData.stats && (
        <>
          <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
            <Card>
              <CardContent className="p-4 text-center">
                <div className="text-2xl font-bold text-blue-600">{userData.stats.coursesTeaching}</div>
                <div className="text-sm text-muted-foreground">Courses Teaching</div>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="p-4 text-center">
                <div className="text-2xl font-bold text-green-600">{userData.stats.totalStudents}</div>
                <div className="text-sm text-muted-foreground">Total Students</div>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="p-4 text-center">
                <div className="text-2xl font-bold text-yellow-600">{userData.stats.avgClassRating}</div>
                <div className="text-sm text-muted-foreground">Avg Class Rating</div>
              </CardContent>
            </Card>
          </div>

          <Card>
            <CardHeader>
              <CardTitle>Teaching Statistics</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid grid-cols-3 gap-4 text-center">
                <div>
                  <div className="text-lg font-bold">{userData.stats.materialsUploaded}</div>
                  <div className="text-sm text-muted-foreground">Materials Uploaded</div>
                </div>
                <div>
                  <div className="text-lg font-bold">{userData.stats.testsCreated}</div>
                  <div className="text-sm text-muted-foreground">Tests Created</div>
                </div>
                <div>
                  <div className="text-lg font-bold">{userData.stats.assignmentsGiven}</div>
                  <div className="text-sm text-muted-foreground">Assignments Given</div>
                </div>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Course Performance</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {userData.courses.map((course, index) => (
                  <div key={index} className="flex items-center justify-between p-3 border rounded">
                    <div>
                      <h4 className="font-medium">{course.name}</h4>
                      <p className="text-sm text-muted-foreground">{course.students} students</p>
                    </div>
                    <div className="flex items-center gap-2">
                      <Star className="h-4 w-4 text-yellow-500" />
                      <span>{course.rating}</span>
                    </div>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </>
      )}

      {userRole === 'admin' && userData.stats && (
        <>
          <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
            <Card>
              <CardContent className="p-4 text-center">
                <div className="text-2xl font-bold text-blue-600">{userData.stats.totalUsers}</div>
                <div className="text-sm text-muted-foreground">Total Users</div>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="p-4 text-center">
                <div className="text-2xl font-bold text-green-600">{userData.stats.activeCourses}</div>
                <div className="text-sm text-muted-foreground">Active Courses</div>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="p-4 text-center">
                <div className="text-2xl font-bold text-yellow-600">{userData.stats.systemUptime}%</div>
                <div className="text-sm text-muted-foreground">System Uptime</div>
              </CardContent>
            </Card>
          </div>

          <Card>
            <CardHeader>
              <CardTitle>System Health</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-2 gap-4">
                {Object.entries(userData.systemInfo).map(([key, value]) => (
                  <div key={key} className="flex items-center justify-between p-3 border rounded">
                    <span className="font-medium capitalize">{key.replace(/([A-Z])/g, ' $1')}</span>
                    <Badge variant={value === 'Online' || value === 'Healthy' || value === 'Up to date' || value === 'Secure' ? 'default' : 'destructive'}>
                      {value}
                    </Badge>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </>
      )}
    </div>
  );

  const SecurityTab = () => (
    <div className="space-y-6">
      <Card>
        <CardHeader>
          <CardTitle>Account Security</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div>
            <Label>Current Password</Label>
            <div className="relative">
              <Input 
                type={showPassword ? "text" : "password"} 
                placeholder="Enter current password"
              />
              <Button
                type="button"
                variant="ghost"
                size="sm"
                className="absolute right-0 top-0 h-full px-3"
                onClick={() => setShowPassword(!showPassword)}
              >
                {showPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
              </Button>
            </div>
          </div>
          
          <div>
            <Label>New Password</Label>
            <Input type="password" placeholder="Enter new password" />
          </div>
          
          <div>
            <Label>Confirm New Password</Label>
            <Input type="password" placeholder="Confirm new password" />
          </div>
          
          <Button>
            <Lock className="h-4 w-4 mr-2" />
            Update Password
          </Button>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Two-Factor Authentication</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="flex items-center justify-between">
            <div>
              <h4 className="font-medium">Enable 2FA</h4>
              <p className="text-sm text-muted-foreground">Add an extra layer of security to your account</p>
            </div>
            <Button variant="outline">Enable</Button>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Login Activity</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-3">
            {[
              { device: 'Chrome on Windows', location: 'New York, US', time: '2 hours ago', current: true },
              { device: 'Safari on iPhone', location: 'New York, US', time: '1 day ago', current: false },
              { device: 'Chrome on Windows', location: 'New York, US', time: '3 days ago', current: false }
            ].map((session, index) => (
              <div key={index} className="flex items-center justify-between p-3 border rounded">
                <div>
                  <h4 className="font-medium">{session.device}</h4>
                  <p className="text-sm text-muted-foreground">{session.location} • {session.time}</p>
                </div>
                <div className="flex items-center gap-2">
                  {session.current && <Badge variant="default">Current</Badge>}
                  {!session.current && <Button variant="outline" size="sm">Revoke</Button>}
                </div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>
    </div>
  );

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-3xl font-bold">Profile</h2>
          <p className="text-muted-foreground">Manage your account information and settings</p>
        </div>
        <div className="flex gap-2">
          <Button variant="outline">
            <Download className="h-4 w-4 mr-2" />
            Export Data
          </Button>
          <Button variant="outline">
            <Upload className="h-4 w-4 mr-2" />
            Import Data
          </Button>
        </div>
      </div>

      <Tabs defaultValue="personal" className="space-y-4">
        <TabsList>
          <TabsTrigger value="personal">Personal Info</TabsTrigger>
          <TabsTrigger value="stats">Statistics</TabsTrigger>
          <TabsTrigger value="security">Security</TabsTrigger>
          <TabsTrigger value="preferences">Preferences</TabsTrigger>
        </TabsList>

        <TabsContent value="personal">
          <PersonalInfoTab />
        </TabsContent>

        <TabsContent value="stats">
          <StatsTab />
        </TabsContent>

        <TabsContent value="security">
          <SecurityTab />
        </TabsContent>

        <TabsContent value="preferences">
          <Card>
            <CardHeader>
              <CardTitle>Notification Preferences</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="space-y-3">
                {[
                  { title: 'Email Notifications', description: 'Receive email updates about assignments and tests' },
                  { title: 'Push Notifications', description: 'Get browser notifications for important updates' },
                  { title: 'SMS Notifications', description: 'Receive text messages for urgent notifications' },
                  { title: 'Weekly Digest', description: 'Get a weekly summary of your activity' }
                ].map((pref, index) => (
                  <div key={index} className="flex items-center justify-between">
                    <div>
                      <h4 className="font-medium">{pref.title}</h4>
                      <p className="text-sm text-muted-foreground">{pref.description}</p>
                    </div>
                    <input type="checkbox" className="rounded" defaultChecked={index < 2} />
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  );
}