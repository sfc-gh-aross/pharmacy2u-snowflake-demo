# Organizational Listing Enrichment Guide

This document provides the data dictionary and quick start examples to manually add to each organizational listing via Snowsight UI.

## How to Add This Information

1. Navigate to **Snowsight** → **Data Products** → **Private Sharing** → **Listings**
2. Select each listing
3. Click **Edit** or **Add** buttons for each section
4. Copy/paste the information below

---

## LISTING 1: Pharmacy2U Patient 360 Analytics

### Data Dictionary

Add these fields to the data dictionary section:

| Column Name | Data Type | Description |
|------------|-----------|-------------|
| PATIENT_ID | VARCHAR | Unique patient identifier (anonymized) |
| AGE | NUMBER | Patient age in years |
| GENDER | VARCHAR | Patient gender (M/F/Other) |
| POSTCODE | VARCHAR | UK postcode (masked based on role permissions) |
| TOTAL_PRESCRIPTIONS | NUMBER | Lifetime prescription count for patient |
| UNIQUE_DRUGS | NUMBER | Number of distinct drugs prescribed |
| LIFETIME_VALUE_GBP | NUMBER(10,2) | Total revenue from patient (GBP) |
| LAST_PRESCRIPTION_DATE | DATE | Date of most recent prescription |
| MARKETING_INTERACTIONS | NUMBER | Total marketing touchpoints (emails, SMS, etc.) |
| CAMPAIGN_CONVERSIONS | NUMBER | Number of successful campaign conversions |
| REGISTRATION_DATE | DATE | Patient registration date |
| AVG_PRESCRIPTION_VALUE | NUMBER(10,2) | Average value per prescription (calculated) |
| ENGAGEMENT_RATE_PCT | NUMBER(5,2) | Campaign engagement rate percentage |
| CUSTOMER_TIER | VARCHAR | Customer value tier (Platinum/Gold/Silver/Bronze) |

### Quick Start Examples

#### Example 1: High-Value Patient Count
**Description:** Count patients with lifetime value over £2000

```sql
SELECT COUNT(*) as high_value_patients
FROM PATIENT_360_ANALYTICS_PRODUCT
WHERE LIFETIME_VALUE_GBP > 2000;
```

#### Example 2: Customer Tier Distribution
**Description:** Breakdown of patients by value tier

```sql
SELECT 
  CUSTOMER_TIER,
  COUNT(*) as patient_count,
  SUM(LIFETIME_VALUE_GBP) as total_value_gbp,
  AVG(ENGAGEMENT_RATE_PCT) as avg_engagement
FROM PATIENT_360_ANALYTICS_PRODUCT
GROUP BY CUSTOMER_TIER
ORDER BY total_value_gbp DESC;
```

#### Example 3: Marketing Engagement Analysis
**Description:** Patients with high engagement rate

```sql
SELECT 
  CUSTOMER_TIER,
  COUNT(*) as patients,
  AVG(ENGAGEMENT_RATE_PCT) as avg_engagement_rate
FROM PATIENT_360_ANALYTICS_PRODUCT
WHERE MARKETING_INTERACTIONS > 0
GROUP BY CUSTOMER_TIER
ORDER BY avg_engagement_rate DESC;
```

#### Example 4: Geographic Distribution
**Description:** Patient distribution by postcode area

```sql
SELECT 
  LEFT(POSTCODE, 2) as postcode_area,
  COUNT(*) as patient_count,
  SUM(LIFETIME_VALUE_GBP) as area_revenue_gbp
FROM PATIENT_360_ANALYTICS_PRODUCT
GROUP BY postcode_area
ORDER BY patient_count DESC
LIMIT 10;
```

### Attributes

Add these as key-value pairs in the Attributes section:

| Attribute | Value |
|-----------|-------|
| Data Refresh | Real-time via Dynamic Tables |
| Data Source | Pharmacy2U Production Systems |
| PII Level | Contains PII - Role-based Masking Applied |
| Compliance | GDPR Compliant, NHS Data Standards |
| Row Count | 100,000+ patients |
| Update Frequency | Real-time |
| Data Retention | 7 years |
| Quality Score | 98% |

