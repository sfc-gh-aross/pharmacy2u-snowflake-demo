# Cortex Search Usage Guide
**Feature**: Semantic Search on Patient 360 Data  
**Status**: ✅ Service Created - Ready to Use  
**Time to Test**: 10 minutes

---

## Overview

**Cortex Search** provides semantic (meaning-based) search capabilities over your Patient 360 data. Unlike traditional keyword search, it understands the *meaning* of your query.

### **What's the Difference?**

| Feature | Cortex Search | Cortex Analyst (Intelligence) |
|---------|--------------|-------------------------------|
| **Purpose** | Semantic search - find *similar* records | Natural language querying - get *answers* |
| **Returns** | Matching patient records | Aggregated insights & metrics |
| **Use Case** | "Find patients like this one" | "How many patients over 65?" |
| **Input** | Descriptive text search | Business questions |
| **Output** | List of relevant patients | Numbers, charts, summaries |

**Both work together**: Intelligence can USE Search under the hood for better results!

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│ PATIENT_360_SEARCHABLE Table                                │
│ • Combined searchable_content column                        │
│ • Patient attributes (age, gender, postcode, etc.)         │
│ • Customer tier & age group segments                        │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ PATIENT_360_SEARCH_SERVICE (Cortex Search)                  │
│ • Indexes: searchable_content                               │
│ • Attributes: 12 filterable columns                         │
│ • Target lag: 1 minute (auto-refresh)                       │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Query Methods:                                              │
│ 1. SQL: SNOWFLAKE.CORTEX.SEARCH_PREVIEW()                  │
│ 2. Integration: Snowflake Intelligence (automatic)         │
│ 3. API: REST endpoint for applications                     │
└─────────────────────────────────────────────────────────────┘
```

---

## Quick Start: SQL Queries

### **Check Service Status** (Do this first!)

```sql
USE ROLE ACCOUNTADMIN;
USE DATABASE PHARMACY2U_GOLD;
USE SCHEMA ANALYTICS;

-- Check if service is ready
SELECT SYSTEM$GET_CORTEX_SEARCH_SERVICE_STATUS('PATIENT_360_SEARCH_SERVICE');
```

**Expected Response**:
- `"READY"` = ✅ Good to go!
- `"INDEXING"` = ⏳ Wait a few minutes
- `"ERROR"` = ❌ Check troubleshooting section

---

### **Basic Search Query**

Once status is `READY`, try this:

```sql
-- Search for high-value patients with multiple prescriptions
SELECT * FROM TABLE(
    SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
        'PATIENT_360_SEARCH_SERVICE',
        'high value patients with multiple prescriptions'
    )
) LIMIT 10;
```

**What You'll See**:
- `PATIENT_ID`: Patient identifier
- `CUSTOMER_TIER`: Bronze/Silver/Gold/Platinum
- `AGE_GROUP`: Age range
- `TOTAL_PRESCRIPTIONS`: Count
- `LIFETIME_VALUE_GBP`: Total value
- **Relevance score**: How well they match your search

---

## 10 Demo-Ready Search Queries

Copy these to demonstrate Cortex Search capabilities:

### **1. Find High-Value Patients**
```sql
SELECT 
    PATIENT_ID,
    CUSTOMER_TIER,
    LIFETIME_VALUE_GBP,
    TOTAL_PRESCRIPTIONS
FROM TABLE(
    SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
        'PATIENT_360_SEARCH_SERVICE',
        'platinum tier high value customers'
    )
) LIMIT 10;
```

**Use Case**: Identify VIP patients for premium services

---

### **2. Search by Demographics**
```sql
SELECT 
    PATIENT_ID,
    AGE_GROUP,
    GENDER,
    POSTCODE,
    TOTAL_PRESCRIPTIONS
FROM TABLE(
    SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
        'PATIENT_360_SEARCH_SERVICE',
        'elderly patients over 65 with chronic prescriptions'
    )
) LIMIT 10;
```

**Use Case**: Target specific age groups for campaigns

---

### **3. Search by Engagement Level**
```sql
SELECT 
    PATIENT_ID,
    MARKETING_INTERACTIONS,
    CAMPAIGN_CONVERSIONS,
    CUSTOMER_TIER
