-- Common SQL Queries for SarasEduHub LMS
-- Collection of frequently used queries for the platform

-- ============================================
-- USER QUERIES
-- ============================================

-- Get all students with their profile information
SELECT 
    u.id, u.name, u.email, u.status, u.join_date,
    sp.roll_number, sp.grade_level, sp.average_grade
FROM users u
INNER JOIN student_profiles sp ON u.id = sp.user_id
WHERE u.role = 'student'
ORDER BY u.name;

-- Get all teachers with their department and rating
SELECT 
    u.id, u.name, u.email, u.phone,
    tp.department, tp.qualification, tp.average_rating,
    COUNT(DISTINCT c.id) as courses_teaching
FROM users u
INNER JOIN teacher_profiles tp ON u.id = tp.user_id
LEFT JOIN courses c ON c.instructor_id = u.id
WHERE u.role = 'teacher' AND u.status = 'active'
GROUP BY u.id, u.name, u.email, u.phone, tp.department, tp.qualification, tp.average_rating
ORDER BY tp.average_rating DESC;

-- Get user's complete profile
SELECT 
    u.*,
    CASE 
        WHEN u.role = 'student' THEN json_build_object(
            'roll_number', sp.roll_number,
            'grade_level', sp.grade_level,
            'average_grade', sp.average_grade
        )
        WHEN u.role = 'teacher' THEN json_build_object(
            'employee_id', tp.employee_id,
            'department', tp.department,
            'average_rating', tp.average_rating
        )
        ELSE NULL
    END as profile_data
FROM users u
LEFT JOIN student_profiles sp ON u.id = sp.user_id
LEFT JOIN teacher_profiles tp ON u.id = tp.user_id
WHERE u.id = 5;

-- ============================================
-- COURSE QUERIES
-- ============================================

-- Get all active courses with instructor details
SELECT 
    c.id, c.title, c.category, c.level, c.price,
    c.total_enrollments, c.average_rating,
    u.name as instructor_name,
    u.email as instructor_email
FROM courses c
INNER JOIN users u ON c.instructor_id = u.id
WHERE c.status = 'active' AND c.is_published = true
ORDER BY c.average_rating DESC, c.total_enrollments DESC;

-- Get student's enrolled courses with progress
SELECT 
    c.id, c.title, c.category, c.thumbnail_url,
    u.name as instructor_name,
    e.progress_percentage, e.status, e.enrollment_date,
    c.total_lectures,
    COUNT(DISTINCT lp.id) FILTER (WHERE lp.status = 'completed') as completed_lectures
FROM enrollments e
INNER JOIN courses c ON e.course_id = c.id
INNER JOIN users u ON c.instructor_id = u.id
LEFT JOIN lectures l ON l.course_id = c.id
LEFT JOIN lecture_progress lp ON lp.lecture_id = l.id AND lp.student_id = e.student_id
WHERE e.student_id = 5 AND e.status = 'active'
GROUP BY c.id, c.title, c.category, c.thumbnail_url, u.name, 
         e.progress_percentage, e.status, e.enrollment_date, c.total_lectures
ORDER BY e.last_accessed DESC NULLS LAST;

-- Get course details with complete information
SELECT 
    c.*,
    u.name as instructor_name,
    u.email as instructor_email,
    u.bio as instructor_bio,
    tp.department, tp.qualification,
    COUNT(DISTINCT e.id) as total_students,
    COUNT(DISTINCT l.id) as total_lectures,
    AVG(cr.rating) as avg_rating,
    COUNT(DISTINCT cr.id) as review_count
FROM courses c
INNER JOIN users u ON c.instructor_id = u.id
LEFT JOIN teacher_profiles tp ON u.id = tp.user_id
LEFT JOIN enrollments e ON c.id = e.course_id AND e.status = 'active'
LEFT JOIN lectures l ON c.id = l.course_id
LEFT JOIN course_reviews cr ON c.id = cr.course_id
WHERE c.id = 1
GROUP BY c.id, u.name, u.email, u.bio, tp.department, tp.qualification;

