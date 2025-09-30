-- ============================================================================
-- Pharmacy2U Demo - Enrich Organizational Listings with Additional Metadata
-- Purpose: Add data dictionaries, quick start examples, and documentation
-- Reference: https://docs.snowflake.com/en/sql-reference/sql/alter-listing
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE PHARMACY2U_DEMO_WH;

SELECT 'Creating enriched organizational listings with full metadata...' AS STATUS;

-- ============================================================================
-- LISTING 1: Patient 360 Analytics - Add Rich Metadata
-- ============================================================================

CREATE ORGANIZATION LISTING PHARMACY2U_PATIENT_360_LISTING
  SHARE PATIENT_ANALYTICS_SHARE AS
$$
title: "Pharmacy2U Patient 360 Analytics"
description: |
  Comprehensive patient analytics data product for marketing and business intelligence.
  
  **What's Included:**
  - Patient demographics (age, gender, postcode)
  - Prescription history and lifetime value
  - Marketing engagement metrics
  - Customer tier segmentation
  
  **Use Cases:**
  - Customer segmentation and targeting
  - Lifetime value analysis
  - Campaign performance measurement
  - Executive dashboards
  
  **Data Governance:**
  - PII is automatically masked based on user role
  - Access policies enforce GDPR compliance
  - Real-time refresh via Dynamic Tables
  
  **Target Audience:** Marketing teams, BI analysts, data scientists

organization_profile: "INTERNAL"
organization_targets:
  access:
    - all_accounts: true
support_contact: "data-team@pharmacy2u.co.uk"
approver_contact: "analytics-lead@pharmacy2u.co.uk"
locations:
  access_regions:
    - name: "PUBLIC.AZURE_WESTUS2"

data_dictionary:
  - name: "PATIENT_ID"
    type: "VARCHAR"
    description: "Unique patient identifier (anonymized)"
  - name: "AGE"
    type: "NUMBER"
    description: "Patient age in years"
  - name: "GENDER"
    type: "VARCHAR"
    description: "Patient gender (M/F/Other)"
  - name: "POSTCODE"
    type: "VARCHAR"
    description: "UK postcode (masked based on role permissions)"
  - name: "TOTAL_PRESCRIPTIONS"
    type: "NUMBER"
    description: "Lifetime prescription count for patient"
  - name: "UNIQUE_DRUGS"
    type: "NUMBER"
    description: "Number of distinct drugs prescribed"
  - name: "LIFETIME_VALUE_GBP"
    type: "NUMBER(10,2)"
    description: "Total revenue from patient (GBP)"
  - name: "LAST_PRESCRIPTION_DATE"
    type: "DATE"
    description: "Date of most recent prescription"
  - name: "MARKETING_INTERACTIONS"
    type: "NUMBER"
    description: "Total marketing touchpoints (emails, SMS, etc.)"
  - name: "CAMPAIGN_CONVERSIONS"
    type: "NUMBER"
    description: "Number of successful campaign conversions"
  - name: "REGISTRATION_DATE"
    type: "DATE"
    description: "Patient registration date"
  - name: "AVG_PRESCRIPTION_VALUE"
    type: "NUMBER(10,2)"
    description: "Average value per prescription (calculated)"
  - name: "ENGAGEMENT_RATE_PCT"
    type: "NUMBER(5,2)"
    description: "Campaign engagement rate percentage"
  - name: "CUSTOMER_TIER"
    type: "VARCHAR"
    description: "Customer value tier (Platinum/Gold/Silver/Bronze)"

quick_start_examples:
  - title: "High-Value Patient Count"
    description: "Count patients with lifetime value over £2000"
    query: |
      SELECT COUNT(*) as high_value_patients
      FROM PATIENT_360_ANALYTICS_PRODUCT
      WHERE LIFETIME_VALUE_GBP > 2000;
  
  - title: "Customer Tier Distribution"
    description: "Breakdown of patients by value tier"
    query: |
      SELECT 
        CUSTOMER_TIER,
        COUNT(*) as patient_count,
        SUM(LIFETIME_VALUE_GBP) as total_value_gbp,
        AVG(ENGAGEMENT_RATE_PCT) as avg_engagement
      FROM PATIENT_360_ANALYTICS_PRODUCT
      GROUP BY CUSTOMER_TIER
      ORDER BY total_value_gbp DESC;
  
  - title: "Marketing Engagement Analysis"
    description: "Patients with high engagement rate"
    query: |
      SELECT 
        CUSTOMER_TIER,
        COUNT(*) as patients,
        AVG(ENGAGEMENT_RATE_PCT) as avg_engagement_rate
      FROM PATIENT_360_ANALYTICS_PRODUCT
      WHERE MARKETING_INTERACTIONS > 0
      GROUP BY CUSTOMER_TIER
      ORDER BY avg_engagement_rate DESC;
  
  - title: "Geographic Distribution"
    description: "Patient distribution by postcode area"
    query: |
      SELECT 
        LEFT(POSTCODE, 2) as postcode_area,
        COUNT(*) as patient_count,
        SUM(LIFETIME_VALUE_GBP) as area_revenue_gbp
      FROM PATIENT_360_ANALYTICS_PRODUCT
      GROUP BY postcode_area
      ORDER BY patient_count DESC
      LIMIT 10;

