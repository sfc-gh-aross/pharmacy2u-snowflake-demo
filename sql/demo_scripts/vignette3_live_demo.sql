-- ============================================================================
-- VIGNETTE 3 LIVE DEMO SCRIPT
-- Title: Powering the Future - From Trusted Data to Generative AI
-- Duration: 15-16 minutes
-- Audience: Head of Data Science, Chief Architect
-- ============================================================================

-- PRE-DEMO SETUP
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE PHARMACY2U_DEMO_WH;
USE DATABASE PHARMACY2U_GOLD;
USE SCHEMA ANALYTICS;

-- ============================================================================
-- DEMO POINT 1: SNOWFLAKE INTELLIGENCE AGENT
-- Duration: 5 minutes
-- KEY MOMENT #1: 4,927 patients in 10 seconds
-- ============================================================================

-- This is demonstrated in Snowflake Intelligence UI
-- Navigate to: Snowflake Intelligence → PATIENT_360_AGENT

-- Queries to type in Intelligence UI:
-- 1. How many patients do we have?
-- 2. What are the top 5 most prescribed drugs this year?
-- 3. For Atorvastatin, what is the patient age breakdown?
-- 4. Of patients over 65, how many haven't converted on Heart Health campaign? (KEY MOMENT)
-- 5. What is the average lifetime value of these patients?
-- 6. Show me the distribution of high-value patients by region

-- Supporting SQL (if agent fails, run these manually):

-- Query 1 equivalent:
-- Note: Using PATIENT_360 dynamic table for performance (materialized)
SELECT COUNT(*) as total_patients 
FROM PATIENT_360;

-- Query 2 equivalent:
SELECT 
    drug_name,
    COUNT(*) as prescription_count
FROM PHARMACY2U_SILVER.GOVERNED_DATA.PRESCRIPTIONS
WHERE YEAR(PRESCRIPTION_DATE) = YEAR(CURRENT_DATE())
GROUP BY drug_name
ORDER BY prescription_count DESC
LIMIT 5;

-- Query 4 equivalent (THE KEY MOMENT):
-- Note: Using PATIENT_360 dynamic table for sub-second performance
SELECT 
    COUNT(DISTINCT p.PATIENT_ID) as non_converter_count,
    SUM(p.MARKETING_INTERACTIONS) as total_marketing_touches,
    ROUND(AVG(p.TOTAL_PRESCRIPTIONS), 2) as avg_prescriptions_per_patient
FROM PATIENT_360 p
WHERE p.AGE > 65
  AND p.CAMPAIGN_CONVERSIONS = 0;

-- ============================================================================
-- DEMO POINT 2: STREAMLIT DASHBOARD - INTERACTIVE BUSINESS ANALYTICS
-- Duration: 2.5 minutes
-- KEY MOMENT: Python dashboards native to Snowflake
-- ============================================================================

-- This is demonstrated in Streamlit UI
-- Navigate to: Snowsight → Streamlit → Apps → PATIENT_360_DASHBOARD

-- Supporting query (what the dashboard is running):
-- Note: Using PATIENT_360 dynamic table for fast dashboard loads
SELECT 
    CUSTOMER_TIER,
    COUNT(*) as patient_count,
    ROUND(AVG(LIFETIME_VALUE_GBP), 2) as avg_lifetime_value,
    SUM(TOTAL_PRESCRIPTIONS) as total_prescriptions
FROM PATIENT_360
GROUP BY CUSTOMER_TIER
ORDER BY 
    CASE CUSTOMER_TIER
        WHEN 'Platinum' THEN 1
        WHEN 'Gold' THEN 2
        WHEN 'Silver' THEN 3
        WHEN 'Bronze' THEN 4
    END;

-- ============================================================================
-- DEMO POINT 3: SNOWFLAKE NOTEBOOKS (Optional if time permits)
-- Duration: 1 minute
-- ============================================================================

-- This is demonstrated in Notebooks UI or via SQL demo version
-- Navigation: Projects → Notebooks

-- SQL demo version - Patient churn feature engineering:

