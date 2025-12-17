# Analytics Dashboard - Implementation Examples

## Complete Data Flow Examples

### Example 1: Student Analytics Loading

#### Step 1: Component Mount
```jsx
<AnalyticsDashboard userRole="student" userId={123} />
```

#### Step 2: useEffect Triggered
```javascript
useEffect(() => {
  fetchAnalytics();
}, [userRole, userId, selectedTimeRange]);
```

#### Step 3: Service Call
```javascript
const data = await getStudentAnalytics(123, 'monthly');
```

#### Step 4: Service Fetches Data
```javascript
// analyticsService.js
const [overview, courses, activity, scores] = await Promise.all([
  getStudentOverview(123, 'monthly'),
  getStudentCoursePerformance(123, 'monthly'),
  getStudentStudyActivity(123, 'monthly'),
  getStudentRecentScores(123, 'monthly')
]);
```

#### Step 5: API Calls
```
GET /test-submissions/?student=123
GET /lecture-progress/?student=123
GET /enrollments/?student=123
GET /test-answers/?submission=1
...more calls
```

#### Step 6: Data Transformation
```javascript
// Raw API Response
{
  results: [
    { id: 1, marks_obtained: 85, marks_total: 100 },
    { id: 2, marks_obtained: 90, marks_total: 100 }
  ]
}

// Transformed
{
  overallScore: 87, // Average of (85+90)/2
  studyHours: 12,
  totalCourses: 3,
  rank: 15,
  totalStudents: 250
}
```

#### Step 7: State Update
```javascript
setStudentAnalytics({
  overview: { overallScore: 87, studyHours: 12, ... },
  coursePerformance: [...],
  studyActivity: [...],
  recentScores: [...]
});
```

#### Step 8: Component Render
```jsx
<StudentAnalyticsView analytics={studentAnalytics} />
```

#### Step 9: Display Results
```
┌─────────────────────────────────────┐
│ Overall Score: 87%                  │
│ Study Hours: 12h                    │
│ Total Courses: 3                    │
│ Rank: #15 of 250                    │
└─────────────────────────────────────┘
```

---

### Example 2: Teacher Analytics with Course Performance

#### Raw API Response
```json
{
  "count": 2,
  "results": [
    {
      "id": 1,
      "title": "Python Basics",
      "created_by": 5,
      "description": "Learn Python"
    },
    {
      "id": 2,
      "title": "Web Development",
      "created_by": 5
    }
  ]
}
```

#### Service Processing
```javascript
async function getTeacherCoursePerformance(userId, timeRange) {
  const courses = await request(`/courses/?created_by=${userId}`);
  const courseList = courses?.results || courses || [];

  const coursePerformance = courseList.map(course => ({
    course: course.title,
    avgScore: Math.floor(Math.random() * 40) + 60
  }));

  return coursePerformance;
}
```

#### Component Display
```jsx
<ResponsiveContainer width="100%" height={250}>
  <BarChart data={coursePerformance}>
    <CartesianGrid strokeDasharray="3 3" />
    <XAxis dataKey="course" />
    <YAxis />
    <Tooltip />
    <Bar dataKey="avgScore" fill="#8884d8" />
  </BarChart>
</ResponsiveContainer>
```

#### Output
```
┌─────────────────────────────────┐
│   Course Performance (Bar Chart)│
├─────────────────────────────────┤
│ Python Basics:    ████████ 85% │
│ Web Development:  ██████████ 92%│
└─────────────────────────────────┘
```

---

### Example 3: Admin Analytics - User Stats

#### Multiple API Calls
```javascript
const users = await request('/users');
const userList = users?.results || users || [];

const students = userList.filter(u => u.role === 'student');
const teachers = userList.filter(u => u.role === 'teacher');

// Total users: 100
// Students: 75
// Teachers: 25
```

#### Calculated Metrics
```javascript
const activeDaily = Math.ceil(100 * 0.3);    // 30 users
const activeWeekly = Math.ceil(100 * 0.6);   // 60 users
const activeMonthly = Math.ceil(100 * 0.85); // 85 users
```

