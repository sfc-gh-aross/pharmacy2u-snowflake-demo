# Snowflake Notebooks - Implementation Guide
**Feature**: Interactive Data Science Environment  
**Demo**: Pharmacy2U Patient Churn Analysis  
**Vignette**: 3 - Supporting Feature

---

## Overview

Snowflake Notebooks brings Jupyter-style interactive computing directly into Snowflake, enabling data scientists and analysts to:
- Explore and analyze data using Python and SQL
- Create visualizations with familiar libraries (Matplotlib, Plotly, Seaborn)
- Collaborate with teams in real-time
- Version control and share analysis
- Keep all work within Snowflake's governance boundary

---

## Business Value for Pharmacy2U

### Problem Solved:
- **No Data Movement**: Analyze 100K patients without exporting to Azure ML
- **Unified Platform**: Data + Analysis + ML in one governed environment
- **Collaboration**: Share notebooks across data science, marketing, and business teams
- **Security**: PII data never leaves Snowflake's governance

### Use Case:
**Patient Churn Analysis** - Identify £18M+ in revenue at risk from churning patients

---

## Implementation Status

✅ **COMPLETE** - Ready for Demo

**Created**:
1. SQL Demo Script: `sql/demo_scripts/vignette3/01_patient_churn_notebook_demo.sql`
2. Churn Features View: `V_PATIENT_CHURN_FEATURES`
3. Marketing Segments Table: `PATIENT_MARKETING_SEGMENTS`
4. Risk Scores Table: `PATIENT_CHURN_RISK_SCORES`

**Tested via CLI**:
```
✅ Churn analysis features created
✅ 100,000 patients analyzed
✅ 49,830 high-risk patients identified (£18M at risk)
✅ 21,132 medium-risk patients (£10M at risk)
✅ 29,038 low-risk patients (£17M at risk)
✅ Marketing segments created for campaign activation
```

---

## Demo Flow (3-4 minutes)

### Option 1: Show Snowflake Notebooks UI (Recommended)

**If you have access to Snowflake Notebooks**:

1. **Open Snowflake Notebooks**:
   - Navigate to Projects > Notebooks in Snowsight
   - Click "Create Notebook"
   - Select "Python 3.8" kernel
   - Set warehouse to `PHARMACY2U_DEMO_WH`

2. **Create Analysis Cells**:
   ```python
   # Cell 1: Import libraries
   import pandas as pd
   from snowflake.snowpark.functions import col
   
   # Cell 2: Load patient data
   patient_df = session.table("V_PATIENT_CHURN_FEATURES")
   
   # Cell 3: Analyze churn
   churn_stats = patient_df.group_by("VALUE_TIER").agg({
       "CHURN_RISK_FLAG": "sum"
   })
   churn_stats.show()
   ```

3. **Add Visualizations**:
   ```python
   # Cell 4: Visualize churn by tier
   import matplotlib.pyplot as plt
   data = churn_stats.to_pandas()
   plt.bar(data['VALUE_TIER'], data['SUM(CHURN_RISK_FLAG)'])
   plt.title('At-Risk Patients by Customer Tier')
   plt.show()
   ```

4. **Key Talking Points**:
   - "This is Jupyter running natively in Snowflake"
   - "Data never leaves the platform - instant access to 100K patients"
   - "I can share this notebook with marketing for campaign planning"
   - "All changes are versioned and auditable"

---

### Option 2: Run SQL Demo Script (Fallback)

**If Notebooks UI is not available**:

Execute the SQL script that demonstrates the analysis:

```bash
snow sql -f sql/demo_scripts/vignette3/01_patient_churn_notebook_demo.sql
```

**Key Results to Show**:

1. **Overall Churn Rate**:
   - Total patients: 100,000
   - At-risk patients: ~50,000
   - Churn rate: ~50%

2. **Churn by Value Tier**:
   ```
   Platinum: Lower churn, higher value
   Gold:     Moderate churn
   Silver:   Higher churn  
   Bronze:   Highest churn
   ```

3. **Revenue at Risk**:
   - High Risk: £18.2M
   - Medium Risk: £10.2M
   - Total at risk: £28.4M+

