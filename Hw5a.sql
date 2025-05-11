--#1 percentage is off I have 53.85 instead of 54.06
SELECT 
    FORMAT(AVG(lost_salary), 'C', 'en-US') AS avg_lost_income_dollars,
    FORMAT(AVG(CAST(lost_income_percentage AS FLOAT)) * 100, 'N2') + '%' AS avg_percent_difference_in_salary
FROM (
    SELECT 
        s.playerid,
        SUM(s.salary) AS total_salary,
        MAX(s.salary) AS max_salary,
        MAX(s.salary) * 3 AS lost_salary,  -- Lost income as 3 times the max salary
        CAST(1 - (SUM(s.salary) * 1.0 / (SUM(s.salary) + MAX(s.salary) * 3)) AS FLOAT) AS lost_income_percentage
    FROM dbo.Salaries s
    WHERE s.playerid IN (SELECT DISTINCT playerid FROM dbo.CollegePlaying)
    GROUP BY s.playerid
    HAVING (1 - (SUM(s.salary) * 1.0 / (SUM(s.salary) + MAX(s.salary) * 3))) > 0
) AS subquery;

--#2 This one I have the the dollar amount and the percentage off. Not sure what I did wrong inthis one
SELECT 
    FORMAT(AVG(lost_salary), 'C', 'en-US') AS avg_lost_income_dollars,
    FORMAT(
        (SUM(lost_salary) * 1.0) / (SUM(lost_salary) + SUM(total_salary)) * 100,
        'N2'
    ) + '%' AS avg_percent_difference_in_salary
FROM (
    SELECT 
        s.playerid,
        SUM(s.salary) AS total_salary,
        MAX(s.salary) AS max_salary,
        MAX(s.salary) * 3 AS lost_salary,  -- Lost income as 3 times the max salary
        CAST(1 - (SUM(s.salary) * 1.0 / (SUM(s.salary) + MAX(s.salary) * 3)) AS FLOAT) AS lost_income_percentage
    FROM dbo.Salaries s
    WHERE s.playerid IN (SELECT DISTINCT playerid FROM dbo.CollegePlaying)
    GROUP BY s.playerid
    HAVING (1 - (SUM(s.salary) * 1.0 / (SUM(s.salary) + MAX(s.salary) * 3))) > 0
) AS subquery;

--#3  I get 32495 vs 14396
SELECT 
    p.playerID,
    p.nameGiven + ' (' + p.nameFirst + ') ' + p.nameLast AS fullName,
    MAX(s.yearID) AS last_year_played,
    MAX(s.salary) AS last_salary,
    ps.avg_player_salary,
    (MAX(s.salary) - ts.avg_team_salary) AS salary_difference
FROM Salaries s
JOIN 
    (SELECT playerID, AVG(salary) AS avg_player_salary
     FROM Salaries
     GROUP BY playerID) ps ON s.playerID = ps.playerID
JOIN 
    (SELECT teamID, yearID, AVG(salary) AS avg_team_salary
     FROM Salaries
     GROUP BY teamID, yearID) ts ON s.teamID = ts.teamID AND s.yearID = ts.yearID
JOIN dbo.People p ON p.playerID = s.playerID
GROUP BY p.playerID, p.nameGiven, p.nameFirst, p.nameLast, ps.avg_player_salary, ts.avg_team_salary
ORDER BY 
    p.playerID ASC,
    last_year_played DESC,
    salary_difference DESC;

--#4 once I fix 3 I should be able to do 4
WITH PlayerAvgSalary AS (
    SELECT playerID, AVG(salary) AS avg_player_salary
    FROM Salaries
    GROUP BY playerID
),
TeamAvgSalary AS (
    SELECT teamID, yearID, AVG(salary) AS avg_team_salary
    FROM Salaries
    GROUP BY teamID, yearID
)
SELECT 
    p.nameFirst + ' ' + p.namelast AS full_name,
    ps.avg_player_salary,
    s.teamID,
    MAX(s.yearID) AS last_year_played,
    (MAX(s.salary) - ts.avg_team_salary) AS salary_difference
