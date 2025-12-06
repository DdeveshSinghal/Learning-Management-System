import io
import zipfile
import time
import requests
import pytest

BASE = 'http://127.0.0.1:8000'
LOGIN = BASE + '/api/auth/login'
UPLOAD = BASE + '/api/uploads/'


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
def token():
    wait_for_backend()
    creds = {'username': 'sarah.johnson', 'password': 'teacherpass'}
    r = requests.post(LOGIN, json=creds)
    assert r.status_code == 200, f'Login failed: {r.status_code} {r.text}'
    return r.json()['access']


def make_zip_bytes():
    buf = io.BytesIO()
    with zipfile.ZipFile(buf, 'w') as zf:
        zf.writestr('hello.txt', 'this is a test')
    buf.seek(0)
    return buf


@pytest.mark.parametrize('name,content,content_type', [
    ('upload_test.zip', make_zip_bytes(), 'application/zip'),
    ('upload_test.pdf', io.BytesIO(b'%PDF-1.4\n%\xc2\xc2\xc2\n'), 'application/pdf'),
    ('upload_test.png', io.BytesIO(b'\x89PNG\r\n\x1a\n'), 'image/png'),
])
def test_uploads(name, content, content_type, token):
    headers = {'Authorization': f'Bearer {token}'}
    # requests requires file-like object with name attribute or a tuple
    files = {'file': (name, content, content_type)}
    r = requests.post(UPLOAD, headers=headers, files=files)
    assert r.status_code == 201, f'Upload failed for {name}: {r.status_code} {r.text}'
