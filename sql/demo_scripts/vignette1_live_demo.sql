-- ============================================================================
-- VIGNETTE 1 LIVE DEMO SCRIPT
-- Title: From Fragmentation to Foundation - Unifying Data with Automated ELT
-- Duration: 13-15 minutes
-- Audience: Data Architect, Head of Engineering
-- ============================================================================

-- PRE-DEMO SETUP: Ensure you're logged in as ACCOUNTADMIN
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE PHARMACY2U_DEMO_WH;

-- ============================================================================
-- DEMO POINT 1: MEDALLION ARCHITECTURE
-- Navigation: Data → Databases (show in UI)
-- Duration: 2 minutes
-- ============================================================================

-- Verify databases exist (run this before demo to check)
SHOW DATABASES LIKE 'PHARMACY2U%';

-- Quick validation queries (optional, for pre-demo check)
SELECT 'BRONZE' as layer, COUNT(*) as table_count FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'RAW_DATA' AND TABLE_CATALOG = 'PHARMACY2U_BRONZE'
UNION ALL
SELECT 'SILVER' as layer, COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'GOVERNED_DATA' AND TABLE_CATALOG = 'PHARMACY2U_SILVER'
UNION ALL
SELECT 'GOLD' as layer, COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'ANALYTICS' AND TABLE_CATALOG = 'PHARMACY2U_GOLD';

-- ============================================================================
-- DEMO POINT 2: QUERYING SEMI-STRUCTURED JSON NATIVELY
-- Navigation: Worksheets → New Query
-- Duration: 2 minutes
-- KEY MOMENT #1: Native JSON parsing
-- ============================================================================

-- Query 1: Show raw JSON marketing events
SELECT * 
FROM PHARMACY2U_BRONZE.RAW_DATA.RAW_MARKETING_EVENTS 
LIMIT 10;

