-- ============================================================================
-- VIGNETTE 2 - Demo Script 1: Governance Setup
-- Pharmacy2U Demo - Dynamic Data Masking & Row Access Policies
-- Duration: 3-4 minutes
-- Key Message: "Security follows the data, not the query"
-- ============================================================================

-- ============================================================================
-- STEP 1: Show Unmasked Data (ACCOUNTADMIN View)
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE PHARMACY2U_DEMO_WH;
USE DATABASE PHARMACY2U_SILVER;
USE SCHEMA GOVERNED_DATA;

-- Talking Point: "As an admin, I have full access to sensitive patient data"
SELECT 
    PATIENT_ID,
    FIRST_NAME,
    LAST_NAME,
    EMAIL,
    PHONE,
    NHS_NUMBER,
    DATE_OF_BIRTH,
    REGISTRATION_DATE
FROM PATIENTS
LIMIT 10;

-- Expected: See real PII data (emails, phone numbers, NHS numbers, names)

-- ============================================================================
-- STEP 2: Apply Masking Policies
-- ============================================================================

-- Talking Point: "Let's apply GDPR-compliant masking policies with a single SQL statement"

-- Email masking policy
CREATE OR REPLACE MASKING POLICY EMAIL_MASK AS (val STRING) RETURNS STRING ->
    CASE
        WHEN CURRENT_ROLE() IN ('ACCOUNTADMIN', 'PHARMACY2U_DATA_ENGINEER') 
            THEN val
        ELSE '***MASKED***@' || SPLIT_PART(val, '@', 2)
    END
COMMENT = 'Mask email addresses for BI users, show domain only';

-- Apply to PATIENTS table
ALTER TABLE PATIENTS
    MODIFY COLUMN EMAIL SET MASKING POLICY EMAIL_MASK;

-- Phone masking policy
CREATE OR REPLACE MASKING POLICY PHONE_MASK AS (val STRING) RETURNS STRING ->
    CASE
        WHEN CURRENT_ROLE() IN ('ACCOUNTADMIN', 'PHARMACY2U_DATA_ENGINEER') 
            THEN val
        ELSE 'XXX-XXX-' || RIGHT(val, 4)
    END
COMMENT = 'Mask phone numbers, show only last 4 digits';

ALTER TABLE PATIENTS
    MODIFY COLUMN PHONE SET MASKING POLICY PHONE_MASK;

-- NHS number masking policy
CREATE OR REPLACE MASKING POLICY NHS_NUMBER_MASK AS (val STRING) RETURNS STRING ->
    CASE
        WHEN CURRENT_ROLE() IN ('ACCOUNTADMIN', 'PHARMACY2U_DATA_ENGINEER') 
            THEN val
        ELSE 'XXX-XXX-' || RIGHT(val, 3)
    END
COMMENT = 'Mask NHS numbers for GDPR compliance';

ALTER TABLE PATIENTS
    MODIFY COLUMN NHS_NUMBER SET MASKING POLICY NHS_NUMBER_MASK;

-- Name masking policy
CREATE OR REPLACE MASKING POLICY NAME_MASK AS (val STRING) RETURNS STRING ->
    CASE
        WHEN CURRENT_ROLE() IN ('ACCOUNTADMIN', 'PHARMACY2U_DATA_ENGINEER') 
            THEN val
        ELSE LEFT(val, 1) || '***'
    END
COMMENT = 'Mask patient names, show only first initial';

ALTER TABLE PATIENTS
    MODIFY COLUMN FIRST_NAME SET MASKING POLICY NAME_MASK;

ALTER TABLE PATIENTS
    MODIFY COLUMN LAST_NAME SET MASKING POLICY NAME_MASK;

-- ============================================================================
-- STEP 3: Verify ACCOUNTADMIN Still Sees Unmasked Data
-- ============================================================================

-- Talking Point: "As an admin, I still see everything - the policies don't affect me"
SELECT 
    PATIENT_ID,
    FIRST_NAME,
    LAST_NAME,
    EMAIL,
    PHONE,
    NHS_NUMBER
FROM PATIENTS
LIMIT 10;

-- Expected: Still see real PII data (policies don't apply to ACCOUNTADMIN)

-- ============================================================================
-- STEP 4: Switch to BI_USER Role and Show Masked Data
-- ============================================================================

-- Talking Point: "Now let's see what a BI analyst would see with the EXACT same query"
USE ROLE PHARMACY2U_BI_USER;

SELECT 
    PATIENT_ID,
    FIRST_NAME,      -- Will show: J***
    LAST_NAME,       -- Will show: S***
    EMAIL,           -- Will show: ***MASKED***@gmail.com
    PHONE,           -- Will show: XXX-XXX-1234
    NHS_NUMBER       -- Will show: XXX-XXX-789
FROM PATIENTS
LIMIT 10;

-- Expected: All PII fields are masked according to policies

-- KEY MOMENT #1: Point out that the query didn't change - only the role changed
-- "This is centralized, automated governance. The security policy is attached 
-- to the DATA, not the query. It's impossible for a BI user to see raw PII,
-- regardless of how they access the data."

-- ============================================================================
-- STEP 5: Show Row Access Policy (Optional - Time Permitting)
-- ============================================================================

USE ROLE ACCOUNTADMIN;

-- Apply row access policy to limit BI users to recent patients only
CREATE OR REPLACE ROW ACCESS POLICY PATIENT_ACCESS_POLICY
    AS (registration_date DATE) RETURNS BOOLEAN ->
    CASE
        WHEN CURRENT_ROLE() IN ('ACCOUNTADMIN', 'PHARMACY2U_DATA_ENGINEER') 
            THEN TRUE
        -- BI users can only see patients from last 2 years
        WHEN registration_date >= DATEADD(YEAR, -2, CURRENT_DATE())
            THEN TRUE
        ELSE FALSE
    END
COMMENT = 'Row-level security: Restrict BI users to recent patients only';

ALTER TABLE PATIENTS
    ADD ROW ACCESS POLICY PATIENT_ACCESS_POLICY ON (REGISTRATION_DATE);

-- Verify row access policy
USE ROLE PHARMACY2U_BI_USER;

-- This will only show patients registered in the last 2 years
SELECT 
    COUNT(*) as visible_patients,
    MIN(REGISTRATION_DATE) as earliest_visible_date
FROM PATIENTS;

-- ============================================================================
-- STEP 6: Reset for Next Demo
-- ============================================================================

USE ROLE ACCOUNTADMIN;

SELECT 'Governance policies configured successfully - Data is now protected!' AS DEMO_STATUS;

-- ============================================================================
-- COMPETITIVE DIFFERENTIATION TALKING POINTS
-- ============================================================================

-- 1. "This is centralized governance vs distributed policy management in Fabric"
-- 2. "Policies travel with the data - even when shared externally"
-- 3. "No separate governance tools needed - it's built into the platform"
-- 4. "GDPR compliance made simple for your lean team"
