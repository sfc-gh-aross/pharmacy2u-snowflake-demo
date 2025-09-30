-- ============================================================================
-- Pharmacy2U Demo - Object Tagging & Data Classification
-- Purpose: Automated data discovery and compliance tracking
-- Key Feature: Metadata-driven governance for pharmaceutical data
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE PHARMACY2U_DEMO_WH;

-- ============================================================================
-- STEP 1: Create Tag Schema for Governance Tags
-- ============================================================================

-- Create dedicated schema for governance tags
CREATE SCHEMA IF NOT EXISTS PHARMACY2U_GOLD.GOVERNANCE_TAGS
    COMMENT = 'Schema for storing data classification and governance tags';

USE SCHEMA PHARMACY2U_GOLD.GOVERNANCE_TAGS;

SELECT 'Tag schema created for governance metadata' AS STATUS;

-- ============================================================================
-- STEP 2: Define Tag Categories
-- ============================================================================

-- Tag Category 1: DATA_CLASSIFICATION
-- Purpose: Classify data sensitivity levels
CREATE OR REPLACE TAG DATA_CLASSIFICATION
    ALLOWED_VALUES 'PII', 'SENSITIVE', 'CONFIDENTIAL', 'INTERNAL', 'PUBLIC'
    COMMENT = 'Data sensitivity classification for compliance and access control';

-- Tag Category 2: COMPLIANCE_CATEGORY
-- Purpose: Track regulatory compliance requirements
CREATE OR REPLACE TAG COMPLIANCE_CATEGORY
    ALLOWED_VALUES 'GDPR', 'NHS_STANDARDS', 'MHRA_REGULATED', 'FINANCIAL', 'NONE'
    COMMENT = 'Regulatory compliance requirements (UK pharmaceutical standards)';

-- Tag Category 3: BUSINESS_DOMAIN
-- Purpose: Organize data by business function
CREATE OR REPLACE TAG BUSINESS_DOMAIN
    ALLOWED_VALUES 'PATIENT_DATA', 'PRESCRIPTION_DATA', 'MARKETING_DATA', 'OPERATIONAL_DATA', 'ANALYTICS_DATA'
    COMMENT = 'Business domain classification for data ownership';

-- Tag Category 4: DATA_QUALITY
-- Purpose: Track data quality and processing stage
CREATE OR REPLACE TAG DATA_QUALITY
    ALLOWED_VALUES 'RAW', 'VALIDATED', 'ENRICHED', 'CURATED', 'ARCHIVED'
    COMMENT = 'Data quality and processing stage in medallion architecture';

-- Tag Category 5: DATA_OWNER
-- Purpose: Assign ownership for data stewardship
CREATE OR REPLACE TAG DATA_OWNER
    COMMENT = 'Team or person responsible for data stewardship (free text)';

-- Tag Category 6: RETENTION_PERIOD
-- Purpose: Define data retention requirements
CREATE OR REPLACE TAG RETENTION_PERIOD
    ALLOWED_VALUES '1_YEAR', '2_YEARS', '5_YEARS', '7_YEARS', 'INDEFINITE'
    COMMENT = 'Data retention period for compliance (UK pharmaceutical standards)';

-- Tag Category 7: PII_TYPE
-- Purpose: Specific PII classification for GDPR
CREATE OR REPLACE TAG PII_TYPE
    ALLOWED_VALUES 'DIRECT_IDENTIFIER', 'QUASI_IDENTIFIER', 'SENSITIVE_ATTRIBUTE', 'NOT_PII'
    COMMENT = 'Specific type of personally identifiable information';

SELECT 'Tag categories created successfully' AS STATUS;

-- ============================================================================
-- STEP 3: Apply Tags to Databases (Medallion Architecture)
-- ============================================================================

-- BRONZE Layer: Raw, unvalidated data
ALTER DATABASE PHARMACY2U_BRONZE SET TAG 
    GOVERNANCE_TAGS.DATA_QUALITY = 'RAW',
    GOVERNANCE_TAGS.DATA_CLASSIFICATION = 'INTERNAL',
    GOVERNANCE_TAGS.COMPLIANCE_CATEGORY = 'GDPR',
    GOVERNANCE_TAGS.DATA_OWNER = 'Data Engineering Team';

-- SILVER Layer: Validated, governed data
ALTER DATABASE PHARMACY2U_SILVER SET TAG 
    GOVERNANCE_TAGS.DATA_QUALITY = 'VALIDATED',
    GOVERNANCE_TAGS.DATA_CLASSIFICATION = 'SENSITIVE',
    GOVERNANCE_TAGS.COMPLIANCE_CATEGORY = 'GDPR',
    GOVERNANCE_TAGS.DATA_OWNER = 'Data Engineering Team';

