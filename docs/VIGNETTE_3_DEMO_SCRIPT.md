# Vignette 3 Demo Script
**Title**: Powering the Future: From Trusted Data to Generative AI  
**Duration**: 13-15 minutes  
**Audience**: Head of Data Science (Mustafa Ghafouri), Chief Architect (Miles Hewitt)

---

## Pre-Demo Setup (2 minutes before)

### Browser Tabs to Open:
- [ ] **Tab 1**: Snowflake Intelligence UI - `PATIENT_360_AGENT` agent (logged in as ACCOUNTADMIN)
- [ ] **Tab 2**: Snowsight → Streamlit → `PATIENT_360_DASHBOARD` app (Patient 360 Dashboard) ← **KEY DEMO**
- [ ] **Tab 3**: Snowsight → Projects → Notebooks (Snowflake Notebooks UI)
- [ ] **Tab 4**: Snowsight → Data → Marketplace (Snowflake Marketplace)
- [ ] **Tab 5**: Snowsight → Worksheets (for Cortex AI functions demo if needed)
- [ ] **Tab 6**: This demo script for reference
- [ ] **Tab 7**: `INTELLIGENCE_DEMO_CHEAT_SHEET.md` (for query reference)

### Validation Checks:
- [ ] Intelligence Agent `PATIENT_360_AGENT` is active
- [ ] Click "New thread" in Intelligence to start fresh conversation
- [ ] Verify semantic model is loaded in agent
- [ ] **Streamlit App Deployed**: `PATIENT_360_DASHBOARD` app is running and accessible
- [ ] Check Cortex Search service status: `PATIENT_360_SEARCH_SERVICE` is READY
- [ ] Verify churn analysis results exist: Run `sql/demo_scripts/vignette3/01_patient_churn_notebook_demo.sql` sections to have results ready
- [ ] Warehouse `PHARMACY2U_DEMO_WH` is RUNNING

### Physical Setup:
- [ ] Screen sharing ready (Intelligence UI primary)
- [ ] Second monitor with cheat sheet visible
- [ ] Practiced Query 4 delivery (the KEY MOMENT)
- [ ] Water nearby
- [ ] Ready to inspire! 🚀

---

## TELL #1 - Set the Stage (2 minutes)

### Business Context (45 seconds)

> "Welcome to the final vignette, Mustafa and team. We've built a unified data foundation, made it governable and resilient. Now comes the payoff: **putting that trusted data to work with AI and machine learning.**
>
> Mustafa, you mentioned your key priority is bringing AI/ML in-house with a 'smooth delivery' experience. You have ambitious goals—Smart Reminders, agentic chatbots, predictive models that could save millions. But you've also noted concerns about:
> - MLOps complexity and deployment friction
> - Security risks of moving sensitive patient data to train models
> - Version control and reproducibility challenges
> - Bridging the gap between data science outputs and business action
>
> These are real concerns that have derailed AI projects before."

**[Pause for acknowledgment]**

---

### Quantified Problem (45 seconds)

> "Let me frame the AI/ML challenges quantitatively:
>
> **Time to Value**:
> - Past AI projects: Weeks to build, months to deploy, slow business adoption
> - Each integration (feature engineering → training → deployment → business consumption) adds friction
> - Data scientists spend 60% of time on infrastructure, 40% on actual modeling
>
> **Security & Governance**:
> - Moving PII to external ML platforms creates regulatory exposure
> - Shadow AI: Teams using ChatGPT or external tools with ungoverned data
> - No lineage from data → model → prediction → business decision
>
> **Business Impact Gap**:
> - Models built but not consumed—ML outputs sit in S3, never reach business users
> - Insights discovered by data science, but marketing can't act on them without developer support
> - No 'last mile' connection from prediction to execution
>
> The challenge isn't just building models—it's making AI accessible, governed, and actionable across your organization."

---

### Success Vision (30 seconds)

> "In the next 13 minutes, I'll show you Snowflake as the platform for the entire AI lifecycle:
>
> **Democratized Analytics** - Non-technical users ask questions in plain English  
> **Integrated ML** - Build and deploy models where your data lives, with governance intact  
> **Production AI** - From raw data to business action, all within Snowflake's security boundary
>
> You'll see Snowflake Intelligence answer complex business questions in seconds. You'll see analytical workflows that replace weeks of manual analysis. And you'll see how we close the loop from data science insights to marketing execution.
>
> This is the 'smooth delivery' experience you asked for. Let's power your AI future."

