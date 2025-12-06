import time
import requests
import io
import zipfile
import pytest

BASE = 'http://127.0.0.1:8000'
LOGIN = BASE + '/api/auth/login'
ASSIGNMENTS = BASE + '/api/assignments/'
SUBMISSIONS = BASE + '/api/assignment-submissions/'


def wait_for_backend(timeout=60):
    start = time.time()
    while True:
        try:
            requests.get(BASE + '/api/')
            return
        except Exception:
            if time.time() - start > timeout:
                pytest.exit('Backend did not become ready in time')
            time.sleep(1)


@pytest.fixture(scope='module')
def teacher_token():
    wait_for_backend()
    r = requests.post(LOGIN, json={'username': 'sarah.johnson', 'password': 'teacherpass'})
    assert r.status_code == 200
    return r.json()['access']


@pytest.fixture(scope='module')
def student_token():
    wait_for_backend()
    r = requests.post(LOGIN, json={'username': 'john.doe', 'password': 'studentpass'})
    assert r.status_code == 200
    return r.json()['access']


def make_zip_bytes():
    buf = io.BytesIO()
    with zipfile.ZipFile(buf, 'w') as zf:
        zf.writestr('hello.txt', 'this is a test')
    buf.seek(0)
    return buf


def test_create_assignment_and_student_submission(teacher_token, student_token):
    # Teacher creates an assignment (assign to the seeded Advanced Mathematics course)
    headers = {'Authorization': f'Bearer {teacher_token}'}
    # Find a course id first
    r = requests.get(BASE + '/api/courses/', headers=headers)
    assert r.status_code == 200
    courses = r.json().get('results') or r.json()
    assert courses, 'No courses available for assignment creation'
    course_id = courses[0]['id']

    import datetime
    due_date = (datetime.datetime.utcnow() + datetime.timedelta(days=7)).isoformat() + 'Z'
    payload = {
        'course': course_id,
        'title': 'Integration Test Assignment',
        'description': 'Please submit a small ZIP',
        'due_date': due_date,
        'total_marks': '100.00'
    }
    r2 = requests.post(ASSIGNMENTS, headers=headers, json=payload)
    assert r2.status_code == 201, f'Assignment creation failed: {r2.status_code} {r2.text}'
    assignment = r2.json()

    # Student submits an assignment with a file
    s_headers = {'Authorization': f'Bearer {student_token}'}
    zip_buf = make_zip_bytes()
    files = {'file': ('submission.zip', zip_buf, 'application/zip')}
    data = {'assignment': assignment['id'], 'submission_text': 'Here is my submission.'}
    r3 = requests.post(SUBMISSIONS, headers=s_headers, files=files, data=data)
    assert r3.status_code == 201, f'Submission failed: {r3.status_code} {r3.text}'
    sub = r3.json()
    assert sub.get('assignment') == assignment['id']


def test_submission_visible_in_student_and_teacher_views(teacher_token, student_token):
    # Verify teacher can see submissions for their assignments and student can see their own
    t_headers = {'Authorization': f'Bearer {teacher_token}'}
    s_headers = {'Authorization': f'Bearer {student_token}'}

    # teacher view: list submissions
    rt = requests.get(SUBMISSIONS, headers=t_headers)
    assert rt.status_code == 200
    # ensure at least one submission exists
    data_t = rt.json().get('results') or rt.json()
    assert data_t, 'Teacher cannot see any submissions'

    # student view: list my submissions
    rs = requests.get(SUBMISSIONS, headers=s_headers)
    assert rs.status_code == 200
    data_s = rs.json().get('results') or rs.json()
    assert data_s, 'Student cannot see their submissions'
