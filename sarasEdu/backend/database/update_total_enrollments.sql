-- ============================================
-- Update total_enrollments field in core_course 
-- based on core_enrollments data
-- ============================================

-- Step 1: Update all courses with enrollment counts
UPDATE core_course c
SET c.total_enrollments = (
    SELECT COUNT(*)
    FROM core_enrollments e
    WHERE e.course_id = c.id
);

-- Step 2: Verify the update
SELECT 
    c.id,
    c.title,
    c.total_enrollments as updated_count,
    (SELECT COUNT(*) FROM core_enrollments e WHERE e.course_id = c.id) as actual_count,
    CASE 
        WHEN c.total_enrollments = (SELECT COUNT(*) FROM core_enrollments e WHERE e.course_id = c.id) 
        THEN 'OK' 
        ELSE 'MISMATCH' 
    END as status
FROM core_course c
ORDER BY c.id;

-- Step 3: Show summary
SELECT 
    COUNT(*) as total_courses,
    SUM(total_enrollments) as total_enrollments_across_all_courses
FROM core_course;
