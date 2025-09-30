# Snowflake Intelligence UI Configuration Guide
**Feature**: Cortex Analyst + Snowflake Intelligence  
**Time Required**: 30 minutes  
**Prerequisites**: Semantic model uploaded to Snowflake stage ✅

---

## Overview

Snowflake Intelligence provides a natural language interface to query your data using the semantic model we created. This guide walks through the UI configuration and testing.

---

## Prerequisites Checklist

Before starting, verify these are complete (all should be ✅):

```sql
-- Run this validation script
USE ROLE ACCOUNTADMIN;
USE DATABASE PHARMACY2U_GOLD;
USE SCHEMA ANALYTICS;

-- Check 1: Semantic model file uploaded
LIST @SEMANTIC_MODELS_STAGE;
-- Expected: patient_360_analytics.yaml (12,560 bytes)

-- Check 2: Base view exists
SELECT COUNT(*) FROM V_PATIENT_360;
-- Expected: 100,000 patients

-- Check 3: Cortex Search service exists
SHOW CORTEX SEARCH SERVICES LIKE 'PATIENT_360_SEARCH_SERVICE';
-- Expected: Service exists

-- All checks passed? Proceed to setup!
```

---

## Step-by-Step Configuration

### **STEP 1: Access Snowflake Intelligence** (2 minutes)

1. **Log into Snowsight**:
   - Open your Snowflake account URL
   - Sign in as `ACCOUNTADMIN` or a role with CORTEX privileges

2. **Navigate to Intelligence**:
   - **Option A**: Direct URL
     ```
     https://<your-account>.snowflakecomputing.com/intelligence
     ```
   
   - **Option B**: Via Menu
     - Click left sidebar menu
     - Look for "Intelligence" or "Cortex" section
     - Click "Snowflake Intelligence"

3. **First-Time Setup** (if prompted):
   - Enable Cortex Intelligence for your account
   - Accept terms and conditions
   - Confirm warehouse selection (use `PHARMACY2U_DEMO_WH`)

---

### **STEP 2: Create Intelligence Workspace** (3 minutes)

1. **Create New Workspace**:
   - Click "+ New Workspace" or "Create Workspace"
   - Name: `Pharmacy2U Analytics`
   - Description: `Patient 360 pharmaceutical analytics - natural language queries`

2. **Select Warehouse**:
   - Warehouse: `PHARMACY2U_DEMO_WH`
   - This is where queries will execute

3. **Configure Settings**:
   - Database: `PHARMACY2U_GOLD`
   - Schema: `ANALYTICS`
   - Click "Create" or "Save"

---

### **STEP 3: Load Semantic Model** (5 minutes)

1. **Add Semantic Model**:
   - In your workspace, click "+ Add Semantic Model" or "Configure Model"
   
2. **Select Model Source**:
   - Choose: "From Stage"
   - Database: `PHARMACY2U_GOLD`
   - Schema: `ANALYTICS`
   - Stage: `SEMANTIC_MODELS_STAGE`
   - File: `patient_360_analytics.yaml`

3. **Validate Model**:
   - Click "Validate" or "Check Model"
   - System will parse the YAML and verify:
     - Table references exist
     - Columns are valid
     - Measures are calculable
   - Expected: ✅ "Model validated successfully"

4. **Activate Model**:
   - Click "Activate" or "Use This Model"
   - Model status should show: "Active" or "Ready"

---

### **ALTERNATIVE: Manual Model Upload** (if stage doesn't work)

If you can't load from stage, upload directly:

1. **Download Model Locally**:
   ```bash
   # From your local machine
   cd /Users/axross/Snowflake/Customers/Pharmacy2U/pharmacy2u-snowflake-demo
   
   # File is at:
   # config/semantic_models/patient_360_analytics.yaml
   ```

