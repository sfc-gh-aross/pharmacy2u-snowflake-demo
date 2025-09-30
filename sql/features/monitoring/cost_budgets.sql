-- ============================================================================
-- Pharmacy2U Demo - Cost Management & Budgets
-- Purpose: Resource monitoring, cost tracking, and budget controls
-- Key Features: Resource monitors, spend tracking, per-second billing visibility
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE PHARMACY2U_DEMO_WH;

-- ============================================================================
-- Create Resource Monitor for Budget Control
-- ============================================================================

-- Create monthly budget monitor for demo environment
CREATE OR REPLACE RESOURCE MONITOR PHARMACY2U_DEMO_BUDGET
WITH 
    CREDIT_QUOTA = 100                    -- £500 monthly budget (assuming ~£5/credit)
    FREQUENCY = MONTHLY
    START_TIMESTAMP = IMMEDIATELY
    TRIGGERS 
        ON 50 PERCENT DO NOTIFY              -- Alert at 50% usage
        ON 75 PERCENT DO NOTIFY              -- Alert at 75% usage  
        ON 90 PERCENT DO NOTIFY              -- Alert at 90% usage
        ON 100 PERCENT DO SUSPEND            -- Suspend at 100% (optional for demo)
        ON 110 PERCENT DO SUSPEND_IMMEDIATE  -- Hard stop at 110%
COMMENT = 'Monthly budget monitor for Pharmacy2U demo environment';

-- Assign monitor to warehouses
ALTER WAREHOUSE PHARMACY2U_DEMO_WH SET RESOURCE_MONITOR = PHARMACY2U_DEMO_BUDGET;
ALTER WAREHOUSE PHARMACY2U_ETL_WH SET RESOURCE_MONITOR = PHARMACY2U_DEMO_BUDGET;

-- Note: Create additional warehouses monitors if needed
-- ALTER WAREHOUSE PHARMACY2U_ML_WH SET RESOURCE_MONITOR = PHARMACY2U_DEMO_BUDGET;

SELECT 'Resource monitor created and assigned to warehouses' AS STATUS;

-- ============================================================================
-- Cost Tracking Queries
-- ============================================================================

-- Query 1: Current month credit consumption
SELECT 
    WAREHOUSE_NAME,
    SUM(CREDITS_USED) as total_credits_used,
    SUM(CREDITS_USED) * 5 as estimated_cost_gbp,  -- Adjust multiplier based on your pricing
    COUNT(DISTINCT DATE_TRUNC('day', START_TIME)) as days_active
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
WHERE 1=1
    AND START_TIME >= DATE_TRUNC('month', CURRENT_DATE())
    AND WAREHOUSE_NAME LIKE 'PHARMACY2U%'
GROUP BY WAREHOUSE_NAME
ORDER BY total_credits_used DESC;

-- Query 2: Cost per warehouse over time
SELECT 
    DATE_TRUNC('day', START_TIME) as usage_date,
    WAREHOUSE_NAME,
    SUM(CREDITS_USED) as daily_credits,
    SUM(CREDITS_USED) * 5 as estimated_daily_cost_gbp
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
WHERE 1=1
    AND START_TIME >= DATEADD(DAY, -30, CURRENT_DATE())
    AND WAREHOUSE_NAME LIKE 'PHARMACY2U%'
GROUP BY usage_date, WAREHOUSE_NAME
ORDER BY usage_date DESC, daily_credits DESC;

-- Query 3: Cost per user/role
SELECT 
    qh.USER_NAME,
    qh.ROLE_NAME,
    qh.WAREHOUSE_NAME,
    COUNT(DISTINCT qh.QUERY_ID) as query_count,
    SUM(qh.EXECUTION_TIME/1000/60/60) as total_execution_hours,
    -- Approximate credit calculation (simplified)
    SUM(qh.EXECUTION_TIME/1000/60/60) * 
        CASE qh.WAREHOUSE_SIZE 
            WHEN 'XSMALL' THEN 1
            WHEN 'SMALL' THEN 2
            WHEN 'MEDIUM' THEN 4
            WHEN 'LARGE' THEN 8
            ELSE 1
        END as estimated_credits_used
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY qh
WHERE 1=1
    AND qh.START_TIME >= DATE_TRUNC('month', CURRENT_DATE())
    AND qh.WAREHOUSE_NAME LIKE 'PHARMACY2U%'
    AND qh.EXECUTION_STATUS = 'SUCCESS'
