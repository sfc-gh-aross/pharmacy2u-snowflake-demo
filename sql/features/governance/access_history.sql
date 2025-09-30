-- ============================================================================
-- Pharmacy2U Demo - Access History & Data Lineage
-- Purpose: Comprehensive audit trails and data lineage for GDPR compliance
-- Key Features: Query tracking, access patterns, data lineage
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE PHARMACY2U_DEMO_WH;

-- ============================================================================
-- Access History Queries - GDPR Compliance & Audit Trails
-- ============================================================================

-- Query 1: Who accessed PATIENTS table in the last 7 days?
-- Use Case: GDPR audit - track all access to sensitive patient data
SELECT 
    USER_NAME,
    ROLE_NAME,
    QUERY_TYPE,
    QUERY_TEXT,
    START_TIME,
    EXECUTION_STATUS,
    ROWS_PRODUCED
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE 1=1
    AND QUERY_TEXT ILIKE '%PATIENTS%'
    AND START_TIME >= DATEADD(DAY, -7, CURRENT_TIMESTAMP())
    AND EXECUTION_STATUS = 'SUCCESS'
ORDER BY START_TIME DESC
LIMIT 50;

-- Query 2: What queries modified patient PII data?
-- Use Case: Track all UPDATE/DELETE operations on sensitive data
SELECT 
    USER_NAME,
    ROLE_NAME,
    QUERY_TYPE,
    START_TIME,
    TOTAL_ELAPSED_TIME/1000 as execution_seconds,
    ROWS_UPDATED,
    ROWS_DELETED,
    LEFT(QUERY_TEXT, 200) as query_preview
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE 1=1
    AND (QUERY_TYPE IN ('UPDATE', 'DELETE', 'MERGE'))
    AND QUERY_TEXT ILIKE ANY ('%PATIENTS%', '%EMAIL%', '%PHONE%', '%NHS_NUMBER%')
    AND START_TIME >= DATEADD(DAY, -30, CURRENT_TIMESTAMP())
ORDER BY START_TIME DESC
LIMIT 100;

-- Query 3: Data lineage - trace data from source to dashboard
-- Use Case: Understand complete data flow for compliance and troubleshooting
SELECT 
    qh.QUERY_ID,
    qh.QUERY_TEXT,
    qh.DATABASE_NAME,
    qh.SCHEMA_NAME,
    qh.START_TIME,
    qh.USER_NAME,
    qh.ROLE_NAME,
    ao.OBJECT_NAME,
    ao.OBJECT_DOMAIN as object_type
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY qh
JOIN SNOWFLAKE.ACCOUNT_USAGE.ACCESS_HISTORY ah 
    ON qh.QUERY_ID = ah.QUERY_ID
JOIN LATERAL FLATTEN(input => ah.OBJECTS_MODIFIED) ao_flat
JOIN LATERAL FLATTEN(input => ao_flat.value:"columns") col_flat
CROSS JOIN TABLE(FLATTEN(input => ah.BASE_OBJECTS_ACCESSED)) ao
WHERE 1=1
    AND qh.START_TIME >= DATEADD(DAY, -7, CURRENT_TIMESTAMP())
    AND (
        ao.VALUE:"objectName"::STRING ILIKE '%PATIENT_360%' 
        OR ao.VALUE:"objectName"::STRING ILIKE '%PRESCRIPTIONS%'
    )
LIMIT 100;

-- Query 4: Access patterns by role (DATA_ENGINEER vs BI_USER)
-- Use Case: Understand which roles are accessing which data
SELECT 
    ROLE_NAME,
    DATABASE_NAME,
    SCHEMA_NAME,
    COUNT(DISTINCT QUERY_ID) as query_count,
    COUNT(DISTINCT USER_NAME) as unique_users,
    SUM(TOTAL_ELAPSED_TIME)/1000 as total_execution_seconds,
    AVG(ROWS_PRODUCED) as avg_rows_returned
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE 1=1
    AND START_TIME >= DATEADD(DAY, -7, CURRENT_TIMESTAMP())
    AND DATABASE_NAME LIKE 'PHARMACY2U%'
    AND EXECUTION_STATUS = 'SUCCESS'
GROUP BY ROLE_NAME, DATABASE_NAME, SCHEMA_NAME
ORDER BY query_count DESC;

-- Query 5: Unusual access patterns - potential security issues
-- Use Case: Detect anomalous data access for GDPR compliance
SELECT 
    USER_NAME,
    ROLE_NAME,
    COUNT(DISTINCT QUERY_ID) as query_count,
    SUM(ROWS_PRODUCED) as total_rows_accessed,
    MIN(START_TIME) as first_access,
    MAX(START_TIME) as last_access,
    COUNT(DISTINCT DATABASE_NAME) as databases_accessed
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE 1=1
    AND START_TIME >= DATEADD(DAY, -1, CURRENT_TIMESTAMP())
    AND QUERY_TEXT ILIKE ANY ('%PATIENTS%', '%NHS_NUMBER%', '%EMAIL%')
    AND EXECUTION_STATUS = 'SUCCESS'
