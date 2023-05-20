create view months as (
    select to_char(dd, 'YYYY-mm') as month
    from generate_series(
    (select min(date_trunc('month', created)) from purchases)::timestamp,
    (select max(date_trunc('month', created)) from purchases)::timestamp,
    '1 month'
    ) as dd
    order by 1);
   
    create view region_sales_per_channel as (
    select 
    r.id,
    r.title,
    p.channel,
    coalesce(sum(p.product_price), 0) as total,
    to_char(p.created, 'YYYY-mm') as month
    from regions r
    left join offices o on r.id = o.region_id
    left join managers m on o.id = m.office_id
    left join purchases p on m.id = p.manager_id
    where p.channel is not null
    and p.channel <> 'unknown'
    group by r.id, r.title, p.channel, month
    order by r.id
);

select distinct
	m.month,
	r.id as region_id,
	r.title as region_title,
	(
	    select rspc.channel
	    from region_sales_per_channel as rspc
	    where rspc.id = r.id
	    and rspc.month = m.month
	    order by rspc.total desc
	    limit 1
	) as channel,
	coalesce(
			    (
			        select max(rspc.total)
			        from region_sales_per_channel as rspc
			        where rspc.id = r.id
			        and rspc.month = m.month
			    ), 0
			) as total
from 
months as m
cross join regions as r
full outer join region_sales_per_channel as rspc on rspc.id = r.id
order by m.month, r.id
limit 50
;