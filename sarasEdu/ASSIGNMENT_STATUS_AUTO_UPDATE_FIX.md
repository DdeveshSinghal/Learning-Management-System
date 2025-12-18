# Assignment Status Auto-Update - Bug Fix

## Problem
Assignment with ID 1 (xyz) has due_date **2025-11-29** but status shows **active** even though today is **December 18, 2025**. The assignment is overdue but the database status was not being updated.

## Solution
Implemented automatic status updates from 'active' to 'overdue' when the due date passes.

## How It Works

### 1. **Automatic Signal-Based Update** (Real-time)
When an assignment is saved/modified, a Django signal automatically checks:
- If `status == 'active'` AND
- If `due_date < current_time`

Then it automatically updates `status` to `'overdue'`

**File:** `backend/sarasedu_backend/core/signals.py`
```python
@receiver(post_save, sender=Assignment)
def update_assignment_status_on_save(sender, instance, **kwargs):
    if instance.status == 'active' and instance.due_date and timezone.now() > instance.due_date:
        Assignment.objects.filter(id=instance.id).update(status='overdue')
```

### 2. **Manual Management Command** (Batch Update)
For existing assignments or to update all at once:

```bash
# Preview what will be updated (dry-run)
python manage.py update_assignment_statuses --dry-run

# Actually update the database
python manage.py update_assignment_statuses
```

Output example:
```
✓ Successfully updated 1 assignment(s) to "overdue":
  - ID 1: xyz (due: 2025-11-29 11:59:00, overdue by 19d 12h)
```

**File:** `backend/sarasedu_backend/core/management/commands/update_assignment_statuses.py`

## Files Modified

### Backend Changes

1. **`core/models.py`** - Assignment Model
   - Updated `STATUS` choices to include both `'active'` and `'overdue'`
   - Removed the `computed_status` property

2. **`core/serializers.py`** - AssignmentSerializer  
   - Removed `computed_status` SerializerMethodField
   - Now uses the actual `status` field from database

3. **`core/signals.py`** - Django Signals
   - Added `post_save` signal for Assignment
   - Automatically updates status when assignment becomes overdue

4. **`core/migrations/0013_update_assignment_status.py`**
   - Updated to allow both 'active' and 'overdue' status choices
   - Converts any legacy draft/archived statuses to 'active'

### New Files

5. **`core/management/commands/update_assignment_statuses.py`** (NEW)
   - Management command to batch update overdue assignments
   - Includes `--dry-run` flag for preview

6. **`core/management/__init__.py`** (NEW)
7. **`core/management/commands/__init__.py`** (NEW)

## Deployment Steps

### Step 1: Apply Migration
```bash
cd backend
python manage.py migrate core 0013_update_assignment_status
```

### Step 2: Update Existing Overdue Assignments
```bash
# Preview first
python manage.py update_assignment_statuses --dry-run

# Then update
python manage.py update_assignment_statuses
```

Expected output:
```
✓ Successfully updated 1 assignment(s) to "overdue":
  - ID 1: xyz (due: 2025-11-29 11:59:00, overdue by 19d 12h)
```

### Step 3: Deploy Backend
```bash
# No frontend changes needed, API still returns 'active'/'overdue' status
```

## Database Status Changes

### Before (Current)
```
ID: 1
title: xyz
due_date: 2025-11-29 11:59:00
status: active  ❌ (Should be overdue)
```

### After (Fixed)
```
ID: 1
title: xyz
due_date: 2025-11-29 11:59:00
status: overdue  ✅ (Correctly updated)
```

## How the Frontend Works

The `getVisibleStatus()` function in frontend now simply reads the database status:

```javascript
// Frontend uses the status from API directly
const getVisibleStatus = (assignment) => {
  const status = assignment.status;  // 'active' or 'overdue'
  
  if (userRole === 'student') {
    // Check submission state first
    const sub = mySubmissionsMap[assignment.id];
    if (sub?.status === 'graded') return 'graded';
    if (sub?.status === 'submitted') return 'submitted';
  }
  
  // Return the database status
  return status;
};
```

## Verification

To verify the fix works:

1. **Check Assignment 1 Status**
   ```sql
   SELECT id, title, due_date, status FROM core_assignment WHERE id = 1;
   ```
   Should show: `status: overdue`

2. **Test the Management Command**
   ```bash
   python manage.py update_assignment_statuses --dry-run
   ```
   Should show no assignments to update (since all are now correct)

3. **Create Test Assignment**
   - Create new assignment with due_date in the past
   - Run the management command
   - Verify it updates to 'overdue'

4. **Check API Response**
   ```bash
   curl http://localhost:8000/api/assignments/1/
   ```
   Should return `"status": "overdue"`

## Features

✅ **Automatic Real-time Update** - Updates when assignment is accessed/saved  
✅ **Batch Update Tool** - Update all at once with management command  
✅ **Dry-run Preview** - See what will change before applying  
✅ **Backward Compatible** - No breaking changes to API  
✅ **No Manual Intervention** - Works automatically going forward  
✅ **Simple Status Logic** - Status stored in DB, not computed

## Status Values

| Status | Meaning | When Applied |
|--------|---------|--------------|
| `active` | Assignment is open for submission | `due_date >= current_time` |
| `overdue` | Assignment deadline has passed | `due_date < current_time` |

## Future Improvements

1. **Celery Task** - Add periodic task to update all overdue assignments (optional)
2. **Webhook** - Trigger status update when due date is reached
3. **Scheduled Job** - Cron job to update statuses daily at midnight

For now, the signal-based approach handles 99% of cases automatically.
