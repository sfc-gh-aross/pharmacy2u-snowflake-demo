# Vignette 2 Demo Script
**Title**: Building Unbreakable Trust: Automated Governance & Internal Collaboration  
**Duration**: 13-15 minutes  
**Audience**: Head of Data (Phil Cliff), Head of BI, Head of Customer Insight

---

## Pre-Demo Setup (2 minutes before)

### Browser Tabs to Open:
- [ ] **Tab 1**: Snowsight - Worksheets (logged in as ACCOUNTADMIN)
- [ ] **Tab 2**: Admin → Users & Roles (ready to switch roles)
- [ ] **Tab 3**: Admin → Cost Management → Resource Monitors ← **For Demo Point 5**
- [ ] **Tab 4**: Account → Usage (for Access History queries)
- [ ] **Tab 5**: Data Products → Private Sharing (for Organizational Listings)
- [ ] **Tab 6**: This demo script for reference

### Validation Checks:
- [ ] Run: `sql/demo_scripts/vignette2/01_governance_setup.sql` (verify masking policies work)
- [ ] Verify role exists: `PHARMACY2U_BI_USER`
- [ ] Verify cloned database exists from Time Travel demo OR be ready to create it live
- [ ] **Check Resource Monitor exists**: `PHARMACY2U_DEMO_BUDGET` (for Cost Management demo)
- [ ] **Check Alert Tasks exist**: Run `sql/features/monitoring/alerts_setup.sql` if needed
- [ ] Verify tags applied: Run validation query from `sql/features/governance/object_tagging.sql`

### Physical Setup:
- [ ] Two browser windows side-by-side (for role switching demo)
- [ ] Second monitor with script visible
- [ ] Clicker/keyboard shortcuts practiced for role switching
- [ ] Confident and ready! 🛡️

---

## TELL #1 - Set the Stage (2 minutes)

### Business Context (45 seconds)

> "Welcome back. We've built this powerful, unified data foundation—Patient 360 data from multiple sources, all analytics-ready. **But with great data comes great responsibility.**
>
> Phil, your team is handling highly sensitive patient data. NHS numbers, prescription history, contact information—all subject to strict GDPR regulations. One data leak, one unauthorized access, one governance failure could result in regulatory fines, patient trust erosion, and brand damage.
>
> At the same time, you're a lean team experiencing a P1 incident every two weeks. You need agility to support the business, but you can't sacrifice security or compliance."

**[Pause for acknowledgment]**

---

### Quantified Problem (45 seconds)

> "Let me quantify the governance and operational challenges:
>
> **Compliance Risk**:
> - Sensitive PII across multiple tables, manually tracked
> - No centralized policy enforcement—risk of exposure
> - Audit requirements eating analyst time (30+ hours per quarter for lineage reports)
>
> **Operational Fragility**:
> - **P1 incidents**: Every two weeks—often data quality or access issues
> - Recovery time: Hours to days (restore from backup, validate, redeploy)
> - Dev/test bottlenecks: Production-scale copies are expensive and time-consuming
>
> **Internal Data Silos**:
> - Valuable data assets (Patient 360, churn models, analytics) locked in team silos
> - No central discovery—analysts spend hours hunting for data
> - Duplication of effort—three teams building the same metrics differently
>
> These aren't just IT problems—they're business risks that slow you down and create exposure."

---

### Success Vision (30 seconds)

> "In the next 13 minutes, I'm going to show you how Snowflake creates an environment that is:
> 
> **Secure by default** - Automated governance that's impossible to bypass  
> **Operationally resilient** - Mistakes are reversible in seconds, not hours  
> **Collaborative by design** - Internal data marketplace that breaks down silos
>
> You'll see features that Microsoft Fabric fundamentally cannot match—Time Travel, Zero-Copy Cloning, and integrated data products. These aren't nice-to-haves; they're competitive differentiators.
>
> Let's build unbreakable trust."

---

## SHOW - Live Demonstration (10 minutes)

### Demo Point 1: Dynamic Data Masking - Automated PII Protection (2.5 minutes)

**Script reference**: `sql/demo_scripts/vignette2/01_governance_setup.sql`

**Navigation**: Worksheets → Open query for PATIENTS table

**Action**: Query patient data as ACCOUNTADMIN

