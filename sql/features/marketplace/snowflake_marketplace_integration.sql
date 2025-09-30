-- ============================================================================
-- Pharmacy2U Demo - Snowflake Marketplace Data Integration
-- Purpose: Demonstrate external data enrichment without data movement
-- Key Feature: Instant access to third-party pharmaceutical data
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE PHARMACY2U_DEMO_WH;
USE DATABASE PHARMACY2U_GOLD;
USE SCHEMA ANALYTICS;

-- ============================================================================
-- MARKETPLACE VALUE PROPOSITION
-- ============================================================================

SELECT '=== SNOWFLAKE MARKETPLACE: INSTANT DATA ENRICHMENT ===' AS INFO;

SELECT 
    'Challenge: Internal data alone has limitations' AS business_context
UNION ALL SELECT 'Need: External pharmaceutical reference data, demographics, market insights'
UNION ALL SELECT 'Traditional Approach: Procurement, contracts, ETL, ongoing sync'
UNION ALL SELECT 'Snowflake Solution: Browse, click, query - zero data movement';

-- ============================================================================
-- STEP 1: Document Relevant Marketplace Data Products
-- ============================================================================

-- Note: This is a demonstration script. In production, you would:
-- 1. Browse Snowflake Marketplace via Snowsight UI
-- 2. Search for: "pharmaceutical", "healthcare", "demographics", "UK data"
-- 3. Acquire free/trial datasets
-- 4. Query them alongside internal data

SELECT 'Marketplace Data Products Relevant to Pharmacy2U:' AS CATEGORY;

CREATE OR REPLACE TABLE MARKETPLACE_DATA_CATALOG (
    category VARCHAR,
    product_name VARCHAR,
    provider VARCHAR,
    description VARCHAR,
    use_case VARCHAR,
    data_type VARCHAR,
    pricing VARCHAR
) AS
SELECT 
    'Pharmaceutical Reference',
    'Drug Database & Interactions',
    'Multiple Providers Available',
    'Comprehensive drug formulary, interactions, contraindications, therapeutic classifications',
    'Validate prescriptions, check drug interactions, clinical decision support',
    'Reference Data',
    'Free trials available'
UNION ALL SELECT 
    'Healthcare Demographics',
    'UK Population Health Statistics',
    'ONS / NHS Digital',
    'Population health metrics, disease prevalence, healthcare utilization by region',
    'Market sizing, service planning, patient cohort analysis',
    'Statistical Data',
    'Free/Open Data'
UNION ALL SELECT 
    'Geospatial',
    'UK Postcode Demographics',
    'Various Providers',
    'Socioeconomic indicators, deprivation indices, population density by UK postcode',
    'Geographic analysis, service area planning, targeted marketing',
    'Reference Data',
    'Subscription'
UNION ALL SELECT 
    'Financial',
    'Pharmaceutical Market Data',
    'Industry Analysts',
    'Drug pricing trends, market size, competitive intelligence, formulary changes',
    'Pricing strategy, competitive analysis, market opportunity assessment',
    'Market Intelligence',
    'Subscription'
UNION ALL SELECT 
    'Compliance',
    'MHRA Drug Safety Alerts',
    'MHRA (Medicines and Healthcare products Regulatory Agency)',
    'Drug safety alerts, recalls, regulatory updates for UK pharmaceutical sector',
    'Compliance monitoring, patient safety, proactive communication',
    'Regulatory Data',
    'Free/Government'
UNION ALL SELECT 
    'Weather & Events',
    'UK Weather Data',
    'Weather Providers',
    'Historical and forecast weather data by UK region',
    'Demand forecasting (flu season, seasonal allergies), delivery planning',
    'Time Series Data',
    'Subscription';

SELECT * FROM MARKETPLACE_DATA_CATALOG ORDER BY category, product_name;

SELECT 'Marketplace catalog created - 6 potential data sources' AS STATUS;

-- ============================================================================
-- STEP 2: Simulated External Data - UK Postcode Demographics
-- ============================================================================

-- In a real implementation, this would come from Marketplace
-- For demo purposes, we'll create sample reference data

CREATE OR REPLACE TABLE EXTERNAL_UK_POSTCODE_DEMOGRAPHICS (
    postcode_prefix VARCHAR(4),
    region_name VARCHAR,
    population_density VARCHAR,
    median_age NUMBER,
    deprivation_index NUMBER,  -- 1=most deprived, 10=least deprived
    health_index NUMBER,  -- 1=poorest health, 10=best health
    average_income_gbp NUMBER,
    data_source VARCHAR DEFAULT 'Snowflake Marketplace - UK Demographics Provider'
) COMMENT = 'Simulated Marketplace data - UK postcode demographics for enrichment';

-- Insert sample demographic data for UK postcodes
INSERT INTO EXTERNAL_UK_POSTCODE_DEMOGRAPHICS 
    (postcode_prefix, region_name, population_density, median_age, deprivation_index, health_index, average_income_gbp)
