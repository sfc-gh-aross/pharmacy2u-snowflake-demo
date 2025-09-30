-- ============================================================================
-- SCALE DATA 1000X - Generate 100M Patient Records
-- Purpose: Scale demo data from 100K to 100M patients for performance testing
-- Method: Use cross joins with number sequences to replicate data efficiently
-- Estimated execution time: 10-20 minutes (Snowflake parallelizes this)
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE PHARMACY2U_DEMO_WH;

-- Increase warehouse size for faster processing
ALTER WAREHOUSE PHARMACY2U_DEMO_WH SET WAREHOUSE_SIZE = 'LARGE';
ALTER WAREHOUSE PHARMACY2U_DEMO_WH SET AUTO_SUSPEND = 300;

-- ============================================================================
-- STEP 1: Create Backup of Current Tables (Safety First!)
-- ============================================================================

SELECT 'Creating backup tables before scaling...' AS STATUS;

CREATE TABLE IF NOT EXISTS PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS_ORIGINAL 
CLONE PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS;

CREATE TABLE IF NOT EXISTS PHARMACY2U_SILVER.GOVERNED_DATA.PRESCRIPTIONS_ORIGINAL 
CLONE PHARMACY2U_SILVER.GOVERNED_DATA.PRESCRIPTIONS;

SELECT 'Backups created successfully' AS STATUS;

-- ============================================================================
-- STEP 2: Scale PATIENTS Table to 100M Records (1000x from 100K)
-- ============================================================================

SELECT 'Starting PATIENTS table scaling to 100M records...' AS STATUS;
SELECT 'This will take 10-15 minutes. Snowflake is parallelizing the work.' AS INFO;

-- Create a sequence multiplier table (0-999 for 1000x multiplier)
CREATE OR REPLACE TEMPORARY TABLE multiplier_sequence AS
SELECT SEQ4() AS multiplier
FROM TABLE(GENERATOR(ROWCOUNT => 1000));

-- Generate 100M patients by cross-joining original 100K with 1000 multipliers
CREATE OR REPLACE TABLE PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS_TEMP AS
SELECT 
    -- Generate new unique PATIENT_ID (format: PT-00032226)
    'PT-' || LPAD(((CAST(SPLIT_PART(p.PATIENT_ID, '-', 2) AS NUMBER) - 1) * 1000 + m.multiplier + 1)::STRING, 8, '0') AS PATIENT_ID,
    
    -- Keep original data with slight variations
    p.FIRST_NAME,
    p.LAST_NAME,
    p.DATE_OF_BIRTH,
    p.AGE + UNIFORM(0, 2, RANDOM()) AS AGE,  -- Add slight variation
    p.GENDER,
    p.NHS_NUMBER,
    p.POSTCODE,
    p.EMAIL,
    p.PHONE,
    
    -- Vary registration dates
    DATEADD(DAY, UNIFORM(-30, 30, RANDOM()), p.REGISTRATION_DATE) AS REGISTRATION_DATE,
    
    CURRENT_TIMESTAMP() AS PROCESSED_TIMESTAMP
FROM PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS p
CROSS JOIN multiplier_sequence m;

SELECT 'Patients temp table created with ' || COUNT(*) || ' records' AS STATUS
FROM PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS_TEMP;

-- Replace original table with scaled version
ALTER TABLE PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS RENAME TO PATIENTS_OLD;
ALTER TABLE PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS_TEMP RENAME TO PATIENTS;
DROP TABLE PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS_OLD;

SELECT 'PATIENTS table scaled to ' || COUNT(*) || ' records!' AS STATUS
FROM PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS;

-- ============================================================================
-- STEP 3: Scale PRESCRIPTIONS Table to 477M Records (1000x from 477K)
-- ============================================================================

SELECT 'Starting PRESCRIPTIONS table scaling to 477M records...' AS STATUS;
SELECT 'This will take 15-20 minutes. Grab a coffee!' AS INFO;

-- Generate 477M prescriptions by cross-joining original 477K with 1000 multipliers
CREATE OR REPLACE TABLE PHARMACY2U_SILVER.GOVERNED_DATA.PRESCRIPTIONS_TEMP AS
SELECT 
    -- Generate new unique PRESCRIPTION_ID (format: RX-0000000007)
    'RX-' || LPAD(((CAST(SPLIT_PART(prx.PRESCRIPTION_ID, '-', 2) AS NUMBER) - 1) * 1000 + m.multiplier + 1)::STRING, 10, '0') AS PRESCRIPTION_ID,
    
    -- Map to new scaled PATIENT_IDs (format: PT-00032226)
    'PT-' || LPAD(((CAST(SPLIT_PART(prx.PATIENT_ID, '-', 2) AS NUMBER) - 1) * 1000 + m.multiplier + 1)::STRING, 8, '0') AS PATIENT_ID,
    
    -- Keep original prescription data
    prx.DRUG_CODE,
    prx.DRUG_NAME,
    prx.QUANTITY,
    prx.DAYS_SUPPLY,
    
    -- Vary prescription dates
    DATEADD(DAY, UNIFORM(-30, 30, RANDOM()), prx.PRESCRIPTION_DATE) AS PRESCRIPTION_DATE,
    
    prx.PRESCRIBER_ID,
    prx.PHARMACY_ID,
    
    -- Vary costs slightly
    prx.COST_GBP * (1 + UNIFORM(-0.1, 0.1, RANDOM())) AS COST_GBP,
    
    CURRENT_TIMESTAMP() AS PROCESSED_TIMESTAMP
FROM PHARMACY2U_SILVER.GOVERNED_DATA.PRESCRIPTIONS prx
CROSS JOIN multiplier_sequence m;

