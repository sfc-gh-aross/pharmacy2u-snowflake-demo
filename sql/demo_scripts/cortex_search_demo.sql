-- ============================================================================
-- Cortex Search Demo Script
-- Duration: 3-4 minutes
-- Audience: Technical users who want semantic search capabilities
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE PHARMACY2U_GOLD;
USE SCHEMA ANALYTICS;
USE WAREHOUSE PHARMACY2U_DEMO_WH;

-- ============================================================================
-- SETUP: Verify Service is Ready
-- ============================================================================

SELECT '=== CORTEX SEARCH DEMO ===' AS DEMO_TITLE;

-- Check service status (must show "READY")
SELECT SYSTEM$GET_CORTEX_SEARCH_SERVICE_STATUS('PATIENT_360_SEARCH_SERVICE') AS service_status;

-- Expected: "READY" (if not, wait a few minutes)

-- ============================================================================
-- DEMO POINT 1: Semantic Understanding
-- Talking Point: "Unlike keyword search, Cortex Search understands MEANING"
-- ============================================================================

SELECT '1. Find High-Value Platinum Customers' AS demo_query;

-- Natural language search - no exact keyword matching needed
SELECT 
    PATIENT_ID,
    CUSTOMER_TIER,
    LIFETIME_VALUE_GBP,
    TOTAL_PRESCRIPTIONS,
    AGE_GROUP
FROM TABLE(
    SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
        'PATIENT_360_SEARCH_SERVICE',
        'platinum tier high value customers with many prescriptions'
    )
) LIMIT 10;

-- Talking Point: "I just described what I wanted in plain language. 
-- It understood 'platinum tier' = CUSTOMER_TIER, 'high value' = LIFETIME_VALUE, 
-- 'many prescriptions' = TOTAL_PRESCRIPTIONS."

-- ============================================================================
-- DEMO POINT 2: Marketing Use Case - Conversion Opportunities
-- Talking Point: "Find patients ready to convert"
-- ============================================================================

SELECT '2. Marketing Engagement Without Conversions' AS demo_query;

-- Search by behavior pattern
SELECT 
    PATIENT_ID,
    CUSTOMER_TIER,
    MARKETING_INTERACTIONS,
    CAMPAIGN_CONVERSIONS,
    LIFETIME_VALUE_GBP
FROM TABLE(
    SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
        'PATIENT_360_SEARCH_SERVICE',
        'patients with high marketing engagement but no conversions'
    )
) LIMIT 10;

-- Talking Point: "These patients are ENGAGED but haven't converted yet - 
-- perfect targets for a special offer or nurture campaign."

-- ============================================================================
-- DEMO POINT 3: Clinical Use Case - Demographic Search
-- Talking Point: "Target specific patient populations"
-- ============================================================================

SELECT '3. Elderly Patients with Chronic Prescriptions' AS demo_query;

-- Search by demographics and prescription patterns
SELECT 
    PATIENT_ID,
    AGE_GROUP,
    GENDER,
    POSTCODE,
    TOTAL_PRESCRIPTIONS,
    UNIQUE_DRUGS,
    LAST_PRESCRIPTION_DATE
FROM TABLE(
    SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
        'PATIENT_360_SEARCH_SERVICE',
        'elderly patients over 65 with chronic prescription needs'
    )
) LIMIT 10;

-- Talking Point: "Perfect for targeted clinical programs - 
-- medication adherence, wellness checks, preventive care."

-- ============================================================================
-- DEMO POINT 4: Power User - Combine Search + SQL Filters
-- Talking Point: "Best of both worlds - semantic search + precise filters"
-- ============================================================================

SELECT '4. Combined Semantic Search + SQL Filtering' AS demo_query;

-- Use search to find pattern, then filter precisely
SELECT 
    s.PATIENT_ID,
    s.AGE_GROUP,
    s.CUSTOMER_TIER,
    s.LIFETIME_VALUE_GBP,
    s.TOTAL_PRESCRIPTIONS,
    s.MARKETING_INTERACTIONS
FROM TABLE(
    SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
        'PATIENT_360_SEARCH_SERVICE',
        'patients with consistent prescription patterns and good engagement'
    )
) s
WHERE s.LIFETIME_VALUE_GBP > 2000
  AND s.AGE_GROUP IN ('51-65', '65+')
  AND s.CUSTOMER_TIER IN ('Gold', 'Platinum')
ORDER BY s.LIFETIME_VALUE_GBP DESC
LIMIT 15;

-- Talking Point: "I combined semantic search ('consistent patterns', 'good engagement') 
-- with precise SQL filters (value > £2000, specific age groups). 
-- This gives you the power of AI search with the precision of SQL."

-- ============================================================================
-- DEMO POINT 5: Geographic Analysis
-- Talking Point: "Discover regional opportunities"
-- ============================================================================

SELECT '5. High-Value Patients by Region' AS demo_query;

