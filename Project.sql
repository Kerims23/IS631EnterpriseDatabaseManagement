-- PART 1

-- ### Creating the necessary geography column.

-- Add a geography column
ALTER TABLE [dbo].[aqs_sites]
ADD geoLocation geography;

-- ### Populating it using existing latitude and longitude.

-- Update the column with geography points using existing Latitude and Longitude
UPDATE [dbo].[aqs_sites]
SET geoLocation = geography::Point(Latitude, Longitude, 4326)
WHERE Latitude IS NOT NULL AND Longitude IS NOT NULL;





-- PART 2



-- Drop the procedure if it exists
IF OBJECT_ID('ks835_Calc_GEO_Distance', 'P') IS NOT NULL
    DROP PROCEDURE ks835_Calc_GEO_Distance;
GO

-- Create the stored procedure
CREATE PROCEDURE ks835_Calc_GEO_Distance
    @latitude FLOAT,
    @longitude FLOAT,
    @State NVARCHAR(100),
    @rownum INT
AS
BEGIN
    -- Create the geography point for the starting location
    DECLARE @h GEOGRAPHY = GEOGRAPHY::Point(@latitude, @longitude, 4326);

    -- Query to return city data with distance and hours of travel
    SELECT TOP (@rownum)
        Site_Number,
        ISNULL(Local_Site_Name, CAST(Site_Number AS NVARCHAR) + '_' + City_Name) AS Local_Site_Name,
        Address,
        City_Name,
        State_Name,
        Zip_Code,
        geoLocation.STDistance(@h) AS Distance_In_Meters,
        Latitude,
        Longitude,
        (geoLocation.STDistance(@h) * 0.000621371) / 55 AS Hours_of_Travel
    FROM [dbo].[aqs_sites]
    WHERE State_Name = @State
      AND geoLocation IS NOT NULL
    ORDER BY geoLocation.STDistance(@h);
END;
GO


-- PART 3

-- First test case
EXEC ks835_Calc_GEO_Distance
    @latitude = 36.778261,
    @longitude = -119.417932,
    @State = 'California',
    @rownum = 30;
GO

-- Second test case
EXEC ks835_Calc_GEO_Distance
    @latitude = 40.712776,
    @longitude = -74.005974,
    @State = 'New York',
    @rownum = 25;
GO

