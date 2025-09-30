# Pharmacy2U Demo - Technical Setup Guide

## Prerequisites

### Required Software
- Python 3.9 or higher
- Snowflake CLI (`snow` command)
- pip (Python package installer)
- Git (for version control)

### Snowflake Requirements
- Snowflake account (Enterprise edition or higher)
- ACCOUNTADMIN role access
- Azure region deployment (for Azure data source connectivity)

## Installation Steps

### 1. Install Snowflake CLI

```bash
# Install using pip
pip install snowflake-cli-labs

# Verify installation
snow --version
```

### 2. Install Python Dependencies

```bash
# Navigate to project directory
cd pharmacy2u-snowflake-demo

# Install requirements
pip install -r requirements.txt
```

### 3. Configure Snowflake Connection

#### Option A: Using Snowflake CLI (Recommended)

```bash
# Create dedicated demo connection
snow connection add --connection-name pharmacy2u_demo_connection \
  --account <YOUR_ACCOUNT> \
  --user <YOUR_USER> \
  --role ACCOUNTADMIN \
  --database PHARMACY2U_DEMO_DB \
  --schema DEMO_SCHEMA \
  --warehouse PHARMACY2U_DEMO_WH \
  --authenticator externalbrowser

# Set as default connection
snow connection set-default pharmacy2u_demo_connection

# Test connection
snow connection test
```

#### Option B: Manual Configuration

Edit `~/.snowflake/config.toml` (Linux/Mac) or `%USERPROFILE%\.snowflake\config.toml` (Windows):

```toml
[connections.pharmacy2u_demo_connection]
account = "YOUR_ACCOUNT"
user = "YOUR_USER"
role = "ACCOUNTADMIN"
database = "PHARMACY2U_DEMO_DB"
schema = "DEMO_SCHEMA"
warehouse = "PHARMACY2U_DEMO_WH"
authenticator = "externalbrowser"
```

## Deployment Process

### Automated Deployment (Recommended)

```bash
# Run master deployment script
python deployment/scripts/deploy_demo_environment.py pharmacy2u_demo_connection

# Deploy Streamlit applications
python deployment/scripts/deploy_streamlit_apps.py pharmacy2u_demo_connection
```

### Manual Deployment

#### Step 1: Infrastructure Setup

```bash
# Execute setup scripts in sequence
snow sql --filename sql/setup/00_database_setup.sql --connection pharmacy2u_demo_connection
snow sql --filename sql/setup/01_warehouse_configuration.sql --connection pharmacy2u_demo_connection
snow sql --filename sql/setup/02_schema_creation.sql --connection pharmacy2u_demo_connection
snow sql --filename sql/setup/03_permissions.sql --connection pharmacy2u_demo_connection
```

#### Step 2: Data Generation

```bash
# Generate prescription data (500K records)
python src/python/data_generation/prescription_generator.py pharmacy2u_demo_connection 500000

# Generate patient data (100K records)
python src/python/data_generation/patient_generator.py pharmacy2u_demo_connection 100000

# Generate marketing events (1M records)
python src/python/data_generation/marketing_events_generator.py 1000000
```

#### Step 3: Feature Deployment

```bash
# Deploy Dynamic Tables
snow sql --filename sql/features/dynamic_tables/bronze_to_silver.sql --connection pharmacy2u_demo_connection

# Deploy Access Policies
snow sql --filename sql/features/governance/access_policies.sql --connection pharmacy2u_demo_connection
```

## Validation

### Verify Database Infrastructure

```sql
-- Show databases
SHOW DATABASES LIKE 'PHARMACY2U%';

-- Show warehouses
SHOW WAREHOUSES LIKE 'PHARMACY2U%';

-- Show schemas
SHOW SCHEMAS IN DATABASE PHARMACY2U_BRONZE;
```

### Verify Data Generation