**Type and execute:**
```sql
-- View patient data as admin (unmasked)
SELECT 
    PATIENT_ID,
    FIRST_NAME,
    LAST_NAME,
    EMAIL,
    PHONE,
    NHS_NUMBER,
    AGE,
    POSTCODE
FROM PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS
LIMIT 10;
```

**Point to the results:**

> "As an administrator, I can see all the sensitive data—email addresses, phone numbers, NHS numbers. This is necessary for my role. **But watch what happens when a BI user queries the exact same table.**"

**Action**: Switch role to BI_USER

**Navigation**: Top-right role selector → Switch to `PHARMACY2U_BI_USER`

**Wait for role to switch, then run the EXACT SAME query again**

**Point to the masked results:**

> "**KEY MOMENT #1**: Look at the transformation. Email is now `***@***.**`. Phone shows `***-***-****`. NHS number is completely masked. **Same query, same table, different role, automatic protection.**
>
> This is **policy-based governance**. The security policy is attached to the data columns themselves, not to the query. It's impossible for a BI user to see raw PII, regardless of how they query it—SQL, BI tool, API, doesn't matter. **The policy follows the data everywhere.**"

**Navigate to show the policy (optional, if time permits):**

Data → PHARMACY2U_SILVER → GOVERNED_DATA → PATIENTS → Column: EMAIL → Policies tab

> "Here's the policy. We defined it once, applied it to the column, and it's automatically enforced across all access paths."

**Switch role back to ACCOUNTADMIN:**

Top-right → ACCOUNTADMIN

**Competitive wedge:**
> "In Microsoft Fabric, you'd configure Row-Level Security in Power BI datasets, then separately in Synapse, then again in any other tool accessing the data. Multiple configurations, multiple failure points, constant maintenance.
>
> Snowflake: **Define once, enforce everywhere. Centralized, automated, impossible to bypass.**"

**Audience engagement:**
> "Phil, how much time does your team spend on quarterly GDPR compliance audits? Proving data access is properly restricted?"

**[Wait for response]**

> "With policy-based governance and full access history—which we'll see in a moment—you go from manual audits to automated compliance reporting. Days to hours."

**Timing checkpoint**: 2.5 minutes elapsed

---

### Demo Point 2: Time Travel - Instant Incident Recovery (2.5 minutes)

**Script reference**: `sql/demo_scripts/vignette2/02_time_travel.sql`

**Navigation**: Worksheets → New query

**Setup the scenario:**

> "Let's talk about operational resilience. It's Friday at 4:30 PM. Someone on the team runs an UPDATE statement and accidentally nullifies a critical column. In a traditional database, this is a P1 incident—restore from backup, validate data integrity, hours of work, possibly impacting users.
>
> **Watch how Snowflake turns a P1 incident into a 30-second fix.**"

**Action**: Execute the "Friday afternoon mistake"

**Script to run** (or reference): Execute section from `sql/demo_scripts/vignette2/02_time_travel.sql`

```sql
-- Create a demo copy of the table
CREATE TABLE PATIENTS_DEMO CLONE PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS;

-- The "Friday mistake" - accidentally nullify emails
UPDATE PATIENTS_DEMO
SET EMAIL = NULL
WHERE PATIENT_ID LIKE 'P%';

-- Oh no! Check the damage
SELECT COUNT(*) as nullified_emails 
FROM PATIENTS_DEMO 
WHERE EMAIL IS NULL;
```

**Point to the result showing many NULL emails:**

> "Disaster. We just wiped out thousands of email addresses. Traditionally, this means:
> 1. Stop the database
> 2. Restore from last night's backup
> 3. Lose all data changes from today
> 4. Spend hours validating
> 
> **With Snowflake Time Travel, watch this:**"

**Execute the recovery:**

```sql
-- Use Time Travel to query data from 10 seconds ago (before the mistake)
SELECT 
    PATIENT_ID,
    EMAIL
FROM PATIENTS_DEMO
AT(OFFSET => -10)  -- 10 seconds ago
WHERE PATIENT_ID LIKE 'P%'
LIMIT 10;
```

**Point to the results showing intact emails:**

> "**KEY MOMENT #2**: We're querying the table as it existed 10 seconds ago, before the mistake. The data is intact. Time Travel gives us instant access to historical versions.
>
> Now, let's restore the table:"