-- Create churn features view
-- Note: Using PATIENT_360 dynamic table as source for better performance
CREATE OR REPLACE VIEW V_PATIENT_CHURN_FEATURES AS
SELECT 
    PATIENT_ID,
    AGE,
    GENDER,
    CUSTOMER_TIER,
    TOTAL_PRESCRIPTIONS,
    LIFETIME_VALUE_GBP,
    MARKETING_INTERACTIONS,
    CAMPAIGN_CONVERSIONS,
    DATEDIFF(DAY, LAST_PRESCRIPTION_DATE, CURRENT_DATE()) as days_since_last_prescription,
    CASE 
        WHEN DATEDIFF(DAY, LAST_PRESCRIPTION_DATE, CURRENT_DATE()) > 90 THEN 'High'
        WHEN DATEDIFF(DAY, LAST_PRESCRIPTION_DATE, CURRENT_DATE()) > 60 THEN 'Medium'
        ELSE 'Low'
    END as churn_risk_category
FROM PATIENT_360;

-- Show churn risk distribution
SELECT 
    churn_risk_category,
    COUNT(*) as patient_count,
    ROUND(AVG(LIFETIME_VALUE_GBP), 2) as avg_lifetime_value,
    ROUND(AVG(days_since_last_prescription), 0) as avg_days_inactive
FROM V_PATIENT_CHURN_FEATURES
GROUP BY churn_risk_category
ORDER BY 
    CASE churn_risk_category
        WHEN 'High' THEN 1
        WHEN 'Medium' THEN 2
        WHEN 'Low' THEN 3
    END;

-- ============================================================================
-- DEMO POINT 4: FROM ML TO BUSINESS ACTION - CLOSING THE LOOP
-- Duration: 1.5 minutes
-- ============================================================================

-- Show that ML outputs can be published as data products
-- Reference: Organizational Listings from Vignette 2

-- Example: Marketing uses churn scores immediately
SELECT 
    p.PATIENT_ID,
    p.AGE,
    p.CUSTOMER_TIER,
    c.churn_risk_category,
    c.days_since_last_prescription,
    p.LIFETIME_VALUE_GBP
FROM PATIENT_360 p
JOIN V_PATIENT_CHURN_FEATURES c ON p.PATIENT_ID = c.PATIENT_ID
WHERE c.churn_risk_category = 'High'
  AND p.CUSTOMER_TIER IN ('Gold', 'Platinum')
ORDER BY p.LIFETIME_VALUE_GBP DESC
LIMIT 100;

-- ============================================================================
-- DEMO POINT 5: CORTEX AI FUNCTIONS - SERVERLESS AI CAPABILITIES
-- Duration: 1.5 minutes
-- ============================================================================

-- Note: PATIENT_FEEDBACK table needs to exist with sample data
-- If it doesn't exist, create sample data:

