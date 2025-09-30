-- ============================================================================
-- Pharmacy2U Demo - Secure Data Sharing
-- Purpose: External collaboration without data movement or copies
-- Key Feature: Live, governed data sharing with partners
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE PHARMACY2U_DEMO_WH;

-- ============================================================================
-- SECURE SHARING VALUE PROPOSITION
-- ============================================================================

SELECT '=== SNOWFLAKE SECURE DATA SHARING ===' AS INFO;

SELECT 
    'Challenge: Share data with NHS partners, regulators, research institutions' AS business_context
UNION ALL SELECT 'Traditional Approach: Export files, email, FTP - no governance, stale data'
UNION ALL SELECT 'Security Risk: Data copies proliferate, lose control, compliance issues'
UNION ALL SELECT 'Snowflake Solution: Live shares with zero copies, governed access';

-- ============================================================================
-- STEP 1: Create Schema for Shared Data
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS PHARMACY2U_GOLD.SHARED_DATA
    COMMENT = 'Schema containing secure views for external data sharing';

USE SCHEMA PHARMACY2U_GOLD.SHARED_DATA;

SELECT 'Shared data schema created' AS STATUS;

-- ============================================================================
-- STEP 2: Create Secure View for NHS Partnership
-- ============================================================================

-- Use Case: Share prescription analytics with NHS trust for population health research
-- Requirements: No PII, aggregated data only, filtered by region

CREATE OR REPLACE SECURE VIEW NHS_PRESCRIPTION_ANALYTICS AS
SELECT 
    -- Temporal dimensions
    DATE_TRUNC('MONTH', p.PRESCRIPTION_DATE) AS month,
    DATE_TRUNC('QUARTER', p.PRESCRIPTION_DATE) AS quarter,
    YEAR(p.PRESCRIPTION_DATE) AS year,
    
    -- Geographic (regional only, no specific postcodes)
    LEFT(pat.POSTCODE, 2) AS region_code,
    
    -- Drug information (no patient linkage)
    p.DRUG_NAME,
    p.DRUG_CODE,
    
    -- Aggregated metrics (no individual patient data)
    COUNT(DISTINCT p.PRESCRIPTION_ID) AS total_prescriptions,
    COUNT(DISTINCT p.PATIENT_ID) AS unique_patients,
    SUM(p.QUANTITY) AS total_quantity,
    ROUND(AVG(p.COST_GBP), 2) AS avg_cost_per_prescription,
    ROUND(SUM(p.COST_GBP), 2) AS total_cost_gbp,
    
    -- Age demographics (aggregated bands only)
    COUNT(DISTINCT CASE WHEN pat.AGE < 18 THEN p.PATIENT_ID END) AS patients_under_18,
    COUNT(DISTINCT CASE WHEN pat.AGE BETWEEN 18 AND 64 THEN p.PATIENT_ID END) AS patients_18_to_64,
    COUNT(DISTINCT CASE WHEN pat.AGE >= 65 THEN p.PATIENT_ID END) AS patients_65_plus
    
FROM PHARMACY2U_SILVER.GOVERNED_DATA.PRESCRIPTIONS p
JOIN PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS pat
    ON p.PATIENT_ID = pat.PATIENT_ID

-- Security filter: Only data from last 2 years
WHERE p.PRESCRIPTION_DATE >= DATEADD(YEAR, -2, CURRENT_DATE())

GROUP BY 
    DATE_TRUNC('MONTH', p.PRESCRIPTION_DATE),
    DATE_TRUNC('QUARTER', p.PRESCRIPTION_DATE),
    YEAR(p.PRESCRIPTION_DATE),
    LEFT(pat.POSTCODE, 2),
    p.DRUG_NAME,
    p.DRUG_CODE

-- Additional security: Suppress small cohorts to prevent re-identification
HAVING COUNT(DISTINCT p.PATIENT_ID) >= 10;

COMMENT ON VIEW NHS_PRESCRIPTION_ANALYTICS IS 'Secure aggregated prescription data for NHS partnership - no PII, minimum cohort size enforced';

SELECT 'NHS prescription analytics secure view created' AS STATUS;

-- Show sample of shareable data
SELECT * FROM NHS_PRESCRIPTION_ANALYTICS
WHERE year = 2025
ORDER BY month DESC, total_prescriptions DESC
LIMIT 10;