---

## LISTING 2: Pharmacy2U ML Churn Risk Predictions

### Data Dictionary

| Column Name | Data Type | Description |
|------------|-----------|-------------|
| PATIENT_ID | VARCHAR | Unique patient identifier |
| VALUE_TIER | VARCHAR | Customer value tier (Platinum/Gold/Silver/Bronze) |
| AGE_GROUP | VARCHAR | Patient age group segmentation |
| CHURN_RISK_SCORE | NUMBER(5,2) | ML-generated churn probability (0-100) |
| RISK_CATEGORY | VARCHAR | Risk level (High Risk/Medium Risk/Low Risk) |
| LIFETIME_VALUE_GBP | NUMBER(10,2) | Total patient lifetime value (GBP) |
| TOTAL_PRESCRIPTIONS | NUMBER | Total prescription count |
| MARKETING_INTERACTIONS | NUMBER | Total marketing touchpoints |
| MARKETING_SEGMENT | VARCHAR | Marketing segment classification |
| RECOMMENDED_ACTION | VARCHAR | System-recommended retention action |

### Quick Start Examples

#### Example 1: Immediate Action Required - VIP Patients
**Description:** High-value patients requiring immediate retention intervention

```sql
SELECT 
  PATIENT_ID,
  CHURN_RISK_SCORE,
  LIFETIME_VALUE_GBP,
  RECOMMENDED_ACTION
FROM CHURN_RISK_PRODUCT
WHERE RECOMMENDED_ACTION = 'IMMEDIATE_ACTION_REQUIRED'
ORDER BY LIFETIME_VALUE_GBP DESC
LIMIT 20;
```

#### Example 2: Retention Campaign Target List
**Description:** All patients needing retention campaigns

```sql
SELECT 
  MARKETING_SEGMENT,
  COUNT(*) as patient_count,
  SUM(LIFETIME_VALUE_GBP) as revenue_at_risk_gbp,
  AVG(CHURN_RISK_SCORE) as avg_risk_score
FROM CHURN_RISK_PRODUCT
WHERE RECOMMENDED_ACTION IN ('IMMEDIATE_ACTION_REQUIRED', 'RETENTION_CAMPAIGN')
GROUP BY MARKETING_SEGMENT
ORDER BY revenue_at_risk_gbp DESC;
```

#### Example 3: Revenue at Risk Analysis
**Description:** Total revenue at risk by risk category

```sql
SELECT 
  RISK_CATEGORY,
  VALUE_TIER,
  COUNT(*) as patients,
  SUM(LIFETIME_VALUE_GBP) as revenue_at_risk,
  AVG(CHURN_RISK_SCORE) as avg_score
FROM CHURN_RISK_PRODUCT
GROUP BY RISK_CATEGORY, VALUE_TIER
ORDER BY revenue_at_risk DESC;
```

#### Example 4: High-Risk Platinum Customers
**Description:** Most valuable at-risk customers

```sql
SELECT 
  PATIENT_ID,
  CHURN_RISK_SCORE,
  LIFETIME_VALUE_GBP,
  TOTAL_PRESCRIPTIONS,
  RECOMMENDED_ACTION
FROM CHURN_RISK_PRODUCT
WHERE VALUE_TIER = 'Platinum' 
  AND RISK_CATEGORY = 'High Risk'
ORDER BY CHURN_RISK_SCORE DESC;
```

### Attributes

| Attribute | Value |
|-----------|-------|
| Model Type | XGBoost Classification |
| Model Accuracy | 87.3% |
| Data Refresh | Daily at 2:00 AM UTC |
| Data Source | Patient 360 + ML Model Predictions |
| PII Level | Contains PII - Role-based Masking Applied |
| Compliance | GDPR Compliant |
| Prediction Window | Next 90 days |
| Row Count | 100,000+ predictions |
| Last Model Training | 2025-09-01 |

---

## LISTING 3: Pharmacy2U Prescription Analytics