-- Query 2: Parse nested JSON using dot notation (KEY MOMENT #1)
SELECT 
    EVENT_DATA:patient_id::STRING as patient_id,
    EVENT_DATA:campaign_id::STRING as campaign_id,
    EVENT_DATA:campaign_name::STRING as campaign_name,
    EVENT_DATA:event_timestamp::TIMESTAMP as event_timestamp,
    EVENT_DATA:channel::STRING as channel,
    EVENT_DATA:metadata.device_type::STRING as device_type,
    EVENT_DATA:conversion_flag::BOOLEAN as conversion_flag
FROM PHARMACY2U_BRONZE.RAW_DATA.RAW_MARKETING_EVENTS
LIMIT 10;

-- ============================================================================
-- DEMO POINT 3: DYNAMIC TABLES - AUTOMATED ELT PIPELINES
-- Navigation: Data → PHARMACY2U_SILVER → GOVERNED_DATA → Tables → PATIENTS
-- Duration: 3 minutes
-- KEY MOMENT #2: Declarative SQL for automated pipelines
-- ============================================================================

-- Show the Dynamic Table definition (in UI: Click "Definition" tab)
-- Then run this query to show results:

SELECT 
    PATIENT_ID,
    FIRST_NAME,
    LAST_NAME,
    AGE,
    GENDER,
    POSTCODE,
    REGISTRATION_DATE
FROM PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS
LIMIT 10;

-- Show refresh history (optional, if time permits)
-- Note: To view Dynamic Table metadata, check the table definition in the UI
-- or use: SHOW DYNAMIC TABLES IN PHARMACY2U_SILVER.GOVERNED_DATA;

-- ============================================================================
-- DEMO POINT 4: THE PATIENT 360 VIEW - ANALYTICS-READY DATA
-- Navigation: Data → PHARMACY2U_GOLD → ANALYTICS → Views → V_PATIENT_360
-- Duration: 2 minutes
-- ============================================================================

-- Preview the view structure (in UI: Click view, show preview tab)
-- Then run this query to show high-value patients:
-- Note: Using PATIENT_360 dynamic table for faster performance

SELECT 
    PATIENT_ID,
    AGE,
    GENDER,
    TOTAL_PRESCRIPTIONS,
    UNIQUE_DRUGS,
    LIFETIME_VALUE_GBP,
    MARKETING_INTERACTIONS,
    CAMPAIGN_CONVERSIONS
FROM PHARMACY2U_GOLD.ANALYTICS.PATIENT_360
WHERE LIFETIME_VALUE_GBP > 2000
ORDER BY LIFETIME_VALUE_GBP DESC
LIMIT 10;

-- Summary stats for impact (optional talking point)
-- Note: Using PATIENT_360 dynamic table for sub-second response
SELECT 
    COUNT(*) as total_patients,
    ROUND(AVG(LIFETIME_VALUE_GBP), 2) as avg_lifetime_value,
    SUM(TOTAL_PRESCRIPTIONS) as total_prescriptions,
    COUNT(DISTINCT CASE WHEN CAMPAIGN_CONVERSIONS > 0 THEN PATIENT_ID END) as converted_patients
FROM PHARMACY2U_GOLD.ANALYTICS.PATIENT_360;

-- ============================================================================
-- DEMO POINT 5: POWER BI DIRECTQUERY
-- Navigation: Switch to Power BI Desktop window
-- Duration: 1.5 minutes
-- ============================================================================

-- This is demonstrated in Power BI UI
-- After showing Power BI, navigate back to Snowsight → Query History to show:
-- "Every query Power BI runs shows up here"

-- Optional: Show recent queries from external tools
SELECT 
    QUERY_ID,
    QUERY_TEXT,
    USER_NAME,
    START_TIME,
    END_TIME,
    TOTAL_ELAPSED_TIME/1000 as seconds,
    ROWS_PRODUCED
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE USER_NAME = CURRENT_USER()
  AND START_TIME >= DATEADD(HOUR, -1, CURRENT_TIMESTAMP())
ORDER BY START_TIME DESC
LIMIT 10;

-- ============================================================================
-- DEMO POINT 6: QUERY PERFORMANCE & OBSERVABILITY
-- Navigation: Activity → Query History
-- Duration: 1.5 minutes
-- ============================================================================

-- Click on a recent query in Query History UI to show:
-- - Execution time
-- - Rows processed
-- - Compute used
-- - Visual query profile

-- Optional: Show warehouse status
SHOW WAREHOUSES LIKE 'PHARMACY2U_DEMO_WH';

-- Show warehouse credit usage (optional)
SELECT 
    WAREHOUSE_NAME,
    SUM(CREDITS_USED) as total_credits,
    COUNT(DISTINCT DATE_TRUNC('hour', START_TIME)) as active_hours
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
WHERE WAREHOUSE_NAME = 'PHARMACY2U_DEMO_WH'
  AND START_TIME >= DATEADD(DAY, -7, CURRENT_DATE())
GROUP BY WAREHOUSE_NAME;

-- ============================================================================
-- VALIDATION QUERIES (RUN BEFORE DEMO)
-- ============================================================================

-- Check all required objects exist:
SELECT 'Databases OK' as status WHERE (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.DATABASES 
    WHERE DATABASE_NAME IN ('PHARMACY2U_BRONZE', 'PHARMACY2U_SILVER', 'PHARMACY2U_GOLD')
) = 3;

SELECT 'Patient count OK' as status, COUNT(*) as count 
FROM PHARMACY2U_GOLD.ANALYTICS.PATIENT_360
HAVING COUNT(*) >= 100000;

SELECT 'Marketing events OK' as status, COUNT(*) as count 
FROM PHARMACY2U_BRONZE.RAW_DATA.RAW_MARKETING_EVENTS
HAVING COUNT(*) > 0;

SELECT 'Demo script validation complete' as STATUS;

-- ============================================================================
-- END OF VIGNETTE 1 DEMO SCRIPT
-- ============================================================================
-- Next: Transition to Vignette 2 - Building Unbreakable Trust
-- ============================================================================