CREATE OR REPLACE TABLE PATIENT_FEEDBACK (
    feedback_id NUMBER AUTOINCREMENT,
    patient_id VARCHAR,
    feedback_text VARCHAR,
    feedback_channel VARCHAR,
    created_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Insert sample feedback
INSERT INTO PATIENT_FEEDBACK (patient_id, feedback_text, feedback_channel)
VALUES
    ('P00001', 'Excellent service! My prescription arrived on time and the delivery driver was very professional.', 'Email'),
    ('P00002', 'Very disappointed with the delayed delivery. Had to wait 3 extra days for my medication.', 'Phone'),
    ('P00003', 'The new app is fantastic. Makes reordering so much easier than before.', 'App Review'),
    ('P00004', 'Customer service was unhelpful when I called about a missing item in my order.', 'Phone'),
    ('P00005', 'Always reliable service. Been using Pharmacy2U for 2 years now and never had issues.', 'Email'),
    ('P00006', 'The packaging could be better. One of my bottles was damaged during delivery.', 'Email'),
    ('P00007', 'Quick response to my query. The pharmacist was very knowledgeable and helpful.', 'Chat'),
    ('P00008', 'Not happy with the price increase. Considering switching to another pharmacy.', 'Email'),
    ('P00009', 'Love the auto-refill feature! Never have to worry about running out of meds.', 'App Review'),
    ('P00010', 'Website is difficult to navigate. Took me 20 minutes to find what I needed.', 'Email');

-- Analyze patient feedback sentiment using Cortex AI
SELECT 
    feedback_id,
    patient_id,
    feedback_text,
    SNOWFLAKE.CORTEX.SENTIMENT(feedback_text) AS sentiment_score,
    CASE
        WHEN SNOWFLAKE.CORTEX.SENTIMENT(feedback_text) > 0.7 THEN 'Very Positive'
        WHEN SNOWFLAKE.CORTEX.SENTIMENT(feedback_text) > 0.3 THEN 'Positive'
        WHEN SNOWFLAKE.CORTEX.SENTIMENT(feedback_text) BETWEEN -0.3 AND 0.3 THEN 'Neutral'
        WHEN SNOWFLAKE.CORTEX.SENTIMENT(feedback_text) < -0.7 THEN 'Very Negative'
        ELSE 'Negative'
    END AS sentiment_category
FROM PATIENT_FEEDBACK
LIMIT 10;

-- Show summarization (optional if time permits)
SELECT 
    feedback_id,
    SNOWFLAKE.CORTEX.SUMMARIZE(feedback_text) AS summary
FROM PATIENT_FEEDBACK
WHERE LENGTH(feedback_text) > 100
LIMIT 5;

-- ============================================================================
-- DEMO POINT 6: SNOWFLAKE MARKETPLACE - EXTERNAL DATA ENRICHMENT
-- Duration: 1.5 minutes
-- ============================================================================

-- This is demonstrated in Marketplace UI
-- Navigation: Data → Marketplace

-- Show simulated marketplace integration (enriched demographics)
SELECT 
    p.patient_id,
    p.age,
    p.postcode,
    p.lifetime_value_gbp,
    ext.region_name,
    ext.area_deprivation_index,
    ext.area_health_index,
    CASE 
        WHEN ext.area_deprivation_index >= 7 THEN 'High Deprivation Area'
        ELSE 'Lower Deprivation Area'
    END AS deprivation_category
FROM PATIENT_360 p
LEFT JOIN PHARMACY2U_GOLD.MARKETPLACE_DATA.EXTERNAL_UK_POSTCODE_DEMOGRAPHICS ext
    ON LEFT(p.postcode, 2) = ext.postcode_prefix
LIMIT 10;

-- Show enrichment value - correlation between deprivation and lifetime value
SELECT 
    CASE 
        WHEN ext.area_deprivation_index >= 7 THEN 'High Deprivation'
        WHEN ext.area_deprivation_index >= 4 THEN 'Medium Deprivation'
        ELSE 'Low Deprivation'
    END AS deprivation_level,
    COUNT(DISTINCT p.patient_id) as patient_count,
    ROUND(AVG(p.lifetime_value_gbp), 2) as avg_lifetime_value,
    ROUND(AVG(p.total_prescriptions), 2) as avg_prescriptions
FROM PATIENT_360 p
LEFT JOIN PHARMACY2U_GOLD.MARKETPLACE_DATA.EXTERNAL_UK_POSTCODE_DEMOGRAPHICS ext
    ON LEFT(p.postcode, 2) = ext.postcode_prefix
WHERE ext.area_deprivation_index IS NOT NULL
GROUP BY deprivation_level
ORDER BY deprivation_level;

-- ============================================================================
-- VALIDATION QUERIES (RUN BEFORE DEMO)
-- ============================================================================

-- Check Intelligence Agent exists and is active
-- (This must be done in Snowflake Intelligence UI)

-- Check Streamlit app is deployed
-- (Check in Snowsight → Streamlit → Apps)

-- Check Cortex Search service is ready
DESCRIBE CORTEX SEARCH SERVICE PHARMACY2U_GOLD.ANALYTICS.PATIENT_360_SEARCH_SERVICE;

-- Check semantic model is deployed
LIST @PHARMACY2U_GOLD.ANALYTICS.SEMANTIC_MODELS;

-- Check Patient 360 dynamic table has data
SELECT COUNT(*) as patient_count 
FROM PATIENT_360
HAVING COUNT(*) >= 100000;

-- Check patient feedback table exists
SELECT COUNT(*) as feedback_count 
FROM PATIENT_FEEDBACK;

-- Check marketplace data exists
SELECT COUNT(*) as external_data_count 
FROM PHARMACY2U_GOLD.MARKETPLACE_DATA.EXTERNAL_UK_POSTCODE_DEMOGRAPHICS;

SELECT 'Vignette 3 validation complete' as STATUS;

-- ============================================================================
-- INTELLIGENCE AGENT QUERIES CHEAT SHEET
-- ============================================================================

/*
MEMORIZE THESE 6 QUERIES FOR THE INTELLIGENCE DEMO:

1. How many patients do we have?

2. What are the top 5 most prescribed drugs this year?

3. For Atorvastatin, what is the patient age breakdown?

4. Of patients over 65, how many haven't converted on Heart Health campaign?
   ⭐⭐⭐ THIS IS THE KEY MOMENT - 4,927 patients in 10 seconds

5. What is the average lifetime value of these patients?

6. Show me the distribution of high-value patients by region
*/

-- ============================================================================
-- END OF VIGNETTE 3 DEMO SCRIPT
-- ============================================================================
-- Next: Q&A and closing
-- ============================================================================