---

## SHOW - Live Demonstration (10 minutes)

### Demo Point 1: Snowflake Intelligence Agent - Data Democratization (5 minutes)

**Reference**: `docs/INTELLIGENCE_AGENT_DEMO_FLOW.md` and `INTELLIGENCE_DEMO_CHEAT_SHEET.md`

**Navigation**: Snowflake Intelligence → `PATIENT_360_AGENT` → New thread (if not already there)

**Setup - Persona introduction (20 seconds):**

> "Let me introduce you to Sarah, a marketing manager at Pharmacy2U. Sarah has great business intuition but zero SQL knowledge. Today, she's planning next month's Heart Health campaign and needs to identify the right patient cohort to target.
>
> Traditionally, Sarah would email the analytics team, wait 2-3 days for a response, realize she asked the wrong question, and iterate again. Each cycle costs days.
>
> **With Snowflake Intelligence, watch what Sarah can do herself:**"

---

#### **Query 1: Warm-up** (20 seconds)

**Type in Intelligence agent:**
```
How many patients do we have?
```

**Wait for response, point to answer:**

> "100 million patients. Instant answer in under 2 seconds. Notice the agent understood this is about our patient base, generated SQL against our **materialized PATIENT_360 dynamic table**, and returned the result. Sarah never saw the SQL, never knew it happened. **Natural language to instant answer.**
>
> **This is key**: We're querying 100 million patient records with complex aggregations, and it's sub-second because the data is materialized and auto-refreshing. In Microsoft Fabric, you'd need to manually configure aggregations in Power BI or build separate views—here, it's automatic."

---

#### **Query 2: Business Intelligence** (30 seconds)

**Type in agent:**
```
What are the top 5 most prescribed drugs this year?
```

**Wait for response, point to the list:**

> "Perfect—Atorvastatin, Metformin, Amlodipine, Omeprazole, Simvastatin. These are the top prescribed drugs. Sarah can see Atorvastatin is #1, accounting for the highest prescription volume.
>
> She's building context. Now she wants to understand the demographics..."

---

#### **Query 3: Demographic Analysis** (30 seconds)

**Type in agent:**
```
For Atorvastatin, what is the patient age breakdown?
```

**Wait for response, point to age groups:**

> "Excellent. Most Atorvastatin patients are in the 51-65 age group, with a significant population in 65+. These are Sarah's core Heart Health campaign demographics.
>
> Now here's where it gets powerful. She wants to find a specific, actionable cohort..."

---

#### **Query 4: THE KEY MOMENT** ⭐⭐⭐ (90 seconds)

**Type slowly (build suspense):**
```
Of patients over 65, how many haven't converted on Heart Health campaign?
```

**Wait for response**

**PAUSE. Let the number sink in. Then point to the screen:**

> "**KEY MOMENT #1**. In 10 seconds, Sarah just identified **4,927 actionable patients from a database of 100 million**. Let me break down what just happened and why this matters:
>
> **How is this so fast?** The Intelligence Agent queries the PATIENT_360 **dynamic table**—materialized, auto-refreshing analytics data optimized for instant performance. No manual view building, no aggregation configuration. Snowflake handles it automatically.

**Point to the insights in the agent response:**

> "These 4,927 patients:
> - Are in the **65+ demographic**—the highest-risk group for heart conditions requiring statins like Atorvastatin
> - Have received a total of **39,246 marketing touches** across all campaigns—they're ENGAGED with Pharmacy2U
> - Average **4.76 prescriptions per patient**—they're active, regular customers, not lapsed users
> - But have **ZERO conversions on the specific Heart Health campaign** despite being targeted
>
> **This is a massive opportunity.** These patients are:
> - Already engaged with your service (high touchpoint count)
> - In the exact demographic for heart health (age 65+)
> - Active prescription users (regular customer behavior)
> - But haven't responded to this specific campaign yet
>
> Sarah can now launch a **targeted re-engagement campaign TODAY** for these exact 4,927 patients. Personalized messaging, tailored to their age and prescription history, addressing why they didn't convert the first time.
>
> **With traditional BI and analytics:**
> - Sarah emails the analytics team: Day 1
> - Analyst queues it behind other requests: Day 2
> - Analyst builds query, realizes they need clarification: Day 3
> - Back and forth on requirements: Days 4-5
> - Final results delivered: End of Week 1
> - Sarah realizes she needs a follow-up question: Repeat cycle
> - Campaign finally launches: Week 2 or 3
>
> **With Snowflake Intelligence:**
> - Sarah asks the question herself: **10 seconds**
> - Campaign planning starts: **Today**
>
> This isn't just faster—it's a fundamental transformation of how your business operates. Marketing becomes data-driven and self-sufficient. Your analytics team is freed from ad-hoc queries to focus on strategic work. Campaign velocity accelerates from weeks to days."

