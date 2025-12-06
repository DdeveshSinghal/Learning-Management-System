# backend

This folder is reserved for backend work (Django + MySQL recommended).

What's included:
- `backend/db/schema.sql` — small loader that references the MySQL schema and sample seed files in `docs/`.

Next recommended steps for backend team:
- Create a Python virtual environment and start a Django project: `django-admin startproject sarasedu_backend`.
- Add Django REST Framework and configure MySQL connector (`mysqlclient` or `mysql-connector-python`).
- Create Django models based on `docs/mysql_schema.sql` and generate migrations.
- Import seed data using the `docs/` SQL files or load fixtures from Django.
 
Quick start (Docker Compose - dev)

1. Copy `.env.example` to `.env` and edit values.

```powershell
cd backend
cp .env.example .env
docker-compose up --build
```

2. The backend will be available at `http://localhost:8000` and the API base path is `/api/`.

Local Python dev environment (without Docker)

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
cd sarasedu_backend
python manage.py migrate
python manage.py createsuperuser
python manage.py runserver
```

Project scaffold included:
- `sarasedu_backend/` — Django project
- `core/` — example app with `User` (custom) and `Course` models, basic auth (JWT) and courses endpoints to match frontend expectations.

Next steps for backend team:
- Expand models to match `backend/database/schema.sql` and generate migrations.
- Implement file uploads (S3/MinIO) and other endpoints per `docs/openapi.yaml`.
- Add tests, CI, and production settings.

Seeding the database

The repo includes a management command to import the SQL sample data file into the configured database:

```powershell
cd backend
# Ensure DB is running and settings point to it, then run:
cd sarasedu_backend
python manage.py seed_db
```

Notes about migrations

To produce accurate migrations for your environment run:

```powershell
cd backend\sarasedu_backend
python manage.py makemigrations
python manage.py migrate
```

I didn't auto-generate migration files in the repo because running `makemigrations` locally ensures Django sets up the auth user model and dependency ordering correctly for your environment.

Migrations
----------
This repository now includes a conventional Django initial migration for the `core` app at `core/migrations/0001_initial.py` that uses `CreateModel` operations for the main models. The migration has been created with dependencies on Django's `auth` and `contenttypes` initial migrations to ensure correct ordering in most environments.

Recommended workflow for new environments:

```powershell
cd backend\sarasedu_backend
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r ../requirements.txt
python manage.py migrate
python manage.py createsuperuser
```

If you already have an existing database created from the SQL files in `docs/` (or `backend/database/schema.sql`), adopt one of these approaches:
- Run the migration and then `python manage.py migrate --fake core 0001_initial` to mark the initial migration as applied without altering the schema.
- Alternatively, run `python manage.py makemigrations` locally to generate migrations that match your models, and coordinate with the team on whether to `--fake` or adjust applied migrations.

If you want me to regenerate migrations (for example to split/simplify operations, add explicit indexes, or adapt to a specific Django version), tell me which approach you prefer and I will update the migration files.
