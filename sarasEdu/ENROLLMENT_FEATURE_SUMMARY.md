# Course Enrollment Feature Implementation

## Overview
Implemented a course enrollment system where students must enroll in a course before they can access and learn from it. The enrollment information is stored in the `core_enrollment` table in the database.

## Changes Made

### 1. API Service Updates (`frontend/src/services/api.js`)
Added three new enrollment-related functions:

- **`getEnrollments()`** - Fetches all enrollments for the current user
- **`enrollInCourse(courseId, studentId)`** - Creates a new enrollment record in the database
- **`checkEnrollment(courseId, studentId)`** - Checks if a student is enrolled in a specific course

### 2. SimpleCourses Component Updates (`frontend/src/components/simple-courses.jsx`)

#### Imports
- Added `useAuth` hook to access the current user
- Added `UserPlus` icon from lucide-react for the enroll button
- Added `toast` from sonner for user feedback

#### State Management
- Added `enrollments` state to track user's course enrollments
- Added `enrollingCourseId` state to track which course is being enrolled (for loading state)

#### Data Fetching
- Modified `useEffect` to fetch both courses and enrollments in parallel
- Only fetches enrollments for students (not teachers or admins)

#### New Functions
- **`handleEnroll(courseId)`** - Handles the enrollment process:
  - Validates user is logged in
  - Calls the enrollment API
  - Shows success/error toast notifications
  - Refreshes enrollments after successful enrollment

- **`isEnrolled(courseId)`** - Checks if the current user is enrolled in a course

#### UI Changes
For student users, the course card now shows:
- **Enrolled students**: Progress bar and "Continue Learning" button
- **Non-enrolled students**: "Enroll Now" button with loading state

## Database Integration
The enrollment is saved to the `core_enrollment` table with:
- `student` - Foreign key to the User
- `course` - Foreign key to the Course
- `status` - Set to 'active' by default
- `enrollment_date` - Automatically set when created

## User Experience Flow

### For Non-Enrolled Students:
1. Student views courses page
2. Sees "Enroll Now" button on each course card
3. Clicks "Enroll Now"
4. System creates enrollment record
5. Shows success message
6. Button changes to "Continue Learning" with progress tracking

### For Enrolled Students:
1. Student views courses page
2. Sees their enrolled courses with progress bars
3. Can click "Continue Learning" to access course content

## Backend API Endpoints Used
- `GET /enrollments/` - Fetch user enrollments
- `POST /enrollments/` - Create new enrollment

## Notes
- Only students can enroll in courses
- Enrollment is required to access course learning materials
- Each student can only enroll once per course (enforced by database unique constraint)
- Teachers and admins see different UI (View/Edit buttons) without enrollment requirements