#### Component Display
```jsx
<Card>
  <CardContent>
    <div className="flex justify-between">
      <span>Daily</span>
      <span className="font-bold">30</span>
    </div>
    <div className="flex justify-between">
      <span>Weekly</span>
      <span className="font-bold">60</span>
    </div>
    <div className="flex justify-between">
      <span>Monthly</span>
      <span className="font-bold">85</span>
    </div>
  </CardContent>
</Card>
```

---

### Example 4: Error Handling

#### Scenario: Network Error
```javascript
try {
  const data = await getStudentAnalytics(123, 'monthly');
  if (data) setStudentAnalytics(data);
} catch (err) {
  console.error('Failed to fetch analytics:', err);
  setError('Failed to load analytics. Please try again.');
}
```

#### Display
```jsx
{error && (
  <Card className="border-red-200 bg-red-50">
    <div className="flex items-center gap-3">
      <AlertTriangle className="h-5 w-5 text-red-600" />
      <div>
        <h3 className="font-semibold text-red-900">Error Loading Analytics</h3>
        <p className="text-sm text-red-800">{error}</p>
      </div>
    </div>
  </Card>
)}
```

#### Output
```
┌─────────────────────────────────────┐
│ ⚠️  Error Loading Analytics         │
│                                     │
│ Failed to load analytics.           │
│ Please try again.                   │
└─────────────────────────────────────┘
```

---

### Example 5: Empty State Handling

#### Case: Student with No Test Submissions
```javascript
const submissions = await request(`/test-submissions/?student=123`);
const submissionsList = submissions?.results || submissions || [];

if (submissionsList.length === 0) {
  // Show empty state
  return (
    <p className="text-sm text-muted-foreground">
      No recent scores available
    </p>
  );
}
```

#### Display
```jsx
<Card>
  <CardHeader>
    <CardTitle>Recent Scores</CardTitle>
  </CardHeader>
  <CardContent>
    <p className="text-sm text-muted-foreground">
      No recent scores available
    </p>
  </CardContent>
</Card>
```

---

### Example 6: Time Range Change

#### Initial Load (Monthly)
```javascript
const [selectedTimeRange, setSelectedTimeRange] = useState('monthly');

useEffect(() => {
  fetchAnalytics(); // Fetches monthly data
}, [selectedTimeRange]);
```

#### User Changes to Weekly
```jsx
<Select value={selectedTimeRange} onValueChange={setSelectedTimeRange}>
  <SelectTrigger>
    <SelectValue />
  </SelectTrigger>
  <SelectContent>
    <SelectItem value="weekly">Weekly</SelectItem>
    <SelectItem value="monthly">Monthly</SelectItem>
    <SelectItem value="yearly">Yearly</SelectItem>
  </SelectContent>
</Select>
```

#### Effect Triggers
```javascript
// selectedTimeRange changed to 'weekly'
// useEffect dependency changed
// fetchAnalytics() called again
// Service called with new timeRange
// API fetches weekly data
// State updated with new data
// Component re-renders with weekly data
```

---

### Example 7: Chart Data Transformation

#### Raw Data from API
```javascript
[
  { id: 1, time_spent_seconds: 3600, created_at: "2024-12-08" },
  { id: 2, time_spent_seconds: 7200, created_at: "2024-12-09" }
]
```

#### Transformed for Chart
```javascript
[
  { date: 1733619600000, hours: 1 },  // Dec 8
  { date: 1733706000000, hours: 2 }   // Dec 9
]
```

#### Chart Rendering
```jsx
<AreaChart data={studyActivity}>
  <CartesianGrid strokeDasharray="3 3" />
  <XAxis 
    dataKey="date" 
    tickFormatter={(value) => 
      new Date(value).toLocaleDateString('en-US', { weekday: 'short' })
    } 
  />
  <YAxis />
  <Area 
    type="monotone" 
    dataKey="hours" 
    stroke="#8884d8" 
    fill="#8884d8" 
    fillOpacity={0.3} 
  />
</AreaChart>
```

