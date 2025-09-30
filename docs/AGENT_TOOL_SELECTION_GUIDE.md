# Intelligence Agent Tool Selection Guide
**Understanding when Cortex Search vs Semantic Model is used**

---

## Quick Reference

| Query Type | Tool Used | Example |
|------------|-----------|---------|
| **Find/Search for patients** | 🔍 Cortex Search | "Find high-value elderly patients" |
| **Count/Aggregate** | 📊 Semantic Model | "How many patients over 65?" |
| **Show me patients like...** | 🔍 Cortex Search | "Show me patients similar to platinum tier" |
| **What is the average/total...** | 📊 Semantic Model | "What is the average lifetime value?" |
| **Discover/Identify cohorts** | 🔍 Cortex Search | "Identify patients at risk of churn" |
| **Top N analysis** | 📊 Semantic Model | "Top 5 prescribed drugs" |
| **Breakdown/Distribution** | 📊 Semantic Model | "Age breakdown of Atorvastatin patients" |

---

## 🔍 Cortex Search Queries (Patient Discovery)

### **Trigger Words:**
- "Find..."
- "Search for..."
- "Show me patients..."
- "Identify patients..."
- "Discover..."
- "Who are the patients..."
- "Give me a list of patients..."
- "Similar to..."
- "Like..."

### **Example Questions that Invoke Cortex Search:**

#### **1. Discovery by Description**
```
Find high-value elderly patients with multiple prescriptions
```
**Returns**: List of matching patient records with PATIENT_ID, CUSTOMER_TIER, etc.

---

#### **2. Look-alike Search**
```
Show me patients similar to our platinum tier customers
```
**Returns**: Patient records that match the profile semantically

---

#### **3. Cohort Identification**
```
Identify patients with high marketing engagement but low conversions
```
**Returns**: Specific patient records matching this behavior pattern

---

#### **4. Pattern Discovery**
```
Find patients at risk of churn based on prescription patterns
```
**Returns**: Patient records with declining activity

---

#### **5. Demographic Discovery**
```
Search for patients over 65 in London area with chronic medication needs
```
**Returns**: Patient records matching these criteria

---

#### **6. Behavioral Search**
```
Who are the patients with consistent prescription refills and good adherence?
```
**Returns**: Patient records with regular patterns

---

#### **7. Value-based Search**
```
Give me a list of gold tier patients with growth potential
```
**Returns**: Patient records in Gold tier with specific characteristics

---

#### **8. Geographic Discovery**
```
Find high-prescription patients in Manchester region
```
**Returns**: Patient records in that geographic area

---

#### **9. Engagement Search**
```
Show me patients who haven't responded to any marketing campaigns
```
**Returns**: Patient records with zero campaign conversions

---

#### **10. Clinical Pattern Search**
```
Identify patients with complex medication regimens
```
**Returns**: Patient records with high unique drug counts

---

## 📊 Semantic Model Queries (Analytics & Aggregation)

### **Trigger Words:**
- "How many..."
- "What is the..."
- "Show me the distribution..."
- "What are the top..."
- "Average..."
- "Total..."
- "Sum of..."
- "Count of..."
- "Breakdown by..."
- "Compare..."

### **Example Questions that Use Semantic Model:**

#### **1. Counting**
```
How many patients do we have?
```
**Returns**: Single number (100,000)

---

#### **2. Top N Analysis**
```
What are the top 5 most prescribed drugs?
```
**Returns**: Aggregated list with counts

---

#### **3. Averages**
```
What is the average lifetime value by age group?
```
**Returns**: Aggregated metrics by category

---

#### **4. Distributions**
```
For Atorvastatin, what is the patient age breakdown?
```
**Returns**: Counts grouped by age ranges

---

#### **5. Percentages**
```
What percentage of patients have engaged with marketing?
```
**Returns**: Calculated percentage

---

#### **6. Totals**
```
What is the total lifetime value of all platinum customers?
```
**Returns**: Sum aggregation

---

#### **7. Comparisons**
```
Compare prescription volumes by gender
```
**Returns**: Side-by-side aggregated metrics

