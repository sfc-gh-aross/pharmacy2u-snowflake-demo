-- ============================================================================
-- Pharmacy2U Demo - Create Formal Organizational Listings
-- Purpose: Publish data products to Snowflake's Internal Marketplace
-- Key Feature: Official organizational listings with proper discovery
-- Reference: https://docs.snowflake.com/en/sql-reference/sql/create-organization-listing
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE PHARMACY2U_DEMO_WH;
USE DATABASE PHARMACY2U_GOLD;

-- ============================================================================
-- PREREQUISITE: Ensure Shares and Data Products Exist
-- ============================================================================

-- Run organizational_listings.sql first to create:
-- 1. DATA_PRODUCTS schema
-- 2. Secure views (PATIENT_360_ANALYTICS_PRODUCT, etc.)
-- 3. Shares (PATIENT_ANALYTICS_SHARE, etc.)
-- 4. Catalog tables

SELECT 'Creating Organizational Listings for Internal Marketplace...' AS STATUS;

-- ============================================================================
-- LISTING 1: Patient 360 Analytics
-- ============================================================================

CREATE ORGANIZATION LISTING IF NOT EXISTS PHARMACY2U_PATIENT_360_LISTING
  SHARE PATIENT_ANALYTICS_SHARE AS
$$
title: "Pharmacy2U Patient 360 Analytics"
description: |
  Comprehensive patient analytics data product for marketing and business intelligence.
  
  **What's Included:**
  - Patient demographics (age, gender, postcode)
  - Prescription history and lifetime value
  - Marketing engagement metrics
  - Customer tier segmentation
  
  **Use Cases:**
  - Customer segmentation and targeting
  - Lifetime value analysis
  - Campaign performance measurement
  - Executive dashboards
  
  **Data Governance:**
  - PII is automatically masked based on user role
  - Access policies enforce GDPR compliance
  - Real-time refresh via Dynamic Tables
  
  **Target Audience:** Marketing teams, BI analysts, data scientists

organization_profile: "INTERNAL"
organization_targets:
  access:
    - all_accounts: true
support_contact: "data-team@pharmacy2u.co.uk"
approver_contact: "analytics-lead@pharmacy2u.co.uk"
locations:
  access_regions:
    - name: "PUBLIC.AZURE_WESTUS2"
$$
PUBLISH = TRUE;

SELECT 'Listing 1: Patient 360 Analytics - Published ✅' AS STATUS;

-- ============================================================================
-- LISTING 2: Churn Risk Scores
-- ============================================================================

CREATE ORGANIZATION LISTING IF NOT EXISTS PHARMACY2U_CHURN_RISK_LISTING
  SHARE CHURN_RISK_SHARE AS
$$
title: "Pharmacy2U ML Churn Risk Predictions"
description: |
  Machine learning-powered patient churn risk scores with actionable recommendations.
  
  **What's Included:**
  - Patient-level churn risk scores (0-100)
  - Risk categories (High/Medium/Low)
  - Recommended actions for retention
  - Customer value tier segmentation
  - Marketing segment assignments
  
  **Use Cases:**
  - Proactive retention campaigns
  - VIP customer care programs
  - Revenue protection strategies
  - Marketing ROI optimization
  
  **Data Governance:**
  - Contains PII - masked based on user role
  - Access policies automatically applied
  - Daily refresh schedule
  
  **Business Value:**
  Identify high-value at-risk customers before they churn and take targeted action.
  
  **Target Audience:** Marketing teams, customer success, executives

organization_profile: "INTERNAL"
organization_targets:
  access:
    - all_accounts: true
support_contact: "data-science@pharmacy2u.co.uk"
approver_contact: "ml-lead@pharmacy2u.co.uk"
locations:
  access_regions:
    - name: "PUBLIC.AZURE_WESTUS2"
$$
PUBLISH = TRUE;

SELECT 'Listing 2: Churn Risk Scores - Published ✅' AS STATUS;

