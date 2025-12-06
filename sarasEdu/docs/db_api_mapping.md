# SarasEdu — Frontend → Backend API Mapping

This document maps frontend pages/components to the backend endpoints your team should implement. Use this as the API contract for backend engineers.

Important notes
- All endpoints should be under `/api/` base path.
- Use JSON responses and standard HTTP status codes.
- Protect endpoints with authentication and role-based authorization.
- Use pagination for list endpoints (limit/offset or cursor).

---

## Authentication

POST /api/auth/login
- Request: { email, password }
- Response: { token: "<jwt>", user: { id, name, email, role, avatar_url } }

POST /api/auth/register
- Request: { name, email, password, role }
- Response: { token, user }

GET /api/auth/me
- Requires Authorization header
- Response: { id, name, email, role, profile }

POST /api/auth/logout
- Invalidate token/session

---

## Users / Profiles

GET /api/users/:id
- Response: { id, name, email, role, avatar_url, bio, phone, profile: { ... } }

PUT /api/users/:id
- Update profile

---

## Courses

GET /api/courses?published=true&page=1&limit=20
- Response: { data: [ { id, title, subtitle, thumbnail_url, price, instructor: { id, name } } ], meta: { total, page, limit } }

GET /api/courses/:id
- Response: { id, title, description, instructor: { id, name, avatar_url }, lectures: [ ... ], schedule: [ ... ], tags: [], start_date, end_date }

POST /api/courses (teacher/admin)
PUT /api/courses/:id
DELETE /api/courses/:id

GET /api/courses/:id/lectures
- Response: [ { id, title, duration_minutes, order_index, is_published } ]

---

## Enrollments

POST /api/enrollments
- Request: { student_id, course_id }
- Response: 201 created enrollment

GET /api/users/:id/enrollments
- Response: [ { course: { id, title }, progress_percentage, status } ]

---

## Lectures & Materials

GET /api/lectures/:id
- Response: { id, title, description, video_url, materials: [ { id, file_url } ] }

POST /api/lectures/:id/materials
- File upload endpoint; returns { id, file_url }

---

## Assignments

GET /api/assignments?course_id=1
GET /api/assignments/:id

POST /api/assignments (teacher)
POST /api/assignments/:id/submissions
- Request: form-data (file) or JSON { submission_text }
- Response: submission record

GET /api/assignments/:id/submissions (teacher)

---

## Tests / Quizzes

GET /api/tests?student_id=5
GET /api/tests/:id (returns test + questions)
POST /api/tests/:id/submissions

GET /api/tests/:id/results (teacher)

---

## Events / Calendar

GET /api/events?from=YYYY-MM-DD&to=YYYY-MM-DD
- Response: [ { id, title, event_date, start_time, end_time, event_type, course: { id, title }, instructor: { id, name }, zoom_link } ]

POST /api/events (teacher/admin)
PUT /api/events/:id
DELETE /api/events/:id

---

## Library

GET /api/library?page=1&limit=20
GET /api/library/:id
POST /api/library (multipart/form-data or JSON with file URL)
PUT /api/library/:id
DELETE /api/library/:id

---

## Announcements & Notifications

GET /api/announcements?audience=students
POST /api/notifications/mark-read

---

## AI Tutor

POST /api/ai/chat
- Request: { message, conversation_id? }
- Response: { message_id, content, role }

POST /api/ai/image
- Request: { prompt }
- Response: { image_url }

POST /api/ai/transcribe
- Request: multipart/form-data with audio file
- Response: { text }

---

## File uploads

POST /api/uploads
- multipart/form-data; returns { url }
- Used by lecture_materials, assignment submissions, library uploads

---

## Example Event JSON (for FullCalendar frontend)

{
  "id": 12,
  "title": "Intro to Algebra",
  "event_date": "2025-11-14",
  "start_time": "10:00:00",
  "end_time": "11:30:00",
  "event_type": "live-class",
  "course": { "id": 1, "title": "Advanced Mathematics" },
  "instructor": { "id": 2, "name": "Dr. Smith" },
  "zoom_link": "https://zoom.us/j/123456789"
}

---

## Notes for backend team
- Return dates in ISO format (YYYY-MM-DD) and times as HH:MM:SS where relevant.
- Include minimal instructor/course objects inline to prevent extra fetches for lists.
- Support search and filters on list endpoints.
- Implement pagination for large lists.

---

If you want, I can convert this mapping into an OpenAPI YAML or a Postman collection next — tell me which format your backend team prefers.