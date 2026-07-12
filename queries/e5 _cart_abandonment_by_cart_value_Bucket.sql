-- Query E5 — Cart Abandonment by Cart Value Bucket
-- Cart abandonment is 70% overall — but is it the same for ₹500 carts as ₹15,000 carts? Where do we lose the most rupees?

with sessions as (
select session_id
, lower(event_type) event_name
, quantity*unit_price as cart_value 
from ecom.session_events
where lower(event_type) in ('add_to_cart','purchase')
)
,session_cart_values as (
select session_id
,event_name
,sum(cart_value) over(partition by session_id) as cart_value
from sessions
)
, cart_buckets as (
select session_id
, event_name
, cart_value
, case  when cart_value <500 then '<500'
		when cart_value >=500 and cart_value <2000 then '500-1999'
		when cart_value >=2000 and cart_value <5000 then '2000-4999'
		when cart_value >=5000 and cart_value <15000 then '5000-14999'
		else '15000+' end as cart_bucket
from session_cart_values
)
, add_to_cart_sessions as (
select cart_bucket
, count(session_id) as atc_sessions
, sum(cart_value) as gmv_atc
from cart_buckets
where event_name = 'add_to_cart'
group by 1
)
, purchased_sessions as (
select cart_bucket
, count(session_id) as purchased_sessions
, sum(cart_value) as gmv_purchased
from cart_buckets
where event_name = 'purchase'
group by 1
)
, cart_metrics as (
select atc.cart_bucket
, atc.atc_sessions
, atc.gmv_atc
, ps.purchased_sessions
, ps.gmv_purchased
from add_to_cart_sessions atc
left join purchased_sessions ps 
on atc.cart_bucket = ps.cart_bucket
)
select cart_bucket
,atc_sessions
,purchased_sessions
, atc_sessions-purchased_sessions as abandoned_sessions
, 1-(purchased_sessions::numeric/atc_sessions::numeric) as abandoment_rate
, gmv_atc-gmv_purchased as gmv_left_on_table
from cart_metrics


-- select distinct session_id 
-- select * from ecom.session_events
-- where order_id=30175

-- select * from ecom.order_items
-- where order_id = 30175

-- with sessions as (
-- select 
-- session_id
-- , lower(event_type) as event_name
-- , quantity
-- , unit_price
-- , quantity*unit_price as cart_value
-- from ecom.session_events
-- where lower(event_type) in ('add_to_cart','purchase')
-- )
-- , cart_buckets as (
-- select session_id
-- , event_name
-- , cart_value
-- , case  when cart_value <500 then '<500'
-- 		when cart_value >=500 and cart_value <2000 then '500-1999'
-- 		when cart_value >=2000 and cart_value <5000 then '2000-4999'
-- 		when cart_value >=5000 and cart_value <15000 then '5000-14999'
-- 		else '15000+' end as cart_bucket
-- from sessions
-- )
-- , add_to_cart_sessions as (
-- select cart_bucket
-- , count(session_id) as atc_sessions
-- , sum(cart_value) as gmv_atc
-- from cart_buckets
-- where event_name = 'add_to_cart'
-- group by 1
-- )
-- , purchased_sessions as (
-- select cart_bucket
-- , count(session_id) as purchased_sessions
-- , sum(cart_value) as gmv_purchased
-- from cart_buckets
-- where event_name = 'purchase'
-- group by 1
-- )
-- select atc.cart_bucket
-- , atc.atc_sessions
-- , atc.gmv_atc
-- , ps.purchased_sessions
-- , ps.gmv_purchased
-- from add_to_cart_sessions atc
-- left join purchased_sessions ps 
-- on atc.cart_bucket = ps.cart_bucket



