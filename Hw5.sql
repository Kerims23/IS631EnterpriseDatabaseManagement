-- #1 i get 1230
SELECT 
    P.playerID, P.birthCity, P.birthState, 
    B.yearID, B.HR, B.RBI, B.AB, 
    FORMAT(COALESCE(s.salary, 0), 'C', 'en-US') AS salary,  -- Format salary as currency, set NULL to 0
    FORMAT(CAST(b.H AS FLOAT) / NULLIF(b.AB, 0), 'N4') AS batting_avg -- Avoid divide by zero error
FROM dbo.PEOPLE P
JOIN dbo.BATTING B ON P.playerID = B.playerID 
JOIN dbo.SALARIES S ON P.playerID = S.playerID AND B.yearID = S.yearID and S.teamid = B.teamID and S.lgID = B.lgID
WHERE P.birthCity = 'TX' AND B.AB > 0
ORDER BY 
    P.nameFirst ASC, 
    B.yearID ASC;


-- #2 1902
SELECT 
    P.playerID, P.birthCity, P.birthState, 
    B.yearID, B.HR, B.RBI, B.AB, 
    FORMAT(S.salary, 'C0') AS salary, 
    FORMAT(CAST(B.H AS FLOAT) / CAST(B.AB AS FLOAT), 'N4') AS batting_average,
    C.schoolID
FROM dbo.PEOPLE P
JOIN dbo.BATTING B ON P.playerID = B.playerID
JOIN dbo.SALARIES S ON P.playerID = S.playerID AND B.yearID = S.yearID and S.teamid = B.teamID and S.lgID = B.lgID
JOIN dbo.CollegePlaying C ON P.playerID = C.playerID  
WHERE P.birthCity = 'TX' AND B.AB > 0
ORDER BY 
    P.nameFirst ASC, 
    B.yearID ASC;

-- #3 152
SELECT 
    P.playerID, P.birthCity, P.birthState, 
    B.yearID, B.HR, B.RBI, B.AB, 
    FORMAT(S.salary, 'C0') AS salary, 
    FORMAT(CAST(B.H AS FLOAT) / CAST(B.AB AS FLOAT), 'N4') AS batting_average,
    C.schoolID
FROM dbo.PEOPLE P
JOIN dbo.BATTING B ON P.playerID = B.playerID
JOIN dbo.SALARIES S ON P.playerID = S.playerID AND B.yearID = S.yearID and S.teamid = B.teamID and S.lgID = B.lgID
JOIN dbo.CollegePlaying C ON P.playerID = C.playerID  
WHERE P.birthCity = 'TX' AND B.AB > 0  AND C.yearID BETWEEN '1970' AND '1980'
ORDER BY 
    P.nameFirst ASC, 
    B.yearID ASC;

-- #4 138
SELECT DISTINCT B1.playerID, B1.teamID
FROM dbo.BATTING B1
JOIN dbo.BATTING B2 
    ON B1.playerID = B2.playerID 
    AND B1.teamID = B2.teamID  -- Ensures they played for the same team
    AND B1.yearID = 2016 
    AND B2.yearID = 2021
ORDER BY B1.playerID;

-- #5 I get 457
SELECT DISTINCT b1.playerID, b1.teamID
FROM dbo.Batting b1
JOIN dbo.Batting b2 ON b1.playerID = b2.playerID
WHERE b1.yearID = 2016 AND b2.yearID = 2021 AND b1.teamID <> b2.teamID;

-- #6 27
SELECT playerID, yearID, teamID
FROM dbo.SALARIES
WHERE salary IS NULL
ORDER BY teamID, yearID;

-- #7 6575
SELECT 
    playerID, 
    COUNT(DISTINCT schoolID) AS num_colleges_attended, 
    MIN(yearID) AS first_year_attended, 
    MAX(yearID) AS last_year_attended, 
    (MAX(yearID) - MIN(yearID) + 1) * 2 AS total_semesters_attended
FROM dbo.CollegePlaying
GROUP BY playerID
ORDER BY playerID;

-- #8 this is good 
SELECT 
    FORMAT(MIN(salary), 'C', 'en-US') AS min_salary,
    FORMAT(AVG(salary), 'C', 'en-US') AS avg_salary,
    FORMAT(MAX(salary), 'C', 'en-US') AS max_salary
FROM dbo.Salaries
WHERE salary > 0;

-- #9 6658 but perc diff is wrong 
SELECT 
    s.playerid,
    FORMAT(SUM(s.salary), 'C') AS total_salary,  
    FORMAT(MAX(s.salary), 'C') AS max_salary,  
    FORMAT((MAX(s.salary) * 3), 'C') AS lost_salary,  
    1 - (SUM(s.salary) * 1.0 / (SUM(s.salary) + MAX(s.salary) * 3)) AS lost_income_percentage
FROM dbo.Salaries s
GROUP BY s.playerid
HAVING (1 - (SUM(s.salary) * 1.0 / (SUM(s.salary) + MAX(s.salary) * 3))) > 0
ORDER BY s.playerid;

--#10 this is good 
SELECT 
    FORMAT(AVG(lost_salary), 'C', 'en-US') AS avg_lost_income_dollars,
    FORMAT(AVG(lost_income_percentage) * 100, 'N2') + '%' AS avg_percent_difference_in_salary
FROM (
    SELECT 
        s.playerid,
        SUM(s.salary) AS total_salary,
        MAX(s.salary) AS max_salary,
        MAX(s.salary) * 3 AS lost_salary,  -- Lost income as 3 times the max salary
        1 - (SUM(s.salary) / (SUM(s.salary) + MAX(s.salary) * 3)) AS lost_income_percentage
    FROM dbo.Salaries s
    GROUP BY s.playerid
    HAVING (1 - (SUM(s.salary) / (SUM(s.salary) + MAX(s.salary) * 3))) > 0
) AS subquery;
