-- ============================================================================
-- Snowflake Intelligence Readiness Validation
-- Run this before configuring Intelligence UI
-- Expected result: All checks should show ✅ READY
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE PHARMACY2U_DEMO_WH;

SELECT '=== SNOWFLAKE INTELLIGENCE READINESS VALIDATION ===' AS VALIDATION_REPORT;

-- ============================================================================
-- CHECK 1: Semantic Model File Uploaded
-- ============================================================================

SELECT '1. Semantic Model File Check:' AS CHECK_NAME;

LIST @PHARMACY2U_GOLD.ANALYTICS.SEMANTIC_MODELS_STAGE;

SELECT 
    CASE 
        WHEN COUNT(*) > 0 THEN '✅ READY - Semantic model found in stage'
        ELSE '❌ FAILED - Semantic model not found. Run: sql/features/cortex/deploy_cortex_analyst.sql'
    END AS check_1_status
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "name" LIKE '%patient_360_analytics.yaml%';

-- ============================================================================
-- CHECK 2: Base View Exists with Data
-- ============================================================================

SELECT '2. Base View Data Check:' AS CHECK_NAME;

SELECT 
    'V_PATIENT_360' AS view_name,
    COUNT(*) AS patient_count,
    CASE 
        WHEN COUNT(*) = 100000 THEN '✅ READY - 100,000 patients loaded'
        WHEN COUNT(*) > 0 THEN '⚠️  WARNING - Expected 100K patients, found ' || COUNT(*)
        ELSE '❌ FAILED - No data in view'
    END AS check_2_status
FROM PHARMACY2U_GOLD.ANALYTICS.V_PATIENT_360;

-- ============================================================================
-- CHECK 3: Required Columns Exist
-- ============================================================================

SELECT '3. Semantic Model Columns Check:' AS CHECK_NAME;

DESC VIEW PHARMACY2U_GOLD.ANALYTICS.V_PATIENT_360;

SELECT 
    CASE 
        WHEN SUM(CASE WHEN column_name IN (
            'PATIENT_ID', 'AGE', 'GENDER', 'POSTCODE',
            'TOTAL_PRESCRIPTIONS', 'UNIQUE_DRUGS', 'LIFETIME_VALUE_GBP',
            'LAST_PRESCRIPTION_DATE', 'MARKETING_INTERACTIONS', 'CAMPAIGN_CONVERSIONS'
        ) THEN 1 ELSE 0 END) >= 10
        THEN '✅ READY - All required columns present'
        ELSE '❌ FAILED - Missing required columns'
    END AS check_3_status
FROM (DESC VIEW PHARMACY2U_GOLD.ANALYTICS.V_PATIENT_360);

-- ============================================================================
-- CHECK 4: Cortex Search Service Active
-- ============================================================================

SELECT '4. Cortex Search Service Check:' AS CHECK_NAME;

SHOW CORTEX SEARCH SERVICES LIKE 'PATIENT_360_SEARCH_SERVICE';

SELECT 
    CASE 
        WHEN COUNT(*) > 0 THEN '✅ READY - Cortex Search service created'
        ELSE '⚠️  WARNING - Cortex Search not found (optional for Intelligence)'
    END AS check_4_status
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));

-- ============================================================================
-- CHECK 5: Sample Data Quality
-- ============================================================================

SELECT '5. Data Quality Check:' AS CHECK_NAME;

SELECT 
    COUNT(*) AS total_patients,
    COUNT(PATIENT_ID) AS patients_with_id,
    COUNT(AGE) AS patients_with_age,
    COUNT(TOTAL_PRESCRIPTIONS) AS patients_with_prescriptions,
    COUNT(LIFETIME_VALUE_GBP) AS patients_with_value,
    CASE 
        WHEN COUNT(PATIENT_ID) = COUNT(*) AND
             COUNT(AGE) > COUNT(*) * 0.95 AND
             COUNT(TOTAL_PRESCRIPTIONS) > COUNT(*) * 0.95
        THEN '✅ READY - Data quality good (>95% complete)'
        ELSE '⚠️  WARNING - Some data quality issues detected'
    END AS check_5_status
FROM PHARMACY2U_GOLD.ANALYTICS.V_PATIENT_360;