FROM TABLE(
    SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
        'PATIENT_360_SEARCH_SERVICE',
        'patients with high marketing engagement but no conversions'
    )
) LIMIT 10;
```

**Use Case**: Find patients ready to convert

---

### **4. Geographic Search**
```sql
SELECT 
    PATIENT_ID,
    POSTCODE,
    LIFETIME_VALUE_GBP,
    TOTAL_PRESCRIPTIONS
FROM TABLE(
    SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
        'PATIENT_360_SEARCH_SERVICE',
        'patients in london with high prescription volumes'
    )
) LIMIT 10;
```

**Use Case**: Regional market analysis

---

### **5. Multi-Criteria Search**
```sql
SELECT 
    PATIENT_ID,
    AGE_GROUP,
    CUSTOMER_TIER,
    UNIQUE_DRUGS,
    LIFETIME_VALUE_GBP
FROM TABLE(
    SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
        'PATIENT_360_SEARCH_SERVICE',
        'middle aged gold tier patients with multiple medication needs'
    )
) LIMIT 10;
```

**Use Case**: Complex cohort discovery

---

### **6. Find Similar Patients (Advanced)**

First, get a patient's searchable content:
```sql
-- Get reference patient
SELECT searchable_content 
FROM PATIENT_360_SEARCHABLE 
WHERE CUSTOMER_TIER = 'Platinum' 
LIMIT 1;
```

Then search for similar:
```sql
-- Find patients similar to reference
SELECT 
    PATIENT_ID,
    CUSTOMER_TIER,
    LIFETIME_VALUE_GBP,
    TOTAL_PRESCRIPTIONS
FROM TABLE(
    SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
        'PATIENT_360_SEARCH_SERVICE',
        'Patient with 50+ prescriptions Age 65+ high lifetime value platinum tier'
    )
) LIMIT 10;
```

**Use Case**: Look-alike modeling for targeting

---

### **7. Churn Risk Search**
```sql
SELECT 
    PATIENT_ID,
    LAST_PRESCRIPTION_DATE,
    TOTAL_PRESCRIPTIONS,
    MARKETING_INTERACTIONS
FROM TABLE(
    SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
        'PATIENT_360_SEARCH_SERVICE',
        'patients with declining prescription activity'
    )
) LIMIT 10;
```

**Use Case**: Identify at-risk patients

---

### **8. New Patient Opportunities**
```sql
SELECT 
    PATIENT_ID,
    AGE_GROUP,
    TOTAL_PRESCRIPTIONS,
    LIFETIME_VALUE_GBP
FROM TABLE(
    SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
        'PATIENT_360_SEARCH_SERVICE',
        'young patients with low prescriptions but high potential'
    )
) LIMIT 10;
```

**Use Case**: Growth opportunities

---

### **9. Campaign Response Analysis**
```sql
SELECT 
    PATIENT_ID,
    MARKETING_INTERACTIONS,
    CAMPAIGN_CONVERSIONS,
    CUSTOMER_TIER
FROM TABLE(
    SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
        'PATIENT_360_SEARCH_SERVICE',
        'silver tier patients responsive to marketing campaigns'
    )
) LIMIT 10;
```

**Use Case**: Optimize campaign targeting

---

### **10. Combined Filters (Power User)**
```sql
-- Use search WITH traditional SQL filters
SELECT 
    s.PATIENT_ID,
    s.AGE_GROUP,
    s.CUSTOMER_TIER,
    s.LIFETIME_VALUE_GBP,
    s.TOTAL_PRESCRIPTIONS
FROM TABLE(
    SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
        'PATIENT_360_SEARCH_SERVICE',
        'patients with consistent prescription patterns'
    )
) s
WHERE s.LIFETIME_VALUE_GBP > 1000
  AND s.AGE_GROUP IN ('51-65', '65+')
