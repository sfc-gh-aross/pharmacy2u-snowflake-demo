-- ============================================================================
-- Pharmacy2U Demo - Alerts & Notifications
-- Purpose: Proactive monitoring for data quality, operations, and security
-- Key Features: Task-based alerts, email notifications, automated monitoring
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE PHARMACY2U_DEMO_WH;
USE DATABASE PHARMACY2U_GOLD;
USE SCHEMA ANALYTICS;

-- ============================================================================
-- Alert 1: Data Quality - NULL NHS Numbers Detection
-- ============================================================================

-- Create alert task to check for patients with missing NHS numbers
CREATE OR REPLACE TASK ALERT_NULL_NHS_NUMBERS
    WAREHOUSE = PHARMACY2U_DEMO_WH
    SCHEDULE = 'USING CRON 0 8 * * * Europe/London'  -- Daily at 8 AM
AS
BEGIN
    LET null_count NUMBER;
    
    -- Check for NULL NHS numbers in new patient records
    SELECT COUNT(*) INTO :null_count
    FROM PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS
    WHERE NHS_NUMBER IS NULL
        AND REGISTRATION_DATE >= CURRENT_DATE() - 1;
    
    -- If found, log the alert (in production, would send email/notification)
    IF (:null_count > 0) THEN
        INSERT INTO PHARMACY2U_GOLD.ANALYTICS.ALERT_LOG 
        (alert_timestamp, alert_type, alert_severity, alert_message, record_count)
        VALUES (
            CURRENT_TIMESTAMP(),
            'DATA_QUALITY',
            'HIGH',
            'Patients registered without NHS numbers detected',
            :null_count
        );
    END IF;
END;

-- ============================================================================
-- Alert 2: Prescription Volume Anomaly Detection
-- ============================================================================

-- Create alert for abnormal prescription volumes
CREATE OR REPLACE TASK ALERT_PRESCRIPTION_ANOMALY
    WAREHOUSE = PHARMACY2U_DEMO_WH
    SCHEDULE = 'USING CRON 0 */4 * * * Europe/London'  -- Every 4 hours
AS
BEGIN
    LET current_count NUMBER;
    LET avg_count NUMBER;
    LET std_dev NUMBER;
    
    -- Get current hour's prescription count
    SELECT COUNT(*) INTO :current_count
    FROM PHARMACY2U_SILVER.GOVERNED_DATA.PRESCRIPTIONS
    WHERE PRESCRIPTION_DATE >= DATEADD(HOUR, -1, CURRENT_TIMESTAMP());
    
    -- Get average and standard deviation from last 7 days
    SELECT 
        AVG(hourly_count) INTO :avg_count,
        STDDEV(hourly_count) INTO :std_dev
    FROM (
        SELECT 
            DATE_TRUNC('hour', PRESCRIPTION_DATE) as hour,
            COUNT(*) as hourly_count
        FROM PHARMACY2U_SILVER.GOVERNED_DATA.PRESCRIPTIONS
        WHERE PRESCRIPTION_DATE >= DATEADD(DAY, -7, CURRENT_TIMESTAMP())
        GROUP BY hour
    );
    
    -- Alert if current count is more than 2 standard deviations from average
    IF (:current_count > (:avg_count + (2 * :std_dev))) THEN
        INSERT INTO PHARMACY2U_GOLD.ANALYTICS.ALERT_LOG 
        (alert_timestamp, alert_type, alert_severity, alert_message, record_count)
        VALUES (
            CURRENT_TIMESTAMP(),
            'BUSINESS_ANOMALY',
            'MEDIUM',
            'Prescription volume spike detected: ' || :current_count || ' vs avg ' || :avg_count,
            :current_count
        );
    ELSIF (:current_count < (:avg_count - (2 * :std_dev))) THEN
        INSERT INTO PHARMACY2U_GOLD.ANALYTICS.ALERT_LOG 
        (alert_timestamp, alert_type, alert_severity, alert_message, record_count)
        VALUES (
            CURRENT_TIMESTAMP(),
            'BUSINESS_ANOMALY',
            'MEDIUM',
            'Prescription volume drop detected: ' || :current_count || ' vs avg ' || :avg_count,
            :current_count
        );
    END IF;
END;

-- ============================================================================
-- Alert 3: Failed Data Pipeline Notification
-- ============================================================================

-- Create alert for failed Dynamic Table refreshes
CREATE OR REPLACE TASK ALERT_PIPELINE_FAILURES
    WAREHOUSE = PHARMACY2U_DEMO_WH
    SCHEDULE = 'USING CRON 0 */1 * * * Europe/London'  -- Every hour
