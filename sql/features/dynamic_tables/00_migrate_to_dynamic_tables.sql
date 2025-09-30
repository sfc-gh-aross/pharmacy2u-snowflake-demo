-- ============================================================================
-- Pharmacy2U Demo - Migrate Regular Tables to Dynamic Tables
-- Purpose: Drop existing static tables and replace with Dynamic Tables
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE PHARMACY2U_DEMO_WH;
USE DATABASE PHARMACY2U_SILVER;
USE SCHEMA GOVERNED_DATA;

-- Drop existing static tables
DROP TABLE IF EXISTS PRESCRIPTIONS;
DROP TABLE IF EXISTS PATIENTS;
DROP TABLE IF EXISTS MARKETING_EVENTS;

SELECT '✅ Static tables dropped - ready for Dynamic Tables' AS STATUS;
