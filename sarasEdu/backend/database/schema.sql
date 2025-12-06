-- SarasEduHub LMS Database Schema (MySQL)
-- Complete database schema for the Learning Management System

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
    allowed_file_types JSON,   -- Converted from TEXT[] to JSON
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
    test_type VARCHAR(20) CHECK (test_type IN ('test', 'quiz', 'midterm', 'final')),
    scheduled_date DATETIME NOT NULL,
    duration_minutes INT NOT NULL,
    total_marks DECIMAL(10,2) NOT NULL,
    instructions TEXT,
    status VARCHAR(20) DEFAULT 'upcoming' CHECK (status IN ('draft', 'upcoming', 'ongoing', 'completed', 'archived')),
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
    question_type VARCHAR(20) NOT NULL CHECK (question_type IN ('mcq', 'descriptive', 'true-false', 'multiple-answer')),
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
    status VARCHAR(20) DEFAULT 'in_progress' CHECK (status IN ('in_progress', 'submitted', 'graded', 'abandoned')),
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
    status VARCHAR(20) NOT NULL CHECK (status IN ('present', 'absent', 'late', 'excused')),
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
    item_type VARCHAR(50) CHECK (item_type IN ('Book', 'Video', 'Document', 'Audio', 'Article', 'Research Paper')),
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
    access_level VARCHAR(20) DEFAULT 'all' CHECK (access_level IN ('all', 'students', 'teachers', 'premium')),
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
    event_type VARCHAR(50) CHECK (event_type IN 
        ('live-class', 'quiz', 'test', 'assignment', 'meeting', 'workshop', 'webinar', 'deadline')
    ),
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
    status VARCHAR(20) DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'ongoing', 'completed', 'cancelled')),
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
    rsvp_status VARCHAR(20) DEFAULT 'pending' CHECK (rsvp_status IN ('pending','accepted','declined','maybe')),
    attendance_status VARCHAR(20) CHECK (attendance_status IN ('present','absent','late')),
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
    audience VARCHAR(20) CHECK (audience IN ('all','students','teachers','admins','specific-course')),
    course_id INT,
    priority VARCHAR(20) DEFAULT 'normal' CHECK (priority IN ('low','normal','high','urgent')),
    status VARCHAR(20) DEFAULT 'draft' CHECK (status IN ('draft','published','archived')),
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
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
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
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    feedback TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(teacher_id, student_id, course_id),
    FOREIGN KEY (teacher_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(id)
);


-- ============================================
-- DISCUSSIONS AND CHAT
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
    message_type VARCHAR(20) CHECK (message_type IN ('user','assistant')),
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (conversation_id) REFERENCES ai_tutor_conversations(id) ON DELETE CASCADE
);


-- ============================================
-- ANALYTICS AND REPORTING
-- ============================================

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


-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================

-- ============================================
-- INDEXES FOR PERFORMANCE (MySQL 8+)
-- ============================================

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


-- ============================================
-- TRIGGERS FOR AUTO-UPDATE
-- ============================================

-- Auto-update updated_at timestamp
DELIMITER $$

CREATE TRIGGER trigger_name
BEFORE UPDATE ON table_name
FOR EACH ROW
BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

DELIMITER ;


DELIMITER $$

CREATE TRIGGER update_users_updated_at
BEFORE UPDATE ON users
FOR EACH ROW
BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

DELIMITER ;


DELIMITER $$

CREATE TRIGGER update_courses_updated_at
BEFORE UPDATE ON courses
FOR EACH ROW
BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

DELIMITER ;


DELIMITER $$

CREATE TRIGGER update_lectures_updated_at
BEFORE UPDATE ON lectures
FOR EACH ROW
BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

DELIMITER ;


DELIMITER $$

CREATE TRIGGER update_assignments_updated_at
BEFORE UPDATE ON assignments
FOR EACH ROW
BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

DELIMITER ;


DELIMITER $$

CREATE TRIGGER update_tests_updated_at
BEFORE UPDATE ON tests
FOR EACH ROW
BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

DELIMITER ;


DELIMITER $$

CREATE TRIGGER update_events_updated_at
BEFORE UPDATE ON events
FOR EACH ROW
BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

DELIMITER ;


DELIMITER $$

CREATE TRIGGER update_announcements_updated_at
BEFORE UPDATE ON announcements
FOR EACH ROW
BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

DELIMITER ;

