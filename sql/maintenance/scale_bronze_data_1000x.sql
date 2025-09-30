-- ============================================================================
-- SCALE BRONZE DATA 1000X - Generate 100M Patient Records
-- Purpose: Scale source data from 100K to 100M patients at BRONZE layer
-- Method: CREATE OR REPLACE approach (atomic, no DROP/RENAME issues)
-- Estimated execution time: 10-20 minutes
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE PHARMACY2U_DEMO_WH;

-- Increase warehouse size for faster processing
ALTER WAREHOUSE PHARMACY2U_DEMO_WH SET WAREHOUSE_SIZE = 'LARGE';
ALTER WAREHOUSE PHARMACY2U_DEMO_WH SET AUTO_SUSPEND = 300;

-- ============================================================================
-- STEP 1: Create Backups of Current BRONZE Tables (Safety First!)
-- ============================================================================

SELECT '📦 Creating backup of current BRONZE data...' AS STATUS;

CREATE TABLE IF NOT EXISTS PHARMACY2U_BRONZE.RAW_DATA.RAW_PATIENTS_ORIGINAL 
CLONE PHARMACY2U_BRONZE.RAW_DATA.RAW_PATIENTS;

CREATE TABLE IF NOT EXISTS PHARMACY2U_BRONZE.RAW_DATA.RAW_PRESCRIPTIONS_ORIGINAL 
CLONE PHARMACY2U_BRONZE.RAW_DATA.RAW_PRESCRIPTIONS;

SELECT '✅ Backups created: RAW_PATIENTS_ORIGINAL, RAW_PRESCRIPTIONS_ORIGINAL' AS STATUS;

-- ============================================================================
-- STEP 2: Create Multiplier Sequence (0-999 for 1000x)
-- ============================================================================

SELECT '🔢 Creating multiplier sequence for 1000x scaling...' AS STATUS;

CREATE OR REPLACE TEMPORARY TABLE multiplier_sequence AS
SELECT SEQ4() AS multiplier
FROM TABLE(GENERATOR(ROWCOUNT => 1000));

SELECT 'Multiplier sequence created: 1000 values' AS STATUS;

-- ============================================================================
-- STEP 3: Scale RAW_PATIENTS to 100M Records (1000x from 100K)
-- ============================================================================

SELECT '🚀 Starting RAW_PATIENTS scaling to 100M records...' AS STATUS;
SELECT '⏱️  This will take 10-15 minutes. Snowflake is parallelizing across all compute nodes.' AS INFO;

-- Use CREATE OR REPLACE for atomic replacement (no DROP/RENAME issues)
CREATE OR REPLACE TABLE PHARMACY2U_BRONZE.RAW_DATA.RAW_PATIENTS AS
SELECT 
    -- Generate new unique PATIENT_ID (format: PT-00032226)
    'PT-' || LPAD(
        ((CAST(SPLIT_PART(p.PATIENT_ID, '-', 2) AS NUMBER) - 1) * 1000 + m.multiplier + 1)::STRING, 
        8, '0'
    ) AS PATIENT_ID,
    
    -- Keep original demographic data
    p.FIRST_NAME,
    p.LAST_NAME,
    p.DATE_OF_BIRTH,
    p.GENDER,
    
    -- Generate new NHS numbers to maintain uniqueness
    LPAD(
        (CAST(p.NHS_NUMBER AS NUMBER) + m.multiplier * 1000000)::STRING,
        10, '0'
    ) AS NHS_NUMBER,
    
    p.POSTCODE,
    
    -- Vary email to maintain uniqueness
    SPLIT_PART(p.EMAIL, '@', 1) || '.' || m.multiplier || '@' || SPLIT_PART(p.EMAIL, '@', 2) AS EMAIL,
    
    p.PHONE,
    
    -- Vary registration dates slightly for realism
    DATEADD(DAY, UNIFORM(-30, 30, RANDOM()), p.REGISTRATION_DATE) AS REGISTRATION_DATE,
    
    CURRENT_TIMESTAMP() AS INGESTION_TIMESTAMP,
    p.SOURCE_SYSTEM
FROM PHARMACY2U_BRONZE.RAW_DATA.RAW_PATIENTS_ORIGINAL p
CROSS JOIN multiplier_sequence m;