ORDER BY s.LIFETIME_VALUE_GBP DESC
LIMIT 20;
```

**Use Case**: Combine semantic search with precise filters

---

## Advanced Usage: Filters & Options

### **Add Filters to Search**

```sql
-- Search with attribute filters
SELECT * FROM TABLE(
    SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
        'PATIENT_360_SEARCH_SERVICE',
        OPTIONS => {
            'QUERY': 'high value patients',
            'FILTER': {'@eq': {'CUSTOMER_TIER': 'Platinum'}},
            'LIMIT': 10
        }
    )
);
```

### **Filter Syntax Examples**

```sql
-- Equals
'FILTER': {'@eq': {'CUSTOMER_TIER': 'Gold'}}

-- Greater than
'FILTER': {'@gt': {'LIFETIME_VALUE_GBP': 2000}}

-- Less than
'FILTER': {'@lt': {'AGE': 30}}

-- In list
'FILTER': {'@in': {'AGE_GROUP': ['31-50', '51-65']}}

-- Combined filters (AND)
'FILTER': {
    '@and': [
        {'@eq': {'CUSTOMER_TIER': 'Platinum'}},
        {'@gt': {'LIFETIME_VALUE_GBP': 5000}}
    ]
}

-- Combined filters (OR)
'FILTER': {
    '@or': [
        {'@eq': {'CUSTOMER_TIER': 'Gold'}},
        {'@eq': {'CUSTOMER_TIER': 'Platinum'}}
    ]
}
```

---

## Integration with Snowflake Intelligence

### **How They Work Together**

When you ask Snowflake Intelligence a question like:
```
"Find patients similar to our top performers"
```

**Behind the scenes**:
1. Intelligence uses **Cortex Analyst** to understand the question
2. It MAY use **Cortex Search** to find relevant records
3. It generates SQL combining both
4. Returns aggregated insights

### **Why This Matters**

- ✅ Better semantic understanding
- ✅ Faster discovery of relevant cohorts
- ✅ More accurate natural language queries
- ✅ Combined power of search + analytics

### **You Don't Need to Configure Anything**

If Cortex Search service exists in the same database/schema as your semantic model, Intelligence will automatically discover and use it!

**Our Setup** ✅:
- Search Service: `PHARMACY2U_GOLD.ANALYTICS.PATIENT_360_SEARCH_SERVICE`
- Semantic Model: References `PHARMACY2U_GOLD.ANALYTICS.V_PATIENT_360`
- **Same location** = Automatic integration!

---

## Demo Script: Cortex Search

### **Setup** (30 seconds)
```sql
USE ROLE ACCOUNTADMIN;
USE DATABASE PHARMACY2U_GOLD;
USE SCHEMA ANALYTICS;

-- Verify service is ready
SELECT SYSTEM$GET_CORTEX_SEARCH_SERVICE_STATUS('PATIENT_360_SEARCH_SERVICE');
-- Expected: "READY"
```

### **Demo Flow** (3-4 minutes)

**1. Introduce the Capability** (30 seconds)
> "Let me show you Cortex Search - our semantic search engine. Unlike traditional keyword search, it understands *meaning*."

**2. Run Search Query 1** - High Value Patients
```sql
SELECT 
    PATIENT_ID,
    CUSTOMER_TIER,
    LIFETIME_VALUE_GBP,
    TOTAL_PRESCRIPTIONS
FROM TABLE(
    SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
        'PATIENT_360_SEARCH_SERVICE',
        'platinum tier high value customers'
    )
) LIMIT 5;
```

> "I just asked for 'platinum tier high value customers' in plain language. It found exactly that."

**3. Run Search Query 3** - Marketing Engagement
```sql
SELECT 
    PATIENT_ID,
    MARKETING_INTERACTIONS,
    CAMPAIGN_CONVERSIONS,
    CUSTOMER_TIER