GROUP BY qh.USER_NAME, qh.ROLE_NAME, qh.WAREHOUSE_NAME
ORDER BY estimated_credits_used DESC
LIMIT 50;

-- Query 4: Idle time vs active time ratio (warehouse efficiency)
SELECT 
    WAREHOUSE_NAME,
    SUM(CREDITS_USED_COMPUTE) as compute_credits,
    SUM(CREDITS_USED_CLOUD_SERVICES) as cloud_services_credits,
    SUM(CREDITS_USED) as total_credits,
    -- Efficiency metric: higher is better
    ROUND(SUM(CREDITS_USED_COMPUTE) / NULLIF(SUM(CREDITS_USED), 0) * 100, 2) as compute_efficiency_pct
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
WHERE 1=1
    AND START_TIME >= DATEADD(DAY, -7, CURRENT_DATE())
    AND WAREHOUSE_NAME LIKE 'PHARMACY2U%'
GROUP BY WAREHOUSE_NAME
ORDER BY total_credits DESC;

-- Query 5: Auto-suspend effectiveness
SELECT 
    wlh.WAREHOUSE_NAME,
    COUNT(DISTINCT DATE_TRUNC('hour', wlh.START_TIME)) as active_hours,
    SUM(wlh.CREDITS_USED) as total_credits,
    -- Average credits per active hour
    SUM(wlh.CREDITS_USED) / NULLIF(COUNT(DISTINCT DATE_TRUNC('hour', wlh.START_TIME)), 0) as credits_per_active_hour
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_LOAD_HISTORY wlh
WHERE 1=1
    AND wlh.START_TIME >= DATEADD(DAY, -7, CURRENT_DATE())
    AND wlh.WAREHOUSE_NAME LIKE 'PHARMACY2U%'
GROUP BY wlh.WAREHOUSE_NAME
ORDER BY total_credits DESC;

-- ============================================================================
-- Budget Projection & Forecasting
-- ============================================================================

-- Query 6: Project monthly spend based on current usage
WITH daily_usage AS (
    SELECT 
        DATE_TRUNC('day', START_TIME) as usage_date,
        SUM(CREDITS_USED) as daily_credits
    FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
    WHERE 1=1
        AND START_TIME >= DATE_TRUNC('month', CURRENT_DATE())
        AND WAREHOUSE_NAME LIKE 'PHARMACY2U%'
    GROUP BY usage_date
),
avg_daily AS (
    SELECT AVG(daily_credits) as avg_credits_per_day
    FROM daily_usage
)
SELECT 
    avg_credits_per_day,
    avg_credits_per_day * 30 as projected_monthly_credits,
    avg_credits_per_day * 30 * 5 as projected_monthly_cost_gbp,
    100 as budget_credits,  -- From resource monitor
    CASE 
        WHEN (avg_credits_per_day * 30) > 100 
        THEN 'OVER BUDGET - Adjust warehouse sizes or auto-suspend'
        WHEN (avg_credits_per_day * 30) > 75
        THEN 'WARNING - Approaching budget limit'
        ELSE 'ON TRACK'
    END as budget_status
FROM avg_daily;

-- ============================================================================
-- Per-Second Billing Demonstration
-- ============================================================================

-- Query 7: Show per-second billing granularity
SELECT 
    QUERY_ID,
    WAREHOUSE_NAME,
    START_TIME,
    END_TIME,
    EXECUTION_TIME as execution_milliseconds,
    EXECUTION_TIME/1000 as execution_seconds,
    -- Approximate credit usage (1 credit = 1 XSMALL warehouse hour = 3600 seconds)
    (EXECUTION_TIME/1000/3600) * 
        CASE WAREHOUSE_SIZE
            WHEN 'XSMALL' THEN 1
            WHEN 'SMALL' THEN 2  
            WHEN 'MEDIUM' THEN 4
            ELSE 1
        END as credits_consumed,
    QUERY_TYPE,
    LEFT(QUERY_TEXT, 100) as query_preview
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE 1=1
    AND START_TIME >= DATEADD(HOUR, -1, CURRENT_TIMESTAMP())
    AND WAREHOUSE_NAME LIKE 'PHARMACY2U%'
    AND EXECUTION_STATUS = 'SUCCESS'
ORDER BY START_TIME DESC
LIMIT 20;

