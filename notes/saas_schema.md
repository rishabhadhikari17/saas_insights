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

<img width="344" height="529" alt="image" src="https://github.com/user-attachments/assets/bb3b0ccc-90e6-4b5c-9dcf-6d078ed46db5" />


Interpretations:
Data in the legacy tables is already present in the other tables
Subscription_events --> Most used table,  user level event data is present in this table.

<img width="1162" height="241" alt="image" src="https://github.com/user-attachments/assets/0635c18f-48ff-4291-9861-dc8e449bfd55" />

