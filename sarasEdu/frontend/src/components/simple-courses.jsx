import React, { useEffect, useState } from 'react';
import { Card, CardContent } from './ui/card';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Progress } from './ui/progress';
import { Input } from './ui/input';
import { 
  BookOpen, 
  Video, 
  Star,
  Users,
  Clock,
  Plus,
  Search,
  Filter,
  Eye,
  Edit,
  Play,
  UserPlus
} from 'lucide-react';
import { ImageWithFallback } from './figma/ImageWithFallback';
import { EnhancedCourseDetail } from './enhanced-course-detail';
import { EnhancedCourseCreation } from './enhanced-course-creation';
import api from '../services/api';
import { useAuth } from '../contexts/AuthContext';
import { toast } from 'sonner';

// Props/types removed for JS build. Courses should be fetched from an API.
export function SimpleCourses({ userRole }) {
  const { user } = useAuth();
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCourse, setSelectedCourse] = useState(null);
  const [courseCreationMode, setCourseCreationMode] = useState(null);
  const [courses, setCourses] = useState([]);
  const [loading, setLoading] = useState(false);
  const [enrollments, setEnrollments] = useState([]);
  const [enrollingCourseId, setEnrollingCourseId] = useState(null);

  useEffect(() => {
    let mounted = true;
    setLoading(true);
    
    const fetchData = async () => {
      try {
        const [coursesData, enrollmentsData] = await Promise.all([
          api.getCourses(),
          userRole === 'student' ? api.getEnrollments() : Promise.resolve([])
        ]);
        
        if (mounted) {
          setCourses(coursesData || []);
          setEnrollments(enrollmentsData || []);
        }
      } catch (error) {
        if (mounted) {
          setCourses([]);
          setEnrollments([]);
        }
      } finally {
        if (mounted) setLoading(false);
      }
    };
    
    fetchData();
    return () => { mounted = false; };
  }, [userRole]);

  const handleEnroll = async (courseId) => {
    if (!user || !user.id) {
      toast.error('Please log in to enroll in courses');
      return;
    }

    setEnrollingCourseId(courseId);
    try {
      await api.enrollInCourse(courseId, user.id);
      toast.success('Successfully enrolled in the course!');
      
      // Refresh enrollments
      const updatedEnrollments = await api.getEnrollments();
      setEnrollments(updatedEnrollments || []);
    } catch (error) {
      console.error('Enrollment error:', error);
      toast.error(error.message || 'Failed to enroll in course');
    } finally {
      setEnrollingCourseId(null);
    }
  };

  const isEnrolled = (courseId) => {
    if (!user || !user.id) return false;
    return enrollments.some(e => e.course === courseId && e.student === user.id);
  };

  if (selectedCourse) {
    return (
      <EnhancedCourseDetail 
        courseId={selectedCourse} 
        userRole={userRole}
        onBack={() => setSelectedCourse(null)} 
      />
    );
  }

  if (courseCreationMode) {
    return (
      <EnhancedCourseCreation
        mode={courseCreationMode.mode}
        courseId={courseCreationMode.courseId}
        onBack={() => setCourseCreationMode(null)}
      />
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <h2 className="text-3xl font-bold">
          {userRole === 'student' ? 'My Courses' : userRole === 'admin' ? 'All Courses' : 'Course Management'}
        </h2>
        <div className="flex items-center gap-4">
          <div className="flex items-center gap-2">
            <Search className="h-4 w-4" />
            <Input
              placeholder="Search courses..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-64"
            />
          </div>
          <Button variant="outline">
            <Filter className="h-4 w-4 mr-2" />
            Filter
          </Button>
          {userRole === 'teacher' && (
            <Button onClick={() => setCourseCreationMode({ mode: 'create' })}>
              <Plus className="h-4 w-4 mr-2" />
              Create Course
            </Button>
          )}
        </div>
      </div>

      {/* Courses Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {loading ? (
          <div>Loading courses...</div>
        ) : courses.map((course) => (
          <Card key={course.id} className="hover:shadow-lg transition-shadow">
            <div className="aspect-video relative">
              {(() => {
                const raw = course.thumbnail_url || course.image || course.thumbnail || '';
                const transformDriveUrl = (u) => {
                  if (!u) return '';
                  try {
                    const url = new URL(u);
                    const host = url.host || '';
                    if (host.includes('drive.google.com')) {
                      // Try to extract file id from /file/d/ID or ?id=ID
                      const m = u.match(/\/d\/([a-zA-Z0-9_-]+)/);
                      if (m && m[1]) return `https://drive.google.com/uc?export=view&id=${m[1]}`;
                      const q = url.searchParams.get('id');
                      if (q) return `https://drive.google.com/uc?export=view&id=${q}`;
                      // fallback: if contains "open?id=" pattern
                      const m2 = u.match(/[?&]id=([a-zA-Z0-9_-]+)/);
                      if (m2 && m2[1]) return `https://drive.google.com/uc?export=view&id=${m2[1]}`;
                    }
                  } catch (e) {
                    // ignore URL parse errors
                  }
                  return u;
                };

                const src = transformDriveUrl(raw);
                if (!src) {
                  return (
                    <div className="w-full h-full bg-gray-100 rounded-t-lg flex items-center justify-center">
                      <span className="text-gray-400">No image</span>
                    </div>
                  );
                }
                return (
                  <ImageWithFallback
                    src={src}
                    alt={course.title}
                    className="w-full h-full object-cover rounded-t-lg"
                  />
                );
              })()}
              <div className="absolute top-2 right-2">
                <Badge variant="secondary">{course.rating}★</Badge>
              </div>
            </div>
            <CardContent className="p-4">
              <div className="space-y-3">
                <div>
                  <h3 className="font-semibold text-lg">{course.title}</h3>
                  <p className="text-sm text-muted-foreground">{
                    (() => {
                      const instr = course.instructor;
                      if (!instr) return '';
                      if (typeof instr === 'string') return instr;
                      return instr.first_name || instr.last_name ? `${instr.first_name || ''} ${instr.last_name || ''}`.trim() : instr.username || instr.email || '';
                    })()
                  }</p>
                </div>
                
                {userRole === 'student' ? (
                  <>
                    {isEnrolled(course.id) ? (
                      <>
                        <div className="space-y-1">
                          <div className="flex justify-between text-sm">
                            <span>Progress</span>
                            <span>{course.progress || 0}%</span>
                          </div>
                          <Progress value={course.progress || 0} />
                        </div>
                        <div className="flex gap-2">
                          <Button size="sm" className="flex-1" onClick={() => setSelectedCourse(course.id)}>
                            <Play className="h-3 w-3 mr-1" />
                            Continue Learning
                          </Button>
                        </div>
                      </>
                    ) : (
                      <div className="flex gap-2">
                        <Button 
                          size="sm" 
                          className="flex-1" 
                          onClick={() => handleEnroll(course.id)}
                          disabled={enrollingCourseId === course.id}
                        >
                          <UserPlus className="h-3 w-3 mr-1" />
                          {enrollingCourseId === course.id ? 'Enrolling...' : 'Enroll Now'}
                        </Button>
                      </div>
                    )}
                  </>
                ) : (
                  <>
                    <div className="flex items-center justify-between">
                      <Badge variant="outline">{course.enrolled} students</Badge>
                      <div className="flex items-center gap-1 text-sm text-muted-foreground">
                        <Star className="h-3 w-3" />
                        <span>{course.rating}</span>
                      </div>
                    </div>
                    <div className="flex gap-2">
                      <Button size="sm" variant="outline" className="flex-1" onClick={() => setSelectedCourse(course.id)}>
                        <Eye className="h-3 w-3 mr-1" />
                        View
                      </Button>
                      {userRole === 'teacher' && (
                        <Button size="sm" variant="outline" onClick={(e) => {
                          e.stopPropagation();
                          setCourseCreationMode({ mode: 'edit', courseId: course.id });
                        }}>
                          <Edit className="h-3 w-3 mr-1" />
                          Edit
                        </Button>
                      )}
                    </div>
                  </>
                )}
              </div>
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  );
}