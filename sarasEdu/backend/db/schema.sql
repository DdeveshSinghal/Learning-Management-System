-- SarasEduHub Backend DB Schema Loader
-- This file exists so backend developers can quickly import the schema and seed data.
-- It references the files in the project's `docs/` folder. From the repo root run:
--    cd backend/db
--    mysql -u <user> -p < schema.sql

SOURCE ../../docs/mysql_schema.sql;
SOURCE ../../docs/sample_data_mysql.sql;

-- If you want a single-file copy here, tell me and I will create it (it will include DELIMITER blocks for triggers).
