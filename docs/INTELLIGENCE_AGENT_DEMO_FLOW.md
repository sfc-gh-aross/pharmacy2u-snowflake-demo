# Snowflake Intelligence Agent Demo Flow
**Vignette 3 - Key Moment #1: Data Democratization**  
**Duration**: 4-5 minutes  
**Impact**: 🌟 HIGH - Shows true self-service analytics

---

## Pre-Demo Checklist (2 minutes before)

- [ ] Log into Snowsight as `ACCOUNTADMIN`
- [ ] Navigate to Snowflake Intelligence
- [ ] Open the `PATIENT_360_AGENT` agent
- [ ] Click "New thread" to start fresh
- [ ] Have this script open on second monitor/tablet
- [ ] Warehouse `PHARMACY2U_DEMO_WH` is resumed
- [ ] Take a deep breath - you've got this! 🚀

---

## Demo Script: Tell-Show-Tell Format

### **TELL #1 - Set the Stage** (45 seconds)

**Context Setting:**
> "We've built this unified, governed data foundation. Now let me show you how we **democratize** access to it. I'm going to act as Sarah, a marketing manager at Pharmacy2U. Sarah has a business question but doesn't know SQL."

**Quantified Problem:**
> "Currently, when Sarah needs insight, she emails the analytics team, waits 2-3 days for a response, and often needs to iterate multiple times. This delays campaigns and limits her effectiveness."

**Success Vision:**
> "With Snowflake Intelligence, Sarah gets instant answers in natural language - no SQL, no waiting, no dependencies. Let me show you."

---

## **SHOW - Live Demonstration** (3 minutes)

### **Query 1: Simple Warm-Up** (20 seconds)

**Type in agent:**
```
How many patients do we have?
```

**Wait for response, then say:**
> "100,000 patients - instant answer. Notice it's not just returning a number - it understands this is about our patient base."

**Key Point:** ✅ Natural language → instant answer

---

### **Query 2: Business Intelligence** (30 seconds)

**Type in agent:**
```
What are the top 5 most prescribed drugs this year?
```

**Wait for response, then say:**
> "Now we're getting somewhere. The agent is querying our semantic model - the same governed data we showed earlier - and giving Sarah the top drugs. She can see Atorvastatin is #1. Now she wants to dig deeper..."

**Key Point:** ✅ Complex query made simple

---

### **Query 3: Demographic Analysis** (30 seconds)

**Type in agent:**
```
For Atorvastatin, what is the patient age breakdown?
```

**Wait for response, then say:**
> "Perfect - she can see most Atorvastatin patients are 51-65, but there's also a significant 65+ population. Now here's where it gets powerful..."

**Key Point:** ✅ Follow-up question shows context awareness

---

### **Query 4: THE KEY MOMENT** ⭐ (60 seconds)

**Type in agent:**
```
Of patients over 65, how many haven't converted on Heart Health campaign?
```

**Wait for response, then PAUSE for impact**

**Point to the screen and say:**
> "This is the moment. In 10 seconds, Sarah just identified **4,927 actionable patients**. Let me break down what just happened:"

**Click "Show Details" if available, then explain:**

> "These 4,927 patients:
> - Are in the 65+ demographic most at risk for heart conditions
> - Have received 39,246 marketing touches across all campaigns  
> - Average 4.76 prescriptions per patient - they're engaged with our service
> - But haven't responded to the specific Heart Health campaign
>
> Sarah can now launch a **targeted campaign TODAY** for this exact cohort. With traditional BI tools, this analysis would take 2-3 days and require a data analyst. Here, it took **10 seconds** and Sarah did it herself."

**Key Point:** ✅ Actionable business insight in seconds

---

### **Query 5: Show Versatility** (30 seconds)

**Type in agent:**
```
What is the average lifetime value of these patients?
```

