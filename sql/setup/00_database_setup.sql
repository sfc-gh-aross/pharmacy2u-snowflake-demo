-- ============================================================================
-- Pharmacy2U Demo - Database Setup
-- Purpose: Create medallion architecture databases (BRONZE, SILVER, GOLD)
-- ============================================================================

USE ROLE ACCOUNTADMIN;

-- Create BRONZE database for raw data ingestion
CREATE DATABASE IF NOT EXISTS PHARMACY2U_BRONZE
    COMMENT = 'Raw data layer - Ingested as-is from SQL Server, PostgreSQL, and ADLS Gen2';

-- Create SILVER database for cleaned and governed data
CREATE DATABASE IF NOT EXISTS PHARMACY2U_SILVER
    COMMENT = 'Governed data layer - Cleaned, validated, and enriched';

-- Create GOLD database for analytics-ready data
CREATE DATABASE IF NOT EXISTS PHARMACY2U_GOLD
    COMMENT = 'Analytics-ready layer - Patient 360 views and ML-optimized datasets';

-- Create main demo database (alias for GOLD)
CREATE DATABASE IF NOT EXISTS PHARMACY2U_DEMO_DB
    COMMENT = 'Main demo database - Entry point for analytics and AI/ML';

-- Set default database
USE DATABASE PHARMACY2U_DEMO_DB;

-- Create schemas in each database
CREATE SCHEMA IF NOT EXISTS PHARMACY2U_BRONZE.RAW_DATA
    COMMENT = 'Schema for raw ingested data from multiple sources';

CREATE SCHEMA IF NOT EXISTS PHARMACY2U_SILVER.GOVERNED_DATA
    COMMENT = 'Schema for cleaned and governed data with quality rules';

CREATE SCHEMA IF NOT EXISTS PHARMACY2U_GOLD.ANALYTICS
    COMMENT = 'Schema for analytics-ready views and ML datasets';

CREATE SCHEMA IF NOT EXISTS PHARMACY2U_DEMO_DB.DEMO_SCHEMA
    COMMENT = 'Main demo schema for interactive demonstrations';

-- Create file formats for different data types
CREATE OR REPLACE FILE FORMAT PHARMACY2U_BRONZE.RAW_DATA.CSV_FORMAT
    TYPE = 'CSV'
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    NULL_IF = ('NULL', 'null', '')
    EMPTY_FIELD_AS_NULL = TRUE
    COMPRESSION = AUTO
    COMMENT = 'CSV file format for structured data ingestion';

CREATE OR REPLACE FILE FORMAT PHARMACY2U_BRONZE.RAW_DATA.JSON_FORMAT
    TYPE = 'JSON'
    COMPRESSION = AUTO
    STRIP_OUTER_ARRAY = TRUE
    COMMENT = 'JSON file format for marketing events and semi-structured data';

-- Create stages for data loading
CREATE OR REPLACE STAGE PHARMACY2U_BRONZE.RAW_DATA.PRESCRIPTION_STAGE
    FILE_FORMAT = PHARMACY2U_BRONZE.RAW_DATA.CSV_FORMAT
    COMMENT = 'Stage for prescription data from SQL Server';

CREATE OR REPLACE STAGE PHARMACY2U_BRONZE.RAW_DATA.PATIENT_STAGE
    FILE_FORMAT = PHARMACY2U_BRONZE.RAW_DATA.CSV_FORMAT
    COMMENT = 'Stage for patient data from PostgreSQL';

CREATE OR REPLACE STAGE PHARMACY2U_BRONZE.RAW_DATA.MARKETING_STAGE
    FILE_FORMAT = PHARMACY2U_BRONZE.RAW_DATA.JSON_FORMAT
    COMMENT = 'Stage for marketing events JSON from ADLS Gen2';

CREATE OR REPLACE STAGE PHARMACY2U_DEMO_DB.DEMO_SCHEMA.PHARMACY2U_STREAMLIT_STAGE
    COMMENT = 'Stage for Streamlit application files';

-- Grant permissions
GRANT USAGE ON DATABASE PHARMACY2U_BRONZE TO ROLE PUBLIC;
GRANT USAGE ON DATABASE PHARMACY2U_SILVER TO ROLE PUBLIC;
GRANT USAGE ON DATABASE PHARMACY2U_GOLD TO ROLE PUBLIC;
GRANT USAGE ON DATABASE PHARMACY2U_DEMO_DB TO ROLE PUBLIC;

GRANT USAGE ON ALL SCHEMAS IN DATABASE PHARMACY2U_BRONZE TO ROLE PUBLIC;
GRANT USAGE ON ALL SCHEMAS IN DATABASE PHARMACY2U_SILVER TO ROLE PUBLIC;
GRANT USAGE ON ALL SCHEMAS IN DATABASE PHARMACY2U_GOLD TO ROLE PUBLIC;
GRANT USAGE ON ALL SCHEMAS IN DATABASE PHARMACY2U_DEMO_DB TO ROLE PUBLIC;

SELECT 'Database setup completed successfully' AS STATUS;
