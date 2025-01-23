USE [TEST_DATABASE]
GO

SELECT [pizza_id]
      ,[order_id]
      ,[pizza_name_id]
      ,[quantity]
      ,[order_date]
      ,[order_time]
      ,[unit_price]
      ,[total_price]
      ,[pizza_size]
      ,[pizza_category]
      ,[pizza_ingredients]
      ,[pizza_name]
  FROM [dbo].[Pizza_Sales]

GO

alter table [dbo].[Pizza_Sales]
alter column [quantity] int

alter table [dbo].[Pizza_Sales]
alter column [unit_price] int

alter table [dbo].[Pizza_Sales]
alter column [total_price] int


--1	Total Revenue
select SUM([quantity]*[unit_price]) as total_rev
from [dbo].[Pizza_Sales]


--2	Total Pizzas Sold
select	COUNT([order_id]) as [No of Orders],
		SUM([quantity]) as [No of Pizzas Sold]
from [dbo].[Pizza_Sales]

--3	How many order Veggie pizza category was sold

select	SUM([quantity]) as [Veggie Sold],
		SUM([quantity]*[unit_price]) as [Rev from Veggie Pizzas]
from [dbo].[Pizza_Sales]
where [pizza_category]='Veggie'

-- 4 top 10 pizzas
select	top 10 [pizza_name],
		sum([quantity]*[total_price]) as [revenue]
from [dbo].[Pizza_Sales]
group by [pizza_name]
order by [revenue] desc

-- 5 revenue from the top 10 pizzas
select	sum([revenue]) as [Rev of Top 10]
from (
select	top 10 [pizza_name],
		sum([quantity]*[total_price]) as [revenue]
from [dbo].[Pizza_Sales]
group by [pizza_name]
order by [revenue] desc
) A

-- 6 % of Top 10 Revenue
with T10 as (
select	sum([revenue]) as [Rev of Top 10]
from (
select	top 10 [pizza_name],
		sum([quantity]*[total_price]) as [revenue]
from [dbo].[Pizza_Sales]
group by [pizza_name]
order by [revenue] desc
) A
),
T32 as (
select	sum([revenue]) as [Total Rev]
from (
select	[pizza_name],
		sum([quantity]*[total_price]) as [revenue]
from [dbo].[Pizza_Sales]
group by [pizza_name]
) B
)
select (T10.[Rev of Top 10]*1.0/T32.[Total Rev])*100 as [T10 % of Total Rev]
from T10 join T32
on 1=1

-- 7 the least performing Pizza
select top 5	[pizza_name],
				sum([quantity]*[total_price]) as [Total Rev]
from [dbo].[Pizza_Sales]
group by [pizza_name]
order by [Total Rev] asc

-- 8 Total Revenue of 5 Least Performing Pizza
select sum([Total Rev]) as [Total Rev Least Perf Pizzas]
from (
select top 5	[pizza_name],
				sum([quantity]*[total_price]) as [Total Rev]
from [dbo].[Pizza_Sales]
group by [pizza_name]
order by [Total Rev] asc
) A

-- 9 % Total Revenue of 5 Least Performing Pizza
with L5 as (
select sum([Total Rev]) as [Total Rev Least Perf Pizzas]
from (
select top 5	[pizza_name],
				sum([quantity]*[total_price]) as [Total Rev]
from [dbo].[Pizza_Sales]
group by [pizza_name]
order by [Total Rev] asc
) A
),
T32 as (
select sum([Total Rev]) as [Final Rev]
from (
select [pizza_name],
		sum([quantity]*[total_price]) as [Total Rev]
from [dbo].[Pizza_Sales]
group by [pizza_name]
) B
)
select ([Total Rev Least Perf Pizzas]*1.0/[Final Rev])*100 as [% Rev of L5]
from L5
join T32
on 1=1


-- 8 Best performing months
select top 3	[month],
				[Revenue]
from (
select	format([order_date], 'yyyy-MM') as [month],
		sum([quantity]*[total_price]) as [Revenue]
from [dbo].[Pizza_Sales]
group by format([order_date], 'yyyy-MM')
) A
order by [Revenue] desc

-- 9 least performing months
select top 3	[month],
				[Revenue]
from (
select	format([order_date], 'yyyy-MM') as [month],
		sum([quantity]*[total_price]) as [Revenue]
from [dbo].[Pizza_Sales]
group by format([order_date], 'yyyy-MM')
) A
order by [Revenue] asc

-- 10 the top 3 pizzas bought during highest performing months
with mRev as (
select	format([order_date], 'yyyy-MM') as [month],
		sum([quantity]*[total_price]) as [total revenue]
from [dbo].[Pizza_Sales]
group by format([order_date], 'yyyy-MM')
),
T3M as (
select top 3 [month]
from mRev	
order by [total revenue] desc
),
pRev as (
select	p.[pizza_name], 
		format(p.[order_date], 'yyyy-MM') as [month],
		sum(p.[quantity]*p.[total_price]) as [revenue]
from [dbo].[Pizza_Sales] p
where format(p.[order_date], 'yyyy-MM') in (select [month]
												from T3M)
group by format(p.[order_date], 'yyyy-MM'), p.[pizza_name]
),
pizza_rank as (
select	[month],
		[pizza_name],
		[revenue],
		rank() over(partition by [month] order by [revenue] desc) as [rank]
from pRev
)
select 	[month],
		[pizza_name],
		[revenue]
