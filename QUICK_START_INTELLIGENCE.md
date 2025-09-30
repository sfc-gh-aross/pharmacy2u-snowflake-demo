# ⚡ Quick Start: Snowflake Intelligence UI (30 Minutes)

**Status**: ✅ All prerequisites complete - ready to configure!  
**What You'll Do**: Load semantic model into Intelligence UI and test natural language queries  
**Time Required**: 30 minutes

---

## 🎯 What You're Setting Up

**Snowflake Intelligence** = Natural language interface to query your pharmaceutical data

**What's Already Done** ✅:
- Semantic model created and uploaded
- 100,000 patient records loaded
- Cortex Search service configured
- All demo queries designed and tested

**What You Need to Do** ⏭️:
- Open Intelligence UI (5 min)
- Load semantic model (10 min)
- Test queries (15 min)

---

## 🚀 3-Step Setup

### **STEP 1: Open Intelligence** (5 minutes)

1. **Login to Snowsight**:
   ```
   https://<your-account>.snowflakecomputing.com
   ```
   - Use `ACCOUNTADMIN` role

2. **Navigate to Intelligence**:
   - **Quick Link**: Add `/intelligence` to your URL
     ```
     https://<your-account>.snowflakecomputing.com/intelligence
     ```
   
   - **Or via Menu**: Look for "Intelligence" in left sidebar

3. **Create Workspace**:
   - Click "+ New Workspace"
   - Name: `Pharmacy2U Analytics`
   - Warehouse: `PHARMACY2U_DEMO_WH`
   - Click "Create"

✅ **Checkpoint**: You should see an empty workspace

---

### **STEP 2: Load Semantic Model** (10 minutes)

1. **Click "Add Semantic Model"** or "+ Model"

2. **Select Source**: "From Stage"
   - Database: `PHARMACY2U_GOLD`
   - Schema: `ANALYTICS`
   - Stage: `SEMANTIC_MODELS_STAGE`
   - File: `patient_360_analytics.yaml`

3. **Click "Validate"**
   - Wait 30 seconds
   - Should show: ✅ "Model validated successfully"

4. **Click "Activate"** or "Use This Model"
   - Status changes to "Active" or "Ready"

✅ **Checkpoint**: Model shows as "Active" with green indicator