FROM TABLE(
    SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
        'PATIENT_360_SEARCH_SERVICE',
        'patients with high marketing engagement but no conversions'
    )
) LIMIT 5;
```

> "Notice I described the *behavior* I wanted to find - high engagement, but no conversions. The search understood that concept."

**4. Show Combined Approach** - Search + SQL
```sql
-- Use search WITH traditional filters
SELECT 
    s.PATIENT_ID,
    s.AGE_GROUP,
    s.CUSTOMER_TIER,
    s.LIFETIME_VALUE_GBP
FROM TABLE(
    SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
        'PATIENT_360_SEARCH_SERVICE',
        'patients with consistent prescription patterns'
    )
) s
WHERE s.LIFETIME_VALUE_GBP > 2000
  AND s.AGE_GROUP = '65+'
LIMIT 10;
```

> "We can combine semantic search with precise SQL filters - best of both worlds."

**5. Wrap-up** (15 seconds)
> "This search service is automatically maintained, stays up-to-date with our data, and powers the Snowflake Intelligence interface you'll see next."

---

## Use Cases by Department

### **Marketing Team**
```sql
-- Find conversion opportunities
'patients highly engaged in campaigns but low conversion rates'

-- Geographic expansion
'high value patients in underserved postcodes'

-- Segment discovery
'middle aged professionals with preventive care needs'
```

### **Clinical Operations**
```sql
-- Adherence monitoring
'patients with irregular prescription refill patterns'

-- High-risk cohorts
'elderly patients with multiple chronic medications'

-- Care coordination
'patients with complex medication regimens'
```

### **Business Analytics**
```sql
-- Revenue opportunities
'silver tier patients showing gold tier behaviors'

-- Retention analysis
'long-term customers with declining engagement'

-- Market analysis
'prescription trends in specific geographic regions'
```

---

## Talking Points for Demo

| What to Say | Why It Matters |
|-------------|----------------|
| "Semantic search, not keyword matching" | Shows AI understanding |
| "Understands meaning, not just words" | Differentiation from traditional search |
| "Automatically refreshed every minute" | No manual index maintenance |
| "Works with your existing data" | No special preparation |
| "Combines with SQL for power users" | Flexibility |
| "Powers Snowflake Intelligence" | Foundation for broader AI |
| "Serverless - no infrastructure to manage" | Operational simplicity |

---

## Troubleshooting

### **Issue**: Service shows "INDEXING" status

**Solution**: Wait 2-5 minutes for initial indexing to complete
```sql
-- Check again
SELECT SYSTEM$GET_CORTEX_SEARCH_SERVICE_STATUS('PATIENT_360_SEARCH_SERVICE');
```

---

### **Issue**: Search returns no results

**Solution 1**: Check service is READY
```sql
SELECT SYSTEM$GET_CORTEX_SEARCH_SERVICE_STATUS('PATIENT_360_SEARCH_SERVICE');
```

**Solution 2**: Verify data exists
```sql
SELECT COUNT(*) FROM PATIENT_360_SEARCHABLE;
-- Should return 100,000
```

**Solution 3**: Try a broader search
```sql
-- Instead of:
'very specific complex multi-criteria search'

-- Try:
'high value patients'
```

---

### **Issue**: Service status returns ERROR

**Solution**: Recreate the service
```sql
-- Drop and recreate
DROP CORTEX SEARCH SERVICE IF EXISTS PATIENT_360_SEARCH_SERVICE;

-- Run the setup script again
-- sql/features/cortex/cortex_search_setup.sql
```

---

### **Issue**: Warehouse suspended

**Solution**: Resume it
```sql
ALTER WAREHOUSE PHARMACY2U_DEMO_WH RESUME;
```

---

## Performance Tips

### **1. Use Filters When Possible**
```sql
-- Good: Narrow search with filters
OPTIONS => {
    'QUERY': 'high engagement',
    'FILTER': {'@eq': {'CUSTOMER_TIER': 'Gold'}},
    'LIMIT': 10
}

-- Less efficient: Broad search, filter in SQL
```

### **2. Limit Results**
```sql
-- Always include LIMIT for interactive queries
) LIMIT 10;  -- Good

) LIMIT 1000;  -- May be slow
```

### **3. Combine Search + Traditional Indexes**
```sql
-- Use indexed columns in WHERE clause after search
WHERE s.PATIENT_ID IN (...)
  AND s.LIFETIME_VALUE_GBP > 1000  -- Fast if indexed
