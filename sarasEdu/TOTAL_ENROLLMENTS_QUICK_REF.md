# Quick Reference: Update Total Enrollments

## 🚀 Quick Commands

### Update ALL courses
```bash
cd backend/sarasedu_backend
python manage.py update_total_enrollments
```

### Update ONE specific course
```bash
python manage.py update_total_enrollments --course-id=5
```

### Direct SQL Update
```sql
UPDATE core_course c
SET c.total_enrollments = (
    SELECT COUNT(*) FROM core_enrollments e WHERE e.course_id = c.id
);
```

## 📋 What Was Added

1. **Management Command**: `update_total_enrollments.py` - Updates enrollment counts
2. **SQL Script**: `update_total_enrollments.sql` - Direct database update
3. **Auto-sync Signals**: Keeps counts updated automatically on enrollment changes
4. **Test Suite**: `test_total_enrollments.py` - Verifies functionality

## ✅ Automatic Updates

The system now automatically updates `total_enrollments` when:
- ✓ New enrollment created
- ✓ Enrollment deleted
- ✓ Enrollment modified

## 🔍 Verify Results

```sql
SELECT id, title, total_enrollments,
       (SELECT COUNT(*) FROM core_enrollments e WHERE e.course_id = c.id) as actual
FROM core_course c;
```

## 📚 Full Documentation

See `TOTAL_ENROLLMENTS_UPDATE_GUIDE.md` for complete details.
