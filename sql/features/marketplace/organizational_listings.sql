-- ============================================================================
-- Pharmacy2U Demo - Organizational Listings (Internal Marketplace)
-- Purpose: Create internal data products for secure sharing across teams
-- Key Feature: Break down data silos, enable self-service data discovery
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE PHARMACY2U_DEMO_WH;

-- ============================================================================
-- STEP 1: Create Schema for Shared Data Products
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS PHARMACY2U_GOLD.DATA_PRODUCTS
    COMMENT = 'Schema for curated data products available on internal marketplace';

USE SCHEMA PHARMACY2U_GOLD.DATA_PRODUCTS;

SELECT 'Data Products schema created for internal marketplace' AS STATUS;

-- ============================================================================
-- STEP 2: Create Data Product 1 - Patient 360 Analytics
-- ============================================================================

-- Secure view for Patient 360 (respects existing access policies)
CREATE OR REPLACE SECURE VIEW PATIENT_360_ANALYTICS_PRODUCT AS
SELECT 
    PATIENT_ID,
    AGE,
    GENDER,
    POSTCODE,  -- Will be masked based on role
    TOTAL_PRESCRIPTIONS,
    UNIQUE_DRUGS,
    LIFETIME_VALUE_GBP,
    LAST_PRESCRIPTION_DATE,
    MARKETING_INTERACTIONS,
    CAMPAIGN_CONVERSIONS,
    REGISTRATION_DATE,
    -- Add calculated metrics
    ROUND(LIFETIME_VALUE_GBP / NULLIF(TOTAL_PRESCRIPTIONS, 0), 2) AS AVG_PRESCRIPTION_VALUE,
    ROUND((CAMPAIGN_CONVERSIONS * 100.0 / NULLIF(MARKETING_INTERACTIONS, 0)), 2) AS ENGAGEMENT_RATE_PCT,
    CASE 
        WHEN LIFETIME_VALUE_GBP > 5000 THEN 'Platinum'
        WHEN LIFETIME_VALUE_GBP > 2000 THEN 'Gold'
        WHEN LIFETIME_VALUE_GBP > 500 THEN 'Silver'
        ELSE 'Bronze'
    END AS CUSTOMER_TIER
FROM PHARMACY2U_GOLD.ANALYTICS.V_PATIENT_360;

COMMENT ON VIEW PATIENT_360_ANALYTICS_PRODUCT IS 'Secure Patient 360 view for internal analytics - respects all masking and access policies';

-- Sample queries document for this data product
CREATE OR REPLACE TABLE PATIENT_360_SAMPLE_QUERIES (
    query_name VARCHAR,
    query_description VARCHAR,
    sample_sql VARCHAR,
    use_case VARCHAR
) AS
SELECT 
    'High-Value Patient Count',
    'Count patients with lifetime value > £2000',
    'SELECT COUNT(*) FROM PATIENT_360_ANALYTICS_PRODUCT WHERE LIFETIME_VALUE_GBP > 2000',
    'Business Intelligence'
UNION ALL SELECT 
    'Customer Tier Distribution',
    'Breakdown of patients by value tier',
    'SELECT CUSTOMER_TIER, COUNT(*) FROM PATIENT_360_ANALYTICS_PRODUCT GROUP BY 1',
    'Executive Reporting'
UNION ALL SELECT 
    'Marketing Engagement Analysis',
    'Average engagement rate by age group',
    'SELECT CASE WHEN AGE < 50 THEN ''Under 50'' ELSE ''50+'' END AS age_segment, AVG(ENGAGEMENT_RATE_PCT) FROM PATIENT_360_ANALYTICS_PRODUCT GROUP BY 1',
    'Marketing Analytics'
UNION ALL SELECT 
    'Geographic Analysis',
    'Patient distribution by postcode prefix',
    'SELECT LEFT(POSTCODE, 2) AS region, COUNT(*) FROM PATIENT_360_ANALYTICS_PRODUCT GROUP BY 1',
    'Operations Planning';

SELECT 'Data Product 1: Patient 360 Analytics - Created' AS STATUS;