FROM Salaries s
JOIN PlayerAvgSalary ps ON s.playerID = ps.playerID
JOIN TeamAvgSalary ts ON s.teamID = ts.teamID AND s.yearID = ts.yearID
JOIN dbo.People p ON s.playerID = p.playerID
GROUP BY 
    p.nameFirst, p.namelast, ps.avg_player_salary, s.teamID, ts.avg_team_salary, s.playerID
ORDER BY 
    last_year_played DESC,
    salary_difference DESC,
    s.playerID ASC;

--#5 I think this is right I get 21010
SELECT playerid,
    p.namegiven +  ' (' + p.nameFirst + ') ' + p.nameLast AS fullname,
    
        -- Number of Teams Played for from Batting Table
    (SELECT COUNT(DISTINCT teamID)
     FROM Batting b
     WHERE b.playerID = p.playerID) AS Total_teams,

    -- Average Salary from Salaries Table
    (SELECT AVG(s.salary) 
     FROM Salaries s
     WHERE s.playerID = p.playerID) AS avg_salary,

    -- Career ERA (Earned Run Average) from Pitching Table
    (SELECT COALESCE(AVG(ERA), 0)
     FROM Pitching pi
     WHERE pi.playerID = p.playerID) AS Avg_ERA,

    -- Career Batting Average from Batting Table
    (SELECT COALESCE(SUM(H) * 1.0 / NULLIF(SUM(AB), 0), 0)
     FROM Batting b
     WHERE b.playerID = p.playerID) AS avg_BA
FROM People p
ORDER BY playerid asc;


--#6 I got 33302 
UPDATE Salaries
SET Player_401K_Contributions = salary * 0.06;

--#7 33302
UPDATE Salaries
SET Team_401K_Contributions = 
    CASE 
        WHEN salary < 1000000 THEN salary * 0.05  -- 5% contribution if salary is under $1 million
        WHEN salary >= 1000000 THEN salary * 0.025  -- 2.5% contribution if salary is over $1 million
    END;

select playerid, salary, Player_401K_Contributions,Team_401K_Contributions
from salaries
order by playerid asc

--#8 21010 this is right 
UPDATE People -- 21010
SET 
    total_hr = (SELECT SUM(H) 
                FROM Batting b 
                WHERE b.playerID = People.playerID 
                  AND b.ab > 0),  -- Ensures we only count valid at-bats
    high_ba = (SELECT COALESCE(SUM(H) * 1.0 / NULLIF(SUM(AB), 0), 0)
               FROM Batting b 
               WHERE b.playerID = People.playerID)

-- Select playerid, Total HRs and Highest Batting Average
SELECT -- 21010
    p.playerID,
    p.Total_HR,
    FORMAT(p.High_BA, 'N4') AS High_BA -- Format to 4 decimal places
FROM People p
ORDER BY p.playerID;

--#9 6404 
UPDATE People
SET Total_401K = (
    SELECT SUM(s.Player_401K_Contributions + s.Team_401K_Contributions)
    FROM Salaries s
    WHERE s.playerID = People.playerID
)
WHERE EXISTS (
    SELECT 1 FROM Salaries s 
    WHERE s.playerID = People.playerID
);

-- Select playerid, full name, and total 401K for players who have contributed
SELECT 
    p.playerID,
    p.namegiven +  ' (' + p.nameFirst + ') ' + p.nameLast AS fullname,
    p.Total_401K
FROM People p
WHERE p.Total_401K > 0  -- Only show players with contributions to their 401K
ORDER BY p.playerID;

--#10 this is wrong I have 25133 vs 17640

SELECT 
    p.playerID,
    p.namegiven +  ' (' + p.nameFirst + ') ' + p.nameLast AS fullname,
    s.yearID,
    s.salary,
    prev.salary AS prior_year,
    (s.salary - prev.salary) AS salary_difference,
    CASE 
        WHEN prev.salary > 0 THEN ROUND(((s.salary - prev.salary) * 100.0) / prev.salary, 2)
        ELSE NULL
    END AS salary_increase
FROM Salaries s
JOIN People p ON s.playerID = p.playerID
LEFT JOIN Salaries prev 
    ON s.playerID = prev.playerID 
    AND s.yearID = prev.yearID + 1  -- Join on the previous year
WHERE prev.salary IS NOT NULL  -- Exclude players without a previous salary
ORDER BY s.playerID ASC, s.yearID DESC;
