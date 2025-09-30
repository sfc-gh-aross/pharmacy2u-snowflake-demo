-- ============================================================================
-- VIGNETTE 3 - Snowflake Notebooks Demo Script
-- Pharmacy2U Patient Churn Analysis
-- Duration: 3-4 minutes
-- Key Message: "Collaborative data science environment - Jupyter in Snowflake"
-- ============================================================================

-- This script demonstrates the analysis that would be done in Snowflake Notebooks
-- In the actual demo, you would show the Snowflake Notebooks UI

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE PHARMACY2U_DEMO_WH;
USE DATABASE PHARMACY2U_GOLD;
USE SCHEMA ANALYTICS;

-- ============================================================================
-- STEP 1: Feature Engineering for Churn Analysis
-- ============================================================================

-- Talking Point: "Let's analyze patient churn risk using our Patient 360 data"

-- Create churn risk features
CREATE OR REPLACE VIEW V_PATIENT_CHURN_FEATURES AS
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
    
    -- Feature: Days since last prescription (Recency)
    DATEDIFF(DAY, LAST_PRESCRIPTION_DATE, CURRENT_DATE()) AS DAYS_SINCE_LAST_RX,
    
    -- Feature: Average prescription value
    ROUND(LIFETIME_VALUE_GBP / NULLIF(TOTAL_PRESCRIPTIONS, 0), 2) AS AVG_PRESCRIPTION_VALUE,
    
    -- Feature: Marketing engagement score
    ROUND((CAMPAIGN_CONVERSIONS * 100.0 / NULLIF(MARKETING_INTERACTIONS, 0)), 2) AS ENGAGEMENT_SCORE,
    
    -- Feature: Customer value tier
    CASE 
        WHEN LIFETIME_VALUE_GBP > 5000 THEN 'Platinum'
        WHEN LIFETIME_VALUE_GBP > 2000 THEN 'Gold'
        WHEN LIFETIME_VALUE_GBP > 500 THEN 'Silver'
        ELSE 'Bronze'
    END AS VALUE_TIER,
    
    -- Feature: Age group
    CASE
        WHEN AGE < 30 THEN '18-30'
        WHEN AGE < 50 THEN '31-50'
        WHEN AGE < 65 THEN '51-65'
        ELSE '65+'
    END AS AGE_GROUP,
    
    -- Target: Churn flag (no prescription in 90 days)
    CASE
        WHEN DATEDIFF(DAY, LAST_PRESCRIPTION_DATE, CURRENT_DATE()) > 90 THEN 1
        ELSE 0
    END AS CHURN_RISK_FLAG
FROM V_PATIENT_360;

SELECT 'Churn analysis features created' AS STATUS;

-- ============================================================================
-- STEP 2: Exploratory Analysis
-- ============================================================================

-- Talking Point: "Let's see how many patients are at risk"

-- Overall churn statistics
SELECT 
    COUNT(*) AS total_patients,
    SUM(CHURN_RISK_FLAG) AS at_risk_patients,
    ROUND(100.0 * SUM(CHURN_RISK_FLAG) / COUNT(*), 2) AS churn_rate_pct,
    ROUND(AVG(DAYS_SINCE_LAST_RX), 1) AS avg_days_since_last_rx
FROM V_PATIENT_CHURN_FEATURES;

-- Churn rate by customer tier
SELECT 
    VALUE_TIER,
    COUNT(*) AS patient_count,
    SUM(CHURN_RISK_FLAG) AS at_risk_count,
    ROUND(100.0 * SUM(CHURN_RISK_FLAG) / COUNT(*), 2) AS churn_rate_pct,
    ROUND(SUM(LIFETIME_VALUE_GBP), 2) AS total_value_gbp,
    ROUND(SUM(CASE WHEN CHURN_RISK_FLAG = 1 THEN LIFETIME_VALUE_GBP ELSE 0 END), 2) AS at_risk_value_gbp
FROM V_PATIENT_CHURN_FEATURES
GROUP BY VALUE_TIER
ORDER BY 
    CASE VALUE_TIER
        WHEN 'Platinum' THEN 1
        WHEN 'Gold' THEN 2
        WHEN 'Silver' THEN 3
        WHEN 'Bronze' THEN 4
    END;