SELECT 'Prescriptions temp table created with ' || COUNT(*) || ' records' AS STATUS
FROM PHARMACY2U_SILVER.GOVERNED_DATA.PRESCRIPTIONS_TEMP;

-- Replace original table with scaled version
ALTER TABLE PHARMACY2U_SILVER.GOVERNED_DATA.PRESCRIPTIONS RENAME TO PRESCRIPTIONS_OLD;
ALTER TABLE PHARMACY2U_SILVER.GOVERNED_DATA.PRESCRIPTIONS_TEMP RENAME TO PRESCRIPTIONS;
DROP TABLE PHARMACY2U_SILVER.GOVERNED_DATA.PRESCRIPTIONS_OLD;

SELECT 'PRESCRIPTIONS table scaled to ' || COUNT(*) || ' records!' AS STATUS
FROM PHARMACY2U_SILVER.GOVERNED_DATA.PRESCRIPTIONS;

-- ============================================================================
-- STEP 4: Verify Scaling Results
-- ============================================================================

SELECT '======================================' AS SEPARATOR;
SELECT 'DATA SCALING COMPLETE!' AS STATUS;
SELECT '======================================' AS SEPARATOR;

-- Show new record counts
SELECT 
    'PATIENTS' as table_name,
    COUNT(*) as new_row_count,
    '100,000,000 target' as expected
FROM PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS

UNION ALL

SELECT 
    'PRESCRIPTIONS' as table_name,
    COUNT(*) as new_row_count,
    '477,612,000 target' as expected
FROM PHARMACY2U_SILVER.GOVERNED_DATA.PRESCRIPTIONS;

-- Verify foreign key integrity (sample)
SELECT 
    'Foreign key check' as validation_type,
    COUNT(*) as orphaned_prescriptions
FROM PHARMACY2U_SILVER.GOVERNED_DATA.PRESCRIPTIONS prx
LEFT JOIN PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS pat
    ON prx.PATIENT_ID = pat.PATIENT_ID
WHERE pat.PATIENT_ID IS NULL;

-- Show sample of new data
SELECT 'Sample of scaled PATIENTS data:' AS INFO;
SELECT * FROM PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS LIMIT 5;

SELECT 'Sample of scaled PRESCRIPTIONS data:' AS INFO;
SELECT * FROM PHARMACY2U_SILVER.GOVERNED_DATA.PRESCRIPTIONS LIMIT 5;

-- ============================================================================
-- STEP 5: Trigger Dynamic Table Refresh (if needed)
-- ============================================================================

SELECT 'Triggering Dynamic Table refreshes...' AS STATUS;

-- The PATIENTS and PRESCRIPTIONS Dynamic Tables will auto-refresh
-- But we can manually trigger if needed:
-- ALTER DYNAMIC TABLE PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS REFRESH;
-- ALTER DYNAMIC TABLE PHARMACY2U_SILVER.GOVERNED_DATA.PRESCRIPTIONS REFRESH;

-- GOLD layer views will automatically reflect new data (they're just views)
SELECT 'Verifying GOLD layer V_PATIENT_360...' AS STATUS;
SELECT COUNT(*) as patient_360_count 
FROM PHARMACY2U_GOLD.ANALYTICS.V_PATIENT_360;

-- ============================================================================
-- STEP 6: Performance Comparison Queries
-- ============================================================================

SELECT 'Running performance test queries...' AS STATUS;

-- Query 1: Count high-value patients (should be ~1000x more)
SELECT 
    'High-value patients' as metric,
    COUNT(*) as count
FROM PHARMACY2U_GOLD.ANALYTICS.V_PATIENT_360
WHERE LIFETIME_VALUE_GBP > 2000;

-- Query 2: Top drugs prescribed (should still return quickly)
SET start_time = CURRENT_TIMESTAMP();

SELECT 
    DRUG_NAME,
    COUNT(*) as prescription_count,
    SUM(COST_GBP) as total_cost_gbp
FROM PHARMACY2U_SILVER.GOVERNED_DATA.PRESCRIPTIONS
GROUP BY DRUG_NAME
ORDER BY prescription_count DESC
LIMIT 10;

SELECT 
    'Query execution time' as metric,
    DATEDIFF(SECOND, $start_time, CURRENT_TIMESTAMP()) as seconds;

-- ============================================================================
-- STEP 7: Scale Warehouse Back Down
-- ============================================================================

ALTER WAREHOUSE PHARMACY2U_DEMO_WH SET WAREHOUSE_SIZE = 'XSMALL';

SELECT '✅ DATA SCALING COMPLETE!' AS STATUS;
SELECT '📊 100M patients + 477M prescriptions ready for demo!' AS INFO;
SELECT '💰 Original data backed up to *_ORIGINAL tables' AS BACKUP_NOTE;
SELECT '🔄 To restore: DROP TABLE PATIENTS; ALTER TABLE PATIENTS_ORIGINAL RENAME TO PATIENTS;' AS RESTORE_HINT;

-- ============================================================================
-- CLEANUP NOTES
-- ============================================================================

/*
-- To restore original 100K dataset:
DROP TABLE PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS;
DROP TABLE PHARMACY2U_SILVER.GOVERNED_DATA.PRESCRIPTIONS;

ALTER TABLE PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS_ORIGINAL RENAME TO PATIENTS;
ALTER TABLE PHARMACY2U_SILVER.GOVERNED_DATA.PRESCRIPTIONS_ORIGINAL RENAME TO PRESCRIPTIONS;

-- To drop backup tables (after confirming scaled data works):
DROP TABLE IF EXISTS PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS_ORIGINAL;
DROP TABLE IF EXISTS PHARMACY2U_SILVER.GOVERNED_DATA.PRESCRIPTIONS_ORIGINAL;
*/

-- ============================================================================
-- END OF SCALING SCRIPT
-- ============================================================================