-- ============================================================================
-- LISTING 3: Prescription Analytics
-- ============================================================================

CREATE ORGANIZATION LISTING IF NOT EXISTS PHARMACY2U_PRESCRIPTION_ANALYTICS_LISTING
  SHARE PRESCRIPTION_ANALYTICS_SHARE AS
$$
title: "Pharmacy2U Prescription Analytics"
description: |
  Aggregated prescription statistics and drug utilization insights - no PII.
  
  **What's Included:**
  - Drug-level prescription volumes and costs
  - Unique patient counts per medication
  - Prescriber and pharmacy network metrics
  - Cost per prescription trends
  - Date range coverage
  
  **Use Cases:**
  - Drug utilization analysis
  - Cost management and forecasting
  - Network planning and optimization
  - Inventory forecasting
  - Regulatory reporting (MHRA compliance)
  
  **Data Governance:**
  - NO PII - aggregated data only
  - Safe for broad organizational distribution
  - No access restrictions required
  - Daily refresh schedule
  
  **Business Value:**
  Enable all teams to make data-driven decisions about clinical operations, 
  finance, and network planning without privacy concerns.
  
  **Target Audience:** All teams - clinical, finance, operations, strategy

organization_profile: "INTERNAL"
organization_targets:
  access:
    - all_accounts: true
support_contact: "clinical-ops@pharmacy2u.co.uk"
approver_contact: "operations-lead@pharmacy2u.co.uk"
locations:
  access_regions:
    - name: "PUBLIC.AZURE_WESTUS2"
$$
PUBLISH = TRUE;

SELECT 'Listing 3: Prescription Analytics - Published ✅' AS STATUS;

-- ============================================================================
-- VERIFY LISTINGS WERE CREATED
-- ============================================================================

SELECT '=== VERIFYING ORGANIZATIONAL LISTINGS ===' AS STATUS;

-- Show all organizational listings
SHOW LISTINGS;

-- Show details of our listings
SELECT 
    'Listing created successfully' AS status,
    'Run: SHOW LISTINGS; to see all organizational listings' AS next_step
UNION ALL SELECT 
    'Access via Snowsight',
    'Data Products → Private Sharing → Listings'
UNION ALL SELECT
    'Internal Marketplace',
    'Consumers can now discover and request access';

-- ============================================================================
-- CLEANUP COMMANDS (if needed)
-- ============================================================================

-- To remove listings (DO NOT RUN during demo):
-- DROP LISTING IF EXISTS PHARMACY2U_PATIENT_360_LISTING;
-- DROP LISTING IF EXISTS PHARMACY2U_CHURN_RISK_LISTING;
-- DROP LISTING IF EXISTS PHARMACY2U_PRESCRIPTION_ANALYTICS_LISTING;

SELECT '✅ Organizational Listings Created and Published to Internal Marketplace!' AS FINAL_STATUS;

-- ============================================================================
-- DEMO TALKING POINTS
-- ============================================================================

SELECT '=== ORGANIZATIONAL LISTINGS - KEY MESSAGES ===' AS TALKING_POINTS;

SELECT 
    '1. Real Internal Marketplace' AS message,
    'These are actual Snowflake listings, not simulated' AS details
UNION ALL SELECT 
    '2. Self-Service Discovery',
    'Teams can browse, request access via Snowsight UI'
UNION ALL SELECT 
    '3. Zero Data Movement',
    'Live shares - consumers see real-time data instantly'
UNION ALL SELECT 
    '4. Governance Preserved',
    'Access policies and masking travel with the data'
UNION ALL SELECT 
    '5. Rich Metadata',
    'Descriptions, use cases, support contacts all visible'
UNION ALL SELECT 
    '6. vs Microsoft Fabric',
    'Fabric has no equivalent - requires manual SharePoint coordination';

SELECT 'Organizational listings demo ready! 🚀' AS STATUS;
