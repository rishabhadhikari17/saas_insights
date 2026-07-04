-- select * from saas.subscription_events
-- where event_type='cancelled'

with account_events as (
  select account_id
  , event_time
  , event_type
  , mrr_delta
  from saas.subscription_events
  where lower(event_type) <> 'trial_started'
)

, cohorts as (
  select
    account_id
    ,date_trunc('month', min(event_time)) as cohort_month
  from account_events
  where lower(event_type) in ('subscription_started', 'trial_converted')
  group by account_id
)

, account_mrr_asof as (
  select
    ae.account_id
    ,c.cohort_month
    ,sum(ae.mrr_delta) filter (
      where ae.event_time < c.cohort_month + interval '1 month'
    ) as starting_mrr
    ,sum(ae.mrr_delta) filter (
      where ae.event_time < c.cohort_month + interval '13 months'
    ) as mrr_12m_later
  from account_events ae
  join cohorts c on c.account_id = ae.account_id
  group by ae.account_id, c.cohort_month
)

, account_buckets as (
  select
    account_id
    ,cohort_month
    ,starting_mrr
    ,mrr_12m_later
    ,case when mrr_12m_later > 0 then least(starting_mrr, mrr_12m_later) else 0 end as retained_mrr
    ,case when mrr_12m_later > 0 then greatest(mrr_12m_later - starting_mrr, 0) else 0 end as expansion_mrr
    ,case when mrr_12m_later > 0 then greatest(starting_mrr - mrr_12m_later, 0) else 0 end as contraction_mrr
    ,case when mrr_12m_later <= 0 then starting_mrr else 0 end as churn_mrr
  from account_mrr_asof
  where starting_mrr > 0                                    
    and cohort_month + interval '12 months' <= date '2026-06-15'
)

select
  cohort_month
  ,sum(starting_mrr) as cohort_starting_mrr
  ,sum(retained_mrr) as retained_mrr_12m
  ,sum(expansion_mrr) as expansion_mrr_12m
  ,sum(contraction_mrr) as contraction_mrr_12m
  ,sum(churn_mrr) as churn_mrr_12m
  ,round(sum(retained_mrr) / nullif(sum(starting_mrr), 0), 4) as grr
  ,round((sum(retained_mrr) + sum(expansion_mrr) - sum(contraction_mrr))/ nullif(sum(starting_mrr), 0), 4) as nrr
from account_buckets
group by cohort_month
order by cohort_month;
