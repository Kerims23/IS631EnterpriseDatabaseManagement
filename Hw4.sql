
/*
The number of rows returned for each question are as follows:
Question 1 - (51368 rows affected)
Question 2 - (51368 rows affected)
Question 3 - (325 rows affected)
Question 4 - (93812 rows affected)
Question 5 - (10567 rows affected)
Question 6 - (10567 rows affected)
Question 7 - (10567 rows affected)
Question 8 - (145 rows affected)
(151 rows affected) – using nullif
Question 9 - (49 rows affected)
Question 10 - (175 rows affected)
*/

/*
Using the Pitching table, write a query that selects the playerid, teamid, Wins (W), Loss (L) and Earned Run
Average (ERA) for every player (Slide 15).
playerid teamid w l era
aardsda01 SFN 1 0 6.75
aardsda01 CHN 3 0 4.08
aardsda01 CHA 2 1 6.4
aardsda01 BOS 4 2 5.55
*/

-- #1
select  playerid, teamid, w, l, ERA 
from dbo.Pitching

-- #2
select  playerid, teamid, w, l, ERA 
from dbo.Pitching 
order by era DESC

-- #3
select distinct name, park, teamID
from dbo.Teams 
order by park desc

-- #4 I think this is right but getting different numbers 
SELECT 
    playerID, yearID, teamID, 
    (H + BB + (B2 * 2) + (B3 * 3) + (HR * 4)) AS Total_Bases_Touched
FROM dbo.BATTING
ORDER BY yearID, teamID, playerID;

-- #5 I think this is right but getting different numbers 
SELECT 
    playerid, yearid, teamid, 
    (H + BB + (B2 * 2) + (B3 * 3) + (HR * 4)) AS Total_Bases_Touched 
FROM dbo.BATTING
where teamid IN ('NYA', 'BOS') 
order by Total_Bases_Touched DESC, playerid ASC;

-- #6 
SELECT 
    B.playerID, 
    B.yearID, 
    B.teamID, 
    (B.H + B.BB + (B.B2 * 2) + (B.B3 * 3) + (B.HR * 4)) AS Total_Bases_Touched,
    FORMAT(
        (CAST((B.H + B.BB + (B.B2 * 2) + (B.B3 * 3) + (B.HR * 4)) AS FLOAT) /
        NULLIF(CAST((T.H + T.BB + (T.B2 * 2) + (T.B3 * 3) + (T.HR * 4)) AS FLOAT), 0)) * 100,
        'N2'
    ) + '%' AS Percent_Team_Total_Bases_Touched,
    (T.H + T.BB + (T.B2 * 2) + (T.B3 * 3) + (T.HR * 4)) AS Team_Bases_Touched
FROM dbo.BATTING B, dbo.TEAMS T
where B.yearID = T.yearID and B.teamID = T.teamID and B.teamID in ('NYA', 'BOS')
order by Percent_Team_Total_Bases_Touched desc, B.playerID asc;

-- #7
SELECT 
    B.playerID, 
    B.yearID, 
    B.teamID, 
    (B.H + B.BB + (B.B2 * 2) + (B.B3 * 3) + (B.HR * 4)) AS Total_Bases_Touched,
    FORMAT(
        (CAST((B.H + B.BB + (B.B2 * 2) + (B.B3 * 3) + (B.HR * 4)) AS FLOAT) /
        NULLIF(CAST((T.H + T.BB + (T.B2 * 2) + (T.B3 * 3) + (T.HR * 4)) AS FLOAT), 0)) * 100,
        'N2'
    ) + '%' AS Percent_Team_Total_Bases_Touched,
    (T.H + T.BB + (T.B2 * 2) + (T.B3 * 3) + (T.HR * 4)) AS Team_Bases_Touched
FROM dbo.BATTING B
JOIN dbo.TEAMS T 
    ON B.yearID = T.yearID 
    AND B.teamID = T.teamID
where B.teamID IN ('NYA', 'BOS')
order by Percent_Team_Total_Bases_Touched desc, B.playerID asc;

-- #8
SELECT 
    P.playerID, P.nameFirst, P.nameLast, P.nameGiven,
    CONCAT(P.nameGiven, ' (', P.nameFirst, ') ', P.nameLast) AS Full_Name,
    B.yearID, B.teamID,
    FORMAT(CAST(B.H AS FLOAT) / NULLIF(CAST(B.AB AS FLOAT), 0), 'N4') AS batting_average
FROM dbo.PEOPLE P
JOIN dbo.BATTING B ON P.playerID = B.playerID
where (P.nameFirst LIKE '%.%' OR P.nameGiven LIKE '%.%')
    and B.teamID in ('NYA', 'BOS')
    and B.H > 0  -- Exclude players with 0 hits
order by B.yearID asc, B.playerID asc;


-- #9
SELECT 
    P.playerID, P.nameFirst, P.nameLast, P.nameGiven,
    CONCAT(P.nameGiven, ' (', P.nameFirst, ') ', P.nameLast) AS Full_Name,
    B.yearID, B.teamID,
    FORMAT(CAST(B.H AS FLOAT) / NULLIF(CAST(B.AB AS FLOAT), 0), 'N4') AS batting_average
FROM dbo.PEOPLE P
JOIN dbo.BATTING B 
    ON P.playerID = B.playerID
where 
    (P.nameFirst LIKE '%.%' OR P.nameGiven LIKE '%.%')
    AND B.teamID IN ('NYA', 'BOS')
    AND B.H > 0  -- Exclude players with 0 hits
    AND (CAST(B.H AS FLOAT) / NULLIF(CAST(B.AB AS FLOAT), 0)) BETWEEN 0.2 AND 0.4999
order by batting_average desc, B.playerID asc, B.yearID asc;

-- #10
SELECT 
    P.playerID, 
    CONCAT(P.nameGiven, ' (', P.nameFirst, ') ', P.nameLast) AS Full_Name,
    B.yearID,
    T.name AS Team_Name, 
    (B.H + B.BB + (B.B2 * 2) + (B.B3 * 3) + (B.HR * 4)) AS Total_Bases_Touched,
    FORMAT(CAST(B.H AS FLOAT) / NULLIF(CAST(B.AB AS FLOAT), 0), 'N4') AS batting_average,
    FORMAT(CAST(T.H AS FLOAT) / NULLIF(CAST(T.AB AS FLOAT), 0), 'N4') AS team_batting_average,
    FORMAT(
        (CAST(B.H AS FLOAT) / NULLIF(CAST(B.AB AS FLOAT), 0)) / 
        NULLIF((CAST(T.H AS FLOAT) / NULLIF(CAST(T.AB AS FLOAT), 0)), 0) * 100, 
        'N2'
    ) + '%' AS Percent_Team_Avg
FROM Batting b
JOIN People p ON b.playerid = p.playerid
JOIN Teams t ON b.teamid = t.teamid AND b.yearid = t.yearid
WHERE (p.nameFirst LIKE '%.%' OR p.nameGiven LIKE '%.%') AND b.AB >= 50
ORDER BY Batting_Average DESC, p.playerid, b.yearid;
