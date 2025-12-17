# Analytics Dashboard - API Endpoints Reference

## Overview
This document lists all API endpoints used by the Analytics Dashboard component.

## Base URL
```
http://localhost:8000/api
```

## Authentication
All endpoints require JWT Bearer token in Authorization header:
```
Authorization: Bearer {access_token}
```

## Endpoints by Feature

### Student Analytics Endpoints

#### 1. Get Test Submissions
**Endpoint:** `GET /test-submissions/?student={student_id}`

**Purpose:** Fetch all test submissions for a student

**Query Parameters:**
- `student` (required): Student user ID

**Response Format:**
```json
{
  "count": 5,
  "next": null,
  "previous": null,
  "results": [
    {
      "id": 1,
      "test": 1,
      "student": 1,
      "marks_obtained": 85,
      "marks_total": 100,
      "status": "completed",
      "created_at": "2024-12-09T10:30:00Z",
      "updated_at": "2024-12-09T10:30:00Z"
    }
  ]
}
```

**Used For:** Overall score calculation, recent scores

---

#### 2. Get Lecture Progress
**Endpoint:** `GET /lecture-progress/?student={student_id}`

**Purpose:** Fetch study activity and time spent by student

**Query Parameters:**
- `student` (required): Student user ID

**Response Format:**
```json
{
  "count": 10,
  "results": [
    {
      "id": 1,
      "lecture": 5,
      "student": 1,
      "time_spent_seconds": 3600,
      "progress_percentage": 100,
      "is_completed": true,
      "created_at": "2024-12-08T10:00:00Z",
      "updated_at": "2024-12-09T12:00:00Z"
    }
  ]
}
```

**Used For:** Study hours calculation, activity chart data

---

#### 3. Get Student Enrollments
**Endpoint:** `GET /enrollments/?student={student_id}`

**Purpose:** Get all courses enrolled by student

**Query Parameters:**
- `student` (required): Student user ID

**Response Format:**
```json
{
  "count": 3,
  "results": [
    {
      "id": 1,
      "course": 1,
      "student": 1,
      "enrollment_date": "2024-12-01",
      "status": "active",
      "is_completed": false
    }
  ]
}
```

**Used For:** Total courses count, course performance fetch

---

#### 4. Get Test Answers
**Endpoint:** `GET /test-answers/?submission={submission_id}`

**Purpose:** Get individual answers for a test submission

**Query Parameters:**
- `submission` (required): Test submission ID

**Response Format:**
```json
{
  "count": 20,
  "results": [
    {
      "id": 1,
      "submission": 1,
      "question": 1,
      "student_answer": "Option A",
      "is_correct": true,
      "marks_awarded": 5
    }
  ]
}
```

**Used For:** Detailed score calculation, answer analysis

---

### Teacher Analytics Endpoints

#### 1. Get Courses Created by Teacher
**Endpoint:** `GET /courses/?created_by={teacher_id}`

**Purpose:** Get all courses created by a teacher

**Query Parameters:**
- `created_by` (required): Teacher user ID

**Response Format:**
```json
{
  "count": 3,
  "results": [
    {
      "id": 1,
      "title": "Python Basics",
      "description": "Learn Python fundamentals",
      "created_by": 2,
      "created_at": "2024-12-01",
      "is_published": true
    }
  ]
}
```

**Used For:** Total courses, course performance, student count

---

#### 2. Get Course Enrollments
**Endpoint:** `GET /enrollments/?course={course_id}`

**Purpose:** Get all students enrolled in a course

**Query Parameters:**
- `course` (required): Course ID

**Response Format:**
```json
{
  "count": 25,
  "results": [
    {
      "id": 1,
      "course": 1,
      "student": 10,
      "enrollment_date": "2024-12-01"
    }
  ]
}
```

**Used For:** Total students count, average progress/scores

---

#### 3. Get Tests Created by Teacher
**Endpoint:** `GET /tests/?created_by={teacher_id}`

**Purpose:** Get all tests created by teacher

**Query Parameters:**
- `created_by` (required): Teacher user ID

**Response Format:**
```json
{
  "count": 5,
  "results": [
    {
      "id": 1,
      "title": "Unit 1 Quiz",
      "created_by": 2,
      "total_questions": 20,
      "created_at": "2024-12-05"
    }
  ]
}
```

**Used For:** Test metrics, course performance

---

### Admin Analytics Endpoints

#### 1. Get All Users
**Endpoint:** `GET /users`

**Purpose:** Get all system users

