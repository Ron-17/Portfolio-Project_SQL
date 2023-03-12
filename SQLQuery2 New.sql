



----What was the best month for sales in a specific year? How much was earned that month? 
select  MONTH_ID, sum(sales) Revenue, count(ORDERNUMBER) Frequency
from [Portfolio].[dbo].[sales_data_sample]
where YEAR_ID = 2004 --change year to see the rest
group by  MONTH_ID
order by 2 desc


--November seems to be the month, what product do they sell in November, Classic I believe
select  MONTH_ID, PRODUCTLINE, sum(sales) Revenue, count(ORDERNUMBER)
from [Portfolio].[dbo].[sales_data_sample]
where YEAR_ID = 2004 and MONTH_ID = 11 --change year to see the rest
group by  MONTH_ID, PRODUCTLINE
order by 3 desc


----Who is our best customer (this could be best answered with RFM)


DROP TABLE IF EXISTS #rfm
;with rfm as 
(
	select 
		CUSTOMERNAME, 
		sum(sales) MonetaryValue,
		avg(sales) AvgMonetaryValue,
		count(ORDERNUMBER) Frequency,
		max(ORDERDATE) last_order_date,
		DATEDIFF(DD, max(ORDERDATE), (select max(ORDERDATE) from [Portfolio].[dbo].[sales_data_sample])) Recency
	from [Portfolio].[dbo].[sales_data_sample]
	group by CUSTOMERNAME
),
rfm_calc as
(

	select r.*,
		NTILE(4) OVER (order by Recency desc) rfm_recency,
		NTILE(4) OVER (order by Frequency) rfm_frequency,
		NTILE(4) OVER (order by MonetaryValue) rfm_monetary
	from rfm r
)
select 
	c.*, rfm_recency+ rfm_frequency+ rfm_monetary as rfm_cell,
	cast(rfm_recency as varchar) + cast(rfm_frequency as varchar) + cast(rfm_monetary  as varchar)rfm_cell_string
into #rfm
from rfm_calc c

select CUSTOMERNAME , rfm_recency, rfm_frequency, rfm_monetary,
	case 
		when rfm_cell_string in (111, 112 , 121, 122, 123, 132, 211, 212, 114, 141) then 'lost_customers'  --lost customers
		when rfm_cell_string in (133, 134, 143, 244, 334, 343, 344, 144) then 'slipping away, cannot lose' -- (Big spenders who haven’t purchased lately) slipping away
		when rfm_cell_string in (311, 411, 331) then 'new customers'
		when rfm_cell_string in (222, 223, 233, 322) then 'potential churners'
		when rfm_cell_string in (323, 333,321, 422, 332, 432) then 'active' --(Customers who buy often & recently, but at low price points)
		when rfm_cell_string in (433, 434, 443, 444) then 'loyal'
	end rfm_segment

from #rfm


SELECT * FROM [Portfolio].[dbo].[sales_data_sample];
----Correlation Between Products

with a as(
Select d1.CUSTOMERNAME as CUSTOMERNAME,d1.PRODUCTLINE as first_product,d2.PRODUCTLINE as second_product from [Portfolio].[dbo].[sales_data_sample] d1 inner join [Portfolio].[dbo].[sales_data_sample] d2
on d1.ORDERNUMBER<d2.ORDERNUMBER and d1.PRODUCTLINE<> d2.PRODUCTLINE and d1.CUSTOMERNAME=d2.CUSTOMERNAME  where DATEDIFF(SECOND,d1.ORDERDATE,D2.ORDERDATE)<10),
b as(Select a.CUSTOMERNAME,a.first_product as first_product,a.second_product  as second_product,count(*) as Correlation_Count from a group by a.first_product,a.second_product,a.CUSTOMERNAME)




SELECT *,rank()over(partition by b.CUSTOMERNAME order by b.Correlation_Count desc) as rnk from b;






