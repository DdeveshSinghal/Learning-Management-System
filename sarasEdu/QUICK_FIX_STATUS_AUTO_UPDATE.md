# Quick Fix Summary - Assignment Status Auto-Update

## The Problem
Assignment ID 1 (xyz) is **OVERDUE** but shows status **active** ❌

```
due_date:  2025-11-29 11:59:00
today:     2025-12-18
status:    active  (WRONG - should be 'overdue')
```

## The Fix - 3 Steps

### Step 1: Apply Migration
```bash
cd backend
python manage.py migrate core 0013_update_assignment_status
```

### Step 2: Update Existing Overdue Assignments
```bash
# See what will be updated
python manage.py update_assignment_statuses --dry-run

# Apply the update
python manage.py update_assignment_statuses
```

Output:
```
✓ Successfully updated 1 assignment(s) to "overdue":
  - ID 1: xyz (due: 2025-11-29 11:59:00, overdue by 19d 12h)
```

### Step 3: Deploy
Deploy the backend code changes.

## After the Fix ✅
Assignment 1 now shows: `status: overdue`

## Files Changed
- `core/models.py` - Updated STATUS choices
- `core/serializers.py` - Removed computed_status
- `core/signals.py` - Added auto-update logic
- `core/migrations/0013_...py` - Updated schema
- `core/management/commands/...py` - New batch update command

## How It Works

**Automatic (Real-time):**
- When an assignment is saved, a signal checks if it's overdue
- If yes, automatically updates status to 'overdue'

**Manual (Batch):**
- Run the management command to update all overdue assignments at once
- Use `--dry-run` to preview changes first

## No Frontend Changes Needed
Frontend already displays status correctly. After the fix, it will show 'overdue' properly.

## Verify the Fix
```sql
SELECT id, title, status FROM core_assignment WHERE id = 1;
-- Should show: status = 'overdue'
```
