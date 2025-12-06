-- Sample data for SarasEduHub (MySQL-ready)
-- NOTE: this file contains a subset of the original sample_data.sql converted to MySQL syntax.
-- Use this as seed data; adjust IDs if you import into existing DB.

-- Admin user
INSERT INTO users (name, email, password_hash, role, phone, bio) VALUES
('Admin User', 'admin@sarasedu.com', '$2b$10$abcdefghijklmnopqrstuvwxyz1234567890', 'admin', '+1234567890', 'System Administrator');

INSERT INTO admin_profiles (user_id, employee_id, position, access_level, department) VALUES
(LAST_INSERT_ID(), 'EMP001', 'Platform Administrator', 'full', 'IT');

-- Teachers
INSERT INTO users (name, email, password_hash, role, phone, bio) VALUES
('Dr. Sarah Johnson', 'sarah.johnson@sarasedu.com', '$2b$10$abcdefghijklmnopqrstuvwxyz1234567890', 'teacher', '+1234567891', 'Mathematics Professor with 15 years experience'),
('Prof. Michael Chen', 'michael.chen@sarasedu.com', '$2b$10$abcdefghijklmnopqrstuvwxyz1234567890', 'teacher', '+1234567892', 'Physics Expert and Researcher'),
('Dr. Emily Davis', 'emily.davis@sarasedu.com', '$2b$10$abcdefghijklmnopqrstuvwxyz1234567890', 'teacher', '+1234567893', 'Chemistry Specialist');

-- Assume inserted ids are sequential; adjust if necessary in your environment.
-- Teacher profiles (example ids 2,3,4)
INSERT INTO teacher_profiles (user_id, employee_id, department, qualification, specialization, hire_date, average_rating) VALUES
(2, 'TEACH001', 'Mathematics', 'PhD in Mathematics', 'Calculus and Linear Algebra', '2020-01-15', 4.8),
(3, 'TEACH002', 'Physics', 'PhD in Physics', 'Quantum Mechanics', '2019-06-01', 4.6),
(4, 'TEACH003', 'Chemistry', 'PhD in Chemistry', 'Organic Chemistry', '2021-03-10', 4.7);

-- Students
INSERT INTO users (name, email, password_hash, role, phone) VALUES
('John Doe', 'john.doe@student.com', '$2b$10$abcdefghijklmnopqrstuvwxyz1234567890', 'student', '+1234567894'),
('Jane Smith', 'jane.smith@student.com', '$2b$10$abcdefghijklmnopqrstuvwxyz1234567890', 'student', '+1234567895'),
('Mike Johnson', 'mike.johnson@student.com', '$2b$10$abcdefghijklmnopqrstuvwxyz1234567890', 'student', '+1234567896'),
('Emma Wilson', 'emma.wilson@student.com', '$2b$10$abcdefghijklmnopqrstuvwxyz1234567890', 'student', '+1234567897'),
('David Brown', 'david.brown@student.com', '$2b$10$abcdefghijklmnopqrstuvwxyz1234567890', 'student', '+1234567898');

INSERT INTO student_profiles (user_id, roll_number, grade_level, average_grade) VALUES
(5, 'CS001', '12', 87.5),
(6, 'CS002', '12', 92.0),
(7, 'CS003', '11', 78.5),
(8, 'CS004', '12', 88.0),
(9, 'CS005', '11', 85.5);

-- Courses (instructor_id values should match inserted teacher user IDs)
INSERT INTO courses (
    title, subtitle, description, category, level, language, 
    duration_weeks, price, instructor_id, status, is_published,
    total_lectures, average_rating, total_enrollments
) VALUES
(
    'Advanced Mathematics',
    'Master calculus, linear algebra, and differential equations',
    'This comprehensive course covers advanced mathematical concepts including differential calculus, integral calculus, linear algebra, and differential equations. Perfect for students pursuing STEM fields.',
    'Mathematics',
    'Advanced',
    'English',
    16,
    299.00,
    2,
    'active',
    true,
    24,
    4.8,
    124
),
(
    'Physics Fundamentals',
    'Explore the laws of physics from mechanics to electromagnetism',
    'Comprehensive introduction to physics covering mechanics, thermodynamics, waves, and electromagnetism with practical experiments.',
    'Physics',
    'Intermediate',
    'English',
    14,
    249.00,
    3,
    'active',
    true,
    20,
    4.6,
    89
),
(
    'Chemistry Basics',
    'Understanding atomic structure and chemical reactions',
    'Learn fundamental chemistry concepts including atomic theory, periodic table, chemical bonding, and reactions.',
    'Chemistry',
    'Beginner',
    'English',
    12,
    199.00,
    4,
    'active',
    true,
    18,
    4.7,
    67
);