```sql
-- Check record counts
SELECT 'RAW_PRESCRIPTIONS' AS TABLE_NAME, COUNT(*) AS ROW_COUNT 
FROM PHARMACY2U_BRONZE.RAW_DATA.RAW_PRESCRIPTIONS
UNION ALL
SELECT 'RAW_PATIENTS', COUNT(*) 
FROM PHARMACY2U_BRONZE.RAW_DATA.RAW_PATIENTS
UNION ALL
SELECT 'RAW_MARKETING_EVENTS', COUNT(*) 
FROM PHARMACY2U_BRONZE.RAW_DATA.RAW_MARKETING_EVENTS;

-- Expected results:
-- RAW_PRESCRIPTIONS: ~500,000 rows
-- RAW_PATIENTS: ~100,000 rows
-- RAW_MARKETING_EVENTS: ~1,000,000 rows
```

### Verify Dynamic Tables

```sql
-- Check Dynamic Table status
SELECT 
    table_name,
    target_lag,
    scheduling_state,
    last_suspended_on
FROM PHARMACY2U_SILVER.INFORMATION_SCHEMA.DYNAMIC_TABLES
WHERE table_schema = 'GOVERNED_DATA'
ORDER BY table_name;
```

### Verify Access Policies

```sql
-- Test as ACCOUNTADMIN (should see unmasked data)
USE ROLE ACCOUNTADMIN;
SELECT PATIENT_ID, FIRST_NAME, LAST_NAME, EMAIL, PHONE 
FROM PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS LIMIT 5;

-- Test as BI_USER (should see masked data)
USE ROLE PHARMACY2U_BI_USER;
SELECT PATIENT_ID, FIRST_NAME, LAST_NAME, EMAIL, PHONE 
FROM PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS LIMIT 5;
```

## Troubleshooting

### Connection Issues

**Problem**: `Connection test failed`

**Solution**:
1. Verify account name is correct: `<account>.<region>.<cloud>`
2. Check authentication method (externalbrowser, snowflake, etc.)
3. Ensure network connectivity to Snowflake

### Data Generation Slow

**Problem**: Data generation takes longer than benchmark times

**Solution**:
1. Increase warehouse size temporarily: `ALTER WAREHOUSE PHARMACY2U_LOADING_WH SET WAREHOUSE_SIZE = 'SMALL';`
2. Check network connectivity
3. Monitor warehouse load with `SHOW PARAMETERS IN WAREHOUSE`

### Streamlit App Errors

**Problem**: Streamlit app fails to load or shows errors

**Solution**:
1. Verify `environment.yml` has correct format with `snowflake` channel
2. Check app has `get_active_session()` for native Snowflake deployment
3. Review app logs in Snowsight
4. Ensure warehouse is running: `ALTER WAREHOUSE PHARMACY2U_ANALYTICS_WH RESUME;`

### Permission Errors

**Problem**: `SQL access control error: Insufficient privileges`

**Solution**:
1. Ensure using ACCOUNTADMIN role: `USE ROLE ACCOUNTADMIN;`
2. Grant necessary permissions: `GRANT ALL ON DATABASE PHARMACY2U_DEMO_DB TO ROLE <ROLE_NAME>;`
3. Check role hierarchy and inheritance

## Performance Optimization

### Warehouse Sizing
- **Demo/Analytics**: XSMALL (cost-efficient for demos)
- **Data Loading**: XSMALL initially, can scale to SMALL for bulk loads
- **ML/AI**: XSMALL for demos, scale up for production workloads

### Auto-Suspend Settings
- All warehouses: 60 seconds (balance responsiveness and cost)
- Can increase to 300 seconds for frequently used warehouses

### Query Optimization
- Enable Search Optimization Service for large tables
- Use clustering keys for frequently filtered columns
- Leverage materialized views for complex aggregations

## Cost Management

### Expected Costs (Demo Environment)
- Warehouses: ~$0.50/hour (XSMALL, per-second billing)
- Storage: ~$23/TB/month
- Data transfer: Minimal for demo

### Cost Reduction Tips
1. Suspend warehouses when not in use
2. Use XSMALL warehouses for demos
3. Set auto-suspend to 60 seconds
4. Drop demo environment after completion: `DROP DATABASE PHARMACY2U_DEMO_DB CASCADE;`

## Next Steps

1. Review demo scripts in `sql/demo_scripts/`
2. Practice demo flow and timing
3. Customize for specific customer scenarios
4. Review audience engagement tips in `docs/audience_engagement_tips.md`
