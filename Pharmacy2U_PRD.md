# Product Requirements Document: Composing a Snowflake Demo for Pharmacy2U

## 1.0 Executive Summary

  * **Objective:** To demonstrate that Snowflake is the single, unified platform that can solve Pharmacy2U’s critical data fragmentation and scalability challenges, enabling a foundation of trusted, governed data to power accelerated BI, self-service analytics, internal data collaboration, and future-state AI applications, thereby solidifying Snowflake as the superior choice over Microsoft Fabric.
  * **Business Problem:** Pharmacy2U's explosive growth and acquisition strategy have outpaced its legacy data architecture, creating significant business challenges. The current single SQL Server environment faces critical scalability limitations and costly vertical upgrades (current instance is \~£36k/annum with a significant jump to enterprise), creating performance bottlenecks that delay critical analytics. Data is fragmented and siloed across SSIS, MariaDB, and PostgreSQL systems from acquisitions, making it difficult to achieve a single source of truth. This lack of trust forces teams to build their own BI, while the lean engineering team spends valuable time firefighting frequent P1 incidents (one every two weeks) and managing inefficient, manual SSIS packages instead of driving innovation.
  * **Proposed Solution:** This demonstration will present a compelling narrative through three distinct "Value Vignettes." We will show an end-to-end data journey, starting with the seamless ingestion and unification of disparate data sources, eliminating SSIS-related pain. We will then build a foundation of trust through automated governance, security, and unique platform resiliency features. Finally, we will showcase how this trusted data foundation empowers democratized self-service analytics, secure internal collaboration via the **Snowflake Internal Marketplace**, and a secure, integrated environment for Pharmacy2U's advanced AI and Machine Learning ambitions.

## 2.0 Stakeholders

  * **Champion(s):**
      * **Miles Hewitt** (Data Architect): Primary technical champion, leading the data platform redevelopment.
      * **Mustafa Ghafouri** (Head of Data Science): Key champion for AI/ML, focused on MLOps and GenAI capabilities.
      * **Phil Cliff** (Head of Data & AI): Key business and technical decision-maker.
  * **Key Audience:** Head of Customer Insight, Head of BI, Chief Architect, Head of Engineering, Head of Data, Head of Data Science.
  * **Decision Makers:**
      * **Joe Graham** (CDIO): The ultimate business sponsor driving the data strategy forward.
      * **Phil Cliff** (Head of Data & AI).

## 3.0 Current State Analysis

  * **Existing Architecture:** The current architecture is centered on a single Microsoft SQL Server running enterprise on a VM. Data integration is handled by SSIS packages. The analytics stack includes SSRS, Tableau, and an evaluation of Power BI. Due to acquisitions, data is fragmented across various other systems, including MariaDB and PostgreSQL. The team has begun using Python for more efficient data movement and is exploring a Medallion architecture with Azure Data Lake Gen 2.
  * **Key Challenges:**
      * **Scalability & Performance:** The single SQL Server cannot scale to meet the demand of 500k+ daily orders and future growth, leading to performance "creaking at the seams" and expensive, disruptive vertical scaling.
      * **Data Fragmentation:** Data from acquisitions remains in silos, making it incredibly difficult and time-consuming to create a unified view for analytics.
      * **Operational Inefficiency:** The lean data engineering team is burdened with maintaining complex SSIS packages, firefighting incidents, and manually managing a sprawling data model instead of focusing on strategic initiatives.
      * **Lack of Data Trust:** Without a clear data catalog or lineage, business users lack trust in the central data, leading them to create their own separate BI solutions.
      * **AI/ML Friction:** The current setup creates significant friction for the data science team, who are concerned about MLOps complexity and the security risks of moving sensitive patient data to train models.
      * **Slow Time-to-Value:** The combination of these challenges means that delivering new insights and integrating new data sources is a slow, manual process that cannot keep pace with business demands.

