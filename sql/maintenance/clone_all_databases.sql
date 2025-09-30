-- ============================================================================
-- CLONE ALL PHARMACY2U DATABASES
-- Purpose: Create zero-copy clones of all demo databases for backup/testing
-- Zero-cost, instant clones using Snowflake's metadata-based cloning
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE PHARMACY2U_DEMO_WH;

-- ============================================================================
-- Clone BRONZE Database
-- ============================================================================

CREATE DATABASE IF NOT EXISTS PHARMACY2U_BRONZE_BACKUP
CLONE PHARMACY2U_BRONZE
COMMENT = 'Zero-copy clone of BRONZE database - Created for backup/testing';

SELECT 'BRONZE database cloned successfully' AS STATUS;

-- ============================================================================
-- Clone SILVER Database
-- ============================================================================

CREATE DATABASE IF NOT EXISTS PHARMACY2U_SILVER_BACKUP
CLONE PHARMACY2U_SILVER
COMMENT = 'Zero-copy clone of SILVER database - Created for backup/testing';

SELECT 'SILVER database cloned successfully' AS STATUS;

-- ============================================================================
-- Clone GOLD Database
-- ============================================================================

CREATE DATABASE IF NOT EXISTS PHARMACY2U_GOLD_BACKUP
CLONE PHARMACY2U_GOLD
COMMENT = 'Zero-copy clone of GOLD database - Created for backup/testing';

SELECT 'GOLD database cloned successfully' AS STATUS;

-- ============================================================================
-- Verify All Clones
-- ============================================================================

SHOW DATABASES LIKE 'PHARMACY2U%';

-- Verify record counts match
SELECT 'ORIGINAL DATABASES' as source_type;

SELECT 
    'BRONZE' as database_name,
    COUNT(*) as table_count
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_CATALOG = 'PHARMACY2U_BRONZE'
  AND TABLE_SCHEMA = 'RAW_DATA'

UNION ALL

SELECT 
    'SILVER' as database_name,
    COUNT(*) as table_count
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_CATALOG = 'PHARMACY2U_SILVER'
  AND TABLE_SCHEMA = 'GOVERNED_DATA'

UNION ALL

SELECT 
    'GOLD' as database_name,
    COUNT(*) as table_count
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_CATALOG = 'PHARMACY2U_GOLD'
  AND TABLE_SCHEMA = 'ANALYTICS';

SELECT 'CLONED DATABASES' as source_type;

SELECT 
    'BRONZE_BACKUP' as database_name,
    COUNT(*) as table_count
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_CATALOG = 'PHARMACY2U_BRONZE_BACKUP'
  AND TABLE_SCHEMA = 'RAW_DATA'

UNION ALL

SELECT 
    'SILVER_BACKUP' as database_name,
    COUNT(*) as table_count
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_CATALOG = 'PHARMACY2U_SILVER_BACKUP'
  AND TABLE_SCHEMA = 'GOVERNED_DATA'

UNION ALL

SELECT 
    'GOLD_BACKUP' as database_name,
    COUNT(*) as table_count
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_CATALOG = 'PHARMACY2U_GOLD_BACKUP'
  AND TABLE_SCHEMA = 'ANALYTICS';

-- Verify Patient 360 data in GOLD clone
SELECT COUNT(*) as patient_count_in_backup
FROM PHARMACY2U_GOLD_BACKUP.ANALYTICS.V_PATIENT_360;

-- ============================================================================
-- Summary
-- ============================================================================

SELECT 
    '✅ All PHARMACY2U databases cloned successfully!' as STATUS,
    'Zero storage cost until clones are modified' as COST_NOTE,
    'Instant clones using metadata pointers' as PERFORMANCE_NOTE,
    'Use these for testing or backup before demo' as USE_CASE;

-- ============================================================================
-- TO DROP CLONES (when no longer needed):
-- ============================================================================

/*
DROP DATABASE IF EXISTS PHARMACY2U_BRONZE_BACKUP;
DROP DATABASE IF EXISTS PHARMACY2U_SILVER_BACKUP;
DROP DATABASE IF EXISTS PHARMACY2U_GOLD_BACKUP;
*/

-- ============================================================================
-- END OF CLONE SCRIPT
-- ============================================================================