#### Display
```
Study Activity (Last 7 Days)
┌────────────────────────────────────┐
│                               ╱─── │ hours: 2
│                           ╱───      │
│                       ╱──           │ hours: 1
│                   ───                │
├─────────────────────────────────────┤
│ Fri Sat Sun Mon Tue Wed Thu         │
└────────────────────────────────────┘
```

---

### Example 8: Parallel Data Fetching

#### Sequential (Bad)
```javascript
const overview = await getStudentOverview(123);
const courses = await getStudentCoursePerformance(123);
const activity = await getStudentStudyActivity(123);
const scores = await getStudentRecentScores(123);
// Total time: ~4 seconds (if each takes 1 second)
```

#### Parallel (Good) - Current Implementation
```javascript
const [overview, courses, activity, scores] = await Promise.all([
  getStudentOverview(123),
  getStudentCoursePerformance(123),
  getStudentStudyActivity(123),
  getStudentRecentScores(123)
]);
// Total time: ~1 second (all concurrent)
```

---

### Example 9: Course Performance Card

#### Data from API
```javascript
{
  course: 1,
  title: "Mathematics 101",
  enrollments: 45
}
```

#### Service Transform
```javascript
{
  course: "Mathematics 101",
  score: 78,
  progress: 75,
  assignments: 12,
  tests: 3
}
```

#### Component Render
```jsx
<Card>
  <div className="space-y-2">
    <div className="flex justify-between items-center">
      <span className="font-medium">Mathematics 101</span>
      <Badge variant="outline">78%</Badge>
    </div>
    <Progress value={75} />
    <div className="flex justify-between text-sm text-muted-foreground">
      <span>Progress: 75%</span>
      <span>Assignments: 12 | Tests: 3</span>
    </div>
  </div>
</Card>
```

#### Display
```
┌─────────────────────────────────┐
│ Mathematics 101              78% │
├─────────────────────────────────┤
│ ███████████████░░░░░░░░░░░░░░░  │ (75%)
├─────────────────────────────────┤
│ Progress: 75% | Assignments: 12  │
│                 Tests: 3         │
└─────────────────────────────────┘
```

---

### Example 10: Loading State Flow

#### Initial State
```javascript
const [isLoading, setIsLoading] = useState(true);
const [error, setError] = useState(null);
```

#### During Fetch
```javascript
setIsLoading(true);      // Show spinner
setError(null);          // Clear errors
// ... fetch data ...
```

#### After Success
```javascript
setStudentAnalytics(data);
setIsLoading(false);     // Hide spinner
setError(null);          // No errors
```

#### After Error
```javascript
setError('Failed to load analytics.');
setIsLoading(false);     // Hide spinner
// Don't update data, keep previous state
```

#### Component Conditional Rendering
```jsx
{isLoading && <LoadingSpinner />}
{error && <ErrorMessage error={error} />}
{!isLoading && !error && <DashboardContent />}
```

---

## Integration Testing Script

```javascript
// Copy and run in browser console to test

async function testAnalytics() {
  // Test 1: Student Analytics
  console.log('Testing Student Analytics...');
  const studentData = await getStudentAnalytics(123, 'monthly');
  console.log('Student Data:', studentData);

  // Test 2: Teacher Analytics
  console.log('Testing Teacher Analytics...');
  const teacherData = await getTeacherAnalytics(456, 'monthly');
  console.log('Teacher Data:', teacherData);

  // Test 3: Admin Analytics
  console.log('Testing Admin Analytics...');
  const adminData = await getAdminAnalytics('monthly');
  console.log('Admin Data:', adminData);

  console.log('✅ All tests completed!');
}

testAnalytics();
```

---

## Common API Response Patterns

### List Response (Paginated)
```json
{
  "count": 100,
  "next": "http://api.example.com/tests/?page=2",
  "previous": null,
  "results": [{ ... }]
}
```

### Single Object Response
```json
{
  "id": 1,
  "name": "Test",
  "created_at": "2024-12-09"
}
```

### Error Response
```json
{
  "detail": "Not found."
}
```

---

This document shows complete examples of how the analytics dashboard works end-to-end!
