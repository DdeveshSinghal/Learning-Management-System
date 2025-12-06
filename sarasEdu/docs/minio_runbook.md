**MinIO / S3 Runbook (one-page)

- **Purpose**: How to enable S3 (MinIO) for local development, create the `sarasedu` bucket, restart services so Django uses S3 storage, and run smoke tests for uploads.

- **Prereqs**: Docker & Docker Compose installed; repository checked out; backend `.env` present at `backend/.env`.

- **1) Enable S3 in `.env`**
  - Edit `backend/.env` and set:
    - `USE_S3=1`
    - `MINIO_ENDPOINT=minio:9000` (container-internal DNS, leave as-is for compose)
    - `MINIO_ACCESS_KEY=minioadmin`
    - `MINIO_SECRET_KEY=minioadmin`
    - `MINIO_BUCKET=sarasedu`
    - `MINIO_SECURE=0` (or `1` for TLS)
    - `MINIO_PUBLIC_ENDPOINT=http://localhost:9000` (public URL shown in generated file links)

- **2) Start services (docker-compose)**

```powershell
cd backend
# Start DB, MinIO, and backend
docker-compose up -d --build
```

- **3) Create the bucket**

Preferred (from host): run the helper script and point it at the host-mapped MinIO endpoint:

```powershell
cd backend
# run the script using the host endpoint so it can reach MinIO from the host
python scripts/create_minio_bucket.py
# If you need to override endpoint, set MINIO_ENDPOINT env var for the script
# e.g. $env:MINIO_ENDPOINT = 'localhost:9000'; python scripts/create_minio_bucket.py
```

Alternate (from inside the backend container):

```powershell
# open shell in backend container and run the script using container DNS
docker-compose exec backend bash
python scripts/create_minio_bucket.py
exit
```

- **4) Confirm backend can reach MinIO**
  - Ensure the backend container env uses `MINIO_ENDPOINT=minio:9000` (internal) and `MINIO_PUBLIC_ENDPOINT` points to a host URL for generated links.
  - If you change `.env`, restart backend so settings reload:

```powershell
docker-compose restart backend
```

- **5) Upload smoke test (authenticated)**

```powershell
cd backend
# 1) Login to obtain JWT access token
$resp = Invoke-RestMethod -Uri http://127.0.0.1:8000/api/auth/login -Method Post -Body '{"username":"sarah.johnson","password":"teacherpass"}' -ContentType 'application/json'
$access = $resp.access
# 2) Upload a file (multipart/form-data)
$hdr = "Authorization: Bearer $access"
curl.exe -v -F "file=@./upload_test.zip" -H $hdr http://127.0.0.1:8000/api/uploads/
```

Expected: HTTP 201 with JSON `{ "id": <n>, "url": "http://localhost:9000/...." }`.

- **6) Notes on validation & production**
  - `ALLOWED_UPLOAD_MIME_TYPES` is configured in `backend/sarasedu_backend/sarasedu_backend/settings.py` (defaults to `application/pdf,image/png,image/jpeg,video/mp4,application/zip`). Do not include `application/octet-stream` in production.
  - The upload view now attempts content-based detection with `python-magic` when available; if detection is generic (`application/octet-stream`) we fall back to the filename extension using Python's `mimetypes` module to avoid false negatives for common archives (ZIP).
  - For stricter verification in production, consider validating file contents more deeply (e.g., extract ZIPCentralDirectory checks, parse PDF headers) and run antivirus scanning.

- **7) CI suggestions**
  - Add an integration test that boots a test compose stack with MinIO and exercises the `/api/uploads/` endpoint (login → upload → GET upload list).
  - In CI, run the `create_minio_bucket.py` step before tests if the MinIO container doesn't auto-create the bucket.

- **8) Troubleshooting**
  - If you see `EndpointConnectionError` or `Connection refused`, confirm backend container env uses `MINIO_ENDPOINT=minio:9000` and the `minio` service is `Running` in `docker-compose ps`.
  - If generated URLs point to `http://minio:9000/...` instead of `localhost:9000`, ensure `MINIO_PUBLIC_ENDPOINT` is set and `AWS_S3_CUSTOM_DOMAIN` is configured in settings (the code sets this automatically when `MINIO_PUBLIC_ENDPOINT` is present).

- **Location of helpers**: `backend/scripts/create_minio_bucket.py` (creates/checks the bucket)

---
Generated on: 2025-11-15
