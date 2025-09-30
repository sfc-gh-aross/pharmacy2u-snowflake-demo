# Vignette 1 Demo Script
**Title**: From Fragmentation to Foundation: Unifying Data with Automated ELT  
**Duration**: 13-15 minutes  
**Audience**: Data Architect (Miles Hewitt), Head of Engineering (Adam Young)

---

## Pre-Demo Setup (2 minutes before)

### Browser Tabs to Open:
- [ ] **Tab 1**: Snowsight Home (logged in as ACCOUNTADMIN)
- [ ] **Tab 2**: Worksheets - Open blank worksheet for live SQL execution
- [ ] **Tab 3**: Data → Databases (ready to show BRONZE/SILVER/GOLD)
- [ ] **Tab 4**: Data → PHARMACY2U_SILVER → GOVERNED_DATA → PATIENTS (Dynamic Table view)
- [ ] **Tab 5**: This demo script for reference

### Additional Windows:
- [ ] **Power BI Desktop**: Patient 360 dashboard open and connected to Snowflake

### Validation Checks:
- [ ] Warehouse `PHARMACY2U_DEMO_WH` is RUNNING
- [ ] All databases exist: PHARMACY2U_BRONZE, PHARMACY2U_SILVER, PHARMACY2U_GOLD
- [ ] Patient count: `SELECT COUNT(*) FROM PHARMACY2U_GOLD.ANALYTICS.V_PATIENT_360` returns 100,000
- [ ] Dynamic Tables are ACTIVE (check status)
- [ ] **Power BI Dashboard**: Patient 360 dashboard open and connected

### Physical Setup:
- [ ] Screen sharing ready (Snowsight UI)
- [ ] Second monitor with this script visible
- [ ] Water nearby
- [ ] Confident and ready! 💪

---

## TELL #1 - Set the Stage (2 minutes)

### Business Context (45 seconds)

> "Good morning everyone. Let's start by addressing your most pressing data challenge: **fragmentation**.
> 
> Pharmacy2U's growth through acquisition has been phenomenal—you're now processing 500,000+ orders daily. But this success has outpaced your data architecture. You have prescription data in SQL Server, patient information from acquisitions sitting in PostgreSQL and MariaDB, and marketing events scattered across JSON files in Azure Data Lake.
>
> Miles, your team is spending a disproportionate amount of time just trying to stitch these sources together, aren't they?"

**[Pause for acknowledgment]**

---

### Quantified Problem (45 seconds)

> "Let me put some numbers to this pain:
> 
> - **Integration time**: Each new acquisition takes 3-4 months to fully integrate into your central reporting
> - **SSIS overhead**: Your lean engineering team spends an estimated 40 hours per month managing and firefighting SSIS package failures
> - **P1 incidents**: You're dealing with a data platform incident every two weeks
> - **Analyst capacity**: Your analysts spend 60% of their time on data plumbing instead of delivering insights
>
> This fragmentation isn't just a technical problem—it's a business blocker. Every day data stays siloed is a day you can't get a unified view of patient behavior, can't optimize cross-sell opportunities, and can't make fast, data-driven decisions."

---

### Success Vision (30 seconds)

> "Here's what success looks like: In the next 13 minutes, I'm going to show you how Snowflake turns this multi-month, multi-system integration nightmare into a **same-day win**.
>
> We're going to ingest data from SQL Server, PostgreSQL, and JSON files, transform it all through automated pipelines, and land it in an analytics-ready Patient 360 view—all within a single, unified platform. No SSIS. No orchestration complexity. No Friday afternoon firefighting.
>
> Let me show you how we do it."

---

## SHOW - Live Demonstration (9 minutes)

### Demo Point 1: The Foundation - Medallion Architecture (2 minutes)

**Navigation**: Data → Databases

**Action**: Show the three-tier architecture visually

> "First, let me show you the foundation. We've implemented what's called a **Medallion Architecture**—three layers that organize data from raw to analytics-ready."

**Point to each database in the UI:**

1. **PHARMACY2U_BRONZE** (Raw layer)
   > "BRONZE is where we land raw data exactly as it comes from source systems. No transformations yet—just a perfect historical record."

