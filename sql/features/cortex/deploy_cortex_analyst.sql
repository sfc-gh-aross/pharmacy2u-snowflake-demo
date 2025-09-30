-- ============================================================================
-- Pharmacy2U Demo - Deploy Cortex Analyst Semantic Model
-- Purpose: Upload and register semantic model for Snowflake Intelligence
-- Key Feature: Enable natural language queries on Patient 360 data
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE PHARMACY2U_DEMO_WH;
USE DATABASE PHARMACY2U_GOLD;
USE SCHEMA ANALYTICS;

-- ============================================================================
-- STEP 1: Create Stage for Semantic Model
-- ============================================================================

-- Create stage to hold semantic model YAML file
CREATE STAGE IF NOT EXISTS SEMANTIC_MODELS_STAGE
    COMMENT = 'Stage for storing Cortex Analyst semantic model files';

-- Show stage
SHOW STAGES LIKE 'SEMANTIC_MODELS_STAGE';

-- ============================================================================
-- STEP 2: Upload Semantic Model File
-- ============================================================================

-- Note: Use SnowSQL or Snowflake CLI to upload the YAML file
-- snow stage put config/semantic_models/patient_360_analytics.yaml @SEMANTIC_MODELS_STAGE --overwrite

-- For manual upload in Snowsight:
-- 1. Navigate to Data > Databases > PHARMACY2U_GOLD > ANALYTICS > Stages > SEMANTIC_MODELS_STAGE
-- 2. Click "+" button to upload file
-- 3. Select config/semantic_models/patient_360_analytics.yaml

SELECT 'Semantic model stage created - Ready for file upload' AS STATUS;

-- ============================================================================
-- STEP 3: Verify Semantic Model File Upload
-- ============================================================================

-- List files in stage
LIST @SEMANTIC_MODELS_STAGE;

-- ============================================================================
-- STEP 4: Test Semantic Model (After Upload)
-- ============================================================================

-- Note: Cortex Analyst can reference the semantic model from the stage
-- The semantic model will be used by Snowflake Intelligence UI

-- Verify the model references the correct base table
SELECT 
    'V_PATIENT_360' as semantic_model_table,
    COUNT(*) as row_count,
    COUNT(DISTINCT PATIENT_ID) as unique_patients
FROM V_PATIENT_360;

-- Show available columns for semantic model
DESC VIEW V_PATIENT_360;

-- Sample queries that the semantic model should support
SELECT '=== Sample Natural Language Queries the Model Supports ===' AS INFO;

SELECT 
    '1. Which are our top 5 most prescribed drugs this year?' AS sample_question
UNION ALL
SELECT '2. For Atorvastatin, what is the patient age breakdown?'
UNION ALL
SELECT '3. Of patients over 65, how many have not converted on Heart Health campaign?'
UNION ALL
SELECT '4. Show me the distribution of high-value patients by region'
UNION ALL
SELECT '5. What is our overall marketing campaign conversion rate?'
UNION ALL
SELECT '6. How many patients have not ordered in the last 3 months?'
UNION ALL
SELECT '7. Show patient gender distribution across value tiers';

-- ============================================================================
-- STEP 5: Validate Data for Semantic Model
-- ============================================================================

-- Check data quality for semantic model
SELECT 
    COUNT(*) as total_patients,
    COUNT(DISTINCT PATIENT_ID) as unique_patients,
    COUNT(AGE) as patients_with_age,
    COUNT(GENDER) as patients_with_gender,
    COUNT(POSTCODE) as patients_with_postcode,
    COUNT(LIFETIME_VALUE_GBP) as patients_with_value,
    ROUND(AVG(TOTAL_PRESCRIPTIONS), 2) as avg_prescriptions,
    ROUND(AVG(MARKETING_INTERACTIONS), 2) as avg_marketing_touches
FROM V_PATIENT_360;

-- Sample data for semantic model verification
SELECT 
    PATIENT_ID,
    AGE,
    GENDER,
    POSTCODE,
    TOTAL_PRESCRIPTIONS,
    UNIQUE_DRUGS,
    LIFETIME_VALUE_GBP,
    MARKETING_INTERACTIONS,
    CAMPAIGN_CONVERSIONS,
    LAST_PRESCRIPTION_DATE
