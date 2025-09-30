-- ============================================================================
-- Pharmacy2U Demo - Marketing Events Data Generation (SQL-based)
-- Purpose: Generate 1M marketing event JSON records
-- Target: 1M+ records in <3 minutes
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE PHARMACY2U_BRONZE;
USE SCHEMA RAW_DATA;
USE WAREHOUSE PHARMACY2U_LOADING_WH;

-- Clear existing data
TRUNCATE TABLE IF EXISTS RAW_MARKETING_EVENTS;

-- Generate 1M marketing event records in JSON format
INSERT INTO RAW_MARKETING_EVENTS (
    EVENT_DATA,
    INGESTION_TIMESTAMP,
    SOURCE_SYSTEM
)
SELECT
    OBJECT_CONSTRUCT(
        'event_id', 'EVT-' || LPAD(SEQ4(), 10, '0'),
        'patient_id', 'PT-' || LPAD(UNIFORM(1, 100000, RANDOM()), 8, '0'),
        'campaign_id', campaigns.campaign_id,
        'campaign_name', campaigns.campaign_name,
        'event_type', event_types.event_type,
        'event_timestamp', 
            DATEADD(
                SECOND,
                -UNIFORM(0, 63072000, RANDOM()),  -- Last 2 years
                CURRENT_TIMESTAMP()
            ),
        'channel', campaigns.channel,
        'conversion_flag', 
            CASE 
                WHEN event_types.event_type = 'conversion' THEN TRUE
                WHEN event_types.event_type = 'click' AND UNIFORM(1, 100, RANDOM()) <= 8 THEN TRUE
                WHEN UNIFORM(1, 100, RANDOM()) <= 2 THEN TRUE
                ELSE FALSE
            END,
        'metadata', OBJECT_CONSTRUCT(
            'device_type', 
                CASE UNIFORM(1, 3, RANDOM())
                    WHEN 1 THEN 'mobile'
                    WHEN 2 THEN 'desktop'
                    ELSE 'tablet'
                END,
            'browser',
                CASE UNIFORM(1, 4, RANDOM())
                    WHEN 1 THEN 'Chrome'
                    WHEN 2 THEN 'Safari'
                    WHEN 3 THEN 'Firefox'
                    ELSE 'Edge'
                END,
            'location',
                CASE UNIFORM(1, 5, RANDOM())
                    WHEN 1 THEN 'London'
                    WHEN 2 THEN 'Manchester'
                    WHEN 3 THEN 'Birmingham'
                    WHEN 4 THEN 'Leeds'
                    ELSE 'Glasgow'
                END
        )
    ) AS EVENT_DATA,
    CURRENT_TIMESTAMP() AS INGESTION_TIMESTAMP,
    'ADLS_GEN2' AS SOURCE_SYSTEM
FROM 
    TABLE(GENERATOR(ROWCOUNT => 1000000)) gen
CROSS JOIN (
    SELECT * FROM (
        SELECT 'CAMP-001' AS campaign_id, 'Heart Health Month' AS campaign_name, 'email' AS channel
        UNION ALL SELECT 'CAMP-002', 'Flu Season Reminder', 'sms'
        UNION ALL SELECT 'CAMP-003', 'Prescription Refill Alert', 'push'
        UNION ALL SELECT 'CAMP-004', 'Diabetes Awareness', 'email'
        UNION ALL SELECT 'CAMP-005', 'Summer Allergy Relief', 'sms'
        UNION ALL SELECT 'CAMP-006', 'Winter Wellness', 'email'
        UNION ALL SELECT 'CAMP-007', 'Mental Health Support', 'push'
        UNION ALL SELECT 'CAMP-008', 'NHS Prescription Savings', 'email'
    )
    QUALIFY ROW_NUMBER() OVER (ORDER BY RANDOM()) = UNIFORM(1, 8, RANDOM())
) campaigns
CROSS JOIN (
    SELECT * FROM (
        SELECT 'email_open' AS event_type
        UNION ALL SELECT 'click'
        UNION ALL SELECT 'conversion'
        UNION ALL SELECT 'app_open'
        UNION ALL SELECT 'sms_delivered'
        UNION ALL SELECT 'push_notification'
    )
    QUALIFY ROW_NUMBER() OVER (ORDER BY RANDOM()) = UNIFORM(1, 6, RANDOM())
) event_types;

-- Validate data generation
SELECT 
    'RAW_MARKETING_EVENTS' AS TABLE_NAME,
    COUNT(*) AS RECORD_COUNT,
    COUNT(DISTINCT EVENT_DATA:event_id) AS UNIQUE_EVENTS,
    COUNT(DISTINCT EVENT_DATA:patient_id) AS UNIQUE_PATIENTS,
    COUNT(DISTINCT EVENT_DATA:campaign_id) AS UNIQUE_CAMPAIGNS,
    SUM(CASE WHEN EVENT_DATA:conversion_flag = TRUE THEN 1 ELSE 0 END) AS TOTAL_CONVERSIONS,
    ROUND(SUM(CASE WHEN EVENT_DATA:conversion_flag = TRUE THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS CONVERSION_RATE_PCT
FROM RAW_MARKETING_EVENTS;

-- Show sample JSON data
SELECT EVENT_DATA FROM RAW_MARKETING_EVENTS LIMIT 5;

SELECT '✅ Marketing events data generation completed successfully' AS STATUS;
