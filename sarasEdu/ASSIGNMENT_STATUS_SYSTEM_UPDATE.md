# Assignment Status System Update

## Overview
Updated the assignment status system to use only two states: `active` and `overdue`. The `overdue` status is computed dynamically based on the current date/time compared to the assignment's due date.

## Changes Made

### 1. Backend - Database Model (`backend/sarasedu_backend/core/models.py`)
**Changes:**
- Updated `Assignment.STATUS` choices to only include `('active', 'Active')`
- Removed `('draft', 'Draft')` and `('archived', 'Archived')` choices
- Added `computed_status` property that:
  - Returns `'overdue'` if current time exceeds the due_date
  - Returns `'active'` otherwise

**Key Implementation:**
```python
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

### 2. Database Migration (`backend/sarasedu_backend/core/migrations/0013_update_assignment_status.py`)
**Changes:**
- Created migration to:
  - Update the `status` field choices to only include `'active'`
  - Convert any existing `draft` or `archived` assignments to `active`
  - Add help text explaining the new behavior

### 3. Backend - Serializer (`backend/sarasedu_backend/core/serializers.py`)
**Changes:**
- Added `computed_status` as a SerializerMethodField
- Returns the dynamically computed status for each assignment
- This field is read-only and computed on-the-fly

**Implementation:**
```python
class AssignmentSerializer(serializers.ModelSerializer):
    created_by = UserSerializer(read_only=True)
    computed_status = serializers.SerializerMethodField(read_only=True)

    class Meta:
        model = Assignment
        fields = '__all__'

    def get_computed_status(self, obj):
        return obj.computed_status
```

### 4. Frontend - Status Logic (`frontend/src/components/assignment-system.jsx`)
**Changes:**

#### a. Removed Draft Creation
- Removed "Save as Draft" button
- Removed draft-related form validation and logic
- Single button now always creates assignments with `status='active'`

#### b. Simplified `getVisibleStatus()` Function
- Removed references to `draft` and `archived` statuses
- Logic now simplified to:
  - **Students**: Check submission state first (graded/submitted), then check due date (overdue/active)
  - **Teachers**: Show based on due date only (overdue/active)

#### c. Updated Submission Details Condition
- Changed from `selectedAssignment.status !== 'pending'` 
- To: `userRole === 'student' || getVisibleStatus(selectedAssignment) === 'submitted' || getVisibleStatus(selectedAssignment) === 'graded'`
- This ensures submission details only show when relevant

#### d. Removed Graded Status Badge from Card
- Removed the card-level display of graded status with score/grade
- Grading information is only shown in the assignment details dialog

## Status Values

| Status | Meaning | Duration |
|--------|---------|----------|
| `active` | Assignment is open for submission (due_date not yet reached) | current_time ≤ due_date |
| `overdue` | Assignment deadline has passed (computed dynamically) | current_time > due_date |

## Frontend Tab Labels

### For Students:
- **All Assignments**: All assignments
- **Active**: Assignments before due date with no submission
- **Submitted**: Assignments with student submission but not graded
- **Graded**: Assignments that have been graded by teacher
- **Overdue**: Assignments past due date with no submission

### For Teachers:
- **All Assignments**: All assignments
- **Active**: Assignments before due date
- **Submissions**: Assignments with student submissions
- **Completed**: Assignments that have been graded
- **Overdue**: Assignments past due date

## API Changes

### Request (Create/Update Assignment)
- Always set `status` to `'active'` (only valid value)
- Backend automatically enforces this

### Response (Get Assignment)
- Includes both fields:
  - `status`: Database value (always `'active'`)
  - `computed_status`: Dynamically computed value (`'active'` or `'overdue'`)

## Deployment Notes

1. **Database Migration Required**: Run migration `0013_update_assignment_status.py`
   ```bash
   python manage.py migrate core 0013
   ```

2. **Data Cleanup**: Any existing `draft` or `archived` assignments will be converted to `active`

3. **No Breaking Changes**: 
   - API still accepts create/update requests (ignoring status field if provided)
   - Frontend removes draft functionality
   - Existing assignments remain functional

4. **Verification**: After deployment, verify:
   - No errors when loading assignments list
   - Overdue status correctly computed based on current time
   - All tabs filter assignments correctly
   - Teachers can still create assignments

## Testing Checklist

- [ ] Create a new assignment with future due date → should show as `active`
- [ ] Create/edit assignment with past due date → should show as `overdue`
- [ ] View assignment details and verify submission section appears correctly
- [ ] Run database migration successfully
- [ ] Verify existing assignments are converted to `active` status
- [ ] Test all filter tabs (All, Active, Submitted, Graded, Overdue)
- [ ] Verify status colors/icons display correctly

## Benefits

1. **Simpler Status Management**: Only two states to manage instead of four
2. **Dynamic Computation**: No need to manually update status when deadline passes
3. **Consistency**: Status is always current and accurate
4. **Reduced UI Complexity**: Removed draft functionality simplifies the assignment creation flow
5. **Better UX**: Clear distinction between active and overdue assignments for students
