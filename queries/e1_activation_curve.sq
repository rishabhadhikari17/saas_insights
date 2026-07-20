-- Query E1 — Activation Curve: Time-to-First-Meaningful-Action
-- How fast do new signups become real users, and how has that changed cohort-over-cohort?

with cohort_signups as (
select
customer_id
, created_at
, date_trunc('week',created_at) as signup_week
from ecom.customers
where created_at>= date '2026-04-19'
)
,meaningful_actions as (
select se.customer_id
,min(se.occurred_at) as first_meaningful_action
from ecom.session_events se
join ecom.customers c
on se.customer_id = c.customer_id
where lower(event_type) in ('add_to_cart','begin_checkout','purchase')
and se.customer_id is not null
and se.occurred_at>=c.created_at
group by 1
)
, base_info as (
select cs.customer_id
, cs.signup_week
, ma.first_meaningful_action
, case when ma.first_meaningful_action <= cs.created_at +Interval '7 Days' then ma.first_meaningful_action end as activated_at
, case when ma.first_meaningful_action<= cs.created_at + interval '7 days' then extract (epoch from (ma.first_meaningful_action-cs.signup_week))/60.0 end as minutes_to_activation
from cohort_signups cs 
left join meaningful_actions ma
on cs.customer_id = ma.customer_id
)
select 
signup_week
, count(*) as cohort_size
, count(activated_at) as activated_7d
, count(activated_at)::numeric/count(*)::numeric as activation_rate_7d
, percentile_cont(0.5) within group (order by minutes_to_activation) as median_minutes_to_activation
, percentile_cont(0.9) within group (order by minutes_to_activation) as p90_minutes_to_activation
from base_info
group by 1
order by 1
