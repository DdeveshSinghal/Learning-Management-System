# Total Enrollments - Deployment Checklist

## 🎯 Pre-Deployment Checklist

- [ ] Review all changes in signals.py
- [ ] Review management command code
- [ ] Ensure virtual environment is activated
- [ ] Backup current database

## 📦 Files Added/Modified

### Created Files:
- [ ] `backend/sarasedu_backend/core/management/commands/update_total_enrollments.py`
- [ ] `backend/database/update_total_enrollments.sql`
- [ ] `backend/sarasedu_backend/tests/test_total_enrollments.py`
- [ ] `TOTAL_ENROLLMENTS_UPDATE_GUIDE.md`
- [ ] `TOTAL_ENROLLMENTS_QUICK_REF.md`
- [ ] `TOTAL_ENROLLMENTS_SUMMARY.md`
- [ ] `TOTAL_ENROLLMENTS_ARCHITECTURE.md`

### Modified Files:
- [ ] `backend/sarasedu_backend/core/signals.py` (added enrollment update signals)

## 🧪 Testing Steps

### 1. Run Unit Tests
```bash
cd backend/sarasedu_backend
python manage.py test tests.test_total_enrollments -v 2
```
Expected: All tests pass ✓

### 2. Check for Python Errors
```bash
python -m py_compile core/signals.py
python -m py_compile core/management/commands/update_total_enrollments.py
```
Expected: No syntax errors ✓

### 3. Verify Signal Registration
```bash
python manage.py shell
>>> from core import signals
>>> print("Signals imported successfully")
```
Expected: No import errors ✓

## 🚀 Deployment Steps

### Step 1: Backup Database
```bash
# Backup entire database
mysqldump -u username -p database_name > backup_before_enrollments_update.sql

# Or backup just the courses table
mysqldump -u username -p database_name core_course > backup_courses_table.sql
```
- [ ] Backup created successfully

### Step 2: Apply Changes
```bash
# Pull latest code
git pull

# Activate virtual environment (if not already active)
cd backend/sarasedu_backend
source ../../venv/bin/activate  # Linux/Mac
# or
..\..\venv\Scripts\Activate.ps1  # Windows
```
- [ ] Code updated
- [ ] Virtual environment activated

### Step 3: Run Initial Update
```bash
python manage.py update_total_enrollments
```
- [ ] Command executed successfully
- [ ] Output shows updated courses

### Step 4: Verify Results
```sql
-- Check that counts match
SELECT 
    c.id,
    c.title,
    c.total_enrollments as field_value,
    (SELECT COUNT(*) FROM core_enrollments e WHERE e.course_id = c.id) as actual_count,
    CASE 
        WHEN c.total_enrollments = (SELECT COUNT(*) FROM core_enrollments e WHERE e.course_id = c.id) 
        THEN '✓ MATCH' 
        ELSE '✗ MISMATCH' 
    END as status
FROM core_course c
ORDER BY c.id;
```
- [ ] All counts match ✓

### Step 5: Test Automatic Updates
```bash
python manage.py shell
```

```python
# In Django shell
from django.contrib.auth import get_user_model
from core.models import Course, Enrollment

User = get_user_model()

# Get a test course and student
course = Course.objects.first()
student = User.objects.filter(role='student').first()

print(f"Before: {course.total_enrollments}")

# Create enrollment
enrollment = Enrollment.objects.create(student=student, course=course)

# Refresh and check
course.refresh_from_db()
print(f"After create: {course.total_enrollments}")

# Delete enrollment
enrollment.delete()

# Refresh and check
course.refresh_from_db()
print(f"After delete: {course.total_enrollments}")
```
- [ ] Count increases after enrollment creation
- [ ] Count decreases after enrollment deletion

## 🔍 Post-Deployment Verification

### Check Logs
```bash
# Check for any errors in application logs
tail -f logs/django.log

# Or check system logs
journalctl -u your-app-service -f
```
- [ ] No errors in logs

### Monitor Performance
```sql
-- Check query performance
EXPLAIN SELECT id, title, total_enrollments FROM core_course WHERE total_enrollments > 10;
```
- [ ] Query performance is acceptable

### Verify API Endpoints
```bash
# Test course list endpoint
curl -X GET http://localhost:8000/api/courses/ \
  -H "Authorization: Bearer YOUR_TOKEN"
```
- [ ] API returns courses with total_enrollments field
- [ ] Values are accurate

## 📊 Monitoring Setup

### Option 1: Scheduled Verification (Recommended)
```bash
# Add to crontab (runs daily at 3 AM)
0 3 * * * cd /path/to/backend/sarasedu_backend && python manage.py update_total_enrollments >> /var/log/enrollments_update.log 2>&1
```
- [ ] Cron job configured

### Option 2: Database Trigger (Advanced)
```sql
-- Create a stored procedure to verify counts
DELIMITER //
CREATE PROCEDURE verify_enrollment_counts()
BEGIN
    SELECT COUNT(*) as mismatches
    FROM core_course c
    WHERE c.total_enrollments != (
        SELECT COUNT(*) FROM core_enrollments e WHERE e.course_id = c.id
    );
END //
DELIMITER ;
```
- [ ] Verification procedure created

## ✅ Final Checklist

- [ ] All unit tests pass
- [ ] Initial update completed successfully
- [ ] Verification queries show matching counts
- [ ] Manual enrollment test successful
- [ ] Signals working correctly
- [ ] No errors in logs
- [ ] API endpoints returning correct data
- [ ] Monitoring/scheduled tasks configured
- [ ] Documentation reviewed
- [ ] Team notified of changes

## 🆘 Rollback Plan (If Needed)

### Rollback Steps:
1. Stop application
```bash
sudo systemctl stop your-app-service
```

2. Restore database backup
```bash
mysql -u username -p database_name < backup_before_enrollments_update.sql
```

3. Revert code changes
```bash
git revert <commit-hash>
```

4. Restart application
```bash
sudo systemctl start your-app-service
```

## 📞 Support Contacts

- **Developer**: [Your Name]
- **DBA**: [DBA Contact]
- **DevOps**: [DevOps Contact]

## 📝 Notes

- The `total_enrollments` field is now automatically maintained
- Manual updates should only be needed for historical data correction
- The field counts ALL enrollments (active, completed, dropped, suspended)
- Signals are registered in `core/apps.py` ready() method

---

**Deployment Date**: _________________
**Deployed By**: _________________
**Status**: ☐ Success  ☐ Partial  ☐ Rollback Required