VALUES
    ('SW', 'Southwest London', 'High', 38, 8, 7, 45000),
    ('M', 'Manchester', 'High', 35, 5, 6, 32000),
    ('B', 'Birmingham', 'High', 36, 4, 5, 28000),
    ('L', 'Liverpool', 'Medium', 37, 4, 5, 27000),
    ('LS', 'Leeds', 'Medium', 36, 5, 6, 30000),
    ('GL', 'Gloucester', 'Low', 42, 6, 6, 31000),
    ('NE', 'Newcastle', 'Medium', 37, 4, 5, 29000),
    ('BS', 'Bristol', 'Medium', 37, 7, 7, 36000),
    ('CF', 'Cardiff', 'Medium', 36, 5, 6, 31000),
    ('EH', 'Edinburgh', 'Medium', 38, 6, 7, 35000);

SELECT 'External demographic data loaded (simulated marketplace data)' AS STATUS;

-- ============================================================================
-- STEP 3: Data Enrichment - Internal + Marketplace Data
-- ============================================================================

SELECT '=== DEMONSTRATION: ENRICHING PHARMACY2U DATA WITH MARKETPLACE INSIGHTS ===' AS DEMO;

-- Query 1: Patient demographics enriched with area characteristics
CREATE OR REPLACE VIEW V_PATIENT_ENRICHED_DEMOGRAPHICS AS
SELECT 
    p.PATIENT_ID,
    p.AGE,
    p.GENDER,
    p.POSTCODE,
    p.TOTAL_PRESCRIPTIONS,
    p.LIFETIME_VALUE_GBP,
    -- Enrichment from Marketplace data
    ext.region_name,
    ext.population_density AS area_population_density,
    ext.median_age AS area_median_age,
    ext.deprivation_index AS area_deprivation_index,
    ext.health_index AS area_health_index,
    ext.average_income_gbp AS area_avg_income,
    -- Derived insights
    CASE 
        WHEN p.AGE > ext.median_age THEN 'Above Area Median'
        ELSE 'Below Area Median'
    END AS age_vs_area,
    CASE 
        WHEN ext.deprivation_index <= 3 THEN 'High Deprivation'
        WHEN ext.deprivation_index <= 6 THEN 'Medium Deprivation'
        ELSE 'Low Deprivation'
    END AS deprivation_category,
    ext.data_source
FROM V_PATIENT_360 p
LEFT JOIN EXTERNAL_UK_POSTCODE_DEMOGRAPHICS ext
    ON LEFT(p.POSTCODE, REGEXP_COUNT(ext.postcode_prefix, '.')) = ext.postcode_prefix;

COMMENT ON VIEW V_PATIENT_ENRICHED_DEMOGRAPHICS IS 'Patient data enriched with external marketplace demographics';

SELECT 'Enriched patient demographics view created' AS STATUS;

-- Show enriched data sample
SELECT 
    PATIENT_ID,
    AGE,
    POSTCODE,
    region_name,
    area_deprivation_index,
    area_health_index,
    deprivation_category,
    LIFETIME_VALUE_GBP
FROM V_PATIENT_ENRICHED_DEMOGRAPHICS
WHERE region_name IS NOT NULL
LIMIT 10;

-- ============================================================================
-- STEP 4: Business Insights from Enriched Data
-- ============================================================================

SELECT '=== BUSINESS INSIGHTS: MARKETPLACE DATA ENABLES NEW ANALYSIS ===' AS INSIGHTS;

-- Insight 1: Customer Value by Area Deprivation
SELECT 
    deprivation_category,
    COUNT(*) AS patient_count,
    ROUND(AVG(LIFETIME_VALUE_GBP), 2) AS avg_lifetime_value,
    ROUND(SUM(LIFETIME_VALUE_GBP), 2) AS total_value,
    ROUND(AVG(TOTAL_PRESCRIPTIONS), 1) AS avg_prescriptions
FROM V_PATIENT_ENRICHED_DEMOGRAPHICS
WHERE deprivation_category IS NOT NULL
GROUP BY deprivation_category
ORDER BY 
    CASE deprivation_category
        WHEN 'High Deprivation' THEN 1
        WHEN 'Medium Deprivation' THEN 2
        WHEN 'Low Deprivation' THEN 3
    END;

-- Insight 2: Health Index vs Customer Engagement
SELECT 
    area_health_index,
    COUNT(*) AS patient_count,
    ROUND(AVG(LIFETIME_VALUE_GBP), 2) AS avg_lifetime_value,
    ROUND(AVG(TOTAL_PRESCRIPTIONS), 1) AS avg_prescriptions
FROM V_PATIENT_ENRICHED_DEMOGRAPHICS
WHERE area_health_index IS NOT NULL
GROUP BY area_health_index
ORDER BY area_health_index;

