-- Query S2 — Trial-to-Paid Conversion by Cohort
-- Of accounts that started a trial in week W, what fraction converted to paid by day 14, 30, 60?


with first_trials as (
  select *,
         row_number() over (partition by account_id order by started_at) as rn
  from saas.trials
)
,  trial_to_convert as (
  select 
    date_trunc('week', started_at) as trial_week
    , account_id
    , extract(day from converted_at - started_at) as days_to_convert
  from first_trials
  where rn = 1
)
, agg as (
  select
    trial_week
    , count(account_id) as trials_started
    , sum(case when days_to_convert <= 14 then 1 else 0 end) as converted_by_14d
    , sum(case when days_to_convert <= 30 then 1 else 0 end) as converted_by_30d
    , sum(case when days_to_convert <= 60 then 1 else 0 end) as converted_by_60d
    , percentile_cont(0.5) within group (order by days_to_convert) 
        filter (where days_to_convert is not null) as median_days_trial_to_paid
  from trial_to_convert
  group by 1
)
select
  trial_week
  , trials_started
  , converted_by_14d
  , converted_by_30d
  , converted_by_60d
  , round(converted_by_14d::numeric / nullif(trials_started,0), 3) as conv_rate_14d
  , round(converted_by_30d::numeric / nullif(trials_started,0), 3) as conv_rate_30d
  , round(converted_by_60d::numeric / nullif(trials_started,0), 3) as conv_rate_60d
  , median_days_trial_to_paid
  , extract(day from current_date - trial_week) >= 60 as window_60d_complete
from agg
order by trial_week;