```sql
-- Restore the entire table from before the mistake
CREATE OR REPLACE TABLE PATIENTS_DEMO CLONE PATIENTS_DEMO
AT(OFFSET => -10);

-- Verify recovery
SELECT COUNT(*) as recovered_emails 
FROM PATIENTS_DEMO 
WHERE EMAIL IS NOT NULL;
```

**Point to the recovered count:**

> "**Done. 30 seconds. P1 incident avoided.**
>
> No backup restore. No data loss. No downtime. This is what we mean by operational resilience. Time Travel keeps up to 90 days of data history automatically—every table, every change, instantly queryable."

**Competitive wedge - drive this home:**
> "**Microsoft Fabric does not have this capability.** If you make a mistake in OneLake or a Fabric data warehouse, you're restoring from backups, period. Azure SQL versioning requires manual configuration and doesn't work across the platform.
>
> Snowflake Time Travel is built-in, automatic, and available on every single table. **This feature alone de-risks your entire operation.**"

**Timing checkpoint**: 5 minutes elapsed

---

### Demo Point 3: Zero-Copy Cloning - Instant Dev/Test Environments (1.5 minutes)

**Script reference**: `sql/demo_scripts/vignette2/03_zero_copy_cloning.sql`

**Navigation**: Stay in worksheets

**Setup:**

> "You just saw Time Travel prevent a disaster. Now let me show you how Zero-Copy Cloning empowers your team.
>
> Your developers and QA teams need production-scale data for testing. Today, creating a copy of your multi-terabyte GOLD database would take hours, cost storage for a full duplicate, and require complex scripting.
>
> **With Snowflake, watch this:**"

**Execute:**

```sql
-- Clone the entire GOLD database instantly
CREATE DATABASE PHARMACY2U_GOLD_DEV 
CLONE PHARMACY2U_GOLD;

-- Verify it exists and has data
USE DATABASE PHARMACY2U_GOLD_DEV;
SELECT COUNT(*) FROM ANALYTICS.V_PATIENT_360;
```

**Point to execution time and result:**

> "**KEY MOMENT #3**: We just created a perfect, readable, writable copy of the entire GOLD database with 100,000 patient records. Execution time: **Milliseconds. Storage cost: Zero.**
>
> How? Snowflake uses metadata pointers—both databases reference the same underlying storage until you make changes to the clone. It's a snapshot in time, fully independent, zero cost to create."

**Show the database list:**

**Navigation**: Data → Databases

**Point to both PHARMACY2U_GOLD and PHARMACY2U_GOLD_DEV:**

> "Your developers can now test schema changes, run experiments, break things without fear—all on production-scale data. When they're done, drop the clone. **Zero risk to production, zero storage costs until they modify data.**"

**Audience engagement:**
> "How long does it currently take your team to provision a test environment with production data?"

**[Wait for response]**

> "Right. And that's the bottleneck that slows down releases. We just eliminated it."

**Competitive wedge:**
> "In Fabric, database copies are full physical copies. You pay for duplicate storage immediately, and the copy process takes time proportional to data size. No metadata-based cloning exists.
>
> Snowflake: **Instant clones, zero additional cost, production-scale testing with no friction.**"

**Timing checkpoint**: 6.5 minutes elapsed

---

### Demo Point 4: Access History & Audit Trails (1.5 minutes)

**Script reference**: `sql/demo_scripts/vignette2/04_audit_and_lineage.sql`

**Navigation**: Worksheets → New query

**Setup:**

> "Between GDPR audits, compliance requirements, and security monitoring, your team needs to know: Who accessed what data, when, and how?
>
> Snowflake tracks every single query, every data access, automatically. Let me show you."

**Execute audit query:**

```sql
-- Show recent PII access (from Access History)
SELECT 
    user_name,
    query_start_time,
    query_text,
    direct_objects_accessed,
    rows_produced
FROM SNOWFLAKE.ACCOUNT_USAGE.ACCESS_HISTORY
WHERE query_start_time >= DATEADD(day, -7, CURRENT_TIMESTAMP())
  AND ARRAY_CONTAINS('PHARMACY2U_SILVER.GOVERNED_DATA.PATIENTS'::VARIANT, 
                     base_objects_accessed)
ORDER BY query_start_time DESC
LIMIT 10;
```

