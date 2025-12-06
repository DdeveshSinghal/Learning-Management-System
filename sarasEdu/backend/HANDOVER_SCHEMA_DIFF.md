# Schema Diff Report

## Model: admin.LogEntry -> table `django_admin_log`

- model fields (8): ['id', 'action_time', 'user', 'content_type', 'object_id', 'object_repr', 'action_flag', 'change_message']

- db columns (8): ['id', 'action_time', 'object_id', 'object_repr', 'action_flag', 'change_message', 'content_type_id', 'user_id']

- missing in db (in model not in db): ['user', 'content_type']

- extra in db (in db not in model): ['content_type_id', 'user_id']

- type mismatches: [('id', 'integer AUTO_INCREMENT', 'int')]


---

## Model: auth.Permission -> table `auth_permission`

- model fields (4): ['id', 'name', 'content_type', 'codename']

- db columns (4): ['id', 'name', 'content_type_id', 'codename']

- missing in db (in model not in db): ['content_type']

- extra in db (in db not in model): ['content_type_id']

- type mismatches: [('id', 'integer AUTO_INCREMENT', 'int')]


---

## Model: auth.Group -> table `auth_group`

- model fields (2): ['id', 'name']

- db columns (2): ['id', 'name']

- missing in db (in model not in db): []

- extra in db (in db not in model): []

- type mismatches: [('id', 'integer AUTO_INCREMENT', 'int')]


---

## Model: contenttypes.ContentType -> table `django_content_type`

- model fields (3): ['id', 'app_label', 'model']

- db columns (3): ['id', 'app_label', 'model']

- missing in db (in model not in db): []

- extra in db (in db not in model): []

- type mismatches: [('id', 'integer AUTO_INCREMENT', 'int')]


---

## Model: sessions.Session -> table `django_session`

- model fields (3): ['session_key', 'session_data', 'expire_date']

- db columns (3): ['session_key', 'session_data', 'expire_date']

- missing in db (in model not in db): []

- extra in db (in db not in model): []

- type mismatches: []


---

## Model: core.User -> table `core_user`

- model fields (15): ['id', 'password', 'last_login', 'is_superuser', 'username', 'first_name', 'last_name', 'email', 'is_staff', 'is_active', 'date_joined', 'role', 'avatar_url', 'bio', 'phone']

- db columns (15): ['id', 'password', 'last_login', 'is_superuser', 'username', 'first_name', 'last_name', 'email', 'is_staff', 'is_active', 'date_joined', 'role', 'avatar_url', 'bio', 'phone']

- missing in db (in model not in db): []

- extra in db (in db not in model): []

- type mismatches: [('id', 'bigint AUTO_INCREMENT', 'bigint'), ('is_superuser', 'bool', 'tinyint(1)'), ('is_staff', 'bool', 'tinyint(1)'), ('is_active', 'bool', 'tinyint(1)')]


---

## Model: core.StudentProfile -> table `core_studentprofile`

- model fields (10): ['id', 'user', 'roll_number', 'grade_level', 'parent_contact', 'date_of_birth', 'address', 'emergency_contact', 'average_grade', 'created_at']

- db columns (10): ['id', 'roll_number', 'grade_level', 'parent_contact', 'date_of_birth', 'address', 'emergency_contact', 'average_grade', 'created_at', 'user_id']

- missing in db (in model not in db): ['user']

- extra in db (in db not in model): ['user_id']

- type mismatches: [('id', 'bigint AUTO_INCREMENT', 'bigint'), ('average_grade', 'numeric(5, 2)', 'decimal(5,2)')]


---

## Model: core.TeacherProfile -> table `core_teacherprofile`

- model fields (10): ['id', 'user', 'employee_id', 'department', 'qualification', 'specialization', 'hire_date', 'office_hours', 'average_rating', 'created_at']

- db columns (10): ['id', 'employee_id', 'department', 'qualification', 'specialization', 'hire_date', 'office_hours', 'average_rating', 'created_at', 'user_id']

- missing in db (in model not in db): ['user']

- extra in db (in db not in model): ['user_id']

