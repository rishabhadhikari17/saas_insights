with funnel_steps as (
select 
s.session_id
, sc.channel
, max(case  when lower(se.event_type)='begin_checkout' then 1 
		when lower(se.event_type)='add_address' then 2
		when lower(se.event_type)='select shipping' then 3
		when lower(se.event_type)='add_payment' then 4
		when lower(se.event_type)='purchase' then 5
		else 0 end) as max_step
from ecom.sessions s
join ecom.session_channels sc using (session_id)
join ecom.session_events se using (session_id)
group by 1,2
)
, funnel_metrics as (
select channel
, count(*) filter(where max_step>=1) as begin_checkout
, count(*) filter(where max_step>=2) as add_address
, count(*) filter(where max_step>=3) as select_shipping
, count(*) filter(where max_step>=4) as add_payment
, count(*) filter(where max_step>=5) as purchase
from funnel_steps
where max_step>=1 
group by 1
order by begin_checkout desc
)
select channel
, begin_checkout
, add_address
, select_shipping
, add_payment
, purchase
, 1-(add_address::numeric/begin_checkout::numeric) as drop_address_pct
, 1-(select_shipping::numeric/add_address::numeric) as drop_shipping_pct
, 1-(add_payment::numeric/select_shipping::numeric) as drop_payment_pct
, 1-(purchase::numeric/add_payment::numeric) as drop_final_pct
from funnel_metrics
