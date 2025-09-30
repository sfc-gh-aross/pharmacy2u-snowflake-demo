-- ============================================================================
-- VIGNETTE 2 - Demo Script 5: Proactive Monitoring & Alerts
-- Pharmacy2U Demo - Preventing P1 Incidents
-- Duration: 2 minutes (optional/time-permitting)
-- Key Message: "Preventing P1 incidents before they happen"
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE PHARMACY2U_DEMO_WH;
USE DATABASE PHARMACY2U_GOLD;
USE SCHEMA ANALYTICS;

-- ============================================================================
-- STEP 1: Show Active Alert Configuration
-- ============================================================================

-- Talking Point: "Your team experiences a P1 incident every two weeks"
-- "What if we could prevent those incidents with proactive monitoring?"

-- Show configured alert tasks
SHOW TASKS IN SCHEMA ANALYTICS;

-- Talking Point: "These are automated monitoring tasks that run on schedule"
-- "They check for data quality issues, pipeline failures, and security anomalies"

-- ============================================================================
-- STEP 2: Demonstrate Alert Types
-- ============================================================================

-- Data Quality Alert Example
-- Talking Point: "Here's a data quality alert - checking for missing NHS numbers"

SELECT 
    COUNT(*) as patients_with_missing_nhs_numbers,
    CASE 
        WHEN COUNT(*) > 0 THEN 'ALERT: Data quality issue detected'
        ELSE 'OK: All patients have NHS numbers'
    END as status
FROM PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS
WHERE NHS_NUMBER IS NULL
    AND REGISTRATION_DATE >= CURRENT_DATE() - 1;

-- Business Anomaly Alert Example
-- Talking Point: "And here's a business anomaly alert - unusual prescription volumes"

WITH current_volume AS (
    SELECT COUNT(*) as current_count
    FROM PHARMACY2U_SILVER.GOVERNED_DATA.PRESCRIPTIONS
    WHERE PRESCRIPTION_DATE >= CURRENT_DATE()
),
historical_avg AS (
    SELECT 
        AVG(daily_count) as avg_count,
        STDDEV(daily_count) as std_dev
    FROM (
        SELECT 
            DATE_TRUNC('day', PRESCRIPTION_DATE) as day,
            COUNT(*) as daily_count
        FROM PHARMACY2U_SILVER.GOVERNED_DATA.PRESCRIPTIONS
        WHERE PRESCRIPTION_DATE >= DATEADD(DAY, -30, CURRENT_DATE())
        GROUP BY day
    )
)
SELECT 
    cv.current_count,
    ha.avg_count,
    ha.std_dev,
    CASE 
        WHEN cv.current_count > (ha.avg_count + (2 * ha.std_dev)) THEN 'ALERT: Volume spike detected'
        WHEN cv.current_count < (ha.avg_count - (2 * ha.std_dev)) THEN 'ALERT: Volume drop detected'
        ELSE 'OK: Volume within normal range'
    END as anomaly_status
FROM current_volume cv, historical_avg ha;

-- ============================================================================
-- STEP 3: Show Alert Log
-- ============================================================================

-- Talking Point: "All alerts are logged centrally for visibility and tracking"

-- Show recent alerts (if any)
SELECT 
    alert_timestamp,
    alert_type,
    alert_severity,
    alert_message,
    record_count,
    acknowledged
FROM PHARMACY2U_GOLD.ANALYTICS.ALERT_LOG
ORDER BY alert_timestamp DESC
LIMIT 10;

-- If no alerts exist, simulate one for demo
INSERT INTO PHARMACY2U_GOLD.ANALYTICS.ALERT_LOG 
(alert_timestamp, alert_type, alert_severity, alert_message, record_count, acknowledged)
VALUES (
    CURRENT_TIMESTAMP(),
    'DATA_QUALITY',
    'MEDIUM',
    'Demo Alert: 5 patients registered without NHS numbers',
    5,
    FALSE
);

-- Show the simulated alert
SELECT 
    alert_timestamp,
    alert_type,
    alert_severity,
    alert_message,
    record_count
FROM PHARMACY2U_GOLD.ANALYTICS.ALERT_LOG
WHERE acknowledged = FALSE
ORDER BY alert_timestamp DESC;

-- Talking Point: "In production, these alerts would trigger email notifications"
-- "Your team gets proactive alerts before issues become P1 incidents"

-- ============================================================================
-- STEP 4: Alert Summary by Type
-- ============================================================================

-- Talking Point: "Let's see a summary of alerts by type over the last week"