-- GOLD Layer: Curated, analytics-ready data
ALTER DATABASE PHARMACY2U_GOLD SET TAG 
    GOVERNANCE_TAGS.DATA_QUALITY = 'CURATED',
    GOVERNANCE_TAGS.DATA_CLASSIFICATION = 'INTERNAL',
    GOVERNANCE_TAGS.COMPLIANCE_CATEGORY = 'GDPR',
    GOVERNANCE_TAGS.DATA_OWNER = 'Analytics Team';

SELECT 'Database-level tags applied to medallion architecture' AS STATUS;

-- ============================================================================
-- STEP 4: Apply Tags to Schemas by Business Domain
-- ============================================================================

-- BRONZE schemas
ALTER SCHEMA PHARMACY2U_BRONZE.RAW_DATA SET TAG
    GOVERNANCE_TAGS.BUSINESS_DOMAIN = 'OPERATIONAL_DATA',
    GOVERNANCE_TAGS.RETENTION_PERIOD = '2_YEARS';

-- SILVER schemas
ALTER SCHEMA PHARMACY2U_SILVER.GOVERNED_DATA SET TAG
    GOVERNANCE_TAGS.BUSINESS_DOMAIN = 'PATIENT_DATA',
    GOVERNANCE_TAGS.RETENTION_PERIOD = '7_YEARS',
    GOVERNANCE_TAGS.COMPLIANCE_CATEGORY = 'NHS_STANDARDS';

-- GOLD schemas
ALTER SCHEMA PHARMACY2U_GOLD.ANALYTICS SET TAG
    GOVERNANCE_TAGS.BUSINESS_DOMAIN = 'ANALYTICS_DATA',
    GOVERNANCE_TAGS.RETENTION_PERIOD = '5_YEARS';

SELECT 'Schema-level tags applied by business domain' AS STATUS;

-- ============================================================================
-- STEP 5: Apply Tags to Tables
-- ============================================================================

-- Tag patient tables with compliance requirements
ALTER TABLE PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS SET TAG
    GOVERNANCE_TAGS.DATA_CLASSIFICATION = 'PII',
    GOVERNANCE_TAGS.COMPLIANCE_CATEGORY = 'GDPR',
    GOVERNANCE_TAGS.BUSINESS_DOMAIN = 'PATIENT_DATA',
    GOVERNANCE_TAGS.RETENTION_PERIOD = '7_YEARS';

-- Tag prescription tables with MHRA regulation
ALTER TABLE PHARMACY2U_SILVER.GOVERNED_DATA.PRESCRIPTIONS SET TAG
    GOVERNANCE_TAGS.DATA_CLASSIFICATION = 'SENSITIVE',
    GOVERNANCE_TAGS.COMPLIANCE_CATEGORY = 'MHRA_REGULATED',
    GOVERNANCE_TAGS.BUSINESS_DOMAIN = 'PRESCRIPTION_DATA',
    GOVERNANCE_TAGS.RETENTION_PERIOD = '7_YEARS';

-- Tag marketing tables
ALTER TABLE PHARMACY2U_SILVER.GOVERNED_DATA.MARKETING_EVENTS SET TAG
    GOVERNANCE_TAGS.DATA_CLASSIFICATION = 'INTERNAL',
    GOVERNANCE_TAGS.COMPLIANCE_CATEGORY = 'GDPR',
    GOVERNANCE_TAGS.BUSINESS_DOMAIN = 'MARKETING_DATA',
    GOVERNANCE_TAGS.RETENTION_PERIOD = '2_YEARS';

-- Tag analytics tables
ALTER TABLE PHARMACY2U_GOLD.ANALYTICS.PATIENT_MARKETING_SEGMENTS SET TAG
    GOVERNANCE_TAGS.DATA_CLASSIFICATION = 'CONFIDENTIAL',
    GOVERNANCE_TAGS.BUSINESS_DOMAIN = 'ANALYTICS_DATA',
    GOVERNANCE_TAGS.RETENTION_PERIOD = '2_YEARS';

ALTER TABLE PHARMACY2U_GOLD.ANALYTICS.PATIENT_CHURN_RISK_SCORES SET TAG
    GOVERNANCE_TAGS.DATA_CLASSIFICATION = 'CONFIDENTIAL',
    GOVERNANCE_TAGS.BUSINESS_DOMAIN = 'ANALYTICS_DATA',
    GOVERNANCE_TAGS.RETENTION_PERIOD = '2_YEARS';

