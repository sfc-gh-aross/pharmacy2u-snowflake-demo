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

# Custom CSS for Pharmacy2U branding (matching pharmacy2u.co.uk)
st.markdown("""
<style>
    @import url('https://fonts.googleapis.com/css2?family=Open+Sans:wght@400;600;700&display=swap');
    
    /* Pharmacy2U Color Palette */
    :root {
        --p2u-purple: #6a0dad;
        --p2u-teal: #20b2aa;
        --p2u-pink: #ff69b4;
        --p2u-blue: #007bff;
        --p2u-dark-purple: #4a0080;
        --p2u-light-bg: #f8f9fa;
    }
    
    /* Global Font */
    html, body, [class*="css"] {
        font-family: 'Open Sans', sans-serif;
    }
    
    /* Main Header with Pharmacy2U Logo */
    .main-header {
        font-size: 2.5rem;
        font-weight: 700;
        color: var(--p2u-purple);
        margin-bottom: 1rem;
        background: linear-gradient(135deg, var(--p2u-purple) 0%, var(--p2u-teal) 100%);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        background-clip: text;
    }
    
    .logo-container {
        display: flex;
        align-items: center;
        gap: 1rem;
        margin-bottom: 1rem;
    }
    
    .logo-text {
        font-size: 2.5rem;
        font-weight: 700;
        color: var(--p2u-purple);
    }
    
    /* Metric Cards */
    .metric-card {
        background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
        padding: 1.5rem;
        border-radius: 1rem;
        border-left: 5px solid var(--p2u-teal);
        box-shadow: 0 4px 6px rgba(106, 13, 173, 0.1);
    }
    
    .stMetric {
        background-color: #ffffff;
        padding: 1.5rem;
        border-radius: 1rem;
        box-shadow: 0 4px 12px rgba(0,0,0,0.08);
        border-top: 3px solid var(--p2u-teal);
    }
    
    /* Section Headers */
    h2, h3 {
        color: var(--p2u-purple) !important;
        font-weight: 600 !important;
    }
    
    /* Buttons and Interactive Elements */
    .stButton>button {
        background: linear-gradient(135deg, var(--p2u-teal) 0%, var(--p2u-blue) 100%);
        color: white;
        border: none;
        border-radius: 0.5rem;
        font-weight: 600;
        padding: 0.75rem 2rem;
        transition: all 0.3s ease;
    }
    
    .stButton>button:hover {
        background: linear-gradient(135deg, var(--p2u-purple) 0%, var(--p2u-pink) 100%);
        box-shadow: 0 6px 12px rgba(106, 13, 173, 0.3);
        transform: translateY(-2px);
    }
    
    /* Sidebar Styling */
    [data-testid="stSidebar"] {
        background: linear-gradient(180deg, #f8f9fa 0%, #ffffff 100%);
        border-right: 3px solid var(--p2u-purple);
    }
    
    [data-testid="stSidebar"] h1, [data-testid="stSidebar"] h2 {
        color: var(--p2u-purple) !important;
    }
    
    /* Data Table Styling */
    .dataframe {
        border: 2px solid var(--p2u-teal) !important;
        border-radius: 0.5rem;
    }
    
    /* Footer Styling */
    .footer {
        background: linear-gradient(135deg, var(--p2u-purple) 0%, var(--p2u-teal) 100%);
        color: white;
        padding: 2rem;
        border-radius: 1rem;
        text-align: center;
        margin-top: 2rem;
    }
    
    /* Vibrant Accent Colors */
    .accent-purple { color: var(--p2u-purple); }
    .accent-teal { color: var(--p2u-teal); }
    .accent-pink { color: var(--p2u-pink); }
</style>
""", unsafe_allow_html=True)

# Application header with Pharmacy2U branding
st.markdown("""
<div class="logo-container">
    <img src="https://www.pharmacy2u.co.uk/themes/p2u/assets/p2u_logo.svg" 
         alt="Pharmacy2U Logo" 
         style="height: 60px; margin-right: 1rem;">
    <div style="flex-grow: 1;">
        <h1 style="color: #6a0dad; font-size: 2rem; font-weight: 700; margin: 0;">
            Patient 360 Dashboard
        </h1>
        <p style="color: #20b2aa; font-size: 1rem; margin: 0.25rem 0 0 0;">
            Real-time pharmaceutical analytics powered by Snowflake Data Cloud
        </p>
    </div>
</div>
<hr style="border: none; height: 2px; background: linear-gradient(90deg, #6a0dad 0%, #20b2aa 100%); margin: 1.5rem 0;">
""", unsafe_allow_html=True)

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
                color_discrete_sequence=['#20b2aa']
            )
            fig_age.update_layout(
                showlegend=False, 
                height=400,
                plot_bgcolor='rgba(0,0,0,0)',
                paper_bgcolor='rgba(0,0,0,0)',
                font=dict(color='#6a0dad')
            )
            st.plotly_chart(fig_age, use_container_width=True, config={'displayModeBar': False})
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
                color_discrete_sequence=['#6a0dad', '#20b2aa', '#ff69b4']
            )
            fig_gender.update_layout(
                height=400,
                plot_bgcolor='rgba(0,0,0,0)',
                paper_bgcolor='rgba(0,0,0,0)',
                font=dict(color='#6a0dad')
            )
            st.plotly_chart(fig_gender, use_container_width=True, config={'displayModeBar': False})
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
                color_discrete_sequence=['#6a0dad'],
                render_mode='svg'
            )
            fig_scatter.update_layout(
                height=400,
                plot_bgcolor='rgba(0,0,0,0)',
                paper_bgcolor='rgba(0,0,0,0)',
                font=dict(color='#6a0dad')
            )
            fig_scatter.update_traces(marker=dict(size=8, opacity=0.6))
            st.plotly_chart(fig_scatter, use_container_width=True, config={'displayModeBar': False})
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
                color_discrete_sequence=['#ff69b4']
            )
            fig_drugs.update_layout(
                showlegend=False, 
                height=400,
                plot_bgcolor='rgba(0,0,0,0)',
                paper_bgcolor='rgba(0,0,0,0)',
                font=dict(color='#6a0dad')
            )
            st.plotly_chart(fig_drugs, use_container_width=True, config={'displayModeBar': False})
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
    <div class='footer'>
        <h3 style='color: white; margin-bottom: 0.5rem;'>💊 Pharmacy2U Patient 360 Dashboard</h3>
        <p style='font-size: 1.1rem; margin-bottom: 0.5rem;'>Powered by Snowflake Data Cloud</p>
        <p style='opacity: 0.9;'>Real-time analytics from unified pharmaceutical data platform</p>
        <p style='font-size: 0.9rem; opacity: 0.8; margin-top: 1rem;'>
            Pharmacy2U - 25 years of digital healthcare leadership
        </p>
    </div>
    """,
    unsafe_allow_html=True
)