- type mismatches: [('id', 'bigint AUTO_INCREMENT', 'bigint'), ('average_rating', 'numeric(3, 2)', 'decimal(3,2)')]


---

## Model: core.AdminProfile -> table `core_adminprofile`

- model fields (7): ['id', 'user', 'employee_id', 'position', 'access_level', 'department', 'created_at']

- db columns (7): ['id', 'employee_id', 'position', 'access_level', 'department', 'created_at', 'user_id']

- missing in db (in model not in db): ['user']

- extra in db (in db not in model): ['user_id']

- type mismatches: [('id', 'bigint AUTO_INCREMENT', 'bigint')]


---

## Model: core.Course -> table `core_course`

- model fields (28): ['id', 'title', 'subtitle', 'description', 'category', 'level', 'language', 'duration_weeks', 'price', 'thumbnail_url', 'instructor', 'status', 'enrollment_type', 'prerequisites', 'learning_outcomes', 'tags', 'allow_discussions', 'require_approval', 'is_published', 'total_lectures', 'average_rating', 'total_enrollments', 'revenue', 'access_level', 'created_at', 'updated_at', 'start_date', 'end_date']

- db columns (28): ['id', 'title', 'subtitle', 'description', 'category', 'level', 'language', 'duration_weeks', 'price', 'thumbnail_url', 'status', 'enrollment_type', 'prerequisites', 'learning_outcomes', 'tags', 'allow_discussions', 'require_approval', 'is_published', 'total_lectures', 'average_rating', 'total_enrollments', 'revenue', 'access_level', 'created_at', 'updated_at', 'start_date', 'end_date', 'instructor_id']

- missing in db (in model not in db): ['instructor']

- extra in db (in db not in model): ['instructor_id']

- type mismatches: [('id', 'bigint AUTO_INCREMENT', 'bigint'), ('duration_weeks', 'integer', 'int'), ('price', 'numeric(10, 2)', 'decimal(10,2)'), ('allow_discussions', 'bool', 'tinyint(1)'), ('require_approval', 'bool', 'tinyint(1)'), ('is_published', 'bool', 'tinyint(1)'), ('total_lectures', 'integer', 'int'), ('average_rating', 'numeric(3, 2)', 'decimal(3,2)'), ('total_enrollments', 'integer', 'int'), ('revenue', 'numeric(10, 2)', 'decimal(10,2)')]


---

## Model: core.Lecture -> table `core_lecture`

- model fields (13): ['id', 'course', 'title', 'description', 'video_url', 'video_file', 'duration_minutes', 'order_index', 'is_published', 'is_free_preview', 'content_text', 'created_at', 'updated_at']

- db columns (13): ['id', 'title', 'description', 'video_url', 'video_file', 'duration_minutes', 'order_index', 'is_published', 'is_free_preview', 'content_text', 'created_at', 'updated_at', 'course_id']

- missing in db (in model not in db): ['course']

- extra in db (in db not in model): ['course_id']

- type mismatches: [('id', 'bigint AUTO_INCREMENT', 'bigint'), ('duration_minutes', 'integer', 'int'), ('order_index', 'integer', 'int'), ('is_published', 'bool', 'tinyint(1)'), ('is_free_preview', 'bool', 'tinyint(1)')]


---

## Model: core.LectureMaterial -> table `core_lecturematerial`

- model fields (7): ['id', 'lecture', 'name', 'file_url', 'file_type', 'file_size_kb', 'created_at']

- db columns (7): ['id', 'name', 'file_url', 'file_type', 'file_size_kb', 'created_at', 'lecture_id']

- missing in db (in model not in db): ['lecture']

- extra in db (in db not in model): ['lecture_id']

- type mismatches: [('id', 'bigint AUTO_INCREMENT', 'bigint'), ('file_size_kb', 'integer', 'int')]


---

## Model: core.CourseSchedule -> table `core_courseschedule`

- model fields (9): ['id', 'course', 'day_of_week', 'start_time', 'end_time', 'session_type', 'room_number', 'is_active', 'created_at']

- db columns (9): ['id', 'day_of_week', 'start_time', 'end_time', 'session_type', 'room_number', 'is_active', 'created_at', 'course_id']

