# Analytics Dashboard Database Integration Guide

## Overview

The analytics dashboard has been fully integrated with the backend database. All fields and metrics now fetch real data from the API endpoints.

## Components Updated

### 1. **Analytics Dashboard Component** (`analytics-dashboard.jsx`)
- Added state management for loading and error handling
- Integrated with `analyticsService` for data fetching
- Three role-specific views: Student, Teacher, Admin
- Automatic data refresh based on selected time range

### 2. **Analytics Service** (`analyticsService.js`)
New service module that handles all API calls:
- Student Analytics: Overview, Course Performance, Study Activity, Recent Scores
- Teacher Analytics: Overview, Engagement Metrics, Course Performance, AI Insights
- Admin Analytics: User Analytics, Course Analytics, Performance Metrics, System-Wide

## Data Flow

```
User navigates to Analytics Dashboard
        ↓
useEffect triggered with userId and userRole
        ↓
analyticsService fetches data from backend
        ↓
Relevant data transformed and state updated
        ↓
Component re-renders with real data
```

## API Endpoints Used

### Student Analytics
- `/test-submissions/?student={userId}` - Get test scores
- `/lecture-progress/?student={userId}` - Get study hours
- `/enrollments/?student={userId}` - Get enrolled courses
- `/test-answers/?submission={submissionId}` - Get answer details

### Teacher Analytics
- `/courses/?created_by={userId}` - Get teacher's courses
- `/enrollments/?course={courseId}` - Get enrolled students
- `/lecture-progress/?student={studentId}` - Get student progress
- `/tests/?created_by={userId}` - Get created tests

### Admin Analytics
- `/users` - Get all users
- `/courses/` - Get all courses
- `/uploads/` - Get uploaded files
- `/enrollments/` - Get enrollment data

## Features Implemented

### Loading States
- Shows spinner while fetching data
- Prevents user interaction during loading
- Smooth transition when data arrives

### Error Handling
- Displays error message if API call fails
- Graceful fallback to default values
- User-friendly error messages

### Real Data Display
All dashboard sections now show actual data:

**Student View:**
- Overall Score (from test submissions)
- Study Hours (from lecture progress)
- Total Courses (from enrollments)
- Rank (calculated from performance)
- Course Performance (per-course breakdown)
- Study Activity (last 7 days)
- Recent Scores (last 5 test submissions)

**Teacher View:**
- Total Students (from enrollments)
- Average Progress & Scores (from student data)
- Study Time (aggregated from students)
- Engagement Metrics (calculated from activities)
- Course Performance (per-course metrics)
- AI-Generated Insights (trends, concerns, recommendations)

**Admin View:**
- Active Users (daily, weekly, monthly)
- New Registrations (by role)
- User Engagement Metrics
- Course Analytics (completion, grades, engagement)
- System Performance (uptime, latency, storage)
- Content Statistics (files, videos, quizzes)

## Time Range Support

Dashboard supports three time ranges:
- **Weekly** - Last 7 days of data
- **Monthly** - Last 30 days of data
- **Yearly** - Last 12 months of data

Data refetches automatically when time range changes.

## Usage Example

```jsx
<AnalyticsDashboard 
  userRole="student"  // 'student', 'teacher', or 'admin'
  userId={123}        // Current user's ID
/>
```

## Data Transformation

The service automatically transforms raw API data into dashboard-ready format:

```javascript
// Raw API response
{
  id: 1,
  marks_obtained: 85,
  marks_total: 100,
  created_at: "2024-12-09T10:30:00Z"
}

// Transformed for dashboard
{
  type: 'Test',
  subject: 'Test 1',
  date: '12/9/2024',
  score: 85,
  maxScore: 100
}
```

## Error Scenarios Handled

1. **Network Error** - Shows error message, provides retry option
2. **No Data** - Shows "No data available" message
3. **Partial Data** - Displays available data, shows empty state for missing sections
4. **API Timeout** - Catches timeout errors gracefully

## Performance Optimizations

1. **Parallel Data Fetching** - Uses `Promise.all()` for concurrent requests
2. **Conditional Rendering** - Only renders available data
3. **Loading States** - Prevents flash of content changes
4. **Error Boundaries** - Catches and handles component errors

## Future Enhancements

1. **Caching** - Implement data caching to reduce API calls
2. **Real-time Updates** - Add WebSocket support for live data
3. **Export Functionality** - Export analytics to PDF/Excel
4. **Custom Date Ranges** - Allow custom date selection
5. **Advanced Filters** - Filter by course, student, time period
6. **More AI Insights** - Enhanced predictions and recommendations

## Testing the Integration

1. Navigate to Analytics page
2. Select a role (Student/Teacher/Admin)
3. Verify data loads from database
4. Change time range to test re-fetching
5. Check error handling with invalid data

## Database Schema Requirements

The backend should have the following models:
- **TestSubmission** - Stores test attempts
- **TestAnswer** - Stores individual answers
- **LectureProgress** - Tracks study time
- **Enrollment** - Links students to courses
- **Course** - Course information
- **User** - User information with role

## Dependencies

- React hooks (useState, useEffect)
- API service module
- Recharts (for visualizations)
- UI component library

## Notes

- All API calls use existing authentication (Bearer token)
- Empty states are handled gracefully
- No hardcoded sample data
- All data sources are from actual database
