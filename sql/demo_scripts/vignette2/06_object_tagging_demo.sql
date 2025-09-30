-- ============================================================================
-- VIGNETTE 2 - Object Tagging & Data Classification Demo
-- Pharmacy2U Automated Governance
-- Duration: 2-3 minutes
-- Key Message: "Self-documenting, automatically governed data"
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE PHARMACY2U_DEMO_WH;
USE DATABASE PHARMACY2U_GOLD;
USE SCHEMA ANALYTICS;

-- ============================================================================
-- DEMO FLOW: Show automated data classification and discovery
-- ============================================================================

-- Talking Point: "Tags enable automated data discovery and compliance tracking"

SELECT '=== PHARMACY2U DATA GOVERNANCE: TAG-BASED CLASSIFICATION ===' AS DEMO_TITLE;

-- ============================================================================
-- STEP 1: Show PII Inventory for GDPR Compliance
-- ============================================================================

SELECT '1. PII Inventory - All Personally Identifiable Information:' AS STEP;

-- Show all PII columns across the organization
SELECT 
    database_name,
    schema_name,
    table_name,
    column_name,
    pii_classification,
    sensitivity_level,
    compliance_requirement
FROM V_PII_INVENTORY
WHERE database_name = 'PHARMACY2U_SILVER'
ORDER BY 
    CASE pii_classification
        WHEN 'DIRECT_IDENTIFIER' THEN 1
        WHEN 'QUASI_IDENTIFIER' THEN 2
        WHEN 'SENSITIVE_ATTRIBUTE' THEN 3
    END,
    table_name,
    column_name
LIMIT 15;

-- Talking Point: "Every PII column automatically tagged and tracked for GDPR compliance"

-- ============================================================================
-- STEP 2: Data Classification Summary
-- ============================================================================

SELECT '2. Data Classification Across All Objects:' AS STEP;

-- Show breakdown by classification level
SELECT 
    classification_level,
    object_type,
    object_count
FROM V_DATA_CLASSIFICATION_SUMMARY
ORDER BY 
    CASE classification_level
        WHEN 'PII' THEN 1
        WHEN 'SENSITIVE' THEN 2
        WHEN 'CONFIDENTIAL' THEN 3
        WHEN 'INTERNAL' THEN 4
        WHEN 'PUBLIC' THEN 5
    END,
    object_type;

-- Talking Point: "Automated classification of all data assets - tables, columns, databases"

-- ============================================================================
-- STEP 3: Compliance Framework Coverage
-- ============================================================================

SELECT '3. Compliance Framework Coverage:' AS STEP;

-- Show which data assets are covered by each compliance framework
SELECT 
    compliance_framework,
    databases_covered,
    schemas_covered,
    objects_covered
FROM V_COMPLIANCE_COVERAGE
ORDER BY objects_covered DESC;

-- Talking Point: "GDPR, NHS Standards, MHRA - all tracked automatically"

-- ============================================================================
-- STEP 4: Find All NHS-Regulated Data
-- ============================================================================

SELECT '4. NHS-Regulated Data Assets (Patient Health Data):' AS STEP;

-- Query to find all NHS-regulated columns (immediate verification)
SELECT 
    TAG_NAME,
    TAG_VALUE,
    OBJECT_NAME AS table_name,
    COLUMN_NAME
FROM TABLE(PHARMACY2U_GOLD.INFORMATION_SCHEMA.TAG_REFERENCES_ALL_COLUMNS(
    'PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS',
    'table'
))
WHERE TAG_NAME = 'COMPLIANCE_CATEGORY'
    AND TAG_VALUE = 'NHS_STANDARDS'
ORDER BY COLUMN_NAME
LIMIT 10;

-- Talking Point: "Instantly identify all NHS-regulated data for audit purposes"

-- ============================================================================
-- STEP 5: MHRA-Regulated Prescription Data
-- ============================================================================

SELECT '5. MHRA-Regulated Prescription Data (Drug Information):' AS STEP;

-- Find all MHRA-regulated columns in prescriptions
SELECT 
    TAG_NAME,
    TAG_VALUE,
    OBJECT_NAME AS table_name,
    COLUMN_NAME
FROM TABLE(PHARMACY2U_GOLD.INFORMATION_SCHEMA.TAG_REFERENCES_ALL_COLUMNS(
    'PHARMACY2U_SILVER.GOVERNED_DATA.PRESCRIPTIONS',
    'table'
))
WHERE TAG_NAME = 'COMPLIANCE_CATEGORY'
    AND TAG_VALUE = 'MHRA_REGULATED'
ORDER BY COLUMN_NAME;

-- Talking Point: "Pharmaceutical-specific compliance tracked automatically"

-- ============================================================================
-- STEP 6: Data Ownership and Stewardship
-- ============================================================================