-- Churn rate by age group
SELECT 
    AGE_GROUP,
    COUNT(*) AS patient_count,
    SUM(CHURN_RISK_FLAG) AS at_risk_count,
    ROUND(100.0 * SUM(CHURN_RISK_FLAG) / COUNT(*), 2) AS churn_rate_pct,
    ROUND(AVG(ENGAGEMENT_SCORE), 2) AS avg_engagement_score
FROM V_PATIENT_CHURN_FEATURES
GROUP BY AGE_GROUP
ORDER BY 
    CASE AGE_GROUP
        WHEN '18-30' THEN 1
        WHEN '31-50' THEN 2
        WHEN '51-65' THEN 3
        WHEN '65+' THEN 4
    END;

-- ============================================================================
-- STEP 3: Identify High-Value At-Risk Patients
-- ============================================================================

-- Talking Point: "These are our highest-value patients at risk of churning"

SELECT 
    PATIENT_ID,
    AGE,
    GENDER,
    VALUE_TIER,
    LIFETIME_VALUE_GBP,
    TOTAL_PRESCRIPTIONS,
    DAYS_SINCE_LAST_RX,
    ENGAGEMENT_SCORE
FROM V_PATIENT_CHURN_FEATURES
WHERE CHURN_RISK_FLAG = 1
    AND LIFETIME_VALUE_GBP > 1000
ORDER BY LIFETIME_VALUE_GBP DESC
LIMIT 20;

-- Revenue at risk summary
SELECT 
    'High-Value At-Risk Patients' AS segment,
    COUNT(*) AS patient_count,
    ROUND(SUM(LIFETIME_VALUE_GBP), 2) AS total_at_risk_value_gbp,
    ROUND(AVG(LIFETIME_VALUE_GBP), 2) AS avg_value_per_patient,
    ROUND(AVG(DAYS_SINCE_LAST_RX), 1) AS avg_days_inactive
FROM V_PATIENT_CHURN_FEATURES
WHERE CHURN_RISK_FLAG = 1
    AND LIFETIME_VALUE_GBP > 1000;

-- ============================================================================
-- STEP 4: Create Marketing Segments
-- ============================================================================

-- Talking Point: "Let's create actionable segments for the marketing team"

CREATE OR REPLACE TABLE PATIENT_MARKETING_SEGMENTS AS
SELECT 
    *,
    CASE
        WHEN CHURN_RISK_FLAG = 1 AND LIFETIME_VALUE_GBP > 2000 THEN 'VIP_RETENTION'
        WHEN CHURN_RISK_FLAG = 1 AND LIFETIME_VALUE_GBP > 500 THEN 'HIGH_VALUE_WINBACK'
        WHEN CHURN_RISK_FLAG = 1 THEN 'STANDARD_WINBACK'
        WHEN ENGAGEMENT_SCORE < 20 AND CHURN_RISK_FLAG = 0 THEN 'LOW_ENGAGEMENT_ACTIVE'
        WHEN LIFETIME_VALUE_GBP > 2000 THEN 'VIP_ACTIVE'
        ELSE 'STANDARD_ACTIVE'
    END AS MARKETING_SEGMENT
FROM V_PATIENT_CHURN_FEATURES;

-- Segment summary
SELECT 
    MARKETING_SEGMENT,
    COUNT(*) AS patient_count,
    ROUND(SUM(LIFETIME_VALUE_GBP), 2) AS total_value_gbp,
    ROUND(AVG(LIFETIME_VALUE_GBP), 2) AS avg_value_gbp,
    ROUND(AVG(ENGAGEMENT_SCORE), 2) AS avg_engagement_score
FROM PATIENT_MARKETING_SEGMENTS
GROUP BY MARKETING_SEGMENT
ORDER BY total_value_gbp DESC;

-- ============================================================================
-- STEP 5: Create Churn Risk Scores
-- ============================================================================

-- Talking Point: "We can create a simple churn risk score for prioritization"

