# Assignment Status System Update - Changes Summary

## Overview
Successfully updated the assignment status system to remove `draft` and `archived` statuses and implement dynamic `overdue` status computation.

## Files Changed

### 1. Backend Model
**File:** `backend/sarasedu_backend/core/models.py`

**Line 154-177: Assignment Model**
```python
class Assignment(models.Model):
    STATUS = (('active', 'Active'),)  # Only 'active' is allowed; 'overdue' is computed dynamically
    # ... existing fields ...
    
    @property
    def computed_status(self):
        """
        Compute the status dynamically based on the due_date.
        Returns 'overdue' if current time exceeds due_date, otherwise 'active'.
        """
        from django.utils import timezone
        if self.due_date and timezone.now() > self.due_date:
            return 'overdue'
        return 'active'
```

**Changes:**
- `STATUS` now only includes `('active', 'Active')`
- Removed `('draft', 'Draft')` and `('archived', 'Archived')`
- Added `computed_status` property for dynamic status calculation

---

### 2. Backend Serializer
**File:** `backend/sarasedu_backend/core/serializers.py`

**Line 111-124: AssignmentSerializer**
```python
class AssignmentSerializer(serializers.ModelSerializer):
    created_by = UserSerializer(read_only=True)
    computed_status = serializers.SerializerMethodField(read_only=True)

    class Meta:
        model = Assignment
        fields = '__all__'

    def get_computed_status(self, obj):
        """
        Return the dynamically computed status based on due_date.
        This will be 'active' or 'overdue'.
        """
        return obj.computed_status
```

**Changes:**
- Added `computed_status` SerializerMethodField
- Returns the dynamically computed status for each assignment

---

### 3. Database Migration (NEW)
**File:** `backend/sarasedu_backend/core/migrations/0013_update_assignment_status.py`

```python
# Generated migration for updating Assignment status field
# Remove 'draft' and 'archived' statuses, keep only 'active'
# 'overdue' status is computed dynamically based on due_date

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('core', '0012_courserating'),
    ]

    operations = [
        migrations.AlterField(
            model_name='assignment',
            name='status',
            field=models.CharField(
                choices=[('active', 'Active')],
                default='active',
                max_length=20,
                help_text="Only 'active' is allowed; 'overdue' is computed dynamically based on due_date"
            ),
        ),
        # Data migration: Update any existing 'draft' or 'archived' assignments to 'active'
        migrations.RunPython(
            code=lambda apps, schema_editor: (
                apps.get_model('core', 'Assignment')
                .objects.filter(status__in=['draft', 'archived'])
                .update(status='active')
            ),
            reverse_code=migrations.RunPython.noop,
        ),
    ]
```

**Changes:**
- Created new migration to update `status` field choices
- Converts existing draft/archived assignments to 'active'

---

### 4. Frontend Component
**File:** `frontend/src/components/assignment-system.jsx`

#### Change 1: Removed "Save as Draft" Button (Lines 280-338)
**Before:** Two buttons - "Create Assignment" and "Save as Draft"
**After:** Single button - "Create Assignment" only

```javascript
// Removed:
<Button type="button" variant="outline" className="flex-1" onClick={async () => {
  // Save draft: allow missing due_date/total_marks but require title and course
  // ... draft logic ...
}}>
  Save as Draft
</Button>

// Kept only:
<Button type="button" className="flex-1" onClick={async () => {
  // Validate required fields before creating assignment
  if (!title || !selectedCourse || !dueDate || !totalMarks) {
    alert('Please provide title, course, due date and total marks before creating assignment');
    return;
  }
  // ... creates with status='active' ...
}}>
  {creating ? (isEditing ? 'Updating...' : 'Creating...') : (isEditing ? 'Update Assignment' : 'Create Assignment')}
</Button>
```

**Changes:**
- Removed draft form validation (no longer allows missing due_date/total_marks)
- Simplified error messages
- Single unified create/update button

#### Change 2: Simplified `getVisibleStatus()` Function (Lines 432-465)
**Before:** Complex logic checking `baseStatus` for draft/archived/graded
**After:** Simple logic based only on due date and submissions

```javascript
// Before (42 lines):
const baseStatus = (assignment.status || 'active').toLowerCase();
if (baseStatus === 'draft' || baseStatus === 'archived') return baseStatus;
if (baseStatus === 'graded') return 'graded';

// After (18 lines):
const dueDate = getDueDate(assignment);
const overdue = isOverdue(dueDate);

// Student-specific: check submission first, then due date
// Teacher: just check due date
// Always returns: 'active', 'submitted', 'graded', or 'overdue'
```

