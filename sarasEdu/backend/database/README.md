# SarasEduHub Database Documentation

## Overview
This directory contains the complete PostgreSQL database schema, sample data, and queries for the SarasEduHub Learning Management System.

## Database Type
**PostgreSQL** (Replit provides PostgreSQL, not MySQL)

## Files

### 1. `schema.sql`
Complete database schema with:
- **26 tables** covering all LMS functionality
- **Foreign key relationships** for data integrity
- **Indexes** for query performance
- **Triggers** for automatic timestamp updates
- **Check constraints** for data validation

### 2. `sample_data.sql`
Realistic sample data including:
- 1 Admin, 3 Teachers, 5 Students
- 3 Courses with lectures and materials
- Enrollments and progress tracking
- Assignments, tests, and submissions
- Attendance records
- Library items, events, announcements

### 3. `queries.sql`
70+ ready-to-use SQL queries for:
- User management
- Course enrollment and progress
- Assignment and test management
- Attendance tracking
- Analytics and reporting
- Library operations
- Notifications and announcements

## Database Structure

### Core Entities

#### Users & Profiles
- `users` - Base user table
- `student_profiles` - Student-specific data
- `teacher_profiles` - Teacher-specific data  
- `admin_profiles` - Admin-specific data

#### Courses & Learning
- `courses` - Course information
- `lectures` - Lecture/lesson content
- `lecture_materials` - Supplementary materials
- `lecture_progress` - Student progress tracking
- `course_schedules` - Class schedules
- `study_materials` - Course documents
- `enrollments` - Student-course relationships

#### Assessments
- `assignments` - Assignment details
- `assignment_submissions` - Student submissions
- `assignment_attachments` - Assignment files
- `tests` - Tests and quizzes
- `questions` - Test questions
- `test_submissions` - Student test attempts
- `test_answers` - Individual question responses

#### Attendance & Analytics
- `attendance_records` - Daily attendance
- `user_activity_logs` - User actions
- `daily_reports` - Platform statistics

#### Library & Resources
- `library_items` - Educational resources
- `library_favorites` - User bookmarks
- `library_downloads` - Download tracking

#### Communication
- `events` - Calendar events
- `event_attendees` - Event participants
- `announcements` - System announcements
- `announcement_reads` - Read tracking
- `notifications` - User notifications
- `discussion_threads` - Course discussions
- `discussion_posts` - Discussion messages
- `ai_tutor_conversations` - AI chat sessions
- `ai_tutor_messages` - Chat messages

#### Feedback
- `course_reviews` - Course ratings
- `teacher_ratings` - Teacher feedback

## Setup Instructions

### Option 1: Using Replit Database Pane (Recommended)
1. Click on the "Database" icon in the left sidebar
2. Create a new PostgreSQL database
3. Open the database console
4. Copy and paste `schema.sql` content
5. Execute to create all tables
6. Copy and paste `sample_data.sql` content (optional)
7. Execute to populate with sample data

### Option 2: Using Command Line
```bash
# Connect to PostgreSQL
psql $DATABASE_URL

# Run schema
\i database/schema.sql

# Load sample data (optional)
\i database/sample_data.sql
```

### Option 3: Using Node.js
```javascript
const { Pool } = require('pg');
const fs = require('fs');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL
});

async function setupDatabase() {
  const schema = fs.readFileSync('database/schema.sql', 'utf8');
  await pool.query(schema);
  
  const sampleData = fs.readFileSync('database/sample_data.sql', 'utf8');
  await pool.query(sampleData);
  
  console.log('Database setup complete!');
}

setupDatabase();
```

## Key Features

### Data Integrity
- Foreign key constraints ensure referential integrity
- Check constraints validate data values
- Unique constraints prevent duplicates
- NOT NULL constraints for required fields

### Performance Optimization
- Strategic indexes on frequently queried columns
- Composite indexes for common query patterns
- JSONB for flexible structured data (test options, activity logs)

### Automatic Timestamp Management
- `created_at` timestamps on all tables
- `updated_at` auto-updates via triggers on 7 main tables
- Consistent timezone handling (UTC)

### Scalability Features
- Normalized design reduces data redundancy
- Efficient query patterns in `queries.sql`
- Ready for connection pooling
- Supports horizontal scaling

## Common Query Examples

### Get Student Dashboard Data
```sql
-- See queries.sql: "Student performance dashboard"
```

### Enroll Student in Course
```sql
INSERT INTO enrollments (student_id, course_id)
VALUES (5, 1);
```

### Mark Attendance
```sql
INSERT INTO attendance_records (student_id, course_id, date, status, marked_by)
VALUES (5, 1, CURRENT_DATE, 'present', 2);
```

### Submit Assignment
```sql
INSERT INTO assignment_submissions (
    assignment_id, student_id, submission_text, status
)
VALUES (1, 5, 'My solution...', 'submitted');
```

### Grade Assignment
```sql
UPDATE assignment_submissions
SET status = 'graded',
    marks_obtained = 45,
    grade = 'A',
    teacher_feedback = 'Excellent work!',
    graded_by = 2,
    graded_at = NOW()
WHERE id = 1;
```

## Connection in Node.js/React

### Install Package
```bash
npm install pg
```

### Create Database Connection
```javascript
// server/db.js
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});

module.exports = {
  query: (text, params) => pool.query(text, params),
  pool
};
```

### Use in API
```javascript
const db = require('./db');

// Get user
app.get('/api/users/:id', async (req, res) => {
  const { id } = req.params;
  const result = await db.query(
    'SELECT * FROM users WHERE id = $1',
    [id]
  );
  res.json(result.rows[0]);
});

// Enroll student
app.post('/api/enrollments', async (req, res) => {
  const { student_id, course_id } = req.body;
  const result = await db.query(
    'INSERT INTO enrollments (student_id, course_id) VALUES ($1, $2) RETURNING *',
    [student_id, course_id]
  );
  res.json(result.rows[0]);
});
```

## Environment Variables

Add to `.env` file:
```env
DATABASE_URL=postgresql://username:password@host:port/database
```

In Replit, this is automatically set when you create a PostgreSQL database.

## Best Practices

### Security
- ✅ Use parameterized queries to prevent SQL injection
- ✅ Hash passwords with bcrypt (never store plain text)
- ✅ Validate input data before database insertion
- ✅ Use least-privilege database users
- ✅ Keep database credentials in environment variables

### Performance
- ✅ Use connection pooling
- ✅ Add indexes on frequently searched columns
- ✅ Batch insert operations when possible
- ✅ Use transactions for multi-step operations
- ✅ Monitor slow queries and optimize

### Maintenance
- ✅ Regular backups (Replit handles this automatically)
- ✅ Monitor database size and growth
- ✅ Archive old records periodically
- ✅ Update statistics for query optimizer
- ✅ Review and optimize indexes

## Migration Strategy

When deploying to production:
1. Test schema on development database
2. Create backup of production database
3. Run schema.sql on production
4. Verify all tables created successfully
5. Test critical queries
6. Monitor for errors

For schema updates:
1. Create migration files with version numbers
2. Test migrations on development
3. Apply migrations during maintenance window
4. Verify data integrity after migration

## Support

For database-related questions or issues:
- Review the `queries.sql` file for examples
- Check table structure in `schema.sql`
- Consult PostgreSQL documentation
- Use Replit's database pane for visual inspection

## License

This database schema is part of SarasEduHub and follows the same license as the main project.