AS
BEGIN
    LET failure_count NUMBER;
    
    -- Check for failed refreshes in last hour
    SELECT COUNT(*) INTO :failure_count
    FROM TABLE(INFORMATION_SCHEMA.DYNAMIC_TABLE_REFRESH_HISTORY(
        'PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS'
    ))
    WHERE STATE = 'FAILED'
        AND REFRESH_END_TIME >= DATEADD(HOUR, -1, CURRENT_TIMESTAMP());
    
    -- Alert on failures
    IF (:failure_count > 0) THEN
        INSERT INTO PHARMACY2U_GOLD.ANALYTICS.ALERT_LOG 
        (alert_timestamp, alert_type, alert_severity, alert_message, record_count)
        VALUES (
            CURRENT_TIMESTAMP(),
            'PIPELINE_FAILURE',
            'CRITICAL',
            'Dynamic Table refresh failures detected',
            :failure_count
        );
    END IF;
END;

-- ============================================================================
-- Alert 4: Warehouse Credit Threshold Alert
-- ============================================================================

-- Create alert for high warehouse credit consumption
CREATE OR REPLACE TASK ALERT_WAREHOUSE_CREDITS
    WAREHOUSE = PHARMACY2U_DEMO_WH
    SCHEDULE = 'USING CRON 0 0 * * * Europe/London'  -- Daily at midnight
AS
BEGIN
    LET daily_credits NUMBER;
    LET threshold_credits NUMBER := 10;  -- Adjust based on budget
    
    -- Check today's credit consumption
    SELECT COALESCE(SUM(CREDITS_USED), 0) INTO :daily_credits
    FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
    WHERE WAREHOUSE_NAME LIKE 'PHARMACY2U%'
        AND START_TIME >= CURRENT_DATE();
    
    -- Alert if exceeding daily threshold
    IF (:daily_credits > :threshold_credits) THEN
        INSERT INTO PHARMACY2U_GOLD.ANALYTICS.ALERT_LOG 
        (alert_timestamp, alert_type, alert_severity, alert_message, record_count)
        VALUES (
            CURRENT_TIMESTAMP(),
            'COST_ALERT',
            'HIGH',
            'Daily credit threshold exceeded: ' || :daily_credits || ' credits used',
            :daily_credits
        );
    END IF;
END;

-- ============================================================================
-- Alert 5: Security - Unusual Access Patterns
-- ============================================================================

-- Create alert for after-hours administrative actions
CREATE OR REPLACE TASK ALERT_AFTER_HOURS_ADMIN
    WAREHOUSE = PHARMACY2U_DEMO_WH
    SCHEDULE = 'USING CRON 0 9 * * * Europe/London'  -- Daily at 9 AM
AS
BEGIN
    LET admin_action_count NUMBER;
    
    -- Check for administrative actions between 10 PM and 6 AM
    SELECT COUNT(DISTINCT QUERY_ID) INTO :admin_action_count
    FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
    WHERE USER_NAME != 'SYSTEM'
        AND ROLE_NAME = 'ACCOUNTADMIN'
        AND START_TIME >= CURRENT_DATE() - 1
        AND START_TIME < CURRENT_DATE()
        AND HOUR(START_TIME) NOT BETWEEN 6 AND 22
        AND QUERY_TYPE IN ('UPDATE', 'DELETE', 'DROP', 'GRANT', 'REVOKE');
    
    -- Alert if unusual admin activity detected
    IF (:admin_action_count > 0) THEN
        INSERT INTO PHARMACY2U_GOLD.ANALYTICS.ALERT_LOG 
        (alert_timestamp, alert_type, alert_severity, alert_message, record_count)
        VALUES (
            CURRENT_TIMESTAMP(),
            'SECURITY_ALERT',
            'HIGH',
            'After-hours administrative actions detected',
            :admin_action_count
        );
    END IF;
END;

-- ============================================================================
-- Alert 6: Data Quality - Prescription Date Validation
-- ============================================================================

-- Create alert for prescriptions with future dates
CREATE OR REPLACE TASK ALERT_FUTURE_PRESCRIPTIONS
    WAREHOUSE = PHARMACY2U_DEMO_WH
    SCHEDULE = 'USING CRON 0 12 * * * Europe/London'  -- Daily at noon
AS
BEGIN
    LET future_count NUMBER;
    
    -- Check for prescriptions with future dates (data quality issue)
    SELECT COUNT(*) INTO :future_count
    FROM PHARMACY2U_SILVER.GOVERNED_DATA.PRESCRIPTIONS
    WHERE PRESCRIPTION_DATE > CURRENT_DATE();
    
    -- Alert if found
    IF (:future_count > 0) THEN
        INSERT INTO PHARMACY2U_GOLD.ANALYTICS.ALERT_LOG 
        (alert_timestamp, alert_type, alert_severity, alert_message, record_count)
        VALUES (
            CURRENT_TIMESTAMP(),
            'DATA_QUALITY',
            'MEDIUM',
            'Prescriptions with future dates detected',
            :future_count
        );
    END IF;