-- Get course curriculum (lectures)
SELECT 
    l.id, l.title, l.description, l.duration_minutes, l.order_index,
    l.is_published, l.is_free_preview,
    COUNT(lm.id) as materials_count
FROM lectures l
LEFT JOIN lecture_materials lm ON l.id = lm.lecture_id
WHERE l.course_id = 1 AND l.is_published = true
GROUP BY l.id, l.title, l.description, l.duration_minutes, l.order_index, 
         l.is_published, l.is_free_preview
ORDER BY l.order_index;

-- ============================================
-- ASSIGNMENT QUERIES
-- ============================================

-- Get student's assignments with submission status
SELECT 
    a.id, a.title, a.description, a.due_date, a.total_marks,
    c.title as course_title,
    CASE 
        WHEN asub.id IS NULL THEN 'pending'
        ELSE asub.status
    END as submission_status,
    asub.marks_obtained, asub.grade, asub.submission_date,
    CASE 
        WHEN asub.id IS NULL AND a.due_date < NOW() THEN 'overdue'
        WHEN asub.id IS NULL THEN 'pending'
        ELSE 'submitted'
    END as overall_status
FROM assignments a
INNER JOIN courses c ON a.course_id = c.id
INNER JOIN enrollments e ON c.id = e.course_id
LEFT JOIN assignment_submissions asub ON a.id = asub.assignment_id AND asub.student_id = e.student_id
WHERE e.student_id = 5 AND e.status = 'active'
ORDER BY 
    CASE 
        WHEN asub.id IS NULL AND a.due_date < NOW() THEN 1
        WHEN asub.id IS NULL THEN 2
        ELSE 3
    END,
    a.due_date;

-- Get assignments pending grading for a teacher
SELECT 
    a.id, a.title, a.due_date,
    c.title as course_title,
    COUNT(asub.id) as total_submissions,
    COUNT(asub.id) FILTER (WHERE asub.status = 'submitted') as pending_grading,
    COUNT(asub.id) FILTER (WHERE asub.status = 'graded') as graded
FROM assignments a
INNER JOIN courses c ON a.course_id = c.id
LEFT JOIN assignment_submissions asub ON a.id = asub.assignment_id
WHERE c.instructor_id = 2
GROUP BY a.id, a.title, a.due_date, c.title
HAVING COUNT(asub.id) FILTER (WHERE asub.status = 'submitted') > 0
ORDER BY a.due_date;

-- ============================================
-- TEST/QUIZ QUERIES
-- ============================================

-- Get student's upcoming tests
SELECT 
    t.id, t.title, t.subject, t.test_type, t.scheduled_date,
    t.duration_minutes, t.total_marks,
    c.title as course_title,
    t.camera_required, t.screen_monitoring
FROM tests t
INNER JOIN courses c ON t.course_id = c.id
INNER JOIN enrollments e ON c.id = e.course_id
WHERE e.student_id = 5 
  AND t.status IN ('upcoming', 'ongoing')
  AND t.scheduled_date > NOW()
ORDER BY t.scheduled_date;

-- Get test results for a student
SELECT 
    t.id, t.title, t.subject, t.total_marks,
    c.title as course_title,
    ts.marks_obtained, ts.grade, ts.submit_time,
    ROUND((ts.marks_obtained / t.total_marks) * 100, 2) as percentage
FROM test_submissions ts
INNER JOIN tests t ON ts.test_id = t.id
INNER JOIN courses c ON t.course_id = c.id
WHERE ts.student_id = 5 AND ts.status = 'graded'
ORDER BY ts.submit_time DESC;