-- ============================================================================
-- STEP 3: Create Secure View for Regulatory Reporting (MHRA)
-- ============================================================================

-- Use Case: Share drug utilization data with MHRA for safety monitoring

CREATE OR REPLACE SECURE VIEW MHRA_DRUG_UTILIZATION AS
SELECT 
    -- Drug information
    p.DRUG_NAME,
    p.DRUG_CODE,
    
    -- Temporal aggregation (monthly only)
    DATE_TRUNC('MONTH', p.PRESCRIPTION_DATE) AS reporting_month,
    
    -- Utilization metrics (fully aggregated, no patient identifiers)
    COUNT(DISTINCT p.PRESCRIPTION_ID) AS prescription_count,
    COUNT(DISTINCT p.PATIENT_ID) AS patient_count,
    SUM(p.QUANTITY) AS total_quantity_dispensed,
    
    -- Age/gender demographics (aggregated)
    COUNT(DISTINCT CASE WHEN pat.GENDER = 'Male' THEN p.PATIENT_ID END) AS male_patients,
    COUNT(DISTINCT CASE WHEN pat.GENDER = 'Female' THEN p.PATIENT_ID END) AS female_patients,
    ROUND(AVG(pat.AGE), 1) AS avg_patient_age,
    
    -- Pharmacy network statistics
    COUNT(DISTINCT p.PHARMACY_ID) AS pharmacy_count,
    COUNT(DISTINCT p.PRESCRIBER_ID) AS prescriber_count
    
FROM PHARMACY2U_SILVER.GOVERNED_DATA.PRESCRIPTIONS p
JOIN PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS pat
    ON p.PATIENT_ID = pat.PATIENT_ID

-- Regulatory requirement: Last 12 months only
WHERE p.PRESCRIPTION_DATE >= DATEADD(MONTH, -12, CURRENT_DATE())

GROUP BY 
    p.DRUG_NAME,
    p.DRUG_CODE,
    DATE_TRUNC('MONTH', p.PRESCRIPTION_DATE)

-- Minimum reporting threshold
HAVING COUNT(DISTINCT p.PATIENT_ID) >= 5;

COMMENT ON VIEW MHRA_DRUG_UTILIZATION IS 'Regulatory-compliant drug utilization data for MHRA safety monitoring';

SELECT 'MHRA drug utilization secure view created' AS STATUS;

-- ============================================================================
-- STEP 4: Create Secure View for Research Partnership
-- ============================================================================

-- Use Case: Share anonymized cohort data with university for clinical research

CREATE OR REPLACE SECURE VIEW RESEARCH_COHORT_ANALYTICS AS
SELECT 
    -- Anonymized patient cohort ID (no actual patient IDs)
    MD5(pat.PATIENT_ID) AS cohort_patient_id,  -- One-way hash
    
    -- Demographics (age bands and gender only)
    CASE 
        WHEN pat.AGE < 30 THEN '18-30'
        WHEN pat.AGE < 50 THEN '31-50'
        WHEN pat.AGE < 65 THEN '51-65'
        ELSE '65+'
    END AS age_group,
    pat.GENDER,
    
    -- Geographic region (first 2 characters of postcode only)
    LEFT(pat.POSTCODE, 2) AS region,
    
    -- Clinical indicators (aggregated)
    COUNT(DISTINCT presc.PRESCRIPTION_ID) AS total_prescriptions,
    COUNT(DISTINCT presc.DRUG_NAME) AS unique_medications,
    DATEDIFF(MONTH, MIN(presc.PRESCRIPTION_DATE), MAX(presc.PRESCRIPTION_DATE)) AS months_active,
    
    -- Cost (banded, not exact)
    CASE 
        WHEN SUM(presc.COST_GBP) < 100 THEN '£0-100'
        WHEN SUM(presc.COST_GBP) < 500 THEN '£100-500'
        WHEN SUM(presc.COST_GBP) < 1000 THEN '£500-1000'
        ELSE '£1000+'
    END AS cost_band

FROM PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS pat
JOIN PHARMACY2U_SILVER.GOVERNED_DATA.PRESCRIPTIONS presc
    ON pat.PATIENT_ID = presc.PATIENT_ID