2. **Upload via UI**:
   - In Intelligence workspace, click "Upload Model"
   - Browse to: `config/semantic_models/patient_360_analytics.yaml`
   - Upload file (12.5 KB)
   - System will validate automatically

---

### **STEP 4: Test with Sample Queries** (10 minutes)

Once model is loaded, test with these queries in order (simple → complex):

#### **Query 1: Simple Count** (Warm-up)
```
How many patients do we have?
```

**Expected Response**:
- Answer: "100,000 patients"
- May show SQL: `SELECT COUNT(*) FROM __patient_360`

**Talking Point**: "Natural language to SQL - instantly"

---

#### **Query 2: Top N Analysis**
```
What are the top 5 most prescribed drugs this year?
```

**Expected Response**:
- Should reference verified query from semantic model
- Shows: Atorvastatin, Metformin, Amlodipine, Omeprazole, Simvastatin
- With prescription counts

**Talking Point**: "Semantic model provides business context"

---

#### **Query 3: Demographic Breakdown**
```
For Atorvastatin, what is the patient age breakdown?
```

**Expected Response**:
- Age groups: 18-30, 31-50, 51-65, 65+
- Patient counts per group
- May include average lifetime value

**Talking Point**: "Complex queries made simple"

---

#### **Query 4: Complex Filter (KEY MOMENT!)** ⭐
```
Of patients over 65, how many haven't converted on Heart Health campaign?
```

**Expected Response**:
- Count of patients aged 65+
- With marketing interactions > 0
- But campaign conversions = 0
- Shows cohort size and potential revenue

**Talking Point**: "This is the KEY demo moment - identifies actionable cohort in seconds!"

---

#### **Query 5: Business Insight**
```
Show me the distribution of high-value patients by region
```

**Expected Response**:
- Patients with lifetime value > £2000
- Grouped by postcode prefix
- Total value per region
- Top 10 regions

**Talking Point**: "From question to business insight - no SQL required"

---

#### **Query 6: Marketing Analytics**
```
What is our overall marketing campaign conversion rate?
```

**Expected Response**:
- Total marketing interactions
- Total conversions
- Conversion rate percentage

**Talking Point**: "Marketing team gets instant answers"

---

### **STEP 5: Save & Organize Queries** (3 minutes)

1. **Save Favorite Queries**:
   - Click "Save Query" or bookmark icon
   - Name: "Top Prescribed Drugs"
   - Category: "Clinical Analytics"

2. **Create Query Collections**:
   - Marketing Insights
   - Clinical Operations
   - Executive Dashboard Queries

3. **Share with Team** (if available):
   - Click "Share Workspace"
   - Add roles: `PHARMACY2U_DATA_ANALYST`, `PHARMACY2U_BI_USER`
   - They can now ask questions too!

---

### **STEP 6: Demo Preparation** (7 minutes)

1. **Take Screenshots**:
   - Screenshot of each query result (for backup)
   - Save to: `docs/screenshots/`
   - Use if live demo has issues

2. **Test Follow-up Questions**:
   - After asking Query 4, try: "Show me their average age"
   - System should maintain context
   - Demonstrates conversational capability

3. **Practice Timing**:
   - Run through queries 1-6 in sequence
   - Target: 3-4 minutes total
   - This is Key Moment #1 of Vignette 3!

---

## Troubleshooting Guide

### **Issue 1: Model Won't Load**

**Error**: "Cannot find table PATIENT_360"

**Solution**:
```sql
-- Verify view exists
USE ROLE ACCOUNTADMIN;
SELECT COUNT(*) FROM PHARMACY2U_GOLD.ANALYTICS.V_PATIENT_360;

-- If error, check database/schema names in YAML match exactly
```

---

### **Issue 2: Query Returns No Results**

**Error**: "No data found"

**Solution**:
```sql
-- Check data exists
SELECT * FROM PHARMACY2U_GOLD.ANALYTICS.V_PATIENT_360 LIMIT 10;

-- Verify semantic model base_table path:
-- database: PHARMACY2U_GOLD
-- schema: ANALYTICS
-- table: V_PATIENT_360
```

