-- ============================================================================
-- VIGNETTE 2 LIVE DEMO SCRIPT
-- Title: Building Unbreakable Trust - Automated Governance & Internal Collaboration
-- Duration: 15-16 minutes
-- Audience: Head of Data, Head of BI, Head of Customer Insight
-- ============================================================================

-- PRE-DEMO SETUP
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE PHARMACY2U_DEMO_WH;

-- ============================================================================
-- DEMO POINT 1: DYNAMIC DATA MASKING - AUTOMATED PII PROTECTION
-- Duration: 2.5 minutes
-- KEY MOMENT #1: Policy-based governance
-- ============================================================================

-- Query as ACCOUNTADMIN (unmasked)
SELECT 
    PATIENT_ID,
    FIRST_NAME,
    LAST_NAME,
    EMAIL,
    PHONE,
    NHS_NUMBER,
    AGE,
    POSTCODE
FROM PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS
LIMIT 10;

-- NOW SWITCH ROLE IN UI: Top-right → PHARMACY2U_BI_USER
-- (Demonstrate role switching in UI)

-- Run THE EXACT SAME QUERY as BI_USER (data will be masked)
-- (Execute the query above again after switching roles)

-- SWITCH BACK TO ACCOUNTADMIN
-- Top-right → ACCOUNTADMIN

-- Optional: Show the masking policy definition
SHOW MASKING POLICIES IN SCHEMA PHARMACY2U_SILVER.GOVERNED_DATA;

-- ============================================================================
-- DEMO POINT 2: TIME TRAVEL - INSTANT INCIDENT RECOVERY
-- Duration: 2.5 minutes
-- KEY MOMENT #2: P1 incident → 30-second fix
-- ============================================================================

-- Step 1: Create a demo copy of the table
CREATE OR REPLACE TABLE PATIENTS_DEMO 
CLONE PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS;

-- Wait a few seconds for the clone to complete
CALL SYSTEM$WAIT(5);

-- Step 2: The "Friday afternoon mistake" - accidentally nullify emails
UPDATE PATIENTS_DEMO
SET EMAIL = NULL
WHERE PATIENT_ID LIKE 'P%';

-- Step 3: Check the damage
SELECT COUNT(*) as nullified_emails 
FROM PATIENTS_DEMO 
WHERE EMAIL IS NULL;

-- Step 4: Use Time Travel to query data from 10 seconds ago (before the mistake)
SELECT 
    PATIENT_ID,
    EMAIL
FROM PATIENTS_DEMO
AT(OFFSET => -10)  -- 10 seconds ago
WHERE PATIENT_ID LIKE 'P%'
LIMIT 10;

-- Step 5: Restore the entire table from before the mistake
CREATE OR REPLACE TABLE PATIENTS_DEMO 
CLONE PATIENTS_DEMO AT(OFFSET => -10);

-- Step 6: Verify recovery
SELECT COUNT(*) as recovered_emails 
FROM PATIENTS_DEMO 
WHERE EMAIL IS NOT NULL;

-- Cleanup (optional, or leave for next demo)
-- DROP TABLE IF EXISTS PATIENTS_DEMO;

-- ============================================================================
-- DEMO POINT 3: ZERO-COPY CLONING - INSTANT DEV/TEST ENVIRONMENTS
-- Duration: 1.5 minutes
-- KEY MOMENT #3: Instant clones, zero cost
-- ============================================================================

-- Clone the entire GOLD database instantly
CREATE OR REPLACE DATABASE PHARMACY2U_GOLD_DEV 
CLONE PHARMACY2U_GOLD;

-- Verify it exists and has data
USE DATABASE PHARMACY2U_GOLD_DEV;
SELECT COUNT(*) as patient_count 
FROM ANALYTICS.V_PATIENT_360;

-- Switch back to original database
USE DATABASE PHARMACY2U_GOLD;

-- Show both databases exist (in UI: Data → Databases)
SHOW DATABASES LIKE 'PHARMACY2U_GOLD%';

-- ============================================================================
-- DEMO POINT 4: ACCESS HISTORY & AUDIT TRAILS
-- Duration: 1.5 minutes
-- ============================================================================

-- Show recent PII access (from Access History)
SELECT 
    user_name,
    query_start_time,
    query_text,
    direct_objects_accessed,
    rows_produced
FROM SNOWFLAKE.ACCOUNT_USAGE.ACCESS_HISTORY
WHERE query_start_time >= DATEADD(day, -7, CURRENT_TIMESTAMP())
  AND ARRAY_CONTAINS('PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS'::VARIANT, 
                     base_objects_accessed)
ORDER BY query_start_time DESC
LIMIT 10;

-- Alternative: Show in UI
-- Navigation: Account → Usage → Query History
-- Filter: Objects accessed = PATIENTS

-- ============================================================================
-- DEMO POINT 5: COST MANAGEMENT & BUDGETS
-- Duration: 1 minute
-- Navigation: Admin → Cost Management → Resource Monitors (show in UI)
-- ============================================================================