**ALTERNATIVE** (if stage doesn't work):
- Click "Upload Model"
- Browse to: `config/semantic_models/patient_360_analytics.yaml`
- Upload the 12.5 KB file

---

### **STEP 3: Test Queries** (15 minutes)

Copy these queries **one at a time** into the Intelligence query box:

#### **Query 1** (Warm-up):
```
How many patients do we have?
```
**Expected**: "100,000 patients"

---

#### **Query 2** (Simple analysis):
```
What are the top 5 most prescribed drugs?
```
**Expected**: List of 5 drugs with counts

---

#### **Query 3** (Demographic breakdown):
```
For Atorvastatin, what is the patient age breakdown?
```
**Expected**: Age groups with patient counts

---

#### **Query 4** ⭐ **KEY DEMO MOMENT**:
```
Of patients over 65, how many haven't converted on Heart Health campaign?
```
**Expected**: Patient count + potential revenue impact

**This is your "wow" moment** - actionable business insight in 10 seconds!

---

#### **Query 5** (Geographic analysis):
```
Show me the distribution of high-value patients by region
```
**Expected**: Top regions with patient counts and total value

---

#### **Query 6** (Marketing metrics):
```
What is our overall marketing campaign conversion rate?
```
**Expected**: Conversion percentage with total counts

---

✅ **Checkpoint**: All 6 queries return results

---

## 📸 Take Screenshots

Before you finish, screenshot these for backup:

1. Intelligence workspace with model loaded
2. Query 4 result (the key moment)
3. Any particularly impressive results
4. Save to: `docs/screenshots/`

**Why**: If live demo has issues, use screenshots as backup

---

## ⚠️ Troubleshooting (If Something Breaks)

### **Problem**: Can't find Intelligence menu

**Solution**: 
- Cortex Intelligence might not be enabled
- Contact Snowflake account team to enable
- **Fallback**: Use SQL-based demo queries instead

---

### **Problem**: Model won't validate

**Solution**:
```sql
-- Run this to check:
SELECT * FROM PHARMACY2U_GOLD.ANALYTICS.V_PATIENT_360 LIMIT 10;
```
- If this fails, model can't load
- Check database/schema names match exactly

---

### **Problem**: Queries return no results

**Solution**:
```sql
-- Verify data exists:
SELECT COUNT(*) FROM PHARMACY2U_GOLD.ANALYTICS.V_PATIENT_360;
```
- Should show 100,000
- If not, reload sample data

---

### **Problem**: Query times out

**Solution**:
```sql
-- Increase warehouse size:
ALTER WAREHOUSE PHARMACY2U_DEMO_WH SET WAREHOUSE_SIZE = 'MEDIUM';
ALTER WAREHOUSE PHARMACY2U_DEMO_WH RESUME;
```

---

## 🎬 Demo Day Checklist

**Before Demo** (15 minutes before):
- [ ] Log into Snowsight
- [ ] Open Intelligence workspace
- [ ] Verify model shows "Active"
- [ ] Test Query 1 (quick validation)
- [ ] Have screenshots ready as backup
- [ ] Warehouse is resumed

**During Demo** (3-4 minutes):
- [ ] Introduce: "Let me show you how marketing can ask questions in plain English"
- [ ] Run Query 1-2 (build up)
- [ ] Run Query 4 (KEY MOMENT - pause for impact)
- [ ] Run Query 5-6 (show versatility)
- [ ] Emphasize: "No SQL, no data team, instant insights"

**If Demo Fails**:
- [ ] Use screenshots
- [ ] Explain: "This is what users would see"
- [ ] Show SQL queries as alternative
- [ ] Emphasize the value, not the tech glitch

---

## 💡 Talking Points

**Opening**:
> "This is Snowflake Intelligence - our natural language query interface. Watch how a marketing manager with zero SQL knowledge can get actionable insights in seconds."

**During Query 4** (KEY MOMENT):
> "In 10 seconds, we just identified a specific patient cohort worth potentially millions in revenue. The marketing team can launch a targeted Heart Health campaign TODAY. With traditional BI tools, this analysis would take days and require a data analyst."

**Competitive Edge**:
> "Power BI Q&A requires you to copy data into Power BI, rebuild your semantic model there, and configure separate security. With Snowflake, it's all native - live data, governed access, instant insights."

**Closing**:
> "Every query you saw respects the data masking and access policies we configured earlier. Governance travels with the data automatically."

---

## 📊 Success Metrics

After setup, you should be able to:

- ✅ Ask questions in plain English
- ✅ Get accurate answers in < 10 seconds
- ✅ See SQL that was generated (transparency)
- ✅ Ask follow-up questions (conversational)
- ✅ Save favorite queries
- ✅ Share workspace with team

---

## 🔗 Resources

**Full Instructions**: `docs/SNOWFLAKE_INTELLIGENCE_SETUP.md`  
**Validation Script**: `sql/validate_intelligence_ready.sql`  
**Semantic Model**: `config/semantic_models/patient_360_analytics.yaml`

**Snowflake Docs**:
- [Cortex Analyst Guide](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst)
- [Semantic Models](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst/semantic-model-spec)

---

## ⏱️ Timeline

| Step | Time | 
|------|------|
| Open Intelligence & create workspace | 5 min |
| Load semantic model | 10 min |
| Test all 6 queries | 15 min |
| **TOTAL** | **30 min** |

---

## 🎉 You're Done!

Once all 6 queries return results, you're ready to demo!

**What You've Accomplished**:
- ✅ Configured Snowflake Intelligence
- ✅ Loaded pharmaceutical semantic model
- ✅ Tested natural language queries
- ✅ Validated KEY demo moment (Query 4)
- ✅ Ready to show data democratization

**Next**: Practice the demo flow 2-3 times for timing!

---

**Questions?** See full guide: `docs/SNOWFLAKE_INTELLIGENCE_SETUP.md`  
**Issues?** Run validation: `sql/validate_intelligence_ready.sql`  
**Ready?** You've got this! 🚀

---

**Last Updated**: September 30, 2025  
**Status**: All prerequisites ✅ COMPLETE  
**Estimated Setup Time**: 30 minutes  
**Demo Impact**: 🌟 HIGH - This is Vignette 3's KEY MOMENT!
