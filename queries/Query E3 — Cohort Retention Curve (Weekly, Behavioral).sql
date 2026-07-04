with meaningful_sessions as (
    select distinct
         c.customer_id
        ,date_trunc('week', c.created_at) as cohort_week
        ,floor(
            extract(epoch from (s.started_at - c.created_at))
            / (86400 * 7)
        ) as week_index
    from ecom.customers c
    left join ecom.sessions s
        on c.customer_id = s.customer_id
    left join ecom.session_events se
        on s.session_id = se.session_id
        and lower(se.event_type) in (
             'product_view'
            ,'add_to_cart'
            ,'purchase'
        )
    where c.created_at >= date '2026-04-19'
        and se.session_id is not null
)

,cohort_size as (
    select
         date_trunc('week', created_at) as cohort_week
        ,count(distinct customer_id) as cohort_size
    from ecom.customers
    where created_at >= date '2026-04-19'
    group by 1
)

,retention as (
    select
         cohort_week
        ,week_index
        ,count(distinct customer_id) as retained_users
    from meaningful_sessions
    where week_index between 1 and 4
    group by
         cohort_week
        ,week_index
)

select
     cs.cohort_week
    ,cs.cohort_size
    ,cs.cohort_size as w0_active

    ,coalesce(max(case when r.week_index = 1 then r.retained_users end), 0) as w1_retained
    ,coalesce(max(case when r.week_index = 2 then r.retained_users end), 0) as w2_retained
    ,coalesce(max(case when r.week_index = 3 then r.retained_users end), 0) as w3_retained
    ,coalesce(max(case when r.week_index = 4 then r.retained_users end), 0) as w4_retained

    ,round(
        coalesce(max(case when r.week_index = 1 then r.retained_users end), 0)
        * 100.0
        / cs.cohort_size
    ,2) as w1_retention_rate

    ,round(
        coalesce(max(case when r.week_index = 2 then r.retained_users end), 0)
        * 100.0
        / cs.cohort_size
    ,2) as w2_retention_rate

    ,round(
        coalesce(max(case when r.week_index = 3 then r.retained_users end), 0)
        * 100.0
        / cs.cohort_size
    ,2) as w3_retention_rate

    ,round(
        coalesce(max(case when r.week_index = 4 then r.retained_users end), 0)
        * 100.0
        / cs.cohort_size
    ,2) as w4_retention_rate

from cohort_size cs
left join retention r
    on cs.cohort_week = r.cohort_week

group by
     cs.cohort_week
    ,cs.cohort_size

order by
     cs.cohort_week;
