import time
import requests
import pytest

BASE = 'http://127.0.0.1:8000'
UPLOADS = BASE + '/api/uploads/'
LOGIN = BASE + '/api/auth/login'


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
    r = requests.post(LOGIN, json={'username': 'sarah.johnson', 'password': 'teacherpass'})
    assert r.status_code == 200
    return r.json()['access']


def test_upload_listing_and_download_url(token):
    headers = {'Authorization': f'Bearer {token}'}
    # create a small upload using the uploads endpoint (use existing tests helper from previous file)
    files = {'file': ('hello.txt', b'hello world', 'text/plain')}
    # Note: uploads endpoint will validate MIME; text/plain may be rejected in strict mode, so expect either 201 or 400
    r = requests.post(UPLOADS, headers=headers, files=files)
    if r.status_code == 400:
        # acceptable if validation rejects text/plain; try an allowed type instead
        files = {'file': ('image.png', b'\x89PNG\r\n\x1a\n', 'image/png')}
        r = requests.post(UPLOADS, headers=headers, files=files)
        assert r.status_code == 201, f'Upload of image failed: {r.status_code} {r.text}'
    else:
        assert r.status_code == 201, f'Upload failed: {r.status_code} {r.text}'

    # list uploads
    rl = requests.get(UPLOADS, headers=headers)
    assert rl.status_code == 200
    data = rl.json().get('results') or rl.json()
    assert data, 'Upload list returned empty'
    # check first upload has url
    first = data[0]
    assert 'url' in first and first['url'], 'Uploaded record missing url'
