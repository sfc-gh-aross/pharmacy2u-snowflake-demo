-- ============================================================================
-- VIGNETTE 2 - Demo Script 2: Time Travel
-- Pharmacy2U Demo - Operational Resiliency & P1 Incident Recovery
-- Duration: 2-3 minutes
-- Key Message: "De-risking your entire operation - 5 hours becomes 5 seconds"
-- ============================================================================

-- ============================================================================
-- STEP 1: Create Demo Table (Clone for Testing)
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE PHARMACY2U_DEMO_WH;
USE DATABASE PHARMACY2U_SILVER;
USE SCHEMA GOVERNED_DATA;

-- Note: PATIENTS is a Dynamic Table, so we'll clone it for the demo
CREATE OR REPLACE TABLE PATIENTS_DEMO CLONE PATIENTS;

-- Talking Point: "Let's look at our patient email addresses - everything looks good"
SELECT 
    PATIENT_ID,
    FIRST_NAME,
    LAST_NAME,
    EMAIL,
    REGISTRATION_DATE
FROM PATIENTS_DEMO
LIMIT 10;

-- Show count of patients with valid emails
SELECT 
    COUNT(*) as total_patients,
    COUNT(EMAIL) as patients_with_emails,
    COUNT(CASE WHEN EMAIL LIKE '%@%' THEN 1 END) as valid_email_format
FROM PATIENTS_DEMO;

-- Expected: All patients have valid email addresses

-- ============================================================================
-- STEP 2: Execute "Friday Afternoon Mistake"
-- ============================================================================

-- Talking Point: "It's Friday afternoon. A developer accidentally runs a bad UPDATE..."
-- "We've all done this - updating the wrong records or forgetting a WHERE clause"

-- Wait 5 seconds to ensure time travel history exists
CALL SYSTEM$WAIT(5);

-- Simulate a common mistake: accidentally nullifying email addresses
UPDATE PATIENTS_DEMO
SET EMAIL = NULL
WHERE PATIENT_ID LIKE 'P%0'  -- Accidentally updates many patients
;

-- Show the damage
SELECT 
    COUNT(*) as total_patients,
    COUNT(EMAIL) as patients_with_emails,
    COUNT(CASE WHEN EMAIL IS NULL THEN 1 END) as patients_missing_emails
FROM PATIENTS_DEMO;

-- Talking Point: "We just lost hundreds of patient email addresses!"
-- "In your current environment, this would be a P1 incident requiring backup restoration"
-- "How long would that take? 5 hours? Longer?"

-- ============================================================================
-- STEP 3: Use Time Travel to View Data Before the Mistake
-- ============================================================================

-- Talking Point: "With Snowflake Time Travel, we can instantly see the data 
-- as it existed a few seconds ago - before the mistake"

-- Query data as it was 10 seconds ago (before the UPDATE)
SELECT 
    PATIENT_ID,
    FIRST_NAME,
    LAST_NAME,
    EMAIL,
    REGISTRATION_DATE
FROM PATIENTS_DEMO AT(OFFSET => -10)  -- 10 seconds ago
LIMIT 10;

-- Compare: Show specific patient before and after
SELECT 
    'CURRENT (BROKEN)' as data_state,
    PATIENT_ID,
    EMAIL
FROM PATIENTS_DEMO
WHERE PATIENT_ID = 'PT-00000010'

UNION ALL

SELECT 
    'TIME TRAVEL (CLEAN)' as data_state,
    PATIENT_ID,
    EMAIL
FROM PATIENTS_DEMO AT(OFFSET => -10)
WHERE PATIENT_ID = 'PT-00000010';

-- KEY MOMENT #2: "Notice - the data is intact. No backup restoration needed."

-- ============================================================================
-- STEP 4: Restore Data Using Time Travel
-- ============================================================================

-- Talking Point: "Let's restore the entire table in seconds - not hours"

-- Method 1: CREATE OR REPLACE using Time Travel
CREATE OR REPLACE TABLE PATIENTS_DEMO AS
SELECT * FROM PATIENTS_DEMO AT(OFFSET => -10);

-- Alternative Method 2: UNDROP (if table was dropped)
-- UNDROP TABLE PATIENTS_DEMO;

-- ============================================================================
-- STEP 5: Validate Restoration Success
-- ============================================================================

-- Verify emails are restored
SELECT 
    COUNT(*) as total_patients,
    COUNT(EMAIL) as patients_with_emails,
    COUNT(CASE WHEN EMAIL LIKE '%@%' THEN 1 END) as valid_email_format
FROM PATIENTS_DEMO;

-- Show restored data
SELECT 
    PATIENT_ID,
    FIRST_NAME,
    LAST_NAME,
    EMAIL
FROM PATIENTS_DEMO
LIMIT 10;

SELECT 'Data restored successfully in seconds - P1 incident averted!' AS RECOVERY_STATUS;

-- ============================================================================
-- EXTENSION: Show Time Travel for Queries (Time Permitting)
-- ============================================================================

-- You can also query data at specific timestamps
SELECT COUNT(*) as patient_count_at_timestamp
FROM PATIENTS_DEMO AT(TIMESTAMP => DATEADD(MINUTE, -5, CURRENT_TIMESTAMP()));

-- Show available Time Travel history
SELECT 'Time Travel retention: Up to 90 days (Enterprise Edition)' AS TIME_TRAVEL_RETENTION;

-- Cleanup demo table
DROP TABLE IF EXISTS PATIENTS_DEMO;

-- ============================================================================
-- COMPETITIVE DIFFERENTIATION TALKING POINTS
-- ============================================================================

-- 1. "Microsoft Fabric has NO equivalent to Time Travel - backups are your only option"
-- 2. "This isn't a restore from backup - it's instant access to historical data"
-- 3. "Time Travel works on tables, schemas, and entire databases"
-- 4. "Retention: 1 day standard, up to 90 days with Enterprise"
-- 5. "This single feature has prevented countless P1 incidents for our customers"

-- ============================================================================
-- AUDIENCE ENGAGEMENT
-- ============================================================================

-- Question: "How much time does your team spend each month dealing with 
-- data recovery incidents? Time Travel eliminates that entirely."

-- Follow-up: "And this works for compliance too - instant point-in-time 
-- reporting for audits without maintaining historical snapshots"
