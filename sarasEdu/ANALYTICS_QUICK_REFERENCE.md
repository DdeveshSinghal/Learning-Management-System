# Analytics Dashboard - Quick Reference

## File Structure

```
frontend/src/
├── components/
│   └── analytics-dashboard.jsx       # Main dashboard component
├── services/
│   └── analyticsService.js           # Analytics data fetching logic
```

## How to Use

### Import the Component
```javascript
import { AnalyticsDashboard } from './components/analytics-dashboard';
```

### Render the Component
```jsx
<AnalyticsDashboard userRole="student" userId={currentUser.id} />
```

### Props
| Prop | Type | Required | Values |
|------|------|----------|--------|
| `userRole` | string | Yes | `'student'`, `'teacher'`, `'admin'` |
| `userId` | number | Yes (except admin) | User ID from database |

## Data Sources

### Student Analytics
| Metric | Source |
|--------|--------|
| Overall Score | `/test-submissions/?student={id}` - average marks |
| Study Hours | `/lecture-progress/?student={id}` - sum of time_spent |
| Total Courses | `/enrollments/?student={id}` - count |
| Rank | Calculated from performance |
| Course Performance | Per-course breakdown |
| Study Activity | 7-day activity chart |
| Recent Scores | Last 5 test submissions |

### Teacher Analytics
| Metric | Source |
|--------|--------|
| Total Students | Count from `/enrollments/?course={id}` |
| Avg Progress | Aggregated from student progress |
| Avg Score | Aggregated from student scores |
| Study Time | Sum of all student study hours |
| Engagement | 78%, 85%, 72%, 68% (configurable) |
| Course Performance | Per-course score breakdown |
| AI Insights | Generated recommendations |

### Admin Analytics
| Metric | Source |
|--------|--------|
| Active Users | Calculated from login frequency |
| New Registrations | Count from `/users` |
| Course Stats | From `/courses/` endpoint |
| Content Statistics | From `/uploads/` endpoint |
| System Health | Placeholder values |

## Key Features

### Loading State
- Shows animated spinner while fetching
- Prevents interaction during load
- Smooth transition to data

### Error Handling
- Displays user-friendly error messages
- Gracefully handles missing data
- Shows "No data available" for empty sections

### Time Range Selection
Users can select:
- Weekly (last 7 days)
- Monthly (last 30 days)
- Yearly (last 12 months)

Data automatically refetches when changed.

### Empty States
All charts and tables show helpful messages when no data is available:
- "No course data available"
- "No activity data available"
- "No recent scores available"

## Analytics Service Functions

### getStudentAnalytics(userId, timeRange)
Fetches all student-specific analytics
```javascript
const data = await getStudentAnalytics(123, 'monthly');
// Returns: { overview, coursePerformance, studyActivity, recentScores }
```

### getTeacherAnalytics(userId, timeRange)
Fetches all teacher-specific analytics
```javascript
const data = await getTeacherAnalytics(456, 'monthly');
// Returns: { overview, engagementMetrics, coursePerformance, aiInsights }
```

### getAdminAnalytics(timeRange)
Fetches all admin-specific analytics
```javascript
const data = await getAdminAnalytics('monthly');
// Returns: { userAnalytics, courseAnalytics, performance, systemWide }
```

## Common Issues & Solutions

### Issue: "No data available" message
**Solution:** Check that:
- User is properly authenticated
- User ID is correct
- Backend has data for this user
- API endpoints are accessible

### Issue: Loading spinner never disappears
**Solution:**
- Check browser console for API errors
- Verify network connectivity
- Check backend API status
- Look for CORS issues

### Issue: Charts appear empty
**Solution:**
- Ensure data has correct format
- Check that arrays are not empty
- Verify chart component props

## API Response Format

### Test Submission
```javascript
{
  id: 1,
  test: 5,
  student: 123,
  marks_obtained: 85,
  marks_total: 100,
  created_at: "2024-12-09T10:30:00Z"
}
```

### Lecture Progress
```javascript
{
  id: 1,
  lecture: 5,
  student: 123,
  time_spent_seconds: 3600,
  progress_percentage: 100,
  updated_at: "2024-12-09T10:30:00Z"
}
```

### Enrollment
```javascript
{
  id: 1,
  course: 5,
  student: 123,
  enrollment_date: "2024-12-01",
  status: "active"
}
```

## Performance Tips

1. **Reduce API Calls**
   - Data is fetched once on component mount
   - Re-fetches only when time range changes

2. **Optimize Large Datasets**
   - Only fetch last 5 recent scores
   - Use pagination if needed

3. **Cache Data**
   - Consider implementing local caching
   - Store data with timestamp

## Customization

### Change Colors
Edit the COLORS array in analytics-dashboard.jsx:
```javascript
const COLORS = ['#0088FE', '#00C49F', '#FFBB28', '#FF8042', '#8884d8'];
```

### Add New Metrics
1. Add function in `analyticsService.js`
2. Call it from relevant useEffect
3. Update state with new data
4. Render in component

### Modify Chart Type
Replace chart component and data mapping:
```jsx
// Change from AreaChart to LineChart
<ResponsiveContainer width="100%" height={250}>
  <RechartsLineChart data={analytics.studyActivity}>
    <CartesianGrid strokeDasharray="3 3" />
    <XAxis dataKey="date" />
    <YAxis />
    <Tooltip />
    <Line type="monotone" dataKey="hours" stroke="#8884d8" />
  </RechartsLineChart>
</ResponsiveContainer>
```

## Database Requirements

Ensure backend has these models:
- `CoreUser` - User authentication
- `Course` - Course information
- `Enrollment` - Student-Course relationship
- `TestSubmission` - Test attempts
- `TestAnswer` - Individual answers
- `LectureProgress` - Study activity
- `Lecture` - Lecture information

## Dependencies

```json
{
  "react": "^18.0.0",
  "recharts": "^2.0.0",
  "lucide-react": "latest",
  "@radix-ui/react-tabs": "latest"
}
```

## Testing Checklist

- [ ] Component loads without errors
- [ ] Data fetches on component mount
- [ ] Loading spinner shows during fetch
- [ ] Error message shows on API failure
- [ ] Time range selection works
- [ ] Data updates when time range changes
- [ ] All role views render correctly
- [ ] Charts display data properly
- [ ] Empty states show helpful messages
