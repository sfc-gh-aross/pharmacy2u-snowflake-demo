-- ============================================================================
-- VIGNETTE 2 - Demo Script 3: Zero-Copy Cloning
-- Pharmacy2U Demo - Instant Development Environments
-- Duration: 2-3 minutes
-- Key Message: "Empowering teams with production-scale data without cost or complexity"
-- ============================================================================

-- ============================================================================
-- STEP 1: Show Current Database State
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE PHARMACY2U_DEMO_WH;

-- Talking Point: "Let's look at our current production databases"
SHOW DATABASES LIKE 'PHARMACY2U%';

-- Show the size of our GOLD database
SELECT 
    'PHARMACY2U_GOLD' as database_name,
    COUNT(*) as table_count
FROM PHARMACY2U_GOLD.INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'ANALYTICS';

-- Show row counts in key tables
SELECT 
    'PATIENTS' as table_name,
    COUNT(*) as row_count
FROM PHARMACY2U_GOLD.ANALYTICS.V_PATIENT_360;

-- Talking Point: "This is our production GOLD layer - millions of rows, 
-- complex transformations, sensitive patient data"

-- ============================================================================
-- STEP 2: Create Instant Clone of Entire Database
-- ============================================================================

-- Talking Point: "How long does it take your team to provision a dev environment 
-- with production-scale data? Days? Weeks?"
-- "Watch this - we'll do it in seconds with ZERO additional storage cost"

-- Clone the entire GOLD database
CREATE OR REPLACE DATABASE PHARMACY2U_DEV_ENV 
    CLONE PHARMACY2U_GOLD;

-- Expected: Completes in < 5 seconds regardless of data size!

SELECT 'Clone created instantly!' AS CLONE_STATUS;

-- ============================================================================
-- STEP 3: Verify Clone is Immediately Queryable
-- ============================================================================

-- Talking Point: "The clone is immediately available - not a future job, not pending"

-- Verify the dev environment exists
SHOW DATABASES LIKE 'PHARMACY2U%';

-- Query the cloned database
USE DATABASE PHARMACY2U_DEV_ENV;
USE SCHEMA ANALYTICS;

SELECT 
    COUNT(*) as patient_count_in_clone
FROM V_PATIENT_360;

-- Show that cloned data is identical to production
SELECT 
    'PRODUCTION' as source,
    COUNT(*) as patient_count,
    SUM(LIFETIME_VALUE_GBP) as total_lifetime_value
FROM PHARMACY2U_GOLD.ANALYTICS.V_PATIENT_360

UNION ALL

SELECT 
    'DEV CLONE' as source,
    COUNT(*) as patient_count,
    SUM(LIFETIME_VALUE_GBP) as total_lifetime_value
FROM PHARMACY2U_DEV_ENV.ANALYTICS.V_PATIENT_360;

-- KEY MOMENT #3: "Identical data, instant availability, zero storage cost initially"

-- ============================================================================
-- STEP 4: Demonstrate Data Isolation
-- ============================================================================

-- Talking Point: "Now the magic - changes in the clone don't affect production"
-- "This is true isolation for safe testing and development"

-- Make a change in the dev environment
USE DATABASE PHARMACY2U_DEV_ENV;

-- Update data in the clone (simulate development work)
UPDATE ANALYTICS.V_PATIENT_360
SET LIFETIME_VALUE_GBP = LIFETIME_VALUE_GBP * 1.1  -- Simulate test data changes
WHERE PATIENT_ID LIKE 'P00001%';

-- Show the clone has changed
SELECT 
    'PRODUCTION' as source,
    AVG(LIFETIME_VALUE_GBP) as avg_lifetime_value
FROM PHARMACY2U_GOLD.ANALYTICS.V_PATIENT_360

UNION ALL

SELECT 
    'DEV CLONE (MODIFIED)' as source,
    AVG(LIFETIME_VALUE_GBP) as avg_lifetime_value
FROM PHARMACY2U_DEV_ENV.ANALYTICS.V_PATIENT_360;

-- Talking Point: "Production is completely untouched - perfect isolation"

-- ============================================================================
-- STEP 5: Show Storage Efficiency (Time Permitting)
-- ============================================================================

-- Talking Point: "Here's the real magic - storage"
-- "Initially, the clone shares ALL storage with the original"
-- "You only pay for storage as you CHANGE data in the clone"

-- Query to show storage (requires ACCOUNT_USAGE view)
-- Note: May show zero storage initially for new clones
SELECT 
    DATABASE_NAME,
    BYTES / (1024 * 1024 * 1024) as storage_gb
FROM SNOWFLAKE.ACCOUNT_USAGE.DATABASE_STORAGE_USAGE_HISTORY
WHERE DATABASE_NAME IN ('PHARMACY2U_GOLD', 'PHARMACY2U_DEV_ENV')
    AND USAGE_DATE = CURRENT_DATE()
ORDER BY DATABASE_NAME;

-- ============================================================================
-- STEP 6: Clone at Different Time Travel Points (Advanced)
-- ============================================================================

-- Talking Point: "And you can combine this with Time Travel"
-- "Clone the database as it existed yesterday, last week, or 90 days ago"

-- Example: Clone database from 1 day ago
CREATE OR REPLACE DATABASE PHARMACY2U_YESTERDAY_CLONE 
    CLONE PHARMACY2U_GOLD 
    AT(OFFSET => -86400);  -- 86400 seconds = 1 day

SELECT 'Created clone from historical point-in-time!' AS ADVANCED_CLONE_STATUS;

-- ============================================================================
-- STEP 7: Cleanup
-- ============================================================================

-- Talking Point: "And cleanup is instant too"

DROP DATABASE IF EXISTS PHARMACY2U_DEV_ENV;
DROP DATABASE IF EXISTS PHARMACY2U_YESTERDAY_CLONE;

SELECT 'Cleanup complete - resources released instantly' AS CLEANUP_STATUS;

-- Reset to production
USE DATABASE PHARMACY2U_GOLD;

-- ============================================================================
-- COMPETITIVE DIFFERENTIATION TALKING POINTS
-- ============================================================================

-- 1. "Microsoft Fabric has NO equivalent to Zero-Copy Cloning"
-- 2. "Traditional approach: Full database backup/restore taking hours or days"
-- 3. "Zero-Copy Cloning works on databases, schemas, and individual tables"
-- 4. "This enables: instant dev/test environments, A/B testing, safe experimentation"
-- 5. "Customers report 10x faster development cycles with this single feature"

-- ============================================================================
-- USE CASES TO DISCUSS
-- ============================================================================

-- 1. Development & Testing: Instant prod-scale environments
-- 2. A/B Testing: Clone tables to test different transformation logic
-- 3. Compliance: Provide auditors with point-in-time snapshots
-- 4. Training: Give analysts safe sandbox environments
-- 5. Pre-Production: Test changes before deploying to production

-- ============================================================================
-- AUDIENCE ENGAGEMENT
-- ============================================================================

-- Question: "How many times has your team delayed testing because provisioning 
-- an environment was too time-consuming or expensive?"

-- Follow-up: "What if every developer could have their own production-scale 
-- environment in seconds, whenever they needed it?"
