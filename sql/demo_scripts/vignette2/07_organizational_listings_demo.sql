-- ============================================================================
-- VIGNETTE 2 - Organizational Listings (Internal Marketplace) Demo
-- Pharmacy2U Data Product Discovery
-- Duration: 2-3 minutes
-- Key Message: "Internal data marketplace - breaking down silos"
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE PHARMACY2U_DEMO_WH;
USE DATABASE PHARMACY2U_GOLD;
USE SCHEMA DATA_PRODUCTS;

-- ============================================================================
-- DEMO FLOW: Show internal data marketplace and self-service discovery
-- ============================================================================

SELECT '=== PHARMACY2U INTERNAL DATA MARKETPLACE ===' AS DEMO_TITLE;

-- ============================================================================
-- STEP 1: Show Available Data Products
-- ============================================================================

SELECT '1. Data Product Catalog - Self-Service Discovery:' AS STEP;

-- Show all available data products in the marketplace
SELECT 
    product_id,
    product_name,
    business_domain,
    target_audience,
    pii_status,
    ROW_COUNT as records_available,
    total_users AS current_users,
    use_cases
FROM V_DATA_PRODUCT_DISCOVERY
ORDER BY product_id;

-- Talking Point: "Three curated data products ready for internal teams to discover and use"

-- ============================================================================
-- STEP 2: Show Detailed Product Information
-- ============================================================================

SELECT '2. Patient 360 Analytics - Detailed Information:' AS STEP;

-- Show details for Patient 360 product
SELECT 
    product_name,
    product_description,
    data_owner,
    refresh_frequency,
    pii_status,
    governance_level,
    target_audience
FROM DATA_PRODUCT_CATALOG
WHERE product_id = 'DP001';

-- Talking Point: "Complete metadata - teams know exactly what they're getting"

-- ============================================================================
-- STEP 3: Show Sample Queries for Data Product
-- ============================================================================

SELECT '3. Sample Queries Included - Instant Productivity:' AS STEP;

-- Show sample queries for Patient 360
SELECT 
    query_name,
    query_description,
    use_case
FROM PATIENT_360_SAMPLE_QUERIES
ORDER BY query_name;

-- Talking Point: "Sample queries included - teams can start using data immediately"

-- ============================================================================
-- STEP 4: Show Access Tracking
-- ============================================================================

SELECT '4. Access Governance - Who Has Access to What:' AS STEP;

-- Show access log
SELECT 
    dpc.product_name,
    dpal.requesting_team,
    dpal.business_justification,
    dpal.access_level,
    dpal.access_granted_by,
    TO_CHAR(dpal.access_granted_date, 'YYYY-MM-DD') AS granted_date
FROM DATA_PRODUCT_ACCESS_LOG dpal
JOIN DATA_PRODUCT_CATALOG dpc ON dpal.product_id = dpc.product_id
ORDER BY dpal.access_granted_date DESC;

-- Talking Point: "Full audit trail - know who requested what and why"

-- ============================================================================
-- STEP 5: Show Secure Shares Ready for Listing
-- ============================================================================

SELECT '5. Secure Shares - Zero Data Movement:' AS STEP;

-- Show created shares
SHOW SHARES LIKE '%_SHARE';

-- Talking Point: "Shares are live - consumers see real-time data, no copies, no lag"

-- ============================================================================
-- STEP 6: Demonstrate Self-Service Access (Simulated)
-- ============================================================================

SELECT '6. Self-Service Workflow:' AS STEP;

SELECT 
    'Step 1: User searches internal marketplace' AS workflow_step,
    'Browse data products by domain, keywords, or tags' AS description
UNION ALL SELECT 
    'Step 2: User reviews product details',
    'See metadata, sample queries, use cases, governance'
UNION ALL SELECT 
    'Step 3: User requests access',
    'Submit justification, auto-routed to data owner'
UNION ALL SELECT 
    'Step 4: Data owner approves',
    'Review request, grant access with appropriate permissions'
UNION ALL SELECT 
    'Step 5: User receives access instantly',
    'Share activated, user can query data immediately'
UNION ALL SELECT 
    'Step 6: User queries data',
    'Use sample queries or write custom SQL';

-- Talking Point: "From discovery to access in minutes, not days or weeks"

-- ============================================================================
-- BUSINESS VALUE SUMMARY
-- ============================================================================

SELECT '=== BUSINESS VALUE DELIVERED ===' AS SUMMARY;

SELECT 
    'Data Silo Elimination: Internal teams can discover and access data products' AS value_1
UNION ALL SELECT 'Self-Service: Reduce dependency on data engineering for data access'
UNION ALL SELECT 'Faster Time-to-Insight: From request to access in minutes'
UNION ALL SELECT 'Governance Maintained: All access policies apply automatically'
UNION ALL SELECT 'Zero Data Movement: Live shares, no copies, real-time updates'
UNION ALL SELECT 'Complete Audit Trail: Know who accesses what and when';

-- ============================================================================
-- COMPETITIVE DIFFERENTIATION
-- ============================================================================

SELECT '=== VS MICROSOFT FABRIC ===' AS COMPETITIVE_EDGE;

SELECT 
    'Snowflake: Built-in internal marketplace' AS snowflake_advantage
UNION ALL SELECT 'Fabric: Manual SharePoint/Teams coordination required'
UNION ALL SELECT 'Snowflake: Live data shares with governance'
UNION ALL SELECT 'Fabric: Must copy data or use Power BI datasets'
UNION ALL SELECT 'Snowflake: Self-service discovery portal'
UNION ALL SELECT 'Fabric: No unified data product catalog';

-- ============================================================================
-- PHARMACEUTICAL USE CASES
-- ============================================================================

SELECT '=== PHARMACY2U USE CASES ===' AS USE_CASES;

SELECT 
    'Marketing accesses Patient 360 for campaign targeting' AS use_case
UNION ALL SELECT 'Sales uses Churn Risk scores for retention calls'
UNION ALL SELECT 'Finance analyzes Prescription Analytics for cost management'
UNION ALL SELECT 'Operations uses drug data for inventory planning'
UNION ALL SELECT 'Strategy team analyzes all products for business insights'
UNION ALL SELECT 'Data Science builds models on shared datasets';

-- ============================================================================
-- DEMO TALKING POINTS
-- ============================================================================

SELECT '=== KEY DEMO MESSAGES ===' AS TALKING_POINTS;

SELECT 
    '1. Internal marketplace breaks down data silos' AS message
UNION ALL SELECT '2. Self-service reduces data engineering bottlenecks'
UNION ALL SELECT '3. Zero data movement - live shares only'
UNION ALL SELECT '4. Governance travels with the data automatically'
UNION ALL SELECT '5. Sample queries enable instant productivity'
UNION ALL SELECT '6. Complete audit trail for compliance';

SELECT 'Organizational listings demo complete!' AS STATUS;
