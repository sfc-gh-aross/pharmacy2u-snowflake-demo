# Pharmacy2U Demo Execution Guide

## Pre-Demo Checklist

### 24 Hours Before Demo
- [ ] Verify Snowflake account access and credentials
- [ ] Run complete deployment: `python deployment/scripts/deploy_demo_environment.py`
- [ ] Validate all data generated successfully
- [ ] Deploy Streamlit applications
- [ ] Test all demo queries and scripts
- [ ] Rehearse complete demo flow (target: <45 minutes)

### 1 Hour Before Demo
- [ ] Reset demo environment: `snow sql --filename sql/demo_scripts/common/reset_demo.sql`
- [ ] Verify connection: `snow connection test --connection pharmacy2u_demo_connection`
- [ ] Pre-warm warehouses: Resume all warehouses
- [ ] Test Streamlit app URLs are accessible
- [ ] Prepare Snowsight worksheets with demo scripts
- [ ] Confirm screen sharing and presentation setup

### 15 Minutes Before Demo
- [ ] Join meeting and test audio/video
- [ ] Open Snowsight in browser
- [ ] Open Streamlit dashboard in separate tab
- [ ] Have demo scripts ready
- [ ] Clear Snowsight query history for clean slate
- [ ] Take deep breath! 😊

## Demo Flow Structure

### Total Duration: 45 Minutes
- **Vignette 1**: 13 minutes (Fragmentation → Foundation)
- **Vignette 2**: 13 minutes (Building Trust)
- **Vignette 3**: 15 minutes (AI-Powered Future)
- **Q&A Buffer**: 4 minutes

---

## Vignette 1: From Fragmentation to Foundation (13 min)

### Objective
Demonstrate how Snowflake radically simplifies data integration, eliminating SSIS complexity

### Script Location
`sql/demo_scripts/vignette1/`

### Execution Flow

**[0:00-2:00] TELL #1 - Set the Stage**
- "Pharmacy2U's growth through acquisitions is creating a data integration bottleneck"
- "Your team spends 40+ hours/month managing SSIS packages"
- "Each acquisition takes 3-4 months to integrate"
- "Let's show you a better way"

**[2:00-10:00] SHOW - Live Demonstration**

**[2:00-3:00] Create Databases**
```sql
-- Execute: sql/demo_scripts/vignette1/01_data_ingestion.sql
USE ROLE ACCOUNTADMIN;
SHOW DATABASES LIKE 'PHARMACY2U%';
```

**[3:00-5:00] Demonstrate Data Ingestion**
- Show connectors for SQL Server (prescriptions)
- Show connectors for PostgreSQL (patient data)
- Show Snowpipe for JSON marketing events
- Highlight: "One platform, multiple source types, no complex orchestration"

**[5:00-7:00] KEY MOMENT #1 - JSON Querying**
```sql
-- Execute: sql/demo_scripts/vignette1/02_json_querying.sql
-- Query raw JSON with dot notation
SELECT 
    EVENT_DATA:event_id AS event_id,
    EVENT_DATA:patient_id AS patient_id,
    EVENT_DATA:campaign_name AS campaign_name,
    EVENT_DATA:conversion_flag AS conversion
FROM PHARMACY2U_BRONZE.RAW_DATA.RAW_MARKETING_EVENTS
LIMIT 10;
```
- Emphasis: "No complex JSON parsing required - Snowflake handles it natively"
- "This alone saves hours of development time"

**[7:00-10:00] KEY MOMENT #2 - Dynamic Tables**
```sql
-- Execute: sql/demo_scripts/vignette1/03_dynamic_tables.sql
-- Show Dynamic Table definition
SHOW DYNAMIC TABLES IN SCHEMA PHARMACY2U_SILVER.GOVERNED_DATA;

-- Explain the declarative approach
-- "Just define the end state - Snowflake handles orchestration, dependencies, incremental refreshes"
```

**[10:00-11:00] TELL #2 - Reinforce Value**
- "You just saw M&A integration time reduced from months to days"
- "One platform, one copy of data, one skill set (SQL)"
- "25% of your engineering capacity freed up for innovation"
- vs. Fabric: "Multiple services, complex stitching, steep learning curve"

