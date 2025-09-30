-- ============================================================================
-- Pharmacy2U Demo - Cortex Search Service
-- Purpose: Enable semantic search on Patient 360 data for Snowflake Intelligence
-- Key Feature: Natural language search over pharmaceutical patient data
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE PHARMACY2U_DEMO_WH;
USE DATABASE PHARMACY2U_GOLD;
USE SCHEMA ANALYTICS;

-- ============================================================================
-- STEP 1: Verify V_PATIENT_360 View Exists
-- ============================================================================

-- Show view structure
DESC VIEW V_PATIENT_360;

-- Check row count
SELECT COUNT(*) as total_patients FROM V_PATIENT_360;

-- Sample data for search service context
SELECT 
    PATIENT_ID,
    AGE,
    GENDER,
    POSTCODE,
    TOTAL_PRESCRIPTIONS,
    UNIQUE_DRUGS,
    LIFETIME_VALUE_GBP,
    MARKETING_INTERACTIONS,
    CAMPAIGN_CONVERSIONS
FROM V_PATIENT_360
LIMIT 10;

-- ============================================================================
-- STEP 2: Create Searchable Patient Table
-- ============================================================================

-- Create a searchable version of patient data with combined text content
CREATE OR REPLACE TABLE PATIENT_360_SEARCHABLE AS
SELECT 
    PATIENT_ID,
    AGE,
    GENDER,
    POSTCODE,
    TOTAL_PRESCRIPTIONS,
    UNIQUE_DRUGS,
    LIFETIME_VALUE_GBP,
    LAST_PRESCRIPTION_DATE,
    MARKETING_INTERACTIONS,
    CAMPAIGN_CONVERSIONS,
    -- Create combined searchable content for semantic search
    'Patient ' || PATIENT_ID || 
    ' Age: ' || COALESCE(AGE::STRING, 'N/A') || 
    ' Gender: ' || COALESCE(GENDER, 'N/A') || 
    ' Location: ' || COALESCE(POSTCODE, 'N/A') || 
    ' Prescriptions: ' || COALESCE(TOTAL_PRESCRIPTIONS::STRING, '0') || 
    ' Drugs: ' || COALESCE(UNIQUE_DRUGS::STRING, '0') || 
    ' Lifetime Value: £' || COALESCE(LIFETIME_VALUE_GBP::STRING, '0') ||
    ' Marketing Interactions: ' || COALESCE(MARKETING_INTERACTIONS::STRING, '0')
    AS searchable_content,
    -- Add patient segmentation for better search
    CASE 
        WHEN LIFETIME_VALUE_GBP > 5000 THEN 'Platinum'
        WHEN LIFETIME_VALUE_GBP > 2000 THEN 'Gold'
        WHEN LIFETIME_VALUE_GBP > 500 THEN 'Silver'
        ELSE 'Bronze'
    END as CUSTOMER_TIER,
    CASE
        WHEN AGE < 30 THEN '18-30'
        WHEN AGE < 50 THEN '31-50'
        WHEN AGE < 65 THEN '51-65'
        ELSE '65+'
    END as AGE_GROUP,
    CURRENT_TIMESTAMP() as INDEXED_TIMESTAMP
FROM V_PATIENT_360;

-- Add comment to table
COMMENT ON TABLE PATIENT_360_SEARCHABLE IS 'Searchable version of Patient 360 data for Cortex Search';

-- Verify table creation
SELECT 'Patient 360 searchable table created with ' || COUNT(*) || ' records' as status 
FROM PATIENT_360_SEARCHABLE;

-- ============================================================================
-- STEP 3: Create Cortex Search Service
-- ============================================================================

-- Create Cortex Search Service on the searchable content
CREATE OR REPLACE CORTEX SEARCH SERVICE PATIENT_360_SEARCH_SERVICE
    ON searchable_content
    ATTRIBUTES PATIENT_ID, AGE, GENDER, POSTCODE, TOTAL_PRESCRIPTIONS, UNIQUE_DRUGS, 
               LIFETIME_VALUE_GBP, LAST_PRESCRIPTION_DATE, MARKETING_INTERACTIONS, 
               CAMPAIGN_CONVERSIONS, CUSTOMER_TIER, AGE_GROUP
    WAREHOUSE = PHARMACY2U_DEMO_WH
    TARGET_LAG = '1 minute'
    COMMENT = 'Cortex Search service for semantic search on Patient 360 pharmaceutical data'