---

#### **8. Conversion Rates**
```
What is our overall marketing campaign conversion rate?
```
**Returns**: Calculated percentage from aggregates

---

#### **9. Regional Aggregates**
```
Show me the distribution of high-value patients by region
```
**Returns**: Grouped counts and sums by region

---

#### **10. Demographic Analysis**
```
Of patients over 65, how many haven't converted on Heart Health campaign?
```
**Returns**: Filtered count with aggregated insights

---

## 🤖 Agent Decision Logic

The agent uses this logic to choose the right tool:

### **Use Cortex Search when:**
- User wants to **find specific patient records**
- Query describes **characteristics to search for**
- User wants **similar patients** or **look-alikes**
- Output should be a **list of patients** with their attributes
- Focus is on **discovery** or **identification**

### **Use Semantic Model when:**
- User wants **counts, sums, averages, or percentages**
- Query asks **"how many"** or **"what is"**
- User wants **aggregated insights** not individual records
- Output should be **metrics** or **summaries**
- Focus is on **analysis** or **measurement**

### **Use Both when:**
- Query has two parts: discovery + analysis
- Example: "Find high-value patients and show me their average age"
  1. Search finds the patients (Cortex Search)
  2. Then aggregate their data (Semantic Model)

---

## 🎯 Demo Queries Mapped to Tools

Here's how the 6 demo queries map:

| Query | Tool | Why |
|-------|------|-----|
| Q1: How many patients? | 📊 Semantic Model | Counting/aggregation |
| Q2: Top 5 drugs? | 📊 Semantic Model | Top N analysis |
| Q3: Atorvastatin age breakdown? | 📊 Semantic Model | Distribution/grouping |
| Q4: 65+ non-converters count? | 📊 Semantic Model | Filtered count |
| Q5: Average lifetime value? | 📊 Semantic Model | Average aggregation |
| Q6: High-value by region? | 📊 Semantic Model | Distribution by geography |

**Note**: All 6 core demo queries use the Semantic Model for analytics!

---

## 🔍 Additional Search-Specific Demo Queries

Want to show off Cortex Search? Add these to your demo:

### **Search Demo Query 1: Patient Discovery**
```
Find platinum tier patients over 65 with high prescription volumes
```
**What happens**: 
- Cortex Search returns up to 10 matching patient records
- Shows PATIENT_ID, CUSTOMER_TIER, AGE_GROUP, TOTAL_PRESCRIPTIONS
- Semantic understanding of "platinum tier", "over 65", "high volumes"

---

### **Search Demo Query 2: Look-alike Modeling**
```
Show me patients similar to our best customers
```
**What happens**:
- Cortex Search finds patients with similar characteristics to top performers
- Returns patient records with high lifetime value and engagement

---

### **Search Demo Query 3: Marketing Opportunities**
```
Identify gold tier patients who haven't converted but are highly engaged
```
**What happens**:
- Cortex Search finds specific patients matching this profile
- Marketing can target these individuals directly

---

### **Search Demo Query 4: Geographic Targeting**
```
Find high-value patients in London area
```
**What happens**:
- Cortex Search filters by postcode semantically
- Returns patient records in that region

---

## 🎬 Demo Flow Option: Show Both Tools

If you want to demonstrate the difference between Search and Analytics:

### **Part 1: Analytics (Semantic Model)**
**You**: "How many patients over 65 haven't converted on Heart Health campaign?"  
**Agent**: Uses Semantic Model → Returns count: 4,927

**Say**: "That's the count - now let me find the actual patients..."

### **Part 2: Discovery (Cortex Search)**
**You**: "Find patients over 65 who haven't converted on Heart Health campaign"  
**Agent**: Uses Cortex Search → Returns list of 10 patient records

**Say**: "Now marketing has specific PATIENT_IDs to target. The first query told us HOW MANY. This query shows us WHO THEY ARE."

---

## 💡 Pro Tips for Invoking Search

### **To Force Cortex Search, Use These Phrases:**