-- ============================================================================
-- Warehouse Efficiency Comparison
-- ============================================================================

-- Query 8: Compare cost efficiency of different warehouse sizes
SELECT 
    WAREHOUSE_SIZE,
    COUNT(DISTINCT QUERY_ID) as query_count,
    AVG(EXECUTION_TIME/1000) as avg_execution_seconds,
    SUM(EXECUTION_TIME/1000/3600) as total_compute_hours,
    -- Credit calculation by size
    SUM(EXECUTION_TIME/1000/3600) * 
        CASE WAREHOUSE_SIZE
            WHEN 'XSMALL' THEN 1
            WHEN 'SMALL' THEN 2
            WHEN 'MEDIUM' THEN 4
            WHEN 'LARGE' THEN 8
            ELSE 1
        END as estimated_credits,
    -- Cost per query
    (SUM(EXECUTION_TIME/1000/3600) * 
        CASE WAREHOUSE_SIZE
            WHEN 'XSMALL' THEN 1
            WHEN 'SMALL' THEN 2
            WHEN 'MEDIUM' THEN 4
            ELSE 1
        END) / NULLIF(COUNT(DISTINCT QUERY_ID), 0) as credits_per_query
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE 1=1
    AND START_TIME >= DATEADD(DAY, -7, CURRENT_DATE())
    AND WAREHOUSE_NAME LIKE 'PHARMACY2U%'
    AND EXECUTION_STATUS = 'SUCCESS'
GROUP BY WAREHOUSE_SIZE
ORDER BY estimated_credits DESC;

-- ============================================================================
-- Cost Optimization Recommendations
-- ============================================================================

-- Query 9: Identify optimization opportunities
SELECT 
    'Long-running queries on small warehouses' as optimization_opportunity,
    COUNT(*) as query_count,
    AVG(EXECUTION_TIME/1000) as avg_execution_seconds
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE 1=1
    AND START_TIME >= DATEADD(DAY, -7, CURRENT_DATE())
    AND WAREHOUSE_SIZE = 'XSMALL'
    AND EXECUTION_TIME > 60000  -- Queries longer than 1 minute
    AND EXECUTION_STATUS = 'SUCCESS'

UNION ALL

SELECT 
    'Queries during off-hours (potential for scheduled batch)' as optimization_opportunity,
    COUNT(*) as query_count,
    AVG(EXECUTION_TIME/1000) as avg_execution_seconds
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE 1=1
    AND START_TIME >= DATEADD(DAY, -7, CURRENT_DATE())
    AND HOUR(START_TIME) NOT BETWEEN 8 AND 18  -- Outside business hours
    AND EXECUTION_STATUS = 'SUCCESS';

-- ============================================================================
-- Create Cost Monitoring Dashboard View
-- ============================================================================

CREATE OR REPLACE VIEW PHARMACY2U_GOLD.ANALYTICS.V_COST_DASHBOARD AS
SELECT 
    DATE_TRUNC('day', START_TIME) as usage_date,
    WAREHOUSE_NAME,
    SUM(CREDITS_USED) as daily_credits,
    SUM(CREDITS_USED) * 5 as estimated_daily_cost_gbp,
    COUNT(DISTINCT QUERY_ID) as query_count,
    AVG(EXECUTION_TIME/1000) as avg_query_seconds
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY wmh
LEFT JOIN SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY qh
    ON wmh.WAREHOUSE_NAME = qh.WAREHOUSE_NAME
    AND DATE_TRUNC('hour', wmh.START_TIME) = DATE_TRUNC('hour', qh.START_TIME)
WHERE 1=1
    AND wmh.START_TIME >= DATEADD(DAY, -30, CURRENT_DATE())
    AND wmh.WAREHOUSE_NAME LIKE 'PHARMACY2U%'
GROUP BY usage_date, WAREHOUSE_NAME;

SELECT 'Cost management and budgets configured successfully' AS STATUS;

-- ============================================================================
-- DEMO TALKING POINTS
-- ============================================================================

-- 1. "Per-second billing means you only pay for what you use - no idle charges"
-- 2. "Resource monitors provide guardrails to prevent runaway costs"
-- 3. "Complete cost visibility down to the query level"
-- 4. "Auto-suspend ensures warehouses stop consuming credits when not in use"
-- 5. "This level of cost control and transparency is critical for lean teams"