- missing in db (in model not in db): ['course']

- extra in db (in db not in model): ['course_id']

- type mismatches: [('id', 'bigint AUTO_INCREMENT', 'bigint'), ('is_active', 'bool', 'tinyint(1)')]


---

## Model: core.StudyMaterial -> table `core_studymaterial`

- model fields (10): ['id', 'course', 'title', 'file_url', 'file_type', 'file_size_kb', 'category', 'description', 'uploaded_by', 'created_at']

- db columns (10): ['id', 'title', 'file_url', 'file_type', 'file_size_kb', 'category', 'description', 'created_at', 'course_id', 'uploaded_by_id']

- missing in db (in model not in db): ['course', 'uploaded_by']

- extra in db (in db not in model): ['course_id', 'uploaded_by_id']

- type mismatches: [('id', 'bigint AUTO_INCREMENT', 'bigint'), ('file_size_kb', 'integer', 'int')]


---

## Model: core.Enrollment -> table `core_enrollment`

- model fields (10): ['id', 'student', 'course', 'enrollment_date', 'status', 'progress_percentage', 'last_accessed', 'completion_date', 'final_grade', 'certificate_issued']

- db columns (10): ['id', 'enrollment_date', 'status', 'progress_percentage', 'last_accessed', 'completion_date', 'final_grade', 'certificate_issued', 'course_id', 'student_id']

- missing in db (in model not in db): ['student', 'course']

- extra in db (in db not in model): ['course_id', 'student_id']

- type mismatches: [('id', 'bigint AUTO_INCREMENT', 'bigint'), ('progress_percentage', 'numeric(5, 2)', 'decimal(5,2)'), ('final_grade', 'numeric(5, 2)', 'decimal(5,2)'), ('certificate_issued', 'bool', 'tinyint(1)')]


---

## Model: core.LectureProgress -> table `core_lectureprogress`

- model fields (7): ['id', 'student', 'lecture', 'status', 'watch_time_minutes', 'completed_at', 'last_position_seconds']

- db columns (7): ['id', 'status', 'watch_time_minutes', 'completed_at', 'last_position_seconds', 'lecture_id', 'student_id']

- missing in db (in model not in db): ['student', 'lecture']

- extra in db (in db not in model): ['lecture_id', 'student_id']

- type mismatches: [('id', 'bigint AUTO_INCREMENT', 'bigint'), ('watch_time_minutes', 'integer', 'int'), ('last_position_seconds', 'integer', 'int')]


---

## Model: core.Assignment -> table `core_assignment`

- model fields (13): ['id', 'course', 'title', 'description', 'instructions', 'due_date', 'total_marks', 'word_limit', 'allowed_file_types', 'status', 'created_by', 'created_at', 'updated_at']

- db columns (13): ['id', 'title', 'description', 'instructions', 'due_date', 'total_marks', 'word_limit', 'allowed_file_types', 'status', 'created_at', 'updated_at', 'course_id', 'created_by_id']

- missing in db (in model not in db): ['course', 'created_by']

- extra in db (in db not in model): ['course_id', 'created_by_id']

- type mismatches: [('id', 'bigint AUTO_INCREMENT', 'bigint'), ('total_marks', 'numeric(10, 2)', 'decimal(10,2)'), ('word_limit', 'integer', 'int')]


---

## Model: core.AssignmentSubmission -> table `core_assignmentsubmission`

- model fields (12): ['id', 'assignment', 'student', 'submission_date', 'submitted_file_url', 'submission_text', 'status', 'marks_obtained', 'grade', 'teacher_feedback', 'graded_by', 'graded_at']

- db columns (12): ['id', 'submission_date', 'submitted_file_url', 'submission_text', 'status', 'marks_obtained', 'grade', 'teacher_feedback', 'graded_at', 'assignment_id', 'graded_by_id', 'student_id']

- missing in db (in model not in db): ['assignment', 'student', 'graded_by']

- extra in db (in db not in model): ['assignment_id', 'graded_by_id', 'student_id']