-- ============================================================================
-- STEP 3: Create Data Product 2 - Churn Risk Scores
-- ============================================================================

-- Secure view for ML-generated churn scores (for marketing activation)
CREATE OR REPLACE SECURE VIEW CHURN_RISK_PRODUCT AS
SELECT 
    pcrs.PATIENT_ID,
    pcrs.VALUE_TIER,
    pcrs.AGE_GROUP,
    pcrs.CHURN_RISK_SCORE,
    pcrs.RISK_CATEGORY,
    p360.LIFETIME_VALUE_GBP,
    p360.TOTAL_PRESCRIPTIONS,
    p360.MARKETING_INTERACTIONS,
    pms.MARKETING_SEGMENT,
    -- Add actionable insights
    CASE 
        WHEN pcrs.RISK_CATEGORY = 'High Risk' AND p360.LIFETIME_VALUE_GBP > 2000 THEN 'IMMEDIATE_ACTION_REQUIRED'
        WHEN pcrs.RISK_CATEGORY = 'High Risk' THEN 'RETENTION_CAMPAIGN'
        WHEN pcrs.RISK_CATEGORY = 'Medium Risk' THEN 'MONITOR'
        ELSE 'MAINTAIN_RELATIONSHIP'
    END AS RECOMMENDED_ACTION
FROM PHARMACY2U_GOLD.ANALYTICS.PATIENT_CHURN_RISK_SCORES pcrs
JOIN PHARMACY2U_GOLD.ANALYTICS.V_PATIENT_360 p360 
    ON pcrs.PATIENT_ID = p360.PATIENT_ID
LEFT JOIN PHARMACY2U_GOLD.ANALYTICS.PATIENT_MARKETING_SEGMENTS pms
    ON pcrs.PATIENT_ID = pms.PATIENT_ID;

COMMENT ON VIEW CHURN_RISK_PRODUCT IS 'ML-powered churn risk scores for retention campaigns';

-- Sample queries for churn risk product
CREATE OR REPLACE TABLE CHURN_RISK_SAMPLE_QUERIES (
    query_name VARCHAR,
    query_description VARCHAR,
    sample_sql VARCHAR,
    use_case VARCHAR
) AS
SELECT 
    'High-Risk VIP Patients',
    'Patients requiring immediate retention action',
    'SELECT PATIENT_ID, CHURN_RISK_SCORE, LIFETIME_VALUE_GBP FROM CHURN_RISK_PRODUCT WHERE RECOMMENDED_ACTION = ''IMMEDIATE_ACTION_REQUIRED'' ORDER BY LIFETIME_VALUE_GBP DESC',
    'VIP Retention Campaign'
UNION ALL SELECT 
    'Retention Campaign List',
    'All patients needing retention campaigns',
    'SELECT PATIENT_ID, MARKETING_SEGMENT, RISK_CATEGORY FROM CHURN_RISK_PRODUCT WHERE RECOMMENDED_ACTION IN (''IMMEDIATE_ACTION_REQUIRED'', ''RETENTION_CAMPAIGN'')',
    'Marketing Campaign Planning'
UNION ALL SELECT 
    'Revenue at Risk',
    'Total lifetime value at risk by segment',
    'SELECT MARKETING_SEGMENT, SUM(LIFETIME_VALUE_GBP) AS revenue_at_risk FROM CHURN_RISK_PRODUCT WHERE RISK_CATEGORY = ''High Risk'' GROUP BY 1',
    'Financial Planning';

SELECT 'Data Product 2: Churn Risk Scores - Created' AS STATUS;

-- ============================================================================
-- STEP 4: Create Data Product 3 - Prescription Analytics
-- ============================================================================

-- Aggregate prescription insights (no PII, safe for broad sharing)
CREATE OR REPLACE SECURE VIEW PRESCRIPTION_ANALYTICS_PRODUCT AS
SELECT 
    DRUG_NAME,
    COUNT(DISTINCT PATIENT_ID) AS unique_patients,
    COUNT(*) AS total_prescriptions,
    SUM(QUANTITY) AS total_quantity,
    SUM(COST_GBP) AS total_cost_gbp,
    ROUND(AVG(COST_GBP), 2) AS avg_cost_per_prescription,
    MIN(PRESCRIPTION_DATE) AS first_prescription_date,
    MAX(PRESCRIPTION_DATE) AS most_recent_prescription_date,
    COUNT(DISTINCT PRESCRIBER_ID) AS unique_prescribers,
    COUNT(DISTINCT PHARMACY_ID) AS unique_pharmacies