---

### **Issue 3: Model Validation Fails**

**Error**: "Invalid measure definition"

**Solution**:
- Download semantic model from stage
- Check for syntax errors in YAML
- Common issues:
  - Indentation (use spaces, not tabs)
  - Missing required fields (name, expr, data_type)
  - Column names don't match view

---

### **Issue 4: Queries Time Out**

**Error**: "Query timeout"

**Solution**:
```sql
-- Increase warehouse size temporarily
ALTER WAREHOUSE PHARMACY2U_DEMO_WH SET WAREHOUSE_SIZE = 'MEDIUM';

-- Resume warehouse if suspended
ALTER WAREHOUSE PHARMACY2U_DEMO_WH RESUME;
```

---

### **Issue 5: "Intelligence Not Available"**

**Error**: Account doesn't have Intelligence enabled

**Solution**:
- Contact Snowflake account team to enable Cortex Intelligence
- **Fallback for demo**: Show Cortex Analyst API calls via SQL
  ```sql
  -- Alternative: Call Cortex Analyst via SQL
  SELECT SNOWFLAKE.CORTEX.COMPLETE(
      'mixtral-large',
      'Using the patient_360_analytics semantic model, answer: How many patients over 65 have not converted on campaigns?'
  );
  ```

---

## Demo Script for Vignette 3 (Recommended Flow)

### **Intro** (30 seconds)
*"Let me show you how we democratize data access for non-technical users. I'm going to act as a marketing manager who has a business question..."*

### **Demo** (3-4 minutes)

1. **Open Snowflake Intelligence workspace**
   - "This is our Pharmacy2U Analytics workspace"

2. **Ask Query 1** (warm-up)
   - Type: "How many patients do we have?"
   - Show: Natural language → SQL → Result
   - *"100,000 patients - instant answer"*

3. **Ask Query 2** (build complexity)
   - Type: "What are the top 5 most prescribed drugs?"
   - Show: Results
   - *"Atorvastatin is #1 - now let's dig deeper"*

4. **Ask Query 3** (demographic analysis)
   - Type: "For Atorvastatin, what is the patient age breakdown?"
   - Show: Age groups
   - *"Most patients are 51-65, but we also serve 65+"*

5. **Ask Query 4** ⭐ **KEY MOMENT**
   - Type: "Of patients over 65 on Atorvastatin, how many haven't converted on Heart Health campaign?"
   - Show: Result with patient count
   - **Pause for impact**
   - *"In 10 seconds, we identified an actionable cohort worth £XXX. Marketing can launch a campaign TODAY."*

6. **Follow-up** (show context awareness)
   - Type: "What's their average lifetime value?"
   - System uses previous context
   - *"Conversational - no need to repeat the question"*

### **Wrap-up** (30 seconds)
*"From business question to actionable insight - no SQL, no data team dependency. This is true data democratization, and it respects all the governance we set up earlier."*

---

## Talking Points Cheat Sheet

| What to Say | Why It Matters |
|-------------|----------------|
| "Natural language to SQL" | Shows accessibility |
| "Semantic model provides business context" | Not just technical columns |
| "No SQL knowledge required" | Democratization |
| "Respects all governance policies" | Security maintained |
| "From question to insight in seconds" | Time to value |
| "Marketing can do this themselves" | Self-service |
| "Single platform - no external tools" | vs Fabric complexity |

---

## Competitive Differentiation

**Snowflake Intelligence** vs **Power BI Q&A**:

| Feature | Snowflake Intelligence | Power BI Q&A |
|---------|----------------------|--------------|
| **Data Source** | Native to data warehouse | Requires semantic model in Power BI |
| **Setup** | Upload YAML, done | Build Power BI model, publish, configure |
| **Governance** | Inherits all policies | Separate RLS configuration |
| **Scale** | Warehouse compute | Limited by Power BI capacity |
| **Context** | Conversational memory | Single-shot questions |
| **Integration** | Part of platform | Separate BI tool |