SELECT 'Table-level tags applied to key data assets' AS STATUS;

-- ============================================================================
-- STEP 6: Apply Tags to PII Columns (GDPR Compliance)
-- ============================================================================

-- Direct identifiers (most sensitive)
ALTER TABLE PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS MODIFY COLUMN EMAIL 
    SET TAG GOVERNANCE_TAGS.PII_TYPE = 'DIRECT_IDENTIFIER',
             GOVERNANCE_TAGS.DATA_CLASSIFICATION = 'PII';

ALTER TABLE PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS MODIFY COLUMN PHONE 
    SET TAG GOVERNANCE_TAGS.PII_TYPE = 'DIRECT_IDENTIFIER',
             GOVERNANCE_TAGS.DATA_CLASSIFICATION = 'PII';

ALTER TABLE PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS MODIFY COLUMN NHS_NUMBER 
    SET TAG GOVERNANCE_TAGS.PII_TYPE = 'DIRECT_IDENTIFIER',
             GOVERNANCE_TAGS.DATA_CLASSIFICATION = 'SENSITIVE',
             GOVERNANCE_TAGS.COMPLIANCE_CATEGORY = 'NHS_STANDARDS';

ALTER TABLE PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS MODIFY COLUMN FIRST_NAME 
    SET TAG GOVERNANCE_TAGS.PII_TYPE = 'DIRECT_IDENTIFIER',
             GOVERNANCE_TAGS.DATA_CLASSIFICATION = 'PII';

ALTER TABLE PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS MODIFY COLUMN LAST_NAME 
    SET TAG GOVERNANCE_TAGS.PII_TYPE = 'DIRECT_IDENTIFIER',
             GOVERNANCE_TAGS.DATA_CLASSIFICATION = 'PII';

-- Quasi-identifiers (can be identifying when combined)
ALTER TABLE PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS MODIFY COLUMN DATE_OF_BIRTH 
    SET TAG GOVERNANCE_TAGS.PII_TYPE = 'QUASI_IDENTIFIER',
             GOVERNANCE_TAGS.DATA_CLASSIFICATION = 'SENSITIVE';

ALTER TABLE PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS MODIFY COLUMN POSTCODE 
    SET TAG GOVERNANCE_TAGS.PII_TYPE = 'QUASI_IDENTIFIER',
             GOVERNANCE_TAGS.DATA_CLASSIFICATION = 'SENSITIVE';

-- Sensitive attributes (health data under GDPR)
ALTER TABLE PHARMACY2U_SILVER.GOVERNED_DATA.PRESCRIPTIONS MODIFY COLUMN DRUG_NAME 
    SET TAG GOVERNANCE_TAGS.PII_TYPE = 'SENSITIVE_ATTRIBUTE',
             GOVERNANCE_TAGS.DATA_CLASSIFICATION = 'SENSITIVE',
             GOVERNANCE_TAGS.COMPLIANCE_CATEGORY = 'MHRA_REGULATED';

ALTER TABLE PHARMACY2U_SILVER.GOVERNED_DATA.PRESCRIPTIONS MODIFY COLUMN DRUG_CODE 
    SET TAG GOVERNANCE_TAGS.PII_TYPE = 'SENSITIVE_ATTRIBUTE',
             GOVERNANCE_TAGS.DATA_CLASSIFICATION = 'SENSITIVE',
             GOVERNANCE_TAGS.COMPLIANCE_CATEGORY = 'MHRA_REGULATED';

ALTER TABLE PHARMACY2U_SILVER.GOVERNED_DATA.PRESCRIPTIONS MODIFY COLUMN QUANTITY 
    SET TAG GOVERNANCE_TAGS.PII_TYPE = 'SENSITIVE_ATTRIBUTE',
             GOVERNANCE_TAGS.DATA_CLASSIFICATION = 'SENSITIVE',
             GOVERNANCE_TAGS.COMPLIANCE_CATEGORY = 'MHRA_REGULATED';

SELECT 'Column-level PII tags applied for GDPR compliance' AS STATUS;

-- ============================================================================
-- STEP 7: Discovery Queries - Find Data by Tags
-- ============================================================================

-- Query 1: Find all PII columns across the organization
SELECT 
    'PII_DISCOVERY' AS query_type,
    TAG_DATABASE,
    TAG_SCHEMA,
    TAG_NAME AS table_or_column,
    COLUMN_NAME,
    TAG_VALUE,
    OBJECT_DATABASE,
    OBJECT_SCHEMA,
    OBJECT_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.TAG_REFERENCES
WHERE TAG_NAME = 'DATA_CLASSIFICATION'
    AND TAG_VALUE IN ('PII', 'SENSITIVE')
    AND OBJECT_DELETED IS NULL