**[Pause - let the impact land]**

---

#### **Query 5: Conversational Follow-up** (30 seconds)

**Type in agent:**
```
What is the average lifetime value of these patients?
```

**Wait for response:**

> "And here's the conversational intelligence—the agent remembered the context from my previous question. It knows 'these patients' refers to the 65+ non-converters we just discussed.
>
> Now Sarah knows not just the cohort size but the **revenue opportunity**. She can calculate expected ROI for the campaign, justify the budget, and prioritize this over other initiatives.
>
> **This is self-service analytics**: No SQL, no dependencies, no waiting. Just business questions and instant answers."

---

#### **Query 6: Show Versatility** (Optional - 20 seconds if time permits)

**Type in agent:**
```
Show me the distribution of high-value patients by region
```

**Wait for response:**

> "And she can pivot the analysis any direction—geographic distribution, customer tier segmentation, prescription patterns. All in natural language, all instant, all governed by the policies we configured in Vignette 2."

**Timing checkpoint**: 5 minutes elapsed

---

### Demo Point 1b: The AI Under the Hood (Optional - 30 seconds)

**If audience is technical and engaged, click "Show Details" on Query 4:**

**Point to the generated SQL:**

> "For the technical folks—here's the SQL the agent generated. It understood:
> - 'Over 65' maps to our AGE dimension with a filter
> - 'Haven't converted' means CAMPAIGN_CONVERSIONS = 0
> - 'Heart Health campaign' is contextual from our marketing interactions
> 
> The semantic model we defined provides the business logic. Cortex Analyst generates the SQL. The user never needs to know it happened. This is AI grounded in real data, not hallucinations."

---

### Demo Transition: From Self-Service to Interactive Dashboards (15 seconds)

> "That's natural language analytics for one-off questions. But business teams also need **interactive dashboards** they can explore themselves. Let me show you Streamlit in Snowflake."

**Timing checkpoint**: 5.5 minutes elapsed

---

### Demo Point 2: Streamlit Dashboard - Interactive Business Analytics (2.5 minutes)

**App location**: `src/streamlit_apps/patient_360_dashboard/app.py`

**Navigation**: Snowsight → Streamlit → Apps → `PATIENT_360_DASHBOARD`

**Setup:**

> "Business users need more than just Q&A—they need interactive dashboards to explore data visually. This is where Streamlit in Snowflake comes in.
>
> **Streamlit is Python-based dashboarding that runs natively in Snowflake**—no separate BI server, no data movement, just interactive apps on your governed data."

**Action**: Open the Patient 360 Dashboard app

**Point to the dashboard loading:**

> "This is a Python application running inside Snowflake, querying the PATIENT_360 dynamic table—**100 million patient records, materialized for instant performance**. Watch how fast it loads..."

**After dashboard loads (emphasize performance):**

> "Sub-second load time on 100 million patients. This is the power of Dynamic Tables—data pre-aggregated, auto-refreshing every 5 minutes, zero manual optimization required. 
>
> **Compare to Fabric**: You'd need to manually build aggregations in multiple places, manage refresh schedules separately, and optimize each query individually. Here, it's automatic."

**Walk through the dashboard sections:**

**1. KPI Cards at the top:**

> "First glance: Key metrics. Total patients, average lifetime value, total prescriptions, campaign conversion rate. These are live—queried from our Patient 360 view as the dashboard loads."

**2. Scroll to the visualizations:**

**Point to the patient distribution chart:**

> "Here's the patient distribution by customer tier—Bronze, Silver, Gold, Platinum. We can see most patients are Bronze tier, but Platinum drives the highest value.
>
> This is built with **Plotly**—interactive, professional charts. Hover over bars, zoom, pan—all client-side interactivity."

**3. Show the filters in the sidebar:**

**Click sidebar filters (Age Group, Customer Tier, etc.):**

> "And here's where it gets powerful. Watch what happens when I filter to only Gold and Platinum customers..."

**Apply filter, watch dashboard update:**

