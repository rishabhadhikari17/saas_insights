# All Tables
SELECT table_name, column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'saas'
ORDER BY table_name, ordinal_position;

<img width="712" height="3841" alt="image" src="https://github.com/user-attachments/assets/d769af5a-eb8c-44a8-b21d-26d5c71b5482" />


# Total Rows in each table
SELECT relname AS table_name, n_live_tup AS approx_row_count
FROM pg_stat_user_tables
WHERE schemaname = 'saas'
ORDER BY n_live_tup DESC;

<img width="161" height="529" alt="image" src="https://github.com/user-attachments/assets/3085942c-2cf7-4f4d-944c-62e01c26918b" />