ORDER BY TAG_VALUE DESC, OBJECT_DATABASE, OBJECT_SCHEMA, OBJECT_NAME
LIMIT 50;

-- Query 2: Find all GDPR-regulated data assets
SELECT 
    'GDPR_COMPLIANCE' AS query_type,
    OBJECT_DATABASE,
    OBJECT_SCHEMA,
    OBJECT_NAME,
    DOMAIN AS object_type,
    TAG_VALUE AS compliance_requirement
FROM SNOWFLAKE.ACCOUNT_USAGE.TAG_REFERENCES
WHERE TAG_NAME = 'COMPLIANCE_CATEGORY'
    AND TAG_VALUE = 'GDPR'
    AND OBJECT_DELETED IS NULL
ORDER BY OBJECT_DATABASE, OBJECT_SCHEMA, OBJECT_NAME
LIMIT 50;

-- Query 3: Find data owners for each business domain
SELECT 
    bd.TAG_VALUE AS business_domain,
    COUNT(DISTINCT bd.OBJECT_NAME) AS object_count,
    MAX(owner.TAG_VALUE) AS data_owner
FROM SNOWFLAKE.ACCOUNT_USAGE.TAG_REFERENCES bd
LEFT JOIN SNOWFLAKE.ACCOUNT_USAGE.TAG_REFERENCES owner
    ON bd.OBJECT_ID = owner.OBJECT_ID
    AND owner.TAG_NAME = 'DATA_OWNER'
WHERE bd.TAG_NAME = 'BUSINESS_DOMAIN'
    AND bd.OBJECT_DELETED IS NULL
GROUP BY bd.TAG_VALUE
ORDER BY object_count DESC;

-- Query 4: Data retention compliance report
SELECT 
    TAG_VALUE AS retention_period,
    COUNT(DISTINCT OBJECT_NAME) AS object_count
FROM SNOWFLAKE.ACCOUNT_USAGE.TAG_REFERENCES
WHERE TAG_NAME = 'RETENTION_PERIOD'
    AND OBJECT_DELETED IS NULL
GROUP BY TAG_VALUE
ORDER BY 
    CASE TAG_VALUE
        WHEN 'INDEFINITE' THEN 5
        WHEN '7_YEARS' THEN 4
        WHEN '5_YEARS' THEN 3
        WHEN '2_YEARS' THEN 2
        WHEN '1_YEAR' THEN 1
    END DESC;

-- Query 5: NHS-regulated data inventory
SELECT 
    OBJECT_DATABASE,
    OBJECT_SCHEMA,
    OBJECT_NAME,
    DOMAIN AS object_type,
    COLUMN_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.TAG_REFERENCES
WHERE TAG_NAME = 'COMPLIANCE_CATEGORY'
    AND TAG_VALUE = 'NHS_STANDARDS'
    AND OBJECT_DELETED IS NULL
ORDER BY OBJECT_DATABASE, OBJECT_SCHEMA, OBJECT_NAME;

-- Query 6: PII type breakdown (for GDPR Article 30 compliance)
SELECT 
    TAG_VALUE AS pii_type,
    COUNT(DISTINCT COLUMN_NAME) AS column_count
FROM SNOWFLAKE.ACCOUNT_USAGE.TAG_REFERENCES
WHERE TAG_NAME = 'PII_TYPE'
    AND TAG_VALUE != 'NOT_PII'
    AND OBJECT_DELETED IS NULL
GROUP BY TAG_VALUE
ORDER BY column_count DESC;

SELECT 'Tag discovery queries ready for compliance reporting' AS STATUS;

-- NOTE: ACCOUNT_USAGE views have latency (up to 2 hours)
-- For immediate validation, use INFORMATION_SCHEMA.TAG_REFERENCES instead
SELECT '⚠️ NOTE: Tag data in ACCOUNT_USAGE may take up to 2 hours to appear' AS LATENCY_WARNING;

-- Alternative: Immediate tag verification using INFORMATION_SCHEMA
SELECT 'Immediate tag verification:' AS INFO;

SELECT 
    TAG_NAME,
    TAG_VALUE,
    OBJECT_DATABASE,
    OBJECT_SCHEMA,
    OBJECT_NAME,
    COLUMN_NAME
FROM TABLE(PHARMACY2U_GOLD.INFORMATION_SCHEMA.TAG_REFERENCES_ALL_COLUMNS(
    'PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS',
    'table'
))
WHERE TAG_NAME IN ('DATA_CLASSIFICATION', 'PII_TYPE')
ORDER BY COLUMN_NAME, TAG_NAME
LIMIT 20;