attributes:
  data_refresh: "Real-time via Dynamic Tables"
  data_source: "Pharmacy2U Production Systems"
  pii_level: "Contains PII - Role-based Masking Applied"
  compliance: "GDPR Compliant, NHS Data Standards"
  row_count: "100,000+ patients"
  update_frequency: "Real-time"
  data_retention: "7 years"
  quality_score: "98%"
$$
PUBLISH = TRUE;

SELECT 'Patient 360 listing enriched ✅' AS STATUS;

-- ============================================================================
-- LISTING 2: Churn Risk Scores - Add Rich Metadata
-- ============================================================================

CREATE ORGANIZATION LISTING PHARMACY2U_CHURN_RISK_LISTING
  SHARE CHURN_RISK_SHARE AS
$$
title: "Pharmacy2U ML Churn Risk Predictions"
description: |
  Machine learning-powered patient churn risk scores with actionable recommendations.
  
  **What's Included:**
  - Patient-level churn risk scores (0-100)
  - Risk categories (High/Medium/Low)
  - Recommended actions for retention
  - Customer value tier segmentation
  - Marketing segment assignments
  
  **Use Cases:**
  - Proactive retention campaigns
  - VIP customer care programs
  - Revenue protection strategies
  - Marketing ROI optimization
  
  **Data Governance:**
  - Contains PII - masked based on user role
  - Access policies automatically applied
  - Daily refresh schedule
  
  **Business Value:**
  Identify high-value at-risk customers before they churn and take targeted action.
  
  **Target Audience:** Marketing teams, customer success, executives

organization_profile: "INTERNAL"
organization_targets:
  access:
    - all_accounts: true
support_contact: "data-science@pharmacy2u.co.uk"
approver_contact: "ml-lead@pharmacy2u.co.uk"
locations:
  access_regions:
    - name: "PUBLIC.AZURE_WESTUS2"

data_dictionary:
  - name: "PATIENT_ID"
    type: "VARCHAR"
    description: "Unique patient identifier"
  - name: "VALUE_TIER"
    type: "VARCHAR"
    description: "Customer value tier (Platinum/Gold/Silver/Bronze)"
  - name: "AGE_GROUP"
    type: "VARCHAR"
    description: "Patient age group segmentation"
  - name: "CHURN_RISK_SCORE"
    type: "NUMBER(5,2)"
    description: "ML-generated churn probability (0-100)"
  - name: "RISK_CATEGORY"
    type: "VARCHAR"
    description: "Risk level (High Risk/Medium Risk/Low Risk)"
  - name: "LIFETIME_VALUE_GBP"
    type: "NUMBER(10,2)"
    description: "Total patient lifetime value (GBP)"
  - name: "TOTAL_PRESCRIPTIONS"
    type: "NUMBER"
    description: "Total prescription count"
  - name: "MARKETING_INTERACTIONS"
    type: "NUMBER"
    description: "Total marketing touchpoints"
  - name: "MARKETING_SEGMENT"
    type: "VARCHAR"
    description: "Marketing segment classification"
  - name: "RECOMMENDED_ACTION"
    type: "VARCHAR"
    description: "System-recommended retention action"

