USE [TEST_DATABASE]
GO

SELECT [Date]
      ,[Injury Location]
      ,[Gender]
      ,[Age Group]
      ,[Incident Type]
      ,[Days Lost]
      ,[Plant]
      ,[Report Type]
      ,[Shift]
      ,[Department]
      ,[Incident Cost]
      ,[WkDay]
      ,[Month]
      ,[Year]
  FROM [dbo].[Workplace Safety]

GO

-- Introduction


-- find all plants
select [Plant]
from [dbo].[Workplace Safety]
group by [Plant]
order by [Plant] asc



-- Incidents Types
select [Incident Type]
from [dbo].[Workplace Safety]
group by [Incident Type]



-- Injury Location
select [Injury Location]
from [dbo].[Workplace Safety]
group by [Injury Location]



-- Total Cost of Incidents for All Plants
select Sum([Total Incident Cost]) as [Total Cost Incurred For ALL PLants]
from (
select	[Plant], 
		SUM([Incident Cost]) as [Total Incident Cost]
from [dbo].[Workplace Safety] as ws
group by Plant
) A

-- OR

select Sum([Incident Cost]) as [Total Cost Incurred For ALL PLants]
from [dbo].[Workplace Safety]

-- Top 3 Plant With Greatest Cost
select top 3 [Plant],[Total Incident Cost]
from (
select	[Plant], 
		SUM([Incident Cost]) as [Total Incident Cost]
from [dbo].[Workplace Safety] as ws
group by Plant
) A
order by [Total Incident Cost] desc


-- Injuries and Associated Costs
select	[Injury Location],
		COUNT([Days Lost]) as [Number of Days Lost],
		Sum([Incident Cost]) as [Total Cost of Days Lost]
from [dbo].[Workplace Safety]
where [Days Lost] > 2
group by [Injury Location]
order by [Total Cost of Days Lost] desc


-- 1 Workplace incidents that have caused more than 2 days work absence 
select *
from [dbo].[Workplace Safety]
where [Days Lost] > 2

-- 2 Number of incidents that have caused > 2 days work absence 
select Count([Days Lost])
from [dbo].[Workplace Safety]
where [Days Lost] > 2

-- 3 Type of incidents that have caused > 2 days work absence
select	[Incident Type],
		COUNT([Days Lost]) as [No of Incidents] 
from [dbo].[Workplace Safety]
where [Days Lost] > 2
group by [Incident Type]
order by [No of Incidents] desc 

-- 4 Type of injury that have caused > 2 days work absence
select	[Injury Location],
		COUNT([Days Lost]) as [Loss of Days] 
from [dbo].[Workplace Safety]
where [Days Lost] > 2
group by [Injury Location]
order by [Loss of Days] desc 

-- 5 Which plant had the greatest number of incidents by cost?
select	top 3 [Plant], 
		Sum([Incident Cost]) as [Total Incidence Cost at Plant],
		count([Incident Type]) as [Total No of Incidents] 
from [dbo].[Workplace Safety]
group by [Plant]
order by [Total Incidence Cost at Plant] desc

-- Also by Total No of Incidents
select	top 3 [Plant], 
		Sum([Incident Cost]) as [Total Incidence Cost at Plant],
		count([Incident Type]) as [Total No of Incidents] 
from [dbo].[Workplace Safety]
group by [Plant]
order by [Total No of Incidents] desc


-- 6 Find likelihood of incidence at plant. Which plant has the greatest probability of incidence?
select	[Plant],
		Count([Incident Type]) as [No. of Incidents],
		Sum([Days Lost]) as [No. of Days Lost to Incidents],
		Sum([Incident Cost]) as [Total Incidence Cost at Plant],
		Count([Incident Type])*1.0/DATEDIFF(y, '2020-01-01', '2022-06-28') as [Likelihood of Incidence]
from [dbo].[Workplace Safety]
group by [Plant]
order by [Total Incidence Cost at Plant] desc;

-- 7 % likelihood of incidence at plant. Which plant has the greatest probability of incidence?
select	[Plant], 
		Count([Incident Type]) as [No. of Incidents],
		Sum([Days Lost]) as [No. of Days Lost to Incidents],
		Sum([Incident Cost]) as [Total Incidence Cost at Plant],
		(Count([Incident Type])*1.0/DATEDIFF(y, '2020-01-01', '2022-06-28'))*100 as [% Likelihood of Incidence]
from [dbo].[Workplace Safety]
group by [Plant]
order by [% Likelihood of Incidence] desc; 

-- 8 Likelihood of incident by shift
with a as (
select	[Plant], [Shift],
		count([Shift]) as [No of Shifts]
from [dbo].[Workplace Safety]
group by [Plant], [Shift]
),
b as (
select	[Plant],
		count([Incident Type]) as [Total No of Incidents]
from [dbo].[Workplace Safety]
group by [Plant]
)
select	a.[Plant],a.[Shift],
		([No of Shifts]*1.0/[Total No of Incidents])*100 as [% Likelihood of Incident By Shift]
