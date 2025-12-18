# Assignment Status System Update - Implementation Guide

## Summary of Changes

This update removes the `draft` and `archived` statuses from the assignment system and replaces them with dynamic status computation based on the assignment's due date.

### What Changed?

**Before:**
- Statuses: `active`, `draft`, `archived`
- Teachers could create draft assignments
- Manual status management

**After:**
- Statuses: `active` (stored in DB), `overdue` (computed dynamically)
- All assignments created are immediately `active`
- Status automatically updates based on current time vs due_date

## Files Modified

### Backend Files
1. **`backend/sarasedu_backend/core/models.py`**
   - Updated `Assignment.STATUS` to only include `'active'`
   - Added `computed_status` property

2. **`backend/sarasedu_backend/core/serializers.py`**
   - Added `computed_status` SerializerMethodField to AssignmentSerializer

3. **`backend/sarasedu_backend/core/migrations/0013_update_assignment_status.py`** (NEW)
   - Database migration to update status field choices
   - Converts existing draft/archived assignments to active

### Frontend Files
1. **`frontend/src/components/assignment-system.jsx`**
   - Removed "Save as Draft" button
   - Simplified `getVisibleStatus()` logic
   - Removed draft/archived status references
   - Updated submission details visibility condition
   - Removed graded status display from assignment cards

## How to Deploy

### Step 1: Apply Database Migration
```bash
cd backend
python manage.py migrate core 0013_update_assignment_status
```

This will:
- Update the `status` field in the `Assignment` model
- Convert any existing `draft` or `archived` assignments to `active`

### Step 2: Deploy Backend
```bash
# Test the changes
python manage.py test

# Deploy normally
```

### Step 3: Deploy Frontend
```bash
cd frontend
npm run build
```

## How It Works

### Status Computation Logic

```python
# Backend (Python)
@property
def computed_status(self):
    if timezone.now() > self.due_date:
        return 'overdue'
    return 'active'
```

```javascript
// Frontend (JavaScript)
const getVisibleStatus = (assignment) => {
  // For students: check submission first, then due date
  if (userRole === 'student') {
    const sub = mySubmissionsMap[assignment.id];
    if (sub) {
      if (sub.status === 'graded' || sub.grade != null) return 'graded';
      if (sub.status === 'submitted') return 'submitted';
    }
    if (isOverdue(getDueDate(assignment))) return 'overdue';
    return 'active';
  }
  
  // For teachers: just check due date
  if (isOverdue(getDueDate(assignment))) return 'overdue';
  return 'active';
};
```

## Migration Strategy

### For Existing Data
- All `draft` assignments → converted to `active`
- All `archived` assignments → converted to `active`
- All `active` assignments → remain `active`

**Why?** Draft assignments are work-in-progress and should be treated as active to remain visible. Archived assignments are made active as a conservative approach (they were likely complete but should not be lost).

### Rollback Plan
If needed to rollback:
```bash
python manage.py migrate core 0012
```
This will revert to the previous migration but will NOT restore draft/archived statuses (they'll remain as their converted values).

## API Changes

### POST/PUT Assignment Endpoints
- Request can still include `status` field (will be ignored)
- Response includes both:
  - `status`: Always `'active'` (or the old value if from before migration)
  - `computed_status`: Dynamically computed (`'active'` or `'overdue'`)

### GET Assignment Endpoints
Response example:
```json
{
  "id": 1,
  "title": "Math Assignment",
  "due_date": "2025-12-25T23:59:59Z",
  "status": "active",
  "computed_status": "overdue",
  "...": "other fields"
}
```

## Testing Checklist

After deployment, test:

- [ ] **Create Assignment**: Create new assignment with future due date
  - Should appear in "Active" tab
  - Status should show "active" in UI
  - `computed_status` in API should be "active"

- [ ] **Overdue Assignment**: Create assignment with past due date
  - Should appear in "Overdue" tab
  - Status should show "overdue" in UI
  - `computed_status` in API should be "overdue"

- [ ] **No Draft Button**: Verify "Save as Draft" button is gone
  - Only "Create Assignment" button should exist
  - Requires all fields to be filled

- [ ] **Filter Tabs**: Test all assignment tabs
  - All, Active, Submitted, Graded, Overdue
  - Counts should be accurate

- [ ] **Submission Details**: 
  - Submit assignment as student
  - Verify submission details appear in assignment view
  - Verify grade section appears after teacher grades

- [ ] **Existing Assignments**: 
  - Verify any existing draft/archived assignments appear
  - They should be marked as `active` in DB

- [ ] **Date Boundary**: 
  - Create assignment due in 1 minute
  - Wait for it to pass
  - Verify status changes to "overdue" (may need page refresh)

## Known Limitations

1. **Client-side Status Display**: Frontend status may not update in real-time without page refresh
   - Solution: Call `fetchAssignments()` periodically or after specific timeouts

2. **Timezone Handling**: Status comparison uses server timezone
   - Ensure server timezone is consistent across deployment
   - Frontend displays times in user's local timezone

3. **No Draft Save**: Teachers cannot save incomplete assignments
   - Workaround: Create assignment with temporary due date and edit later

## Performance Considerations

- **No Database Impact**: Status is computed from `due_date` field, no additional queries
- **Serializer Performance**: `computed_status` computed on-the-fly (minimal overhead)
- **Caching**: If using caching, be aware status changes without explicit save

## Support & Troubleshooting

### Issue: Status not updating to "overdue"
- **Cause**: Client-side cache or timezone mismatch
- **Solution**: Refresh page, check server timezone

### Issue: Migration fails
- **Cause**: Corrupted data or Django version issues
- **Solution**: Check Django version matches requirements.txt

### Issue: Assignments missing after migration
- **Cause**: Unusual - migration preserves all assignments
- **Solution**: Check database directly: `SELECT * FROM core_assignment;`

## Questions?

Refer to `ASSIGNMENT_STATUS_SYSTEM_UPDATE.md` for detailed documentation.