-- Get test with questions for taking the test
SELECT 
    t.id, t.title, t.instructions, t.duration_minutes, t.total_marks,
    json_agg(
        json_build_object(
            'id', q.id,
            'type', q.question_type,
            'question', q.question_text,
            'options', q.options,
            'marks', q.marks,
            'order', q.order_index
        ) ORDER BY q.order_index
    ) as questions
FROM tests t
INNER JOIN questions q ON t.id = q.test_id
WHERE t.id = 1
GROUP BY t.id, t.title, t.instructions, t.duration_minutes, t.total_marks;

-- ============================================
-- ATTENDANCE QUERIES
-- ============================================

-- Get student's attendance summary by course
SELECT 
    c.id as course_id,
    c.title as course_name,
    c.code as course_code,
    u.name as instructor,
    COUNT(ar.id) as total_classes,
    COUNT(ar.id) FILTER (WHERE ar.status = 'present') as present_count,
    COUNT(ar.id) FILTER (WHERE ar.status = 'absent') as absent_count,
    COUNT(ar.id) FILTER (WHERE ar.status = 'late') as late_count,
    ROUND(
        (COUNT(ar.id) FILTER (WHERE ar.status = 'present')::numeric / 
         NULLIF(COUNT(ar.id), 0) * 100), 2
    ) as attendance_percentage
FROM courses c
LEFT JOIN users u ON c.instructor_id = u.id
LEFT JOIN attendance_records ar ON c.id = ar.course_id AND ar.student_id = 5
WHERE c.id IN (
    SELECT course_id FROM enrollments WHERE student_id = 5 AND status = 'active'
)
GROUP BY c.id, c.title, c.code, u.name
ORDER BY c.title;

-- Get daily attendance for a course
SELECT 
    ar.date,
    u.name as student_name,
    sp.roll_number,
    ar.status,
    ar.notes
FROM attendance_records ar
INNER JOIN users u ON ar.student_id = u.id
INNER JOIN student_profiles sp ON u.id = sp.user_id
WHERE ar.course_id = 1
  AND ar.date = CURRENT_DATE
ORDER BY sp.roll_number;

-- Get attendance statistics for teacher's courses
SELECT 
    c.id, c.title,
    COUNT(DISTINCT e.student_id) as total_students,
    COUNT(ar.id) as total_records,
    ROUND(AVG(
        CASE WHEN ar.status = 'present' THEN 100 ELSE 0 END
    ), 2) as average_attendance_percentage
FROM courses c
LEFT JOIN enrollments e ON c.id = e.course_id AND e.status = 'active'
LEFT JOIN attendance_records ar ON c.id = ar.course_id
WHERE c.instructor_id = 2
GROUP BY c.id, c.title
ORDER BY c.title;

-- ============================================
-- ANALYTICS QUERIES
-- ============================================

-- Student performance dashboard
SELECT 
    u.name,
    COUNT(DISTINCT e.course_id) as enrolled_courses,
    ROUND(AVG(e.progress_percentage), 2) as avg_progress,
    ROUND(AVG(asub.marks_obtained / a.total_marks * 100), 2) as avg_assignment_score,
    ROUND(AVG(ts.marks_obtained / t.total_marks * 100), 2) as avg_test_score,
    ROUND(AVG(
        CASE WHEN ar.status = 'present' THEN 100 ELSE 0 END
    ), 2) as attendance_percentage
FROM users u
LEFT JOIN enrollments e ON u.id = e.student_id AND e.status = 'active'
LEFT JOIN assignment_submissions asub ON u.id = asub.student_id AND asub.status = 'graded'
LEFT JOIN assignments a ON asub.assignment_id = a.id
LEFT JOIN test_submissions ts ON u.id = ts.student_id AND ts.status = 'graded'
LEFT JOIN tests t ON ts.test_id = t.id
LEFT JOIN attendance_records ar ON u.id = ar.student_id
WHERE u.id = 5
GROUP BY u.id, u.name;