✅ **"Find..."** - Strong search trigger  
✅ **"Show me patients..."** - Returns individual records  
✅ **"Identify..."** - Discovery mode  
✅ **"Give me a list..."** - Implies individual records  
✅ **"Search for..."** - Explicit search command  
✅ **"Who are the patients..."** - Returns individuals  

### **To Force Semantic Model, Use These Phrases:**

✅ **"How many..."** - Counting  
✅ **"What is the average/total/sum..."** - Aggregation  
✅ **"Show me the distribution..."** - Grouping  
✅ **"What percentage..."** - Calculation  
✅ **"Top N..."** - Ranking with aggregation  
✅ **"Compare..."** - Side-by-side aggregates  

---

## 🧪 Test Both Tools

Try these pairs to see the difference:

### **Pair 1: Count vs Find**

**Analytics:**
```
How many platinum tier patients do we have?
```
**Result**: Number (e.g., "5,234 platinum patients")

**Search:**
```
Find platinum tier patients
```
**Result**: List of 10 patient records with their details

---

### **Pair 2: Average vs List**

**Analytics:**
```
What is the average lifetime value of patients over 65?
```
**Result**: Single number (e.g., "£2,456.78")

**Search:**
```
Show me patients over 65 with high lifetime value
```
**Result**: Individual patient records matching criteria

---

### **Pair 3: Percentage vs Cohort**

**Analytics:**
```
What percentage of patients haven't converted on campaigns?
```
**Result**: Percentage (e.g., "32.5% haven't converted")

**Search:**
```
Identify patients who haven't converted on campaigns
```
**Result**: Specific patient records to target

---

## 🎯 When to Use Each in a Demo

### **Use Semantic Model to Show:**
- ✅ Business intelligence and reporting
- ✅ Executive dashboards and KPIs
- ✅ Trend analysis and comparisons
- ✅ Performance metrics
- ✅ Quick answers to "how many/what is" questions

**Audience**: Executives, BI users, analysts

---

### **Use Cortex Search to Show:**
- ✅ Marketing campaign targeting
- ✅ Patient cohort discovery
- ✅ Look-alike modeling
- ✅ Personalized outreach
- ✅ Clinical cohort identification

**Audience**: Marketing teams, clinical operations, data scientists

---

## 📋 Quick Reference Card

**Print this for quick reference:**

```
┌─────────────────────────────────────────────────────────┐
│ CORTEX SEARCH (Patient Discovery)                       │
├─────────────────────────────────────────────────────────┤
│ Keywords: Find, Search, Show me patients, Identify      │
│ Returns: List of patient records (up to 10)             │
│ Use for: Targeting, cohort discovery, look-alikes       │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ SEMANTIC MODEL (Analytics)                              │
├─────────────────────────────────────────────────────────┤
│ Keywords: How many, What is, Average, Total, Top N      │
│ Returns: Aggregated metrics, counts, percentages        │
│ Use for: Reporting, KPIs, analysis, insights            │
└─────────────────────────────────────────────────────────┘
```

---

## 🚀 Advanced: Combined Query

The agent can use BOTH tools in sequence:

**Complex Query:**
```
Find our top platinum customers and tell me their average prescription count
```

**What happens:**
1. **Cortex Search**: Finds platinum customers → gets patient records
2. **Semantic Model**: Calculates average prescriptions for those patients
3. **Agent**: Combines both results into a comprehensive answer

**Demo this to show orchestration!**

---

## ✅ Summary

| Aspect | Cortex Search | Semantic Model |
|--------|---------------|----------------|
| **Purpose** | Find individual records | Aggregate analysis |
| **Output** | Patient records | Numbers, metrics |
| **Max results** | 10 patients | Aggregated data |
| **Best for** | Discovery, targeting | Reporting, insights |
| **Trigger words** | Find, Search, Show patients | How many, What is, Average |
| **Use case** | "Who should we target?" | "How are we performing?" |

---

**The core demo queries (1-6) primarily use the Semantic Model because they focus on analytics. To showcase Cortex Search, add discovery-focused queries that start with "Find..." or "Show me patients..."** 

Want me to create a demo script that shows BOTH tools? Let me know! 🚀