### Data Dictionary

| Column Name | Data Type | Description |
|------------|-----------|-------------|
| DRUG_NAME | VARCHAR | Generic drug name (BNF standard) |
| UNIQUE_PATIENTS | NUMBER | Count of distinct patients prescribed this drug |
| TOTAL_PRESCRIPTIONS | NUMBER | Total number of prescriptions |
| TOTAL_QUANTITY | NUMBER | Total quantity dispensed (units vary by drug) |
| TOTAL_COST_GBP | NUMBER(12,2) | Total cost in GBP |
| AVG_COST_PER_PRESCRIPTION | NUMBER(8,2) | Average cost per prescription |
| FIRST_PRESCRIPTION_DATE | DATE | Earliest prescription date in dataset |
| MOST_RECENT_PRESCRIPTION_DATE | DATE | Most recent prescription date |
| UNIQUE_PRESCRIBERS | NUMBER | Count of distinct prescribers |
| UNIQUE_PHARMACIES | NUMBER | Count of distinct pharmacy locations |

### Quick Start Examples

#### Example 1: Top 10 Most Prescribed Drugs
**Description:** Most commonly prescribed medications

```sql
SELECT 
  DRUG_NAME,
  TOTAL_PRESCRIPTIONS,
  UNIQUE_PATIENTS,
  TOTAL_COST_GBP,
  AVG_COST_PER_PRESCRIPTION
FROM PRESCRIPTION_ANALYTICS_PRODUCT
ORDER BY TOTAL_PRESCRIPTIONS DESC
LIMIT 10;
```

#### Example 2: Highest Cost Medications
**Description:** Drugs with highest total spend

```sql
SELECT 
  DRUG_NAME,
  TOTAL_COST_GBP,
  UNIQUE_PATIENTS,
  AVG_COST_PER_PRESCRIPTION,
  TOTAL_PRESCRIPTIONS
FROM PRESCRIPTION_ANALYTICS_PRODUCT
ORDER BY TOTAL_COST_GBP DESC
LIMIT 10;
```

#### Example 3: Network Coverage Analysis
**Description:** Drug availability across pharmacy network

```sql
SELECT 
  DRUG_NAME,
  UNIQUE_PHARMACIES as pharmacy_coverage,
  UNIQUE_PRESCRIBERS as prescriber_count,
  TOTAL_PRESCRIPTIONS
FROM PRESCRIPTION_ANALYTICS_PRODUCT
WHERE TOTAL_PRESCRIPTIONS > 100
ORDER BY pharmacy_coverage DESC
LIMIT 15;
```

#### Example 4: Cost Efficiency Analysis
**Description:** Drugs with best patient reach per cost

```sql
SELECT 
  DRUG_NAME,
  UNIQUE_PATIENTS,
  TOTAL_COST_GBP,
  ROUND(TOTAL_COST_GBP / UNIQUE_PATIENTS, 2) as cost_per_patient
FROM PRESCRIPTION_ANALYTICS_PRODUCT
WHERE UNIQUE_PATIENTS > 50
ORDER BY cost_per_patient ASC
LIMIT 20;
```

### Attributes

| Attribute | Value |
|-----------|-------|
| Data Refresh | Daily at 1:00 AM UTC |
| Data Source | NHS Prescription Data Feed |
| PII Level | No PII - Aggregated Data Only |
| Compliance | MHRA Compliant, NHS Standards |
| Row Count | 1,500+ drug entries |
| Update Frequency | Daily |
| Aggregation Level | Drug Name |
| Safe for Sharing | Yes - External Partners |
| Data Quality | Validated against BNF codes |

---

## Notes

- The data dictionary and quick start examples need to be added through the Snowsight UI as these fields are not supported in the CREATE ORGANIZATION LISTING YAML manifest
- Access the listings via: **Snowsight** → **Data Products** → **Private Sharing** → **Listings**
- For each listing, you can edit and add the data dictionary, quick start examples, and attributes through the UI
- This enriched metadata will make the listings more discoverable and useful for internal teams
