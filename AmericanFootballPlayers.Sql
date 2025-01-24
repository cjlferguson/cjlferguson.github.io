USE [TEST_DATABASE]
GO

SELECT [Year]
      ,[Team]
      ,[NAME ]
      ,[No#]
      ,[Pos]
      ,[Ht]
      ,[Wt]
      ,[Age]
      ,[Exp]
      ,[College]
      ,[FirstName]
      ,[LastName]
      ,[Ft]
      ,[In]
      ,[Inches]
      ,[NumGrp]
  FROM [dbo].['Football Players Data]

GO

--1 The number of teams and players
select	distinct [Team],
		count([NAME ]) as [No of Players]
from [dbo].['Football Players Data]
group by [Team]

select	distinct [Team],
		count([NAME ]) as [No of Players]
from [dbo].['Football Players Data]
where [Year] = '2010'
group by [Team]

select	distinct [Team],
		count([NAME ]) as [No of Players]
from [dbo].['Football Players Data]
where [Year] = '2022'
group by [Team]

-- 2 The age of all players overall and by years
select distinct [Age]
from [dbo].['Football Players Data]

select distinct [Age]
from [dbo].['Football Players Data]
where [Year]=2010

select distinct [Age]
from [dbo].['Football Players Data]
where [Year]=2022

--3	Team comparison by position by years.
with A as (
select	[Pos],
		[Year],
		count([Pos]) as [A No of Players]
from [dbo].['Football Players Data]
where [Team] = 'Arizona'
group by [Pos], [Year]
),
NO as (
select	[Pos],
		[Year],
		count([Pos]) as [NO No of Players]
from [dbo].['Football Players Data]
where [Team] = 'New Orleans'
group by [Pos],[Year]
)
select	A.[Pos], 
		[A No of Players],
		[NO No of Players],
		([NO No of Players]-[A No of Players]) as [Diff in Pos]
from A join NO
on A.[Pos] = NO.[Pos]
and A.[Year] = NO.[Year]
where A.[Year] = '2010'

with A as (
select	[Pos],
		[Year],
		count([Pos]) as [A No of Players]
from [dbo].['Football Players Data]
where [Team] = 'Arizona'
group by [Pos], [Year]
),
NO as (
select	[Pos],
		[Year],
		count([Pos]) as [NO No of Players]
from [dbo].['Football Players Data]
where [Team] = 'New Orleans'
group by [Pos],[Year]
)
select	A.[Pos], 
		[A No of Players],
		[NO No of Players],
		([NO No of Players]-[A No of Players]) as [Diff in Pos]
from A join NO
on A.[Pos] = NO.[Pos]
and A.[Year] = NO.[Year]
where A.[Year] = '2022'

-- 4 colleges of selection
select [College],
		count([College]) as [count],
		rank() over(order by count([College]) desc) as [rank]
from [dbo].['Football Players Data]
group by [College]

-- 5 age groups of positions; are ages similar across positions
-- 2010 Team
select [Pos], [Age], 
       COUNT(case when [Team] = 'Arizona' then 1 end) as Arizona_Count,
       COUNT(case when [Team] = 'New Orleans' then 1 end) as NO_Count
from [dbo].['Football Players Data]
where [Year]='2010' and [Team] in ('Arizona', 'New Orleans')
group by [Pos], [Age]

-- 2022 Team
select [Pos], [Age], 
       COUNT(case when [Team] = 'Arizona' then 1 end) as Arizona_Count,
       COUNT(case when [Team] = 'New Orleans' then 1 end) as NO_Count
from [dbo].['Football Players Data]
where [Year]='2022' and [Team] in ('Arizona', 'New Orleans')
group by [Pos], [Age]

select [Team], [Pos],[Age]
	from [dbo].['Football Players Data]
	where [Year]='2010' and [Team] = 'New Orleans'
	order by [Pos]

select [Team],[Age],
		count([Age])
from [dbo].['Football Players Data]
where [Year]='2010' and [Team] in ('Arizona','New Orleans')
group by [Team], [Age]
order by [Team],[Age]

-- 6 did any player swtich teams?
--Test 1
select distinct		o.[NAME] as [Old Name], 
					o.[Team] as [Old Team],
					o.[Year] as [Old Year],
					n.[Team] as [New Team],
					n.[Year] as [New Year]
from [dbo].['Football Players Data] o
join [dbo].['Football Players Data] n
on o.[NAME] = n.[NAME] 
and o.[Team] = 'Arizona' and o.[Year] = '2010'
and n.[Team] = 'New Orleans' and n.[Year] = '2022'
order by o.[NAME]

--Test 2
SELECT DISTINCT a.[NAME], a.[Team] AS Old_Team, a.[Year] AS Old_Year, 
                n.[Team] AS New_Team, n.[Year] AS New_Year
FROM [dbo].['Football Players Data] a
JOIN [dbo].['Football Players Data] n
    ON a.[NAME] = n.[NAME] -- Same player
    AND a.[Year] = '2010' -- Played in any team in 2010
    AND n.[Year] = '2022' -- Played in any team in 2022
    AND a.[Team] <> n.[Team] -- Ensures they switched teams
ORDER BY a.[NAME];


--Test 3
select distinct [Team],
				[NAME ],
				Count(*)
from [dbo].['Football Players Data]
group by [Team],[NAME ]
having count(*)>1 --there are no transfers

--6 Write a query to list all players taller than 6 feet 2 inches.
select	[Team], 
		count(distinct [NAME ]) as [No of Players Above 6]
from [dbo].['Football Players Data]
where Ht > '5-7' and [Year] = '2022'
group by [Team]


select [Ht], [Year]
from [dbo].['Football Players Data]


--7	Write a query to list players who are 25 years old or younger.
select [Team], [NAME ], [Age]
from [dbo].['Football Players Data]
where Age <='25'
order by [Team], [Age] desc

-- 8 % of players who are 25 years old or younger for 2010
with A as (
select [Team], count(*) as [No of Players 25 and Under]
from [dbo].['Football Players Data]
where Age <='25'
and [Year] = '2010'
group by [Team]
),
B as (
select [Team], count(*) as [Number of Players Per Team]
from [dbo].['Football Players Data]
where [Year] = '2010'
group by [Team]
)
select 
	A.[Team],
	(A.[No of Players 25 and Under]*1.0/B.[Number of Players Per Team])*100
		as [% of Team 25 Yrs and Under]
from A join B
on A.[Team] = B.[Team]
group by A.[Team], A.[No of Players 25 and Under], B.[Number of Players Per Team]

-- 9 % of players who are 25 years old or younger for 2022
with A as (
select [Team], count(*) as [No of Players 25 and Under]
from [dbo].['Football Players Data]
where Age <='25'
and [Year] = '2022'
group by [Team]
),
B as (
select [Team], count(*) as [Number of Players Per Team]
from [dbo].['Football Players Data]
where [Year] = '2022'
group by [Team]
)
select 
	A.[Team],
	(A.[No of Players 25 and Under]*1.0/B.[Number of Players Per Team])*100
		as [% of Team 25 Yrs and Under]
from A join B
on A.[Team] = B.[Team]
group by A.[Team], A.[No of Players 25 and Under], B.[Number of Players Per Team]

-- 10 Team Positions and Number 2010 and 2022
select	[Team], [Pos],
		count(*) as [No of Players per Pos]
from [dbo].['Football Players Data]
where [Year] = '2010'
and [Team] in ('Arizona', 'New Orleans')
group by [Team], [Pos]
order by [Team]

select	[Team], [Pos],
		count(*) as [No of Players per Pos]
from [dbo].['Football Players Data]
where [Year] = '2022'
and [Team] in ('Arizona', 'New Orleans')
group by [Team], [Pos]
order by [Team]
