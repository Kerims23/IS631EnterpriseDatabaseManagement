-- ### PART 1 ###

-- Add ks835_Career_EqA if it doesn't exist
IF COL_LENGTH('PEOPLE', 'ks835_Career_EqA') IS NULL
BEGIN
    ALTER TABLE PEOPLE
    ADD ks835_Career_EqA FLOAT;
END;

-- Add ks835_Date_Last_Update if it doesn't exist
IF COL_LENGTH('PEOPLE', 'ks835_Date_Last_Update') IS NULL
BEGIN
    ALTER TABLE PEOPLE
    ADD ks835_Date_Last_Update DATETIME;
END;

-- ### PART 2 ###
-- Drop procedure if it already exists
-- Drop the procedure if it exists
IF OBJECT_ID('ks835_Update_EqA_If_Stale', 'P') IS NOT NULL
DROP PROCEDURE ks835_Update_EqA_If_Stale;
GO

CREATE PROCEDURE ks835_Update_EqA_If_Stale
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @playerID CHAR(10),
        @H INT,
        @B2 INT,
        @B3 INT,
        @HR INT,
        @BB INT,
        @HBP INT,
        @SB INT,
        @SH INT,
        @SF INT,
        @CS INT,
        @AB INT,
        @EqA FLOAT,
        @rowCounter INT = 0;

    -- Cursor that selects only players where Date_Last_Update is not today
    DECLARE player_cursor CURSOR FOR
    SELECT 
        B.playerID,
        SUM(CAST(H AS INT)), 
        SUM(CAST(B2 AS INT)), 
        SUM(CAST(B3 AS INT)), 
        SUM(CAST(HR AS INT)),
        SUM(CAST(BB AS INT)), 
        SUM(CAST(HBP AS INT)), 
        SUM(CAST(SB AS INT)), 
        SUM(CAST(SH AS INT)),
        SUM(CAST(SF AS INT)), 
        SUM(CAST(CS AS INT)), 
        SUM(CAST(AB AS INT))
    FROM BATTING B
    INNER JOIN PEOPLE P ON B.playerID = P.playerID
    WHERE CONVERT(DATE, ks835_Date_Last_Update) <> CONVERT(DATE, GETDATE())
       OR ks835_Date_Last_Update IS NULL
    GROUP BY B.playerID;

    OPEN player_cursor;

    -- Fetch the first row
    FETCH NEXT FROM player_cursor INTO 
        @playerID, @H, @B2, @B3, @HR, @BB, @HBP, @SB, @SH, @SF, @CS, @AB;

    -- Get number of rows in the cursor
    PRINT 'Rows in cursor: ' + CAST(@@CURSOR_ROWS AS VARCHAR(10));

    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE @numerator FLOAT, @denominator FLOAT;

        SET @numerator = 
            @H + 
            (@H + 2.0*@B2 + 3.0*@B3 + 4.0*@HR + @BB) + 
            (1.5 * (@BB + @HBP)) + 
            @SB + 
            @SH + 
            @SF;

        SET @denominator = 
            @AB + @BB + @HBP + @SH + @SF + @CS + (CAST(@SB AS FLOAT) / 3.0);

        IF @denominator = 0
            SET @EqA = NULL;
        ELSE
            SET @EqA = @numerator / @denominator;

        -- Update PEOPLE table
        UPDATE PEOPLE
        SET 
            ks835_Career_EqA = @EqA,
            ks835_Date_Last_Update = GETDATE()
        WHERE playerID = @playerID;

        SET @rowCounter = @rowCounter + 1;

        -- Progress report every 1000 rows
        IF @rowCounter % 1000 = 0
        BEGIN
            PRINT 'Updated ' + CAST(@rowCounter AS VARCHAR(10)) + 
                  ' rows as of ' + CONVERT(VARCHAR, GETDATE(), 120);
        END;

        FETCH NEXT FROM player_cursor INTO 
            @playerID, @H, @B2, @B3, @HR, @BB, @HBP, @SB, @SH, @SF, @CS, @AB;
    END;

    CLOSE player_cursor;
    DEALLOCATE player_cursor;

    PRINT 'Update complete at ' + CONVERT(VARCHAR, GETDATE(), 120) + 
          ' | Total updated: ' + CAST(@rowCounter AS VARCHAR(10));
END;
GO

-- ### PART 3 ###
-- First run
EXEC ks835_Update_EqA_If_Stale;

-- ### PART 4 ###
-- Second run (should show 0 rows in cursor if run same day)
EXEC ks835_Update_EqA_If_Stale;

-- ### PART 5 ###
SELECT 
    playerID, 
    ks835_Career_EqA, 
    ks835_Date_Last_Update
FROM PEOPLE;