-- ============================================================================
-- STEP 8: Create Compliance Dashboard Views
-- ============================================================================

USE SCHEMA PHARMACY2U_GOLD.ANALYTICS;

-- View 1: PII Inventory for GDPR compliance
CREATE OR REPLACE VIEW V_PII_INVENTORY AS
SELECT 
    OBJECT_DATABASE AS database_name,
    OBJECT_SCHEMA AS schema_name,
    OBJECT_NAME AS table_name,
    COLUMN_NAME,
    MAX(CASE WHEN TAG_NAME = 'PII_TYPE' THEN TAG_VALUE END) AS pii_classification,
    MAX(CASE WHEN TAG_NAME = 'DATA_CLASSIFICATION' THEN TAG_VALUE END) AS sensitivity_level,
    MAX(CASE WHEN TAG_NAME = 'COMPLIANCE_CATEGORY' THEN TAG_VALUE END) AS compliance_requirement
FROM SNOWFLAKE.ACCOUNT_USAGE.TAG_REFERENCES
WHERE COLUMN_NAME IS NOT NULL
    AND OBJECT_DELETED IS NULL
    AND (TAG_NAME IN ('PII_TYPE', 'DATA_CLASSIFICATION', 'COMPLIANCE_CATEGORY'))
GROUP BY OBJECT_DATABASE, OBJECT_SCHEMA, OBJECT_NAME, COLUMN_NAME
HAVING MAX(CASE WHEN TAG_NAME = 'PII_TYPE' THEN TAG_VALUE END) IS NOT NULL
ORDER BY database_name, schema_name, table_name, column_name;

-- View 2: Data Classification Summary
CREATE OR REPLACE VIEW V_DATA_CLASSIFICATION_SUMMARY AS
SELECT 
    TAG_VALUE AS classification_level,
    DOMAIN AS object_type,
    COUNT(DISTINCT OBJECT_ID) AS object_count
FROM SNOWFLAKE.ACCOUNT_USAGE.TAG_REFERENCES
WHERE TAG_NAME = 'DATA_CLASSIFICATION'
    AND OBJECT_DELETED IS NULL
GROUP BY TAG_VALUE, DOMAIN
ORDER BY classification_level, object_type;

-- View 3: Compliance Coverage Report
CREATE OR REPLACE VIEW V_COMPLIANCE_COVERAGE AS
SELECT 
    TAG_VALUE AS compliance_framework,
    COUNT(DISTINCT OBJECT_DATABASE) AS databases_covered,
    COUNT(DISTINCT OBJECT_SCHEMA) AS schemas_covered,
    COUNT(DISTINCT OBJECT_NAME) AS objects_covered
FROM SNOWFLAKE.ACCOUNT_USAGE.TAG_REFERENCES
WHERE TAG_NAME = 'COMPLIANCE_CATEGORY'
    AND OBJECT_DELETED IS NULL
GROUP BY TAG_VALUE
ORDER BY objects_covered DESC;

SELECT 'Compliance dashboard views created' AS STATUS;

-- ============================================================================
-- DEMO TALKING POINTS
-- ============================================================================

SELECT '=== Object Tagging Demo Talking Points ===' AS INFO;

SELECT 
    'Point 1: Tags enable automated data discovery and classification' AS talking_point
UNION ALL SELECT 'Point 2: Compliance tracking built into the platform - GDPR, NHS, MHRA'
UNION ALL SELECT 'Point 3: Self-documenting data - business context travels with the data'
UNION ALL SELECT 'Point 4: Automated policy suggestions based on tags'
UNION ALL SELECT 'Point 5: Single source of truth for data governance'
UNION ALL SELECT 'Point 6: Fabric requires manual documentation in Purview - we auto-tag';

-- ============================================================================
-- PHARMACEUTICAL COMPLIANCE USE CASES
-- ============================================================================

SELECT '=== UK Pharmaceutical Compliance Enabled ===' AS INFO;

SELECT 
    'GDPR Article 30: Record of processing activities - automated via tags' AS use_case
UNION ALL SELECT 'NHS Data Security Standards: Patient data classification - PII tags'
UNION ALL SELECT 'MHRA GxP: Drug prescription traceability - compliance tags'
UNION ALL SELECT 'Data retention: 7-year requirement for patient records - retention tags'
UNION ALL SELECT 'Right to be forgotten: Quick PII identification for deletion requests'
UNION ALL SELECT 'Data breach reporting: Immediate PII scope identification';

SELECT 'Object tagging implementation complete!' AS FINAL_STATUS;