```

---

## Competitive Differentiation

**Cortex Search** vs **Azure Cognitive Search**:

| Feature | Cortex Search | Azure Cognitive Search |
|---------|---------------|------------------------|
| **Setup** | SQL command, done | Provision service, configure indexes, deploy |
| **Data Movement** | None - searches Snowflake data | Must copy data to Azure Search |
| **Maintenance** | Automatic | Manual index management |
| **Security** | Inherits Snowflake policies | Separate security configuration |
| **Cost** | Serverless, pay per query | Fixed index hosting costs |
| **Integration** | Native to platform | External service, API integration |

**Key Message**: "Azure Cognitive Search requires data copying, separate infrastructure, and ongoing index management. Cortex Search works on your data in place, with zero setup beyond a single SQL statement."

---

## Monitoring & Maintenance

### **Check Search Service Health**
```sql
-- Service status
SELECT SYSTEM$GET_CORTEX_SEARCH_SERVICE_STATUS('PATIENT_360_SEARCH_SERVICE');

-- Service details
DESCRIBE CORTEX SEARCH SERVICE PATIENT_360_SEARCH_SERVICE;

-- View all search services
SHOW CORTEX SEARCH SERVICES;
```

### **Refresh Service** (if data changed significantly)
```sql
-- Force refresh (usually not needed - auto-refreshes)
ALTER CORTEX SEARCH SERVICE PATIENT_360_SEARCH_SERVICE REFRESH;
```

### **Monitor Usage**
```sql
-- Check search query history
SELECT 
    USER_NAME,
    QUERY_TEXT,
    START_TIME,
    TOTAL_ELAPSED_TIME
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE QUERY_TEXT ILIKE '%CORTEX.SEARCH%'
ORDER BY START_TIME DESC
LIMIT 20;
```

---

## Quick Reference: Key Commands

```sql
-- Check status
SELECT SYSTEM$GET_CORTEX_SEARCH_SERVICE_STATUS('PATIENT_360_SEARCH_SERVICE');

-- Basic search
SELECT * FROM TABLE(SNOWFLAKE.CORTEX.SEARCH_PREVIEW('PATIENT_360_SEARCH_SERVICE', 'your search query')) LIMIT 10;

-- Search with filters
SELECT * FROM TABLE(SNOWFLAKE.CORTEX.SEARCH_PREVIEW('PATIENT_360_SEARCH_SERVICE', OPTIONS => {'QUERY': 'text', 'FILTER': {...}, 'LIMIT': 10}));

-- Describe service
DESCRIBE CORTEX SEARCH SERVICE PATIENT_360_SEARCH_SERVICE;

-- Refresh service
ALTER CORTEX SEARCH SERVICE PATIENT_360_SEARCH_SERVICE REFRESH;
```

---

## Resources

**Documentation**:
- [Cortex Search Overview](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-search/cortex-search-overview)
- [Cortex Search Query Syntax](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-search/query-cortex-search-service)

**Our Implementation**:
- Setup Script: `sql/features/cortex/cortex_search_setup.sql`
- Search Table: `PHARMACY2U_GOLD.ANALYTICS.PATIENT_360_SEARCHABLE`
- Search Service: `PATIENT_360_SEARCH_SERVICE`

---

## Success Criteria

After testing, you should be able to:

- ✅ Check service status (shows "READY")
- ✅ Run basic search queries
- ✅ Get relevant patient results
- ✅ Combine search with SQL filters
- ✅ Understand how it powers Intelligence
- ✅ Demo search in < 5 minutes

---

**Status**: ✅ Service Created  
**Time to Test**: 10 minutes  
**Demo Impact**: Medium (supports Intelligence, powerful for technical users)  
**Best Used**: As foundation for Intelligence demo, or for power user workflows

---

**Ready to test?** Run the 10 demo queries above and see semantic search in action! 🔍