**Query Parameters:** None (optional role filter)

**Response Format:**
```json
{
  "count": 100,
  "results": [
    {
      "id": 1,
      "username": "john_doe",
      "email": "john@example.com",
      "role": "student",
      "first_name": "John",
      "last_name": "Doe",
      "date_joined": "2024-12-01"
    }
  ]
}
```

**Used For:** User count, registration stats, active user calculation

---

#### 2. Get All Courses
**Endpoint:** `GET /courses/`

**Purpose:** Get all courses in system

**Response Format:**
```json
{
  "count": 15,
  "results": [
    {
      "id": 1,
      "title": "Python Basics",
      "description": "Learn Python",
      "created_by": 2,
      "enrollment_count": 25
    }
  ]
}
```

**Used For:** Course analytics, popular courses, completion rates

---

#### 3. Get All Uploads
**Endpoint:** `GET /uploads/`

**Purpose:** Get all uploaded files in system

**Response Format:**
```json
{
  "count": 500,
  "results": [
    {
      "id": 1,
      "file": "http://storage.url/file.pdf",
      "file_type": "pdf",
      "uploaded_by": 2,
      "uploaded_at": "2024-12-09",
      "file_size": 1024000
    }
  ]
}
```

**Used For:** Content statistics, storage usage

---

#### 4. Get All Enrollments
**Endpoint:** `GET /enrollments/`

**Purpose:** Get all course enrollments

**Response Format:**
```json
{
  "count": 250,
  "results": [
    {
      "id": 1,
      "course": 1,
      "student": 10,
      "enrollment_date": "2024-12-01",
      "status": "active"
    }
  ]
}
```

**Used For:** Enrollment metrics, course completion rates

---

## Error Responses

### 401 Unauthorized
```json
{
  "detail": "Authentication credentials were not provided."
}
```

**Cause:** Missing or invalid JWT token

### 403 Forbidden
```json
{
  "detail": "You do not have permission to perform this action."
}
```

**Cause:** User lacks permissions for the action

### 404 Not Found
```json
{
  "detail": "Not found."
}
```

**Cause:** Resource does not exist

### 500 Server Error
```json
{
  "detail": "Internal server error"
}
```

**Cause:** Server-side error

---

## Response Handling

### Success (200 OK)
Data is extracted from the response:
```javascript
const data = await request('/test-submissions/?student={id}');
// Returns: { count, next, previous, results: [...] }
// Service extracts: data.results
```

### Pagination
All list endpoints support pagination:
- `count`: Total number of items
- `next`: URL to next page (or null)
- `previous`: URL to previous page (or null)
- `results`: Array of items on current page

---

## Rate Limiting

Some endpoints may have rate limits:
- Check response headers for rate limit info
- Implement exponential backoff for retries
- Cache data when possible to reduce requests

---

## Common Query Parameters

### Filtering
```
GET /test-submissions/?student=1&status=completed
```

### Pagination
```
GET /enrollments/?page=2&page_size=50
```

### Ordering
```
GET /courses/?ordering=-created_at
```

---

## Caching Strategy

**Recommended Cache Times:**
- User data: 5 minutes
- Course data: 10 minutes
- Student analytics: 2 minutes
- Admin analytics: 5 minutes

---

## Performance Considerations

1. **Batch Requests**
   - Use `Promise.all()` to fetch multiple endpoints simultaneously

2. **Pagination**
   - Use `page_size` parameter to limit results
   - Cache next/previous URLs for pagination

3. **Filtering**
   - Use backend filtering instead of client-side filtering

4. **Partial Responses**
   - Request only needed fields if backend supports `fields` parameter

---

## Integration Example

```javascript
// Fetch student analytics
const studentId = 123;

try {
  // Fetch all data in parallel
  const [submissions, progress, enrollments] = await Promise.all([
    request(`/test-submissions/?student=${studentId}`),
    request(`/lecture-progress/?student=${studentId}`),
    request(`/enrollments/?student=${studentId}`)
  ]);

  // Extract results
  const submissionsList = submissions.results || [];
  const progressList = progress.results || [];
  const enrollmentsList = enrollments.results || [];

  // Transform and calculate metrics
  const overallScore = submissionsList.length > 0
    ? Math.round(submissionsList.reduce((acc, s) => acc + s.marks_obtained, 0) / submissionsList.length)
    : 0;

} catch (error) {
  console.error('Analytics fetch failed:', error);
}
```

---

## Endpoint Status

All endpoints tested and working as of December 2024.

For issues or questions, contact the backend team.