from a join b
on a.[Plant] = b.[Plant]
order by [% Likelihood of Incident By Shift] desc

-- And for top 3 Plants
with a as (
select	[Plant], [Shift],
		count([Shift]) as [No of Shifts]
from [dbo].[Workplace Safety]
group by [Plant], [Shift]
),
b as (
select	[Plant],
		count([Incident Type]) as [Total No of Incidents]
from [dbo].[Workplace Safety]
group by [Plant]
)
select	a.[Plant],a.[Shift],
		([No of Shifts]*1.0/[Total No of Incidents])*100 as [% Likelihood of Incident By Shift]
from a join b
on a.[Plant] = b.[Plant]
where a.[Plant] in ('Montana', 'Illinois', 'Florida')
order by [Plant] desc

-- 9 No. of days lost to incidents per plant
select	[Plant],
		Sum([Days Lost]) as [No. of Days Lost to Incidents],
		SUM([Incident Cost]) as [Cost per Period Lost]
from [dbo].[Workplace Safety]
group by [Plant]
order by [Plant] desc 


-- 10 which departments carried the greatest cost of incidents per plant?
select top	3 Plant, Department, [Cost by Department],
			rank() over (order by [Cost by Department] desc) as Greatest_Payout
from (select [Plant], [Department],
				Count([Incident Type]) as [No. of Incidents Per Department],
				Sum([Incident Cost]) as [Cost by Department]
from [dbo].[Workplace Safety]
Group by [Plant], [Department]) as A

--least cost of incidents per plant
select	Plant, Department, [Cost by Department], 
		rank() over (order by [Cost by Department] desc) as [Greatest_Payout]
from (select [Plant], [Department],
				Count([Incident Type]) as [No. of Incidents Per Department],
				Sum([Incident Cost]) as [Cost by Department]
from [dbo].[Workplace Safety]
Group by [Plant], [Department]) as A
order by [Greatest_Payout] desc

-- 11 Days most likely to be injured?
select	[WkDay],
		Count([Incident Type]) as [Days with Greatest Incidents]
from [dbo].[Workplace Safety]
Group by [WkDay]
Order by [Days with Greatest Incidents] desc

-- 12 Which plant has the highest days of incidents
select	[Plant],[WkDay], 
		Count([Incident Type]) as [Days with Greatest Incidents],
		rank() over(partition by [Plant] order by count([Incident Type]) desc) as [Ranked_Days]
from [dbo].[Workplace Safety]
Group by [Plant],[WkDay]
order by [Ranked_Days] asc

-- 13 What days are incidents causing > 3 days work absence likely to occur?
select	[Incident Type],
		sum([Days Lost]) as [TotalDaysLostByIncident]
from [dbo].[Workplace Safety]
where [Days Lost] > 3
group by [Incident Type] 
order by [TotalDaysLostByIncident] desc

-- 14 What incidents are the worst having causing the most days lost?
select	[Incident Type],
		Sum([Days Lost]) as [No. of Days Lost]
from [dbo].[Workplace Safety]
Group by [Incident Type] 
Order by [No. of Days Lost] desc

-- 15 Which plants have highest days lost?
select	[Plant],
		Sum([Days Lost]) as [Lost Days]
from [dbo].[Workplace Safety]
Group by [Plant]
order by [Lost Days] desc 

-- 16 Plant Payout by Injury and Location
select [Plant],
		[Injury Location], 
		[TotalCostofIncident],
		[Rank]
from (
select	[Plant],
		[Injury Location],
		Sum([Incident Cost]) as [TotalCostofIncident],
		rank() over(partition by [Plant] order by Sum([Incident Cost]) desc) as [Rank]
from [dbo].[Workplace Safety]
where [Plant] in ('Florida','Georgia', 'Montana')
group by [Plant],[Injury Location]
) A
where [Rank] in (1,2,3) 

-- 17 Plant Payout with Incident type, injury location, total cost of incident and rank
select [Plant],
		[Incident Type],
		[Injury Location], 
		[TotalCostofIncident],
		[Rank]
from (
select	[Plant],
		[Injury Location],
		[Incident Type],
		Sum([Incident Cost]) as [TotalCostofIncident],
		rank() over(partition by [Plant] order by Sum([Incident Cost]) desc) as [Rank]
from [dbo].[Workplace Safety]
where [Plant] in ('Florida','Georgia', 'Montana')
group by [Plant],[Injury Location],[Incident Type]
) A
where [Rank] in (1,2,3) 

--Aso, Costs associated strictly for Incident Type

select [Plant],
		[Incident Type],
		[TotalCostofIncident],
		[Rank]
from (
select	[Plant],
		[Incident Type],
		Sum([Incident Cost]) as [TotalCostofIncident],
		rank() over(partition by [Plant] order by Sum([Incident Cost]) desc) as [Rank]
from [dbo].[Workplace Safety]
where [Plant] in ('Florida','Georgia', 'Montana')
group by [Plant],[Injury Location],[Incident Type]
) A
where [Rank] in (1,2,3) 