-- Lectures (example)
INSERT INTO lectures (course_id, title, description, duration_minutes, order_index, is_published) VALUES
(1, 'Introduction to Calculus', 'Learn the fundamental concepts of differential calculus', 45, 1, true),
(1, 'Limits and Continuity', 'Understanding limits, continuity, and their applications', 42, 2, true),
(1, 'Derivatives', 'Master the concept of derivatives and differentiation rules', 50, 3, true),
(1, 'Integration Basics', 'Introduction to integral calculus', 48, 4, true),
(2, 'Introduction to Physics', 'Overview of physics and scientific method', 40, 1, true),
(2, 'Kinematics', 'Study of motion without considering forces', 45, 2, true),
(2, 'Newton''s Laws', 'Understanding the fundamental laws of motion', 50, 3, true),
(3, 'Atomic Structure', 'Understanding atoms, electrons, and the periodic table', 38, 1, true),
(3, 'Chemical Bonding', 'Learn about ionic, covalent, and metallic bonds', 42, 2, true);

-- Enrollments
INSERT INTO enrollments (student_id, course_id, progress_percentage, final_grade, status) VALUES
(5, 1, 75.0, 87.5, 'active'),
(5, 2, 60.0, NULL, 'active'),
(6, 1, 85.0, 92.0, 'active'),
(6, 2, 70.0, NULL, 'active'),
(7, 1, 45.0, NULL, 'active'),
(8, 2, 55.0, NULL, 'active'),
(9, 3, 80.0, 88.0, 'active');

-- Lecture progress example (use DATE_SUB for MySQL)
INSERT INTO lecture_progress (student_id, lecture_id, status, watch_time_minutes, completed_at) VALUES
(5, 1, 'completed', 45, DATE_SUB(NOW(), INTERVAL 10 DAY)),
(5, 2, 'completed', 42, DATE_SUB(NOW(), INTERVAL 8 DAY)),
(5, 3, 'in_progress', 25, NULL),
(6, 1, 'completed', 45, DATE_SUB(NOW(), INTERVAL 9 DAY)),
(6, 2, 'completed', 42, DATE_SUB(NOW(), INTERVAL 7 DAY)),
(6, 3, 'completed', 50, DATE_SUB(NOW(), INTERVAL 5 DAY));

-- Course schedules
INSERT INTO course_schedules (course_id, day_of_week, start_time, end_time, session_type, room_number) VALUES
(1, 'Monday', '10:00:00', '11:30:00', 'Lecture', 'Room 301'),
(1, 'Wednesday', '10:00:00', '11:30:00', 'Lecture', 'Room 301'),
(1, 'Friday', '14:00:00', '15:30:00', 'Lab Session', 'Lab 205'),
(2, 'Tuesday', '09:00:00', '10:30:00', 'Lecture', 'Room 204'),
(2, 'Thursday', '09:00:00', '10:30:00', 'Lecture', 'Room 204'),
(3, 'Monday', '13:00:00', '14:30:00', 'Lecture', 'Room 105'),
(3, 'Wednesday', '13:00:00', '14:30:00', 'Lab Session', 'Lab 102');

-- Assignments (convert INTERVAL syntax to DATE_ADD)
INSERT INTO assignments (course_id, title, description, instructions, due_date, total_marks, created_by) VALUES
(1, 'Calculus Problem Set 1', 'Solve differential calculus problems covering limits and derivatives', 'Complete all 10 problems. Show all working. Submit as PDF.', DATE_ADD(NOW(), INTERVAL 7 DAY), 50.00, 2),
(1, 'Integration Assignment', 'Integration problems and applications', 'Solve the given integration problems and provide step-by-step solutions.', DATE_ADD(NOW(), INTERVAL 14 DAY), 40.00, 2),
(2, 'Kinematics Lab Report', 'Write a lab report on motion experiments', 'Include methodology, observations, calculations, and conclusions.', DATE_ADD(NOW(), INTERVAL 10 DAY), 30.00, 3);

-- Assignment submissions (converted graded_at uses DATE_SUB)
INSERT INTO assignment_submissions (assignment_id, student_id, submission_text, status, marks_obtained, grade, teacher_feedback, graded_by, graded_at) VALUES
(1, 5, 'All problems solved with detailed explanations...', 'graded', 45.00, 'A', 'Excellent work! Very clear explanations.', 2, DATE_SUB(NOW(), INTERVAL 2 DAY)),
(1, 6, 'Complete solutions to all problems...', 'graded', 48.00, 'A+', 'Outstanding! Perfect solutions.', 2, DATE_SUB(NOW(), INTERVAL 2 DAY));