> "The entire dashboard updates instantly—KPIs recalculate, charts refilter, all in real-time. The Streamlit app is running Python code that queries Snowflake, processes results, and renders visualizations—all in one place."

**4. Show additional charts:**

**Scroll to prescription trends or geographic distribution:**

> "Prescription trends over time, geographic distribution by postcode, marketing campaign performance—all interactive, all governed, all in one app.
>
> **And here's the kicker**: This dashboard is **shareable**."

**Click "Share" or explain the sharing:**

> "I can share this Streamlit app with the entire marketing team. They open it in their browser, apply their own filters, export data, explore insights—all without SQL, all without waiting for the BI team."

**Competitive wedge:**

> "Compare this to Power BI:
> - **Power BI**: Separate service, data must be extracted to Power BI workspace, Premium licensing required for sharing
> - **Streamlit in Snowflake**: Native to platform, queries live data, no separate infrastructure, share with a link
>
> **And it's Python-based**, which means your data science team can build these dashboards using the same language they use for ML models. One skill set, one platform."

**Talking point - Development velocity:**

> "This dashboard—KPIs, charts, filters, interactivity—was built in under 300 lines of Python. No complex BI tool configuration, no semantic layer setup in a separate tool. Just Python code deployed to Snowflake.
>
> Your team can iterate on dashboards at the speed of code, version control them in Git, and deploy them instantly.
>
> **And it scales effortlessly**: We're running this on 100 million patients. Tomorrow, if you scale to 500 million, the dynamic table handles it automatically—no dashboard changes, no performance tuning."

**Timing checkpoint**: 8 minutes elapsed

---

### Demo Point 3: Snowflake Notebooks - ML Development (Optional - 1 minute if time permits)

**Script reference**: `sql/demo_scripts/vignette3/01_patient_churn_notebook_demo.sql`

**Navigation**: Projects → Notebooks (or Snowsight → Worksheets if running SQL demo version)

**Setup:**

> "Your data science team needs to build predictive models—patient churn prediction, prescription forecasting, Smart Reminders. They work in Python, notebooks, and want access to production data without complex authentication or data movement.
>
> **Snowflake Notebooks bring the notebook environment directly to your data.**"

**Action**: Show pre-run Notebook results (or execute key sections of SQL version)

**If using UI Notebook (preferred):**
- Open a pre-configured notebook with patient churn analysis
- Show executed cells with results

**If using SQL demo version:**
- Navigate to Worksheets
- Execute sections from `sql/demo_scripts/vignette3/01_patient_churn_notebook_demo.sql`

**Point to the feature engineering:**

> "Look at this analytical workflow. We're creating:
> - **Patient churn features** - recency of last prescription, prescription frequency trends, value tier movement
> - **Marketing engagement metrics** - interaction counts, conversion rates, campaign responsiveness
> - **Risk segmentation** - high/medium/low churn risk based on multiple signals
>
> All of this is running on 100,000 patient records, using Snowflake's compute, with no data movement outside your governance boundary."

**Scroll to or execute the churn risk scores section:**

```sql
-- Show churn risk distribution (from the SQL demo script)
SELECT 
    churn_risk_category,
    COUNT(*) as patient_count,
    ROUND(AVG(lifetime_value_gbp), 2) as avg_lifetime_value,
    ROUND(AVG(days_since_last_prescription), 0) as avg_days_inactive
FROM [churn_scores_table]
GROUP BY churn_risk_category;
```

**Point to results:**

> "Here are your high-risk churn patients—[X] patients worth an average of £[Y] each who haven't had a prescription in [Z] days. This is actionable intelligence.
>
> **But here's the critical part**: These churn scores aren't trapped in a data science notebook or S3 bucket. Watch what we do next..."

**Timing checkpoint**: 9 minutes elapsed (if Notebooks shown) OR 8 minutes (if skipped)

---

### Demo Point 4: From ML to Business Action - Closing the Loop (1.5 minutes)

**Navigation**: Data → PHARMACY2U_GOLD → DATA_PRODUCTS → Tables (or reference Organizational Listings)

**Setup:**

> "This is where most companies fail with ML—the **last mile problem**. Data scientists build brilliant models, predictions sit in files, and business teams never consume them because there's no easy path from model output to action.
>
> **Snowflake solves this with data products:**"

**Action**: Show that churn scores or ML outputs can be published as internal data products

**Reference the Organizational Listings from Vignette 2:**