4. **Marketing Segments Created**:
   - VIP_RETENTION
   - HIGH_VALUE_WINBACK
   - STANDARD_WINBACK
   - LOW_ENGAGEMENT_ACTIVE
   - VIP_ACTIVE
   - STANDARD_ACTIVE

---

## Analysis Features Created

### 1. Churn Risk Features (View)

**Table**: `V_PATIENT_CHURN_FEATURES`

**Features Engineered**:
- `DAYS_SINCE_LAST_RX` - Recency indicator
- `AVG_PRESCRIPTION_VALUE` - Customer value per order
- `ENGAGEMENT_SCORE` - Marketing responsiveness (%)
- `VALUE_TIER` - Platinum/Gold/Silver/Bronze segmentation
- `AGE_GROUP` - 18-30, 31-50, 51-65, 65+
- `CHURN_RISK_FLAG` - Binary indicator (1=at risk, 0=active)

**Usage**:
```sql
SELECT * FROM V_PATIENT_CHURN_FEATURES 
WHERE CHURN_RISK_FLAG = 1 
  AND LIFETIME_VALUE_GBP > 2000
ORDER BY LIFETIME_VALUE_GBP DESC
LIMIT 20;
```

---

### 2. Marketing Segments (Table)

**Table**: `PATIENT_MARKETING_SEGMENTS`

**Segments**:
1. **VIP_RETENTION** - High-value at-risk (>£2000) - IMMEDIATE ACTION
2. **HIGH_VALUE_WINBACK** - Mid-high value at-risk (>£500)
3. **STANDARD_WINBACK** - Standard value at-risk
4. **LOW_ENGAGEMENT_ACTIVE** - Active but low engagement (<20%)
5. **VIP_ACTIVE** - High-value active customers
6. **STANDARD_ACTIVE** - Regular active customers

**Marketing Usage**:
```sql
-- Get VIP retention list
SELECT PATIENT_ID, LIFETIME_VALUE_GBP, DAYS_SINCE_LAST_RX
FROM PATIENT_MARKETING_SEGMENTS
WHERE MARKETING_SEGMENT = 'VIP_RETENTION'
ORDER BY LIFETIME_VALUE_GBP DESC;

-- Export for campaign tool
SELECT PATIENT_ID, MARKETING_SEGMENT
FROM PATIENT_MARKETING_SEGMENTS
WHERE MARKETING_SEGMENT IN ('VIP_RETENTION', 'HIGH_VALUE_WINBACK');
```

---

### 3. Churn Risk Scores (Table)

**Table**: `PATIENT_CHURN_RISK_SCORES`

**Risk Scoring Model**:
```
Score = (Days Since Last Rx * 0.5) + 
        ((100 - Engagement Score) * 0.3) +
        (Low Frequency Penalty: +20 if <3 prescriptions)

Risk Categories:
- 0-30:  Low Risk
- 30-60: Medium Risk
- 60+:   High Risk
```

**Usage**:
```sql
-- Prioritized retention list
SELECT 
    pcrs.PATIENT_ID,
    pcrs.CHURN_RISK_SCORE,
    pcrs.RISK_CATEGORY,
    p.LIFETIME_VALUE_GBP,
    p.TOTAL_PRESCRIPTIONS
FROM PATIENT_CHURN_RISK_SCORES pcrs
JOIN V_PATIENT_360 p ON pcrs.PATIENT_ID = p.PATIENT_ID
WHERE RISK_CATEGORY = 'High Risk'
  AND p.LIFETIME_VALUE_GBP > 1000
ORDER BY CHURN_RISK_SCORE DESC, p.LIFETIME_VALUE_GBP DESC
LIMIT 100;
```

---

## Business Recommendations

### Immediate Actions (This Week):
1. **VIP Retention Campaign**
   - Target: VIP_RETENTION segment
   - Method: Personalized email + phone outreach
   - Offer: Loyalty discount or free delivery
   - Expected Impact: Save £5M+ in revenue

2. **High-Value Winback**
   - Target: HIGH_VALUE_WINBACK segment  
   - Method: Automated email series
   - Offer: Special promotions
   - Expected Impact: Recover 20-30% of at-risk patients

3. **Top 100 Outreach**
   - Target: Highest-value at-risk patients
   - Method: Direct call center contact
   - Offer: Concierge service
   - Expected Impact: High conversion rate