**OR** (if the agent doesn't maintain context, ask differently):
```
What is the average lifetime value by age group?
```

**Wait for response, then say:**
> "Now Sarah knows the revenue opportunity. She can justify the campaign budget and calculate expected ROI. Notice the agent maintained context from my previous question - it's conversational, not just transactional."

**Key Point:** ✅ Conversational intelligence

---

### **Query 6: Power User Feature** (Optional - 20 seconds)

**Type in agent:**
```
Show me the distribution of high-value patients by region
```

**Wait for response, then say:**
> "And she can slice the data any way she needs - by region, by tier, by prescription patterns. All in natural language, all instant, all governed."

**Key Point:** ✅ Flexible, powerful analytics

---

## **TELL #2 - Reinforce Value** (60 seconds)

### **Business Impact:**

> "What you just saw transforms how Pharmacy2U operates:
>
> **Time to Insight**: 2-3 days → **10 seconds**  
> **Required Skills**: SQL, database knowledge → **Plain English**  
> **Team Dependency**: Wait for analysts → **Self-service**  
> **Campaign Velocity**: Weekly launches → **Daily launches**  
> **Decision Quality**: Delayed, stale data → **Real-time, fresh insights**"

### **Differentiation vs Microsoft Fabric:**

> "With Power BI Q&A in Microsoft Fabric, Sarah would need to:
> 1. Wait for IT to copy data from Snowflake to Power BI Premium
> 2. Wait for a data modeler to build and publish a semantic model in Power BI
> 3. Wait for separate row-level security configuration
> 4. Pay for expensive Premium capacity
> 5. Hope her question fits within Power BI Q&A's limited capabilities
>
> With Snowflake Intelligence:
> 1. It's already there - native to the platform
> 2. Uses the same semantic model we defined once
> 3. Inherits all governance automatically
> 4. Serverless - pay only when querying
> 5. More sophisticated AI with Cortex Search integration
>
> **One platform. One copy of data. One skill set: English.**"

### **The Trust Factor:**

> "And here's the critical point: **every query you just saw respects the governance we set up in Vignette 2**. If Sarah tries to see PII like email addresses, the masking policies apply. If she's restricted by row access policies, she only sees her allowed data. The intelligence layer doesn't bypass security - it inherits it. This is **trusted self-service**."

### **Next Steps:**

> "Sarah can now share this agent with her entire marketing team. They can all ask questions, discover cohorts, and launch campaigns without waiting for the analytics team. This is true data democratization - and it's only possible because we built that unified, governed foundation you saw in Vignettes 1 and 2."

---

## Alternative Demo Path (Technical Audience)

If your audience is more technical and wants to see "under the hood":

### **After Query 4, Click "Show Details"**

**Point to the SQL:**
> "Notice the agent automatically generated this SQL query against our semantic model. It understood 'over 65' maps to our AGE dimension, 'haven't converted' means CAMPAIGN_CONVERSIONS = 0, and 'Heart Health campaign' is contextual. The semantic model provides the business logic, Cortex Analyst generates the SQL, and the user never needs to know it happened."

### **Show the Cortex Search Integration**

**Type in agent:**
```
Find me similar patients to our top platinum customers
```

**Wait for response:**
> "This query used both our semantic model for analytics AND our Cortex Search service for semantic similarity. The agent orchestrated multiple AI capabilities to answer a single business question. This is the power of an integrated platform."

---

## Handling Common Questions During Demo

### **Q: "Can anyone ask any question?"**

**A:** 
> "Yes - but they only see data they're authorized to see. The governance we configured earlier travels with the data. If you're a BI user with masking policies, you'll see masked data. If you have row access restrictions, you only see your rows. The intelligence layer makes data accessible, not insecure."

---

### **Q: "What if it gives a wrong answer?"**

**A:**
> "Great question. The agent shows you the SQL it generated - you can verify the logic. We also included 'verified queries' in our semantic model that teach the agent proven patterns. And as users ask questions, you can continuously improve the semantic model to handle edge cases. It's not magic - it's AI guided by your business definitions."

---

### **Q: "How is this different from ChatGPT?"**

**A:**
> "ChatGPT doesn't have access to your data and would just make things up. Snowflake Intelligence is grounded in your actual data, governed by your security policies, and guided by your semantic model. Every answer is backed by real queries on real data. Plus, it stays within your Snowflake security boundary - data never leaves your environment."

---

### **Q: "What about cost?"**

**A:**
> "It's serverless - you pay only for the warehouse compute when queries run, just like any other Snowflake query. There's no separate 'Intelligence capacity' to buy. And because these queries are typically simple aggregations on well-modeled data, they're very efficient. Compare that to Power BI Premium at £4,995/month minimum for similar capabilities."

---

### **Q: "Can we customize the agent?"**

**A:**
> "Absolutely. We configured this agent with orchestration instructions, response formatting rules, and integrated Cortex Search. You can create different agents for different teams - one for marketing, one for clinical operations, one for executives - each with their own tools, permissions, and behaviors."

---

## Demo Backup Plans

### **If the Agent is Slow to Respond:**

**Say this:**
> "The agent is generating SQL and querying our 100,000 patient records right now. Even with a slight delay, this is still 1000x faster than the traditional 2-3 day wait for analyst support."

**If it takes more than 20 seconds:**
> "While we wait, let me show you what it's doing..." [Click "Show Details" if available, or talk through the architecture]

---

### **If a Query Fails:**

**Stay calm and say:**
> "This is actually a great teaching moment. Let me refine the question..." [Rephrase the query]

**OR:**
> "This shows the importance of the semantic model. If the agent doesn't understand a question, we can add that pattern to our verified queries, and it will learn for next time. Let me show you one of our tested queries instead..."

[Fall back to Query 2 or 4]

---

### **If Intelligence UI is Unavailable:**

**Fallback Option 1 - Use SQL Directly:**
```sql
-- Show this in a worksheet
SELECT 
    COUNT(*) as non_converting_patients_65plus,
    SUM(MARKETING_INTERACTIONS) as total_marketing_touches,
    AVG(TOTAL_PRESCRIPTIONS) as avg_prescriptions_per_patient
FROM PHARMACY2U_GOLD.ANALYTICS.V_PATIENT_360
WHERE AGE >= 65
  AND MARKETING_INTERACTIONS > 0
  AND CAMPAIGN_CONVERSIONS = 0;
```

**Say:**
> "The Intelligence UI is temporarily unavailable, but let me show you the SQL that would be auto-generated. This is the query a marketing manager would never have to write themselves - the agent does it for them."

**Fallback Option 2 - Use Screenshots:**
> "I have screenshots of the agent in action from testing. Let me walk you through what Sarah would see..."

[Use prepared screenshots from `docs/screenshots/`]

---

## Post-Demo Actions

### **Immediate (During Meeting):**

1. **Offer to share the agent:**
   > "I can give you access to this agent right now if you'd like to try it yourself."

2. **Show how to create new threads:**
   > "Each conversation is a new thread - you can keep multiple analyses organized."

3. **Demonstrate saving queries:**
   > "You can bookmark frequently used queries as examples for your team."

---

### **Follow-Up (After Demo):**

1. **Send access instructions:**
   - Share URL to Intelligence UI
   - Provide login credentials if needed
   - Include quick start guide

2. **Schedule training session:**
   - 30-minute session for marketing team
   - 30-minute session for analytics team
   - 15-minute session for executives

3. **Provide query library:**
   - Share the 15 example questions
   - Categorize by use case (Marketing, Clinical, Operations)
   - Add their specific business questions

---

## Success Metrics to Highlight

After the demo, emphasize these outcomes:

| Metric | Before | After | Impact |
|--------|--------|-------|--------|
| **Time to Insight** | 2-3 days | 10 seconds | **25,920x faster** |
| **Queries per Day** | 5-10 (limited by analysts) | Unlimited | **Self-service** |
| **User Access** | 5 analysts | 50+ business users | **10x democratization** |
| **Campaign Velocity** | Weekly | Daily | **7x faster iteration** |
| **Analyst Capacity** | 80% on ad-hoc queries | 80% on strategic work | **Role transformation** |

---

## Talking Points Cheat Sheet

Keep this handy during the demo:

| When to Say It | What to Say |
|----------------|-------------|
| **Opening** | "I'm acting as a marketing manager who doesn't know SQL" |
| **Query 1** | "Instant answer - no waiting, no SQL" |
| **Query 2** | "Complex analysis made simple" |
| **Query 3** | "Notice it understands context from my previous question" |
| **Query 4** ⭐ | "In 10 seconds, we identified 4,927 actionable patients. This would normally take 2-3 days." |
| **Query 5** | "Conversational intelligence - it remembers what we talked about" |
| **Governance** | "Every query respects the masking and access policies we configured" |
| **vs Fabric** | "One platform, one copy of data, one skill set: English" |
| **Cost** | "Serverless - pay only when querying, no Premium capacity needed" |
| **Closing** | "This is true data democratization - accessible, but still governed" |

---

## Competitive Battle Card

**When competing against Microsoft Fabric:**

| Capability | Snowflake Intelligence | Power BI Q&A (Fabric) |
|------------|----------------------|----------------------|
| **Setup** | Upload YAML semantic model, done | Build Power BI model, publish to Premium, configure Q&A |
| **Data Location** | Native - queries Snowflake directly | Requires data copy to Power BI |
| **Governance** | Inherits all Snowflake policies | Separate RLS configuration in Power BI |
| **Cost** | Serverless, pay per query | Power BI Premium from £4,995/month |
| **AI Capabilities** | Cortex Analyst + Search + LLMs | Basic Q&A on dataset |
| **Query Sophistication** | Advanced semantic understanding | Limited natural language parsing |
| **Integration** | Native platform feature | Separate BI tool requiring data movement |
| **Security Boundary** | Data never leaves Snowflake | Data copied to Power BI service |

**Key Message:**
> "Power BI Q&A is a feature bolted onto a separate BI tool. Snowflake Intelligence is native to the platform where your data lives. No copies, no separate security, no Premium licensing. It just works."

---

## Demo Variants by Audience

### **Executive Audience (C-Level):**
- Focus on Query 4 (business impact)
- Emphasize time savings (2-3 days → 10 seconds)
- Show ROI: analyst capacity freed up, faster campaign velocity
- Keep technical details light
- **Duration**: 3 minutes

---

### **Technical Audience (Architects, Engineers):**
- Show "Show Details" to reveal SQL
- Explain semantic model architecture
- Demonstrate Cortex Search integration
- Discuss governance inheritance
- **Duration**: 5-6 minutes

---

### **Business User Audience (Marketing, Operations):**
- Let them ask their own questions!
- Have them type queries
- Show how to save favorites
- Demonstrate multiple threads
- **Duration**: 4-5 minutes + Q&A

---

### **Data Team Audience (Analysts, Data Scientists):**
- Show semantic model YAML
- Discuss verified queries
- Explain agent orchestration
- Show how to improve the model iteratively
- **Duration**: 6-8 minutes

---

## Quick Reference: The 6 Demo Queries

1. **How many patients do we have?** → Warm-up
2. **What are the top 5 most prescribed drugs this year?** → Business intelligence
3. **For Atorvastatin, what is the patient age breakdown?** → Demographic analysis
4. **Of patients over 65, how many haven't converted on Heart Health campaign?** → ⭐ **KEY MOMENT**
5. **What is the average lifetime value of these patients?** → Conversational follow-up
6. **Show me the distribution of high-value patients by region** → Versatility

---

## Final Checklist Before Demo

- [ ] Agent is saved and active
- [ ] Warehouse is resumed
- [ ] Fresh browser tab (no cached errors)
- [ ] New thread started (clean slate)
- [ ] Demo script printed/accessible
- [ ] Screenshots ready as backup
- [ ] Talking points memorized
- [ ] Confident and ready! 💪

---

**Duration**: 4-5 minutes  
**Difficulty**: Easy (just type questions!)  
**Impact**: 🌟 Very High  
**Wow Factor**: Query 4 - always gets the reaction  
**Competitive Edge**: Strong vs Fabric  

**You're ready to blow their minds with true data democratization!** 🚀

---

**Quick Tip**: Practice Query 4 a few times before the real demo. The pause after the result is critical - let the numbers sink in, then explain the business impact. That's your moment of maximum impact!