> "Remember the internal marketplace from Vignette 2? We have **real Snowflake organizational listings** already published—including a Churn Risk Scores listing.
>
> Your data science team built these predictions. **They're now discoverable in the internal marketplace**:
> - Marketing searches 'churn' in Data Products → Private Sharing → Listings
> - Finds 'Pharmacy2U ML Churn Risk Predictions' listing
> - Reads the documentation: what it predicts, how to use it, sample queries
> - Requests access (routed to ML team lead for approval)
> - Instantly queries churn scores using the Uniform Listing Locator
> - Joins with campaign data to launch retention campaigns
>
> **This is the last-mile connection**: ML predictions → data product → business action. All within Snowflake, all governed, all instant.
>
> **Zero data movement. Zero complex integrations. Zero delay from model to marketing campaign.**"

**Alternative - Show SQL join:**

```sql
-- Marketing uses churn scores immediately
SELECT 
    p.patient_id,
    p.first_name,
    p.email,
    c.churn_risk_category,
    c.recommended_action,
    m.last_marketing_touchpoint
FROM PATIENTS p
JOIN CHURN_RISK_SCORES c ON p.patient_id = c.patient_id
JOIN MARKETING_HISTORY m ON p.patient_id = m.patient_id
WHERE c.churn_risk_category = 'High'
  AND p.customer_tier IN ('Gold', 'Platinum')
LIMIT 100;
```

**Point to the query:**

> "Marketing just self-served the churn predictions, joined them with customer data, and identified 100 high-value at-risk patients to contact today. **This is the smooth MLOps delivery you asked for, Mustafa.**
>
> Model training happens in Snowflake. Predictions are scored in Snowflake. Business consumption happens in Snowflake. All governed, all traceable, all within your security boundary."

**Timing checkpoint**: 10.5 minutes elapsed (if Notebooks shown) OR 9.5 minutes (if skipped)

---

### Demo Point 5: Cortex AI Functions - Serverless AI Capabilities (1.5 minutes)

**Script reference**: `sql/features/cortex/cortex_ai_functions.sql`

**Navigation**: Worksheets → New query

**Setup:**

> "Beyond custom ML models, Snowflake provides serverless AI functions for common tasks—sentiment analysis, text classification, summarization, translation. No infrastructure, no model training, just SQL functions.
>
> Let me show you patient feedback analysis:"

**Action**: Execute sentiment analysis query

```sql
-- Analyze patient feedback sentiment (reference from cortex_ai_functions.sql)
SELECT 
    feedback_id,
    patient_id,
    feedback_text,
    SNOWFLAKE.CORTEX.SENTIMENT(feedback_text) AS sentiment_score,
    CASE
        WHEN SNOWFLAKE.CORTEX.SENTIMENT(feedback_text) > 0.7 THEN 'Very Positive'
        WHEN SNOWFLAKE.CORTEX.SENTIMENT(feedback_text) > 0.3 THEN 'Positive'
        WHEN SNOWFLAKE.CORTEX.SENTIMENT(feedback_text) BETWEEN -0.3 AND 0.3 THEN 'Neutral'
        WHEN SNOWFLAKE.CORTEX.SENTIMENT(feedback_text) < -0.7 THEN 'Very Negative'
        ELSE 'Negative'
    END AS sentiment_category
FROM PATIENT_FEEDBACK
LIMIT 10;
```

**Point to results:**

> "Look at this—we just analyzed patient feedback sentiment using a large language model, directly in SQL. No API calls to external services, no data leaving Snowflake, no infrastructure to manage.
>
> **SNOWFLAKE.CORTEX.SENTIMENT()** - that's it. One SQL function. Production-ready AI.
>
> This works for:
> - **SENTIMENT**: Understand patient satisfaction from free-text feedback
> - **SUMMARIZE**: Condense long clinical notes or support tickets
> - **TRANSLATE**: Multilingual patient communication
> - **CLASSIFY**: Categorize feedback into issue types automatically
> - **EXTRACT_ANSWER**: Pull specific information from unstructured text
>
> All serverless. All governed. All integrated with your data."

**Competitive wedge:**
> "In Azure, you'd use Cognitive Services (separate service), Azure OpenAI (separate service), authenticate separately, move data via APIs, manage keys and endpoints. 
>
> Snowflake: **One SQL function. Done.**"

**Timing checkpoint**: 12 minutes elapsed

---

### Demo Point 6: Snowflake Marketplace - External Data Enrichment (1.5 minutes)

