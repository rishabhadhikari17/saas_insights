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


# Interpretations:
- Data in the legacy tables is already present in the other tables
- 
# event Table
- Details of events associated with a particular feature_id and account_id

# payment_attempts
- Details of the attempts by the users for the payments with the attempt number and the status

# invoices
- Stores Invoive related data associated with each account_id

# subscription_events
- Most used table,  user level event data is present in this table.
<img width="1162" height="241" alt="image" src="https://github.com/user-attachments/assets/0635c18f-48ff-4291-9861-dc8e449bfd55" />

# email_sends
- Stores data for the emails, sent to the users for different marketing campaign (so that users can convert from this)

# experiment_assignments
- Stores data for different experiments conducted (A/B testing)

# users
- user level data who have used the product or are using the product

# saas.subscriptions
- details of the subscription status of subscription_id asscosicated with each user and their plan changes

# seats
- Stores data for each seat_id with their activated_at and deactivated_at

# accounts
- Stores the data for each account_id (their metadata like source of acquisition, account_type)

# support_tickets
- stores data for each support ticket raised, its severity and csat

# trials
- stores data for the each trial started and its converted subscription_id

# features
- has data of each feature and its release

# experiment_variants
- stores data for the variants used in the experiments

# plans
- plans description

# experiments
- experiment level data
