-- Query S4 — Feature Adoption vs Retention
-- Which product features predict 90-day retention? Which are red herrings?

with account_lifecycle as (
  select
    account_id
    ,min(start_date) as signup_date
    ,(array_agg(cancelled_at order by start_date desc))[1] as cancelled_at
  from saas.subscriptions
  group by account_id
)

, eligible_accounts as (
  select
    account_id
    ,signup_date
    ,(cancelled_at is null 
     or cancelled_at > signup_date + interval '90 days') as retained_90d
  from account_lifecycle
  where signup_date <= current_date - interval '90 days'
)

, adoption as (
  select
    e.account_id
    ,e.feature_id
    ,count(*) as use_count
  from saas.events e
  join eligible_accounts ea on ea.account_id = e.account_id
  where lower(e.event_type) = 'feature_use'
    and e.feature_id is not null                      
    and e.occurred_at between ea.signup_date and ea.signup_date + interval '14 days'
  group by 1, 2
  having count(*) >= 1                                  
)

, feature_flags as (
  select
    f.feature_id
    ,f.feature_name
    ,ea.account_id
    ,ea.retained_90d
    ,(a.account_id is not null) as adopted
  from eligible_accounts ea
  cross join saas.features f
  left join adoption a
    on a.account_id = ea.account_id
    and a.feature_id = f.feature_id
)
select
  feature_name
  ,sum(case when adopted then 1 else 0 end) as accounts_adopted
  ,sum(case when not adopted then 1 else 0 end) as accounts_not_adopted
  ,round(sum(case when adopted and retained_90d then 1 else 0 end)::numeric
        / nullif(sum(case when adopted then 1 else 0 end), 0), 3) as retention_rate_adopted
  ,round(sum(case when not adopted and retained_90d then 1 else 0 end)::numeric
        / nullif(sum(case when not adopted then 1 else 0 end), 0), 3) as retention_rate_not_adopted
  ,round(
    (sum(case when adopted and retained_90d then 1 else 0 end)::numeric
       / nullif(sum(case when adopted then 1 else 0 end), 0))
    - (sum(case when not adopted and retained_90d then 1 else 0 end)::numeric
       / nullif(sum(case when not adopted then 1 else 0 end), 0)), 3
  ) as retention_lift_pp
  ,round(
    ((sum(case when adopted and retained_90d then 1 else 0 end)::numeric
        / nullif(sum(case when adopted then 1 else 0 end), 0))
     - (sum(case when not adopted and retained_90d then 1 else 0 end)::numeric
        / nullif(sum(case when not adopted then 1 else 0 end), 0)))
    / nullif(sum(case when not adopted and retained_90d then 1 else 0 end)::numeric
        / nullif(sum(case when not adopted then 1 else 0 end), 0), 0), 3
  ) as retention_lift_pct
from feature_flags
group by feature_name
order by retention_lift_pp desc;

