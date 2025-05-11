-- Question 1 - (10569 rows affected)
SELECT playerid, 
       Career_SO, 
       RANK() OVER (ORDER BY Career_SO DESC) AS SO_Rank
FROM IS631View
WHERE Career_SO IS NOT NULL 
ORDER BY SO_Rank;

-- Question 2 - (10569 rows affected)
SELECT playerid, 
       Career_SO, 
       DENSE_RANK() OVER (ORDER BY Career_SO ASC) AS SO_Rank
FROM IS631View
WHERE Career_SO IS NOT NULL  
ORDER BY SO_Rank;

-- Question 3- (455 rows affected) this is wrong somehow 
WITH RankedPlayers AS (
    SELECT playerid, 
           LastPlayed, 
           Career_SO, 
           DENSE_RANK() OVER (PARTITION BY LastPlayed ORDER BY Career_SO DESC) AS SO_Rank
    FROM IS631View
    WHERE Career_SO IS NOT NULL  -- Exclude non-pitchers (those without strikeouts)
)
SELECT playerid, 
       LastPlayed, 
       Career_SO, 
       SO_Rank
FROM RankedPlayers
ORDER BY LastPlayed DESC, SO_Rank;

-- Question 4 - (10569 rows affected)
WITH RankedPlayers AS (
    SELECT playerid, 
           LastPlayed, 
           Career_SO, 
           RANK() OVER (PARTITION BY LastPlayed ORDER BY Career_SO DESC) AS SO_Rank
    FROM IS631View
    WHERE Career_SO IS NOT NULL  -- Exclude non-pitchers (those without strikeouts)
)
SELECT playerid, 
       LastPlayed, 
       Career_SO, 
       SO_Rank
FROM RankedPlayers
WHERE SO_Rank <= 3
ORDER BY LastPlayed DESC, SO_Rank;

-- Question 5 - (10,569 rows affected)
WITH RankedPlayers AS (
    SELECT playerid, 
           Career_SO, 
           PERCENT_RANK() OVER (ORDER BY Career_SO DESC) AS Percent_Rank
    FROM IS631View
    WHERE Career_SO IS NOT NULL  
)
SELECT playerid, 
       Career_SO, 
       1 - Percent_Rank AS SO_Rank  
FROM RankedPlayers
ORDER BY SO_Rank DESC;  

-- Question 6 - (2,117 rows affected) – Copy salaries table
WITH RankedPlayers AS (
    SELECT playerid, 
           Career_SO, 
           CUME_DIST() OVER (ORDER BY Career_SO DESC) AS SO_Cume_Dist
    FROM IS631View
    WHERE Career_SO IS NOT NULL  
)
SELECT playerid, 
       Career_SO, 
       SO_Cume_Dist AS SO_Rank
FROM RankedPlayers
WHERE SO_Cume_Dist BETWEEN 0.4 AND 0.6 
ORDER BY SO_Cume_Dist;

-- Question 7 - (520 rows affected)
-- First, create a backup of the SALARIES table (optional)
IF OBJECT_ID (N'dbo.salaries_backup', N'U') IS NOT NULL
    DROP TABLE [dbo].[salaries_backup]
GO

SELECT * INTO salaries_backup FROM salaries;

-- Now  delete duplicate rows 
WITH CTE AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY yearid, teamid, lgid, playerid ORDER BY yearid) AS rn
    FROM dbo.salaries
)
Delete  FROM dbo.salaries
WHERE EXISTS (
    SELECT 1
    FROM CTE
    WHERE CTE.rn > 1
);

-- Question 8 - (1129 rows affected)
WITH AvgSalaryPerTeam AS (
    -- Calculate the average salary by team and year
    SELECT 
        teamid,
        yearid,
        AVG(salary) AS Avg_Salary
    FROM dbo.salaries
    GROUP BY teamid, yearid
)
SELECT 
    a.teamid,
    a.yearid,
    a.Avg_Salary,
    -- Calculate the windowed average (3 prior years + current year + 1 after year)
    AVG(a.Avg_Salary) OVER (
        PARTITION BY a.teamid 
        ORDER BY a.yearid
        ROWS BETWEEN 3 PRECEDING AND 1 FOLLOWING
    ) AS Windowed_Salary
FROM AvgSalaryPerTeam a
ORDER BY a.teamid, a.yearid;

-- Question 9 - (12 rows affected)

-- This part is used to execute the batch (necessary before the CTE)
GO

WITH RecursiveMonths AS (
    -- Base case: Start with the first month (January)
    SELECT 1 AS MonthNumber, DATENAME(MONTH, DATEADD(MONTH, 0, '2023-01-01')) AS Month_Name
    UNION ALL
    -- Recursive part: Add the next month
    SELECT MonthNumber + 1, DATENAME(MONTH, DATEADD(MONTH, MonthNumber, '2023-01-01'))
    FROM RecursiveMonths
    WHERE MonthNumber < 12  -- Stop when we reach the 12th month (December)
)
-- Final result: Select the results from the CTE
SELECT MonthNumber, Month_Name
FROM RecursiveMonths
ORDER BY MonthNumber;

-- Ends the batch
GO

-- Question 10 - (149 rows affected)
SELECT teamid, 
       [1895], [1896], [1897], [1898], [1899],
       [1995], [1996], [1997], [1998], [1999],
       [2018], [2019], [2020], [2021], [2022]
FROM 
    (SELECT teamid, yearid, hr
     FROM batting
     WHERE yearid IN (1895, 1896, 1897, 1898, 1899, 1995, 1996, 1997, 1998, 1999, 2018, 2019, 2020, 2021, 2022)
    ) AS SourceTable
PIVOT
    (SUM(hr)
     FOR yearid IN ([1895], [1896], [1897], [1898], [1899], 
                    [1995], [1996], [1997], [1998], [1999], 
                    [2018], [2019], [2020], [2021], [2022])
    ) AS PivotTable
ORDER BY teamid;

