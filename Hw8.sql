USE Spring_2025_Baseball;
GO

-- Drop the function if it already exists
IF OBJECT_ID('dbo.ks835_FPct', 'FN') IS NOT NULL
    DROP FUNCTION dbo.ks835_FPct;
GO

-- Create the function to calculate career fielding percentage
CREATE FUNCTION dbo.ks835_FPct (@playerid VARCHAR(50))  
RETURNS FLOAT  
AS  
BEGIN  
    DECLARE @fieldingPercentage FLOAT;  

    SELECT @fieldingPercentage =  
        CASE  
            WHEN SUM(PO + A + E) = 0 THEN 0  -- Avoid division by zero  
            ELSE CAST(SUM(PO + A) AS FLOAT) / CAST(SUM(PO + A + E) AS FLOAT)  
        END  
    FROM Spring_2025_Baseball.dbo.fielding  
    WHERE playerid = @playerid;  

    RETURN ISNULL(@fieldingPercentage, 0); -- Ensure function returns 0 if NULL  

END
GO

--select top(100) * From fielding


-- test fullname function 
select top(10) playerid, dbo.fullname(playerid) from people

-- question 1
SELECT  top(10)
    p.playerid,
    dbo.fullname(p.playerid) AS FullName,
    dbo.ks835_FPct(p.playerid) AS CareerFPct
FROM  people p
ORDER BY  playerid asc;
GO


-- question 2
SELECT top(10)
    b.teamid,
    CONVERT(DECIMAL(7,4), AVG(CONVERT(DECIMAL(7,4), dbo.ks835_FPct(b.playerid)))) AS Team_FPct
FROM Batting b
GROUP BY b.teamid
ORDER BY Team_FPct DESC;
GO
