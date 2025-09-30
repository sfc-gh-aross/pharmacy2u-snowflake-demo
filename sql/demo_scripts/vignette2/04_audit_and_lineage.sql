-- ============================================================================
-- VIGNETTE 2 - Demo Script 4: Access History & Audit Trail
-- Pharmacy2U Demo - GDPR Compliance & Data Lineage
-- Duration: 2 minutes (optional/time-permitting)
-- Key Message: "Built-in compliance and observability - no additional tools required"
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE PHARMACY2U_DEMO_WH;

-- ============================================================================
-- STEP 1: Who Accessed Patient PII Data Recently?
-- ============================================================================

-- Talking Point: "For GDPR compliance, we need to track all access to patient data"
-- "Let's see who accessed our PATIENTS table in the last 7 days"

SELECT 
    USER_NAME,
    ROLE_NAME,
    START_TIME as access_time,
    QUERY_TYPE,
    ROWS_PRODUCED as rows_accessed,
    EXECUTION_STATUS
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE 1=1
    AND QUERY_TEXT ILIKE '%PATIENTS%'
    AND START_TIME >= DATEADD(DAY, -7, CURRENT_TIMESTAMP())
    AND EXECUTION_STATUS = 'SUCCESS'
ORDER BY START_TIME DESC
LIMIT 20;

-- Talking Point: "Complete audit trail - we know exactly who accessed what, when"

-- ============================================================================
-- STEP 2: Track Modifications to Sensitive Data
-- ============================================================================

-- Talking Point: "Even more important - who MODIFIED patient data?"

SELECT 
    USER_NAME,
    ROLE_NAME,
    START_TIME as modification_time,
    QUERY_TYPE,
    ROWS_UPDATED,
    ROWS_DELETED,
    LEFT(QUERY_TEXT, 200) as action_taken
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE 1=1
    AND QUERY_TYPE IN ('UPDATE', 'DELETE', 'MERGE')
    AND QUERY_TEXT ILIKE ANY ('%PATIENTS%', '%PRESCRIPTIONS%')
    AND START_TIME >= DATEADD(DAY, -30, CURRENT_TIMESTAMP())
ORDER BY START_TIME DESC
LIMIT 10;

-- ============================================================================
-- STEP 3: Access Patterns by Role
-- ============================================================================

-- Talking Point: "Let's analyze access patterns - are our roles being used correctly?"

SELECT 
    ROLE_NAME,
    DATABASE_NAME,
    COUNT(DISTINCT QUERY_ID) as query_count,
    COUNT(DISTINCT USER_NAME) as unique_users,
    SUM(ROWS_PRODUCED) as total_rows_accessed
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE 1=1
    AND START_TIME >= DATEADD(DAY, -7, CURRENT_TIMESTAMP())
    AND DATABASE_NAME LIKE 'PHARMACY2U%'
    AND EXECUTION_STATUS = 'SUCCESS'
GROUP BY ROLE_NAME, DATABASE_NAME
ORDER BY query_count DESC;

-- Talking Point: "We can see our BI_USER role is accessing the GOLD layer appropriately"
-- "And DATA_ENGINEER role is working across all layers - exactly as designed"

-- ============================================================================
-- STEP 4: Failed Access Attempts (Security Monitoring)
-- ============================================================================

-- Talking Point: "For security, we also track FAILED access attempts"

SELECT 
    USER_NAME,
    ROLE_NAME,
    START_TIME as failed_attempt_time,
    ERROR_MESSAGE,
    DATABASE_NAME,
    SCHEMA_NAME,
    LEFT(QUERY_TEXT, 150) as attempted_action
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE 1=1
    AND EXECUTION_STATUS = 'FAIL'
    AND ERROR_MESSAGE ILIKE ANY ('%denied%', '%not authorized%', '%permission%')
    AND START_TIME >= DATEADD(DAY, -7, CURRENT_TIMESTAMP())
ORDER BY START_TIME DESC
LIMIT 10;

-- Talking Point: "This helps us identify security issues or misconfigured permissions"

-- ============================================================================
-- STEP 5: Data Lineage - Complete Data Flow Visibility
-- ============================================================================

-- Talking Point: "For compliance and troubleshooting, we can trace data lineage"
-- "Let's see the complete flow from our source tables to analytics views"

-- Show objects accessed in queries involving PATIENT_360
SELECT 
    qh.QUERY_ID,
    qh.START_TIME,
    qh.USER_NAME,
    qh.DATABASE_NAME || '.' || qh.SCHEMA_NAME as context,
    ah.OBJECTS_MODIFIED[0]:objectName::STRING as object_modified,
    ah.BASE_OBJECTS_ACCESSED[0]:objectName::STRING as source_object,
    LEFT(qh.QUERY_TEXT, 150) as query_preview
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY qh
JOIN SNOWFLAKE.ACCOUNT_USAGE.ACCESS_HISTORY ah 
    ON qh.QUERY_ID = ah.QUERY_ID
WHERE 1=1
    AND qh.START_TIME >= DATEADD(DAY, -7, CURRENT_TIMESTAMP())
    AND (
        ah.OBJECTS_MODIFIED[0]:objectName::STRING ILIKE '%PATIENT_360%'
        OR ah.BASE_OBJECTS_ACCESSED[0]:objectName::STRING ILIKE '%PATIENT_360%'
    )
ORDER BY qh.START_TIME DESC
LIMIT 20;

-- Talking Point: "We can trace every transformation from BRONZE to SILVER to GOLD"
-- "This is critical for both compliance audits and debugging data issues"

-- ============================================================================
-- STEP 6: Compliance Report Summary
-- ============================================================================

-- Talking Point: "Let's generate a compliance summary for the last 30 days"

SELECT 
    DATE_TRUNC('day', START_TIME) as access_date,
    DATABASE_NAME,
    COUNT(DISTINCT USER_NAME) as unique_users,
    COUNT(DISTINCT QUERY_ID) as total_queries,
    SUM(CASE WHEN QUERY_TYPE = 'SELECT' THEN 1 ELSE 0 END) as read_operations,
    SUM(CASE WHEN QUERY_TYPE IN ('UPDATE', 'DELETE', 'MERGE', 'INSERT') THEN 1 ELSE 0 END) as write_operations
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE 1=1
    AND START_TIME >= DATEADD(DAY, -30, CURRENT_TIMESTAMP())
    AND DATABASE_NAME LIKE 'PHARMACY2U%'
    AND EXECUTION_STATUS = 'SUCCESS'
GROUP BY access_date, DATABASE_NAME
ORDER BY access_date DESC
LIMIT 30;

SELECT 'Complete audit trail available - GDPR compliance simplified' AS COMPLIANCE_STATUS;

-- ============================================================================
-- COMPETITIVE DIFFERENTIATION TALKING POINTS
-- ============================================================================

-- 1. "Built-in audit trail - no need for separate logging tools"
-- 2. "90-day query history retention (365 days with higher editions)"
-- 3. "Data lineage automatically tracked - no configuration needed"
-- 4. "This information is immediately available - no ETL into a separate system"
-- 5. "Perfect for GDPR Article 30 compliance: Record of Processing Activities"

-- ============================================================================
-- AUDIENCE ENGAGEMENT
-- ============================================================================

-- Question: "How do you currently track data access for GDPR compliance?"
-- "How long would it take you to answer: 'Show me everyone who accessed 
-- patient data last month?'"

-- Follow-up: "With Snowflake, this is instant and automatic - zero configuration needed"
