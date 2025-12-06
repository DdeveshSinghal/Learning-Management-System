# SarasEduHub — Backend Handover

This document is a concise, actionable handover for the backend team to implement the SarasEdu frontend. It collects the API surface, DB schema summary, required environment variables, seeds/migrations, dev setup and a deployment checklist.

**Repository pointers**:
- **Frontend**: `frontend/` — React + Vite app. Uses `/api/*` path for backend.
- **API spec**: `docs/openapi.yaml` — canonical OpenAPI 3.0.3 for main endpoints.
- **API mapping**: `docs/db_api_mapping.md` — frontend→backend mapping and examples.
- **Postman**: `docs/postman_collection.json` — ready-to-use collection (baseUrl variable).
- **DB schema**: `backend/database/schema.sql` and `docs/mysql_schema.sql` — complete MySQL DDL.
- **DB loader**: `backend/db/schema.sql` — single-file loader referencing docs files.

**Summary of API surface (high-level)**
- Auth: `POST /api/auth/login`, `POST /api/auth/register`, `GET /api/auth/me`, `POST /api/auth/logout` (expected).
- Users: `GET|PUT /api/users/:id` (profile retrieval and update).
- Courses: `GET /api/courses`, `GET /api/courses/:id`, `POST|PUT|DELETE /api/courses` and `GET /api/courses/:id/lectures`.
- Enrollments: `POST /api/enrollments`, `GET /api/users/:id/enrollments`.
- Lectures & Materials: `GET /api/lectures/:id`, `POST /api/lectures/:id/materials` (file upload).
- Assignments: `GET /api/assignments`, `POST /api/assignments`, `POST /api/assignments/:id/submissions`.
- Tests/Quizzes: `GET /api/tests`, `GET /api/tests/:id`, `POST /api/tests/:id/submissions`.
- Events: `GET|POST /api/events`, `PUT|DELETE /api/events/:id`.
- Library: `GET|POST /api/library`, `GET /api/library/:id`, `PUT|DELETE /api/library/:id`.
- Announcements & Notifications: `GET /api/announcements`, `POST /api/notifications/mark-read`.
- AI: `POST /api/ai/chat`, `POST /api/ai/image`, `POST /api/ai/transcribe`.
- Generic uploads: `POST /api/uploads` (multipart/form-data)

OpenAPI / Postman
- `docs/openapi.yaml` provides request/response schemas for many endpoints (login/register, courses, lectures, assignments, library, events, AI chat). Backend should use it as the contract and return the documented shapes.
- `docs/postman_collection.json` contains ready requests; set `baseUrl` to the running backend (e.g. `http://localhost:4000`).

Database (MySQL) summary
- Primary design: normalized schema with `users` table and role-specific profiles (`student_profiles`, `teacher_profiles`, `admin_profiles`).
- Core domain tables: `courses`, `lectures`, `lecture_materials`, `study_materials`, `course_schedules`.
- Learning flow tables: `enrollments`, `lecture_progress`, `assignments`, `assignment_submissions`, `assignment_attachments`.
- Assessment: `tests`, `questions`, `test_submissions`, `test_answers`.
- Support: `library_items`, `library_favorites`, `library_downloads`, `events`, `attendance_records`, `announcements`.
- Constraints & relations: foreign keys present across the schema (e.g., `lectures.course_id -> courses.id`, `enrollments.student_id -> users.id`). Many tables use `ON DELETE CASCADE` — backend must be careful when deleting parent records.
- Data types: enums used extensively; JSON columns used for flexible fields (`learning_outcomes`, `tags`, `options` in questions). Use MySQL 5.7+ / 8.0 for JSON support.

Schema import & seed
- Use `backend/db/schema.sql` which sources `docs/mysql_schema.sql` and `docs/sample_data_mysql.sql`.
- Recommended import command (from repo root):

```powershell
cd backend/db; mysql -u <user> -p < schema.sql
```

- Backend should convert DDL into ORM models (Django, Express+TypeORM/Sequelize, or similar) and generate migrations from those models to ensure version control.