FROM PHARMACY2U_SILVER.GOVERNED_DATA.PRESCRIPTIONS
GROUP BY DRUG_NAME;

COMMENT ON VIEW PRESCRIPTION_ANALYTICS_PRODUCT IS 'Aggregated prescription analytics - no PII, safe for wide distribution';

-- Sample queries for prescription analytics
CREATE OR REPLACE TABLE PRESCRIPTION_ANALYTICS_SAMPLE_QUERIES (
    query_name VARCHAR,
    query_description VARCHAR,
    sample_sql VARCHAR,
    use_case VARCHAR
) AS
SELECT 
    'Top 10 Prescribed Drugs',
    'Most commonly prescribed medications',
    'SELECT DRUG_NAME, total_prescriptions, unique_patients FROM PRESCRIPTION_ANALYTICS_PRODUCT ORDER BY total_prescriptions DESC LIMIT 10',
    'Clinical Operations'
UNION ALL SELECT 
    'High-Cost Medications',
    'Drugs with highest total cost',
    'SELECT DRUG_NAME, total_cost_gbp, unique_patients FROM PRESCRIPTION_ANALYTICS_PRODUCT ORDER BY total_cost_gbp DESC LIMIT 10',
    'Financial Analysis'
UNION ALL SELECT 
    'Pharmacy Network Coverage',
    'Average number of pharmacies per drug',
    'SELECT AVG(unique_pharmacies) AS avg_pharmacy_coverage FROM PRESCRIPTION_ANALYTICS_PRODUCT',
    'Network Planning';

SELECT 'Data Product 3: Prescription Analytics - Created' AS STATUS;

-- ============================================================================
-- STEP 5: Create Data Product Catalog
-- ============================================================================

-- Metadata catalog for all available data products
CREATE OR REPLACE TABLE DATA_PRODUCT_CATALOG (
    product_id VARCHAR,
    product_name VARCHAR,
    product_description VARCHAR,
    data_object_name VARCHAR,
    data_owner VARCHAR,
    business_domain VARCHAR,
    refresh_frequency VARCHAR,
    row_count NUMBER,
    pii_status VARCHAR,
    governance_level VARCHAR,
    target_audience VARCHAR,
    use_cases VARCHAR,
    created_date DATE,
    last_updated DATE
) AS
SELECT 
    'DP001',
    'Patient 360 Analytics',
    'Comprehensive patient demographics, prescription history, and marketing engagement data. Includes customer tier segmentation and engagement metrics for targeted analytics.',
    'PATIENT_360_ANALYTICS_PRODUCT',
    'Analytics Team',
    'Patient & Marketing Analytics',
    'Real-time (via Dynamic Tables)',
    (SELECT COUNT(*) FROM PATIENT_360_ANALYTICS_PRODUCT),
    'Contains PII - Masked per user role',
    'GOVERNED - Access policies applied',
    'Marketing, BI Analysts, Data Scientists',
    'Customer segmentation, Lifetime value analysis, Campaign targeting, Executive dashboards',
    CURRENT_DATE(),
    CURRENT_DATE()
UNION ALL SELECT 
    'DP002',
    'Churn Risk Scores',
    'ML-generated patient churn risk predictions with actionable recommendations. Enables proactive retention campaigns and identifies high-value at-risk customers.',
    'CHURN_RISK_PRODUCT',
    'Data Science Team',
    'Patient Retention & ML',
    'Daily',
    (SELECT COUNT(*) FROM CHURN_RISK_PRODUCT),
    'Contains PII - Masked per user role',
    'GOVERNED - Access policies applied',
    'Marketing, Customer Success, Executives',
    'Retention campaigns, VIP customer care, Revenue protection, Marketing ROI analysis',
    CURRENT_DATE(),
    CURRENT_DATE()
