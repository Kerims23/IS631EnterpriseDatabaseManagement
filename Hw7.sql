USE Spring_2025_Baseball;
GO

-- Drop the view first if it exists
IF OBJECT_ID('dbo.ks835_Player_Summary', 'V') IS NOT NULL
    DROP VIEW dbo.ks835_Player_Summary;
GO

-- Part 1
--drop view if exists ks835_Player_Summary;
CREATE VIEW dbo.ks835_Player_Summary AS
WITH BattingStats AS (
    SELECT 
        playerID,
        COUNT(DISTINCT yearID) AS Num_Yrs_Played,
        COUNT(DISTINCT teamID) AS Num_Teams_Played,
        SUM(CAST(HR AS INT)) AS Career_Home_Runs,
        --SUM(CAST(H AS INT)) / NULLIF(SUM(CAST(AB AS INT)),0) AS Career_Batting_Avg,
        MAX(yearID) AS Last_Year_Played
    FROM Batting
    GROUP BY playerID
),
SalaryStats AS (
    SELECT 
        playerID,
        SUM(CAST(salary AS DECIMAL(18,2))) AS Total_Salary,
        AVG(CAST(salary AS DECIMAL(18,2))) AS Avg_Career_Salary,
        MIN(yearID) AS Start_Year,
        MAX(yearID) AS End_Year,
        MIN(CAST(salary AS DECIMAL(18,2))) AS Starting_Salary,
        MAX(CAST(salary AS DECIMAL(18,2))) AS Ending_Salary,
        ((MAX(CAST(salary AS DECIMAL(18,2))) - MIN(CAST(salary AS DECIMAL(18,2)))) * 100.0 / NULLIF(MIN(CAST(salary AS DECIMAL(18,2))),0)) AS Salary_Increase_Percentage
    FROM Salaries
    GROUP BY playerID
),
PitchingStats AS (
    SELECT 
        playerID,
        SUM(CAST(W AS INT)) AS Career_Total_Wins,
        SUM(CAST(SO AS INT)) AS Career_Total_Strikeouts,
        SUM(CAST(SO AS INT) + CAST(BB AS INT)) / NULLIF(SUM(CAST(IPouts AS INT))/3.0, 0) AS Career_Power_Fitness_Ratio
    FROM Pitching
    GROUP BY playerID
),
FieldingStats AS (
    SELECT 
        playerID,
        SUM(CAST(G AS INT)) AS Total_Games_Played,
        SUM(CAST(GS AS INT)) AS Total_Games_Started,
        SUM(CAST(PO AS INT) + CAST(A AS INT)) / NULLIF(SUM(CAST(PO AS INT) + CAST(A AS INT) + CAST(E AS INT)), 0) AS Career_Fielding_Percentage
    FROM Fielding
    GROUP BY playerID
),
HallOfFameStats AS (
    SELECT 
        playerID,
        MAX(CASE WHEN inducted = 'Y' THEN yearID ELSE NULL END) AS Year_Inducted,
        COUNT(CASE WHEN inducted = 'N' THEN 1 END) AS Times_Nominated_Not_Inducted,
        CASE WHEN MAX(CASE WHEN inducted = 'Y' THEN 1 ELSE 0 END) = 1 THEN 'Yes' ELSE 'No' END AS Hall_of_Fame
    FROM HallOfFame
    GROUP BY playerID
)
SELECT 
    p.playerID,
    dbo.fullname(p.playerID) AS Player_Full_Name,
    p.Total_401K,
    b.Num_Yrs_Played,
    b.Num_Teams_Played,
    b.Career_Home_Runs,
    p.High_BA as Career_Batting_Avg,
    b.Last_Year_Played,
    s.Total_Salary,
    s.Avg_Career_Salary,
    s.Starting_Salary,
    s.Ending_Salary,
    s.Salary_Increase_Percentage,
    pi.Career_Total_Wins,
    pi.Career_Total_Strikeouts,
    pi.Career_Power_Fitness_Ratio,
    f.Total_Games_Played,
    f.Total_Games_Started,
    f.Career_Fielding_Percentage,
    h.Year_Inducted,
    h.Times_Nominated_Not_Inducted,
    h.Hall_of_Fame
FROM People p
LEFT JOIN BattingStats b ON p.playerID = b.playerID
LEFT JOIN SalaryStats s ON p.playerID = s.playerID
LEFT JOIN PitchingStats pi ON p.playerID = pi.playerID
LEFT JOIN FieldingStats f ON p.playerID = f.playerID
LEFT JOIN HallOfFameStats h ON p.playerID = h.playerID
go 

-- Part 2 I get 21,010
SELECT * FROM dbo.ks835_Player_Summary; 
GO
-- Part 3
SELECT 
    COUNT(*) AS Total_Rows_Returned,
    AVG(Num_Yrs_Played) AS Avg_Years_Played,
    AVG(Avg_Career_Salary) AS Avg_Average_Salary,
    AVG(Career_Batting_Avg) AS Avg_Career_Batting_Avg,
    COUNT(CASE WHEN Player_Full_Name LIKE 'B%' THEN 1 END) * 1.0 / COUNT(*) AS Percentage_Players_B
FROM dbo.ks835_Player_Summary
GO







