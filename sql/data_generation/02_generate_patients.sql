-- ============================================================================
-- Pharmacy2U Demo - Patient Data Generation (SQL-based)
-- Purpose: Generate 100K realistic UK patient records
-- Target: 100K+ records in <2 minutes (SQL Tier 2 approach)
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE PHARMACY2U_BRONZE;
USE SCHEMA RAW_DATA;
USE WAREHOUSE PHARMACY2U_LOADING_WH;

-- Clear existing data
TRUNCATE TABLE IF EXISTS RAW_PATIENTS;

-- Generate 100K patient records
INSERT INTO RAW_PATIENTS (
    PATIENT_ID,
    FIRST_NAME,
    LAST_NAME,
    DATE_OF_BIRTH,
    GENDER,
    NHS_NUMBER,
    POSTCODE,
    EMAIL,
    PHONE,
    REGISTRATION_DATE,
    INGESTION_TIMESTAMP,
    SOURCE_SYSTEM
)
SELECT
    'PT-' || LPAD(SEQ4(), 8, '0') AS PATIENT_ID,
    CASE UNIFORM(1, 20, RANDOM())
        WHEN 1 THEN 'James' WHEN 2 THEN 'Mary' WHEN 3 THEN 'John'
        WHEN 4 THEN 'Patricia' WHEN 5 THEN 'Robert' WHEN 6 THEN 'Jennifer'
        WHEN 7 THEN 'Michael' WHEN 8 THEN 'Linda' WHEN 9 THEN 'William'
        WHEN 10 THEN 'Elizabeth' WHEN 11 THEN 'David' WHEN 12 THEN 'Barbara'
        WHEN 13 THEN 'Richard' WHEN 14 THEN 'Susan' WHEN 15 THEN 'Joseph'
        WHEN 16 THEN 'Jessica' WHEN 17 THEN 'Thomas' WHEN 18 THEN 'Sarah'
        WHEN 19 THEN 'Charles' ELSE 'Karen'
    END AS FIRST_NAME,
    CASE UNIFORM(1, 20, RANDOM())
        WHEN 1 THEN 'Smith' WHEN 2 THEN 'Jones' WHEN 3 THEN 'Williams'
        WHEN 4 THEN 'Brown' WHEN 5 THEN 'Taylor' WHEN 6 THEN 'Davies'
        WHEN 7 THEN 'Wilson' WHEN 8 THEN 'Evans' WHEN 9 THEN 'Thomas'
        WHEN 10 THEN 'Johnson' WHEN 11 THEN 'Roberts' WHEN 12 THEN 'Walker'
        WHEN 13 THEN 'Wright' WHEN 14 THEN 'Robinson' WHEN 15 THEN 'Thompson'
        WHEN 16 THEN 'White' WHEN 17 THEN 'Hughes' WHEN 18 THEN 'Edwards'
        WHEN 19 THEN 'Green' ELSE 'Lewis'
    END AS LAST_NAME,
    DATEADD(
        DAY, 
        -UNIFORM(18*365, 90*365, RANDOM()),
        CURRENT_DATE()
    ) AS DATE_OF_BIRTH,
    CASE WHEN UNIFORM(1, 100, RANDOM()) <= 51 THEN 'Female' ELSE 'Male' END AS GENDER,
    LPAD(UNIFORM(100000000, 999999999, RANDOM()), 10, '0') AS NHS_NUMBER,
    CASE UNIFORM(1, 10, RANDOM())
        WHEN 1 THEN 'SW1A 1AA' WHEN 2 THEN 'M1 1AD' WHEN 3 THEN 'B2 4QA'
        WHEN 4 THEN 'LS1 1BA' WHEN 5 THEN 'NE1 1EE' WHEN 6 THEN 'G1 1AA'
        WHEN 7 THEN 'CF10 1DD' WHEN 8 THEN 'EH1 1YZ' WHEN 9 THEN 'BS1 1AA'
        ELSE 'L1 1AA'
    END AS POSTCODE,
    LOWER(
        CASE UNIFORM(1, 20, RANDOM())
            WHEN 1 THEN 'james' WHEN 2 THEN 'mary' WHEN 3 THEN 'john'
            WHEN 4 THEN 'patricia' WHEN 5 THEN 'robert' WHEN 6 THEN 'jennifer'
            ELSE 'patient'
        END || '.' || 
        CASE UNIFORM(1, 10, RANDOM())
            WHEN 1 THEN 'smith' WHEN 2 THEN 'jones' WHEN 3 THEN 'williams'
            ELSE 'user'
        END || 
        UNIFORM(100, 9999, RANDOM()) || '@email.com'
    ) AS EMAIL,
    '07' || LPAD(UNIFORM(100000000, 999999999, RANDOM()), 9, '0') AS PHONE,
    DATEADD(
        DAY, 
        -UNIFORM(0, 1825, RANDOM()),
        CURRENT_DATE()
    ) AS REGISTRATION_DATE,
    CURRENT_TIMESTAMP() AS INGESTION_TIMESTAMP,
    'POSTGRESQL' AS SOURCE_SYSTEM
FROM TABLE(GENERATOR(ROWCOUNT => 100000));

-- Validate data generation
SELECT 
    'RAW_PATIENTS' AS TABLE_NAME,
    COUNT(*) AS RECORD_COUNT,
    COUNT(DISTINCT PATIENT_ID) AS UNIQUE_PATIENTS,
    MIN(DATE_OF_BIRTH) AS OLDEST_PATIENT,
    MAX(DATE_OF_BIRTH) AS YOUNGEST_PATIENT,
    AVG(DATEDIFF(YEAR, DATE_OF_BIRTH, CURRENT_DATE())) AS AVG_AGE,
    COUNT(DISTINCT POSTCODE) AS UNIQUE_POSTCODES
FROM RAW_PATIENTS;

-- Show sample data
SELECT * FROM RAW_PATIENTS LIMIT 10;

SELECT '✅ Patient data generation completed successfully' AS STATUS;