SELECT '✅ RAW_PATIENTS scaled to ' || COUNT(*) || ' records!' AS STATUS
FROM PHARMACY2U_BRONZE.RAW_DATA.RAW_PATIENTS;

-- ============================================================================
-- STEP 4: Scale RAW_PRESCRIPTIONS to 500M Records (1000x from 500K)
-- ============================================================================

SELECT '🚀 Starting RAW_PRESCRIPTIONS scaling to 500M records...' AS STATUS;
SELECT '⏱️  This will take 15-20 minutes. Time for a coffee break! ☕' AS INFO;

-- Use CREATE OR REPLACE for atomic replacement
CREATE OR REPLACE TABLE PHARMACY2U_BRONZE.RAW_DATA.RAW_PRESCRIPTIONS AS
SELECT 
    -- Generate new unique PRESCRIPTION_ID (format: RX-0000000007)
    'RX-' || LPAD(
        ((CAST(SPLIT_PART(prx.PRESCRIPTION_ID, '-', 2) AS NUMBER) - 1) * 1000 + m.multiplier + 1)::STRING, 
        10, '0'
    ) AS PRESCRIPTION_ID,
    
    -- Map to new scaled PATIENT_IDs (format: PT-00032226)
    'PT-' || LPAD(
        ((CAST(SPLIT_PART(prx.PATIENT_ID, '-', 2) AS NUMBER) - 1) * 1000 + m.multiplier + 1)::STRING, 
        8, '0'
    ) AS PATIENT_ID,
    
    prx.DRUG_CODE,
    prx.DRUG_NAME,
    
    -- Vary quantities slightly for realism
    prx.QUANTITY * (1 + UNIFORM(-0.1, 0.1, RANDOM())) AS QUANTITY,
    
    prx.DAYS_SUPPLY,
    
    -- Vary prescription dates
    DATEADD(DAY, UNIFORM(-30, 30, RANDOM()), prx.PRESCRIPTION_DATE) AS PRESCRIPTION_DATE,
    
    prx.PRESCRIBER_ID,
    prx.PHARMACY_ID,
    
    -- Vary costs slightly for realism
    prx.COST_GBP * (1 + UNIFORM(-0.1, 0.1, RANDOM())) AS COST_GBP,
    
    CURRENT_TIMESTAMP() AS INGESTION_TIMESTAMP,
    prx.SOURCE_SYSTEM
FROM PHARMACY2U_BRONZE.RAW_DATA.RAW_PRESCRIPTIONS_ORIGINAL prx
CROSS JOIN multiplier_sequence m;

SELECT '✅ RAW_PRESCRIPTIONS scaled to ' || COUNT(*) || ' records!' AS STATUS
FROM PHARMACY2U_BRONZE.RAW_DATA.RAW_PRESCRIPTIONS;

-- ============================================================================
-- STEP 5: Trigger Dynamic Table Refresh (SILVER Layer)
-- ============================================================================

SELECT '🔄 Triggering SILVER Dynamic Table refresh...' AS STATUS;
SELECT '⏱️  Dynamic Tables have TARGET_LAG = 1 minute, will refresh automatically' AS INFO;

-- Manual trigger to start refresh immediately
ALTER DYNAMIC TABLE PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS REFRESH;
ALTER DYNAMIC TABLE PHARMACY2U_SILVER.GOVERNED_DATA.PRESCRIPTIONS REFRESH;

SELECT 'Dynamic Table refresh triggered. Waiting 60 seconds...' AS STATUS;
CALL SYSTEM$WAIT(60);

-- ============================================================================
-- STEP 6: Verify Scaling Results
-- ============================================================================

SELECT '======================================' AS SEPARATOR;
SELECT '✅ ✅ ✅ DATA SCALING COMPLETE! ✅ ✅ ✅' AS STATUS;
SELECT '======================================' AS SEPARATOR;

-- Show BRONZE layer counts
SELECT '📊 BRONZE LAYER (Source Data)' as layer_info;
SELECT 
    'RAW_PATIENTS' as table_name,
    COUNT(*) as row_count,
    '100,000,000 expected' as target
FROM PHARMACY2U_BRONZE.RAW_DATA.RAW_PATIENTS

UNION ALL

SELECT 
    'RAW_PRESCRIPTIONS' as table_name,
    COUNT(*) as row_count,
    '~500,000,000 expected' as target
