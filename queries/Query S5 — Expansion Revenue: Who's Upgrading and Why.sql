-- Query S1 — Monthly MRR Movement Decomposition
-- How did MRR change last month — and what drove the change? New, expansion, contraction, or churn?

with expansion_events as (
select 
account_id,
case when lower(event_type) = 'seat_add' then 'seat_added'
	 when lower(event_type)= 'addon_attach' then  'addon'
	 when lower(event_type)='plan_changed' and mrr_delta>0 then 'plan_upgraded' end as expansion_buckets
,mrr_delta
,extract(day from (event_time - signup_date)) as days_to_convert
from saas.accounts 
join
saas.subscription_events using (account_id)
where event_time> current_date - interval '6 Months'
and event_time <= date '2026-06-15'
)
select expansion_buckets
, count(*) as expansion_events
, count(distinct account_id) as accounts_expanded
, sum(mrr_delta) as expansion_mrr_total
, sum(mrr_delta)::numeric/count(distinct account_id)::numeric as expansion_mrr_per_account
, percentile_cont(0.5) within group (order by days_to_convert) as median_days_to_convert
from expansion_events
where expansion_buckets in ('seat_added','addon','plan_upgraded')
group by 1
