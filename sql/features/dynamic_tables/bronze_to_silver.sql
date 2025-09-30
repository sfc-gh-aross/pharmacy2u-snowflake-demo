-- ============================================================================
-- Pharmacy2U Demo - Dynamic Tables for BRONZE to SILVER Transformation
-- Purpose: Automated ELT from raw data to governed layer
-- Key Moment: Vignette 1 - Demonstrates declarative pipelines vs SSIS complexity
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE PHARMACY2U_DEMO_WH;

-- ============================================================================
-- Dynamic Table: BRONZE Prescriptions → SILVER Prescriptions
-- ============================================================================

CREATE OR REPLACE DYNAMIC TABLE PHARMACY2U_SILVER.GOVERNED_DATA.PRESCRIPTIONS
TARGET_LAG = '1 minute'
WAREHOUSE = PHARMACY2U_DEMO_WH
AS
SELECT
    PRESCRIPTION_ID,
    PATIENT_ID,
    DRUG_CODE,
    DRUG_NAME,
    QUANTITY,
    DAYS_SUPPLY,
    PRESCRIPTION_DATE,
    PRESCRIBER_ID,
    PHARMACY_ID,
    COST_GBP,
    CURRENT_TIMESTAMP() AS PROCESSED_TIMESTAMP
FROM PHARMACY2U_BRONZE.RAW_DATA.RAW_PRESCRIPTIONS
WHERE 
    PRESCRIPTION_ID IS NOT NULL
    AND PATIENT_ID IS NOT NULL
    AND PRESCRIPTION_DATE IS NOT NULL
    AND COST_GBP > 0  -- Data quality: exclude invalid costs
    AND QUANTITY > 0;  -- Data quality: exclude invalid quantities

COMMENT ON DYNAMIC TABLE PHARMACY2U_SILVER.GOVERNED_DATA.PRESCRIPTIONS IS 'Automated ELT: Cleaned prescriptions with data quality rules';

-- ============================================================================
-- Dynamic Table: BRONZE Patients → SILVER Patients
-- ============================================================================

CREATE OR REPLACE DYNAMIC TABLE PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS
TARGET_LAG = '1 minute'
WAREHOUSE = PHARMACY2U_DEMO_WH
AS
SELECT
    PATIENT_ID,
    FIRST_NAME,
    LAST_NAME,
    DATE_OF_BIRTH,
    DATEDIFF(YEAR, DATE_OF_BIRTH, CURRENT_DATE()) AS AGE,
    GENDER,
    NHS_NUMBER,
    POSTCODE,
    EMAIL,
    PHONE,
    REGISTRATION_DATE,
    CURRENT_TIMESTAMP() AS PROCESSED_TIMESTAMP
FROM PHARMACY2U_BRONZE.RAW_DATA.RAW_PATIENTS
WHERE 
    PATIENT_ID IS NOT NULL
    AND DATE_OF_BIRTH IS NOT NULL
    AND DATE_OF_BIRTH < CURRENT_DATE()  -- Data quality: valid birth dates
    AND REGISTRATION_DATE IS NOT NULL;

COMMENT ON DYNAMIC TABLE PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS IS 'Automated ELT: Cleaned patients with calculated age';

-- ============================================================================
-- Dynamic Table: BRONZE Marketing Events → SILVER Marketing Events
-- ============================================================================

CREATE OR REPLACE DYNAMIC TABLE PHARMACY2U_SILVER.GOVERNED_DATA.MARKETING_EVENTS
TARGET_LAG = '1 minute'
WAREHOUSE = PHARMACY2U_DEMO_WH
AS
SELECT
    EVENT_DATA:event_id::VARCHAR AS EVENT_ID,
    EVENT_DATA:patient_id::VARCHAR AS PATIENT_ID,
    EVENT_DATA:campaign_id::VARCHAR AS CAMPAIGN_ID,
    EVENT_DATA:campaign_name::VARCHAR AS CAMPAIGN_NAME,
    EVENT_DATA:event_type::VARCHAR AS EVENT_TYPE,
    EVENT_DATA:event_timestamp::TIMESTAMP_NTZ AS EVENT_TIMESTAMP,
    EVENT_DATA:channel::VARCHAR AS CHANNEL,
    EVENT_DATA:conversion_flag::BOOLEAN AS CONVERSION_FLAG,
    CURRENT_TIMESTAMP() AS PROCESSED_TIMESTAMP
FROM PHARMACY2U_BRONZE.RAW_DATA.RAW_MARKETING_EVENTS
WHERE 
    EVENT_DATA:event_id IS NOT NULL
    AND EVENT_DATA:patient_id IS NOT NULL;

COMMENT ON DYNAMIC TABLE PHARMACY2U_SILVER.GOVERNED_DATA.MARKETING_EVENTS IS 'Automated ELT: Flattened marketing events from JSON';

-- ============================================================================
-- Validation Queries
-- ============================================================================

-- Verify Dynamic Tables are created and refreshing
SELECT 
    table_name,
    target_lag,
    scheduling_state,
    last_suspended_on
FROM PHARMACY2U_SILVER.INFORMATION_SCHEMA.DYNAMIC_TABLES
WHERE table_schema = 'GOVERNED_DATA'
ORDER BY table_name;

-- Show row counts
SELECT 'BRONZE Prescriptions' AS LAYER, COUNT(*) AS ROW_COUNT 
FROM PHARMACY2U_BRONZE.RAW_DATA.RAW_PRESCRIPTIONS
UNION ALL
SELECT 'SILVER Prescriptions', COUNT(*) 
FROM PHARMACY2U_SILVER.GOVERNED_DATA.PRESCRIPTIONS
UNION ALL
SELECT 'BRONZE Patients', COUNT(*) 
FROM PHARMACY2U_BRONZE.RAW_DATA.RAW_PATIENTS
UNION ALL
SELECT 'SILVER Patients', COUNT(*) 
FROM PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS
UNION ALL
SELECT 'BRONZE Marketing Events', COUNT(*) 
FROM PHARMACY2U_BRONZE.RAW_DATA.RAW_MARKETING_EVENTS
UNION ALL
SELECT 'SILVER Marketing Events', COUNT(*) 
FROM PHARMACY2U_SILVER.GOVERNED_DATA.MARKETING_EVENTS;

SELECT 'Dynamic Tables created successfully - Automated ELT pipeline active' AS STATUS;
