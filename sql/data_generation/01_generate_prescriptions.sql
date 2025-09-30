-- ============================================================================
-- Pharmacy2U Demo - Prescription Data Generation (SQL-based)
-- Purpose: Generate 500K realistic UK prescription records
-- Target: 500K+ records in <2 minutes (SQL Tier 2 approach)
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE PHARMACY2U_BRONZE;
USE SCHEMA RAW_DATA;
USE WAREHOUSE PHARMACY2U_LOADING_WH;

-- Resume warehouse
ALTER WAREHOUSE PHARMACY2U_LOADING_WH RESUME IF SUSPENDED;

-- Clear existing data
TRUNCATE TABLE IF EXISTS RAW_PRESCRIPTIONS;

-- Generate 500K prescription records
INSERT INTO RAW_PRESCRIPTIONS (
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
    INGESTION_TIMESTAMP,
    SOURCE_SYSTEM
)
SELECT
    'RX-' || LPAD(SEQ4(), 10, '0') AS PRESCRIPTION_ID,
    'PT-' || LPAD(UNIFORM(1, 100000, RANDOM()), 8, '0') AS PATIENT_ID,
    drugs.drug_code,
    drugs.drug_name,
    drugs.typical_qty + UNIFORM(-5, 10, RANDOM()) AS QUANTITY,
    CASE 
        WHEN UNIFORM(1, 100, RANDOM()) <= 60 THEN 28
        WHEN UNIFORM(1, 100, RANDOM()) <= 85 THEN 56
        ELSE 84
    END AS DAYS_SUPPLY,
    DATEADD(
        DAY, 
        -UNIFORM(0, 730, RANDOM()),
        CURRENT_DATE()
    ) AS PRESCRIPTION_DATE,
    'DR-' || LPAD(UNIFORM(1, 500, RANDOM()), 5, '0') AS PRESCRIBER_ID,
    'PH-' || LPAD(UNIFORM(1, 50, RANDOM()), 3, '0') AS PHARMACY_ID,
    ROUND(
        drugs.avg_cost * (1 + (UNIFORM(-20, 30, RANDOM()) / 100.0)), 
        2
    ) AS COST_GBP,
    CURRENT_TIMESTAMP() AS INGESTION_TIMESTAMP,
    'SQL_SERVER' AS SOURCE_SYSTEM
FROM 
    TABLE(GENERATOR(ROWCOUNT => 500000)) gen
CROSS JOIN (
    SELECT * FROM (
        SELECT '0212000B0' AS drug_code, 'Atorvastatin' AS drug_name, 28 AS typical_qty, 14.50 AS avg_cost
        UNION ALL SELECT '0601023Z0', 'Metformin', 56, 8.20
        UNION ALL SELECT '0205051R0', 'Ramipril', 28, 6.30
        UNION ALL SELECT '0604011L0', 'Levothyroxine', 28, 4.80
        UNION ALL SELECT '0501130R0', 'Omeprazole', 28, 5.90
        UNION ALL SELECT '0407010H0', 'Salbutamol Inhaler', 1, 12.50
        UNION ALL SELECT '0407020A0', 'Fluticasone Inhaler', 1, 18.90
        UNION ALL SELECT '0101010T0', 'Gaviscon', 12, 9.40
        UNION ALL SELECT '0403010A0', 'Aspirin', 28, 3.20
        UNION ALL SELECT '0304010G0', 'Chlorphenamine', 28, 2.80
        UNION ALL SELECT '0106070A0', 'Bisacodyl', 20, 3.50
        UNION ALL SELECT '0402010N0', 'Amlodipine', 28, 5.60
        UNION ALL SELECT '0410010N0', 'Citalopram', 28, 7.80
        UNION ALL SELECT '0602010Y0', 'Insulin Glargine', 5, 32.50
        UNION ALL SELECT '0301011R0', 'Amoxicillin', 21, 6.90
    )
    QUALIFY ROW_NUMBER() OVER (ORDER BY RANDOM()) = UNIFORM(1, 15, RANDOM())
) drugs;

-- Validate data generation
SELECT 
    'RAW_PRESCRIPTIONS' AS TABLE_NAME,
    COUNT(*) AS RECORD_COUNT,
    MIN(PRESCRIPTION_DATE) AS EARLIEST_DATE,
    MAX(PRESCRIPTION_DATE) AS LATEST_DATE,
    AVG(COST_GBP) AS AVG_COST,
    COUNT(DISTINCT PATIENT_ID) AS UNIQUE_PATIENTS,
    COUNT(DISTINCT DRUG_CODE) AS UNIQUE_DRUGS
FROM RAW_PRESCRIPTIONS;

-- Show sample data
SELECT * FROM RAW_PRESCRIPTIONS LIMIT 10;

SELECT '✅ Prescription data generation completed successfully' AS STATUS;
