-- Query S1 — Monthly MRR Movement Decomposition
-- How did MRR change last month — and what drove the change? New, expansion, contraction, or churn?


with mrr_buckets as (
select date_trunc('month',event_time) as month 
, case  when lower(event_type)='subscription_started'and exists(
select 1 from saas.subscription_events p 
where p.account_id = se.account_id
and p.event_type='cancelled'
and p.event_time < se.event_time
) then 'Reactivation MRR'
		when lower(event_type) in ('subscription_started','trial_converted') and mrr_delta> 0  then 'New MRR'
 		when lower(event_type) in ('plan_changed') and mrr_delta> 0 then 'Expansion MRR'
 		when lower(event_type) in ('seat_add','addon_attach') then 'Expansion MRR'
 		when lower(event_type) in ('plan_changed') and mrr_delta< 0 then 'Contraction MRR'
 		when lower(event_type) in ('cancelled') then 'Churn MRR' end as bucket
, mrr_delta
, event_type       
from saas.subscription_events se
where lower(event_type)<>'trial_started'
and event_time >= current_date - Interval '12 Months'
and event_time <= date'2026-06-15'
)
, monthly as (
select
month 
, sum(mrr_delta) filter(where bucket = 'New MRR') as new_mrr
, sum(mrr_delta) filter(where bucket = 'Expansion MRR') as expansion_mrr
, sum(mrr_delta) filter(where bucket = 'Contraction MRR') as contraction_mrr
, sum(mrr_delta) filter(where bucket = 'Churn MRR') as churn_mrr
, sum(mrr_delta) filter(where bucket = 'Reactivation MRR') as reactivation_mrr
, sum(mrr_delta) as net_new_mrr
, sum(mrr_delta) filter(where bucket is null) as unclassified_mrr
from mrr_buckets 
group by 1
)
select
month
, new_mrr
, expansion_mrr
, contraction_mrr
, churn_mrr
, reactivation_mrr
, net_new_mrr
, sum(net_new_mrr) over (order by month rows between unbounded preceding and current row) as ending_mrr
, coalesce(new_mrr,0) + coalesce(expansion_mrr,0) + coalesce(contraction_mrr,0)
  + coalesce(churn_mrr,0) + coalesce(reactivation_mrr,0) - net_new_mrr as reconciliation_gap
, unclassified_mrr
from monthly
order by month;