- type mismatches: [('id', 'bigint AUTO_INCREMENT', 'bigint'), ('marks_obtained', 'numeric(10, 2)', 'decimal(10,2)')]


---

## Model: core.AssignmentAttachment -> table `core_assignmentattachment`

- model fields (6): ['id', 'assignment', 'file_name', 'file_url', 'file_size_kb', 'uploaded_at']

- db columns (6): ['id', 'file_name', 'file_url', 'file_size_kb', 'uploaded_at', 'assignment_id']

- missing in db (in model not in db): ['assignment']

- extra in db (in db not in model): ['assignment_id']

- type mismatches: [('id', 'bigint AUTO_INCREMENT', 'bigint'), ('file_size_kb', 'integer', 'int')]


---

## Model: core.Test -> table `core_test`

- model fields (15): ['id', 'course', 'title', 'subject', 'test_type', 'scheduled_date', 'duration_minutes', 'total_marks', 'instructions', 'status', 'randomize_questions', 'show_results_immediately', 'created_by', 'created_at', 'updated_at']

- db columns (15): ['id', 'title', 'subject', 'test_type', 'scheduled_date', 'duration_minutes', 'total_marks', 'instructions', 'status', 'randomize_questions', 'show_results_immediately', 'created_at', 'updated_at', 'course_id', 'created_by_id']

- missing in db (in model not in db): ['course', 'created_by']

- extra in db (in db not in model): ['course_id', 'created_by_id']

- type mismatches: [('id', 'bigint AUTO_INCREMENT', 'bigint'), ('duration_minutes', 'integer', 'int'), ('total_marks', 'numeric(10, 2)', 'decimal(10,2)'), ('randomize_questions', 'bool', 'tinyint(1)'), ('show_results_immediately', 'bool', 'tinyint(1)')]


---

## Model: core.Question -> table `core_question`

- model fields (10): ['id', 'test', 'question_type', 'question_text', 'options', 'correct_answer', 'marks', 'order_index', 'explanation', 'created_at']

- db columns (10): ['id', 'question_type', 'question_text', 'options', 'correct_answer', 'marks', 'order_index', 'explanation', 'created_at', 'test_id']

- missing in db (in model not in db): ['test']

- extra in db (in db not in model): ['test_id']

- type mismatches: [('id', 'bigint AUTO_INCREMENT', 'bigint'), ('marks', 'numeric(5, 2)', 'decimal(5,2)'), ('order_index', 'integer', 'int')]


---

## Model: core.TestSubmission -> table `core_testsubmission`

- model fields (10): ['id', 'test', 'student', 'start_time', 'submit_time', 'status', 'marks_obtained', 'grade', 'teacher_feedback', 'time_taken_minutes']

- db columns (10): ['id', 'start_time', 'submit_time', 'status', 'marks_obtained', 'grade', 'teacher_feedback', 'time_taken_minutes', 'student_id', 'test_id']

- missing in db (in model not in db): ['test', 'student']

- extra in db (in db not in model): ['student_id', 'test_id']

- type mismatches: [('id', 'bigint AUTO_INCREMENT', 'bigint'), ('marks_obtained', 'numeric(10, 2)', 'decimal(10,2)'), ('time_taken_minutes', 'integer', 'int')]


---

## Model: core.TestAnswer -> table `core_testanswer`

- model fields (8): ['id', 'submission', 'question', 'student_answer', 'is_correct', 'marks_awarded', 'marked', 'marker_notes']

- db columns (8): ['id', 'student_answer', 'is_correct', 'marks_awarded', 'marked', 'marker_notes', 'question_id', 'submission_id']

- missing in db (in model not in db): ['submission', 'question']

- extra in db (in db not in model): ['question_id', 'submission_id']

- type mismatches: [('id', 'bigint AUTO_INCREMENT', 'bigint'), ('is_correct', 'bool', 'tinyint(1)'), ('marks_awarded', 'numeric(5, 2)', 'decimal(5,2)'), ('marked', 'bool', 'tinyint(1)')]


---

## Model: core.AttendanceRecord -> table `core_attendancerecord`

- model fields (8): ['id', 'student', 'course', 'date', 'status', 'notes', 'marked_by', 'marked_at']