-- Search for geographic patterns
SELECT 
    LEFT(POSTCODE, 2) AS region,
    COUNT(*) AS patient_count,
    AVG(LIFETIME_VALUE_GBP) AS avg_value,
    SUM(TOTAL_PRESCRIPTIONS) AS total_prescriptions
FROM TABLE(
    SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
        'PATIENT_360_SEARCH_SERVICE',
        'high prescription volume patients'
    )
)
GROUP BY LEFT(POSTCODE, 2)
HAVING COUNT(*) >= 5
ORDER BY avg_value DESC
LIMIT 10;

-- Talking Point: "Found high-volume prescription patients, 
-- then aggregated by region to identify market opportunities."

-- ============================================================================
-- DEMO POINT 6: Look-alike Discovery
-- Talking Point: "Find patients similar to your best customers"
-- ============================================================================

SELECT '6. Find Similar High-Value Patients' AS demo_query;

-- First, show a reference patient
SELECT 
    'Reference Patient:' AS note,
    PATIENT_ID,
    CUSTOMER_TIER,
    AGE_GROUP,
    TOTAL_PRESCRIPTIONS,
    LIFETIME_VALUE_GBP,
    MARKETING_INTERACTIONS
FROM PATIENT_360_SEARCHABLE
WHERE CUSTOMER_TIER = 'Platinum'
  AND TOTAL_PRESCRIPTIONS > 50
LIMIT 1;

-- Then find similar patients
SELECT 'Similar Patients:' AS note;

SELECT 
    PATIENT_ID,
    CUSTOMER_TIER,
    AGE_GROUP,
    TOTAL_PRESCRIPTIONS,
    LIFETIME_VALUE_GBP,
    MARKETING_INTERACTIONS
FROM TABLE(
    SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
        'PATIENT_360_SEARCH_SERVICE',
        'platinum customers age 65+ with 50+ prescriptions high engagement'
    )
) LIMIT 10;

-- Talking Point: "Look-alike modeling made simple - 
-- describe your ideal customer, find more like them."

-- ============================================================================
-- BUSINESS IMPACT SUMMARY
-- ============================================================================

SELECT '=== BUSINESS VALUE SUMMARY ===' AS summary;

SELECT 
    'Cortex Search' AS capability,
    'Semantic patient discovery' AS use_case,
    'Marketing, Clinical, Analytics teams' AS beneficiaries,
    'Find cohorts by meaning, not just keywords' AS key_benefit,
    'Powers Snowflake Intelligence for better NL queries' AS integration,
    'Serverless, auto-maintained, governed' AS operational_advantage;

-- ============================================================================
-- DEMO WRAP-UP
-- ============================================================================

SELECT '=== KEY TAKEAWAYS ===' AS takeaways;

SELECT 1 AS point_number, 'Semantic understanding - searches by MEANING, not keywords' AS takeaway
UNION ALL
SELECT 2, 'Combines with SQL - flexible for power users and business users'
UNION ALL
SELECT 3, 'Automatically maintained - no manual index management'
UNION ALL
SELECT 4, 'Powers Snowflake Intelligence - foundation for natural language queries'
UNION ALL
SELECT 5, 'Governed by default - inherits all Snowflake security policies'
UNION ALL
SELECT 6, 'Serverless - no infrastructure, pay only when you query'
ORDER BY point_number;

-- ============================================================================
-- COMPETITIVE DIFFERENTIATION
-- ============================================================================

SELECT '=== VS AZURE COGNITIVE SEARCH ===' AS comparison;

SELECT 
    'Data Movement' AS criteria,
    'None - searches in place' AS snowflake_cortex,
    'Must copy to Azure Search' AS azure_cognitive
UNION ALL
SELECT 'Setup Complexity', '1 SQL statement', 'Provision, configure, deploy'
UNION ALL
SELECT 'Maintenance', 'Automatic refresh', 'Manual index management'
UNION ALL
SELECT 'Security', 'Inherits Snowflake policies', 'Separate configuration'
UNION ALL
SELECT 'Cost Model', 'Serverless, per-query', 'Fixed hosting costs'
UNION ALL
SELECT 'Integration', 'Native to platform', 'External API calls';

-- ============================================================================
-- NEXT STEPS FOR CUSTOMER
-- ============================================================================

SELECT '=== ENABLE FOR YOUR TEAM ===' AS next_steps;

SELECT 
    1 AS step_order,
    'Grant CORTEX privileges' AS action,
    'GRANT USAGE ON CORTEX SEARCH SERVICE TO ROLE your_role;' AS example
UNION ALL
SELECT 2, 'Share search queries library', 'Provide common search patterns for each department'
UNION ALL
SELECT 3, 'Train power users', '15-minute session on search + SQL combination'
UNION ALL
SELECT 4, 'Enable in Intelligence', 'Cortex Search enhances natural language queries automatically'
UNION ALL
SELECT 5, 'Monitor usage', 'Track which searches are most valuable to optimize'
ORDER BY step_order;

SELECT 'Cortex Search Demo Complete!' AS DEMO_STATUS;