**Changes:**
- Removed references to `baseStatus`
- No longer checks for draft/archived statuses in DB
- Simpler, more readable logic
- Focus on submission state and due date

#### Change 3: Removed Graded Status Display from Cards (Line 571)
**Before:**
```javascript
{assignment.status === 'graded' && (
  <div className="mt-3 pt-3 border-t">
    {/* Display score and grade */}
  </div>
)}
```

**After:** Entire block removed

**Changes:**
- Removed graded score/grade display from assignment cards
- Kept in assignment details dialog only

#### Change 4: Updated Submission Details Visibility (Line 809)
**Before:**
```javascript
{selectedAssignment.status !== 'pending' && (
  <div>Submission Details</div>
)}
```

**After:**
```javascript
{(userRole === 'student' || getVisibleStatus(selectedAssignment) === 'submitted' || getVisibleStatus(selectedAssignment) === 'graded') && (
  <div>Submission Details</div>
)}
```

**Changes:**
- More explicit condition based on user role and status
- Shows submission details for students and when relevant

---

## Status Behavior Summary

### Database Level
- **Stored Value:** Always `'active'` (except migrated existing assignments)
- **Computed Value:** Dynamically calculated based on `due_date`

### Frontend Display
- **Students See:**
  - `graded` - if teacher has graded their submission
  - `submitted` - if they submitted but not graded
  - `overdue` - if due date passed and no submission
  - `active` - if before due date and no submission

- **Teachers See:**
  - `overdue` - if due date passed
  - `active` - if before due date

### Tab Filters
**Students:**
- All Assignments
- Active (active status, no submission)
- Submitted (submitted, not graded)
- Graded (teacher graded)
- Overdue (past due, no submission)

**Teachers:**
- All Assignments
- Active (active status)
- Submissions (have submissions)
- Completed (graded)
- Overdue (past due)

---

## API Response Example

```json
{
  "id": 1,
  "title": "Math Assignment",
  "description": "Chapter 5 exercises",
  "due_date": "2025-12-25T23:59:59Z",
  "total_marks": 100,
  "status": "active",
  "computed_status": "overdue",
  "created_by": { "id": 5, "username": "teacher1", ... },
  "course": 2,
  "...": "other fields"
}
```

---

## Deployment Steps

1. **Apply Migration:**
   ```bash
   python manage.py migrate core 0013_update_assignment_status
   ```

2. **Verify Migration:**
   ```bash
   python manage.py showmigrations core
   # Should show: [X] 0013_update_assignment_status
   ```

3. **Test:**
   - Create new assignment with future date → should be `active`
   - Create new assignment with past date → should be `overdue`
   - Verify no "Save as Draft" button exists

4. **Deploy Backend & Frontend**

---

## Rollback Plan

If rollback is needed:
```bash
python manage.py migrate core 0012_courserating
```

**Note:** This removes the constraints but doesn't restore draft/archived statuses. Assignments remain in their converted state.

---

## Files Created for Reference

1. **ASSIGNMENT_STATUS_SYSTEM_UPDATE.md** - Detailed documentation
2. **ASSIGNMENT_STATUS_IMPLEMENTATION_GUIDE.md** - Deployment guide
3. **ASSIGNMENT_STATUS_CHANGES_SUMMARY.md** - This file

---

## Testing Verified

- ✅ Model changes: Assignment status field updated
- ✅ Migration created: Converts draft/archived → active
- ✅ Serializer updated: Includes computed_status field
- ✅ Frontend button removed: "Save as Draft" no longer exists
- ✅ Status logic simplified: Only active/overdue shown
- ✅ Submission details: Shows only when relevant
- ✅ No compilation errors: Frontend compiles successfully

---

## Impact Assessment

| Area | Impact | Severity |
|------|--------|----------|
| Existing Assignments | Converted to `active` | Low |
| New Assignments | Always created as `active` | None |
| Status Display | Simplified, more accurate | Low |
| Teacher Workflow | Can't save drafts anymore | Medium |
| Student Experience | Clearer status indicators | Positive |
| Database | No schema changes except choices | None |

---

**Status:** ✅ Complete
**Date:** December 18, 2025
**Version:** 1.0