- db columns (8): ['id', 'date', 'status', 'notes', 'marked_at', 'course_id', 'marked_by_id', 'student_id']

- missing in db (in model not in db): ['student', 'course', 'marked_by']

- extra in db (in db not in model): ['course_id', 'marked_by_id', 'student_id']

- type mismatches: [('id', 'bigint AUTO_INCREMENT', 'bigint')]


---

## Model: core.LibraryItem -> table `core_libraryitem`

- model fields (20): ['id', 'title', 'item_type', 'category', 'course', 'subject', 'description', 'file_url', 'thumbnail_url', 'file_size_kb', 'duration_minutes', 'pages', 'uploaded_by', 'upload_date', 'total_downloads', 'average_rating', 'tags', 'is_featured', 'access_level', 'created_at']

- db columns (20): ['id', 'title', 'item_type', 'category', 'subject', 'description', 'file_url', 'thumbnail_url', 'file_size_kb', 'duration_minutes', 'pages', 'upload_date', 'total_downloads', 'average_rating', 'tags', 'is_featured', 'access_level', 'created_at', 'course_id', 'uploaded_by_id']

- missing in db (in model not in db): ['course', 'uploaded_by']

- extra in db (in db not in model): ['course_id', 'uploaded_by_id']

- type mismatches: [('id', 'bigint AUTO_INCREMENT', 'bigint'), ('file_size_kb', 'integer', 'int'), ('duration_minutes', 'integer', 'int'), ('pages', 'integer', 'int'), ('total_downloads', 'integer', 'int'), ('average_rating', 'numeric(3, 2)', 'decimal(3,2)'), ('is_featured', 'bool', 'tinyint(1)')]


---

## Model: core.LibraryFavorite -> table `core_libraryfavorite`

- model fields (4): ['id', 'user', 'library_item', 'created_at']

- db columns (4): ['id', 'created_at', 'library_item_id', 'user_id']

- missing in db (in model not in db): ['user', 'library_item']

- extra in db (in db not in model): ['library_item_id', 'user_id']

- type mismatches: [('id', 'bigint AUTO_INCREMENT', 'bigint')]


---

## Model: core.LibraryDownload -> table `core_librarydownload`

- model fields (4): ['id', 'user', 'library_item', 'download_date']

- db columns (4): ['id', 'download_date', 'library_item_id', 'user_id']

- missing in db (in model not in db): ['user', 'library_item']

- extra in db (in db not in model): ['library_item_id', 'user_id']

- type mismatches: [('id', 'bigint AUTO_INCREMENT', 'bigint')]


---

## Model: core.Event -> table `core_event`

- model fields (10): ['id', 'title', 'event_type', 'event_date', 'start_time', 'end_time', 'course', 'instructor', 'zoom_link', 'created_at']

- db columns (10): ['id', 'title', 'event_type', 'event_date', 'start_time', 'end_time', 'zoom_link', 'created_at', 'course_id', 'instructor_id']

- missing in db (in model not in db): ['course', 'instructor']

- extra in db (in db not in model): ['course_id', 'instructor_id']

- type mismatches: [('id', 'bigint AUTO_INCREMENT', 'bigint')]


---

## Model: core.Announcement -> table `core_announcement`

- model fields (6): ['id', 'title', 'body', 'audience', 'created_by', 'created_at']

- db columns (6): ['id', 'title', 'body', 'audience', 'created_at', 'created_by_id']

- missing in db (in model not in db): ['created_by']

- extra in db (in db not in model): ['created_by_id']

- type mismatches: [('id', 'bigint AUTO_INCREMENT', 'bigint')]


---

## Model: core.Upload -> table `core_upload`

- model fields (5): ['id', 'file_name', 'file_url', 'uploaded_by', 'uploaded_at']

- db columns (5): ['id', 'file_name', 'file_url', 'uploaded_at', 'uploaded_by_id']

- missing in db (in model not in db): ['uploaded_by']

- extra in db (in db not in model): ['uploaded_by_id']

- type mismatches: [('id', 'bigint AUTO_INCREMENT', 'bigint')]


---
