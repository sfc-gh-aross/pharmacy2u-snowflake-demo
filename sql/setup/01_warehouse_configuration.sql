-- ============================================================================
-- Pharmacy2U Demo - Warehouse Configuration
-- Purpose: Create cost-optimized virtual warehouses for demo workloads
-- Cost Strategy: XSMALL warehouses, 60s auto-suspend, single cluster scaling
-- ============================================================================

USE ROLE ACCOUNTADMIN;

-- Create main demo warehouse (XSMALL for cost efficiency)
CREATE WAREHOUSE IF NOT EXISTS PHARMACY2U_DEMO_WH
    WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    MIN_CLUSTER_COUNT = 1
    MAX_CLUSTER_COUNT = 1
    SCALING_POLICY = 'STANDARD'
    COMMENT = 'Main demo warehouse - XSMALL for cost-efficient demonstrations';

-- Create data loading warehouse (XSMALL, dedicated to avoid contention)
CREATE WAREHOUSE IF NOT EXISTS PHARMACY2U_LOADING_WH
    WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    MIN_CLUSTER_COUNT = 1
    MAX_CLUSTER_COUNT = 1
    SCALING_POLICY = 'STANDARD'
    COMMENT = 'Data loading warehouse - Isolated for bulk ingestion operations';

-- Create ML/AI warehouse for Snowpark workloads (XSMALL initially, can scale during demo)
CREATE WAREHOUSE IF NOT EXISTS PHARMACY2U_ML_WH
    WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    MIN_CLUSTER_COUNT = 1
    MAX_CLUSTER_COUNT = 1
    SCALING_POLICY = 'STANDARD'
    COMMENT = 'ML/AI warehouse - For Snowpark and ML model training';

-- Create analytics warehouse for BI queries (XSMALL for cost efficiency)
CREATE WAREHOUSE IF NOT EXISTS PHARMACY2U_ANALYTICS_WH
    WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    MIN_CLUSTER_COUNT = 1
    MAX_CLUSTER_COUNT = 1
    SCALING_POLICY = 'STANDARD'
    COMMENT = 'Analytics warehouse - For Streamlit apps and Power BI queries';

-- Grant usage permissions
GRANT USAGE ON WAREHOUSE PHARMACY2U_DEMO_WH TO ROLE PUBLIC;
GRANT USAGE ON WAREHOUSE PHARMACY2U_LOADING_WH TO ROLE PUBLIC;
GRANT USAGE ON WAREHOUSE PHARMACY2U_ML_WH TO ROLE PUBLIC;
GRANT USAGE ON WAREHOUSE PHARMACY2U_ANALYTICS_WH TO ROLE PUBLIC;

-- Set default warehouse for demo
USE WAREHOUSE PHARMACY2U_DEMO_WH;

SELECT 
    'Warehouse configuration completed' AS STATUS,
    'All warehouses: XSMALL size, 60s auto-suspend, single cluster' AS COST_OPTIMIZATION;

-- Show warehouse configuration for validation
SHOW WAREHOUSES LIKE 'PHARMACY2U%';
