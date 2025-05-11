-- ### PART 1

-- Add columns to PEOPLE table
ALTER TABLE PEOPLE
ADD ks835_Total_G_Played INT,
    ks835_Career_Range_Factor FLOAT;

-- Populate ks835_Total_G_Played
UPDATE PEOPLE
SET ks835_Total_G_Played = (
    SELECT SUM(G)
    FROM FIELDING
    WHERE FIELDING.playerID = PEOPLE.playerID
);

-- Populate ks835_Career_Range_Factor
UPDATE PEOPLE
SET ks835_Career_Range_Factor = (
    SELECT 
        CASE 
            WHEN SUM(CAST(InnOuts AS FLOAT)) = 0 THEN NULL
            ELSE 9.0 * SUM(PO + A) / (SUM(CAST(InnOuts AS FLOAT)) / 3.0)
        END
    FROM FIELDING
    WHERE FIELDING.playerID = PEOPLE.playerID
);

-- ### PART 2
-- Drop trigger if it exists
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'ks835_Fielding_Update_Trigger')
DROP TRIGGER ks835_Fielding_Update_Trigger;
GO

-- Create trigger
CREATE TRIGGER ks835_Fielding_Update_Trigger
ON FIELDING
AFTER INSERT, DELETE, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @playerID CHAR(10);

    -- Determine command
    IF EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
    BEGIN
        -- UPDATE
        SELECT TOP 1 @playerID = playerID FROM INSERTED;

        -- Recalculate values
        UPDATE PEOPLE
        SET ks835_Total_G_Played = (
            SELECT SUM(G)
            FROM FIELDING
            WHERE FIELDING.playerID = @playerID
        ),
        ks835_Career_Range_Factor = (
            SELECT 
                CASE 
                    WHEN SUM(CAST(InnOuts AS FLOAT)) = 0 THEN NULL
                    ELSE 9.0 * SUM(PO + A) / (SUM(CAST(InnOuts AS FLOAT)) / 3.0)
                END
            FROM FIELDING
            WHERE FIELDING.playerID = @playerID
        )
        WHERE playerID = @playerID;
    END
    ELSE IF EXISTS (SELECT * FROM INSERTED)
    BEGIN
        -- INSERT
        SELECT TOP 1 @playerID = playerID FROM INSERTED;

        UPDATE PEOPLE
        SET ks835_Total_G_Played = (
            SELECT SUM(G)
            FROM FIELDING
            WHERE FIELDING.playerID = @playerID
        ),
        ks835_Career_Range_Factor = (
            SELECT 
                CASE 
                    WHEN SUM(CAST(InnOuts AS FLOAT)) = 0 THEN NULL
                    ELSE 9.0 * SUM(PO + A) / (SUM(CAST(InnOuts AS FLOAT)) / 3.0)
                END
            FROM FIELDING
            WHERE FIELDING.playerID = @playerID
        )
        WHERE playerID = @playerID;
    END
    ELSE IF EXISTS (SELECT * FROM DELETED)
    BEGIN
        -- DELETE
        SELECT TOP 1 @playerID = playerID FROM DELETED;

        UPDATE PEOPLE
        SET ks835_Total_G_Played = (
            SELECT SUM(G)
            FROM FIELDING
            WHERE FIELDING.playerID = @playerID
        ),
        ks835_Career_Range_Factor = (
            SELECT 
                CASE 
                    WHEN SUM(CAST(InnOuts AS FLOAT)) = 0 THEN NULL
                    ELSE 9.0 * SUM(PO + A) / (SUM(CAST(InnOuts AS FLOAT)) / 3.0)
                END
            FROM FIELDING
            WHERE FIELDING.playerID = @playerID
        )
        WHERE playerID = @playerID;
    END
END;
GO


-- ### PART 3

-- # Insert Section -- 
-- Before
SELECT * FROM PEOPLE WHERE playerID = 'willite01'; -- only 1
SELECT * FROM FIELDING WHERE playerID = 'willite01'; -- 20
-- Insert
INSERT INTO FIELDING (playerID, yearID, stint, teamID, lgID, POS, G, PO, A, E, DP, InnOuts)
VALUES ('willite01', 1950, 1, 'BOS', 'AL', 'LF', 10, 20, 5, 1, 0, 810);
-- After
SELECT * FROM PEOPLE WHERE playerID = 'willite01'; -- still 1 
SELECT * FROM FIELDING WHERE playerID = 'willite01'; -- 21 now

-- # Update Section -- 
-- Before
SELECT * FROM PEOPLE WHERE playerID = 'willite01'; -- 1 
SELECT * FROM FIELDING WHERE playerID = 'willite01' AND yearID = 1950; -- 2 
-- Update
UPDATE FIELDING
SET G = 15, PO = 25, A = 7, InnOuts = 900
WHERE playerID = 'willite01' AND yearID = 1950;
-- After
SELECT * FROM PEOPLE WHERE playerID = 'willite01'; 
SELECT * FROM FIELDING WHERE playerID = 'willite01';

-- # Delete Section -- 
-- Before
SELECT * FROM PEOPLE WHERE playerID = 'willite01';
SELECT * FROM FIELDING WHERE playerID = 'willite01';
-- Delete
DELETE FROM FIELDING
WHERE playerID = 'willite01' AND yearID = 1950;
-- After
SELECT * FROM PEOPLE WHERE playerID = 'willite01';
SELECT * FROM FIELDING WHERE playerID = 'willite01';


-- ### PART 4
DISABLE TRIGGER ks835_Fielding_Update_Trigger ON FIELDING;


