import React from 'react';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Progress } from './ui/progress';
import { 
  Video, 
  Clock,  
  Calendar,
  Activity,
  BookOpen,
  Users,
  AlertTriangle,
  Bell,
  Award,
  Mail,
  Settings,
  BarChart3,
  FileText,
  ExternalLink
} from 'lucide-react';

// Sections data should be fetched from API.
export function EnhancedDashboardSections({ userRole }) {
  const upcomingClasses = [];
  const recentActivity = [];

  const StudentSections = () => (
    <div className="space-y-6">
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Video className="h-5 w-5" />
            Upcoming Classes
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-3">
            {upcomingClasses.map((class_) => (
              <div key={class_.id} className="flex items-center justify-between p-4 border rounded-lg hover:bg-gray-50 transition-colors">
                <div className="flex items-center gap-3">
                  <div className={`w-3 h-3 rounded-full ${class_.status === 'live' ? 'bg-red-500 animate-pulse' : 'bg-blue-500'}`} />
                  <div>
                    <h4 className="font-medium">{class_.course}</h4>
                    <p className="text-sm text-muted-foreground">{class_.teacher}</p>
                    <div className="flex items-center gap-2 text-xs text-muted-foreground">
                      <Clock className="h-3 w-3" />
                      <span>{class_.time}</span>
                      <span>•</span>
                      <span>{class_.date}</span>
                      <span>•</span>
                      <span>{class_.platform}</span>
                    </div>
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  {class_.status === 'live' && (
                    <Badge className="bg-red-100 text-red-700">Live Now</Badge>
                  )}
                  <Button size="sm" className={class_.status === 'live' ? 'bg-red-600 hover:bg-red-700' : ''}>
                    <Video className="h-3 w-3 mr-1" />
                    {class_.status === 'live' ? 'Join Now' : 'Join Class'}
                  </Button>
                </div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Activity className="h-5 w-5" />
            Recent Activity
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-3">
            {recentActivity.length === 0 ? (
              <div className="text-sm text-muted-foreground">No recent activity</div>
            ) : (
              recentActivity.map((activity) => (
                <div key={activity.id} className="flex items-center gap-3 p-3 border rounded-lg hover:bg-gray-50 transition-colors">
                  <div className={`w-8 h-8 rounded-full bg-gray-100 flex items-center justify-center`}>
                    {activity.icon ? <activity.icon className={`h-4 w-4 ${activity.color || ''}`} /> : null}
                  </div>
                  <div className="flex-1">
                    <h4 className="font-medium text-sm">{activity.title}</h4>
                    <p className="text-xs text-muted-foreground">{activity.course}</p>
                  </div>
                  <div className="text-xs text-muted-foreground">{activity.time}</div>
                </div>
              ))
            )}
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Calendar className="h-5 w-5" />
            My Attendance Summary
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4" />
        </CardContent>
      </Card>
    </div>
  );

  const TeacherSections = () => (
    <div className="space-y-6">
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <BookOpen className="h-5 w-5" />
            My Courses
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {[].map((course) => (
              <div key={course.id} className="p-4 border rounded-lg hover:bg-gray-50 transition-colors">
                <div className="flex justify-between items-start mb-3">
                  <h4 className="font-medium">{course.title}</h4>
                  <Badge variant="secondary">{course.students} students</Badge>
                </div>
                <div className="space-y-2">
                  <div className="flex justify-between text-sm">
                    <span>Course Progress</span>
                    <span>{course.progress}%</span>
                  </div>
                  <Progress value={course.progress} />
                  <p className="text-xs text-muted-foreground">Next class: {course.nextClass}</p>
                </div>
                <div className="flex gap-2 mt-3">
                  <Button size="sm" variant="outline" className="flex-1">
                    <ExternalLink className="h-3 w-3 mr-1" />
                    View Course
                  </Button>
                  <Button size="sm" variant="outline">Edit</Button>
                </div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Calendar className="h-5 w-5" />
            Today's Schedule
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-3">
            {[].map((schedule, index) => (
              <div key={index} className="flex items-center justify-between p-3 border rounded-lg">
                <div className="flex items-center gap-3">
                  <div className="w-2 h-8 bg-blue-500 rounded-full" />
                  <div>
                    <h4 className="font-medium text-sm">{schedule.course}</h4>
                    <p className="text-xs text-muted-foreground">{schedule.time} • {schedule.room}</p>
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  <Badge variant="outline">{schedule.type}</Badge>
                  {schedule.students && (
                    <span className="text-xs text-muted-foreground">{schedule.students} students</span>
                  )}
                  <Button size="sm" variant="outline">
                    <Video className="h-3 w-3 mr-1" />
                    Start Class
                  </Button>
                </div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Activity className="h-5 w-5" />
            Recent Activity
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-3">
            {[].map((activity, index) => (
              <div key={index} className="flex items-center justify-between p-3 border rounded-lg">
                <div>
                  <h4 className="font-medium text-sm">{activity.action}</h4>
                  <p className="text-xs text-muted-foreground">{activity.course} • {activity.count}</p>
                </div>
                <span className="text-xs text-muted-foreground">{activity.time}</span>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Quick Actions</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
            <Button variant="outline" className="h-20 flex-col gap-2">
              <BookOpen className="h-5 w-5" />
              <span className="text-xs">Edit Course</span>
            </Button>
            <Button variant="outline" className="h-20 flex-col gap-2">
              <Bell className="h-5 w-5" />
              <span className="text-xs">Send Notice</span>
            </Button>
            <Button variant="outline" className="h-20 flex-col gap-2">
              <FileText className="h-5 w-5" />
              <span className="text-xs">Create Assignment</span>
            </Button>
            <Button variant="outline" className="h-20 flex-col gap-2">
              <Award className="h-5 w-5" />
              <span className="text-xs">Create Quiz</span>
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  );

  const AdminSections = () => (
    <div className="space-y-6">
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Activity className="h-5 w-5" />
            Recent Platform Activity
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {[].map((activity) => (
              <div key={activity.id} className="flex items-center gap-3 p-3 border rounded-lg hover:bg-gray-50 transition-colors">
                <div className={`w-8 h-8 rounded-full ${activity.bgColor} flex items-center justify-center`}>
                  <activity.icon className={`h-4 w-4 ${activity.color}`} />
                </div>
                <div className="flex-1">
                  <p className="font-medium text-sm">{activity.action}</p>
                </div>
                <span className="text-xs text-muted-foreground">{activity.time}</span>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <AlertTriangle className="h-5 w-5" />
            System Alerts
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-3">
            {[].map((alert) => (
              <div key={alert.id} className="flex items-center justify-between p-3 border rounded-lg">
                <div className="flex items-center gap-3">
                  <div className={`w-2 h-2 rounded-full ${alert.severity === 'High' ? 'bg-red-500' : alert.severity === 'Medium' ? 'bg-yellow-500' : 'bg-green-500'}`} />
                  <div>
                    <p className="font-medium text-sm">{alert.message}</p>
                    <p className="text-xs text-muted-foreground">{alert.time}</p>
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  <Badge variant={alert.severity === 'High' ? 'destructive' : alert.severity === 'Medium' ? 'default' : 'secondary'}>
                    {alert.severity}
                  </Badge>
                  <Badge variant="outline" className={alert.status === 'resolved' ? 'bg-green-50 text-green-700' : alert.status === 'monitoring' ? 'bg-yellow-50 text-yellow-700' : 'bg-red-50 text-red-700'}>
                    {alert.status}
                  </Badge>
                </div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Administrative Actions</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            {[
              { title: 'Manage Users', icon: Users, description: 'Add, edit, or remove users', color: 'text-blue-600', bgColor: 'bg-blue-100' },
              { title: 'Course Overview', icon: BookOpen, description: 'View all courses and statistics', color: 'text-green-600', bgColor: 'bg-green-100' },
              { title: 'Send Notice', icon: Mail, description: 'Send platform-wide announcements', color: 'text-purple-600', bgColor: 'bg-purple-100' },
              { title: 'System Settings', icon: Settings, description: 'Configure platform settings', color: 'text-orange-600', bgColor: 'bg-orange-100' }
            ].map((action, index) => (
              <Button key={index} variant="outline" className="h-24 flex flex-col items-center justify-center gap-2 p-4 hover:bg-gray-50">
                <div className={`w-8 h-8 rounded-full ${action.bgColor} flex items-center justify-center`}>
                  <action.icon className={`h-4 w-4 ${action.color}`} />
                </div>
                <div className="text-center">
                  <p className="font-medium text-xs">{action.title}</p>
                  <p className="text-xs text-muted-foreground">{action.description}</p>
                </div>
              </Button>
            ))}
          </div>
        </CardContent>
      </Card>
    </div>
  );

  switch (userRole) {
    case 'student':
      return <StudentSections />;
    case 'teacher':
      return <TeacherSections />;
    case 'admin':
      return <AdminSections />;
    default:
      return <StudentSections />;
  }
}