**Point to the results:**

> "Every query against the PATIENTS table—who ran it, when, what they accessed, how many rows. Full audit trail, automatically captured, queryable like any other data.
>
> This is your compliance reporting, security monitoring, and lineage tracking—all built-in."

**Optional - Show in UI** (if time permits):

**Navigation**: Account → Usage → Query History

**Filter**: Objects accessed: PATIENTS

> "You can also visualize this in the UI—filter by table, user, time range. Point and click compliance reporting."

**Talking point:**
> "When a GDPR audit request comes in—'Show me everyone who accessed patient X's data in the last 90 days'—this goes from a week-long manual exercise to a 5-minute SQL query."

**Timing checkpoint**: 8 minutes elapsed

---

### Demo Point 5: Cost Management & Budgets (1 minute)

**Script reference**: `sql/features/monitoring/cost_budgets.sql`

**Navigation**: Admin → Cost Management → Resource Monitors

**Setup:**

> "With a lean team, you need complete visibility into costs. Let me show you Snowflake's built-in cost management."

**Action**: Show Resource Monitors UI

**Point to the PHARMACY2U_DEMO_BUDGET monitor:**

> "We've set up a resource monitor with a monthly budget of 100 credits—roughly £500. Look at the thresholds:
> - **50% usage**: Notification to the team
> - **75% usage**: Warning notification
> - **90% usage**: Critical alert
> - **100% usage**: Suspend warehouse (optional safeguard)
>
> These guardrails prevent runaway costs. No surprise bills, no budget overruns."

**Navigate**: Admin → Usage (or show cost dashboard query if available)

**Optional - Run quick query:**

```sql
-- Show current month spend
SELECT 
    WAREHOUSE_NAME,
    SUM(CREDITS_USED) as total_credits,
    SUM(CREDITS_USED) * 5 as estimated_cost_gbp
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
WHERE START_TIME >= DATE_TRUNC('month', CURRENT_DATE())
  AND WAREHOUSE_NAME LIKE 'PHARMACY2U%'
GROUP BY WAREHOUSE_NAME;
```

**Point to results:**

> "Complete cost visibility down to the warehouse level. We can track:
> - Cost per warehouse
> - Cost per query
> - Cost per user or department
> - Per-second billing—you only pay for what you use
>
> This goes back to the £36k SQL Server scaling problem. With Snowflake, you pay for actual consumption, and warehouses auto-suspend when not in use. No idle charges."

**Competitive wedge:**

> "Microsoft Fabric requires you to pre-purchase Fabric Capacity Units—F64 minimum at £5,000+ per month, whether you use it or not. Snowflake bills per second of actual usage. For a lean team with variable workloads, that's the difference between paying for potential capacity and paying for actual work done."

**Timing checkpoint**: 9 minutes elapsed

---

### Demo Point 6: Alerts & Notifications - Proactive Monitoring (1 minute)

**Script reference**: `sql/features/monitoring/alerts_setup.sql`

**Navigation**: Stay in Worksheets or navigate to Activity → Tasks

**Setup:**

> "Cost management is reactive. Alerts are **proactive**—catching issues before they become P1 incidents."

**Action**: Show configured alert tasks or execute query

**Option 1 - Show Tasks:**

**Navigate**: Data → Databases → PHARMACY2U_GOLD → ANALYTICS → Tasks

> "We've configured six automated alert tasks that run on schedule:
> - **Data quality**: Null NHS numbers, future prescription dates
> - **Business anomalies**: Prescription volume spikes or drops
> - **Pipeline failures**: Dynamic Table refresh errors
> - **Cost alerts**: Daily budget threshold breaches
> - **Security**: After-hours administrative actions
>
> These run automatically—no external monitoring tools needed."

**Option 2 - Show Alert Log:**

```sql
-- Show recent alerts
SELECT 
    alert_type,
    alert_severity,
    alert_message,
    alert_timestamp
FROM PHARMACY2U_GOLD.ANALYTICS.ALERT_LOG
ORDER BY alert_timestamp DESC
LIMIT 10;
```

**Talking point:**

> "This is how you reduce P1 incidents from every two weeks to near zero. Issues are caught and logged automatically. In production, these trigger email or Slack notifications to the on-call team.
>
> **Proactive monitoring** means your team isn't firefighting at 5 PM on Friday—they're alerted early and can fix issues during business hours."