CREATE OR REPLACE TABLE PATIENT_CHURN_RISK_SCORES AS
SELECT 
    PATIENT_ID,
    VALUE_TIER,
    AGE_GROUP,
    DAYS_SINCE_LAST_RX,
    ENGAGEMENT_SCORE,
    CHURN_RISK_FLAG,
    -- Simple churn risk score (0-100)
    ROUND(
        (DAYS_SINCE_LAST_RX * 0.5 + 
         (100 - COALESCE(ENGAGEMENT_SCORE, 50)) * 0.3 +
         CASE WHEN TOTAL_PRESCRIPTIONS < 3 THEN 20 ELSE 0 END),
        2
    ) AS CHURN_RISK_SCORE,
    CASE
        WHEN ROUND(
            (DAYS_SINCE_LAST_RX * 0.5 + 
             (100 - COALESCE(ENGAGEMENT_SCORE, 50)) * 0.3 +
             CASE WHEN TOTAL_PRESCRIPTIONS < 3 THEN 20 ELSE 0 END),
            2
        ) < 30 THEN 'Low Risk'
        WHEN ROUND(
            (DAYS_SINCE_LAST_RX * 0.5 + 
             (100 - COALESCE(ENGAGEMENT_SCORE, 50)) * 0.3 +
             CASE WHEN TOTAL_PRESCRIPTIONS < 3 THEN 20 ELSE 0 END),
            2
        ) < 60 THEN 'Medium Risk'
        ELSE 'High Risk'
    END AS RISK_CATEGORY
FROM V_PATIENT_CHURN_FEATURES;

-- Show distribution of risk scores
SELECT 
    RISK_CATEGORY,
    COUNT(*) AS patient_count,
    ROUND(AVG(CHURN_RISK_SCORE), 2) AS avg_risk_score,
    ROUND(SUM(LIFETIME_VALUE_GBP), 2) AS total_value_at_risk
FROM PATIENT_CHURN_RISK_SCORES pcrs
JOIN V_PATIENT_360 p360 ON pcrs.PATIENT_ID = p360.PATIENT_ID
GROUP BY RISK_CATEGORY
ORDER BY 
    CASE RISK_CATEGORY
        WHEN 'High Risk' THEN 1
        WHEN 'Medium Risk' THEN 2
        WHEN 'Low Risk' THEN 3
    END;

SELECT 'Churn analysis complete - Tables created for marketing activation' AS STATUS;

-- ============================================================================
-- DEMO TALKING POINTS
-- ============================================================================

-- 1. "Snowflake Notebooks brings Jupyter to your data - no data movement required"
-- 2. "Data scientists can use Python, visualize results, and share with stakeholders"
-- 3. "All work is versioned, collaborative, and governed by Snowflake's security"
-- 4. "From exploration to production - seamless workflow"
-- 5. "Results are immediately available as tables for business teams to use"

-- ============================================================================
-- BUSINESS RECOMMENDATIONS
-- ============================================================================

SELECT '=== IMMEDIATE ACTIONS ===' AS RECOMMENDATIONS
UNION ALL SELECT '1. Launch VIP_RETENTION campaign to high-value at-risk patients'
UNION ALL SELECT '2. Offer loyalty incentives to HIGH_VALUE_WINBACK segment'
UNION ALL SELECT '3. Call center outreach to top 100 at-risk patients'
UNION ALL SELECT ''
UNION ALL SELECT '=== THIS MONTH ==='
UNION ALL SELECT '4. Implement automated 60-day inactivity alerts'
UNION ALL SELECT '5. Create re-engagement campaign series'
UNION ALL SELECT '6. Enhance marketing personalization'
UNION ALL SELECT ''
UNION ALL SELECT '=== THIS QUARTER ==='
UNION ALL SELECT '7. Build predictive ML model using XGBoost'
UNION ALL SELECT '8. Integrate churn scores into CRM'
UNION ALL SELECT '9. Develop proactive retention programs';

-- ============================================================================
-- COMPETITIVE DIFFERENTIATION
-- ============================================================================

-- "Microsoft Fabric requires you to export data to Azure ML or Synapse for this analysis"
-- "With Snowflake, data never leaves the platform - it's all here, governed and secure"
-- "Notebooks + Data + ML + Governance = One unified platform"