## 4.0 Proposed Solution Architecture

  * **Narrative:** The demo will showcase a modern, automated data flow built entirely within Snowflake. We will begin by ingesting raw data from core transactional systems (SQL Server, PostgreSQL) and semi-structured files (JSON) into a **BRONZE** raw data layer. From there, we will use Snowflake’s declarative **Dynamic Tables** to automatically transform, clean, and join this data into a governed **SILVER** layer. Finally, we will create an analytics-ready **GOLD** layer, featuring a comprehensive Patient 360 view, ready for consumption by Power BI, self-service AI queries via Snowflake Intelligence, and secure collaboration with internal teams and external partners through the **Snowflake Marketplace**.
  * **Diagram:**
    ```mermaid
    graph LR
        subgraph "Data Sources"
            A["Azure SQL DB (Prescriptions)"]
            B["PostgreSQL (Acquisition Data)"]
            C["ADLS Gen2 (Marketing JSON Events)"]
        end

        subgraph "Snowflake Data Cloud"
            subgraph "Ingestion & Processing"
                D{{"Snowpipe / Connectors"}}
                E[("Dynamic Tables (ELT)")]
            end

            subgraph "Storage & Governance (Horizon)"
                F[("BRONZE <br> Raw Data")]
                G[("SILVER <br> Governed & Enriched")]
                H[("GOLD <br> Analytics Ready <br> Patient 360 View")]
            end

             D --> F
             F -- E --> G
             G -- E --> H
        end

        subgraph "Consumption & Monetization"
            I["Power BI <br> Executive Dashboards"]
            J["Snowflake Intelligence <br> Self-Service Analytics"]
            K["Snowflake Marketplace <br> Internal & External Collaboration"]
            L["Snowpark <br> AI / ML Models"]
        end

        H --> I
        H --> J
        H --> K
        H --> L

    ```

## 5.0 Value Vignettes

-----