SELECT 
    alert_type,
    alert_severity,
    COUNT(*) as alert_count,
    MAX(alert_timestamp) as latest_alert,
    SUM(CASE WHEN acknowledged = TRUE THEN 1 ELSE 0 END) as resolved_count,
    SUM(CASE WHEN acknowledged = FALSE THEN 1 ELSE 0 END) as open_count
FROM PHARMACY2U_GOLD.ANALYTICS.ALERT_LOG
WHERE alert_timestamp >= DATEADD(DAY, -7, CURRENT_TIMESTAMP())
GROUP BY alert_type, alert_severity
ORDER BY alert_count DESC;

-- ============================================================================
-- STEP 5: Show Additional Alert Types
-- ============================================================================

-- Pipeline Health Alert
-- Talking Point: "We also monitor pipeline health - Dynamic Table refresh status"

SELECT 
    'PIPELINE_HEALTH' as monitor_type,
    COUNT(*) as total_refreshes,
    SUM(CASE WHEN STATE = 'FAILED' THEN 1 ELSE 0 END) as failed_refreshes,
    CASE 
        WHEN SUM(CASE WHEN STATE = 'FAILED' THEN 1 ELSE 0 END) > 0 
        THEN 'ALERT: Pipeline failures detected'
        ELSE 'OK: All pipelines healthy'
    END as status
FROM TABLE(INFORMATION_SCHEMA.DYNAMIC_TABLE_REFRESH_HISTORY(
    'PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS'
))
WHERE REFRESH_END_TIME >= DATEADD(HOUR, -24, CURRENT_TIMESTAMP());

-- Cost Alert
-- Talking Point: "And we monitor costs to prevent budget overruns"

SELECT 
    'COST_MONITORING' as monitor_type,
    SUM(CREDITS_USED) as daily_credits,
    10 as daily_threshold,
    CASE 
        WHEN SUM(CREDITS_USED) > 10 THEN 'ALERT: Daily credit threshold exceeded'
        ELSE 'OK: Within budget'
    END as budget_status
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
WHERE WAREHOUSE_NAME LIKE 'PHARMACY2U%'
    AND START_TIME >= CURRENT_DATE();

-- ============================================================================
-- STEP 6: Acknowledge Alert (Optional)
-- ============================================================================

-- Talking Point: "Alerts can be acknowledged once investigated and resolved"

UPDATE PHARMACY2U_GOLD.ANALYTICS.ALERT_LOG
SET 
    acknowledged = TRUE,
    acknowledged_by = CURRENT_USER(),
    acknowledged_at = CURRENT_TIMESTAMP()
WHERE alert_id = (
    SELECT MAX(alert_id) 
    FROM PHARMACY2U_GOLD.ANALYTICS.ALERT_LOG 
    WHERE acknowledged = FALSE
);

-- Show updated status
SELECT 
    COUNT(*) as total_alerts,
    SUM(CASE WHEN acknowledged = TRUE THEN 1 ELSE 0 END) as resolved,
    SUM(CASE WHEN acknowledged = FALSE THEN 1 ELSE 0 END) as open
FROM PHARMACY2U_GOLD.ANALYTICS.ALERT_LOG
WHERE alert_timestamp >= CURRENT_DATE();

SELECT 'Proactive monitoring active - preventing incidents before they impact the business' AS MONITORING_STATUS;

-- ============================================================================
-- COMPETITIVE DIFFERENTIATION TALKING POINTS
-- ============================================================================

-- 1. "Built-in alerting using Snowflake Tasks - no external monitoring tools needed"
-- 2. "Automated checks run on schedule - 24/7 monitoring with zero manual effort"
-- 3. "Email and webhook integrations for real-time notifications"
-- 4. "Covers data quality, pipeline health, security, and cost - all in one platform"
-- 5. "This proactive approach prevents the P1 incidents you currently experience"

-- ============================================================================
-- USE CASES DEMONSTRATED
-- ============================================================================

-- 1. Data Quality: NULL checks, format validation, referential integrity
-- 2. Business Anomalies: Volume spikes/drops, unusual patterns
-- 3. Pipeline Health: Dynamic Table refresh monitoring, Snowpipe status
-- 4. Security: After-hours admin actions, unusual access patterns
-- 5. Cost Control: Credit consumption, warehouse efficiency
-- 6. Compliance: PII access tracking, unauthorized modification attempts

-- ============================================================================
-- AUDIENCE ENGAGEMENT
-- ============================================================================

-- Question: "How much time does your team currently spend firefighting issues 
-- that could have been caught with proactive monitoring?"

-- Follow-up: "What if you could eliminate half of your P1 incidents with 
-- automated alerts that catch problems early?"
