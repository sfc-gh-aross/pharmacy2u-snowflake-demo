# Pharmacy2U Snowflake Demo

## Executive Summary
This demonstration showcases how Snowflake solves Pharmacy2U's critical data fragmentation and scalability challenges, enabling a foundation of trusted, governed data to power accelerated BI, self-service analytics, internal data collaboration, and future-state AI applications.

## Business Context
- **Industry**: UK Online Pharmacy & Healthcare
- **Challenge**: Data fragmentation across SQL Server, PostgreSQL, and MariaDB systems creating scalability bottlenecks
- **Solution**: Snowflake as unified platform for data unification, automated governance, and AI/ML capabilities
- **Demo Duration**: 45 minutes (3 value vignettes)

## Demo Value Vignettes

### Vignette 1: From Fragmentation to Foundation (13 min)
**Core Message**: Snowflake radically simplifies and accelerates the integration of diverse data sources, eliminating SSIS maintenance overhead

**Key Moments**:
- JSON dot notation querying (min 6-7)
- Dynamic Tables declarative ELT (min 10-11)
- External data enrichment via Marketplace (min 12)

### Vignette 2: Building Unbreakable Trust (13 min)
**Core Message**: Built-in automated governance creates foundation of trust and agility for lean teams

**Key Moments**:
- Dynamic data masking (min 3-4)
- Automated data classification (min 5-6)
- Time Travel P1 recovery (min 7-8)
- Zero-copy cloning (min 10-11)
- Internal marketplace (min 12-13)

### Vignette 3: Powering the Future with AI (15 min)
**Core Message**: Secure, unified environment for building, deploying, and sharing AI/ML without data movement

**Key Moments**:
- Natural language analytics (min 4-5)
- AI SQL functions for text analysis (min 7-8)
- ML model deployment (min 9-10)
- Marketplace productization (min 13-14)

## Project Structure
```
pharmacy2u-snowflake-demo/
├── config/                    # Environment and feature configurations
├── sql/                       # SQL scripts for setup, features, and demo flow
├── src/                       # Python code and Streamlit applications
├── notebooks/                 # Jupyter notebooks for data generation and exploration
├── data/                      # Synthetic data and schemas
├── deployment/                # Deployment automation scripts
└── docs/                      # Technical documentation
```

## Quick Start

### Prerequisites
- Snowflake account (Enterprise edition or higher on Azure)
- Snowflake CLI installed (`snow` command)
- Python 3.9+ with pip
- Network connectivity to Azure data sources

### Setup Instructions

1. **Install Dependencies**
```bash
pip install -r requirements.txt
```

2. **Configure Snowflake Connection**
```bash
# Create dedicated demo connection
snow connection add --connection-name pharmacy2u_demo_connection \
  --account <YOUR_ACCOUNT> \
  --user <YOUR_USER> \
  --role ACCOUNTADMIN \
  --database PHARMACY2U_DEMO_DB \
  --schema DEMO_SCHEMA \
  --warehouse PHARMACY2U_DEMO_WH

# Set as default
snow connection set-default pharmacy2u_demo_connection
```

3. **Deploy Demo Environment**
```bash
# Run deployment script
python deployment/scripts/deploy_demo_environment.py

# Verify deployment
python deployment/scripts/validate_deployment.py
```

4. **Generate Synthetic Data**
```bash
# Generate pharmaceutical data (prescriptions, patients, marketing events)
python src/python/data_generation/prescription_generator.py
python src/python/data_generation/patient_generator.py
python src/python/data_generation/marketing_events_generator.py
```

5. **Deploy Streamlit Applications**
```bash
python deployment/scripts/deploy_streamlit_apps.py
```

## Demo Execution Guide

### Pre-Demo Checklist
- [ ] All data generated and loaded (verify with `sql/data_generation/data_validation.sql`)
- [ ] Streamlit apps deployed and accessible
- [ ] Demo connection tested (`snow connection test`)
- [ ] Semantic models configured for Cortex Analyst
- [ ] Marketplace listings prepared
- [ ] Demo timing rehearsed (<45 minutes total)

### Demo Flow
1. Run `sql/demo_scripts/common/reset_demo.sql` to ensure clean state
2. Execute Vignette 1 scripts in sequence
3. Execute Vignette 2 scripts in sequence
4. Execute Vignette 3 scripts in sequence
5. Use Streamlit apps for interactive dashboard demonstrations

## Data Architecture

### Medallion Architecture
- **BRONZE**: Raw data from SQL Server, PostgreSQL, and ADLS Gen2 JSON files
- **SILVER**: Cleaned, governed, and enriched data with data quality rules
- **GOLD**: Analytics-ready Patient 360 views and ML-optimized datasets

### Synthetic Data Volumes
- Prescriptions: 500K+ records (SQL Server simulation)
- Patients: 100K+ records (PostgreSQL simulation)
- Marketing Events: 1M+ JSON records (ADLS Gen2 simulation)

## Key Features Demonstrated

### P0 Features (Core Functionality)
- Connectors & Drivers, Snowpipe, Unstructured Data Handling
- Dynamic Tables, Iceberg Tables, Access Policies
- RBAC, Time Travel, Zero-Copy Cloning
- Organizational Listings, Cortex Analyst, Cortex Search
- Snowflake Intelligence, Snowpark, Streamlit in Snowflake

### P1 Features (Enhanced Value)
- Snowflake Marketplace, Object Tagging & Data Classification
- Access History & Lineage, Snowflake Notebooks
- Virtual Warehouses (elastic scaling)

### P2 Features (Supporting Capabilities)
- Cortex AI SQL Functions, Search Optimization Service
- Secure Data Sharing, Cost Management & Budgets
- Alerts & Notifications

## Troubleshooting

### Common Issues
1. **Connection Failures**: Verify `pharmacy2u_demo_connection` exists and credentials are correct
2. **Data Generation Slow**: Increase warehouse size temporarily for bulk loading
3. **Streamlit App Errors**: Ensure `environment.yml` is properly formatted with snowflake channel
4. **Time Travel Queries Fail**: Check retention period settings on tables

### Support Resources
- Technical Setup: `docs/technical_setup.md`
- Troubleshooting Guide: `docs/troubleshooting.md`
- Audience Engagement Tips: `docs/audience_engagement_tips.md`

## Performance Benchmarks
- Snowpark data generation: 1M+ records in <5 minutes
- SQL data generation: 100K+ records in <2 minutes
- Local Python generation: 500K+ marketing events in <3 minutes
- Query performance: Sub-second responses on GOLD layer tables

## Cost Optimization
- All warehouses default to XSMALL (cost-efficient)
- Auto-suspend set to 60 seconds maximum
- Single cluster scaling for demo workloads
- Per-second billing for elastic scaling demonstrations

## Authors & Contributors
- **Demo Architect**: Snowflake Solutions Engineering
- **Customer**: Pharmacy2U
- **Industry Vertical**: Healthcare & Pharmaceutical

## License
Internal Snowflake demonstration use only. Not for distribution outside Snowflake organization.