from pizza_rank
where [rank] <= 3
order by [month], [rank]

-- 11 The best pizzas and their total revenues for the top 3 months
with mRev as (
select	format([order_date], 'yyyy-MM') as [month],
		sum([quantity]*[total_price]) as [total revenue]
from [dbo].[Pizza_Sales]
group by format([order_date], 'yyyy-MM')
),
T3M as (
select top 3 [month]
from mRev	
order by [total revenue] desc
),
pRev as (
select	p.[pizza_name], 
		format(p.[order_date], 'yyyy-MM') as [month],
		sum(p.[quantity]*p.[total_price]) as [revenue]
from [dbo].[Pizza_Sales] p
where format(p.[order_date], 'yyyy-MM') in (select [month]
												from T3M)
group by format(p.[order_date], 'yyyy-MM'), p.[pizza_name]
),
pizza_rank as (
select	[month],
		[pizza_name],
		[revenue],
		rank() over(partition by [month] order by [revenue] desc) as [rank]
from pRev
)
select 	[pizza_name],
		sum([revenue]) as [top revenue]
from pizza_rank
where [rank] <= 3
group by [pizza_name]
order by [top revenue] desc


-- 11 the top 3 pizzas bought during lowest performing months
with mRev as (
select	format([order_date], 'yyyy-MM') as [month],
		sum([quantity]*[total_price]) as [total revenue]
from [dbo].[Pizza_Sales]
group by format([order_date], 'yyyy-MM')
),
T3M as (
select top 3 [month]
from mRev	
order by [total revenue] asc
),
pRev as (
select	p.[pizza_name], 
		format(p.[order_date], 'yyyy-MM') as [month],
		sum(p.[quantity]*p.[total_price]) as [revenue]
from [dbo].[Pizza_Sales] p
where format(p.[order_date], 'yyyy-MM') in (select [month]
												from T3M)
group by format(p.[order_date], 'yyyy-MM'), p.[pizza_name]
),
pizza_rank as (
select	[month],
		[pizza_name],
		[revenue],
		rank() over(partition by [month] order by [revenue] asc) as [rank]
from pRev
)
select 	[month],
		[pizza_name],
		[revenue]
from pizza_rank
where [rank] <= 3
order by [month], [rank] desc

-- 11 the top 3 pizzas of the 3 worst months and their revenues
with mRev as (
select	format([order_date], 'yyyy-MM') as [month],
		sum([quantity]*[total_price]) as [total revenue]
from [dbo].[Pizza_Sales]
group by format([order_date], 'yyyy-MM')
),
T3M as (
select top 3 [month]
from mRev	
order by [total revenue] asc
),
pRev as (
select	p.[pizza_name], 
		format(p.[order_date], 'yyyy-MM') as [month],
		sum(p.[quantity]*p.[total_price]) as [revenue]
from [dbo].[Pizza_Sales] p
where format(p.[order_date], 'yyyy-MM') in (select [month]
												from T3M)
group by format(p.[order_date], 'yyyy-MM'), p.[pizza_name]
),
pizza_rank as (
select	[month],
		[pizza_name],
		[revenue],
		rank() over(partition by [month] order by [revenue] desc) as [rank]
from pRev
)
select 	[month],
		[pizza_name],
		sum([revenue]) as [t3 pizza worst month]
from pizza_rank
where [rank] <= 3
group by [month],[pizza_name]
order by [month],[t3 pizza worst month] desc


-- 12 pizza types for the worst month of December
select	[pizza_name],
		sum([quantity]*[total_price]) as [revenue]
from [dbo].[Pizza_Sales]
where [order_date] between '2015-12-01' and '2015-12-31'
group by [pizza_name]
order by [revenue] desc

--13 comparing pizza types for the worst monthe of December with the Best month of July
with worst as (
select	[pizza_name],
		sum([quantity]*[total_price]) as [revenue]
from [dbo].[Pizza_Sales]
where [order_date] between '2015-12-01' and '2015-12-31'
group by [pizza_name]
),
best as (
select	[pizza_name],
		sum([quantity]*[total_price]) as [revenue]
from [dbo].[Pizza_Sales]
where [order_date] between '2015-07-01' and '2015-07-31'
group by [pizza_name]
)
select sum([diff in best and worst rev]) as [sum of diff best and worst]
from (
select	best.[pizza_name] as [best pizza],
		best.[revenue] as [best revenue],
		worst.[pizza_name] as [worst pizza],
		worst.[revenue] as [worst revenue],
		(best.[revenue] - worst.[revenue]) as [diff in best and worst rev]
from worst join best
on worst.[pizza_name] = best.[pizza_name]
) A

-- 14 comparing differences in quantities sold between best and worst months
with worst as (
select	[pizza_name],
		[quantity]
from [dbo].[Pizza_Sales]
where [order_date] between '2015-12-01' and '2015-12-31'
),
best as (
select	[pizza_name],
		[quantity]
from [dbo].[Pizza_Sales]
where [order_date] between '2015-07-01' and '2015-07-31'
)
select sum([diff between best and worst quant]) as [diff in quant sold for July and Decem]
from (
select	best.[pizza_name] as [best pizza],
		best.[quantity] as [best quantity],
		worst.[pizza_name] as [worst pizza],
		worst.[quantity] as [worst quantity],
		(best.[quantity] - worst.[quantity]) as [diff between best and worst quant]
from best join worst
on best.[pizza_name] = worst.[pizza_name]
) A