-- Show resource monitor (in UI: Admin → Cost Management → Resource Monitors)
SHOW RESOURCE MONITORS;

-- Show current month spend by warehouse
SELECT 
    WAREHOUSE_NAME,
    SUM(CREDITS_USED) as total_credits,
    SUM(CREDITS_USED) * 5 as estimated_cost_gbp
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
WHERE START_TIME >= DATE_TRUNC('month', CURRENT_DATE())
  AND WAREHOUSE_NAME LIKE 'PHARMACY2U%'
GROUP BY WAREHOUSE_NAME;

-- ============================================================================
-- DEMO POINT 6: ALERTS & NOTIFICATIONS - PROACTIVE MONITORING
-- Duration: 1 minute
-- ============================================================================

-- Option 1: Show alert tasks (in UI: Data → PHARMACY2U_GOLD → ANALYTICS → Tasks)
SHOW TASKS IN SCHEMA PHARMACY2U_GOLD.ANALYTICS;

-- Option 2: Show alert log
SELECT 
    alert_type,
    alert_severity,
    alert_message,
    alert_timestamp
FROM PHARMACY2U_GOLD.ANALYTICS.ALERT_LOG
ORDER BY alert_timestamp DESC
LIMIT 10;

-- If no alerts exist yet, explain:
-- "This table will populate as alerts are triggered. 
--  In production, these trigger email/Slack notifications."

-- ============================================================================
-- DEMO POINT 7: OBJECT TAGGING & DATA CLASSIFICATION
-- Duration: 1.5 minutes
-- ============================================================================

-- Show tags on a column (in UI: Data → PHARMACY2U_SILVER → GOVERNED_DATA → PATIENTS → NHS_NUMBER → Details)

-- Find all PII columns across the entire database
SELECT 
    tag_database,
    tag_schema,
    object_name as table_name,
    column_name,
    tag_value as pii_type
FROM SNOWFLAKE.ACCOUNT_USAGE.TAG_REFERENCES
WHERE tag_name = 'PII_TYPE'
  AND tag_database = 'PHARMACY2U_SILVER'
ORDER BY object_name, column_name;

-- Note: ACCOUNT_USAGE has latency. For immediate results, use:
SELECT 
    TABLE_CATALOG,
    TABLE_SCHEMA,
    TABLE_NAME,
    COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_CATALOG = 'PHARMACY2U_SILVER'
  AND TABLE_SCHEMA = 'GOVERNED_DATA'
  AND (COLUMN_NAME LIKE '%EMAIL%' 
       OR COLUMN_NAME LIKE '%PHONE%' 
       OR COLUMN_NAME LIKE '%NHS%')
ORDER BY TABLE_NAME, COLUMN_NAME;

-- ============================================================================
-- DEMO POINT 8: ORGANIZATIONAL LISTINGS - INTERNAL DATA MARKETPLACE
-- Duration: 2 minutes
-- KEY MOMENT #4: Internal marketplace
-- ============================================================================

-- Show internal data product catalog
SELECT 
    product_name,
    product_description,
    business_domain,
    data_owner,
    target_audience,
    row_count,
    pii_status
FROM PHARMACY2U_GOLD.DATA_PRODUCTS.DATA_PRODUCT_CATALOG
ORDER BY product_name;

-- Show one of the data products
SELECT * 
FROM PHARMACY2U_GOLD.DATA_PRODUCTS.V_PATIENT_360_ANALYTICS
LIMIT 10;

-- Navigation: Also show in UI
-- Data Products → Private Sharing (if configured)

-- ============================================================================
-- VALIDATION QUERIES (RUN BEFORE DEMO)
-- ============================================================================

-- Check masking policies exist
SELECT COUNT(*) as masking_policy_count 
FROM INFORMATION_SCHEMA.MASKING_POLICIES
WHERE POLICY_SCHEMA = 'GOVERNED_DATA'
  AND POLICY_CATALOG = 'PHARMACY2U_SILVER';

-- Check row access policies exist
SELECT COUNT(*) as row_access_policy_count
FROM INFORMATION_SCHEMA.ROW_ACCESS_POLICIES
WHERE POLICY_SCHEMA = 'GOVERNED_DATA'
  AND POLICY_CATALOG = 'PHARMACY2U_SILVER';

-- Check BI_USER role exists
SHOW ROLES LIKE 'PHARMACY2U_BI_USER';

-- Check resource monitor exists
SHOW RESOURCE MONITORS LIKE 'PHARMACY2U_DEMO_BUDGET';

-- Check tags exist
SHOW TAGS IN SCHEMA PHARMACY2U_SILVER.GOVERNANCE_TAGS;

-- Check data product catalog exists
SELECT COUNT(*) as product_count 
FROM PHARMACY2U_GOLD.DATA_PRODUCTS.DATA_PRODUCT_CATALOG;

SELECT 'Vignette 2 validation complete' as STATUS;

-- ============================================================================
-- END OF VIGNETTE 2 DEMO SCRIPT
-- ============================================================================
-- Next: Transition to Vignette 3 - Powering the Future with AI
-- ============================================================================
