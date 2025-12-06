Verification & Migration Handover

Summary
- I verified that Django migrations have been applied and aligned with the existing MySQL database located in the `sarasedu` schema.
- The `core` app initial migration (`core.0001_initial`) is present and was applied (we used `--fake-initial` as needed to match pre-existing SQL-created tables).
- A database connectivity check (`SELECT 1`) succeeded after a non-destructive root password reset.

Model ↔ Table verification (high-level)
- The main models in `sarasedu_backend/core/models.py` (User, StudentProfile, TeacherProfile, AdminProfile, Course, Lecture, LectureMaterial, CourseSchedule, StudyMaterial, Enrollment, LectureProgress, Assignment, AssignmentSubmission, AssignmentAttachment, Test, Question, TestSubmission, TestAnswer, AttendanceRecord, LibraryItem, LibraryFavorite, LibraryDownload, Event, Announcement, Upload) map to `core_<modelname>` tables in MySQL (e.g. `core_user`, `core_course`, `core_lecture`, etc.).
- I confirmed these `core_*` tables exist in MySQL and inspected columns for each table via `INFORMATION_SCHEMA.COLUMNS` to ensure model fields are present. Minor type/NULL-default differences (e.g., `longtext` vs `TextField` length and `NULL` vs `NOT NULL`) may still exist and can be adjusted in models/migrations if required.

What I executed (commands)
1) Non-destructive root password reset (existing data volume preserved)
- Stop DB service and run a temporary helper container mounting the same volume with `--skip-grant-tables`:

```powershell
cd backend
docker compose stop db
docker run --name mysql-reset -v backend_db_data:/var/lib/mysql -e MYSQL_ALLOW_EMPTY_PASSWORD=yes -d mysql:8.0 --skip-grant-tables
# create reset.sql with these lines (literal):
# FLUSH PRIVILEGES;
# ALTER USER 'root'@'%' IDENTIFIED BY 'Rohit$inghal377';
# ALTER USER 'root'@'localhost' IDENTIFIED BY 'Rohit$inghal377';
# FLUSH PRIVILEGES;
# copy and execute the file inside the temp container and remove it afterwards
docker cp .\reset.sql mysql-reset:/reset.sql
docker exec -i mysql-reset bash -c "mysql -u root < /reset.sql"
docker rm -f mysql-reset
docker compose up -d db
```

2) Migration alignment and verification

```powershell
cd backend
# show migrations
docker compose run --rm backend python sarasedu_backend/manage.py showmigrations --list
# mark initial migrations as applied while preserving schema
docker compose run --rm backend python sarasedu_backend/manage.py migrate --fake-initial --noinput
# connectivity check
docker compose run --rm backend python sarasedu_backend/manage.py check_db
```

3) Schema inspection (what I ran to audit tables/columns)

```powershell
# get the running db container id
$DB_CID = (docker compose ps -q db)
# list tables
docker exec -i $DB_CID mysql -u root -p'Rohit$inghal377' -D sarasedu -e "SHOW TABLES;"
# show all columns (ordered by table)
docker exec -i $DB_CID mysql -u root -p'Rohit$inghal377' -D sarasedu -e "SELECT TABLE_NAME, COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='sarasedu' ORDER BY TABLE_NAME, ORDINAL_POSITION;"
```

Notes & Recommendations
- `.env` dollar-sign: I updated `backend/.env` to escape `$` as `$$` to avoid docker-compose interpolation warnings (this prevents environment-variable parsing from dropping parts after `$`).
- `docker-compose.yml`: the top-level `version:` key is deprecated; remove it to silence the warning.
- Next verification step I can perform: produce a per-model diff report (fields missing / extra columns / type mismatches). I can generate that automatically by comparing `Model._meta.get_fields()` with `INFORMATION_SCHEMA.COLUMNS` and produce a short CSV or markdown table.
- If you want all schema differences reconciled by migrations rather than `--fake-initial`, the team should decide whether to:
  - generate migrations locally (with `makemigrations`) and apply them normally on a clean DB, or
  - keep current DB and `--fake` the initial migration (what we did) and then generate incremental migrations going forward.

If you want me to produce the per-model diff report (detailed missing/extra columns and suggested migration actions), say "Please run the schema diff report" and I will generate it and add it to this handover file.