**Navigation**: Data → Marketplace (Snowsight Marketplace UI)

**Setup:**

> "Final capability: **Snowflake Marketplace**—instant access to external datasets that can enrich your internal data. No procurement process, no data downloads, no ETL."

**Action**: Browse marketplace categories

**Click**: Healthcare, Demographics, or UK Data categories

**Point to available datasets:**

> "Thousands of data products available instantly:
> - **UK postcode demographics** - population density, deprivation indices, health statistics
> - **Drug databases** - medication interactions, contraindications, formulary data
> - **Clinical datasets** - disease prevalence, treatment outcomes, healthcare benchmarks
> - **Weather data** - for demand forecasting (prescriptions spike during flu season)
>
> These aren't just catalog listings—many are **live data shares**. You don't download anything. The provider's data stays in their account, you query it directly. Instant access, always up-to-date."

**Reference the implementation:**

**Script**: `sql/features/marketplace/snowflake_marketplace_integration.sql`

> "In our demo environment, we've simulated this with external UK postcode demographics. Watch what happens when we enrich Patient 360 data with external sources:"

**Show enriched view or execute query (if time):**

```sql
-- Enriched patient demographics (from marketplace integration script)
SELECT 
    p.patient_id,
    p.age,
    p.postcode,
    p.lifetime_value_gbp,
    ext.region_name,
    ext.area_deprivation_index,
    ext.area_health_index,
    CASE 
        WHEN ext.area_deprivation_index >= 7 THEN 'High Deprivation Area'
        ELSE 'Lower Deprivation Area'
    END AS deprivation_category
FROM V_PATIENT_360 p
LEFT JOIN EXTERNAL_UK_POSTCODE_DEMOGRAPHICS ext
    ON LEFT(p.postcode, 2) = ext.postcode_prefix
LIMIT 10;
```

**Point to the enrichment:**

> "Now we know:
> - Which patients are in high-deprivation areas (might need different support services)
> - Health indices for their regions (contextualizes prescription patterns)
> - Population density (impacts delivery logistics)
>
> **This enrichment happened with zero data movement.** We joined our internal patient data with external marketplace data, all within Snowflake, all governed.
>
> This is how you accelerate innovation—instant access to third-party data that would normally take months of procurement and integration."

**Timing checkpoint**: 13.5 minutes elapsed

---

## TELL #2 - Reinforce Value (2.5 minutes)

### Business Impact Summary (90 seconds)

> "Let me bring together what you just saw and what it means for Pharmacy2U's AI ambitions:
>
> **Data Democratization**:
> - Marketing managers: **2-3 day wait for analysts → 10-second self-service**
> - Business questions answered: **5-10 per week (analyst-limited) → unlimited**
> - Campaign velocity: **Weekly planning cycles → daily optimization**
> - Analyst capacity: **60% ad-hoc queries → 80% strategic work**
>
> **ML Acceleration**:
> - Time to production: **Months of integration → same-day deployment**
> - Data movement for training: **Risky copies to ML platforms → zero, stays in Snowflake**
> - From model to business action: **Weeks of dev work → instant data product consumption**
> - MLOps complexity: **Custom infrastructure → platform-native capabilities**
>
> **AI Capabilities**:
> - Sentiment analysis setup time: **Weeks to integrate Azure Cognitive Services → one SQL function**
> - External data procurement: **Months of legal/procurement → instant marketplace access**
> - Governance for AI: **Separate security configurations → inherits Snowflake policies automatically**
>
> **The 'Smooth Delivery' Experience**:
> - Data scientists work in native environment (Python, notebooks, SQL)
> - Everything stays within Snowflake's security boundary—no PII exposure risk
> - Predictions and insights are immediately consumable by business teams
> - Full lineage from raw data → model → prediction → business decision
> - One platform for the entire AI lifecycle
>
> Mustafa, this is the **smooth delivery** you asked for. No custom infrastructure, no complex integrations, no security trade-offs. Just data → insight → action, all governed."

---

### Competitive Differentiation vs Microsoft Fabric (60 seconds)