FROM V_PATIENT_360
LIMIT 10;

-- Distribution checks
SELECT 
    CASE
        WHEN AGE < 30 THEN '18-30'
        WHEN AGE < 50 THEN '31-50'
        WHEN AGE < 65 THEN '51-65'
        ELSE '65+'
    END AS age_group,
    COUNT(*) as patient_count,
    ROUND(AVG(LIFETIME_VALUE_GBP), 2) as avg_lifetime_value
FROM V_PATIENT_360
GROUP BY age_group
ORDER BY age_group;

-- Customer tier distribution
SELECT 
    CASE
        WHEN LIFETIME_VALUE_GBP > 5000 THEN 'Platinum'
        WHEN LIFETIME_VALUE_GBP > 2000 THEN 'Gold'
        WHEN LIFETIME_VALUE_GBP > 500 THEN 'Silver'
        ELSE 'Bronze'
    END AS customer_tier,
    COUNT(*) as patient_count,
    ROUND(SUM(LIFETIME_VALUE_GBP), 2) as total_value
FROM V_PATIENT_360
GROUP BY customer_tier
ORDER BY total_value DESC;

SELECT 'Semantic model data validation complete' AS STATUS;

-- ============================================================================
-- STEP 6: Grant Permissions for Cortex Analyst
-- ============================================================================

-- Grant necessary privileges for Cortex Analyst usage
GRANT USAGE ON DATABASE PHARMACY2U_GOLD TO ROLE PHARMACY2U_DATA_ANALYST;
GRANT USAGE ON SCHEMA PHARMACY2U_GOLD.ANALYTICS TO ROLE PHARMACY2U_DATA_ANALYST;
GRANT SELECT ON VIEW PHARMACY2U_GOLD.ANALYTICS.V_PATIENT_360 TO ROLE PHARMACY2U_DATA_ANALYST;
GRANT READ ON STAGE PHARMACY2U_GOLD.ANALYTICS.SEMANTIC_MODELS_STAGE TO ROLE PHARMACY2U_DATA_ANALYST;

-- Grant Cortex privileges (if needed)
-- Note: Actual privilege names may vary - check Snowflake documentation
-- GRANT USAGE ON CORTEX ANALYST TO ROLE PHARMACY2U_DATA_ANALYST;

SELECT 'Permissions granted for Cortex Analyst usage' AS STATUS;

-- ============================================================================
-- DEMO TALKING POINTS
-- ============================================================================

SELECT '=== Cortex Analyst Demo Talking Points ===' AS INFO;

SELECT 
    'Point 1: Democratizing data access - business users can ask questions in plain English' AS talking_point
UNION ALL
SELECT 'Point 2: Semantic model provides business context - not just technical column names'
UNION ALL
SELECT 'Point 3: Natural language to SQL - powered by Snowflake Cortex AI'
UNION ALL
SELECT 'Point 4: No SQL knowledge required - accessible to marketing, operations, executives'
UNION ALL
SELECT 'Point 5: Governance maintained - semantic model respects existing access policies'
UNION ALL
SELECT 'Point 6: Foundation for Snowflake Intelligence - unified AI-powered analytics';

-- ============================================================================
-- PHARMACEUTICAL USE CASES
-- ============================================================================

SELECT '=== Pharmaceutical Business Questions Enabled ===' AS INFO;

SELECT 
    'Marketing: Which patient cohorts should we target for retention campaigns?' AS use_case
UNION ALL
SELECT 'Clinical: What is the prescription pattern distribution across age groups?'
UNION ALL
SELECT 'Finance: What is our customer lifetime value by region?'
UNION ALL
SELECT 'Operations: How many at-risk patients need proactive outreach?'
UNION ALL
SELECT 'Strategy: What is the conversion rate of our marketing campaigns?'
UNION ALL
SELECT 'Compliance: How can we identify high-value patients for VIP programs?';

SELECT 'Cortex Analyst semantic model deployment ready!' AS FINAL_STATUS;