SELECT '6. Data Ownership by Domain:' AS STEP;

-- Show data owners for each business domain
SELECT 
    TAG_VALUE AS business_domain,
    OBJECT_NAME,
    DOMAIN AS object_type
FROM TABLE(PHARMACY2U_GOLD.INFORMATION_SCHEMA.TAG_REFERENCES(
    'PHARMACY2U_GOLD',
    'database'
))
WHERE TAG_NAME = 'BUSINESS_DOMAIN'
ORDER BY business_domain
LIMIT 10;

-- Talking Point: "Clear ownership and stewardship - no more 'who owns this data?'"

-- ============================================================================
-- STEP 7: Data Retention Requirements
-- ============================================================================

SELECT '7. Data Retention Policy Tracking:' AS STEP;

-- Show retention periods for key tables
SELECT 
    OBJECT_DATABASE,
    OBJECT_SCHEMA,
    TAG_VALUE AS retention_period
FROM TABLE(PHARMACY2U_GOLD.INFORMATION_SCHEMA.TAG_REFERENCES(
    'PHARMACY2U_SILVER.GOVERNED_DATA',
    'schema'
))
WHERE TAG_NAME = 'RETENTION_PERIOD'
ORDER BY TAG_VALUE DESC;

-- Talking Point: "7-year retention for patient records - compliance automated"

-- ============================================================================
-- STEP 8: Medallion Architecture Quality Stages
-- ============================================================================

SELECT '8. Data Quality Stages (Medallion Architecture):' AS STEP;

-- Show data quality tags across medallion layers
SELECT 
    OBJECT_DATABASE AS database_layer,
    TAG_VALUE AS quality_stage
FROM TABLE(PHARMACY2U_GOLD.INFORMATION_SCHEMA.TAG_REFERENCES(
    'PHARMACY2U_GOLD',
    'database'
))
WHERE TAG_NAME = 'DATA_QUALITY'
UNION ALL
SELECT 
    OBJECT_DATABASE,
    TAG_VALUE
FROM TABLE(PHARMACY2U_GOLD.INFORMATION_SCHEMA.TAG_REFERENCES(
    'PHARMACY2U_SILVER',
    'database'
))
WHERE TAG_NAME = 'DATA_QUALITY'
UNION ALL
SELECT 
    OBJECT_DATABASE,
    TAG_VALUE
FROM TABLE(PHARMACY2U_GOLD.INFORMATION_SCHEMA.TAG_REFERENCES(
    'PHARMACY2U_BRONZE',
    'database'
))
WHERE TAG_NAME = 'DATA_QUALITY'
ORDER BY quality_stage;

-- Talking Point: "Bronze = Raw, Silver = Validated, Gold = Curated - self-documenting"

-- ============================================================================
-- BUSINESS VALUE SUMMARY
-- ============================================================================

SELECT '=== BUSINESS VALUE DELIVERED ===' AS SUMMARY;

SELECT 
    'Automated GDPR Compliance: All PII tagged and discoverable' AS value_1
UNION ALL SELECT 'NHS & MHRA Standards: Pharmaceutical compliance tracked'
UNION ALL SELECT 'Data Discovery: Find any data asset in seconds'
UNION ALL SELECT 'Audit-Ready: Complete data lineage and classification'
UNION ALL SELECT 'Risk Reduction: Automated identification for breach response'
UNION ALL SELECT 'Self-Documenting: Business context travels with data';

-- ============================================================================
-- COMPETITIVE DIFFERENTIATION
-- ============================================================================

SELECT '=== VS MICROSOFT FABRIC ===' AS COMPETITIVE_EDGE;

SELECT 
    'Snowflake: Automated tagging built into platform' AS snowflake_advantage
UNION ALL SELECT 'Fabric: Manual documentation in Purview required'
UNION ALL SELECT 'Snowflake: Tags drive access policies automatically'
UNION ALL SELECT 'Fabric: Separate security configuration needed'
UNION ALL SELECT 'Snowflake: Single source of truth for governance'
UNION ALL SELECT 'Fabric: Multiple tools to stitch together';

-- ============================================================================
-- DEMO TALKING POINTS
-- ============================================================================

SELECT '=== KEY DEMO MESSAGES ===' AS TALKING_POINTS;

SELECT 
    '1. Tags enable automated compliance - GDPR, NHS, MHRA' AS message
UNION ALL SELECT '2. Self-documenting data - context travels with the data'
UNION ALL SELECT '3. Instant discovery - find PII for breach response in seconds'
UNION ALL SELECT '4. Policy automation - tags drive masking and access control'
UNION ALL SELECT '5. Single platform - no separate governance tools required'
UNION ALL SELECT '6. Pharmaceutical-specific - NHS and MHRA compliance built-in';

SELECT 'Object Tagging demo complete!' AS STATUS;
