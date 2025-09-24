-- ============================================
-- STEP 1: Create a new database for Play Store analysis
-- ============================================
USE master;	
CREATE DATABASE PlayStore_Data;
USE PlayStore_Data;

-- ============================================
-- STEP 2: Create the FINAL table (Apps_Data)
-- This table stores clean and validated app details
-- ============================================
CREATE TABLE Apps_Data (
    App             VARCHAR(255),         -- App name
    Category        VARCHAR(50),          -- App category
    Rating          DECIMAL(2,1),         -- Rating (e.g., 4.5)
    Reviews         BIGINT,               -- Total number of reviews
    SizeInMB        DECIMAL(6,2),         -- App size in MB
    Installs        BIGINT,               -- Number of installs
    Type            VARCHAR(20),          -- Free/Paid
    PriceInDollar   DECIMAL(6,2),         -- App price in dollars
    Content_Rating  VARCHAR(50),          -- Age/content rating
    Genres          VARCHAR(100),         -- Genres
    Last_Updated    DATE,                 -- Last updated date
    Update_Year     INT,                  -- Year of update
    Revenue         DECIMAL(18,2),        -- Revenue (if available)
    Log_Installs    DECIMAL(15,8),        -- Log-transformed installs
    Log_Reviews     DECIMAL(15,8),        -- Log-transformed reviews
    Rating_group    VARCHAR(50)           -- Rating category (e.g., Top Rated App)
);

-- ============================================
-- STEP 3: Create a STAGING table (Apps_Data_Staging)
-- This table will temporarily hold raw data from CSV 
-- All columns are NVARCHAR to avoid type mismatch errors
-- ============================================
CREATE TABLE Apps_Data_Staging (
    App             NVARCHAR(MAX),
    Category        NVARCHAR(MAX),
    Rating          NVARCHAR(MAX),
    Reviews         NVARCHAR(MAX),
    SizeInMB        NVARCHAR(MAX),
    Installs        NVARCHAR(MAX),
    Type            NVARCHAR(MAX),
    PriceInDollar   NVARCHAR(MAX),
    Content_Rating  NVARCHAR(MAX),
    Genres          NVARCHAR(MAX),
    Last_Updated    NVARCHAR(MAX),
    Update_Year     NVARCHAR(MAX),
    Revenue         NVARCHAR(MAX),
    Log_Installs    NVARCHAR(MAX),
    Log_Reviews     NVARCHAR(MAX),
    Rating_group    NVARCHAR(MAX)
);

-- ============================================
-- STEP 4: Load raw CSV data into STAGING table
-- BULK INSERT reads data from CSV into SQL Server
-- ============================================
BULK INSERT Apps_Data_Staging
FROM 'D:\Google Play Store Dataset\Clean Play Store Data.csv'
WITH(
    FORMAT = 'CSV',
    FIRSTROW = 2,              -- Skip header row
    FIELDTERMINATOR = ',',     -- CSV delimiter
    ROWTERMINATOR = '\n',      -- End of line
    TABLOCK,
    CODEPAGE = '65001'         -- UTF-8 encoding for special characters
);

-- ============================================
-- STEP 5: Transform and insert clean data into FINAL table
-- TRY_CAST converts values into correct datatypes
-- If conversion fails, it returns NULL (avoids errors)
-- ============================================
INSERT INTO Apps_Data
SELECT
    App,
    Category,
    TRY_CAST(Rating AS DECIMAL(2,1)), 
    TRY_CAST(Reviews AS BIGINT),
    TRY_CAST(SizeInMB AS DECIMAL(6,2)),
    TRY_CAST(Installs AS BIGINT),
    Type,
    TRY_CAST(PriceInDollar AS DECIMAL(6,2)),
    Content_Rating,
    Genres,
    TRY_CAST(Last_Updated AS DATE),
    TRY_CAST(Update_Year AS INT),
    TRY_CAST(Revenue AS DECIMAL(18,2)),
    TRY_CAST(Log_Installs AS DECIMAL(15,8)),
    TRY_CAST(Log_Reviews AS DECIMAL(15,8)),
    Rating_group
FROM Apps_Data_Staging;

-- ============================================
-- STEP 6: Verify data load by checking first 5 rows
-- ============================================
SELECT TOP 5 * FROM Apps_Data;

-- ============================================
-- STEP 7: Check the schema of FINAL table
-- This query shows datatypes and column definitions
-- ============================================
SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    CHARACTER_MAXIMUM_LENGTH,
    NUMERIC_PRECISION, 
    NUMERIC_SCALE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Apps_Data';


----------------------------------------------------------------------------
-- ============================================
-- STEP 1: Create table for Sentiment Analysis data
-- This will store review sentiment metrics
-- ============================================
CREATE TABLE App_Sentiment_Analysis (
    App                  VARCHAR(255),     -- App name
    Total_Review         INT,              -- Total reviews analyzed
    Avg_Polarity         DECIMAL(9,6),     -- Average polarity score
    Avg_Subjectivity     DECIMAL(9,6),     -- Average subjectivity score
    Avg_Sentiment_score  DECIMAL(9,6),     -- Average sentiment score
    Negative_Review      INT,              -- Count of negative reviews
    Neutral_Review       INT,              -- Count of neutral reviews
    Positive_Review      INT               -- Count of positive reviews
);

-- ============================================
-- STEP 2: Load sentiment analysis data from CSV
-- ============================================
BULK INSERT App_Sentiment_Analysis
FROM 'D:/Google Play Store Dataset/Clean User Reviews Data.csv'
WITH(
    FORMAT = 'CSV',
    FIRSTROW = 2,              -- Skip header
    FIELDTERMINATOR = ',',     -- CSV delimiter
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',        -- UTF-8 encoding
    TABLOCK
);

-- ============================================
-- STEP 3: Verify data load by checking first 5 rows
-- ============================================
SELECT TOP 5 * FROM App_Sentiment_Analysis;