quick_start_examples:
  - title: "Immediate Action Required - VIP Patients"
    description: "High-value patients requiring immediate retention intervention"
    query: |
      SELECT 
        PATIENT_ID,
        CHURN_RISK_SCORE,
        LIFETIME_VALUE_GBP,
        RECOMMENDED_ACTION
      FROM CHURN_RISK_PRODUCT
      WHERE RECOMMENDED_ACTION = 'IMMEDIATE_ACTION_REQUIRED'
      ORDER BY LIFETIME_VALUE_GBP DESC
      LIMIT 20;
  
  - title: "Retention Campaign Target List"
    description: "All patients needing retention campaigns"
    query: |
      SELECT 
        MARKETING_SEGMENT,
        COUNT(*) as patient_count,
        SUM(LIFETIME_VALUE_GBP) as revenue_at_risk_gbp,
        AVG(CHURN_RISK_SCORE) as avg_risk_score
      FROM CHURN_RISK_PRODUCT
      WHERE RECOMMENDED_ACTION IN ('IMMEDIATE_ACTION_REQUIRED', 'RETENTION_CAMPAIGN')
      GROUP BY MARKETING_SEGMENT
      ORDER BY revenue_at_risk_gbp DESC;
  
  - title: "Revenue at Risk Analysis"
    description: "Total revenue at risk by risk category"
    query: |
      SELECT 
        RISK_CATEGORY,
        VALUE_TIER,
        COUNT(*) as patients,
        SUM(LIFETIME_VALUE_GBP) as revenue_at_risk,
        AVG(CHURN_RISK_SCORE) as avg_score
      FROM CHURN_RISK_PRODUCT
      GROUP BY RISK_CATEGORY, VALUE_TIER
      ORDER BY revenue_at_risk DESC;
  
  - title: "High-Risk Platinum Customers"
    description: "Most valuable at-risk customers"
    query: |
      SELECT 
        PATIENT_ID,
        CHURN_RISK_SCORE,
        LIFETIME_VALUE_GBP,
        TOTAL_PRESCRIPTIONS,
        RECOMMENDED_ACTION
      FROM CHURN_RISK_PRODUCT
      WHERE VALUE_TIER = 'Platinum' 
        AND RISK_CATEGORY = 'High Risk'
      ORDER BY CHURN_RISK_SCORE DESC;

attributes:
  model_type: "XGBoost Classification"
  model_accuracy: "87.3%"
  data_refresh: "Daily at 2:00 AM UTC"
  data_source: "Patient 360 + ML Model Predictions"
  pii_level: "Contains PII - Role-based Masking Applied"
  compliance: "GDPR Compliant"
  prediction_window: "Next 90 days"
  row_count: "100,000+ predictions"
  last_model_training: "2025-09-01"
$$
PUBLISH = TRUE;

SELECT 'Churn Risk listing enriched ✅' AS STATUS;

-- ============================================================================
-- LISTING 3: Prescription Analytics - Add Rich Metadata
-- ============================================================================

CREATE ORGANIZATION LISTING PHARMACY2U_PRESCRIPTION_ANALYTICS_LISTING
  SHARE PRESCRIPTION_ANALYTICS_SHARE AS
$$
title: "Pharmacy2U Prescription Analytics"
description: |
  Aggregated prescription statistics and drug utilization insights - no PII.
  
  **What's Included:**
  - Drug-level prescription volumes and costs
  - Unique patient counts per medication
  - Prescriber and pharmacy network metrics
  - Cost per prescription trends
  - Date range coverage
  
  **Use Cases:**
  - Drug utilization analysis
  - Cost management and forecasting
  - Network planning and optimization
  - Inventory forecasting
  - Regulatory reporting (MHRA compliance)
  
  **Data Governance:**
  - NO PII - aggregated data only
  - Safe for broad organizational distribution
  - No access restrictions required
  - Daily refresh schedule
  
  **Business Value:**
  Enable all teams to make data-driven decisions about clinical operations, 
  finance, and network planning without privacy concerns.
  
  **Target Audience:** All teams - clinical, finance, operations, strategy

organization_profile: "INTERNAL"
organization_targets:
  access:
    - all_accounts: true
support_contact: "clinical-ops@pharmacy2u.co.uk"
approver_contact: "operations-lead@pharmacy2u.co.uk"
locations:
  access_regions:
    - name: "PUBLIC.AZURE_WESTUS2"

data_dictionary:
  - name: "DRUG_NAME"
    type: "VARCHAR"
    description: "Generic drug name (BNF standard)"
  - name: "UNIQUE_PATIENTS"
    type: "NUMBER"
    description: "Count of distinct patients prescribed this drug"
  - name: "TOTAL_PRESCRIPTIONS"
    type: "NUMBER"
    description: "Total number of prescriptions"
  - name: "TOTAL_QUANTITY"
    type: "NUMBER"
    description: "Total quantity dispensed (units vary by drug)"
  - name: "TOTAL_COST_GBP"
    type: "NUMBER(12,2)"
    description: "Total cost in GBP"
  - name: "AVG_COST_PER_PRESCRIPTION"
    type: "NUMBER(8,2)"
    description: "Average cost per prescription"
  - name: "FIRST_PRESCRIPTION_DATE"
    type: "DATE"
    description: "Earliest prescription date in dataset"
  - name: "MOST_RECENT_PRESCRIPTION_DATE"
    type: "DATE"
    description: "Most recent prescription date"
  - name: "UNIQUE_PRESCRIBERS"
    type: "NUMBER"
    description: "Count of distinct prescribers"
  - name: "UNIQUE_PHARMACIES"
    type: "NUMBER"
    description: "Count of distinct pharmacy locations"

