# Total Enrollments Update Guide

## Overview
This guide explains how to update and maintain the `total_enrollments` field in the `core_course` table based on actual enrollment data from the `core_enrollments` table.

## What Was Implemented

### 1. Django Management Command
**File:** `backend/sarasedu_backend/core/management/commands/update_total_enrollments.py`

A Django management command that updates the `total_enrollments` field for all courses or a specific course.

#### Usage:

**Update all courses:**
```bash
python manage.py update_total_enrollments
```

**Update a specific course:**
```bash
python manage.py update_total_enrollments --course-id=1
```

This command will:
- Count actual enrollments from `core_enrollments` table
- Update the `total_enrollments` field in `core_course` table
- Display the results with course name, ID, and enrollment count

### 2. SQL Script
**File:** `backend/database/update_total_enrollments.sql`

A direct SQL script for updating the database without using Django.

#### Usage:
```bash
# From the backend directory
mysql -u your_username -p your_database_name < database/update_total_enrollments.sql
```

Or execute directly in your MySQL client:
```sql
UPDATE core_course c
SET c.total_enrollments = (
    SELECT COUNT(*)
    FROM core_enrollments e
    WHERE e.course_id = c.id
);
```

### 3. Automatic Updates via Signals
**File:** `backend/sarasedu_backend/core/signals.py`

Django signals have been added to automatically keep `total_enrollments` updated whenever:
- A new enrollment is created
- An enrollment is deleted
- An enrollment status is updated

This ensures the field stays in sync with actual data going forward.

## How It Works

### Database Tables
- **core_course**: Contains the `total_enrollments` field (denormalized count)
- **core_enrollments**: Contains the actual enrollment records

### The Update Process
1. Count all enrollments for each course from `core_enrollments`
2. Update the `total_enrollments` field in `core_course` with the actual count
3. Verify the update by comparing before and after values

## When to Use Each Method

### Django Management Command
- **Best for:** Regular maintenance, scheduled tasks
- **Advantages:** 
  - Detailed output and logging
  - Can target specific courses
  - Works with Django's ORM
  - Respects Django's business logic

### SQL Script
- **Best for:** Quick one-time updates, database migrations
- **Advantages:**
  - Faster for large datasets
  - No Django dependencies
  - Can be run in production environments

### Automatic Signals
- **Best for:** Ongoing maintenance
- **Advantages:**
  - Keeps data automatically synchronized
  - No manual intervention needed
  - Real-time updates

## Running the Update

### Step 1: Backup Current Data (Recommended)
```bash
# Backup current enrollment counts
mysqldump -u username -p database_name core_course > backup_before_update.sql
```

### Step 2: Run the Update
Choose one of the methods below:

**Option A: Using Django Management Command**
```bash
cd backend/sarasedu_backend
python manage.py update_total_enrollments
```

**Option B: Using SQL Script**
```bash
cd backend
mysql -u username -p database_name < database/update_total_enrollments.sql
```

### Step 3: Verify the Results
```sql
SELECT 
    c.id,
    c.title,
    c.total_enrollments,
    (SELECT COUNT(*) FROM core_enrollments e WHERE e.course_id = c.id) as actual_enrollments
FROM core_course c
ORDER BY c.id;
```

## Example Output

### Django Command Output:
```
Updated course "Introduction to Python" (ID: 1) - total_enrollments: 25
Updated course "Advanced JavaScript" (ID: 2) - total_enrollments: 18
Updated course "Data Science Basics" (ID: 3) - total_enrollments: 42

Completed! Updated 3 course(s) out of 10 total courses.
```

### SQL Verification Output:
```
+----+-------------------------+-----------------+--------------------+
| id | title                   | updated_count   | actual_count       |
+----+-------------------------+-----------------+--------------------+
|  1 | Introduction to Python  |              25 |                 25 |
|  2 | Advanced JavaScript     |              18 |                 18 |
|  3 | Data Science Basics     |              42 |                 42 |
+----+-------------------------+-----------------+--------------------+
```

## Scheduling Regular Updates

### Using Cron (Linux/Mac)
Add to crontab to run daily at 2 AM:
```bash
0 2 * * * cd /path/to/backend/sarasedu_backend && python manage.py update_total_enrollments
```

### Using Windows Task Scheduler
Create a task that runs:
```
python C:\path\to\backend\sarasedu_backend\manage.py update_total_enrollments
```

### Using Django-Cron or Celery
Add to your periodic tasks configuration for automated updates.

## Troubleshooting

### Issue: Counts Don't Match
**Solution:** Check for deleted enrollments or data integrity issues:
```sql
SELECT course_id, COUNT(*) as count
FROM core_enrollments
GROUP BY course_id
HAVING COUNT(*) != (SELECT total_enrollments FROM core_course WHERE id = course_id);
```

### Issue: Command Not Found
**Solution:** Ensure you're in the correct directory and virtual environment:
```bash
cd backend/sarasedu_backend
source /path/to/venv/bin/activate  # Linux/Mac
# or
.\venv\Scripts\Activate.ps1  # Windows PowerShell
python manage.py update_total_enrollments
```

### Issue: Permission Denied
**Solution:** Ensure the database user has UPDATE permissions on `core_course` table.

## Notes

- The `total_enrollments` field is a denormalized field for performance optimization
- With signals in place, manual updates should only be needed for historical data correction
- The field counts ALL enrollments regardless of status (active, completed, dropped, suspended)
- To count only active enrollments, modify the signals and command filters

## Related Files

- `backend/sarasedu_backend/core/models.py` - Course and Enrollment models
- `backend/sarasedu_backend/core/signals.py` - Automatic update signals
- `backend/database/schema.sql` - Database schema definition
- `backend/sarasedu_backend/core/management/commands/update_total_enrollments.py` - Management command
- `backend/database/update_total_enrollments.sql` - SQL update script