**[11:00-13:00] Transition**
- "Now we have unified data - let's secure and govern it"

---

## Vignette 2: Building Unbreakable Trust (13 min)

### Objective
Demonstrate automated governance, operational resilience, and internal collaboration

### Script Location
`sql/demo_scripts/vignette2/`

### Execution Flow

**[0:00-2:00] TELL #1 - Set the Stage**
- "You're handling highly sensitive patient data (GDPR compliance critical)"
- "P1 incidents every two weeks consuming team resources"
- "Data silos prevent teams from discovering valuable assets"

**[2:00-11:00] SHOW - Live Demonstration**

**[2:00-4:00] KEY MOMENT #1 - Dynamic Data Masking**
```sql
-- Execute: sql/demo_scripts/vignette2/01_governance_setup.sql
-- Show unmasked data as ACCOUNTADMIN
USE ROLE ACCOUNTADMIN;
SELECT PATIENT_ID, FIRST_NAME, LAST_NAME, EMAIL, PHONE, NHS_NUMBER
FROM PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS LIMIT 5;

-- Switch to BI_USER - see masked data
USE ROLE PHARMACY2U_BI_USER;
SELECT PATIENT_ID, FIRST_NAME, LAST_NAME, EMAIL, PHONE, NHS_NUMBER
FROM PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS LIMIT 5;
```
- Emphasis: "Security follows the data, not the query"
- "Impossible for BI users to see PII regardless of how they query"

**[4:00-6:00] Automated Data Classification**
- Show Object Tagging & Data Classification demo
- "Snowflake automatically discovers and classifies sensitive data"

**[6:00-8:00] KEY MOMENT #2 - Time Travel**
```sql
-- Execute: sql/demo_scripts/vignette2/02_time_travel.sql
-- Simulate mistake
UPDATE PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS 
SET EMAIL = NULL WHERE EMAIL IS NOT NULL;

-- Instant recovery with Time Travel
SELECT COUNT(*) FROM PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS AT (OFFSET => -60) WHERE EMAIL IS NOT NULL;

-- Restore data
CREATE OR REPLACE TABLE PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS AS
SELECT * FROM PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS AT (OFFSET => -60);
```
- Emphasis: "P1 incident resolved in 5 minutes, not 5 hours"
- "No backup restoration, no downtime"

**[8:00-10:00] KEY MOMENT #3 - Zero-Copy Cloning**
```sql
-- Execute: sql/demo_scripts/vignette2/03_zero_copy_cloning.sql
CREATE DATABASE PHARMACY2U_DEV_ENV CLONE PHARMACY2U_GOLD;

-- Show instant creation, zero storage cost
SHOW DATABASES LIKE 'PHARMACY2U%';
```
- Emphasis: "Production-scale dev environment in seconds, zero additional cost"

**[10:00-11:00] KEY MOMENT #4 - Internal Marketplace**
- Show pre-configured marketplace listing
- "Data products discoverable across organization"
- "Secure internal data economy"

**[11:00-13:00] TELL #2 - Reinforce Value**
- "Automated governance reduces compliance risk"
- "Time Travel: 10x faster incident resolution"
- "Zero-copy cloning: 10x faster development"
- "Marketplace: breaks down data silos"
- vs. Fabric: "No Time Travel, no zero-copy cloning, no integrated marketplace"

---

## Vignette 3: Powering the Future with AI (15 min)

### Objective
Showcase integrated AI/ML platform with secure data processing and model deployment

### Script Location
`sql/demo_scripts/vignette3/`

### Execution Flow

**[0:00-2:00] TELL #1 - Set the Stage**
- "Mustafa's priority: bring AI/ML in-house with smooth delivery"
- "Challenge: MLOps complexity, data movement security concerns"
- "Vision: agentic chatbot and smart reminders saving millions"

**[2:00-13:00] SHOW - Live Demonstration**

**[2:00-5:00] KEY MOMENT #1 - Natural Language Analytics**
- Open Snowflake Intelligence (Cortex Analyst) UI
- Ask business questions in plain English:
  - "Which are our top 5 most prescribed drugs this year?"
  - "For Atorvastatin, what's the patient age breakdown?"
  - "How many Atorvastatin patients over 65 haven't converted on Heart Health campaign?"