### This Month:
4. Implement 60-day inactivity alerts
5. Create 3-part re-engagement email series
6. Enhance personalization using engagement scores

### This Quarter:
7. Build predictive ML model (XGBoost/Random Forest)
8. Integrate churn scores into CRM system
9. Develop automated retention workflows

---

## Competitive Differentiation vs Microsoft Fabric

| Capability | Snowflake Notebooks | Microsoft Fabric |
|------------|-------------------|------------------|
| **Data Movement** | ✅ None required | ❌ Must export to Azure ML |
| **Governance** | ✅ Unified with data platform | ⚠️ Separate Azure ML security |
| **Collaboration** | ✅ Built-in sharing | ⚠️ Requires Azure DevOps setup |
| **Cost** | ✅ Pay for compute only | ⚠️ Multiple service costs |
| **Setup** | ✅ Click "Create Notebook" | ⚠️ Configure multiple Azure services |

**Key Message**: "With Snowflake, your data scientists work directly on the data, with zero setup time and complete governance"

---

## Technical Details

### Snowpark Integration

Snowflake Notebooks uses Snowpark for Python, enabling:
- Lazy evaluation of transformations
- Pushdown to Snowflake compute
- DataFrame API similar to pandas/PySpark
- Seamless transition from exploration to production

**Example**:
```python
# All processing happens in Snowflake, not locally
from snowflake.snowpark.functions import col, sum as sum_

churn_by_tier = patient_df.group_by("VALUE_TIER").agg([
    sum_(col("CHURN_RISK_FLAG")).alias("at_risk_count"),
    sum_(col("LIFETIME_VALUE_GBP")).alias("total_value")
])

# Convert to pandas only for visualization
chart_data = churn_by_tier.to_pandas()
```

### Visualization Libraries Supported

- **Matplotlib**: Static charts (bar, line, scatter, pie)
- **Seaborn**: Statistical visualizations
- **Plotly**: Interactive dashboards
- **Altair**: Declarative visualizations

### Version Control & Collaboration

- **Built-in Versioning**: Auto-save and history
- **Sharing**: Share notebooks with roles/users
- **Comments**: Collaborative annotations
- **Export**: Download as .ipynb for Git

---

## Next Steps for Production ML

After this exploratory analysis, the next steps would be:

1. **Feature Engineering Pipeline**:
   - Automate feature calculation
   - Store features in Feature Store
   - Version features for model reproducibility

2. **Model Training**:
   - Use Snowpark ML for training
   - Try XGBoost, Random Forest, Neural Networks
   - Hyperparameter tuning with cross-validation

3. **Model Deployment**:
   - Deploy as Snowflake UDF
   - Batch scoring daily
   - Real-time scoring via Streamlit app

4. **Monitoring**:
   - Track model performance
   - Monitor data drift
   - Retrain on schedule

---

## Demo Script Checklist

**Pre-Demo**:
- [ ] Verify `V_PATIENT_360` has data
- [ ] Test SQL script runs successfully
- [ ] Take screenshots of expected results (fallback)
- [ ] Practice timing (3-4 minutes)

**During Demo**:
- [ ] Show business context first (patient retention challenge)
- [ ] Execute analysis (either Notebook UI or SQL)
- [ ] Highlight key insights (£18M at risk)
- [ ] Show actionable outputs (marketing segments table)
- [ ] Emphasize "no data movement" message

**Key Talking Points**:
1. "Jupyter running natively in Snowflake"
2. "100K patient records analyzed instantly"
3. "£28M+ in revenue at risk identified"
4. "Marketing can now act on these segments today"
5. "All governed by Snowflake's security - no data exports"

---

## Resources

**Created Tables** (Available for Marketing):
- `PATIENT_MARKETING_SEGMENTS` - Campaign targeting
- `PATIENT_CHURN_RISK_SCORES` - Prioritization

**Views** (For Further Analysis):
- `V_PATIENT_CHURN_FEATURES` - All engineered features

**Documentation**:
- This guide
- SQL demo script with comments
- Jupyter notebook template (in `notebooks/` directory)

---

**Status**: ✅ **COMPLETE & TESTED**  
**Demo Ready**: YES  
**Business Impact**: £28M+ revenue at risk identified and segmented for action
