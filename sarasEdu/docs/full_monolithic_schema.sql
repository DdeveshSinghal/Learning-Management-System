
-- SarasEduHub — Full monolithic schema + seed (VERBATIM)
-- This file is an exact concatenation of `docs/mysql_schema.sql` then `docs/sample_data_mysql.sql`.
-- Import with: mysql -u <user> -p < full_monolithic_schema.sql

/* BEGIN mysql_schema.sql */

-- SarasEduHub MySQL Schema (cleaned)
-- Run on MySQL 8.0+ (supports JSON fields and CHECK constraints)
-- This file is derived from database/schema.sql and adjusted for MySQL usage.
-- Recommended: run in a dev environment first, and apply migrations in sequence.

-- ============================================
-- USERS AND AUTHENTICATION
-- ============================================

CREATE TABLE users (
	id INT AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(255) NOT NULL,
	email VARCHAR(255) UNIQUE NOT NULL,
	password_hash VARCHAR(255) NOT NULL,
	role ENUM('student','teacher','admin') NOT NULL,
	status ENUM('active','inactive','suspended') DEFAULT 'active',
	avatar_url TEXT,
	bio TEXT,
	phone VARCHAR(20),
	join_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

	-- SarasEduHub — Full monolithic schema + seed (VERBATIM)
	-- This file is an exact concatenation of `docs/mysql_schema.sql` then `docs/sample_data_mysql.sql`.
	-- Import with: mysql -u <user> -p < full_monolithic_schema.sql

	/* BEGIN mysql_schema.sql */

	-- SarasEduHub MySQL Schema (cleaned)
	-- Run on MySQL 8.0+ (supports JSON fields and CHECK constraints)
	-- This file is derived from database/schema.sql and adjusted for MySQL usage.
	-- Recommended: run in a dev environment first, and apply migrations in sequence.

	-- ============================================
	-- USERS AND AUTHENTICATION
	-- ============================================

	CREATE TABLE users (
		id INT AUTO_INCREMENT PRIMARY KEY,
		name VARCHAR(255) NOT NULL,
		email VARCHAR(255) UNIQUE NOT NULL,
		password_hash VARCHAR(255) NOT NULL,
		role ENUM('student','teacher','admin') NOT NULL,
		status ENUM('active','inactive','suspended') DEFAULT 'active',
		avatar_url TEXT,
		bio TEXT,
		phone VARCHAR(20),
		join_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		last_login TIMESTAMP NULL,
		created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
	);

	CREATE TABLE student_profiles (
		id INT AUTO_INCREMENT PRIMARY KEY,
		user_id INT UNIQUE NOT NULL,
		roll_number VARCHAR(50) UNIQUE,
		grade_level VARCHAR(20),
		parent_contact VARCHAR(20),
		date_of_birth DATE,
		address TEXT,
		emergency_contact VARCHAR(255),
		average_grade DECIMAL(5,2) DEFAULT 0,
		created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
	);

	CREATE TABLE teacher_profiles (
		id INT AUTO_INCREMENT PRIMARY KEY,
		user_id INT UNIQUE NOT NULL,
		employee_id VARCHAR(50) UNIQUE,
		department VARCHAR(100),
		qualification VARCHAR(255),
		specialization VARCHAR(255),
		hire_date DATE,
		office_hours VARCHAR(255),
		average_rating DECIMAL(3,2) DEFAULT 0,
		created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
	);

	CREATE TABLE admin_profiles (
		id INT AUTO_INCREMENT PRIMARY KEY,
		user_id INT UNIQUE NOT NULL,
		employee_id VARCHAR(50) UNIQUE,
		position VARCHAR(100),
		access_level VARCHAR(50),
		department VARCHAR(100),
		created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
	);


	-- ============================================
	-- COURSES AND CURRICULUM
	-- ============================================

	CREATE TABLE courses (
		id INT AUTO_INCREMENT PRIMARY KEY,
		title VARCHAR(255) NOT NULL,
		subtitle VARCHAR(255),
		description TEXT,
		category VARCHAR(100),
		level ENUM('Beginner','Intermediate','Advanced'),
		language VARCHAR(50) DEFAULT 'English',
		duration_weeks INT,
		price DECIMAL(10,2) DEFAULT 0,
		thumbnail_url TEXT,
		instructor_id INT,
		status ENUM('draft','active','archived','inactive') DEFAULT 'draft',
		enrollment_type ENUM('open','closed','private','invite-only') DEFAULT 'open',
		prerequisites TEXT,
		learning_outcomes JSON,
		tags JSON,
		allow_discussions BOOLEAN DEFAULT TRUE,
		require_approval BOOLEAN DEFAULT FALSE,
		is_published BOOLEAN DEFAULT FALSE,
		total_lectures INT DEFAULT 0,
		average_rating DECIMAL(3,2) DEFAULT 0,
		total_enrollments INT DEFAULT 0,
		revenue DECIMAL(10,2) DEFAULT 0,
		access_level ENUM('basic','premium','pro') DEFAULT 'basic',
		created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
		start_date DATE,
		end_date DATE,
		FOREIGN KEY (instructor_id) REFERENCES users(id)
	);

	CREATE TABLE lectures (
		id INT AUTO_INCREMENT PRIMARY KEY,
		course_id INT NOT NULL,
		title VARCHAR(255) NOT NULL,
		description TEXT,
		video_url TEXT,
		video_file VARCHAR(255),
		duration_minutes INT,
		order_index INT NOT NULL,
		is_published BOOLEAN DEFAULT FALSE,
		is_free_preview BOOLEAN DEFAULT FALSE,
		content_text TEXT,
		created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
		FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
	);

	CREATE TABLE lecture_materials (
		id INT AUTO_INCREMENT PRIMARY KEY,
		lecture_id INT NOT NULL,
		name VARCHAR(255) NOT NULL,
		file_url TEXT NOT NULL,
		file_type VARCHAR(50),
		file_size_kb INT,
		created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		FOREIGN KEY (lecture_id) REFERENCES lectures(id) ON DELETE CASCADE
	);

	CREATE TABLE course_schedules (
		id INT AUTO_INCREMENT PRIMARY KEY,
		course_id INT NOT NULL,
		day_of_week VARCHAR(20) NOT NULL,
		start_time TIME NOT NULL,
		end_time TIME NOT NULL,
		session_type ENUM('Lecture','Lab Session','Tutorial','Discussion'),
		room_number VARCHAR(50),
		is_active BOOLEAN DEFAULT TRUE,
		created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
	);

	CREATE TABLE study_materials (
		id INT AUTO_INCREMENT PRIMARY KEY,
		course_id INT NOT NULL,
		title VARCHAR(255) NOT NULL,
		file_url TEXT NOT NULL,
		file_type VARCHAR(50),
		file_size_kb INT,
		category VARCHAR(100),
		description TEXT,
		uploaded_by INT,
		created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
		FOREIGN KEY (uploaded_by) REFERENCES users(id)
	);

	-- ============================================
	-- ENROLLMENTS AND PROGRESS
	-- ============================================

	CREATE TABLE enrollments (
		id INT AUTO_INCREMENT PRIMARY KEY,
		student_id INT NOT NULL,
		course_id INT NOT NULL,
		enrollment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		status ENUM('active','completed','dropped','suspended') DEFAULT 'active',
		progress_percentage DECIMAL(5,2) DEFAULT 0,
		last_accessed TIMESTAMP NULL,
		completion_date TIMESTAMP NULL,
		final_grade DECIMAL(5,2),
		certificate_issued BOOLEAN DEFAULT FALSE,
		UNIQUE(student_id, course_id),
		FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
		FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
	);

	CREATE TABLE lecture_progress (
		id INT AUTO_INCREMENT PRIMARY KEY,
		student_id INT NOT NULL,
		lecture_id INT NOT NULL,
		status ENUM('not_started','in_progress','completed') DEFAULT 'not_started',
		watch_time_minutes INT DEFAULT 0,
		completed_at TIMESTAMP NULL,
		last_position_seconds INT DEFAULT 0,
		UNIQUE(student_id, lecture_id),
		FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
		FOREIGN KEY (lecture_id) REFERENCES lectures(id) ON DELETE CASCADE
	);

	-- ============================================
	-- ASSIGNMENTS
	-- ============================================

	CREATE TABLE assignments (
		id INT AUTO_INCREMENT PRIMARY KEY,
		course_id INT NOT NULL,
		title VARCHAR(255) NOT NULL,
		description TEXT,
		instructions TEXT,
		due_date TIMESTAMP NOT NULL,
		total_marks DECIMAL(10,2) NOT NULL,
		word_limit INT,
		allowed_file_types JSON,
		status ENUM('active','archived','draft') DEFAULT 'active',
		created_by INT,
		created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
		FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
		FOREIGN KEY (created_by) REFERENCES users(id)
	);

	CREATE TABLE assignment_submissions (
		id INT AUTO_INCREMENT PRIMARY KEY,
		assignment_id INT NOT NULL,
		student_id INT NOT NULL,
		submission_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		submitted_file_url TEXT,
		submission_text TEXT,
		status ENUM('pending','submitted','graded','late','resubmitted') DEFAULT 'submitted',
		marks_obtained DECIMAL(10,2),
		grade VARCHAR(5),
		teacher_feedback TEXT,
		graded_by INT,
		graded_at TIMESTAMP NULL,
		UNIQUE(assignment_id, student_id),
		FOREIGN KEY (assignment_id) REFERENCES assignments(id) ON DELETE CASCADE,
		FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
		FOREIGN KEY (graded_by) REFERENCES users(id)
	);

	CREATE TABLE assignment_attachments (
		id INT AUTO_INCREMENT PRIMARY KEY,
		assignment_id INT NOT NULL,
		file_name VARCHAR(255) NOT NULL,
		file_url TEXT NOT NULL,
		file_size_kb INT,
		uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		FOREIGN KEY (assignment_id) REFERENCES assignments(id) ON DELETE CASCADE
	);

	-- ============================================
	-- TESTS AND QUIZZES
	-- ============================================

	CREATE TABLE tests (
		id INT AUTO_INCREMENT PRIMARY KEY,
		course_id INT NOT NULL,
		title VARCHAR(255) NOT NULL,
		subject VARCHAR(100),
		test_type VARCHAR(20),
		scheduled_date DATETIME NOT NULL,
		duration_minutes INT NOT NULL,
		total_marks DECIMAL(10,2) NOT NULL,
		instructions TEXT,
		status VARCHAR(20) DEFAULT 'upcoming',
		randomize_questions BOOLEAN DEFAULT FALSE,
		show_results_immediately BOOLEAN DEFAULT FALSE,
		created_by INT,
		created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
		FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
		FOREIGN KEY (created_by) REFERENCES users(id)
	);

	CREATE TABLE questions (
		id INT AUTO_INCREMENT PRIMARY KEY,
		test_id INT NOT NULL,
		question_type VARCHAR(20) NOT NULL,
		question_text TEXT NOT NULL,
		options JSON,
		correct_answer TEXT,
		marks DECIMAL(5,2) NOT NULL,
		order_index INT,
		explanation TEXT,
		created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		FOREIGN KEY (test_id) REFERENCES tests(id) ON DELETE CASCADE
	);

	CREATE TABLE test_submissions (
		id INT AUTO_INCREMENT PRIMARY KEY,
		test_id INT NOT NULL,
		student_id INT NOT NULL,
		start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		submit_time TIMESTAMP,
		status VARCHAR(20) DEFAULT 'in_progress',
		marks_obtained DECIMAL(10,2),
		grade VARCHAR(5),
		teacher_feedback TEXT,
		time_taken_minutes INT,
		UNIQUE (test_id, student_id),
		FOREIGN KEY (test_id) REFERENCES tests(id) ON DELETE CASCADE,
		FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE
	);

	CREATE TABLE test_answers (
		id INT AUTO_INCREMENT PRIMARY KEY,
		submission_id INT NOT NULL,
		question_id INT NOT NULL,
		student_answer TEXT,
		is_correct BOOLEAN,
		marks_awarded DECIMAL(5,2),
		marked BOOLEAN DEFAULT FALSE,
		marker_notes TEXT,
		UNIQUE (submission_id, question_id),
		FOREIGN KEY (submission_id) REFERENCES test_submissions(id) ON DELETE CASCADE,
		FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE
	);

	-- ============================================
	-- ATTENDANCE
	-- ============================================

	CREATE TABLE attendance_records (
		id INT AUTO_INCREMENT PRIMARY KEY,
		student_id INT NOT NULL,
		course_id INT NOT NULL,
		date DATE NOT NULL,
		status VARCHAR(20) NOT NULL,
		notes TEXT,
		marked_by INT,
		marked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		UNIQUE(student_id, course_id, date),
		FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
		FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
		FOREIGN KEY (marked_by) REFERENCES users(id)
	);

	-- ============================================
	-- LIBRARY SYSTEM
	-- ============================================

	CREATE TABLE library_items (
		id INT AUTO_INCREMENT PRIMARY KEY,
		title VARCHAR(255) NOT NULL,
		item_type VARCHAR(50),
		category VARCHAR(100),
		course_id INT,
		subject VARCHAR(100),
		description TEXT,
		file_url TEXT,
		thumbnail_url TEXT,
		file_size_kb INT,
		duration_minutes INT,
		pages INT,
		uploaded_by INT,
		upload_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		total_downloads INT DEFAULT 0,
		average_rating DECIMAL(3,2) DEFAULT 0,
		tags JSON,
		is_featured BOOLEAN DEFAULT FALSE,
		access_level VARCHAR(20) DEFAULT 'all',
		created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		FOREIGN KEY (course_id) REFERENCES courses(id),
		FOREIGN KEY (uploaded_by) REFERENCES users(id)
	);

	CREATE TABLE library_favorites (
		id INT AUTO_INCREMENT PRIMARY KEY,
		user_id INT NOT NULL,
		library_item_id INT NOT NULL,
		created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		UNIQUE(user_id, library_item_id),
		FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
		FOREIGN KEY (library_item_id) REFERENCES library_items(id) ON DELETE CASCADE
	);

	CREATE TABLE library_downloads (
		id INT AUTO_INCREMENT PRIMARY KEY,
		user_id INT NOT NULL,
		library_item_id INT NOT NULL,
		download_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
		FOREIGN KEY (library_item_id) REFERENCES library_items(id) ON DELETE CASCADE
	);

	-- ============================================
	-- EVENTS AND CALENDAR
	-- ============================================

	CREATE TABLE events (
		id INT AUTO_INCREMENT PRIMARY KEY,
		title VARCHAR(255) NOT NULL,
		event_type VARCHAR(50),
		description TEXT,
		event_date DATE NOT NULL,
		start_time TIME NOT NULL,
		end_time TIME,
		duration_minutes INT,
		course_id INT,
		instructor_id INT,
		meeting_link TEXT,
		zoom_link TEXT,
		location VARCHAR(255),
		status VARCHAR(20) DEFAULT 'scheduled',
		max_attendees INT,
		is_recurring BOOLEAN DEFAULT FALSE,
		recurrence_pattern VARCHAR(50),
		created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
		FOREIGN KEY (course_id) REFERENCES courses(id),
		FOREIGN KEY (instructor_id) REFERENCES users(id)
	);

	CREATE TABLE event_attendees (
		id INT AUTO_INCREMENT PRIMARY KEY,
		event_id INT NOT NULL,
		user_id INT NOT NULL,
		rsvp_status VARCHAR(20) DEFAULT 'pending',
		attendance_status VARCHAR(20),
		joined_at TIMESTAMP,
		left_at TIMESTAMP,
		UNIQUE (event_id, user_id),
		FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE,
		FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
	);

	-- ============================================
	-- ANNOUNCEMENTS
	-- ============================================

	CREATE TABLE announcements (
		id INT AUTO_INCREMENT PRIMARY KEY,
		title VARCHAR(255) NOT NULL,
		content TEXT NOT NULL,
		audience VARCHAR(20),
		course_id INT,
		priority VARCHAR(20) DEFAULT 'normal',
		status VARCHAR(20) DEFAULT 'draft',
		created_by INT,
		publish_date TIMESTAMP,
		expiry_date TIMESTAMP,
		created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
		FOREIGN KEY (course_id) REFERENCES courses(id),
		FOREIGN KEY (created_by) REFERENCES users(id)
	);

	CREATE TABLE announcement_reads (
		id INT AUTO_INCREMENT PRIMARY KEY,
		announcement_id INT NOT NULL,
		user_id INT NOT NULL,
		read_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		UNIQUE(announcement_id, user_id),
		FOREIGN KEY (announcement_id) REFERENCES announcements(id) ON DELETE CASCADE,
		FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
	);

	-- ============================================
	-- NOTIFICATIONS
	-- ============================================

	CREATE TABLE notifications (
		id INT AUTO_INCREMENT PRIMARY KEY,
		user_id INT NOT NULL,
		title VARCHAR(255) NOT NULL,
		message TEXT NOT NULL,
		notification_type VARCHAR(50) NOT NULL,
		related_entity_type VARCHAR(50),
		related_entity_id INT,
		is_read BOOLEAN DEFAULT FALSE,
		created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
	);

	-- ============================================
	-- REVIEWS AND RATINGS
	-- ============================================

	CREATE TABLE course_reviews (
		id INT AUTO_INCREMENT PRIMARY KEY,
		course_id INT NOT NULL,
		student_id INT NOT NULL,
		rating INT NOT NULL,
		review_text TEXT,
		created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
		UNIQUE(course_id, student_id),
		FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
		FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE
	);

	CREATE TABLE teacher_ratings (
		id INT AUTO_INCREMENT PRIMARY KEY,
		teacher_id INT NOT NULL,
		student_id INT NOT NULL,
		course_id INT,
		rating INT NOT NULL,
		feedback TEXT,
		created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		UNIQUE(teacher_id, student_id, course_id),
		FOREIGN KEY (teacher_id) REFERENCES users(id) ON DELETE CASCADE,
		FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
		FOREIGN KEY (course_id) REFERENCES courses(id)
	);

	-- ============================================
	-- DISCUSSIONS, AI TUTOR, ANALYTICS
	-- ============================================

	CREATE TABLE discussion_threads (
		id INT AUTO_INCREMENT PRIMARY KEY,
		course_id INT NOT NULL,
		lecture_id INT,
		title VARCHAR(255) NOT NULL,
		created_by INT NOT NULL,
		is_pinned BOOLEAN DEFAULT FALSE,
		is_locked BOOLEAN DEFAULT FALSE,
		view_count INT DEFAULT 0,
		created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
		FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
		FOREIGN KEY (lecture_id) REFERENCES lectures(id),
		FOREIGN KEY (created_by) REFERENCES users(id)
	);

	CREATE TABLE discussion_posts (
		id INT AUTO_INCREMENT PRIMARY KEY,
		thread_id INT NOT NULL,
		user_id INT NOT NULL,
		content TEXT NOT NULL,
		parent_post_id INT,
		is_answer BOOLEAN DEFAULT FALSE,
		upvotes INT DEFAULT 0,
		created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
		FOREIGN KEY (thread_id) REFERENCES discussion_threads(id) ON DELETE CASCADE,
		FOREIGN KEY (user_id) REFERENCES users(id),
		FOREIGN KEY (parent_post_id) REFERENCES discussion_posts(id)
	);

	CREATE TABLE ai_tutor_conversations (
		id INT AUTO_INCREMENT PRIMARY KEY,
		student_id INT NOT NULL,
		course_id INT,
		title VARCHAR(255),
		created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
		FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
		FOREIGN KEY (course_id) REFERENCES courses(id)
	);

	CREATE TABLE ai_tutor_messages (
		id INT AUTO_INCREMENT PRIMARY KEY,
		conversation_id INT NOT NULL,
		message_type VARCHAR(20),
		content TEXT NOT NULL,
		created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		FOREIGN KEY (conversation_id) REFERENCES ai_tutor_conversations(id) ON DELETE CASCADE
	);

	CREATE TABLE user_activity_logs (
		id INT AUTO_INCREMENT PRIMARY KEY,
		user_id INT NOT NULL,
		activity_type VARCHAR(100) NOT NULL,
		entity_type VARCHAR(50),
		entity_id INT,
		details JSON,
		ip_address VARCHAR(45),
		user_agent TEXT,
		created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
	);

	CREATE TABLE daily_reports (
		id INT AUTO_INCREMENT PRIMARY KEY,
		report_date DATE NOT NULL UNIQUE,
		total_active_users INT DEFAULT 0,
		total_enrollments INT DEFAULT 0,
		total_assignments_submitted INT DEFAULT 0,
		total_tests_completed INT DEFAULT 0,
		platform_revenue DECIMAL(10,2) DEFAULT 0,
		avg_attendance_percentage DECIMAL(5,2),
		created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
	);

	-- Indexes
	CREATE INDEX idx_users_email ON users(email);
	CREATE INDEX idx_users_role ON users(role);
	CREATE INDEX idx_users_status ON users(status);
	CREATE INDEX idx_courses_instructor ON courses(instructor_id);
	CREATE INDEX idx_courses_status ON courses(status);
	CREATE INDEX idx_courses_category ON courses(category);
	CREATE INDEX idx_enrollments_student ON enrollments(student_id);
	CREATE INDEX idx_enrollments_course ON enrollments(course_id);
	CREATE INDEX idx_enrollments_status ON enrollments(status);
	CREATE INDEX idx_lectures_course ON lectures(course_id);
	CREATE INDEX idx_lecture_progress_student ON lecture_progress(student_id);
	CREATE INDEX idx_assignments_course ON assignments(course_id);
	CREATE INDEX idx_assignment_submissions_student ON assignment_submissions(student_id);
	CREATE INDEX idx_assignment_submissions_assignment ON assignment_submissions(assignment_id);
	CREATE INDEX idx_tests_course ON tests(course_id);
	CREATE INDEX idx_test_submissions_student ON test_submissions(student_id);
	CREATE INDEX idx_test_submissions_test ON test_submissions(test_id);
	CREATE INDEX idx_attendance_student ON attendance_records(student_id);
	CREATE INDEX idx_attendance_course ON attendance_records(course_id);
	CREATE INDEX idx_attendance_date ON attendance_records(date);
	CREATE INDEX idx_events_date ON events(event_date);
	CREATE INDEX idx_events_course ON events(course_id);
	CREATE INDEX idx_notifications_user ON notifications(user_id);
	CREATE INDEX idx_notifications_read ON notifications(is_read);
	CREATE INDEX idx_library_items_type ON library_items(item_type);
	CREATE INDEX idx_library_items_category ON library_items(category);

	-- Triggers: recommend creating via migration scripts or running separately in your DB client
	-- Example trigger (create using DELIMITER in MySQL client):
	-- DELIMITER $$
	-- CREATE TRIGGER update_users_updated_at
	-- BEFORE UPDATE ON users
	-- FOR EACH ROW
	-- BEGIN
	--   SET NEW.updated_at = CURRENT_TIMESTAMP;
	-- END$$
	-- DELIMITER ;

	-- End of schema

	/* END mysql_schema.sql */

	/* BEGIN sample_data_mysql.sql */

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
	('Introduction to Organic Chemistry', 'Video', 'Tutorial', 'Chemistry', 'Video lecture series on organic chemistry fundamentals', 4, 450000, NULL, 4.8, 412);

	-- Events
	INSERT INTO events (title, event_type, description, event_date, start_time, end_time, duration_minutes, course_id, instructor_id, status) VALUES
	('Advanced Mathematics - Live Class', 'live-class', 'Weekly live session for Q&A and problem solving', DATE_ADD(CURRENT_DATE, INTERVAL 1 DAY), '14:00:00', '15:30:00', 90, 1, 2, 'scheduled'),
	('Physics Mid-term Review', 'workshop', 'Comprehensive review session before mid-term exam', DATE_ADD(CURRENT_DATE, INTERVAL 3 DAY), '10:00:00', '12:00:00', 120, 2, 3, 'scheduled');

	-- End of sample data. 
	-- NOTE: The original file contains additional samples and some Postgres-specific SQL. Convert remaining sections similarly: replace INTERVAL 'N days' with DATE_ADD/DATE_SUB, replace json_build_object/json_agg with JSON_OBJECT/JSON_ARRAYAGG or return normalized rows.

	/* END sample_data_mysql.sql */

	-- End of monolithic file

