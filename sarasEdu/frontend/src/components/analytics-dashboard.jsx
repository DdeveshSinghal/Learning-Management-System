import React, { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Progress } from './ui/progress';
import { Tabs, TabsContent, TabsList, TabsTrigger } from './ui/tabs';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from './ui/select';
import { 
  BarChart3, 
  TrendingUp, 
  Users, 
  BookOpen, 
  Clock, 
  Award, 
  Target,
  Activity,
  PieChart,
  LineChart,
  Calendar,
  Download,
  MessageSquare,
  Brain,
  Lightbulb,
  AlertTriangle,
  CheckCircle
} from 'lucide-react';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, LineChart as RechartsLineChart, Line, PieChart as RechartsPieChart, Cell, Pie, AreaChart, Area } from 'recharts';

// Props/type annotations removed for JS build. Fetch analytics from API in production.
export function AnalyticsDashboard({ userRole, userId }) {
  const [selectedTimeRange, setSelectedTimeRange] = useState('monthly');
  const [selectedCourse, setSelectedCourse] = useState('all');

  // Analytics data should be fetched from an API. Removed demo/sample analytics data.
  // Provide safe empty defaults to avoid runtime errors when rendering with no data.
  const studentAnalytics = {
    overview: { overallScore: 0, studyHours: 0, totalCourses: 0, rank: 0, totalStudents: 0 },
    coursePerformance: [],
    studyActivity: [],
    recentScores: []
  };
  const teacherAnalytics = {
    overview: { totalStudents: 0, avgProgress: 0, avgScore: 0, studyTime: 0 },
    engagementMetrics: [],
    coursePerformance: [],
    aiInsights: { trends: [], concerns: [], recommendations: [] }
  };
  const adminAnalytics = {
    userAnalytics: {
      activeUsers: { daily: 0, weekly: 0, monthly: 0 },
      newRegistrations: { students: 0, teachers: 0, thisMonth: 0 },
      engagement: { avgTime: 0, logins: 0, dropouts: 0 }
    },
    courseAnalytics: { completion: 0, averageGrades: 0, engagement: 0, popular: [] },
    performance: [],
    systemWide: { usage: [], content: { totalFiles: 0, totalVideos: 0, totalQuizzes: 0, monthlyUploads: 0 } }
  };

  const COLORS = ['#0088FE', '#00C49F', '#FFBB28', '#FF8042', '#8884d8'];

  const StudentAnalyticsView = () => (
    <div className="space-y-6">
      {/* Overview Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <Card>
          <CardContent className="p-4">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-full bg-orange-100 flex items-center justify-center">
                <Target className="h-5 w-5 text-orange-600" />
              </div>
              <div>
                <p className="text-sm text-muted-foreground">Overall Score</p>
                <p className="text-2xl font-bold">{studentAnalytics.overview.overallScore}%</p>
                <p className="text-xs text-green-600">0% this month</p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-4">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-full bg-purple-100 flex items-center justify-center">
                <Clock className="h-5 w-5 text-purple-600" />
              </div>
              <div>
                <p className="text-sm text-muted-foreground">Study Hours</p>
                <p className="text-2xl font-bold">{studentAnalytics.overview.studyHours}h</p>
                <p className="text-xs text-muted-foreground">This semester</p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-4">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-full bg-blue-100 flex items-center justify-center">
                <BookOpen className="h-5 w-5 text-blue-600" />
              </div>
              <div>
                <p className="text-sm text-muted-foreground">Total Courses</p>
                <p className="text-2xl font-bold">{studentAnalytics.overview.totalCourses}</p>
                <p className="text-xs text-green-600">All active</p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-4">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-full bg-yellow-100 flex items-center justify-center">
                <Award className="h-5 w-5 text-yellow-600" />
              </div>
              <div>
                <p className="text-sm text-muted-foreground">Rank</p>
                <p className="text-2xl font-bold">#{studentAnalytics.overview.rank}</p>
                <p className="text-xs text-muted-foreground">of {studentAnalytics.overview.totalStudents}</p>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Course Performance */}
        <Card>
          <CardHeader>
            <CardTitle>Course Performance</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {studentAnalytics.coursePerformance.map((course, index) => (
                <div key={index} className="space-y-2">
                  <div className="flex justify-between items-center">
                    <span className="font-medium">{course.course}</span>
                    <Badge variant="outline">{course.score}%</Badge>
                  </div>
                  <Progress value={course.progress} />
                  <div className="flex justify-between text-sm text-muted-foreground">
                    <span>Progress: {course.progress}%</span>
                    <span>Assignments: {course.assignments} | Tests: {course.tests}</span>
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>

        {/* Study Activity */}
        <Card>
          <CardHeader>
            <CardTitle>Study Activity (Last 7 Days)</CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={250}>
              <AreaChart data={studentAnalytics.studyActivity}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="date" tickFormatter={(value) => new Date(value).toLocaleDateString('en-US', { weekday: 'short' })} />
                <YAxis />
                <Tooltip labelFormatter={(value) => new Date(value).toLocaleDateString()} />
                <Area type="monotone" dataKey="hours" stroke="#8884d8" fill="#8884d8" fillOpacity={0.3} />
              </AreaChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>
      </div>

      {/* Recent Scores */}
      <Card>
        <CardHeader>
          <CardTitle>Recent Scores</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-3">
            {studentAnalytics.recentScores.map((score, index) => (
              <div key={index} className="flex items-center justify-between p-3 border rounded-lg">
                <div className="flex items-center gap-3">
                  <Badge variant="outline">{score.type}</Badge>
                  <div>
                    <p className="font-medium">{score.subject}</p>
                    <p className="text-sm text-muted-foreground">{score.date}</p>
                  </div>
                </div>
                <div className="text-right">
                  <p className="font-semibold text-lg">{score.score}/{score.maxScore}</p>
                  <p className={`text-sm ${score.score >= 80 ? 'text-green-600' : score.score >= 60 ? 'text-yellow-600' : 'text-red-600'}`}>
                    {((score.score / score.maxScore) * 100).toFixed(0)}%
                  </p>
                </div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>
    </div>
  );

  const TeacherAnalyticsView = () => (
    <div className="space-y-6">
      {/* Overview Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <Card>
          <CardContent className="p-4">
            <div className="text-center">
              <Users className="h-8 w-8 text-blue-500 mx-auto mb-2" />
              <div className="text-2xl font-bold">{teacherAnalytics.overview.totalStudents}</div>
              <p className="text-sm text-muted-foreground">Total Students</p>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-4">
            <div className="text-center">
              <TrendingUp className="h-8 w-8 text-green-500 mx-auto mb-2" />
              <div className="text-2xl font-bold">{teacherAnalytics.overview.avgProgress}%</div>
              <p className="text-sm text-muted-foreground">Avg Progress</p>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-4">
            <div className="text-center">
              <Award className="h-8 w-8 text-yellow-500 mx-auto mb-2" />
              <div className="text-2xl font-bold">{teacherAnalytics.overview.avgScore}%</div>
              <p className="text-sm text-muted-foreground">Avg Score</p>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-4">
            <div className="text-center">
              <Clock className="h-8 w-8 text-purple-500 mx-auto mb-2" />
              <div className="text-2xl font-bold">{(teacherAnalytics.overview.studyTime / 60).toFixed(0)}h</div>
              <p className="text-sm text-muted-foreground">Total Study Time</p>
            </div>
          </CardContent>
        </Card>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Engagement Metrics */}
        <Card>
          <CardHeader>
            <CardTitle>Engagement Metrics</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {teacherAnalytics.engagementMetrics.map((metric, index) => (
                <div key={index} className="flex items-center justify-between">
                  <div className="flex-1">
                    <p className="font-medium text-sm">{metric.metric}</p>
                    <div className="flex items-center gap-2 mt-1">
                      <Progress value={metric.value} className="flex-1" />
                      <span className="text-sm font-medium">{metric.value}%</span>
                    </div>
                  </div>
                  <Badge variant="outline" className="ml-2 text-green-600">
                    {metric.trend}
                  </Badge>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>

        {/* Course Performance */}
        <Card>
          <CardHeader>
            <CardTitle>Course Performance</CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={250}>
              <BarChart data={teacherAnalytics.coursePerformance}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="course" />
                <YAxis />
                <Tooltip />
                <Bar dataKey="avgScore" fill="#8884d8" />
              </BarChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>
      </div>

      {/* AI-Generated Insights */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2 text-green-600">
              <TrendingUp className="h-5 w-5" />
              Positive Trends
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              {teacherAnalytics.aiInsights.trends.map((trend, index) => (
                <div key={index} className="flex items-start gap-2">
                  <CheckCircle className="h-4 w-4 text-green-500 mt-1 flex-shrink-0" />
                  <p className="text-sm">{trend}</p>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2 text-orange-600">
              <AlertTriangle className="h-5 w-5" />
              Areas of Concern
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              {teacherAnalytics.aiInsights.concerns.map((concern, index) => (
                <div key={index} className="flex items-start gap-2">
                  <AlertTriangle className="h-4 w-4 text-orange-500 mt-1 flex-shrink-0" />
                  <p className="text-sm">{concern}</p>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2 text-blue-600">
              <Lightbulb className="h-5 w-5" />
              Recommendations
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              {teacherAnalytics.aiInsights.recommendations.map((rec, index) => (
                <div key={index} className="flex items-start gap-2">
                  <Lightbulb className="h-4 w-4 text-blue-500 mt-1 flex-shrink-0" />
                  <p className="text-sm">{rec}</p>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Quick Actions */}
      <Card>
        <CardHeader>
          <CardTitle>Quick Actions</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <Button className="h-auto p-4" variant="outline">
              <div className="text-center">
                <MessageSquare className="h-8 w-8 mx-auto mb-2" />
                <p className="font-medium">Message Struggling Students</p>
                <p className="text-sm text-muted-foreground">Send personalized help</p>
              </div>
            </Button>
            <Button className="h-auto p-4" variant="outline">
              <div className="text-center">
                <BookOpen className="h-8 w-8 mx-auto mb-2" />
                <p className="font-medium">Create Extra Material</p>
                <p className="text-sm text-muted-foreground">For challenging topics</p>
              </div>
            </Button>
            <Button className="h-auto p-4" variant="outline">
              <div className="text-center">
                <Calendar className="h-8 w-8 mx-auto mb-2" />
                <p className="font-medium">Schedule Support</p>
                <p className="text-sm text-muted-foreground">Extra help sessions</p>
              </div>
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  );

  const AdminAnalyticsView = () => (
    <div className="space-y-6">
      <Tabs defaultValue="users" className="w-full">
        <TabsList className="grid w-full grid-cols-5">
          <TabsTrigger value="users">User Analytics</TabsTrigger>
          <TabsTrigger value="courses">Course Analytics</TabsTrigger>
          <TabsTrigger value="performance">Performance</TabsTrigger>
          <TabsTrigger value="system">System-Wide</TabsTrigger>
          <TabsTrigger value="financial">Financial</TabsTrigger>
        </TabsList>

        <TabsContent value="users" className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <Card>
              <CardHeader>
                <CardTitle>Active Users</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-2">
                  <div className="flex justify-between">
                    <span>Daily</span>
                    <span className="font-bold">{adminAnalytics.userAnalytics.activeUsers.daily}</span>
                  </div>
                  <div className="flex justify-between">
                    <span>Weekly</span>
                    <span className="font-bold">{adminAnalytics.userAnalytics.activeUsers.weekly}</span>
                  </div>
                  <div className="flex justify-between">
                    <span>Monthly</span>
                    <span className="font-bold">{adminAnalytics.userAnalytics.activeUsers.monthly}</span>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle>New Registrations</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-2">
                  <div className="flex justify-between">
                    <span>Students</span>
                    <span className="font-bold">{adminAnalytics.userAnalytics.newRegistrations.students}</span>
                  </div>
                  <div className="flex justify-between">
                    <span>Teachers</span>
                    <span className="font-bold">{adminAnalytics.userAnalytics.newRegistrations.teachers}</span>
                  </div>
                  <div className="flex justify-between">
                    <span>This Month</span>
                    <span className="font-bold text-green-600">{adminAnalytics.userAnalytics.newRegistrations.thisMonth}</span>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle>User Engagement</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-2">
                  <div className="flex justify-between">
                    <span>Avg Time (hrs)</span>
                    <span className="font-bold">{adminAnalytics.userAnalytics.engagement.avgTime}</span>
                  </div>
                  <div className="flex justify-between">
                    <span>Logins/Week</span>
                    <span className="font-bold">{adminAnalytics.userAnalytics.engagement.logins}</span>
                  </div>
                  <div className="flex justify-between">
                    <span>Dropouts (%)</span>
                    <span className="font-bold text-red-600">{adminAnalytics.userAnalytics.engagement.dropouts}%</span>
                  </div>
                </div>
              </CardContent>
            </Card>
          </div>

          <Card>
            <CardHeader>
              <CardTitle>Peak Usage Hours</CardTitle>
            </CardHeader>
            <CardContent>
              <ResponsiveContainer width="100%" height={300}>
                <AreaChart data={adminAnalytics.systemWide.usage}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="hour" />
                  <YAxis />
                  <Tooltip />
                  <Area type="monotone" dataKey="users" stroke="#8884d8" fill="#8884d8" fillOpacity={0.3} />
                </AreaChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="courses" className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
            <Card>
              <CardContent className="p-4">
                <div className="text-center">
                  <div className="text-2xl font-bold text-green-600">{adminAnalytics.courseAnalytics.completion}%</div>
                  <p className="text-sm text-muted-foreground">Completion Rate</p>
                </div>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="p-4">
                <div className="text-center">
                  <div className="text-2xl font-bold text-blue-600">{adminAnalytics.courseAnalytics.averageGrades}%</div>
                  <p className="text-sm text-muted-foreground">Average Grades</p>
                </div>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="p-4">
                <div className="text-center">
                  <div className="text-2xl font-bold text-purple-600">{adminAnalytics.courseAnalytics.engagement}%</div>
                  <p className="text-sm text-muted-foreground">Engagement Rate</p>
                </div>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="p-4">
                <div className="text-center">
                  <div className="text-2xl font-bold text-orange-600">{adminAnalytics.courseAnalytics.popular.length}</div>
                  <p className="text-sm text-muted-foreground">Popular Courses</p>
                </div>
              </CardContent>
            </Card>
          </div>

          <Card>
            <CardHeader>
              <CardTitle>Most Popular Courses</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {adminAnalytics.courseAnalytics.popular.map((course, index) => (
                  <div key={index} className="flex items-center justify-between p-3 border rounded-lg">
                    <div>
                      <p className="font-medium">{course.name}</p>
                      <p className="text-sm text-muted-foreground">{course.enrollments} enrollments</p>
                    </div>
                    <div className="flex items-center gap-2">
                      <Badge variant="outline">{course.rating}★</Badge>
                      <Progress value={(course.enrollments / 400) * 100} className="w-20" />
                    </div>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="performance" className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
            {adminAnalytics.performance.map((item, index) => (
              <Card key={index}>
                <CardContent className="p-4">
                  <div className="text-center">
                    <div className="text-2xl font-bold text-blue-600">{item.value}</div>
                    <p className="font-medium">{item.category}</p>
                    <p className="text-sm text-muted-foreground">{item.description}</p>
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>
        </TabsContent>

        <TabsContent value="system" className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <Card>
              <CardHeader>
                <CardTitle>Content Statistics</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-3">
                  <div className="flex justify-between">
                    <span>Total Files</span>
                    <span className="font-bold">{adminAnalytics.systemWide.content.totalFiles.toLocaleString()}</span>
                  </div>
                  <div className="flex justify-between">
                    <span>Total Videos</span>
                    <span className="font-bold">{adminAnalytics.systemWide.content.totalVideos.toLocaleString()}</span>
                  </div>
                  <div className="flex justify-between">
                    <span>Total Quizzes</span>
                    <span className="font-bold">{adminAnalytics.systemWide.content.totalQuizzes}</span>
                  </div>
                  <div className="flex justify-between">
                    <span>Monthly Uploads</span>
                    <span className="font-bold text-green-600">{adminAnalytics.systemWide.content.monthlyUploads}</span>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle>System Health</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-3">
                  <div>
                    <div className="flex justify-between mb-1">
                      <span>Server Uptime</span>
                      <span>0</span>
                    </div>
                    <Progress value={0} />
                  </div>
                  <div>
                    <div className="flex justify-between mb-1">
                      <span>Database Performance</span>
                      <span>0</span>
                    </div>
                    <Progress value={0} />
                  </div>
                  <div>
                    <div className="flex justify-between mb-1">
                      <span>API Response Time</span>
                      <span>0</span>
                    </div>
                    <Progress value={0} />
                  </div>
                </div>
              </CardContent>
            </Card>
          </div>
        </TabsContent>

        <TabsContent value="financial" className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <Card>
              <CardContent className="p-4">
                <div className="text-center">
                  <div className="text-2xl font-bold text-green-600">0</div>
                  <p className="text-sm text-muted-foreground">Total Revenue</p>
                  <p className="text-xs text-green-600">N/A this month</p>
                </div>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="p-4">
                <div className="text-center">
                  <div className="text-2xl font-bold text-blue-600">0</div>
                  <p className="text-sm text-muted-foreground">Course Sales</p>
                  <p className="text-xs text-blue-600">N/A this month</p>
                </div>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="p-4">
                <div className="text-center">
                  <div className="text-2xl font-bold text-purple-600">0</div>
                  <p className="text-sm text-muted-foreground">Payment Success</p>
                  <p className="text-xs text-green-600">N/A this month</p>
                </div>
              </CardContent>
            </Card>
          </div>
        </TabsContent>
      </Tabs>
    </div>
  );

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-3xl font-bold">Analytics Dashboard</h2>
          <p className="text-muted-foreground">
            {userRole === 'student' && "Track your learning progress and performance"}
            {userRole === 'teacher' && "Monitor student engagement and course performance"}
            {userRole === 'admin' && "Comprehensive platform analytics and insights"}
          </p>
        </div>
        <div className="flex items-center gap-2">
          <Select value={selectedTimeRange} onValueChange={setSelectedTimeRange}>
            <SelectTrigger className="w-32">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="weekly">Weekly</SelectItem>
              <SelectItem value="monthly">Monthly</SelectItem>
              <SelectItem value="yearly">Yearly</SelectItem>
            </SelectContent>
          </Select>
          <Button variant="outline">
            <Download className="h-4 w-4 mr-2" />
            Export
          </Button>
        </div>
      </div>

      {userRole === 'student' && <StudentAnalyticsView />}
      {userRole === 'teacher' && <TeacherAnalyticsView />}
      {userRole === 'admin' && <AdminAnalyticsView />}
    </div>
  );
}