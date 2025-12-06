-- SarasEduHub — Combined schema loader
-- This file references the MySQL-ready schema and sample seed files in the same `docs/` directory.
-- To import using the MySQL CLI, two options:
-- 1) Run the schema and seed files separately:
--    mysql -u <user> -p < docs/mysql_schema.sql
--    mysql -u <user> -p < docs/sample_data_mysql.sql
-- 2) Use the MySQL client to SOURCE this loader (recommended when using the interactive mysql prompt):
--    mysql -u <user> -p
--    SOURCE full_schema_and_seed.sql

-- The loader below uses SOURCE so the client will execute both files in order.
SOURCE ./mysql_schema.sql;
SOURCE ./sample_data_mysql.sql;

-- Notes:
-- - Run inside the `docs/` directory or adjust paths appropriately when sourcing.
-- - If you need a single monolithic file, let me know and I'll concatenate the SQL into one file (includes trigger DELIMITER handling).
-- End of loader