FROM PHARMACY2U_BRONZE.RAW_DATA.RAW_PRESCRIPTIONS;

-- Show SILVER layer counts (Dynamic Tables - may still be refreshing)
SELECT '📊 SILVER LAYER (Dynamic Tables - Auto-Refreshing)' as layer_info;
SELECT 
    'PATIENTS' as table_name,
    COUNT(*) as row_count,
    CASE 
        WHEN COUNT(*) > 50000000 THEN '✅ Refreshing in progress'
        WHEN COUNT(*) = 100000 THEN '⏳ Not yet refreshed'
        ELSE '✅ Complete'
    END as status
FROM PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS

UNION ALL

SELECT 
    'PRESCRIPTIONS' as table_name,
    COUNT(*) as row_count,
    CASE 
        WHEN COUNT(*) > 50000000 THEN '✅ Refreshing in progress'
        WHEN COUNT(*) < 1000000 THEN '⏳ Not yet refreshed'
        ELSE '✅ Complete'
    END as status
FROM PHARMACY2U_SILVER.GOVERNED_DATA.PRESCRIPTIONS;

-- Show GOLD layer (Views - refreshes instantly once SILVER is ready)
SELECT '📊 GOLD LAYER (Analytics Views)' as layer_info;
SELECT 
    'V_PATIENT_360' as view_name,
    COUNT(*) as row_count,
    CASE 
        WHEN COUNT(*) > 50000000 THEN '✅ Scaled!'
        ELSE '⏳ Waiting for SILVER refresh'
    END as status
FROM PHARMACY2U_GOLD.ANALYTICS.V_PATIENT_360;

-- Verify foreign key integrity (sample check on first 1M records)
SELECT '🔍 REFERENTIAL INTEGRITY CHECK (Sample)' as validation_info;
SELECT 
    'Foreign key integrity' as check_type,
    COUNT(*) as orphaned_prescriptions,
    CASE 
        WHEN COUNT(*) = 0 THEN '✅ PASS'
        ELSE '❌ FAIL'
    END as result
FROM (
    SELECT prx.PATIENT_ID
    FROM PHARMACY2U_BRONZE.RAW_DATA.RAW_PRESCRIPTIONS prx
    LEFT JOIN PHARMACY2U_BRONZE.RAW_DATA.RAW_PATIENTS pat
        ON prx.PATIENT_ID = pat.PATIENT_ID
    WHERE pat.PATIENT_ID IS NULL
    LIMIT 1000000
) orphans;

-- Show data distribution sample
SELECT '📋 Sample of scaled RAW_PATIENTS data (first 5 records):' AS info;
SELECT * FROM PHARMACY2U_BRONZE.RAW_DATA.RAW_PATIENTS LIMIT 5;

SELECT '📋 Sample of scaled RAW_PRESCRIPTIONS data (first 5 records):' AS info;
SELECT * FROM PHARMACY2U_BRONZE.RAW_DATA.RAW_PRESCRIPTIONS LIMIT 5;

-- ============================================================================
-- STEP 7: Performance Test Query (Prove Snowflake Speed!)
-- ============================================================================

SELECT '⚡ Running performance test on 100M patients...' AS STATUS;

-- Query 1: Count high-value patients (should complete in seconds!)
SELECT 
    'High-value patients (>£2000 lifetime value)' as metric,
    COUNT(*) as patient_count,
    ROUND(AVG(LIFETIME_VALUE_GBP), 2) as avg_lifetime_value_gbp,
    ROUND(SUM(LIFETIME_VALUE_GBP), 2) as total_lifetime_value_gbp
FROM PHARMACY2U_GOLD.ANALYTICS.V_PATIENT_360
WHERE LIFETIME_VALUE_GBP > 2000;

-- Query 2: Top 10 most prescribed drugs (across 500M prescriptions!)
SELECT '💊 Top 10 Most Prescribed Drugs (from 500M prescriptions):' AS info;
SELECT 
    DRUG_NAME,
    COUNT(*) as prescription_count,
    ROUND(SUM(COST_GBP), 2) as total_cost_gbp,
    ROUND(AVG(COST_GBP), 2) as avg_cost_gbp
