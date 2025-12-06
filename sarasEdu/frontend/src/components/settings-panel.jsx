import React, { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Input } from './ui/input';
import { Label } from './ui/label';
import { Switch } from './ui/switch';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from './ui/select';
import { Tabs, TabsContent, TabsList, TabsTrigger } from './ui/tabs';
import { Separator } from './ui/separator';
import { Badge } from './ui/badge';
import { 
  User,
  Bell,
  Shield,
  Palette,
  Globe,
  BookOpen,
  Mail,
  Phone,
  Lock,
  Eye,
  EyeOff,
  Save,
  Smartphone,
  Monitor,
  Moon,
  Sun,
  Languages,
  Clock,
  Database,
  Users,
  Settings as SettingsIcon
} from 'lucide-react';

// Props/types removed for JS build. Settings should be fetched from API/backend.
export function SettingsPanel({ userRole, userId, userName }) {
  const [settings, setSettings] = useState({
    profile: {
      name: userName || '',
      email: '',
      phone: '',
      bio: '',
      avatar: null
    },
    appearance: {
      theme: 'light',
      language: 'en',
      timezone: 'UTC-5',
      dashboardView: 'default'
    },
    notifications: {
      email: true,
      inApp: true,
      sms: false,
      assignments: true,
      grades: true,
      announcements: true,
      reminders: true,
      discussionReplies: userRole === 'teacher',
      studentSubmissions: userRole === 'teacher'
    },
    privacy: {
      profileVisibility: 'public',
      emailVisible: false,
      phoneVisible: false,
      allowMessaging: true,
      twoFactorAuth: false
    },
    course: {
      autoEnrollment: false,
      deadlineReminders: true,
      lateSubmissionWarning: true
    },
    teaching: {
      defaultGradingScheme: 'percentage',
      lateSubmissionPolicy: 'partial_credit',
      courseVisibility: 'public',
      plagiarismCheck: true,
      studentMessaging: true
    },
    admin: {
      userRegistration: true,
      courseApproval: false,
      systemMaintenance: false,
      backupFrequency: 'daily',
      passwordPolicy: 'strong'
    }
  });

  const updateSettings = (section, key, value) => {
    setSettings(prev => ({
      ...prev,
      [section]: {
        ...prev[section],
        [key]: value
      }
    }));
  };

  const ProfileSettings = () => (
    <div className="space-y-6">
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <User className="h-5 w-5" />
            Profile Information
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="flex items-center gap-4">
            <div className="w-20 h-20 rounded-full bg-gray-200 flex items-center justify-center">
              <User className="h-8 w-8 text-gray-500" />
            </div>
            <div className="flex-1">
              <Button variant="outline">Change Avatar</Button>
              <p className="text-sm text-muted-foreground mt-1">
                JPG, GIF or PNG. Max size 2MB.
              </p>
            </div>
          </div>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <Label htmlFor="name">Full Name</Label>
              <Input 
                id="name"
                value={settings.profile.name}
                onChange={(e) => updateSettings('profile', 'name', e.target.value)}
              />
            </div>
            <div>
              <Label htmlFor="email">Email Address</Label>
              <Input 
                id="email"
                type="email"
                value={settings.profile.email}
                onChange={(e) => updateSettings('profile', 'email', e.target.value)}
              />
            </div>
            <div>
              <Label htmlFor="phone">Phone Number</Label>
              <Input 
                id="phone"
                value={settings.profile.phone}
                onChange={(e) => updateSettings('profile', 'phone', e.target.value)}
              />
            </div>
            <div>
              <Label htmlFor="bio">Bio</Label>
              <Input 
                id="bio"
                value={settings.profile.bio}
                onChange={(e) => updateSettings('profile', 'bio', e.target.value)}
              />
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );

  const AppearanceSettings = () => (
    <div className="space-y-6">
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Palette className="h-5 w-5" />
            Appearance & Display
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-6">
          <div className="flex items-center justify-between">
            <div>
              <Label>Theme</Label>
              <p className="text-sm text-muted-foreground">Choose your preferred theme</p>
            </div>
            <div className="flex gap-2">
              <Button 
                variant={settings.appearance.theme === 'light' ? 'default' : 'outline'}
                size="sm"
                onClick={() => updateSettings('appearance', 'theme', 'light')}
              >
                <Sun className="h-4 w-4 mr-1" />
                Light
              </Button>
              <Button 
                variant={settings.appearance.theme === 'dark' ? 'default' : 'outline'}
                size="sm"
                onClick={() => updateSettings('appearance', 'theme', 'dark')}
              >
                <Moon className="h-4 w-4 mr-1" />
                Dark
              </Button>
            </div>
          </div>
          
          <Separator />
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <Label htmlFor="language">Language</Label>
              <Select value={settings.appearance.language} onValueChange={(value) => updateSettings('appearance', 'language', value)}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="en">English</SelectItem>
                  <SelectItem value="es">Spanish</SelectItem>
                  <SelectItem value="fr">French</SelectItem>
                  <SelectItem value="de">German</SelectItem>
                </SelectContent>
              </Select>
            </div>
            
            <div>
              <Label htmlFor="timezone">Timezone</Label>
              <Select value={settings.appearance.timezone} onValueChange={(value) => updateSettings('appearance', 'timezone', value)}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="UTC-8">Pacific Time (UTC-8)</SelectItem>
                  <SelectItem value="UTC-7">Mountain Time (UTC-7)</SelectItem>
                  <SelectItem value="UTC-6">Central Time (UTC-6)</SelectItem>
                  <SelectItem value="UTC-5">Eastern Time (UTC-5)</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>
          
          <div>
            <Label htmlFor="dashboardView">Default Dashboard View</Label>
            <Select value={settings.appearance.dashboardView} onValueChange={(value) => updateSettings('appearance', 'dashboardView', value)}>
              <SelectTrigger>
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="default">Default</SelectItem>
                <SelectItem value="courses">Courses</SelectItem>
                <SelectItem value="calendar">Calendar</SelectItem>
                <SelectItem value="analytics">Analytics</SelectItem>
              </SelectContent>
            </Select>
          </div>
        </CardContent>
      </Card>
    </div>
  );

  const NotificationSettings = () => (
    <div className="space-y-6">
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Bell className="h-5 w-5" />
            Notification Preferences
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-6">
          <div>
            <h4 className="font-semibold mb-4">Delivery Methods</h4>
            <div className="space-y-4">
              <div className="flex items-center justify-between">
                <div>
                  <Label>Email Notifications</Label>
                  <p className="text-sm text-muted-foreground">Receive notifications via email</p>
                </div>
                <Switch 
                  checked={settings.notifications.email}
                  onCheckedChange={(value) => updateSettings('notifications', 'email', value)}
                />
              </div>
              
              <div className="flex items-center justify-between">
                <div>
                  <Label>In-App Notifications</Label>
                  <p className="text-sm text-muted-foreground">Show notifications in the application</p>
                </div>
                <Switch 
                  checked={settings.notifications.inApp}
                  onCheckedChange={(value) => updateSettings('notifications', 'inApp', value)}
                />
              </div>
              
              <div className="flex items-center justify-between">
                <div>
                  <Label>SMS Notifications</Label>
                  <p className="text-sm text-muted-foreground">Receive important alerts via SMS</p>
                </div>
                <Switch 
                  checked={settings.notifications.sms}
                  onCheckedChange={(value) => updateSettings('notifications', 'sms', value)}
                />
              </div>
            </div>
          </div>
          
          <Separator />
          
          <div>
            <h4 className="font-semibold mb-4">Notification Types</h4>
            <div className="space-y-4">
              <div className="flex items-center justify-between">
                <Label>Assignment Due Dates</Label>
                <Switch 
                  checked={settings.notifications.assignments}
                  onCheckedChange={(value) => updateSettings('notifications', 'assignments', value)}
                />
              </div>
              
              <div className="flex items-center justify-between">
                <Label>Grade Updates</Label>
                <Switch 
                  checked={settings.notifications.grades}
                  onCheckedChange={(value) => updateSettings('notifications', 'grades', value)}
                />
              </div>
              
              <div className="flex items-center justify-between">
                <Label>Announcements</Label>
                <Switch 
                  checked={settings.notifications.announcements}
                  onCheckedChange={(value) => updateSettings('notifications', 'announcements', value)}
                />
              </div>
              
              <div className="flex items-center justify-between">
                <Label>Course Reminders</Label>
                <Switch 
                  checked={settings.notifications.reminders}
                  onCheckedChange={(value) => updateSettings('notifications', 'reminders', value)}
                />
              </div>
              
              {userRole === 'teacher' && (
                <>
                  <div className="flex items-center justify-between">
                    <Label>Discussion Replies</Label>
                    <Switch 
                      checked={settings.notifications.discussionReplies}
                      onCheckedChange={(value) => updateSettings('notifications', 'discussionReplies', value)}
                    />
                  </div>
                  
                  <div className="flex items-center justify-between">
                    <Label>Student Submissions</Label>
                    <Switch 
                      checked={settings.notifications.studentSubmissions}
                      onCheckedChange={(value) => updateSettings('notifications', 'studentSubmissions', value)}
                    />
                  </div>
                </>
              )}
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );

  const PrivacySecuritySettings = () => (
    <div className="space-y-6">
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Shield className="h-5 w-5" />
            Privacy & Security
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-6">
          <div>
            <h4 className="font-semibold mb-4">Privacy Settings</h4>
            <div className="space-y-4">
              <div>
                <Label>Profile Visibility</Label>
                <Select value={settings.privacy.profileVisibility} onValueChange={(value) => updateSettings('privacy', 'profileVisibility', value)}>
                  <SelectTrigger className="mt-1">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="public">Public</SelectItem>
                    <SelectItem value="students">Students Only</SelectItem>
                    <SelectItem value="teachers">Teachers Only</SelectItem>
                    <SelectItem value="private">Private</SelectItem>
                  </SelectContent>
                </Select>
              </div>
              
              <div className="flex items-center justify-between">
                <Label>Show Email Address</Label>
                <Switch 
                  checked={settings.privacy.emailVisible}
                  onCheckedChange={(value) => updateSettings('privacy', 'emailVisible', value)}
                />
              </div>
              
              <div className="flex items-center justify-between">
                <Label>Show Phone Number</Label>
                <Switch 
                  checked={settings.privacy.phoneVisible}
                  onCheckedChange={(value) => updateSettings('privacy', 'phoneVisible', value)}
                />
              </div>
              
              <div className="flex items-center justify-between">
                <Label>Allow Direct Messages</Label>
                <Switch 
                  checked={settings.privacy.allowMessaging}
                  onCheckedChange={(value) => updateSettings('privacy', 'allowMessaging', value)}
                />
              </div>
            </div>
          </div>
          
          <Separator />
          
          <div>
            <h4 className="font-semibold mb-4">Security Settings</h4>
            <div className="space-y-4">
              <div className="flex items-center justify-between">
                <div>
                  <Label>Two-Factor Authentication</Label>
                  <p className="text-sm text-muted-foreground">Add an extra layer of security</p>
                </div>
                <Switch 
                  checked={settings.privacy.twoFactorAuth}
                  onCheckedChange={(value) => updateSettings('privacy', 'twoFactorAuth', value)}
                />
              </div>
              
              <div>
                <Button variant="outline">
                  <Lock className="h-4 w-4 mr-2" />
                  Change Password
                </Button>
              </div>
              
              <div>
                <Button variant="outline">
                  <Smartphone className="h-4 w-4 mr-2" />
                  Manage Connected Devices
                </Button>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );

  const CourseSettings = () => {
    if (userRole === 'admin') return null;
    
    return (
      <div className="space-y-6">
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <BookOpen className="h-5 w-5" />
              {userRole === 'student' ? 'Course Preferences' : 'Teaching Preferences'}
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-6">
            {userRole === 'student' ? (
              <>
                <div className="flex items-center justify-between">
                  <div>
                    <Label>Auto-Enrollment Confirmation</Label>
                    <p className="text-sm text-muted-foreground">Require confirmation before enrolling</p>
                  </div>
                  <Switch 
                    checked={settings.course.autoEnrollment}
                    onCheckedChange={(value) => updateSettings('course', 'autoEnrollment', value)}
                  />
                </div>
                
                <div className="flex items-center justify-between">
                  <Label>Deadline Reminders</Label>
                  <Switch 
                    checked={settings.course.deadlineReminders}
                    onCheckedChange={(value) => updateSettings('course', 'deadlineReminders', value)}
                  />
                </div>
                
                <div className="flex items-center justify-between">
                  <Label>Late Submission Warnings</Label>
                  <Switch 
                    checked={settings.course.lateSubmissionWarning}
                    onCheckedChange={(value) => updateSettings('course', 'lateSubmissionWarning', value)}
                  />
                </div>
              </>
            ) : (
              <>
                <div>
                  <Label>Default Grading Scheme</Label>
                  <Select value={settings.teaching.defaultGradingScheme} onValueChange={(value) => updateSettings('teaching', 'defaultGradingScheme', value)}>
                    <SelectTrigger className="mt-1">
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="percentage">Percentage (0-100)</SelectItem>
                      <SelectItem value="letter">Letter Grade (A-F)</SelectItem>
                      <SelectItem value="points">Points Based</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
                
                <div>
                  <Label>Late Submission Policy</Label>
                  <Select value={settings.teaching.lateSubmissionPolicy} onValueChange={(value) => updateSettings('teaching', 'lateSubmissionPolicy', value)}>
                    <SelectTrigger className="mt-1">
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="no_penalty">No Penalty</SelectItem>
                      <SelectItem value="partial_credit">Partial Credit</SelectItem>
                      <SelectItem value="no_credit">No Credit</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
                
                <div>
                  <Label>Default Course Visibility</Label>
                  <Select value={settings.teaching.courseVisibility} onValueChange={(value) => updateSettings('teaching', 'courseVisibility', value)}>
                    <SelectTrigger className="mt-1">
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="public">Public</SelectItem>
                      <SelectItem value="unlisted">Unlisted</SelectItem>
                      <SelectItem value="private">Private</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
                
                <div className="flex items-center justify-between">
                  <Label>Enable Plagiarism Check</Label>
                  <Switch 
                    checked={settings.teaching.plagiarismCheck}
                    onCheckedChange={(value) => updateSettings('teaching', 'plagiarismCheck', value)}
                  />
                </div>
                
                <div className="flex items-center justify-between">
                  <Label>Allow Student-to-Student Messaging</Label>
                  <Switch 
                    checked={settings.teaching.studentMessaging}
                    onCheckedChange={(value) => updateSettings('teaching', 'studentMessaging', value)}
                  />
                </div>
              </>
            )}
          </CardContent>
        </Card>
      </div>
    );
  };

  const AdminSettings = () => {
    if (userRole !== 'admin') return null;
    
    return (
      <div className="space-y-6">
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <SettingsIcon className="h-5 w-5" />
              System Configuration
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-6">
            <div>
              <h4 className="font-semibold mb-4">User Management</h4>
              <div className="space-y-4">
                <div className="flex items-center justify-between">
                  <div>
                    <Label>Enable Self-Registration</Label>
                    <p className="text-sm text-muted-foreground">Allow users to register without invitation</p>
                  </div>
                  <Switch 
                    checked={settings.admin.userRegistration}
                    onCheckedChange={(value) => updateSettings('admin', 'userRegistration', value)}
                  />
                </div>
                
                <div className="flex items-center justify-between">
                  <div>
                    <Label>Course Approval Required</Label>
                    <p className="text-sm text-muted-foreground">Require admin approval for new courses</p>
                  </div>
                  <Switch 
                    checked={settings.admin.courseApproval}
                    onCheckedChange={(value) => updateSettings('admin', 'courseApproval', value)}
                  />
                </div>
              </div>
            </div>
            
            <Separator />
            
            <div>
              <h4 className="font-semibold mb-4">System Settings</h4>
              <div className="space-y-4">
                <div>
                  <Label>Backup Frequency</Label>
                  <Select value={settings.admin.backupFrequency} onValueChange={(value) => updateSettings('admin', 'backupFrequency', value)}>
                    <SelectTrigger className="mt-1">
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="hourly">Hourly</SelectItem>
                      <SelectItem value="daily">Daily</SelectItem>
                      <SelectItem value="weekly">Weekly</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
                
                <div>
                  <Label>Password Policy</Label>
                  <Select value={settings.admin.passwordPolicy} onValueChange={(value) => updateSettings('admin', 'passwordPolicy', value)}>
                    <SelectTrigger className="mt-1">
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="weak">Basic (6+ characters)</SelectItem>
                      <SelectItem value="medium">Medium (8+ chars, mixed case)</SelectItem>
                      <SelectItem value="strong">Strong (12+ chars, symbols)</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
                
                <div className="flex items-center justify-between">
                  <div>
                    <Label>Maintenance Mode</Label>
                    <p className="text-sm text-muted-foreground">Enable system maintenance mode</p>
                  </div>
                  <Switch 
                    checked={settings.admin.systemMaintenance}
                    onCheckedChange={(value) => updateSettings('admin', 'systemMaintenance', value)}
                  />
                </div>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
    );
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-3xl font-bold">Settings</h2>
          <p className="text-muted-foreground">Manage your account preferences and system settings</p>
        </div>
        <Button>
          <Save className="h-4 w-4 mr-2" />
          Save Changes
        </Button>
      </div>

      <Tabs defaultValue="profile" className="w-full">
        <TabsList className="grid w-full grid-cols-6">
          <TabsTrigger value="profile">Profile</TabsTrigger>
          <TabsTrigger value="appearance">Appearance</TabsTrigger>
          <TabsTrigger value="notifications">Notifications</TabsTrigger>
          <TabsTrigger value="privacy">Privacy</TabsTrigger>
          <TabsTrigger value="course">
            {userRole === 'student' ? 'Course' : userRole === 'teacher' ? 'Teaching' : 'System'}
          </TabsTrigger>
          {userRole === 'admin' && <TabsTrigger value="admin">Admin</TabsTrigger>}
        </TabsList>

        <TabsContent value="profile" className="space-y-4">
          <ProfileSettings />
        </TabsContent>

        <TabsContent value="appearance" className="space-y-4">
          <AppearanceSettings />
        </TabsContent>

        <TabsContent value="notifications" className="space-y-4">
          <NotificationSettings />
        </TabsContent>

        <TabsContent value="privacy" className="space-y-4">
          <PrivacySecuritySettings />
        </TabsContent>

        <TabsContent value="course" className="space-y-4">
          {userRole === 'admin' ? <AdminSettings /> : <CourseSettings />}
        </TabsContent>

        {userRole === 'admin' && (
          <TabsContent value="admin" className="space-y-4">
            <AdminSettings />
          </TabsContent>
        )}
      </Tabs>
    </div>
  );
}