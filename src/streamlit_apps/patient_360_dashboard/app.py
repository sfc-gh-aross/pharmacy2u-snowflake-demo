"""
Pharmacy2U Patient 360 Dashboard
Streamlit application for comprehensive patient analytics
"""

import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from datetime import datetime, timedelta

# CRITICAL: Use native Snowflake session for Streamlit in Snowflake
try:
    from snowflake.snowpark.context import get_active_session
    session = get_active_session()
except Exception as e:
    st.error(f"⚠️ Could not get active Snowflake session: {str(e)}")
    st.stop()


# Helper function for safe row access (CRITICAL for Snowpark Row objects)
def get_row_value(row, column_name, default_value=''):
    """Safely extract value from Snowpark Row object"""
    try:
        return getattr(row, column_name, default_value)
    except:
        return default_value


# Page configuration
st.set_page_config(
    page_title="Pharmacy2U Patient 360",
    page_icon="💊",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Custom CSS for Pharmacy2U branding
st.markdown("""
<style>
    .main-header {
        font-size: 2.5rem;
        font-weight: 700;
        color: #0066CC;
        margin-bottom: 1rem;
    }
    .metric-card {
        background-color: #f0f8ff;
        padding: 1rem;
        border-radius: 0.5rem;
        border-left: 4px solid #0066CC;
    }
    .stMetric {
        background-color: #ffffff;
        padding: 1rem;
        border-radius: 0.5rem;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
</style>
""", unsafe_allow_html=True)

# Application header
st.markdown('<div class="main-header">💊 Pharmacy2U Patient 360 Dashboard</div>', unsafe_allow_html=True)
st.markdown("**Real-time pharmaceutical analytics powered by Snowflake**")

# Sidebar filters
st.sidebar.header("🔍 Filters")
selected_timeframe = st.sidebar.selectbox(
    "Time Period",
    ["Last 30 Days", "Last 90 Days", "Last 6 Months", "Last Year", "All Time"]
)

# Map timeframe to days
timeframe_days = {
    "Last 30 Days": 30,
    "Last 90 Days": 90,
    "Last 6 Months": 180,
    "Last Year": 365,
    "All Time": 99999
}
days = timeframe_days[selected_timeframe]


# Function to load patient 360 data with error handling
@st.cache_data(ttl=300)
def load_patient_360_data(_session):
    """Load Patient 360 view with comprehensive error handling"""
    try:
        sql = f"""
        SELECT * FROM PHARMACY2U_GOLD.ANALYTICS.V_PATIENT_360
        WHERE REGISTRATION_DATE >= DATEADD(DAY, -{days}, CURRENT_DATE())
        LIMIT 10000
        """
        df = _session.sql(sql).to_pandas()
        
        if df.empty:
            st.warning("⚠️ No patient data found. Generating sample data...")
            return generate_sample_data()
        
        return df
    except Exception as e:
        st.error(f"⚠️ Error loading patient data: {str(e)}")
        st.info("Using sample data for demonstration...")
        return generate_sample_data()


def generate_sample_data():
    """Generate sample patient data for fallback"""
    import numpy as np
    
    sample_data = {
        'PATIENT_ID': [f'PT-{i:08d}' for i in range(1, 101)],
        'AGE': np.random.randint(18, 90, 100),
        'GENDER': np.random.choice(['Male', 'Female'], 100),
        'TOTAL_PRESCRIPTIONS': np.random.randint(1, 50, 100),
        'UNIQUE_DRUGS': np.random.randint(1, 10, 100),
        'LIFETIME_VALUE_GBP': np.random.uniform(50, 5000, 100),
        'MARKETING_INTERACTIONS': np.random.randint(0, 100, 100),
        'CAMPAIGN_CONVERSIONS': np.random.randint(0, 20, 100),
    }
    return pd.DataFrame(sample_data)


# Load data
try:
    with st.spinner('Loading patient data...'):
        df = load_patient_360_data(session)
except Exception as e:
    st.error(f"Critical error: {str(e)}")
    df = generate_sample_data()

# Key Metrics Row
st.subheader("📊 Key Performance Indicators")
col1, col2, col3, col4 = st.columns(4)

with col1:
    total_patients = len(df)
    st.metric("Total Patients", f"{total_patients:,}")

with col2:
    avg_prescriptions = df['TOTAL_PRESCRIPTIONS'].mean() if 'TOTAL_PRESCRIPTIONS' in df.columns else 0
    st.metric("Avg Prescriptions/Patient", f"{avg_prescriptions:.1f}")

with col3:
    total_revenue = df['LIFETIME_VALUE_GBP'].sum() if 'LIFETIME_VALUE_GBP' in df.columns else 0
    st.metric("Total Revenue", f"£{total_revenue:,.0f}")

with col4:
    conversion_rate = (df['CAMPAIGN_CONVERSIONS'].sum() / df['MARKETING_INTERACTIONS'].sum() * 100) if 'MARKETING_INTERACTIONS' in df.columns and df['MARKETING_INTERACTIONS'].sum() > 0 else 0
    st.metric("Campaign Conversion Rate", f"{conversion_rate:.1f}%")

# Visualizations
st.subheader("📈 Analytics")

# Row 1: Patient Demographics
col1, col2 = st.columns(2)

with col1:
    st.markdown("**Patient Age Distribution**")
    try:
        if 'AGE' in df.columns:
            fig_age = px.histogram(
                df, 
                x='AGE', 
                nbins=20,
                title='Patient Age Distribution',
                color_discrete_sequence=['#0066CC']
            )
            fig_age.update_layout(showlegend=False, height=400)
            st.plotly_chart(fig_age, use_container_width=True)
        else:
            st.info("Age data not available")
    except Exception as e:
        st.error(f"Error creating age chart: {str(e)}")

with col2:
    st.markdown("**Gender Distribution**")
    try:
        if 'GENDER' in df.columns:
            gender_counts = df['GENDER'].value_counts()
            fig_gender = px.pie(
                values=gender_counts.values,
                names=gender_counts.index,
                title='Patient Gender Distribution',
                color_discrete_sequence=['#0066CC', '#66B3FF']
            )
            fig_gender.update_layout(height=400)
            st.plotly_chart(fig_gender, use_container_width=True)
        else:
            st.info("Gender data not available")
    except Exception as e:
        st.error(f"Error creating gender chart: {str(e)}")

# Row 2: Prescription Analytics
st.markdown("**Prescription & Revenue Analytics**")
col3, col4 = st.columns(2)

with col3:
    try:
        if 'TOTAL_PRESCRIPTIONS' in df.columns and 'LIFETIME_VALUE_GBP' in df.columns:
            fig_scatter = px.scatter(
                df,
                x='TOTAL_PRESCRIPTIONS',
                y='LIFETIME_VALUE_GBP',
                title='Prescriptions vs Lifetime Value',
                trendline='ols',
                color_discrete_sequence=['#0066CC']
            )
            fig_scatter.update_layout(height=400)
            st.plotly_chart(fig_scatter, use_container_width=True)
        else:
            st.info("Prescription data not available")
    except Exception as e:
        st.error(f"Error creating scatter plot: {str(e)}")

with col4:
    try:
        if 'UNIQUE_DRUGS' in df.columns:
            fig_drugs = px.histogram(
                df,
                x='UNIQUE_DRUGS',
                title='Distribution of Unique Drugs per Patient',
                color_discrete_sequence=['#0066CC']
            )
            fig_drugs.update_layout(showlegend=False, height=400)
            st.plotly_chart(fig_drugs, use_container_width=True)
        else:
            st.info("Drug data not available")
    except Exception as e:
        st.error(f"Error creating drugs chart: {str(e)}")

# Patient Data Table
st.subheader("👥 Patient Details")
try:
    display_cols = ['PATIENT_ID', 'AGE', 'GENDER', 'TOTAL_PRESCRIPTIONS', 
                    'LIFETIME_VALUE_GBP', 'MARKETING_INTERACTIONS', 'CAMPAIGN_CONVERSIONS']
    available_cols = [col for col in display_cols if col in df.columns]
    
    if available_cols:
        st.dataframe(
            df[available_cols].head(20),
            use_container_width=True,
            height=400
        )
    else:
        st.warning("No patient data columns available")
except Exception as e:
    st.error(f"Error displaying patient table: {str(e)}")

# Footer
st.markdown("---")
st.markdown(
    """
    <div style='text-align: center; color: #666; padding: 1rem;'>
        <p>Pharmacy2U Patient 360 Dashboard | Powered by Snowflake Data Cloud</p>
        <p>Data updated in real-time from unified data platform</p>
    </div>
    """,
    unsafe_allow_html=True
)