Environment variables (required / recommended)
- `DATABASE_URL` or `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD` — MySQL connection.
- `JWT_SECRET` — secret for signing JWT tokens used by `bearerAuth` in OpenAPI.
- `JWT_EXPIRES_IN` — token TTL (optional).
- `NODE_ENV` or `APP_ENV` — environment.
- `PORT` — backend port.
- `UPLOADS_STORAGE` — `local` or S3-compatible option.
- If using S3: `S3_BUCKET`, `S3_REGION`, `S3_ACCESS_KEY_ID`, `S3_SECRET_ACCESS_KEY`, `S3_ENDPOINT` (if non-AWS).
- `EMAIL_SMTP_HOST`, `EMAIL_SMTP_PORT`, `EMAIL_USER`, `EMAIL_PASSWORD` — for notifications.
- `AI_PROVIDER_KEY` — API key for 3rd-party LLM/multimodal service used by `/api/ai/*`.
- `ZOOM_API_KEY`, `ZOOM_API_SECRET` or calendar provider creds (if creating meeting links).

File uploads
- Frontend expects `POST /api/uploads` and file-upload endpoints (assignments, lectures, library) to accept `multipart/form-data` and return `{ url }`.
- For production use S3 (or other cloud storage) and return signed CDN/https URLs.

Authentication & Authorization
- JWT bearer tokens per `docs/openapi.yaml` `bearerAuth` scheme.
- Backend must implement role-based checks for teacher/admin endpoints (create course, create assignment, grade tests). Follow role values in `users.role` enum.

Pagination, filtering, sorting
- Implement cursor or offset pagination for lists (`/courses`, `/library`, etc.). Frontend expects `page` and `limit` query params; return `{ data: [], meta: { total, page, limit } }`.

Seed & migration strategy
- Create ORM models and generate migrations; do not rely only on SQL dumps for long-term maintenance.
- Provide a one-time seed script to import `docs/sample_data_mysql.sql` into a dev DB; allow idempotent seeds (check for existence before insert when possible).

Testing & mocks
- Use `docs/postman_collection.json` for manual integration testing.
- Provide simple automated integration tests for critical flows: auth, courses list, enrollments, uploads.

Security & compliance checklist
- Hash passwords with bcrypt/argon2. Currently schema stores `password_hash` — assume salted strong hash.
- Rate-limit public endpoints (login, ai/chat) and file uploads.
- Validate and sanitize file uploads (size, type); store outside webroot / use presigned uploads.
- Ensure JWT secret is strong and rotated as needed.
- Secure DB credentials and secrets in a vault or environment variables, not in repo.

Deployment checklist
- Containerize the backend (Dockerfile) and provide a `docker-compose.yml` for local dev with MySQL and optionally MinIO for S3 emulation.
- Provide health endpoint `/health` and readiness/liveness probes for k8s.
- Add CI pipeline to run linters, unit tests, and integration tests against a test DB.

Open questions / items to clarify with frontend owner
- Confirm expected version of MySQL (5.7 vs 8.0) due to JSON usage.
- Confirm file size limits and accepted MIME types for lecture/assignment uploads.
- Confirm whether AI features use a paid provider (OpenAI/Anthropic) or local model.
- Confirm whether streaming responses are needed for AI Chat.
- Confirm retention / archival policy for user data (GDPR, retention periods).

Next recommended steps for the backend team
1. Clone repo, import schema to a dev MySQL instance via `backend/db/schema.sql`.
2. Scaffold chosen backend (Django REST Framework recommended per `backend/README.md`, or Node.js + Express + TypeORM).
3. Implement authentication (JWT) and user model mapping to the `users` table.
4. Implement core endpoints incrementally: courses → lectures → enrollments → assignments → tests → library → events → AI.
5. Add file upload handling (local dev storage + S3 production) and update frontend `baseUrl` for integration.
6. Run Postman collection to validate basic flows.

If you want, I can:
- Generate a concrete Postman environment with auth token automation.
- Scaffold a Docker Compose dev environment (backend + mysql + minio) and a sample `.env` file.

— End of handover