2. **PHARMACY2U_SILVER** (Governed layer)
   > "SILVER is where the magic happens—cleaned, joined, and governed data. This is where your SSIS logic lives today, but automated."

3. **PHARMACY2U_GOLD** (Analytics layer)
   > "GOLD is analytics-ready. This is what your BI users, data scientists, and executives consume. Patient 360 views, aggregated metrics, ready to query."

**Talking point:**
> "Three layers. One platform. One copy of data. Compare this to Microsoft Fabric, where you'd need Data Factory for ingestion, different engines for different data types, separate governance configuration, and constant capacity management. We keep it simple."

**Timing checkpoint**: 2 minutes elapsed

---

### Demo Point 2: Querying Semi-Structured JSON Natively (2 minutes)

**Navigation**: Worksheets → New Query

**Action**: Execute query on JSON data

**Script reference**: Use query from `sql/setup/03_load_bronze_data.sql` (marketing events section)

**Type in worksheet:**
```sql
-- Show raw JSON marketing events
SELECT * FROM PHARMACY2U_BRONZE.RAW_DATA.MARKETING_EVENTS LIMIT 10;
```

**Run query, then point to results:**

> "Look at this. We just ingested raw JSON marketing events from Azure Data Lake—campaign IDs, interaction timestamps, nested engagement data. **We're querying it directly as if it were a structured table.**"

**Scroll through the JSON columns, then run second query:**

```sql
-- Parse nested JSON using dot notation
SELECT 
    patient_id,
    campaign_id,
    interaction_timestamp,
    engagement_data:channel::STRING as channel,
    engagement_data:device::STRING as device,
    engagement_data:duration_seconds::INT as duration
FROM PHARMACY2U_BRONZE.RAW_DATA.MARKETING_EVENTS
LIMIT 10;
```

**Point to the dot notation parsing:**

> "**KEY MOMENT #1**: Notice the syntax—`engagement_data:channel`. That's Snowflake's native JSON parsing. No ETL preprocessing. No flattening scripts. No complex SSIS transformations.
>
> Adam, with SSIS, how long would it take to build the logic to parse nested JSON, handle schema evolution, and deploy it to production?"

**[Wait for response]**

> "Exactly. Days to weeks. Here, it's a SELECT statement. This is what we mean by 'schema-on-read'—flexibility to query without rigid preprocessing."

**Competitive wedge:**
> "In Microsoft Fabric, you'd use Azure Data Factory to parse this JSON, probably write custom Python or mapping logic, deploy it, test it, and hope it doesn't break when the JSON schema changes. Snowflake handles it natively."

**Timing checkpoint**: 4 minutes elapsed

---

### Demo Point 3: Dynamic Tables - Automated ELT Pipelines (3 minutes)

**Navigation**: Data → PHARMACY2U_SILVER → GOVERNED_DATA → Tables → PATIENTS

**Action**: Click on the PATIENTS table to show its definition

**Point to the Dynamic Table badge/indicator:**

> "This is the centerpiece of our automation story: **Dynamic Tables**. This isn't just a table—it's a fully managed, incremental, automated ELT pipeline."