### **Vignette 1: From Fragmentation to Foundation: Unifying Data with Automated ELT**

  * **Target Audience:** `Data Architect (Miles Hewitt), Head of Engineering (Adam Young)`

  * **Core Message:** `Snowflake radically simplifies and accelerates the integration of diverse data sources, eliminating SSIS maintenance overhead and turning M&A integration from a multi-month liability into a strategic advantage.`

  * **Value Wedge Potential:** `High - Directly contrasts Snowflake's single, simple, all-in-one platform against the multi-component complexity of Fabric. Highlights superior native handling of semi-structured data.`

  * **Demo Flow Structure (Tell-Show-Tell):**

    **TELL \#1 - Set the Stage**

      * **Business Context:** Pharmacy2U's growth and acquisition strategy is core to the business, but integrating new data sources like PostgreSQL and MariaDB is a major engineering bottleneck. Your team is spending too much time maintaining brittle SSIS packages instead of building for the future.
      * **Quantified Problem:** `[Insufficient Information in Context]` Generic Example: "Each new acquisition currently takes 3-4 months to fully integrate, delaying consolidated reporting and cross-sell opportunities, representing a significant opportunity cost. Meanwhile, your team spends an estimated 40 hours per month just managing and firefighting SSIS package failures."
      * **Success Vision:** Imagine a world where you can ingest any data source—structured or semi-structured—in minutes, and build reliable, observable, and automated transformation pipelines without writing complex orchestration code. Let's build that foundation right now.

    **SHOW - Live Demonstration**

      * **Demo Script:**
        1.  Start in a blank Snowflake worksheet. "We're starting from scratch to show how simple this is."
        2.  Run a script to create our `BRONZE`, `SILVER`, and `GOLD` databases.
        3.  Ingest raw prescription data from your SQL Server and patient data from an acquired PostgreSQL database using our connectors.
        4.  Ingest raw, nested JSON marketing engagement data directly from ADLS Gen2 using Snowpipe.
        5.  Query the raw JSON directly in the `BRONZE` layer using Snowflake's native dot notation. **(Key Moment \#1)**. "Notice we're querying complex JSON as if it were a structured table, with no complex parsing required. This is a massive accelerator."
        6.  Create a **Dynamic Table** to automatically clean, flatten, and join all three sources into a governed `PATIENT_360` table in the `SILVER` layer.
        7.  Show the simple, declarative SQL for the Dynamic Table. **(Key Moment \#2)**. "This isn't just a query; it's a complete, automated ELT pipeline. Snowflake manages the dependencies, orchestration, and incremental refreshes. You just declare the end state, and we handle the rest, making your SSIS logic obsolete."
      * **Audience Engagement:** "Adam, given your experience with SSIS, how much time would building, deploying, and managing the orchestration for a pipeline like this typically take?"
      * **Technical Talking Points:**
          * **Schema on Read:** We land raw data as-is and parse it within Snowflake, providing flexibility.
          * **Declarative Pipelines:** Dynamic Tables abstract away the complexity of DAGs and orchestration. It's ELT as a simple, automated, and observable process.

    **TELL \#2 - Reinforce Value**

      * **Business Impact:** What you just saw reduces the time to integrate new acquisition data from months to days. This means faster time-to-insight for the business and frees up at least 25% of your data engineering team's capacity to focus on high-value projects instead of pipeline maintenance.
      * **Differentiation:** This was one platform, one copy of data, and one skill set—SQL. With Microsoft Fabric, this would require stitching together multiple services: Azure Data Factory for ingestion, different engines for different data types, and complex management of compute capacities. Snowflake makes it simple and efficient.
      * **Next Steps:** Now that we have a unified and trusted data foundation, let's secure it and make it discoverable.

-----

### **Vignette 2: Building Unbreakable Trust: Automated Governance & Internal Collaboration**

  * **Target Audience:** `Head of Data (Phil Cliff), Head of BI, Head of Customer Insight`

  * **Core Message:** `Snowflake's built-in, automated governance and unique platform features create a foundation of trust and agility, empowering lean teams and enabling confident, secure self-service and internal data collaboration.`

  * **Value Wedge Potential:** `High - Time Travel, Zero-Copy Cloning, and the integrated Internal Marketplace are profound differentiators that Fabric fundamentally lacks. This directly addresses the pain of risk, manual work, dev bottlenecks, and internal data silos.`

  * **Demo Flow Structure (Tell-Show-Tell):**

    **TELL \#1 - Set the Stage**

      * **Business Context:** You're handling highly sensitive patient data and must adhere to strict GDPR standards. Simultaneously, your BI and analytics teams are struggling with data trust, and different business units can't easily discover or access the valuable data assets being created.
      * **Quantified Problem:** "Your DPA team experiences a P1 incident every two weeks, consuming significant team resources. Furthermore, a lack of data discoverability means analysts spend hours hunting for data instead of generating insights, delaying crucial business decisions."
      * **Success Vision:** We will now demonstrate how to create an environment that is secure by default, where operational mistakes are reversible in seconds, and where valuable, governed data assets are easily discoverable and shareable across the entire organization.

    **SHOW - Live Demonstration**

      * **Demo Script:**
        1.  Query the `PATIENT_360` view in the `GOLD` layer, showing sensitive PII columns in plaintext.
        2.  Apply **Dynamic Data Masking** policies to the columns with a single SQL statement.
        3.  Switch roles to a "BI\_USER" and re-run the exact same query. The sensitive data is now masked. **(Key Moment \#1)**. "This is automated, centralized governance. The policy is attached to the data, not the user's query. It's impossible for a BI user to see the raw PII, regardless of how they query it."
        4.  Switch back to the admin role. Run a faulty `UPDATE` statement that incorrectly nullifies a critical column. "A classic 'Friday afternoon' mistake. This would normally be a P1 incident."
        5.  Immediately run a `SELECT` query using **Time Travel** to show the data as it existed one minute before the error. The data is intact. **(Key Moment \#2)**. "No restoring from backups. We can instantly recover the correct data. This de-risks your entire operation."
        6.  Run a single `CLONE` command to create a perfect, readable copy of the entire multi-terabyte GOLD database. Show that it's instantaneous and shares the same storage, incurring zero additional cost. **(Key Moment \#3)**. "You're empowering your teams with production-scale data for development and testing without the cost or complexity."
        7.  "Now that you have this perfect, governed data asset, how do you make it discoverable for other teams? You publish it to your **Snowflake Internal Marketplace**."
        8.  Briefly show a pre-configured Internal Marketplace UI with the `GOLD` database listed as a new data product, complete with metadata. **(Key Moment \#4)**. "This turns your data into discoverable, reusable products, breaking down internal silos and creating a secure, internal data economy, all while maintaining the strict governance we just established."
      * **Audience Engagement:** "Phil, how would features like Time Travel and a central, governed discovery portal for data assets change the risk profile and agility of your development lifecycle?"
      * **Technical Talking Points:**
          * **RBAC & Policy-based Governance:** Security policies live with the data, ensuring consistent enforcement everywhere.
          * **Immutable Storage:** Snowflake’s underlying architecture makes features like Time Travel and Zero-Copy Cloning possible.

    **TELL \#2 - Reinforce Value**

      * **Business Impact:** This is how you build unbreakable trust. Automated governance reduces compliance risk. Time Travel turns potential outages into five-minute fixes. Zero-copy cloning accelerates development by 10x, and the Internal Marketplace breaks down data silos, fostering secure collaboration and maximizing the value of your data assets.
      * **Differentiation:** Microsoft Fabric has no equivalent to Time Travel, Zero-Copy Cloning, or an integrated internal data marketplace. Snowflake delivers this critical trust, agility, and collaboration out-of-the-box.
      * **Next Steps:** With a unified, trusted, and discoverable data asset, we can now unlock its full value with AI.

-----

### **Vignette 3: Powering the Future: From Trusted Data to Generative AI**

  * **Target Audience:** `Head of Data Science (Mustafa Ghafouri), Chief Architect (Miles Hewitt)`

  * **Core Message:** `Snowflake is the premier platform for AI/ML, providing a secure, unified environment to seamlessly build, deploy, operationalize, and share everything from predictive models to advanced GenAI agents, without data ever leaving the governance boundary.`

  * **Value Wedge Potential:** `High - Directly addresses Mustafa's concerns about Snowflake's ML maturity and the desire for a smooth MLOps experience. Showcases our serverless, integrated AI and the ability to productize ML assets via the Internal Marketplace.`

  * **Demo Flow Structure (Tell-Show-Tell):**

    **TELL \#1 - Set the Stage**

      * **Business Context:** Mustafa, your key priority is to bring AI/ML in-house and ensure a "smooth delivery" experience. Your vision for an agentic chatbot requires a powerful, developer-friendly platform that keeps sensitive patient data secure and allows you to easily share the results of your work.
      * **Quantified Problem:** "You've noted that past AI/ML projects struggled with complex deployment and version control. Every day spent wrestling with infrastructure and custom integrations is a day not spent delivering value from models like 'Smart Reminders,' which could save millions."
      * **Success Vision:** We will now show you how Snowflake provides that "smooth delivery" experience, from raw data to powerful insights, and how you can instantly share those insights with the business, all within a single, secure, and fully managed platform.

    **SHOW - Live Demonstration**

      * **Demo Script:**
        1.  "The foundation for great AI is democratizing data access. Let's empower a non-technical marketing manager."
        2.  First, quickly create a **Semantic Model** on our `V_PATIENT_360` view, explaining this provides business context for our AI.
        3.  Pivot to the **Snowflake Intelligence (Cortex Analyst)** UI. Ask a series of business questions in plain English:
              * "Which are our top 5 most prescribed drugs this year?"
              * "For the top drug, Atorvastatin, what is the demographic breakdown of patients by age group?"
              * "Of the Atorvastatin patients over 65, how many have not converted on our 'Heart Health Month' marketing campaign?" **(Key Moment \#1)**
        4.  "In seconds, we've identified a high-value, actionable cohort—a task that previously took days. This is true data democratization."
        5.  Switch to a Snowpark for Python notebook. "Now, for your data science team."
        6.  Show a simple Python notebook that uses the same `PATIENT_360` view to train a classification model predicting patient churn, running on a managed **Container Runtime** for dedicated ML compute. **(Key Moment \#2)**.
        7.  Deploy the trained model to Snowflake's model registry with a single command. "The entire MLOps lifecycle—from feature engineering to one-line model deployment—happens inside Snowflake."
        8.  "But a model is only useful if the business can act on it. You can publish the resulting churn scores as a new, live dataset directly to the **Internal Marketplace**."
        9.  Show the churn scores dataset listed in the Marketplace. "The marketing team can now securely access these live predictions, join them with campaign data, and take action—closing the loop from data science to business value, with zero data movement." **(Key Moment \#3)**.
      * **Audience Engagement:** "Mustafa, how does this integrated experience, including the ability to instantly productize a model's output for the business, compare to managing Azure ML services, containers, and data movement today?"
      * **Technical Talking Points:**
          * **Cortex AI:** A fully managed intelligence layer that makes sophisticated AI accessible to all users.
          * **Snowpark:** Provides first-class support for Python, running in secure, scalable containerized compute next to the data.

    **TELL \#2 - Reinforce Value**

      * **Business Impact:** This unified approach drastically reduces MLOps complexity and accelerates time-to-value for your AI initiatives. By keeping all data and processing within Snowflake's governance boundary and using the Internal Marketplace to share results, you eliminate security risks and close the gap between your data science and business teams.
      * **Differentiation:** Microsoft requires you to be the systems integrator. Snowflake delivers a fully integrated, secure, and serverless AI platform with a built-in mechanism to operationalize and monetize AI assets internally.
      * **Next Steps:** Let's discuss a proof-of-concept to build out one of these use cases on your own data.

## 6.0 Technical Requirements Summary

  * **Data Sources:**
      * Azure SQL DB (for prescription data)
      * PostgreSQL (for anonymized patient data)
      * Azure Data Lake Storage (ADLS) Gen2 (for JSON marketing events)
  * **Processing Capabilities:**
      * **Snowpipe:** For continuous, micro-batch ingestion.
      * **Snowflake Connectors:** For bulk/incremental loading.
      * **Dynamic Tables:** For declarative, automated ELT transformations.
      * **Snowpark (Python):** For data science and ML model training/deployment.
      * **Container Runtimes:** For scalable, dedicated compute for ML workloads.
  * **Analytics & Collaboration Features:**
      * **Snowflake Intelligence (Cortex Analyst):** For natural language, self-service querying.
      * **Semantic Models:** To provide business context to Cortex AI.
      * **Dynamic Data Masking & Tagging:** For automated, policy-based data governance.
      * **Time Travel & Zero-Copy Cloning:** For operational resiliency and dev/test agility.
      * **Snowflake Internal Marketplace:** For secure, internal discovery and sharing of data products (datasets, apps, models).
      * **Secure Data Sharing:** For live, secure data collaboration with external partners.
  * **User Interfaces:**
      * Snowflake UI (Snowsight Worksheets, Notebooks, Cortex Analyst UI, Marketplace UI)
      * Power BI Desktop (connected to Snowflake)
  * **Integration Points:**
      * **Microsoft Power BI:** Demonstrate DirectQuery connectivity to the GOLD layer.
      * **Microsoft Purview:** Discuss the bi-directional connector for unified governance.

## 7.0 Dependencies & Constraints

  * **Data Requirements:**
      * Access to anonymized, sample datasets representing:
          * Prescriptions (from SQL Server)
          * Patient demographics (from PostgreSQL)
          * Marketing campaign events (as JSON files in ADLS)
  * **Infrastructure:**
      * A configured Snowflake Enterprise (or higher) account on Azure.
      * Network connectivity established to allow Snowflake to access the source systems.
  * **Timeline Constraints:** The entire demonstration narrative must be delivered within a **45-minute** timeframe. Each vignette should be approximately 10-13 minutes.
  * **Audience Constraints:** The audience is a mix of technical and business leaders. The narrative must balance deep technical "wow" moments with clear connections to business value.