GROUP BY USER_NAME, ROLE_NAME
HAVING COUNT(DISTINCT QUERY_ID) > 100  -- Flag high-volume access
ORDER BY total_rows_accessed DESC;

-- ============================================================================
-- Data Transfer & Export Tracking
-- ============================================================================

-- Query 6: Track data downloads and exports
-- Use Case: Monitor when sensitive data leaves Snowflake
SELECT 
    USER_NAME,
    SOURCE_CLOUD,
    SOURCE_REGION,
    TARGET_CLOUD,
    TARGET_REGION,
    BYTES_TRANSFERRED / (1024 * 1024 * 1024) as gb_transferred,
    TRANSFER_TYPE,
    START_TIME,
    END_TIME
FROM SNOWFLAKE.ACCOUNT_USAGE.DATA_TRANSFER_HISTORY
WHERE START_TIME >= DATEADD(DAY, -30, CURRENT_TIMESTAMP())
ORDER BY BYTES_TRANSFERRED DESC
LIMIT 50;

-- ============================================================================
-- Administrative Actions Log
-- ============================================================================

-- Query 7: Track governance policy changes
-- Use Case: Audit trail for masking policy and access policy changes
SELECT 
    USER_NAME,
    ROLE_NAME,
    QUERY_TYPE,
    START_TIME,
    LEFT(QUERY_TEXT, 300) as action_taken
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE 1=1
    AND QUERY_TEXT ILIKE ANY (
        '%MASKING POLICY%',
        '%ROW ACCESS POLICY%',
        '%GRANT%',
        '%REVOKE%'
    )
    AND START_TIME >= DATEADD(DAY, -30, CURRENT_TIMESTAMP())
ORDER BY START_TIME DESC
LIMIT 100;

-- ============================================================================
-- Failed Access Attempts - Security Monitoring
-- ============================================================================

-- Query 8: Track failed queries and access denials
-- Use Case: Detect potential security issues or permission problems
SELECT 
    USER_NAME,
    ROLE_NAME,
    ERROR_CODE,
    ERROR_MESSAGE,
    QUERY_TYPE,
    DATABASE_NAME,
    SCHEMA_NAME,
    START_TIME,
    LEFT(QUERY_TEXT, 200) as failed_query
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE 1=1
    AND EXECUTION_STATUS = 'FAIL'
    AND ERROR_MESSAGE ILIKE ANY ('%denied%', '%not authorized%', '%permission%')
    AND START_TIME >= DATEADD(DAY, -7, CURRENT_TIMESTAMP())
ORDER BY START_TIME DESC
LIMIT 50;

-- ============================================================================
-- Object Access Summary for Compliance Reporting
-- ============================================================================

-- Query 9: Complete audit report for sensitive tables
-- Use Case: Generate compliance reports for GDPR, MHRA audits
SELECT 
    DATE_TRUNC('day', START_TIME) as access_date,
    DATABASE_NAME,
    SCHEMA_NAME,
    COUNT(DISTINCT USER_NAME) as unique_users,
    COUNT(DISTINCT QUERY_ID) as total_queries,
    SUM(CASE WHEN QUERY_TYPE = 'SELECT' THEN 1 ELSE 0 END) as read_operations,
    SUM(CASE WHEN QUERY_TYPE IN ('UPDATE', 'DELETE', 'MERGE', 'INSERT') THEN 1 ELSE 0 END) as write_operations,
    SUM(ROWS_PRODUCED) as total_rows_accessed
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE 1=1
    AND START_TIME >= DATEADD(DAY, -30, CURRENT_TIMESTAMP())
    AND DATABASE_NAME LIKE 'PHARMACY2U%'
    AND EXECUTION_STATUS = 'SUCCESS'
GROUP BY access_date, DATABASE_NAME, SCHEMA_NAME
ORDER BY access_date DESC, total_queries DESC;

-- ============================================================================
-- Create Views for Common Audit Queries (Optional)
-- ============================================================================

CREATE OR REPLACE VIEW PHARMACY2U_GOLD.ANALYTICS.V_PII_ACCESS_AUDIT AS
SELECT 
    USER_NAME,
    ROLE_NAME,
    START_TIME as access_timestamp,
    DATABASE_NAME,
    SCHEMA_NAME,
    QUERY_TYPE,
    EXECUTION_STATUS,
    ROWS_PRODUCED,
    TOTAL_ELAPSED_TIME/1000 as execution_seconds,
    LEFT(QUERY_TEXT, 500) as query_preview
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE 1=1
    AND QUERY_TEXT ILIKE ANY ('%EMAIL%', '%PHONE%', '%NHS_NUMBER%', '%PATIENTS%')
    AND START_TIME >= DATEADD(DAY, -90, CURRENT_TIMESTAMP());

SELECT 'Access history and lineage queries created successfully' AS STATUS;