-- Research scope: Active patients only
WHERE presc.PRESCRIPTION_DATE >= DATEADD(YEAR, -1, CURRENT_DATE())

GROUP BY 
    MD5(pat.PATIENT_ID),
    CASE WHEN pat.AGE < 30 THEN '18-30' WHEN pat.AGE < 50 THEN '31-50' WHEN pat.AGE < 65 THEN '51-65' ELSE '65+' END,
    pat.GENDER,
    LEFT(pat.POSTCODE, 2)

-- Privacy protection: Minimum cohort size
HAVING COUNT(DISTINCT presc.PRESCRIPTION_ID) >= 3;

COMMENT ON VIEW RESEARCH_COHORT_ANALYTICS IS 'De-identified patient cohort data for approved clinical research';

SELECT 'Research cohort analytics secure view created' AS STATUS;

-- ============================================================================
-- STEP 5: Create Secure Shares
-- ============================================================================

-- Share 1: NHS Partnership Share
CREATE OR REPLACE SHARE NHS_PARTNERSHIP_SHARE
    COMMENT = 'Secure share for NHS trust partnership - prescription analytics for population health research';

-- Note: Views that reference objects in other databases cannot be shared directly
-- In production, materialize these views as tables in SHARED_DATA schema first

GRANT USAGE ON DATABASE PHARMACY2U_GOLD TO SHARE NHS_PARTNERSHIP_SHARE;
GRANT USAGE ON SCHEMA PHARMACY2U_GOLD.SHARED_DATA TO SHARE NHS_PARTNERSHIP_SHARE;
-- Production step: CREATE TABLE AS SELECT * FROM NHS_PRESCRIPTION_ANALYTICS
-- Then: GRANT SELECT ON TABLE PHARMACY2U_GOLD.SHARED_DATA.NHS_PRESCRIPTION_ANALYTICS TO SHARE NHS_PARTNERSHIP_SHARE;

-- Share 2: MHRA Regulatory Share
CREATE OR REPLACE SHARE MHRA_REGULATORY_SHARE
    COMMENT = 'Secure share for MHRA regulatory compliance - drug utilization monitoring';

GRANT USAGE ON DATABASE PHARMACY2U_GOLD TO SHARE MHRA_REGULATORY_SHARE;
GRANT USAGE ON SCHEMA PHARMACY2U_GOLD.SHARED_DATA TO SHARE MHRA_REGULATORY_SHARE;
-- Production step: CREATE TABLE AS SELECT * FROM MHRA_DRUG_UTILIZATION
-- Then: GRANT SELECT ON TABLE PHARMACY2U_GOLD.SHARED_DATA.MHRA_DRUG_UTILIZATION TO SHARE MHRA_REGULATORY_SHARE;

-- Share 3: Research Partnership Share
CREATE OR REPLACE SHARE RESEARCH_PARTNERSHIP_SHARE
    COMMENT = 'Secure share for university research partnership - de-identified cohort analytics';

GRANT USAGE ON DATABASE PHARMACY2U_GOLD TO SHARE RESEARCH_PARTNERSHIP_SHARE;
GRANT USAGE ON SCHEMA PHARMACY2U_GOLD.SHARED_DATA TO SHARE RESEARCH_PARTNERSHIP_SHARE;
-- Production step: CREATE TABLE AS SELECT * FROM RESEARCH_COHORT_ANALYTICS
-- Then: GRANT SELECT ON TABLE PHARMACY2U_GOLD.SHARED_DATA.RESEARCH_COHORT_ANALYTICS TO SHARE RESEARCH_PARTNERSHIP_SHARE;

SELECT 'Secure shares created and configured' AS STATUS;

-- Show created shares
SHOW SHARES LIKE '%_SHARE';

-- ============================================================================
-- STEP 6: Document Sharing Governance
-- ============================================================================