UNION ALL SELECT 
    'DP003',
    'Prescription Analytics',
    'Aggregated prescription statistics by drug including cost, volume, and network metrics. No PII - safe for broad distribution across the organization.',
    'PRESCRIPTION_ANALYTICS_PRODUCT',
    'Clinical Operations Team',
    'Prescription & Clinical Data',
    'Daily',
    (SELECT COUNT(*) FROM PRESCRIPTION_ANALYTICS_PRODUCT),
    'No PII - Aggregated data only',
    'PUBLIC (within org) - No restrictions',
    'All teams - Clinical, Finance, Operations, Strategy',
    'Drug utilization analysis, Cost management, Network planning, Inventory forecasting',
    CURRENT_DATE(),
    CURRENT_DATE();

SELECT 'Data Product Catalog created with 3 products' AS STATUS;

-- ============================================================================
-- STEP 6: Create Access Request Tracking
-- ============================================================================

-- Table to track who has access to which data products
CREATE OR REPLACE TABLE DATA_PRODUCT_ACCESS_LOG (
    access_id VARCHAR DEFAULT UUID_STRING(),
    product_id VARCHAR,
    requesting_user VARCHAR,
    requesting_team VARCHAR,
    access_granted_date TIMESTAMP,
    access_granted_by VARCHAR,
    business_justification VARCHAR,
    access_level VARCHAR
) COMMENT = 'Audit log for data product access requests and approvals';

-- Sample access records
INSERT INTO DATA_PRODUCT_ACCESS_LOG 
    (product_id, requesting_user, requesting_team, access_granted_date, access_granted_by, business_justification, access_level)
VALUES
    ('DP001', 'PHARMACY2U_BI_USER', 'Business Intelligence', CURRENT_TIMESTAMP(), 'ACCOUNTADMIN', 'Dashboard creation and executive reporting', 'READ'),
    ('DP002', 'PHARMACY2U_DATA_ANALYST', 'Marketing', CURRENT_TIMESTAMP(), 'ACCOUNTADMIN', 'Retention campaign planning', 'READ'),
    ('DP003', 'PHARMACY2U_BI_USER', 'Operations', CURRENT_TIMESTAMP(), 'ACCOUNTADMIN', 'Clinical operations analysis', 'READ');

SELECT 'Access tracking configured' AS STATUS;

-- ============================================================================
-- STEP 7: Create Secure Shares (for potential publishing to listings)
-- ============================================================================

-- Note: Actual listing creation requires Snowsight UI or account admin configuration
-- These shares can be attached to organizational listings

-- Share 1: Patient Analytics (for internal analytics teams)
CREATE OR REPLACE SHARE PATIENT_ANALYTICS_SHARE
    COMMENT = 'Secure share for Patient 360 Analytics - Internal use only';

-- Note: In production, data products would be materialized tables in DATA_PRODUCTS schema
-- For demo purposes, we'll show the catalog and explain organizational listings concept

-- In production, you would:
-- 1. Materialize views as tables in DATA_PRODUCTS schema
-- 2. Create shares on those tables
-- 3. Publish shares to organizational listings via Snowsight UI

GRANT USAGE ON DATABASE PHARMACY2U_GOLD TO SHARE PATIENT_ANALYTICS_SHARE;
GRANT USAGE ON SCHEMA PHARMACY2U_GOLD.DATA_PRODUCTS TO SHARE PATIENT_ANALYTICS_SHARE;
GRANT SELECT ON TABLE PHARMACY2U_GOLD.DATA_PRODUCTS.DATA_PRODUCT_CATALOG TO SHARE PATIENT_ANALYTICS_SHARE;
-- Note: Views referencing other databases cannot be shared
-- GRANT SELECT ON VIEW PHARMACY2U_GOLD.DATA_PRODUCTS.PATIENT_360_ANALYTICS_PRODUCT TO SHARE PATIENT_ANALYTICS_SHARE;

-- Share 2: Churn Risk (for marketing teams)
CREATE OR REPLACE SHARE CHURN_RISK_SHARE
    COMMENT = 'Secure share for Churn Risk Scores - Marketing use';