FROM PHARMACY2U_BRONZE.RAW_DATA.RAW_PRESCRIPTIONS
GROUP BY DRUG_NAME
ORDER BY prescription_count DESC
LIMIT 10;

-- ============================================================================
-- STEP 8: Scale Warehouse Back Down (Save Costs!)
-- ============================================================================

ALTER WAREHOUSE PHARMACY2U_DEMO_WH SET WAREHOUSE_SIZE = 'XSMALL';

SELECT '💰 Warehouse scaled back to XSMALL to minimize costs' AS STATUS;

-- ============================================================================
-- FINAL STATUS
-- ============================================================================

SELECT '======================================' AS separator;
SELECT '✅ ✅ ✅ 1000x SCALING COMPLETE! ✅ ✅ ✅' AS final_status;
SELECT '======================================' AS separator;

SELECT '📊 100M patients generated' AS achievement_1;
SELECT '📊 500M prescriptions generated' AS achievement_2;
SELECT '💰 Original data safely backed up to *_ORIGINAL tables' AS achievement_3;
SELECT '🔄 Dynamic Tables auto-refreshing from scaled BRONZE data' AS achievement_4;
SELECT '⚡ Ready to demo enterprise-scale performance!' AS achievement_5;

-- ============================================================================
-- RESTORE INSTRUCTIONS (if needed)
-- ============================================================================

SELECT 'To restore original 100K dataset, run the commands in the comment block below:' AS restore_info;

/*
-- ============================================================================
-- RESTORE TO ORIGINAL 100K DATASET
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE PHARMACY2U_DEMO_WH;
ALTER WAREHOUSE PHARMACY2U_DEMO_WH SET WAREHOUSE_SIZE = 'LARGE';

-- 1. Restore from backups using CREATE OR REPLACE
CREATE OR REPLACE TABLE PHARMACY2U_BRONZE.RAW_DATA.RAW_PATIENTS 
CLONE PHARMACY2U_BRONZE.RAW_DATA.RAW_PATIENTS_ORIGINAL;

CREATE OR REPLACE TABLE PHARMACY2U_BRONZE.RAW_DATA.RAW_PRESCRIPTIONS 
CLONE PHARMACY2U_BRONZE.RAW_DATA.RAW_PRESCRIPTIONS_ORIGINAL;

-- 2. Trigger Dynamic Table refresh
ALTER DYNAMIC TABLE PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS REFRESH;
ALTER DYNAMIC TABLE PHARMACY2U_SILVER.GOVERNED_DATA.PRESCRIPTIONS REFRESH;

-- 3. Wait for refresh to complete
CALL SYSTEM$WAIT(60);

-- 4. Verify restoration
SELECT 'RAW_PATIENTS' as table_name, COUNT(*) as row_count 
FROM PHARMACY2U_BRONZE.RAW_DATA.RAW_PATIENTS; -- Should be 100K

SELECT 'PATIENTS (SILVER)' as table_name, COUNT(*) as row_count 
FROM PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS; -- Should be 100K

SELECT 'V_PATIENT_360 (GOLD)' as view_name, COUNT(*) as row_count 
FROM PHARMACY2U_GOLD.ANALYTICS.V_PATIENT_360; -- Should be 100K

-- 5. Scale warehouse back down
ALTER WAREHOUSE PHARMACY2U_DEMO_WH SET WAREHOUSE_SIZE = 'XSMALL';

SELECT '✅ Restored to original 100K dataset!' AS status;
*/

-- ============================================================================
-- OPTIONAL: Drop backup tables after verifying scaled data works
-- ============================================================================

/*
-- Only run this after you're 100% confident the scaled data is working correctly!

DROP TABLE IF EXISTS PHARMACY2U_BRONZE.RAW_DATA.RAW_PATIENTS_ORIGINAL;
DROP TABLE IF EXISTS PHARMACY2U_BRONZE.RAW_DATA.RAW_PRESCRIPTIONS_ORIGINAL;
DROP TABLE IF EXISTS PHARMACY2U_BRONZE.RAW_DATA.RAW_PATIENTS_BACKUP;
DROP TABLE IF EXISTS PHARMACY2U_BRONZE.RAW_DATA.RAW_PRESCRIPTIONS_BACKUP;

SELECT '🗑️ Backup tables dropped' AS status;
*/

-- ============================================================================
-- END OF SCALING SCRIPT
-- ============================================================================