AS (
    SELECT 
        searchable_content,
        PATIENT_ID,
        AGE,
        GENDER,
        POSTCODE,
        TOTAL_PRESCRIPTIONS,
        UNIQUE_DRUGS,
        LIFETIME_VALUE_GBP,
        LAST_PRESCRIPTION_DATE,
        MARKETING_INTERACTIONS,
        CAMPAIGN_CONVERSIONS,
        CUSTOMER_TIER,
        AGE_GROUP
    FROM PATIENT_360_SEARCHABLE
);

-- ============================================================================
-- STEP 4: Verify Search Service Creation
-- ============================================================================

-- Show search services
SHOW CORTEX SEARCH SERVICES IN SCHEMA ANALYTICS;

-- Check search service status
DESCRIBE CORTEX SEARCH SERVICE PATIENT_360_SEARCH_SERVICE;

-- Show sample searchable content
SELECT 'Sample searchable content:' as info;
SELECT 
    PATIENT_ID,
    CUSTOMER_TIER,
    AGE_GROUP,
    LEFT(searchable_content, 100) || '...' as content_preview
FROM PATIENT_360_SEARCHABLE 
LIMIT 5;

-- Distribution by customer tier
SELECT 
    CUSTOMER_TIER,
    COUNT(*) as patient_count,
    ROUND(AVG(LIFETIME_VALUE_GBP), 2) as avg_lifetime_value
FROM PATIENT_360_SEARCHABLE 
GROUP BY CUSTOMER_TIER 
ORDER BY avg_lifetime_value DESC;

-- ============================================================================
-- STEP 5: Test Basic Search Queries (After Service is Ready)
-- ============================================================================

-- Note: Search service takes a few minutes to index on first creation
-- Check service status: SELECT SYSTEM$GET_CORTEX_SEARCH_SERVICE_STATUS('PATIENT_360_SEARCH_SERVICE');

-- Test Search Query 1: Find high-value patients
-- Note: Commented out until service is ready
-- SELECT * FROM TABLE(
--     SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
--         'PATIENT_360_SEARCH_SERVICE',
--         'high value patients with multiple prescriptions'
--     )
-- ) LIMIT 10;

-- Test Search Query 2: Search by demographic characteristics
-- SELECT * FROM TABLE(
--     SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
--         'PATIENT_360_SEARCH_SERVICE',
--         'elderly patients age over 65'
--     )
-- ) LIMIT 10;

-- Test Search Query 3: Search by location
-- SELECT * FROM TABLE(
--     SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
--         'PATIENT_360_SEARCH_SERVICE',
--         'patients with high prescription counts'
--     )
-- ) LIMIT 10;

-- ============================================================================
-- STEP 6: Integration Check for Cortex Analyst/Intelligence
-- ============================================================================

-- Verify search service is available for Cortex Analyst/Intelligence
SELECT 
    'PATIENT_360_SEARCH_SERVICE' as service_name,
    'Created - Indexing in progress' as status,
    CURRENT_DATABASE() || '.' || CURRENT_SCHEMA() as location,
    'Foundation for Snowflake Intelligence' as purpose;

SELECT 'Cortex Search service created successfully - Ready for Snowflake Intelligence!' AS STATUS;

-- ============================================================================
-- DEMO TALKING POINTS
-- ============================================================================

-- 1. "Cortex Search enables semantic understanding of patient data"
-- 2. "Natural language queries without complex SQL joins"
-- 3. "Automatically maintained and refreshed - no manual index management"
-- 4. "Foundation for Snowflake Intelligence natural language interface"
-- 5. "Combines structured filters with semantic search for powerful queries"

-- ============================================================================
-- PHARMACEUTICAL USE CASES
-- ============================================================================

-- Use Case 1: Patient Cohort Discovery
-- "Find patients with high medication adherence and engagement"

-- Use Case 2: Campaign Targeting
-- "Identify patients who haven't responded to marketing campaigns"

-- Use Case 3: Clinical Analysis
-- "Search for patients with specific prescription patterns"

-- Use Case 4: Geographic Analysis  
-- "Find high-value patient concentrations by region"

-- Use Case 5: Retention Analysis
-- "Discover patients at risk of churn based on prescription frequency"