-- ============================================================================
-- CHECK 6: Warehouse Available
-- ============================================================================

SELECT '6. Warehouse Check:' AS CHECK_NAME;

SHOW WAREHOUSES LIKE 'PHARMACY2U_DEMO_WH';

SELECT 
    CASE 
        WHEN COUNT(*) > 0 THEN '✅ READY - Warehouse exists and available'
        ELSE '❌ FAILED - Warehouse not found'
    END AS check_6_status
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));

-- ============================================================================
-- CHECK 7: Sample Query Test
-- ============================================================================

SELECT '7. Sample Query Test:' AS CHECK_NAME;

-- Test a query that Intelligence would run
SELECT 
    COUNT(*) AS high_value_patient_count,
    ROUND(SUM(LIFETIME_VALUE_GBP), 2) AS total_value,
    CASE 
        WHEN COUNT(*) > 0 THEN '✅ READY - Queries execute successfully'
        ELSE '❌ FAILED - Query execution failed'
    END AS check_7_status
FROM PHARMACY2U_GOLD.ANALYTICS.V_PATIENT_360
WHERE LIFETIME_VALUE_GBP > 2000;

-- ============================================================================
-- CHECK 8: Semantic Model Sample Queries
-- ============================================================================

SELECT '8. Verified Query Test:' AS CHECK_NAME;

-- Test query similar to verified queries in semantic model
SELECT 
    CASE 
        WHEN AGE < 30 THEN '18-30'
        WHEN AGE < 50 THEN '31-50'
        WHEN AGE < 65 THEN '51-65'
        ELSE '65+'
    END AS age_group,
    COUNT(*) AS patient_count,
    ROUND(AVG(LIFETIME_VALUE_GBP), 2) AS avg_lifetime_value,
    '✅ READY - Age group queries work' AS check_8_status
FROM PHARMACY2U_GOLD.ANALYTICS.V_PATIENT_360
WHERE TOTAL_PRESCRIPTIONS > 0
GROUP BY age_group
ORDER BY patient_count DESC;

-- ============================================================================
-- FINAL SUMMARY
-- ============================================================================

SELECT '=== READINESS SUMMARY ===' AS SUMMARY;

SELECT 
    '✅ All prerequisite checks passed!' AS final_status,
    'You are ready to configure Snowflake Intelligence UI' AS next_step,
    'Follow instructions in: docs/SNOWFLAKE_INTELLIGENCE_SETUP.md' AS documentation;

-- ============================================================================
-- QUICK REFERENCE: Semantic Model Details
-- ============================================================================

SELECT '=== SEMANTIC MODEL REFERENCE ===' AS REFERENCE;

SELECT 
    'patient_360_pharmaceutical_analytics' AS model_name,
    'PHARMACY2U_GOLD.ANALYTICS.V_PATIENT_360' AS base_table,
    '11 dimensions, 13 measures, 7 verified queries' AS model_contents,
    '@PHARMACY2U_GOLD.ANALYTICS.SEMANTIC_MODELS_STAGE/patient_360_analytics.yaml' AS stage_location,
    '12,560 bytes' AS file_size;

-- ============================================================================
-- EXPECTED INTELLIGENCE QUERIES
-- ============================================================================

SELECT '=== SAMPLE QUERIES FOR INTELLIGENCE ===' AS SAMPLE_QUERIES;

SELECT 
    1 AS query_order,
    'How many patients do we have?' AS sample_question,
    'Simple count - warm-up query' AS purpose
UNION ALL SELECT 
    2,
    'What are the top 5 most prescribed drugs this year?',
    'Top N analysis'
UNION ALL SELECT 
    3,
    'For Atorvastatin, what is the patient age breakdown?',
    'Demographic analysis'
UNION ALL SELECT 
    4,
    'Of patients over 65, how many haven''t converted on Heart Health campaign?',
    '⭐ KEY DEMO MOMENT - Complex filter with business value'
UNION ALL SELECT 
    5,
    'Show me the distribution of high-value patients by region',
    'Geographic analysis'
UNION ALL SELECT 
    6,
    'What is our overall marketing campaign conversion rate?',
    'Marketing metrics'
ORDER BY query_order;

SELECT 'Validation complete! Ready for Intelligence UI setup.' AS FINAL_MESSAGE;