-- Insight 3: Service Opportunity Analysis by Region
SELECT 
    region_name,
    area_population_density AS area_type,
    COUNT(*) AS current_patients,
    ROUND(SUM(LIFETIME_VALUE_GBP), 2) AS current_revenue,
    area_deprivation_index,
    area_health_index,
    -- Opportunity score (lower health index + higher deprivation = more opportunity)
    ROUND((11 - area_health_index + area_deprivation_index) / 2, 1) AS service_opportunity_score
FROM V_PATIENT_ENRICHED_DEMOGRAPHICS
WHERE region_name IS NOT NULL
GROUP BY region_name, area_population_density, area_deprivation_index, area_health_index
ORDER BY service_opportunity_score DESC;

SELECT 'Business insights generated from marketplace-enriched data' AS STATUS;

-- ============================================================================
-- STEP 5: Zero Data Movement Value Demonstration
-- ============================================================================

SELECT '=== COMPETITIVE ADVANTAGE: ZERO DATA MOVEMENT ===' AS VALUE_PROP;

CREATE OR REPLACE VIEW V_MARKETPLACE_VALUE_COMPARISON AS
SELECT 
    'Traditional Approach' AS approach,
    'Download CSV from vendor' AS step_1,
    'Upload to Azure Data Lake' AS step_2,
    'Build ETL pipeline' AS step_3,
    'Schedule regular syncs' AS step_4,
    'Monitor data freshness' AS step_5,
    'Weeks' AS time_to_value,
    'High' AS ongoing_cost,
    'Vendor data updates = new ETL' AS maintenance_burden
UNION ALL
SELECT 
    'Snowflake Marketplace',
    'Browse marketplace',
    'Click "Get Data"',
    'Query immediately',
    'Auto-updated by provider',
    'Always fresh',
    'Minutes',
    'Low',
    'Zero - provider maintains';

SELECT * FROM V_MARKETPLACE_VALUE_COMPARISON;

-- ============================================================================
-- STEP 6: Use Case Examples
-- ============================================================================

SELECT '=== PHARMACEUTICAL USE CASES ENABLED ===' AS USE_CASES;

CREATE OR REPLACE TABLE MARKETPLACE_USE_CASES (
    use_case_name VARCHAR,
    marketplace_data_needed VARCHAR,
    business_question VARCHAR,
    value_delivered VARCHAR
) AS
SELECT 
    'Service Expansion Planning',
    'UK Population Demographics + Health Statistics',
    'Which underserved regions should we expand pharmacy services to?',
    'Target £5M+ new revenue from strategic expansion'
UNION ALL SELECT 
    'Precision Marketing',
    'Postcode Socioeconomic Data',
    'Which patient cohorts respond best to different campaign types?',
    'Increase campaign ROI by 30% through better targeting'
UNION ALL SELECT 
    'Drug Interaction Checking',
    'Pharmaceutical Reference Database',
    'Are patients receiving prescriptions with dangerous interactions?',
    'Reduce patient safety incidents, improve clinical outcomes'
UNION ALL SELECT 
    'Competitive Intelligence',
    'Pharmaceutical Market Data',
    'How does our pricing compare to market trends?',
    'Optimize pricing to maximize margin while remaining competitive'
UNION ALL SELECT 
    'Demand Forecasting',
    'Weather Data + Health Statistics',
    'How will flu season impact prescription volume?',
    'Optimize inventory, reduce stockouts and waste'
UNION ALL SELECT 
    'Compliance Monitoring',
    'MHRA Drug Safety Alerts',
    'Are any of our dispensed drugs subject to new safety alerts?',
    'Proactive patient communication, reduce liability';

SELECT * FROM MARKETPLACE_USE_CASES ORDER BY use_case_name;

-- ============================================================================
-- DEMO TALKING POINTS
-- ============================================================================

SELECT '=== Snowflake Marketplace Demo Talking Points ===' AS INFO;

SELECT 
    'Point 1: Instant access to external data - no procurement, no ETL' AS talking_point
UNION ALL SELECT 'Point 2: Zero data movement - query across boundaries seamlessly'
UNION ALL SELECT 'Point 3: Always fresh - providers maintain and update'
UNION ALL SELECT 'Point 4: Try before you buy - free trials for most datasets'
UNION ALL SELECT 'Point 5: Join internal + external in single query'
UNION ALL SELECT 'Point 6: Fabric requires manual data acquisition and integration';

SELECT '=== BUSINESS VALUE SUMMARY ===' AS SUMMARY;

SELECT 
    'Time Saved: Weeks to minutes for external data access' AS value_1
UNION ALL SELECT 'Cost Saved: No ETL infrastructure, no data storage for external data'
UNION ALL SELECT 'Insights Unlocked: Geographic, demographic, market intelligence'
UNION ALL SELECT 'Risk Reduced: Provider maintains data quality and freshness'
UNION ALL SELECT 'Agility Gained: Test multiple data sources quickly'
UNION ALL SELECT 'Innovation Enabled: Focus on analysis, not data engineering';

SELECT 'Snowflake Marketplace integration demonstration complete!' AS FINAL_STATUS;