> "Microsoft is positioning Fabric as an AI platform. Let me be very direct about the differences:
>
> **Snowflake Intelligence + Streamlit**:
> - Natural language queries + interactive dashboards, both native to platform
> - Semantic models uploaded once, available to all tools
> - Python-based dashboards with no separate BI infrastructure
> - Serverless, pay-per-query
> - **Performance**: Materialized dynamic tables enable sub-second queries on 100M+ records
> - **Auto-optimization**: No manual aggregations or query tuning required
>
> **Power BI Q&A + Power BI (Fabric equivalent)**:
> - Requires data copy to Power BI Premium workspace
> - Separate semantic model configuration in Power BI
> - Separate BI service to manage and license
> - Power BI Premium: £4,995/month minimum capacity
> - **Performance**: Manual aggregation configuration required for large datasets
> - **Optimization**: Separate import vs DirectQuery tradeoffs to manage
>
> **Snowflake Cortex AI Functions**:
> - Native SQL functions (SENTIMENT, SUMMARIZE, TRANSLATE)
> - No separate service to configure
> - Pay only when executing functions
>
> **Azure Cognitive Services / Azure OpenAI (Fabric integration)**:
> - Separate services requiring authentication, endpoints, API management
> - Data movement via APIs (security and latency concerns)
> - Separate billing and resource management
>
> **Snowflake Marketplace**:
> - 1,000+ datasets, instant access, zero-copy sharing
> - Live data, always current
> - Integrated billing
>
> **Fabric equivalent**:
> - No equivalent marketplace for instant data access
> - Must procure and ingest separately
>
> **The Strategic Difference**:
> - Snowflake: **One platform, integrated AI, governed by default**
> - Fabric: **Assemble multiple Azure services, manage integration complexity**
>
> You're choosing between:
> - **Snowflake**: A data platform with AI built-in, ready for production
> - **Fabric**: A collection of Microsoft services you integrate yourself
>
> For a lean team with ambitious AI goals, you need the platform that accelerates time-to-value, not one that gives you homework."

---

### Closing Summary - The Complete Story (30 seconds)

> "Let me close by connecting all three vignettes:
>
> **Vignette 1**: We unified fragmented data sources into a governed Patient 360 foundation. **Same-day integration** instead of months.
>
> **Vignette 2**: We made that foundation **unbreakable and discoverable**—automated governance, 30-second incident recovery, and a real internal marketplace with published organizational listings for data products.
>
> **Vignette 3**: We put that foundation to work with AI—**democratized self-service analytics** for business users, **smooth MLOps delivery** for data science, and **serverless AI capabilities** for everyone.
>
> This is the complete Snowflake Data Cloud:
> - **One platform** - not five separate services to stitch together
> - **One copy of data** - no risky movement or duplication
> - **One governance model** - policies that follow data everywhere
> - **One skill set** - SQL for engineering, English for business users
>
> **Your current state**: Fragmented systems, SSIS maintenance overhead, P1 incidents every two weeks, 3-4 months per acquisition, ML projects that struggle to reach production.
>
> **Your future state with Snowflake**: Unified platform, automated operations, near-zero incidents, same-day data integration, AI from prototype to production without friction.
>
> The question isn't whether Snowflake can solve your challenges—you just watched us do it. **The question is: when do you want to start?**"

**[Pause - open the floor]**

---

## Backup Plan (If Live Demo Fails)

### If Intelligence Agent Fails or is Slow:

**Option 1**: Use screenshots from `docs/screenshots/vignette3/intelligence/`
> "I have screenshots from our testing phase showing these exact queries. Let me walk you through..." [Show pre-captured Query 4 results]

**Option 2**: Run the SQL manually in Worksheets
> "The agent is having issues, but let me show you the actual query it would generate..." [Execute SQL from semantic model verified queries]

**Option 3**: Reference the semantic model YAML
> "While we troubleshoot, let me show you the semantic model that powers this..." [Open `config/semantic_models/patient_360_analytics.yaml`]

---

### If Notebooks Unavailable:

**Fallback**: Run SQL demo script instead
> "The Notebooks UI isn't loading, but I can show you the same analytical workflow in SQL..." [Execute `sql/demo_scripts/vignette3/01_patient_churn_notebook_demo.sql` sections]

**Alternative**: Explain the concept with pre-run results
> "Here are the outputs from when we ran this analysis..." [Show saved results or screenshots]

---

### If Marketplace is Empty or Slow:

**Fallback**: Show the simulated marketplace integration
> "While the live marketplace loads, let me show you how we've integrated external data in our demo..." [Run queries from `sql/features/marketplace/snowflake_marketplace_integration.sql`]

**Alternative**: Describe the value conceptually
> "The marketplace has over 1,000 datasets. Let me describe a few use cases specific to pharmaceutical..." [Talk through examples]

