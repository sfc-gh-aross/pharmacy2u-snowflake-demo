-- ============================================================================
-- Fix: Snowflake Intelligence Agents Schema Setup
-- Purpose: Create required schema and grant permissions for Intelligence UI
-- ============================================================================

USE ROLE ACCOUNTADMIN;

-- ============================================================================
-- STEP 1: Create SNOWFLAKE_INTELLIGENCE database (if not exists)
-- ============================================================================

CREATE DATABASE IF NOT EXISTS SNOWFLAKE_INTELLIGENCE
    COMMENT = 'Database for Snowflake Intelligence agents and configurations';

-- ============================================================================
-- STEP 2: Create AGENTS schema
-- ============================================================================

USE DATABASE SNOWFLAKE_INTELLIGENCE;

CREATE SCHEMA IF NOT EXISTS AGENTS
    COMMENT = 'Schema for Snowflake Intelligence agents';

-- ============================================================================
-- STEP 3: Grant necessary permissions
-- ============================================================================

-- Grant usage on database
GRANT USAGE ON DATABASE SNOWFLAKE_INTELLIGENCE TO ROLE ACCOUNTADMIN;

-- Grant all privileges on schema to create agents
GRANT ALL PRIVILEGES ON SCHEMA SNOWFLAKE_INTELLIGENCE.AGENTS TO ROLE ACCOUNTADMIN;

-- Grant future privileges on tables (agents will create tables)
GRANT ALL PRIVILEGES ON FUTURE TABLES IN SCHEMA SNOWFLAKE_INTELLIGENCE.AGENTS TO ROLE ACCOUNTADMIN;

-- Grant future privileges on views
GRANT ALL PRIVILEGES ON FUTURE VIEWS IN SCHEMA SNOWFLAKE_INTELLIGENCE.AGENTS TO ROLE ACCOUNTADMIN;

-- ============================================================================
-- STEP 4: Verify setup
-- ============================================================================

-- Show the database
SHOW DATABASES LIKE 'SNOWFLAKE_INTELLIGENCE';

-- Show the schema
SHOW SCHEMAS IN DATABASE SNOWFLAKE_INTELLIGENCE;

-- Verify grants
SHOW GRANTS ON SCHEMA SNOWFLAKE_INTELLIGENCE.AGENTS;

SELECT 'Intelligence schema setup complete! You can now create agents in the UI.' AS status;

-- ============================================================================
-- OPTIONAL: Grant to other roles who need to create agents
-- ============================================================================

-- If you want other roles to create agents, run these:
-- GRANT USAGE ON DATABASE SNOWFLAKE_INTELLIGENCE TO ROLE PHARMACY2U_DATA_ANALYST;
-- GRANT ALL PRIVILEGES ON SCHEMA SNOWFLAKE_INTELLIGENCE.AGENTS TO ROLE PHARMACY2U_DATA_ANALYST;

-- ============================================================================
-- AGENT SETUP NOTES
-- ============================================================================

SELECT 
    'After running this script, return to Snowflake Intelligence UI' AS step_1,
    'Click "Create agent" button again' AS step_2,
    'The schema error should now be resolved' AS step_3;