- Emphasis: "From days of SQL work to seconds of natural language"
- "True data democratization for business users"

**[5:00-8:00] AI SQL Functions**
```sql
-- Execute: sql/demo_scripts/vignette3/01_cortex_analyst.sql
-- Show Cortex AI SQL functions for text analysis
SELECT 
    DRUG_NAME,
    SNOWFLAKE.CORTEX.COMPLETE('mixtral-8x7b', 
        'Summarize the key benefits of ' || DRUG_NAME || ' for patients'
    ) AS ai_summary
FROM (SELECT DISTINCT DRUG_NAME FROM PHARMACY2U_SILVER.GOVERNED_DATA.PRESCRIPTIONS LIMIT 3);
```

**[8:00-11:00] KEY MOMENT #2 - ML Model Development**
- Switch to Snowflake Notebook
- Show churn prediction model training using Snowpark
- Deploy model with single command
- Emphasis: "Entire MLOps lifecycle inside Snowflake"
- "No data movement, no security risks"

**[11:00-13:00] KEY MOMENT #3 - Marketplace Productization**
- Show churn scores published to Internal Marketplace
- "Marketing team can now access live predictions"
- "Join with campaign data and take action"
- "Closing the loop from data science to business value"

**[13:00-15:00] TELL #2 - Reinforce Value**
- "Unified approach drastically reduces MLOps complexity"
- "All processing within governance boundary"
- "Internal Marketplace operationalizes AI assets"
- vs. Fabric: "Snowflake delivers fully integrated, serverless AI platform"
- "You're the data scientist, not the systems integrator"

---

## Post-Demo Actions

### Immediate Follow-Up
- Thank attendees for their time
- Ask if questions before transitioning to Q&A
- Capture interested stakeholder names
- Schedule POC discussion with champion

### Within 24 Hours
- Send demo recording link
- Share documentation and setup guides
- Provide POC proposal
- Schedule technical deep-dive with data team

## Tips for Success

### Audience Engagement
- Address stakeholders by name
- Ask rhetorical questions: "Adam, how long would this take in SSIS?"
- Pause for effect after "wow moments"
- Watch for reactions and adjust pace accordingly

### Technical Tips
- Have backup queries ready if demo fails
- Know how to quickly reset if something breaks
- Pre-configure Snowsight worksheets with demo SQL
- Test everything 1 hour before demo

### Time Management
- Keep strict time per vignette
- Use timer visible only to you
- If running long, skip optional sections
- Always leave 4 minutes for Q&A

### Energy and Pacing
- Start with energy and enthusiasm
- Vary tone and pace to maintain engagement
- Use strategic pauses for emphasis
- End each vignette with strong value statement

## Common Questions & Answers

**Q: What about existing Power BI investments?**
A: Snowflake has native Power BI connector with DirectQuery support. Your existing dashboards work seamlessly.

**Q: How does this integrate with our Azure Data Lake?**
A: We demonstrated Snowpipe ingesting from ADLS Gen2. Native integration, no third-party tools needed.

**Q: What about data residency and GDPR?**
A: Snowflake on Azure UK region keeps all data in UK. Dynamic masking ensures GDPR compliance automatically.

**Q: Migration timeline and effort?**
A: POC in 2-3 weeks. Typical migration: 2-3 months vs. 6-12 months for Fabric. Lower risk, faster ROI.

**Q: Cost compared to current architecture?**
A: Per-second billing, automatic suspension, and storage compression typically result in 30-40% cost reduction.

## Emergency Procedures

### If Demo Environment is Down
- Use backup account (maintain separate backup)
- Switch to pre-recorded demo video
- Focus on business value discussion and whiteboarding

### If Network Issues
- Switch to offline slide deck with screenshots
- Emphasize architecture diagrams and business value
- Schedule technical demo for later

### If Query Fails
- Have backup queries ready to copy/paste
- Explain what should happen
- Move to next section smoothly
- "Let me show you the next capability while that completes"

---

Good luck with your demo! 🚀