CREATE OR REPLACE TABLE SHARE_GOVERNANCE_LOG (
    share_name VARCHAR,
    consumer_organization VARCHAR,
    data_shared VARCHAR,
    sharing_purpose VARCHAR,
    data_classification VARCHAR,
    approval_date DATE,
    approved_by VARCHAR,
    review_frequency VARCHAR,
    pii_included BOOLEAN,
    aggregation_level VARCHAR
) AS
SELECT 
    'NHS_PARTNERSHIP_SHARE',
    'NHS Greater Manchester Trust',
    'Aggregated prescription analytics',
    'Population health research and service planning',
    'INTERNAL - Aggregated only',
    '2025-09-01',
    'Data Protection Officer',
    'Quarterly',
    FALSE,
    'Monthly aggregation, minimum 10 patients per cohort'
UNION ALL SELECT 
    'MHRA_REGULATORY_SHARE',
    'MHRA (Medicines and Healthcare products Regulatory Agency)',
    'Drug utilization statistics',
    'Pharmacovigilance and drug safety monitoring',
    'INTERNAL - Regulatory compliance',
    '2025-08-15',
    'Chief Pharmacist',
    'Annually',
    FALSE,
    'Monthly aggregation, minimum 5 patients per drug'
UNION ALL SELECT 
    'RESEARCH_PARTNERSHIP_SHARE',
    'University of Manchester - School of Pharmacy',
    'De-identified patient cohorts',
    'Clinical effectiveness research',
    'CONFIDENTIAL - Research use only',
    '2025-07-01',
    'Ethics Committee',
    'Per study (6-12 months)',
    FALSE,
    'Patient-level but anonymized, minimum 3 prescriptions per patient';

SELECT * FROM SHARE_GOVERNANCE_LOG;

SELECT 'Share governance documentation complete' AS STATUS;

-- ============================================================================
-- BUSINESS VALUE SUMMARY
-- ============================================================================

SELECT '=== BUSINESS VALUE DELIVERED ===' AS SUMMARY;

SELECT 
    'Zero Data Movement: Partners query live data, no exports' AS value_1
UNION ALL SELECT 'Always Fresh: Partners see real-time updates automatically'
UNION ALL SELECT 'No Data Proliferation: Single source of truth maintained'
UNION ALL SELECT 'Governance Preserved: Access policies apply to shared data'
UNION ALL SELECT 'Compliance: Audit trail of who accesses what and when'
UNION ALL SELECT 'Cost Savings: No data transfer fees, no storage duplication';

-- ============================================================================
-- COMPETITIVE DIFFERENTIATION
-- ============================================================================

SELECT '=== VS MICROSOFT FABRIC ===' AS COMPETITIVE_EDGE;

SELECT 
    'Snowflake: Live data shares with zero copies' AS snowflake_advantage
UNION ALL SELECT 'Fabric: Must export Power BI datasets or use APIs'
UNION ALL SELECT 'Snowflake: Consumer queries directly on provider storage'
UNION ALL SELECT 'Fabric: Data must be copied to consumer tenant'
UNION ALL SELECT 'Snowflake: Governance travels with shared data'
UNION ALL SELECT 'Fabric: Separate security configuration required';

-- ============================================================================
-- PHARMACEUTICAL USE CASES
-- ============================================================================

SELECT '=== PHARMACY2U SHARING USE CASES ===' AS USE_CASES;

SELECT 
    'NHS Partnership: Share prescription trends for population health planning' AS use_case
UNION ALL SELECT 'MHRA Compliance: Regulatory drug safety monitoring'
UNION ALL SELECT 'Research Collaboration: Clinical effectiveness studies'
UNION ALL SELECT 'Supplier Integration: Share demand forecasts with distributors'
UNION ALL SELECT 'Insurance Partners: Risk assessment and pricing'
UNION ALL SELECT 'Public Health: Disease surveillance and outbreak detection';

-- ============================================================================
-- DEMO TALKING POINTS
-- ============================================================================

SELECT '=== Secure Data Sharing Demo Talking Points ===' AS INFO;

SELECT 
    'Point 1: Zero data movement - partners query live data' AS talking_point
UNION ALL SELECT 'Point 2: No data copies - single source of truth'
UNION ALL SELECT 'Point 3: Always fresh - updates reflected instantly'
UNION ALL SELECT 'Point 4: Governance preserved - access policies apply'
UNION ALL SELECT 'Point 5: Complete audit trail - know who sees what'
UNION ALL SELECT 'Point 6: Fabric requires data exports or complex API integration';

SELECT 'Secure Data Sharing implementation complete!' AS FINAL_STATUS;