-- Teacher performance dashboard
SELECT 
    u.name,
    COUNT(DISTINCT c.id) as total_courses,
    COUNT(DISTINCT e.student_id) as total_students,
    ROUND(AVG(c.average_rating), 2) as avg_course_rating,
    ROUND(AVG(e.progress_percentage), 2) as avg_student_progress,
    SUM(c.revenue) as total_revenue
FROM users u
LEFT JOIN courses c ON u.id = c.instructor_id
LEFT JOIN enrollments e ON c.id = e.course_id AND e.status = 'active'
WHERE u.id = 2
GROUP BY u.id, u.name;

-- Platform-wide statistics
SELECT 
    COUNT(DISTINCT u.id) FILTER (WHERE u.role = 'student') as total_students,
    COUNT(DISTINCT u.id) FILTER (WHERE u.role = 'teacher') as total_teachers,
    COUNT(DISTINCT c.id) FILTER (WHERE c.status = 'active') as active_courses,
    COUNT(DISTINCT e.id) as total_enrollments,
    ROUND(AVG(c.average_rating), 2) as platform_avg_rating,
    SUM(c.revenue) as total_revenue
FROM users u
CROSS JOIN courses c
LEFT JOIN enrollments e ON c.id = e.course_id;

-- ============================================
-- LIBRARY QUERIES
-- ============================================

-- Search library items
SELECT 
    li.id, li.title, li.item_type, li.category, li.subject,
    li.description, li.file_url, li.thumbnail_url,
    li.average_rating, li.total_downloads,
    u.name as uploaded_by_name
FROM library_items li
LEFT JOIN users u ON li.uploaded_by = u.id
WHERE 
    li.title ILIKE '%calculus%' OR
    li.description ILIKE '%calculus%' OR
    'calculus' = ANY(li.tags)
ORDER BY li.average_rating DESC, li.total_downloads DESC
LIMIT 20;

-- Get student's favorite library items
SELECT 
    li.id, li.title, li.item_type, li.category,
    li.thumbnail_url, li.average_rating
FROM library_favorites lf
INNER JOIN library_items li ON lf.library_item_id = li.id
WHERE lf.user_id = 5
ORDER BY lf.created_at DESC;

-- ============================================
-- NOTIFICATION AND ANNOUNCEMENT QUERIES
-- ============================================

-- Get unread notifications for a user
SELECT 
    id, title, message, notification_type, 
    created_at
FROM notifications
WHERE user_id = 5 AND is_read = false
ORDER BY created_at DESC
LIMIT 10;

-- Get active announcements for a user
SELECT 
    a.id, a.title, a.content, a.priority, a.publish_date,
    u.name as created_by_name,
    CASE WHEN ar.id IS NOT NULL THEN true ELSE false END as is_read
FROM announcements a
INNER JOIN users u ON a.created_by = u.id
LEFT JOIN announcement_reads ar ON a.id = ar.announcement_id AND ar.user_id = 5
WHERE a.status = 'published'
  AND a.publish_date <= NOW()
  AND (a.expiry_date IS NULL OR a.expiry_date > NOW())
  AND (a.audience = 'all' OR a.audience = 'students')
ORDER BY a.priority DESC, a.publish_date DESC;

-- ============================================
-- CALENDAR/EVENT QUERIES
-- ============================================

-- Get upcoming events for a student
SELECT 
    e.id, e.title, e.event_type, e.description,
    e.event_date, e.start_time, e.end_time,
    c.title as course_title,
    u.name as instructor_name,
    e.zoom_link
FROM events e
LEFT JOIN courses c ON e.course_id = c.id
LEFT JOIN users u ON e.instructor_id = u.id
WHERE e.status = 'scheduled'
  AND e.event_date >= CURRENT_DATE
  AND (
    e.course_id IN (
        SELECT course_id FROM enrollments WHERE student_id = 5 AND status = 'active'
    ) OR e.course_id IS NULL
  )
ORDER BY e.event_date, e.start_time
LIMIT 10;
