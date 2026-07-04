with product_info as (
select
p.product_id
, p.product_name
, c.category_name
from ecom.products p 
left join ecom.categories c 
on p.category_id = c.category_id
)
, product_metrics as (
select product_id
, Count ( distinct case when lower(event_type)='product_view' then session_id end) as views_sessions
, Count( distinct case when lower(event_type)='add_to_cart' then session_id end )as add_to_cart_sessions
from ecom.session_events
group by 1
)
, product_details as (
select 
pi.product_id
, pi.product_name
, pi.category_name
, pm.views_sessions
, pm.add_to_cart_sessions
from product_info pi 
left join 
product_metrics pm
on pi.product_id = pm.product_id
)
, product_rates as (
select product_id
, product_name
, category_name
, views_sessions as views
, add_to_cart_sessions
, case when coalesce(views_sessions,0)=0 then 0
else add_to_cart_sessions::numeric/ views_sessions end as atc_rate 
from product_details
where views_sessions>0
)
, category_medians as (
select 
category_name
, PERCENTILE_CONT(0.5) within group(order by atc_rate) as category_medain_atc
from product_rates
group by 1
)
, ranked as (
select 
pr.product_id
, pr.product_name
, pr.category_name
, pr.views
, pr.add_to_cart_sessions
, pr.atc_rate
, pr.atc_rate - cm.category_medain_atc as atc_rate_vs_category_median
, rank() over(order by pr.views desc) as views_rank
, rank() over(order by pr.atc_rate asc) as atc_rate_rank
from product_rates pr
left join category_medians cm on pr.category_name = cm.category_name
)
select *
from ranked 
where atc_rate_vs_category_median<0
order by views desc , atc_rate asc
limit 10