**Competitive wedge:**

> "This is built into Snowflake—Tasks and stored procedures. With Fabric, you'd need Azure Monitor, Logic Apps, and custom integrations. More services to manage, more costs, more complexity."

**Timing checkpoint**: 10 minutes elapsed

---

### Demo Point 7: Object Tagging & Data Classification (1.5 minutes)

**Script reference**: `sql/demo_scripts/vignette2/06_object_tagging_demo.sql`

**Navigation**: Data → PHARMACY2U_SILVER → GOVERNED_DATA → PATIENTS → Column: NHS_NUMBER

**Action**: Show tag details in UI

**Click on column → Details/Properties tab → Tags section**

**Point to the tags:**

> "We've automatically classified all sensitive data with governance tags. See here—NHS_NUMBER is tagged as:
> - `PII_TYPE`: HEALTHCARE_ID
> - `DATA_CLASSIFICATION`: HIGHLY_SENSITIVE
> - `COMPLIANCE_CATEGORY`: GDPR_SPECIAL_CATEGORY
>
> These tags drive automated policies, enable discovery queries, and provide governance metadata."

**Navigate back to Worksheets, execute discovery query:**

```sql
-- Find all PII columns across the entire database
SELECT 
    tag_database,
    tag_schema,
    object_name as table_name,
    column_name,
    tag_value as pii_type
FROM SNOWFLAKE.ACCOUNT_USAGE.TAG_REFERENCES
WHERE tag_name = 'PII_TYPE'
  AND tag_database = 'PHARMACY2U_SILVER'
ORDER BY object_name, column_name;
```

**Point to results:**

> "Instant PII inventory across your entire environment. We know exactly where sensitive data lives, what type of PII it is, and what compliance categories apply.
>
> This automated classification makes governance scalable. New tables added? Tags automatically classify them. Compliance audit? Query the tag metadata."

**Competitive wedge:**
> "Microsoft Purview can tag data in Fabric, but it's a separate service with separate costs, separate configuration, and often requires manual classification. 
>
> Snowflake tags are native, govern access policies, and integrate directly with the data platform. One system, one governance model."

**Timing checkpoint**: 11.5 minutes elapsed

---

### Demo Point 8: Organizational Listings - Internal Data Marketplace (2 minutes)

**Script reference**: `sql/demo_scripts/vignette2/07_organizational_listings_demo.sql`

**Navigation**: Data Products → Private Sharing (or Data Marketplace → Private Listings)

**Setup:**

> "You've built incredible data assets—Patient 360 views, churn scores, prescription analytics. But if your teams can't discover them, they build duplicates, waste time, and create data inconsistency.
>
> **KEY MOMENT #4**: Snowflake has an internal marketplace where you publish data products for discovery and collaboration across your organization."

**Action**: Show the marketplace UI (if Organizational Listings/Private Data Exchange is configured)

