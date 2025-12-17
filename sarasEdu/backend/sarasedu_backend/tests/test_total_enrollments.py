"""
Test script to verify total_enrollments update functionality
"""
from django.test import TestCase
from django.contrib.auth import get_user_model
from core.models import Course, Enrollment

User = get_user_model()


class TotalEnrollmentsTestCase(TestCase):
    """Test cases for total_enrollments field updates"""
    
    def setUp(self):
        """Set up test data"""
        # Create a teacher
        self.teacher = User.objects.create_user(
            username='teacher1',
            email='teacher1@test.com',
            password='testpass123',
            role='teacher'
        )
        
        # Create students
        self.student1 = User.objects.create_user(
            username='student1',
            email='student1@test.com',
            password='testpass123',
            role='student'
        )
        self.student2 = User.objects.create_user(
            username='student2',
            email='student2@test.com',
            password='testpass123',
            role='student'
        )
        self.student3 = User.objects.create_user(
            username='student3',
            email='student3@test.com',
            password='testpass123',
            role='student'
        )
        
        # Create a course
        self.course = Course.objects.create(
            title='Test Course',
            instructor=self.teacher,
            status='active',
            is_published=True
        )
    
    def test_enrollment_creation_updates_count(self):
        """Test that creating enrollments updates total_enrollments"""
        # Initial count should be 0
        self.assertEqual(self.course.total_enrollments, 0)
        
        # Create first enrollment
        Enrollment.objects.create(
            student=self.student1,
            course=self.course,
            status='active'
        )
        self.course.refresh_from_db()
        self.assertEqual(self.course.total_enrollments, 1)
        
        # Create second enrollment
        Enrollment.objects.create(
            student=self.student2,
            course=self.course,
            status='active'
        )
        self.course.refresh_from_db()
        self.assertEqual(self.course.total_enrollments, 2)
        
        # Create third enrollment
        Enrollment.objects.create(
            student=self.student3,
            course=self.course,
            status='active'
        )
        self.course.refresh_from_db()
        self.assertEqual(self.course.total_enrollments, 3)
    
    def test_enrollment_deletion_updates_count(self):
        """Test that deleting enrollments updates total_enrollments"""
        # Create enrollments
        enrollment1 = Enrollment.objects.create(
            student=self.student1,
            course=self.course,
            status='active'
        )
        enrollment2 = Enrollment.objects.create(
            student=self.student2,
            course=self.course,
            status='active'
        )
        
        self.course.refresh_from_db()
        self.assertEqual(self.course.total_enrollments, 2)
        
        # Delete one enrollment
        enrollment1.delete()
        self.course.refresh_from_db()
        self.assertEqual(self.course.total_enrollments, 1)
        
        # Delete second enrollment
        enrollment2.delete()
        self.course.refresh_from_db()
        self.assertEqual(self.course.total_enrollments, 0)
    
    def test_management_command_updates_count(self):
        """Test that management command correctly updates total_enrollments"""
        # Create enrollments
        Enrollment.objects.create(student=self.student1, course=self.course)
        Enrollment.objects.create(student=self.student2, course=self.course)
        
        # Manually set wrong count
        Course.objects.filter(id=self.course.id).update(total_enrollments=0)
        self.course.refresh_from_db()
        self.assertEqual(self.course.total_enrollments, 0)
        
        # Run management command
        from django.core.management import call_command
        call_command('update_total_enrollments', '--course-id', self.course.id)
        
        # Verify count is corrected
        self.course.refresh_from_db()
        self.assertEqual(self.course.total_enrollments, 2)