**Click "Definition" or "DDL" tab to show the SQL (don't read it out, just point):**

> "Here's the beauty: this is just a SQL SELECT statement. We define the **end state**—what we want the data to look like. Snowflake handles everything else:
> - Orchestration of dependencies
> - Incremental refreshes (only processing new/changed data)
> - Error handling and retries
> - Monitoring and observability
>
> **No DAGs. No Airflow. No SSIS packages to manage.**"

**Click "Details" or "History" tab:**

> "Look at the refresh history. This pipeline is running automatically, staying fresh, and we never wrote a single line of orchestration code."

**Navigate**: Worksheets → Run a query on the Dynamic Table

```sql
-- Show the result of automated transformation
SELECT 
    PATIENT_ID,
    FIRST_NAME,
    LAST_NAME,
    AGE,
    POSTCODE,
    REGISTRATION_DATE,
    TOTAL_LIFETIME_ORDERS
FROM PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS
LIMIT 10;
```

**Point to the results:**

> "This data came from PostgreSQL acquisitions, was joined with SQL Server prescription history, enriched with marketing events from JSON files, and automatically refreshed every hour. **This is your SSIS replacement, defined in declarative SQL.**"

**Audience engagement:**
> "Adam, imagine one of your acquisition databases adds a new column tomorrow. With SSIS, you'd modify the package, redeploy, hope you didn't break dependencies, and spend hours testing.
>
> Here? We update the SELECT statement. Snowflake handles the rest. **That's the difference between imperative orchestration and declarative transformation.**"

**Competitive wedge:**
> "In Fabric, you'd use Data Factory for orchestration, Dataflow Gen2 for transformations, and Power Query for individual pipelines—each with separate management. Dynamic Tables are one feature, one platform, one simple model."

**Timing checkpoint**: 7 minutes elapsed

---

### Demo Point 4: The Patient 360 View - Analytics-Ready Data (2 minutes)

**Navigation**: Data → PHARMACY2U_GOLD → ANALYTICS → Views → V_PATIENT_360

**Action**: Click the view, show preview tab

> "This is the culmination: **V_PATIENT_360**—a complete view of every patient across all data sources."

**Scroll through the columns:**

> "Patient demographics from PostgreSQL, prescription history from SQL Server, marketing engagement from JSON events, lifetime value calculations—all joined, all governed, all analytics-ready."

**Run a quick query:**

```sql
-- Show 360-degree patient view
SELECT 
    PATIENT_ID,
    AGE,
    GENDER,
    TOTAL_PRESCRIPTIONS,
    UNIQUE_DRUGS,
    LIFETIME_VALUE_GBP,
    MARKETING_INTERACTIONS,
    CAMPAIGN_CONVERSIONS
FROM PHARMACY2U_GOLD.ANALYTICS.V_PATIENT_360
WHERE LIFETIME_VALUE_GBP > 2000
ORDER BY LIFETIME_VALUE_GBP DESC
LIMIT 10;
```

**Point to results:**

> "These are your high-value patients. This query ran in milliseconds against 100,000 patient records. And this view is what powers everything else you'll see today—BI dashboards, AI analytics, self-service queries."

**KEY MOMENT #2 - Drive this home:**
> "**Let's recap what we just did:**
> - Ingested from SQL Server, PostgreSQL, and JSON files
> - Transformed with automated Dynamic Tables
> - Created an analytics-ready Patient 360 view
> - All in ONE platform, ONE copy of data, using ONE skill: SQL
>
> **Time to build**: What would be 3-4 months with SSIS is now **same-day deployment**."

**Timing checkpoint**: 9 minutes elapsed

---

### Demo Point 5: Power BI DirectQuery - BI Tool Integration (1.5 minutes)

**Pre-requisite**: Have Power BI Desktop open with connected Patient 360 dashboard

**Navigation**: Switch to Power BI Desktop window

**Setup:**

> "One final point before we move on: **integration with your existing BI tools**. You mentioned you're evaluating Power BI, and many of your teams use Tableau and other BI platforms.
>
> Here's how Snowflake connects—using Power BI as the example."

**Action**: Show the Power BI dashboard (pre-built)

**Point to the dashboard:**

> "This is Power BI Desktop connected directly to our Patient 360 view via **DirectQuery**. Let me show you what that means."

**Refresh the dashboard or filter it:**

> "Every visual here is querying Snowflake in real-time. There's no data copy, no extract-refresh cycle. When I filter to show only high-value patients or change the date range, Power BI sends the query to Snowflake, and results come back instantly."

**Click on "Edit Queries" or show connection details:**

> "The connection setup is simple—Snowflake ODBC driver, authentication via SSO or username/password, and you're connected. Power BI sees the GOLD layer views just like any other database."

**Talking points:**

> "This addresses a key concern: **you don't have to abandon your existing BI investments**. Your Power BI dashboards, Tableau workbooks, even Excel users—they all connect to Snowflake natively.
>
> The difference from Microsoft Fabric:
> - **Fabric**: Power BI Premium required (£4,995/month minimum), data must be in Fabric workspace
> - **Snowflake**: Works with ANY version of Power BI, even free Desktop. DirectQuery means no data duplication, always current data.
>
> Your BI teams get the tools they're comfortable with, powered by the unified, governed data we just built."

**Competitive wedge:**

> "Microsoft wants to lock you into Power BI Premium and Fabric capacity. Snowflake works with Power BI, Tableau, Looker, Excel—whatever your teams prefer. **No vendor lock-in, just open standards.**"

**Optional - Show query sent to Snowflake:**

**Navigate back to Snowsight → Query History**

> "And here's the beautiful part—every query Power BI runs shows up in our Snowflake query history. Full observability, cost tracking, performance optimization—all in one place."

**Timing checkpoint**: 10.5 minutes elapsed

---

### Demo Point 6: Query Performance & Observability (1.5 minutes)

**Navigation**: Activity → Query History

**Action**: Show the queries we just ran

> "One more thing before we move on: **observability**. Every query, every transformation, every data movement is tracked, logged, and auditable."

**Click on one of the recent queries to show details:**

> "Here's the query we just ran—execution time, rows processed, compute used, even a visual query profile showing how Snowflake optimized it. Your team gets full transparency into what's happening, no black boxes."

**Point to the query profile visualization:**

> "This level of observability is built-in. You're not troubleshooting SSIS package failures at 5 PM on Friday anymore. You have clear visibility into what's working and what needs attention."

**Optional - Show Virtual Warehouse if time permits:**

**Navigation**: Admin → Warehouses → PHARMACY2U_DEMO_WH

> "And here's the compute that powered everything—our virtual warehouse. Notice it scales up and down instantly, bills by the second, and we can have multiple warehouses for different workloads. Your BI users, data scientists, and ETL pipelines never compete for resources."

**Timing checkpoint**: 12 minutes elapsed

---

## TELL #2 - Reinforce Value (3 minutes)

### Business Impact Summary (90 seconds)

> "Let me summarize what you just saw and what it means for Pharmacy2U's business:
>
> **Time to Value**:
> - Acquisition integration: **3-4 months → same-day deployment**
> - New data source onboarding: **weeks → hours**
> - Schema changes: **days of testing → SQL update**
>
> **Operational Efficiency**:
> - SSIS management overhead: **40 hours/month → near zero**
> - P1 incidents from pipeline failures: **every 2 weeks → rare exceptions**
> - Engineering capacity freed: **25-30% of team time back for innovation**
>
> **Cost Optimization**:
> - No vertical SQL Server scaling: **Avoiding £36k+ annual jumps**
> - Elastic compute: **Pay only when processing, scale to zero when idle**
> - Unified platform: **Eliminate separate integration tools and licensing**
>
> **Strategic Enablement**:
> - M&A velocity: **Data integration no longer a bottleneck**
> - Data trust: **Single source of truth in Patient 360 view**
> - Foundation for AI: **Clean, governed, analytics-ready data**"

---

### Competitive Differentiation vs Microsoft Fabric (60 seconds)

> "I know Microsoft Fabric is in the conversation, so let me be direct about the differences:
>
> **What we just showed: ONE Snowflake platform**
> - One ingestion method (Snowpipe, Connectors)
> - One transformation approach (Dynamic Tables)
> - One governance layer (unified)
> - One skill set required (SQL)
> - One place to monitor (Snowsight)
>
> **Microsoft Fabric equivalent: FIVE separate services**
> - Azure Data Factory for ingestion (separate tool)
> - Dataflow Gen2 for transformations (separate engine)
> - Synapse Pipelines for orchestration (separate orchestrator)
> - OneLake for storage (separate layer with manual capacity management)
> - Fabric Capacity Units to manage (complex pricing, pre-purchased)
>
> **The operational difference**:
> - Snowflake: Your team learns **one platform**
> - Fabric: Your team becomes a **systems integrator** stitching Microsoft services together
>
> **The cost difference**:
> - Snowflake: **Pay per second of compute used**
> - Fabric: **Pre-purchase F64 capacity at £5,000+/month minimum**, manage capacity units constantly
>
> You need a data platform that accelerates your business, not one that makes your team manage infrastructure. We give you **simplicity, automation, and unified governance**."

---

### Transition to Vignette 2 (30 seconds)

> "So we've built this unified data foundation—Patient 360 data from fragmented sources, automated pipelines, analytics-ready views. **But foundation isn't enough.**
>
> You're handling highly sensitive patient data under strict GDPR requirements. Your lean team needs confidence that mistakes are reversible. Your business units need to discover and access this valuable data asset—turning these Patient 360 views into discoverable data products.
>
> In the next 15 minutes, let me show you how Snowflake makes this foundation **unbreakable and discoverable** through automated governance, operational resilience, and a real internal marketplace for secure collaboration.
>
> We're going to turn potential risk into competitive advantage."

**[Pause, take a sip of water, proceed to Vignette 2]**

---

## Backup Plan (If Live Demo Fails)

### If Queries Don't Execute:

**Option 1**: Show pre-captured screenshots from `docs/screenshots/vignette1/`
> "I have screenshots of this running from our testing phase. Let me walk you through what you'd see..."

**Option 2**: Explain the architecture conceptually
> "While we troubleshoot, let me explain what's happening under the hood..." [Use whiteboard or slides]

**Option 3**: Jump to Query History to show past successful executions
> "Let me show you when this ran successfully earlier..." [Navigate to Query History, filter by successful queries]

---

### If Dynamic Tables Don't Show:

**Fallback**: Explain via SQL DDL
> "The UI isn't cooperating, but let me show you the definition..." [Open worksheet, show Dynamic Table DDL from `sql/silver/dynamic_tables.sql`]

**Alternative**: Show regular tables/views as example
> "While Dynamic Tables aren't loading, the concept is identical to these views, but with automatic refresh..." [Show V_PATIENT_360]

---

### If Performance is Slow:

**Acknowledge and continue**:
> "Looks like the warehouse is cold-starting—this is the first query after suspension. In production, you'd keep warehouses warm during business hours, but watch how it speeds up on subsequent queries..."

**Alternative**: Use smaller dataset
> "Let me use a subset to keep us moving..." [Add LIMIT 100 to queries]

---

## Talking Points Cheat Sheet

**Print this for quick reference during demo:**

| Moment | Key Talking Point | Time |
|--------|-------------------|------|
| **Opening** | "Fragmentation is your #1 data challenge - 3-4 months per acquisition" | 0:00 |
| **Medallion** | "Three layers, one platform, one copy of data" | 2:00 |
| **JSON Query** | "Schema-on-read—no ETL preprocessing required" ⭐ | 4:00 |
| **Dynamic Tables** | "Declarative SQL—you define end state, we handle orchestration" ⭐⭐ | 7:00 |
| **Patient 360** | "From fragmented sources to analytics-ready in same day" | 9:00 |
| **Power BI** | "DirectQuery—no data copy, any BI tool, no vendor lock-in" | 10:30 |
| **Observability** | "Full transparency, no SSIS troubleshooting at 5 PM Friday" | 12:00 |
| **Impact** | "3-4 months → same day. 40 hrs/month → near zero. 25% capacity back" | 12:30 |
| **vs Fabric** | "One platform vs five services. Per-second billing vs F64 capacity" | 13:30 |
| **Transition** | "Foundation built. Now let's make it unbreakable." | 14:30 |

---

## Success Indicators

**You nailed Vignette 1 if:**
- ✅ Miles nods at "SSIS replacement" message
- ✅ Adam asks "How hard is it to add new sources?"
- ✅ Someone mentions "This is simpler than I thought"
- ✅ Questions shift from "Can it do X?" to "When can we start?"
- ✅ Audience leans forward during Dynamic Tables demo

---

## Quick Navigation Reference

**Snowsight UI Paths:**
- **Databases**: Data → Databases
- **Dynamic Table Details**: Data → [Database] → [Schema] → Tables → [Table Name]
- **Query History**: Activity → Query History
- **Warehouses**: Admin → Warehouses
- **Worksheets**: Projects → Worksheets

**Key SQL Scripts (if needed):**
- Bronze setup: `sql/setup/03_load_bronze_data.sql`
- Silver Dynamic Tables: `sql/silver/dynamic_tables.sql`
- Gold Patient 360: `sql/gold/patient_360_view.sql`

---

**Vignette 1 Duration**: 13-14 minutes  
**Difficulty**: Medium (requires UI navigation comfort)  
**Impact**: High (sets foundation for entire demo)  
**Key Moments**: JSON querying (Moment #1), Dynamic Tables (Moment #2)  

**Ready? Take a breath and show them how data unification should work!** 🚀