-- Tests
INSERT INTO tests (course_id, title, subject, test_type, scheduled_date, duration_minutes, total_marks, instructions, status, created_by) VALUES
(1, 'Calculus Mid-term Examination', 'Mathematics', 'midterm', DATE_ADD(NOW(), INTERVAL 5 DAY), 120, 100.00, 'This is a comprehensive test on calculus. Calculator allowed. Show all working.', 'upcoming', 2),
(2, 'Physics Quiz - Week 4', 'Physics', 'quiz', DATE_ADD(NOW(), INTERVAL 3 DAY), 30, 20.00, 'Quick quiz on kinematics. No calculators allowed.', 'upcoming', 3);

-- Questions (options as JSON)
INSERT INTO questions (test_id, question_type, question_text, options, correct_answer, marks, order_index) VALUES
(1, 'mcq', 'What is the derivative of x²?', JSON_ARRAY('2x','x²','2','x'), '2x', 5.00, 1),
(1, 'descriptive', 'Solve the integral ∫x²dx and explain your steps.', NULL, 'x³/3 + C', 10.00, 2),
(1, 'true-false', 'The derivative of a constant is zero.', JSON_ARRAY('True','False'), 'True', 3.00, 3),
(2, 'mcq', 'What is the SI unit of velocity?', JSON_ARRAY('m/s','m/s²','km/h','mph'), 'm/s', 4.00, 1);

-- Attendance records (DATE_SUB)
INSERT INTO attendance_records (student_id, course_id, date, status, marked_by) VALUES
(5, 1, DATE_SUB(CURRENT_DATE, INTERVAL 5 DAY), 'present', 2),
(5, 1, DATE_SUB(CURRENT_DATE, INTERVAL 4 DAY), 'present', 2),
(5, 1, DATE_SUB(CURRENT_DATE, INTERVAL 3 DAY), 'late', 2),
(5, 1, DATE_SUB(CURRENT_DATE, INTERVAL 2 DAY), 'present', 2),
(5, 1, DATE_SUB(CURRENT_DATE, INTERVAL 1 DAY), 'absent', 2),
(6, 1, DATE_SUB(CURRENT_DATE, INTERVAL 5 DAY), 'present', 2),
(6, 1, DATE_SUB(CURRENT_DATE, INTERVAL 4 DAY), 'present', 2),
(6, 1, DATE_SUB(CURRENT_DATE, INTERVAL 3 DAY), 'present', 2),
(6, 1, DATE_SUB(CURRENT_DATE, INTERVAL 2 DAY), 'present', 2),
(6, 1, DATE_SUB(CURRENT_DATE, INTERVAL 1 DAY), 'present', 2);

-- Library items (example)
INSERT INTO library_items (title, item_type, category, subject, description, uploaded_by, file_size_kb, pages, average_rating, total_downloads) VALUES
('Calculus Reference Guide', 'Document', 'Reference', 'Mathematics', 'Comprehensive reference for calculus formulas and theorems', 2, 2500, 150, 4.7, 234),
('Physics Experiments Handbook', 'Book', 'Laboratory', 'Physics', 'Step-by-step guide for physics laboratory experiments', 3, 5800, 320, 4.5, 189),
('Introduction to Organic Chemistry', 'Video', 'Tutorial', 'Chemistry', 4, 450000, NULL, 4.8, 412);

-- Events
INSERT INTO events (title, event_type, description, event_date, start_time, end_time, duration_minutes, course_id, instructor_id, status) VALUES
('Advanced Mathematics - Live Class', 'live-class', 'Weekly live session for Q&A and problem solving', DATE_ADD(CURRENT_DATE, INTERVAL 1 DAY), '14:00:00', '15:30:00', 90, 1, 2, 'scheduled'),
('Physics Mid-term Review', 'workshop', 'Comprehensive review session before mid-term exam', DATE_ADD(CURRENT_DATE, INTERVAL 3 DAY), '10:00:00', '12:00:00', 120, 2, 3, 'scheduled');

-- End of sample data. 
-- NOTE: The original file contains additional samples and some Postgres-specific SQL. Convert remaining sections similarly: replace INTERVAL 'N days' with DATE_ADD/DATE_SUB, replace json_build_object/json_agg with JSON_OBJECT/JSON_ARRAYAGG or return normalized rows.