**Key Message**: "Power BI Q&A requires data movement to Power BI, separate security setup, and expensive Premium capacity. Snowflake Intelligence works on live data with governance intact."

---

## Success Criteria Checklist

Before considering setup complete, verify:

- [ ] Intelligence workspace created
- [ ] Semantic model loaded and validated
- [ ] All 6 test queries return results
- [ ] Query results match expectations
- [ ] Screenshots taken as backup
- [ ] Demo script practiced and timed
- [ ] Fallback plan documented (use screenshots if live fails)
- [ ] Team members can access workspace (if sharing enabled)

---

## Post-Demo: Enabling for Pharmacy2U Team

After successful demo, help customer enable for their team:

1. **Create User Roles in Intelligence**:
   ```sql
   -- Grant Cortex privileges to analyst roles
   GRANT USAGE ON CORTEX ANALYST TO ROLE PHARMACY2U_DATA_ANALYST;
   GRANT USAGE ON CORTEX ANALYST TO ROLE PHARMACY2U_BI_USER;
   ```

2. **Share Workspace**:
   - Add users to workspace
   - They can start querying immediately

3. **Training** (15 minutes):
   - Show how to ask good questions
   - Demonstrate follow-up questions
   - Share example query library

4. **Measure Adoption**:
   ```sql
   -- Track Intelligence usage
   SELECT 
       USER_NAME,
       COUNT(*) AS queries_run,
       MIN(START_TIME) AS first_query,
       MAX(START_TIME) AS last_query
   FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
   WHERE QUERY_TEXT ILIKE '%CORTEX%ANALYST%'
   GROUP BY USER_NAME;
   ```

---

## Additional Resources

**Snowflake Documentation**:
- [Cortex Analyst Overview](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst)
- [Semantic Model Specification](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst/semantic-model-spec)
- [Snowflake Intelligence User Guide](https://docs.snowflake.com/en/user-guide/ui-snowsight-intelligence)

**Demo Assets**:
- Semantic Model: `config/semantic_models/patient_360_analytics.yaml`
- Sample Queries: Documented in semantic model `verified_queries` section
- Deployment Script: `sql/features/cortex/deploy_cortex_analyst.sql`

---

## Quick Reference: CLI Commands

```bash
# Verify semantic model is uploaded
snow stage list-files @PHARMACY2U_GOLD.ANALYTICS.SEMANTIC_MODELS_STAGE \
  -c pharmacy2u_demo_connection

# Test base view
snow sql -c pharmacy2u_demo_connection \
  -q "SELECT COUNT(*) FROM PHARMACY2U_GOLD.ANALYTICS.V_PATIENT_360"

# Validate Cortex Search service
snow sql -c pharmacy2u_demo_connection \
  -q "SHOW CORTEX SEARCH SERVICES LIKE 'PATIENT_360_SEARCH_SERVICE'"
```

---

## Estimated Timeline

| Task | Time | Status |
|------|------|--------|
| Access Snowflake Intelligence | 2 min | ⏭️ |
| Create workspace | 3 min | ⏭️ |
| Load semantic model | 5 min | ⏭️ |
| Test queries | 10 min | ⏭️ |
| Save & organize | 3 min | ⏭️ |
| Demo preparation | 7 min | ⏭️ |
| **TOTAL** | **30 min** | |

---

**Ready to configure?** Follow the steps above and you'll have Snowflake Intelligence running in 30 minutes! 🚀

**Need help?** All prerequisites are already complete - semantic model uploaded, data loaded, Cortex Search configured. You just need to connect it all in the UI!

---

**Last Updated**: September 30, 2025  
**Status**: Ready for immediate setup  
**Contact**: See Snowflake account team for Intelligence enablement