---

### If Cortex AI Functions Fail:

**Fallback**: Show the function syntax and explain
> "The function isn't executing, but here's how simple it is..." [Show the SQL with CORTEX.SENTIMENT(), explain the concept]

**Alternative**: Show query history with past successful execution
> "Let me show you when this ran successfully earlier..." [Navigate to Query History]

---

## Talking Points Cheat Sheet

**Print this for quick reference during demo:**

| Moment | Key Talking Point | Time |
|--------|-------------------|------|
| **Opening** | "Smooth MLOps delivery—no infrastructure complexity, no security trade-offs" | 0:00 |
| **Intelligence Q1-3** | "Self-service analytics—marketing does it themselves in seconds" | 2:00 |
| **Intelligence Q4** | "4,927 patients, 10 seconds, actionable today. 2-3 days → instant." ⭐⭐⭐ | 3:30 |
| **Intelligence Q5-6** | "Conversational AI, remembers context, fully governed" | 5:00 |
| **Streamlit Dashboard** | "Python dashboards native to Snowflake—no separate BI server" ⭐⭐ | 8:00 |
| **Notebooks** | "Optional: Data science environment native to platform" | 9:00 |
| **ML to Business** | "Last mile solved—predictions become data products instantly" | 10:30 |
| **Cortex AI** | "Serverless LLM functions—one SQL call, production-ready" | 12:00 |
| **Marketplace** | "1,000+ datasets, zero-copy access, instant enrichment" | 13:30 |
| **Impact** | "Days → seconds. Infrastructure → serverless. Risky → governed." | 14:00 |
| **vs Fabric** | "One platform vs service assembly. Built-in AI vs integration homework." | 14:30 |
| **Close** | "When do you want to start?" | 15:00 |

---

## Success Indicators

**You nailed Vignette 3 if:**
- ✅ Audible "wow" when Query 4 returns 4,927 patients in 10 seconds
- ✅ Mustafa asks "Can we deploy custom models this way too?"
- ✅ Someone says "This solves our last-mile problem"
- ✅ Questions about rollout timeline, not feasibility
- ✅ Discussion shifts to which AI use cases to prioritize first

---

## Quick Navigation Reference

**Snowsight UI Paths:**
- **Intelligence**: Snowflake Intelligence → Agents → PATIENT_360_AGENT
- **Notebooks**: Projects → Notebooks
- **Marketplace**: Data → Marketplace
- **Cortex Functions**: Any Worksheet → Use SNOWFLAKE.CORTEX.* functions

**Key SQL Scripts:**
- Churn analysis: `sql/demo_scripts/vignette3/01_patient_churn_notebook_demo.sql`
- Cortex AI functions: `sql/features/cortex/cortex_ai_functions.sql`
- Marketplace integration: `sql/features/marketplace/snowflake_marketplace_integration.sql`

**Intelligence Queries (memorize these):**
1. How many patients do we have?
2. What are the top 5 most prescribed drugs this year?
3. For Atorvastatin, what is the patient age breakdown?
4. **Of patients over 65, how many haven't converted on Heart Health campaign?** ⭐
5. What is the average lifetime value of these patients?
6. Show me the distribution of high-value patients by region

---

**Vignette 3 Duration**: 13-14 minutes  
**Difficulty**: Medium (requires Intelligence UI comfort, query delivery)  
**Impact**: Very High (demonstrates AI/ML differentiation, closes the sale)  
**Key Moment**: Query 4 - the "4,927 patients in 10 seconds" revelation  

**Ready? Show them the future of AI on the Data Cloud!** 🚀

---

## Post-Demo Next Steps

After completing all three vignettes:

### **Immediate Actions** (in the meeting):
- [ ] Ask: "What questions do you have?"
- [ ] Offer: "Would you like hands-on access to try this yourself?"
- [ ] Propose: "Can we schedule a follow-up to discuss POC scope?"

### **Follow-Up** (same day):
- [ ] Send summary email with key takeaways
- [ ] Share access to demo environment (if approved)
- [ ] Provide pricing comparison vs Fabric (if requested)

### **Proof of Concept Planning** (next week):
- [ ] Define 2-3 priority use cases for POC
- [ ] Identify data sources for integration
- [ ] Set 30-day POC timeline
- [ ] Assign Pharmacy2U and Snowflake resources

---

**You've completed the full 45-minute demo! Take a breath, field questions, and close the deal.** 💪✨
