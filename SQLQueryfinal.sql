Select * from dbo.fact_events;
Select * from dbo.dim_campaigns;
Select * from dbo.dim_products;
Select * from dbo.dim_stores;
--Preprocessing--
select distinct product_code from dbo.fact_events;


--Query1--
Select distinct p1.product_name,f1.promo_type,f1.base_price from dbo.fact_events f1 inner join dbo.dim_products p1
on f1.product_code=p1.product_code 
where f1.base_price>500 and f1.promo_type='BOGOF';

--Query2--
select s1.city,count(s1.store_id) as city_wise_store_count from dbo.dim_stores s1
group by s1.city;

--Query3--
with fact_events_new as(
select *,Round(Case when f1.promo_type='500 Cashback' then f1.base_price-500
when f1.promo_type='BOGOF' then f1.base_price*0.5
when f1.promo_type='25% OFF' then f1.base_price*0.75
when f1.promo_type='50% OFF' then f1.base_price*0.5
when f1.promo_type='33% OFF' then f1.base_price*0.66
end,2) as promo_price
from dbo.fact_events f1),

 b as(
select c1.campaign_name,SUM(f1.quantity_sold_before_promo) as before_promo,
SUM(f1.quantity_sold_after_promo)as after_promo
from dbo.dim_campaigns c1
inner join
fact_events_new f1
on c1.campaign_id=f1.campaign_id
group by c1.campaign_name
)

SELECT b.campaign_name,f2.promo_type,CONCAT(FORMAT(SUM((b.before_promo*f2.base_price)/1000000),'N'),'M') as before_promo_revenue,
CONCAT(FORMAT(SUM(Case when f2.promo_type='BOGOF' 
then ((b.after_promo*2*f2.promo_price)/1000000)
else ((b.after_promo*f2.promo_price)/1000000)end),'N'),'M')as after_promo_revenue from b  join dim_campaigns c2
on b.campaign_name=c2.campaign_name
inner join fact_events_new f2
on c2.campaign_id=f2.campaign_id
group by b.campaign_name,f2.promo_type;


--query4--
With a as(
select c1.campaign_name as campaign_name,p1.category as category,(SUM(f1.quantity_sold_after_promo)-
SUM(f1.quantity_sold_before_promo))*100/SUM(f1.quantity_sold_before_promo) as ISU_percentage
from dbo.dim_campaigns c1
inner join
dbo.fact_events f1
on c1.campaign_id=f1.campaign_id
inner join
dbo.dim_products p1
on f1.product_code=p1.product_code
group by p1.category,c1.campaign_name
)
select category,campaign_name,ISU_percentage,rank()over(partition by campaign_name order by ISU_percentage) as ranking from a;

--query5--

with fact_events_new as(
select *,Round(Case when f1.promo_type='500 Cashback' then f1.base_price-500
when f1.promo_type='BOGOF' then f1.base_price*0.5
when f1.promo_type='25% OFF' then f1.base_price*0.75
when f1.promo_type='50% OFF' then f1.base_price*0.5
when f1.promo_type='33% OFF' then f1.base_price*0.66
end,2) as promo_price
from dbo.fact_events f1),

 b as(
select p1.product_name,sum(f1.quantity_sold_before_promo) as before_promo,
SUM(f1.quantity_sold_after_promo)as after_promo
from dbo.dim_products p1
right join
fact_events_new f1
on p1.product_code=f1.product_code
group by p1.product_name
),

c as
(SELECT b.product_name,sUM((b.before_promo*f2.base_price)/1000000) as before_promo_revenue,
(SUM(Case when f2.promo_type='BOGOF' 
then ((b.after_promo*2*f2.promo_price)/1000000)
else (b.after_promo*f2.promo_price)/1000000 end))as after_promo_revenue from b  left join dim_products p2
on b.product_name=p2.product_name
right join fact_events_new f2
on p2.product_code=f2.product_code
group by b.product_name)

select top 5* from (select product_name,(after_promo_revenue-before_promo_revenue)/(before_promo_revenue+1) as IR from c )a order by a.IR desc;