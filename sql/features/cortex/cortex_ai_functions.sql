-- ============================================================================
-- Pharmacy2U Demo - Cortex AI SQL Functions
-- Purpose: Demonstrate serverless AI capabilities directly in SQL
-- Key Feature: LLM-powered analysis without model deployment
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE PHARMACY2U_DEMO_WH;
USE DATABASE PHARMACY2U_GOLD;
USE SCHEMA ANALYTICS;

-- ============================================================================
-- CORTEX AI VALUE PROPOSITION
-- ============================================================================

SELECT '=== SNOWFLAKE CORTEX AI: SERVERLESS INTELLIGENCE ===' AS INFO;

SELECT 
    'Challenge: AI/ML requires complex infrastructure, model deployment, maintenance' AS business_context
UNION ALL SELECT 'Need: Quick insights from text data, sentiment analysis, classification'
UNION ALL SELECT 'Traditional Approach: Deploy models, manage infrastructure, version control'
UNION ALL SELECT 'Snowflake Solution: Call AI functions directly in SQL - no infrastructure';

-- ============================================================================
-- STEP 1: Create Sample Text Data for Demonstration
-- ============================================================================

-- Patient feedback/notes (simulated for demo)
CREATE OR REPLACE TABLE PATIENT_FEEDBACK (
    feedback_id VARCHAR DEFAULT UUID_STRING(),
    patient_id VARCHAR,
    feedback_date DATE,
    feedback_text VARCHAR,
    feedback_channel VARCHAR,
    created_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

COMMENT ON TABLE PATIENT_FEEDBACK IS 'Sample patient feedback for Cortex AI function demonstrations';

INSERT INTO PATIENT_FEEDBACK (patient_id, feedback_date, feedback_text, feedback_channel)
VALUES
    ('PT-0001234', '2025-09-25', 'The delivery was very fast and the pharmacist was extremely helpful in explaining how to take my medication. Very satisfied with the service!', 'Email'),
    ('PT-0002345', '2025-09-24', 'Disappointed that my prescription was delayed by 3 days. I had to call customer service twice to get an update. Not acceptable.', 'Phone'),
    ('PT-0003456', '2025-09-23', 'Good service overall, but the website could be easier to use. Had trouble finding my prescription history.', 'Web Form'),
    ('PT-0004567', '2025-09-22', 'Excellent! Been using Pharmacy2U for 2 years now. Never had any issues. Keep up the great work.', 'Email'),
    ('PT-0005678', '2025-09-21', 'The medication packaging was damaged when it arrived. However, customer service quickly sent a replacement. Appreciate the quick response.', 'Email'),
    ('PT-0006789', '2025-09-20', 'Very unhappy. Wrong medication was sent. This is a serious safety concern. Will not be using this service again.', 'Phone'),
    ('PT-0007890', '2025-09-19', 'The NHS prescription service is brilliant. Saves me going to the chemist. Highly recommend to elderly patients like myself.', 'Letter'),
    ('PT-0008901', '2025-09-18', 'Average service. Nothing special but gets the job done. Prices are reasonable.', 'Web Form'),
    ('PT-0009012', '2025-09-17', 'Absolutely terrible experience. Prescription never arrived. Customer service was unhelpful. Avoid this company.', 'Social Media'),
    ('PT-0000123', '2025-09-16', 'The pharmacist called me proactively about a potential drug interaction. Really appreciated the professional care!', 'Email');

SELECT 'Sample patient feedback data created' AS STATUS;

-- ============================================================================
-- STEP 2: SENTIMENT Analysis with SNOWFLAKE.CORTEX.SENTIMENT
-- ============================================================================

SELECT '=== DEMONSTRATION 1: SENTIMENT ANALYSIS ===' AS DEMO;

-- Analyze sentiment of patient feedback
CREATE OR REPLACE VIEW V_PATIENT_FEEDBACK_SENTIMENT AS
SELECT 
    feedback_id,
    patient_id,
    feedback_date,
    feedback_text,
    feedback_channel,
    -- Cortex AI Sentiment Function (returns -1 to 1, where -1=very negative, 1=very positive)
    SNOWFLAKE.CORTEX.SENTIMENT(feedback_text) AS sentiment_score,
    CASE 
        WHEN SNOWFLAKE.CORTEX.SENTIMENT(feedback_text) >= 0.5 THEN 'Very Positive'
        WHEN SNOWFLAKE.CORTEX.SENTIMENT(feedback_text) >= 0.1 THEN 'Positive'
        WHEN SNOWFLAKE.CORTEX.SENTIMENT(feedback_text) >= -0.1 THEN 'Neutral'
        WHEN SNOWFLAKE.CORTEX.SENTIMENT(feedback_text) >= -0.5 THEN 'Negative'
        ELSE 'Very Negative'
    END AS sentiment_category
FROM PATIENT_FEEDBACK;

COMMENT ON VIEW V_PATIENT_FEEDBACK_SENTIMENT IS 'Patient feedback with AI-powered sentiment analysis';

-- Show sentiment analysis results
SELECT 
    feedback_text,
    sentiment_score,
    sentiment_category
FROM V_PATIENT_FEEDBACK_SENTIMENT
ORDER BY sentiment_score DESC;

-- Talking Point: "Instantly understand customer sentiment across thousands of feedbacks"

-- Sentiment summary
SELECT 
    sentiment_category,
    COUNT(*) AS feedback_count,
    ROUND(AVG(sentiment_score), 3) AS avg_sentiment_score
FROM V_PATIENT_FEEDBACK_SENTIMENT
GROUP BY sentiment_category
ORDER BY avg_sentiment_score DESC;

SELECT 'Sentiment analysis complete using Cortex AI' AS STATUS;

-- ============================================================================
-- STEP 3: TEXT SUMMARIZATION with SNOWFLAKE.CORTEX.COMPLETE
-- ============================================================================

SELECT '=== DEMONSTRATION 2: TEXT SUMMARIZATION ===' AS DEMO;

-- Create drug information (simulated)
CREATE OR REPLACE TABLE DRUG_INFORMATION (
    drug_name VARCHAR,
    full_description TEXT
) AS
SELECT 
    'Atorvastatin',
    'Atorvastatin belongs to a group of medicines called statins. It is used to lower cholesterol and to reduce risk of heart disease. Cholesterol is a fatty substance that builds up in your blood vessels and causes narrowing, which may lead to a heart attack or stroke. Atorvastatin is used in people with high levels of cholesterol or triglycerides in the blood. It is also used to prevent cardiovascular disease in people at high risk, even if cholesterol levels are normal. This medicine is recommended along with a healthy diet and regular physical exercise. Common side effects may include muscle pain, nausea, indigestion and headache. Serious side effects are rare but may include severe muscle problems and liver problems. Patients should report unexplained muscle pain immediately.'
UNION ALL SELECT
    'Metformin',
    'Metformin is an oral diabetes medicine that helps control blood sugar levels. It is used to treat type 2 diabetes, sometimes in combination with insulin or other medications, but is not for treating type 1 diabetes. Metformin works by decreasing glucose production in the liver and improving your body''s sensitivity to insulin. It is often the first medication prescribed for type 2 diabetes and is considered very effective. The medication should be taken with meals to reduce stomach upset. Common side effects include nausea, vomiting, stomach upset, diarrhea and weakness. Patients should monitor blood sugar levels regularly and maintain a proper diet and exercise program. Rare but serious side effects may include lactic acidosis, especially in patients with kidney problems. Regular kidney function tests are recommended.';

-- Generate concise summaries using Cortex AI
SELECT 
    drug_name,
    SNOWFLAKE.CORTEX.COMPLETE(
        'mistral-large',
        'Summarize this drug information in 2 concise sentences for patients: ' || full_description
    ) AS patient_summary,
    SNOWFLAKE.CORTEX.COMPLETE(
        'mistral-large',
        'List the top 3 most important points about this medication in bullet points: ' || full_description
    ) AS key_points
FROM DRUG_INFORMATION;

-- Talking Point: "Generate patient-friendly summaries automatically from technical documentation"

SELECT 'Text summarization complete using Cortex AI' AS STATUS;

-- ============================================================================
-- STEP 4: TEXT CLASSIFICATION with SNOWFLAKE.CORTEX.COMPLETE
-- ============================================================================

SELECT '=== DEMONSTRATION 3: FEEDBACK CLASSIFICATION ===' AS DEMO;

-- Classify patient feedback into categories
CREATE OR REPLACE VIEW V_PATIENT_FEEDBACK_CLASSIFIED AS
SELECT 
    feedback_id,
    patient_id,
    feedback_text,
    sentiment_category,
    -- Use Cortex AI to classify feedback type
    SNOWFLAKE.CORTEX.COMPLETE(
        'mistral-large',
        'Classify this patient feedback into ONE category: DELIVERY, MEDICATION_QUALITY, CUSTOMER_SERVICE, WEBSITE_UX, or PRICING. Only return the category name. Feedback: ' || feedback_text
    ) AS feedback_category
FROM V_PATIENT_FEEDBACK_SENTIMENT;

-- Show classified feedback
SELECT 
    feedback_category,
    sentiment_category,
    COUNT(*) AS feedback_count
FROM V_PATIENT_FEEDBACK_CLASSIFIED
GROUP BY feedback_category, sentiment_category
ORDER BY feedback_category, sentiment_category;

-- Talking Point: "Automatically route feedback to the right team for action"

SELECT 'Feedback classification complete using Cortex AI' AS STATUS;

-- ============================================================================
-- STEP 5: TRANSLATION with SNOWFLAKE.CORTEX.TRANSLATE
-- ============================================================================

SELECT '=== DEMONSTRATION 4: MULTI-LANGUAGE SUPPORT ===' AS DEMO;

-- Translate patient-facing messages
SELECT 
    'English' AS language,
    'Your prescription is ready for collection at your chosen pharmacy' AS message
UNION ALL
SELECT 
    'Polish',
    SNOWFLAKE.CORTEX.TRANSLATE(
        'Your prescription is ready for collection at your chosen pharmacy',
        'en',
        'pl'
    )
UNION ALL
SELECT 
    'Urdu',
    SNOWFLAKE.CORTEX.TRANSLATE(
        'Your prescription is ready for collection at your chosen pharmacy',
        'en',
        'ur'
    )
UNION ALL
SELECT 
    'Bengali',
    SNOWFLAKE.CORTEX.TRANSLATE(
        'Your prescription is ready for collection at your chosen pharmacy',
        'en',
        'bn'
    );

-- Talking Point: "Serve diverse UK patient population in their preferred language"

SELECT 'Translation complete using Cortex AI' AS STATUS;

-- ============================================================================
-- STEP 6: PRACTICAL USE CASE - Proactive Patient Care
-- ============================================================================

SELECT '=== PRACTICAL USE CASE: PROACTIVE PATIENT OUTREACH ===' AS USE_CASE;

-- Identify negative feedback requiring immediate attention
CREATE OR REPLACE VIEW V_URGENT_PATIENT_FEEDBACK AS
SELECT 
    pf.patient_id,
    pf.feedback_date,
    pf.feedback_text,
    pf.feedback_channel,
    pfs.sentiment_score,
    pfs.sentiment_category,
    pfc.feedback_category,
    -- Generate suggested response using AI
    SNOWFLAKE.CORTEX.COMPLETE(
        'mistral-large',
        'Generate a professional, empathetic response to this patient feedback from a pharmacy manager. Keep it under 100 words. Feedback: ' || pf.feedback_text
    ) AS suggested_response
FROM PATIENT_FEEDBACK pf
JOIN V_PATIENT_FEEDBACK_SENTIMENT pfs ON pf.feedback_id = pfs.feedback_id
LEFT JOIN V_PATIENT_FEEDBACK_CLASSIFIED pfc ON pf.feedback_id = pfc.feedback_id
WHERE pfs.sentiment_score < -0.3  -- Negative or very negative
ORDER BY pfs.sentiment_score ASC
LIMIT 5;

-- Show urgent feedback with AI-generated responses
SELECT 
    patient_id,
    feedback_text,
    sentiment_category,
    feedback_category,
    suggested_response
FROM V_URGENT_PATIENT_FEEDBACK;

-- Talking Point: "AI identifies issues and drafts responses - turn complaints into retention opportunities"

SELECT 'Proactive patient care workflow enabled by Cortex AI' AS STATUS;

-- ============================================================================
-- BUSINESS VALUE SUMMARY
-- ============================================================================

SELECT '=== BUSINESS VALUE DELIVERED ===' AS SUMMARY;

SELECT 
    'Sentiment Analysis: Understand 1000s of feedbacks in seconds' AS value_1
UNION ALL SELECT 'Auto-Summarization: Patient-friendly drug information at scale'
UNION ALL SELECT 'Smart Routing: Auto-classify feedback to correct department'
UNION ALL SELECT 'Multilingual: Serve diverse UK population'
UNION ALL SELECT 'AI-Assisted Responses: Faster customer service resolution'
UNION ALL SELECT 'Zero Infrastructure: No model deployment or maintenance';

-- ============================================================================
-- COMPETITIVE DIFFERENTIATION
-- ============================================================================

SELECT '=== VS MICROSOFT FABRIC ===' AS COMPETITIVE_EDGE;

SELECT 
    'Snowflake: AI functions built into SQL - call like any function' AS snowflake_advantage
UNION ALL SELECT 'Fabric: Requires Azure OpenAI setup, API keys, separate billing'
UNION ALL SELECT 'Snowflake: Multiple models available (mixtral, mistral-large, etc.)'
UNION ALL SELECT 'Fabric: Limited to Azure OpenAI models only'
UNION ALL SELECT 'Snowflake: Serverless - no infrastructure to manage'
UNION ALL SELECT 'Fabric: Must manage Azure ML endpoints and scaling';

-- ============================================================================
-- DEMO TALKING POINTS
-- ============================================================================

SELECT '=== Cortex AI Functions Demo Talking Points ===' AS INFO;

SELECT 
    'Point 1: LLM power directly in SQL - no separate services' AS talking_point
UNION ALL SELECT 'Point 2: Serverless - no model deployment or infrastructure'
UNION ALL SELECT 'Point 3: Multiple use cases - sentiment, summarization, translation'
UNION ALL SELECT 'Point 4: Instant insights from unstructured text data'
UNION ALL SELECT 'Point 5: Scales automatically with warehouse size'
UNION ALL SELECT 'Point 6: Pharmaceutical-specific applications demonstrated';

SELECT 'Cortex AI SQL Functions demonstration complete!' AS FINAL_STATUS;