END;

-- ============================================================================
-- Create Alert Log Table
-- ============================================================================

CREATE TABLE IF NOT EXISTS PHARMACY2U_GOLD.ANALYTICS.ALERT_LOG (
    alert_id NUMBER AUTOINCREMENT,
    alert_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    alert_type VARCHAR(50),
    alert_severity VARCHAR(20),
    alert_message VARCHAR(500),
    record_count NUMBER,
    acknowledged BOOLEAN DEFAULT FALSE,
    acknowledged_by VARCHAR(100),
    acknowledged_at TIMESTAMP_NTZ,
    PRIMARY KEY (alert_id)
)
COMMENT = 'Central log for all automated alerts and notifications';

-- ============================================================================
-- Email Notification Setup (Requires Email Integration Configuration)
-- ============================================================================

-- Note: Email integration requires additional Snowflake account setup
-- This is a template for sending email notifications

/*
CREATE OR REPLACE NOTIFICATION INTEGRATION PHARMACY2U_EMAIL_INTEGRATION
    TYPE = EMAIL
    ENABLED = TRUE
    ALLOWED_RECIPIENTS = ('data-team@pharmacy2u.co.uk', 'alerts@pharmacy2u.co.uk');

-- Example email notification stored procedure
CREATE OR REPLACE PROCEDURE SEND_ALERT_EMAIL(
    alert_subject VARCHAR,
    alert_body VARCHAR,
    recipient VARCHAR
)
RETURNS VARCHAR
LANGUAGE SQL
AS
$$
BEGIN
    CALL SYSTEM$SEND_EMAIL(
        'PHARMACY2U_EMAIL_INTEGRATION',
        :recipient,
        :alert_subject,
        :alert_body
    );
    RETURN 'Email sent successfully';
END;
$$;
*/

-- ============================================================================
-- Enable Alert Tasks
-- ============================================================================

ALTER TASK ALERT_NULL_NHS_NUMBERS RESUME;
ALTER TASK ALERT_PRESCRIPTION_ANOMALY RESUME;
ALTER TASK ALERT_PIPELINE_FAILURES RESUME;
ALTER TASK ALERT_WAREHOUSE_CREDITS RESUME;
ALTER TASK ALERT_AFTER_HOURS_ADMIN RESUME;
ALTER TASK ALERT_FUTURE_PRESCRIPTIONS RESUME;

-- ============================================================================
-- Alert Dashboard View
-- ============================================================================

CREATE OR REPLACE VIEW PHARMACY2U_GOLD.ANALYTICS.V_ACTIVE_ALERTS AS
SELECT 
    alert_id,
    alert_timestamp,
    alert_type,
    alert_severity,
    alert_message,
    record_count,
    acknowledged,
    acknowledged_by,
    DATEDIFF(HOUR, alert_timestamp, CURRENT_TIMESTAMP()) as hours_since_alert
FROM PHARMACY2U_GOLD.ANALYTICS.ALERT_LOG
WHERE acknowledged = FALSE
ORDER BY alert_severity DESC, alert_timestamp DESC;

-- ============================================================================
-- Manual Alert Check Queries (For Demo)
-- ============================================================================

-- Check recent alerts
SELECT * FROM PHARMACY2U_GOLD.ANALYTICS.ALERT_LOG
ORDER BY alert_timestamp DESC
LIMIT 20;

-- Alert summary by type
SELECT 
    alert_type,
    alert_severity,
    COUNT(*) as alert_count,
    MAX(alert_timestamp) as latest_alert
FROM PHARMACY2U_GOLD.ANALYTICS.ALERT_LOG
WHERE alert_timestamp >= DATEADD(DAY, -7, CURRENT_TIMESTAMP())
GROUP BY alert_type, alert_severity
ORDER BY alert_count DESC;

SELECT 'Alerts and notifications configured successfully - 6 proactive monitors active' AS STATUS;

-- ============================================================================
-- DEMO TALKING POINTS
-- ============================================================================

-- 1. "Proactive monitoring prevents P1 incidents before they impact the business"
-- 2. "Built-in alerting - no need for external monitoring tools"
-- 3. "Task-based alerts run automatically on schedule"
-- 4. "Email/webhook integration for real-time notifications"
-- 5. "Centralized alert log provides complete operational visibility"