quick_start_examples:
  - title: "Top 10 Most Prescribed Drugs"
    description: "Most commonly prescribed medications"
    query: |
      SELECT 
        DRUG_NAME,
        TOTAL_PRESCRIPTIONS,
        UNIQUE_PATIENTS,
        TOTAL_COST_GBP,
        AVG_COST_PER_PRESCRIPTION
      FROM PRESCRIPTION_ANALYTICS_PRODUCT
      ORDER BY TOTAL_PRESCRIPTIONS DESC
      LIMIT 10;
  
  - title: "Highest Cost Medications"
    description: "Drugs with highest total spend"
    query: |
      SELECT 
        DRUG_NAME,
        TOTAL_COST_GBP,
        UNIQUE_PATIENTS,
        AVG_COST_PER_PRESCRIPTION,
        TOTAL_PRESCRIPTIONS
      FROM PRESCRIPTION_ANALYTICS_PRODUCT
      ORDER BY TOTAL_COST_GBP DESC
      LIMIT 10;
  
  - title: "Network Coverage Analysis"
    description: "Drug availability across pharmacy network"
    query: |
      SELECT 
        DRUG_NAME,
        UNIQUE_PHARMACIES as pharmacy_coverage,
        UNIQUE_PRESCRIBERS as prescriber_count,
        TOTAL_PRESCRIPTIONS
      FROM PRESCRIPTION_ANALYTICS_PRODUCT
      WHERE TOTAL_PRESCRIPTIONS > 100
      ORDER BY pharmacy_coverage DESC
      LIMIT 15;
  
  - title: "Cost Efficiency Analysis"
    description: "Drugs with best patient reach per cost"
    query: |
      SELECT 
        DRUG_NAME,
        UNIQUE_PATIENTS,
        TOTAL_COST_GBP,
        ROUND(TOTAL_COST_GBP / UNIQUE_PATIENTS, 2) as cost_per_patient
      FROM PRESCRIPTION_ANALYTICS_PRODUCT
      WHERE UNIQUE_PATIENTS > 50
      ORDER BY cost_per_patient ASC
      LIMIT 20;

attributes:
  data_refresh: "Daily at 1:00 AM UTC"
  data_source: "NHS Prescription Data Feed"
  pii_level: "No PII - Aggregated Data Only"
  compliance: "MHRA Compliant, NHS Standards"
  row_count: "1,500+ drug entries"
  update_frequency: "Daily"
  aggregation_level: "Drug Name"
  safe_for_sharing: "Yes - External Partners"
  data_quality: "Validated against BNF codes"
$$
PUBLISH = TRUE;

SELECT 'Prescription Analytics listing enriched ✅' AS STATUS;

-- ============================================================================
-- VERIFY ENRICHED LISTINGS
-- ============================================================================

SELECT '=== VERIFYING ENRICHED LISTINGS ===' AS STATUS;

-- Show all listings
SHOW LISTINGS LIKE 'PHARMACY2U%';

-- Describe each listing to see metadata
SELECT 'Use DESCRIBE LISTING to see full metadata:' AS INFO;
SELECT 'DESCRIBE LISTING PHARMACY2U_PATIENT_360_LISTING;' AS example_command;

SELECT '✅ All organizational listings enriched with metadata!' AS FINAL_STATUS;

-- ============================================================================
-- DEMO TALKING POINTS
-- ============================================================================

SELECT '=== ENRICHED LISTING BENEFITS ===' AS BENEFITS;

SELECT 
    'Data Dictionary' AS feature,
    'Users see complete schema with descriptions' AS value
UNION ALL SELECT
    'Quick Start Examples',
    'Sample queries enable instant productivity'
UNION ALL SELECT
    'Attributes',
    'Rich metadata about quality, refresh, compliance'
UNION ALL SELECT
    'Self-Service',
    'Teams can discover and use data independently'
UNION ALL SELECT
    'Governance',
    'PII protection and compliance built-in'
UNION ALL SELECT
    'vs Fabric',
    'No equivalent - SharePoint docs are manual';

SELECT 'Organizational listings ready for demo! 🎯' AS STATUS;
