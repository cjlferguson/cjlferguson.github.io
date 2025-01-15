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
		COUNT([Days Lost])
from [dbo].[Workplace Safety]
where [Days Lost] > 2
group by [Incident Type]

-- 4 Type of injury that have caused > 2 days work absence
select	[Injury Location],
		COUNT([Days Lost])
from [dbo].[Workplace Safety]
where [Days Lost] > 2
group by [Injury Location]

-- 5 Which plant had the greatest number of incidents by cost?
select	[Plant],
		Sum([Incident Cost]) as [Total Incidence Cost at Plant]
from [dbo].[Workplace Safety]
group by [Plant]

-- 6 Find likelihood of incidence at plant. Which plant has the greatest probability of incidence?
select	[Plant], --correct
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
order by [Total Incidence Cost at Plant] desc;

-- 8 No. of days lost to incidents per plant
select	[Plant],
		Sum([Days Lost]) as [No. of Days Lost to Incidents]
from [dbo].[Workplace Safety]
group by [Plant]

-- 9 which departments carried the greatest cost of incidents per plant?
select top	3 Plant, Department, [Cost by Department],
			rank() over (order by [Cost by Department] desc) as Greatest_Payout
from (select [Plant], [Department],
				Count([Incident Type]) as [No. of Incidents Per Department],
				Sum([Incident Cost]) as [Cost by Department]
from [dbo].[Workplace Safety]
Group by [Plant], [Department]) as A

-- 10 Days most likely to be injured?
select	[WkDay],
		Count([Incident Type]) as [Days with Greatest Incidents]
from [dbo].[Workplace Safety]
Group by [WkDay]
Order by [Days with Greatest Incidents] desc

-- 12 plant has the highest days of incidents
select	[Plant],[WkDay],
		Count([Incident Type]) as [Days with Greatest Incidents]
from [dbo].[Workplace Safety]
Group by [Plant],[WkDay]
Order by [Plant],[WkDay] asc

-- 13 What days are incidents causing > 3 days work absence likely to occur?
select [Incident Type],[Days Lost]
from [dbo].[Workplace Safety]
where [Days Lost] > 3

-- 14 What incidents are the worst to having causing the most days lost?
select	[Incident Type],
		Sum([Days Lost]) as [No. of Days Lost]
from [dbo].[Workplace Safety]
Group by [Incident Type] 
Order by [No. of Days Lost] desc

-- 15 Which plants have highest days lost?
select	[Plant],
		Sum([Days Lost])
from [dbo].[Workplace Safety]
Group by [Plant]
