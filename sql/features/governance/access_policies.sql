-- ============================================================================
-- Pharmacy2U Demo - Dynamic Data Masking with Access Policies
-- Purpose: GDPR-compliant PII protection for UK pharmaceutical data
-- Key Moment: Vignette 2 - Demonstrates automated governance
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE PHARMACY2U_DEMO_WH;
USE DATABASE PHARMACY2U_GOLD;
USE SCHEMA ANALYTICS;

-- ============================================================================
-- Create Masking Policies
-- ============================================================================

-- Email masking policy
CREATE OR REPLACE MASKING POLICY EMAIL_MASK AS (val STRING) RETURNS STRING ->
    CASE
        WHEN CURRENT_ROLE() IN ('ACCOUNTADMIN', 'PHARMACY2U_DATA_ENGINEER') 
            THEN val
        ELSE '***MASKED***@' || SPLIT_PART(val, '@', 2)
    END
COMMENT = 'Mask email addresses for BI users, show full email to admins';

-- Phone masking policy
CREATE OR REPLACE MASKING POLICY PHONE_MASK AS (val STRING) RETURNS STRING ->
    CASE
        WHEN CURRENT_ROLE() IN ('ACCOUNTADMIN', 'PHARMACY2U_DATA_ENGINEER') 
            THEN val
        ELSE 'XXX-XXX-' || RIGHT(val, 4)
    END
COMMENT = 'Mask phone numbers, show only last 4 digits to BI users';

-- NHS number masking policy
CREATE OR REPLACE MASKING POLICY NHS_NUMBER_MASK AS (val STRING) RETURNS STRING ->
    CASE
        WHEN CURRENT_ROLE() IN ('ACCOUNTADMIN', 'PHARMACY2U_DATA_ENGINEER') 
            THEN val
        ELSE 'XXX-XXX-' || RIGHT(val, 3)
    END
COMMENT = 'Mask NHS numbers for GDPR compliance';

-- Name masking policy
CREATE OR REPLACE MASKING POLICY NAME_MASK AS (val STRING) RETURNS STRING ->
    CASE
        WHEN CURRENT_ROLE() IN ('ACCOUNTADMIN', 'PHARMACY2U_DATA_ENGINEER') 
            THEN val
        ELSE LEFT(val, 1) || '***'
    END
COMMENT = 'Mask patient names, show only first initial';

-- ============================================================================
-- Apply Masking Policies to SILVER Layer
-- ============================================================================

-- Apply to PATIENTS table
ALTER TABLE PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS
    MODIFY COLUMN EMAIL SET MASKING POLICY EMAIL_MASK;

ALTER TABLE PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS
    MODIFY COLUMN PHONE SET MASKING POLICY PHONE_MASK;

ALTER TABLE PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS
    MODIFY COLUMN NHS_NUMBER SET MASKING POLICY NHS_NUMBER_MASK;

ALTER TABLE PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS
    MODIFY COLUMN FIRST_NAME SET MASKING POLICY NAME_MASK;

ALTER TABLE PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS
    MODIFY COLUMN LAST_NAME SET MASKING POLICY NAME_MASK;

-- ============================================================================
-- Row Access Policy for Sensitive Data
-- ============================================================================

-- Create row access policy to restrict access to certain patient records
CREATE OR REPLACE ROW ACCESS POLICY PATIENT_ACCESS_POLICY
    AS (patient_id STRING) RETURNS BOOLEAN ->
    CASE
        WHEN CURRENT_ROLE() IN ('ACCOUNTADMIN', 'PHARMACY2U_DATA_ENGINEER') 
            THEN TRUE
        -- BI users can only see patients from last 2 years
        ELSE EXISTS (
            SELECT 1 
            FROM PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS p
            WHERE p.PATIENT_ID = patient_id
                AND p.REGISTRATION_DATE >= DATEADD(YEAR, -2, CURRENT_DATE())
        )
    END
COMMENT = 'Row-level security: Restrict BI users to recent patients only';

-- Apply row access policy
ALTER TABLE PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS
    ADD ROW ACCESS POLICY PATIENT_ACCESS_POLICY ON (PATIENT_ID);

-- ============================================================================
-- Demo Validation Queries
-- ============================================================================

-- Query as ACCOUNTADMIN (should see real data)
USE ROLE ACCOUNTADMIN;
SELECT 
    PATIENT_ID, 
    FIRST_NAME, 
    LAST_NAME, 
    EMAIL, 
    PHONE, 
    NHS_NUMBER
FROM PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS
LIMIT 5;

-- Switch to BI_USER role (should see masked data)
USE ROLE PHARMACY2U_BI_USER;
SELECT 
    PATIENT_ID, 
    FIRST_NAME, 
    LAST_NAME, 
    EMAIL, 
    PHONE, 
    NHS_NUMBER
FROM PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS
LIMIT 5;

-- Switch back to ACCOUNTADMIN
USE ROLE ACCOUNTADMIN;

SELECT 'Access policies configured successfully - PII data is now protected' AS STATUS;
