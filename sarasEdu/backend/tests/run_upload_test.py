import requests
import time
import zipfile
import io
import sys

BASE = 'http://127.0.0.1:8000'
LOGIN = BASE + '/api/auth/login'
UPLOAD = BASE + '/api/uploads/'

# wait for backend to be ready
timeout = 60
start = time.time()
while True:
    try:
        r = requests.get(BASE + '/api/')
        # if server returns any HTTP code, assume it's up
        break
    except Exception:
        if time.time() - start > timeout:
            print('Backend did not come up in time', file=sys.stderr)
            sys.exit(2)
        time.sleep(1)

# login
creds = {'username':'sarah.johnson','password':'teacherpass'}
print('Logging in...')
r = requests.post(LOGIN, json=creds)
if r.status_code != 200:
    print('Login failed', r.status_code, r.text)
    sys.exit(3)
access = r.json().get('access')
headers = {'Authorization': f'Bearer {access}'}

# create an in-memory zip file
zip_buffer = io.BytesIO()
with zipfile.ZipFile(zip_buffer, 'w') as zf:
    zf.writestr('hello.txt', 'this is a test')
zip_buffer.seek(0)

files = {'file': ('upload_test.zip', zip_buffer, 'application/zip')}
print('Uploading zip...')
resp = requests.post(UPLOAD, headers=headers, files=files)
print('Status:', resp.status_code)
print('Body:', resp.text)
if resp.status_code != 201:
    sys.exit(4)
print('Upload integration test passed')