GRANT USAGE ON DATABASE PHARMACY2U_GOLD TO SHARE CHURN_RISK_SHARE;
GRANT USAGE ON SCHEMA PHARMACY2U_GOLD.DATA_PRODUCTS TO SHARE CHURN_RISK_SHARE;
GRANT SELECT ON TABLE PHARMACY2U_GOLD.DATA_PRODUCTS.DATA_PRODUCT_CATALOG TO SHARE CHURN_RISK_SHARE;

-- Share 3: Prescription Analytics (for all teams)
CREATE OR REPLACE SHARE PRESCRIPTION_ANALYTICS_SHARE
    COMMENT = 'Secure share for Prescription Analytics - Organization-wide';

GRANT USAGE ON DATABASE PHARMACY2U_GOLD TO SHARE PRESCRIPTION_ANALYTICS_SHARE;
GRANT USAGE ON SCHEMA PHARMACY2U_GOLD.DATA_PRODUCTS TO SHARE PRESCRIPTION_ANALYTICS_SHARE;
GRANT SELECT ON TABLE PHARMACY2U_GOLD.DATA_PRODUCTS.DATA_PRODUCT_CATALOG TO SHARE PRESCRIPTION_ANALYTICS_SHARE;

SELECT 'Secure shares created - ready for publishing to listings' AS STATUS;

-- Show created shares
SHOW SHARES LIKE '%_SHARE';

SELECT '✅ Note: In Snowsight UI, these shares can be published to Organizational Listings' AS PRODUCTION_NOTE;

-- ============================================================================
-- STEP 8: Data Product Discovery Interface
-- ============================================================================

-- View for self-service data product discovery
CREATE OR REPLACE VIEW V_DATA_PRODUCT_DISCOVERY AS
SELECT 
    dpc.product_id,
    dpc.product_name,
    dpc.product_description,
    dpc.business_domain,
    dpc.data_owner,
    dpc.refresh_frequency,
    dpc.pii_status,
    dpc.governance_level,
    dpc.target_audience,
    dpc.use_cases,
    dpc.row_count,
    COUNT(DISTINCT dpal.requesting_user) AS total_users,
    MAX(dpal.access_granted_date) AS last_access_granted
FROM DATA_PRODUCT_CATALOG dpc
LEFT JOIN DATA_PRODUCT_ACCESS_LOG dpal ON dpc.product_id = dpal.product_id
GROUP BY 
    dpc.product_id, dpc.product_name, dpc.product_description,
    dpc.business_domain, dpc.data_owner, dpc.refresh_frequency,
    dpc.pii_status, dpc.governance_level, dpc.target_audience,
    dpc.use_cases, dpc.row_count;

COMMENT ON VIEW V_DATA_PRODUCT_DISCOVERY IS 'Self-service data product discovery portal';

SELECT 'Data product discovery interface created' AS STATUS;

-- ============================================================================
-- DEMONSTRATION QUERIES
-- ============================================================================

SELECT '=== INTERNAL DATA MARKETPLACE: AVAILABLE PRODUCTS ===' AS DEMO;

-- Show all available data products
SELECT 
    product_id,
    product_name,
    business_domain,
    target_audience,
    pii_status,
    row_count,
    total_users AS current_users
FROM V_DATA_PRODUCT_DISCOVERY
ORDER BY product_id;

-- ============================================================================
-- DEMO TALKING POINTS
-- ============================================================================

SELECT '=== Organizational Listings Demo Talking Points ===' AS INFO;

SELECT 
    'Point 1: Internal data marketplace breaks down silos across teams' AS talking_point
UNION ALL SELECT 'Point 2: Self-service discovery - find and request data in minutes'
UNION ALL SELECT 'Point 3: Governance preserved - access policies travel with the data'
UNION ALL SELECT 'Point 4: Zero data movement - live shares, no copies'
UNION ALL SELECT 'Point 5: Sample queries included - instant productivity'
UNION ALL SELECT 'Point 6: Fabric requires manual SharePoint/Teams coordination';

SELECT 'Organizational listings (Internal Marketplace) implementation complete!' AS FINAL_STATUS;
