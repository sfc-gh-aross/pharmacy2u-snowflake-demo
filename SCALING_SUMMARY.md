# Data Scaling Summary - Pharmacy2U Demo

## Current Environment

### ✅ What's Working
- **100,000** patients in RAW_PATIENTS (BRONZE layer)
- **500,809** prescriptions in RAW_PRESCRIPTIONS (BRONZE layer)
- **100,000** patients in SILVER.PATIENTS (Dynamic Table - auto-refreshed)
- **477,612** prescriptions in SILVER.PRESCRIPTIONS (Dynamic Table - filtered by quality rules)
- **100,000** records in V_PATIENT_360 (GOLD layer)

### 🔒 Safety Backups Created
- All PHARMACY2U databases cloned to `*_BACKUP` versions (zero-cost clones)
- `RAW_PATIENTS_BACKUP` - 100,000 original patients
- `RAW_PRESCRIPTIONS_BACKUP` - 500,809 original prescriptions

## 🚀 Options for 1000x Scaling

### Option 1: Run Scaling Script in Snowsight UI (Recommended)
The Snowflake web UI (Snowsight) handles long-running queries better than CLI.

**Steps:**
1. Open Snowsight: https://app.snowflake.com
2. Navigate to Worksheets
3. Run the script: `sql/maintenance/scale_bronze_data_1000x.sql`
4. Monitor progress (10-20 minutes)

### Option 2: Use Python Snowpark (Most Reliable)
For very large data generation, Snowpark handles session management better.

```python
# See: src/python/data_generation/scale_data_1000x.py
```

### Option 3: Batch Processing (Safest)
Instead of 1000x at once, scale in batches:
- Batch 1: 10x (1M patients) - 2 minutes
- Batch 2: 100x (10M patients) - 10 minutes  
- Batch 3: 1000x (100M patients) - 20 minutes

This allows validation at each step.

## 📋 Current Data Architecture

```
BRONZE Layer (Source Data)
├── RAW_PATIENTS (100K) ← Need to scale to 100M
├── RAW_PRESCRIPTIONS (500K) ← Need to scale to 500M
└── RAW_MARKETING_EVENTS (1M)

       ↓ (Dynamic Tables - Auto-refresh in 1 minute)

SILVER Layer (Governed Data)
├── PATIENTS (100K) - Dynamic Table with quality rules
├── PRESCRIPTIONS (477K) - Dynamic Table (filtered invalid records)
└── MARKETING_EVENTS (1M) - Dynamic Table (JSON flattened)

       ↓ (Views - Instant refresh)

GOLD Layer (Analytics)
└── V_PATIENT_360 (100K) - 360° patient view for analytics
```

## 🔧 Quick Commands

### Verify Current Counts
```sql
-- BRONZE
SELECT 'RAW_PATIENTS' as table_name, COUNT(*) as row_count 
FROM PHARMACY2U_BRONZE.RAW_DATA.RAW_PATIENTS
UNION ALL
SELECT 'RAW_PRESCRIPTIONS', COUNT(*) 
FROM PHARMACY2U_BRONZE.RAW_DATA.RAW_PRESCRIPTIONS;

-- SILVER
SELECT 'PATIENTS' as table_name, COUNT(*) as row_count 
FROM PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS
UNION ALL
SELECT 'PRESCRIPTIONS', COUNT(*) 
FROM PHARMACY2U_SILVER.GOVERNED_DATA.PRESCRIPTIONS;

-- GOLD
SELECT 'V_PATIENT_360' as view_name, COUNT(*) as row_count 
FROM PHARMACY2U_GOLD.ANALYTICS.V_PATIENT_360;
```

### Restore from Backup (if needed)
```sql
-- Restore to original 100K dataset
DROP TABLE IF EXISTS PHARMACY2U_BRONZE.RAW_DATA.RAW_PATIENTS;
CREATE TABLE PHARMACY2U_BRONZE.RAW_DATA.RAW_PATIENTS 
CLONE PHARMACY2U_BRONZE.RAW_DATA.RAW_PATIENTS_BACKUP;

DROP TABLE IF EXISTS PHARMACY2U_BRONZE.RAW_DATA.RAW_PRESCRIPTIONS;
CREATE TABLE PHARMACY2U_BRONZE.RAW_DATA.RAW_PRESCRIPTIONS 
CLONE PHARMACY2U_BRONZE.RAW_DATA.RAW_PRESCRIPTIONS_BACKUP;

-- Trigger Dynamic Table refresh
ALTER DYNAMIC TABLE PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS REFRESH;
ALTER DYNAMIC TABLE PHARMACY2U_SILVER.GOVERNED_DATA.PRESCRIPTIONS REFRESH;
```

## 💡 Why Scale to 100M?

### Demo Impact
- **100K patients**: "This is nice"
- **100M patients**: "This is enterprise-scale!" 🚀

### Performance Showcase
- Query 100M records in seconds (vs hours in traditional databases)
- Demonstrate Snowflake's elastic compute
- Show cost efficiency with auto-suspend/resume

### Competitive Advantage
- Microsoft Fabric struggles with this scale
- Traditional SSIS/ETL would take hours to load
- Snowflake: Load 100M records in 15 minutes

## 📁 Scripts Available

1. **`sql/maintenance/scale_bronze_data_1000x.sql`**
   - Full 1000x scaling script
   - Run in Snowsight for best results

2. **`sql/maintenance/clone_all_databases.sql`**
   - ✅ Already executed - backups created

3. **`sql/maintenance/verify_scaled_data.sql`** (to be created)
   - Validation queries post-scaling

## ✅ Next Steps

1. **Decision**: Choose scaling option (Snowsight UI recommended)
2. **Execute**: Run scaling script (10-20 minutes)
3. **Verify**: Check row counts at each layer
4. **Demo**: Wow the audience with 100M patient queries! 🎯

---

**Note**: All backups are zero-cost clones. They only consume storage when modified.
