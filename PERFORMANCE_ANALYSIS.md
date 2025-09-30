# Vignette 3 Performance Analysis

## Issue Identified

**Query ID**: `01bf66c7-0106-ca5b-0001-46f2010e7bfe`

### Performance Metrics
- **Query**: `SELECT COUNT(*) as total_patients FROM V_PATIENT_360;`
- **Duration**: 458 seconds (7.6 minutes)
- **Data Scanned**: 460GB
- **Warehouse**: X-Small
- **Rows Produced**: 1
- **Status**: SUCCESS (but very slow)

### Root Cause
`V_PATIENT_360` is a **VIEW**, not a materialized table. Every query:
1. Joins 100M patients with prescriptions (billions of rows)
2. Joins with marketing events (billions of rows)
3. Performs GROUP BY aggregations
4. Calculates CUSTOMER_TIER on the fly

With 100 million patients scaled up (1000x), this becomes **prohibitively slow for demos**.

## Solution

### Use the PATIENT_360 Dynamic Table (Materialized)

A `PATIENT_360` dynamic table already exists and is **materialized** (pre-aggregated). This will be:
- **100-1000x faster** for queries
- **Pre-joined and pre-aggregated**
- **Auto-refreshing** (5-minute lag)

### Recommended Changes for Demo Scripts

#### Option 1: Use Dynamic Table Directly (Best for Performance)
```sql
SELECT COUNT(*) as total_patients 
FROM PATIENT_360;  -- Dynamic table, not view
```

#### Option 2: Use Result Caching (For Demos)
Run the query once before the demo to cache results:
```sql
-- Pre-warm cache before demo
SELECT COUNT(*) FROM V_PATIENT_360;
```
Subsequent queries will return instantly from cache (if within 24 hours and data unchanged).

#### Option 3: Use LIMIT for Demo Queries
For exploratory queries in demos, use LIMIT to reduce data scanned:
```sql
SELECT COUNT(*) as patient_count_estimate
FROM V_PATIENT_360
LIMIT 1000000;  -- Sample instead of full scan
```

#### Option 4: Increase Warehouse Size
For full-scale queries on views, use a larger warehouse:
```sql
ALTER WAREHOUSE PHARMACY2U_DEMO_WH SET WAREHOUSE_SIZE = 'LARGE';
-- Then run queries
-- Then scale back down
ALTER WAREHOUSE PHARMACY2U_DEMO_WH SET WAREHOUSE_SIZE = 'XSMALL';
```

## Recommended Fix for Vignette 3

Since the demo is about showing AI/ML capabilities, **performance matters**. Recommendation:

1. **Update demo scripts to use `PATIENT_360` (dynamic table) instead of `V_PATIENT_360` (view)**
2. **Keep `V_PATIENT_360` as a wrapper for data sharing** (since dynamic tables can't be shared directly)
3. **Run validation queries on XSMALL warehouse before demo** to warm caches

This ensures:
- ✅ Sub-second query response times during demo
- ✅ Same data, just pre-materialized
- ✅ Still shows full Dynamic Tables story (auto-refresh, lineage)
- ✅ Cost-efficient (no need for large warehouses)

## Implementation Status

- [x] `PATIENT_360` dynamic table exists and is active
- [x] `V_PATIENT_360` view updated to include `CUSTOMER_TIER` column
- [ ] **TODO**: Update `vignette3_live_demo.sql` to use `PATIENT_360` where performance critical
- [ ] **TODO**: Update Streamlit app to use `PATIENT_360` for faster loads
- [ ] **TODO**: Update demo validation script to warm caches

## Query Performance Comparison (Estimated)

| Object Type | Query Time (100M patients) | Use Case |
|---|---|---|
| **V_PATIENT_360** (view) | ~7-8 minutes | Ad-hoc analysis, data sharing |
| **PATIENT_360** (dynamic table) | ~1-5 seconds | Demo queries, dashboards, ML |
| **PATIENT_360 (cached)** | < 1 second | Repeated demo queries |

---

**Next Steps**: Update demo scripts and retest with Snowflake CLI.