**Point to the listings** (or execute query if UI isn't available):

```sql
-- Show internal data product catalog
SELECT 
    product_name,
    product_description,
    business_domain,
    data_owner,
    target_audience,
    row_count
FROM PHARMACY2U_GOLD.DATA_PRODUCTS.DATA_PRODUCT_CATALOG
ORDER BY product_name;
```

**Walk through the catalog:**

> "Here's your internal data marketplace:
> 
> **Patient 360 Analytics** - Complete patient view for BI and analytics  
> **Churn Risk Scores** - ML predictions for retention campaigns  
> **Prescription Analytics** - Clinical insights for operational teams
>
> Each data product is:
> - **Discoverable** - Search by keyword, domain, or audience
> - **Documented** - Business owner, update frequency, use cases
> - **Governed** - Access controls and PII status tracked
> - **Shareable** - One-click access requests for authorized users"

**Explain the impact:**

> "Your BI team builds Patient 360 dashboards. Instead of the marketing team duplicating that work, they discover it here, request access, and consume the same trusted dataset. **No duplicate work, no data inconsistency, no wasted effort.**
>
> This is internal data monetization—turning data assets into discoverable products that drive cross-team collaboration."

**Competitive wedge - critical differentiator:**
> "**Microsoft Fabric has no equivalent to this.** There's no internal marketplace, no data product catalog, no central discovery for shared analytics assets.
>
> You'd need to build a manual SharePoint site or wiki to track what data exists where, and manually grant access through separate admin tools.
>
> Snowflake's Organizational Listings are built into the platform—publish a data product, it's instantly discoverable, access-controlled, and governed. **This breaks down your internal data silos.**"

**Timing checkpoint**: 13.5 minutes elapsed

---

## TELL #2 - Reinforce Value (2.5 minutes)

### Business Impact Summary (90 seconds)

> "Let me bring this all together. In 10 minutes, you saw six capabilities that fundamentally change your risk and operational profile:
>
> **Governance Automation**:
> - PII masking: **Manual tracking → automated policy enforcement**
> - Compliance audits: **30+ hours per quarter → 5-minute SQL queries**
> - Data classification: **Spreadsheet inventory → live, queryable tag metadata**
> - Risk of exposure: **Significantly reduced through centralized, impossible-to-bypass policies**
>
> **Operational Resilience**:
> - P1 incident recovery: **Hours to days → 30 seconds with Time Travel**
> - Incident frequency: **Every 2 weeks → near elimination of data recovery incidents**
> - Development agility: **Days to provision test data → instant zero-copy clones**
> - Team confidence: **Fear of breaking production → freedom to innovate**
>
> **Internal Collaboration**:
> - Data discovery: **Hours hunting → instant marketplace search**
> - Duplicate effort: **Three teams building same metrics → one trusted product**
> - Cross-team data sharing: **Email and manual access → self-service discovery**
> - Data silos: **Broken down through centralized product catalog**
>
> **Cost Impact**:
> - Storage for dev/test: **Full duplicate costs → zero with clones**
> - Incident response costs: **Analyst hours + potential downtime → seconds of recovery**
> - Compliance staff time: **Manual audit preparation → automated reporting**"

---

### Competitive Differentiation vs Microsoft Fabric (60 seconds)

> "Three of the features you just saw—**Time Travel, Zero-Copy Cloning, and Organizational Listings**—do not exist in Microsoft Fabric. Period. These aren't minor features; they're fundamental differentiators:
>
> **Time Travel**:
> - Snowflake: Built-in, automatic, 90 days of history on every table
> - Fabric: No equivalent. Restore from backup or lose the data.
>
> **Zero-Copy Cloning**:
> - Snowflake: Instant metadata-based clones, zero additional storage cost
> - Fabric: Full physical copies, pay immediately for duplicate storage
>
> **Organizational Listings (Internal Marketplace)**:
> - Snowflake: Built-in data product catalog with governance and access controls
> - Fabric: No internal marketplace. Manual documentation and access management.
>
> **The Strategic Difference**:
> - Snowflake: **Built to reduce risk and accelerate collaboration**
> - Fabric: **Built to sell Azure services, not to reduce operational friction**
>
> You're choosing between a platform that makes your lean team **10x more effective** versus one that makes them **systems integrators**. 
>
> With Pharmacy2U's growth trajectory and lean team, you need the platform that gives you superpowers, not homework."

---

### Transition to Vignette 3 (30 seconds)

> "We've now built a foundation that is unified, governed, and resilient. Your data is trusted, your operations are de-risked, your teams can collaborate.
>
> **But trust is just table stakes. The real value comes from putting this foundation to work.**
>
> In the next 15 minutes, I'm going to show you how this governed data powers AI and ML—from democratizing analytics for non-technical users to building predictive models to advanced GenAI capabilities.
>
> Mustafa, this next section is for you. Let's talk about making AI/ML smooth, secure, and production-ready.
>
> Welcome to Vignette 3: Powering the Future with AI."

**[Pause, take a sip of water, proceed to Vignette 3]**

---

## Backup Plan (If Live Demo Fails)

### If Role Switching Fails:

**Option 1**: Use two browser windows (one per role) side-by-side
> "Let me show you the difference side-by-side..." [Pre-logged in to each role]

**Option 2**: Show pre-captured screenshots
> "I have screenshots from testing that show the masking in action..." [Use `docs/screenshots/vignette2/`]

**Option 3**: Explain the policy conceptually
> "The masking policy definition is simple—let me show you the SQL..." [Show policy DDL from `sql/features/governance/access_policies.sql`]

---

### If Time Travel Query Fails:

**Fallback**: Show Query History with previous successful execution
> "Let me show you when this ran successfully in testing..." [Navigate to Query History, show Time Travel queries]

**Alternative**: Explain with query results from past execution
> "Here's the output from our test run..." [Use screenshots or saved query results]

---

### If Organizational Listings UI Unavailable:

**Fallback**: Show the catalog via SQL query
> "The UI isn't loading, but here's the data product catalog via SQL..." [Run query from `sql/demo_scripts/vignette2/07_organizational_listings_demo.sql`]

**Alternative**: Explain the concept with architecture diagram
> "Think of it like an internal app store for data..." [Use whiteboard or slides]

---

### If Access History is Delayed (Common with ACCOUNT_USAGE):

**Acknowledge latency**:
> "ACCOUNT_USAGE views have a slight delay—they're optimized for large-scale queries, not real-time. In production, you'd use INFORMATION_SCHEMA for immediate results or wait 45 minutes for full history."

**Alternative**: Show tag references or query history instead
> "Let me show you the governance tagging which is real-time..." [Switch to tag query]

---

## Talking Points Cheat Sheet

**Print this for quick reference during demo:**

| Moment | Key Talking Point | Time |
|--------|-------------------|------|
| **Opening** | "P1 incidents every 2 weeks, GDPR risk, internal silos—we fix all three" | 0:00 |
| **Masking** | "Policy follows data everywhere—impossible to bypass" ⭐ | 2:30 |
| **Time Travel** | "P1 incident → 30-second fix. Fabric can't do this." ⭐⭐ | 5:00 |
| **Cloning** | "Instant dev/test, zero cost. Metadata magic." ⭐⭐⭐ | 6:30 |
| **Access History** | "GDPR audit: week-long manual → 5-minute SQL query" | 8:00 |
| **Cost Management** | "Per-second billing, resource monitors, no surprise bills" | 9:00 |
| **Alerts** | "Proactive monitoring prevents P1 incidents before they happen" | 10:00 |
| **Tagging** | "Automated PII inventory, queryable governance metadata" | 11:30 |
| **Org Listings** | "Internal marketplace breaks down silos. Fabric has no equivalent." ⭐⭐⭐⭐ | 13:30 |
| **Impact** | "Hours → seconds. Manual → automated. Risk → resilience." | 14:00 |
| **vs Fabric** | "Three features Fabric cannot match: Time Travel, Cloning, Marketplace" | 14:30 |
| **Transition** | "Trust established. Now let's power AI with this foundation." | 15:00 |

---

## Success Indicators

**You nailed Vignette 2 if:**
- ✅ Audible reaction when Time Travel recovers data in 30 seconds
- ✅ Phil asks "Can we roll this out next quarter?"
- ✅ Someone says "This solves our dev environment problem"
- ✅ Questions about organizational listings and data product strategy
- ✅ Audience relaxes—they see risk being addressed, not created

---

## Quick Navigation Reference

**Snowsight UI Paths:**
- **Role Switching**: Top-right corner → Click current role → Select new role
- **Resource Monitors**: Admin → Cost Management → Resource Monitors
- **Access History**: Account → Usage → Query History (filter by tables)
- **Organizational Listings**: Data Products → Private Sharing
- **Tag Details**: Data → [Database] → [Schema] → [Table] → [Column] → Details tab

**Key SQL Scripts:**
- Governance demo: `sql/demo_scripts/vignette2/01_governance_setup.sql`
- Time Travel: `sql/demo_scripts/vignette2/02_time_travel.sql`
- Zero-Copy Cloning: `sql/demo_scripts/vignette2/03_zero_copy_cloning.sql`
- Access History: `sql/demo_scripts/vignette2/04_audit_and_lineage.sql`
- Object Tagging: `sql/demo_scripts/vignette2/06_object_tagging_demo.sql`
- Org Listings: `sql/demo_scripts/vignette2/07_organizational_listings_demo.sql`

---

**Vignette 2 Duration**: 13-14 minutes  
**Difficulty**: Medium-High (requires role switching, UI navigation)  
**Impact**: Very High (addresses risk, compliance, and operational efficiency)  
**Key Moments**: Masking (#1), Time Travel (#2), Cloning (#3), Org Listings (#4)  

**Ready? Show them how to build unbreakable trust!** 🛡️
