"""
Pharmacy2U Demo - Streamlit Application Deployment
Purpose: Deploy Streamlit in Snowflake applications
Follows: Demo Builder critical deployment patterns
"""

import subprocess
import sys
import logging
from pathlib import Path

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)


class StreamlitDeployer:
    """Automated Streamlit application deployer"""
    
    def __init__(self, connection_name: str = 'pharmacy2u_demo_connection'):
        self.connection_name = connection_name
        self.project_root = Path(__file__).parent.parent.parent
    
    def deploy_patient_360_dashboard(self) -> bool:
        """Deploy Patient 360 Dashboard Streamlit app"""
        logger.info("🚀 Deploying Patient 360 Dashboard...")
        
        app_dir = self.project_root / 'src' / 'streamlit_apps' / 'patient_360_dashboard'
        app_file = app_dir / 'app.py'
        env_file = app_dir / 'environment.yml'
        
        if not app_file.exists():
            logger.error(f"❌ App file not found: {app_file}")
            return False
        
        if not env_file.exists():
            logger.warning(f"⚠️ environment.yml not found: {env_file}")
        
        try:
            # Create deployment SQL
            deploy_sql = f"""
            USE ROLE ACCOUNTADMIN;
            USE DATABASE PHARMACY2U_DEMO_DB;
            USE SCHEMA DEMO_SCHEMA;
            USE WAREHOUSE PHARMACY2U_ANALYTICS_WH;
            
            -- Upload files to stage
            PUT file://{app_file} @PHARMACY2U_STREAMLIT_STAGE/patient_360/ AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
            PUT file://{env_file} @PHARMACY2U_STREAMLIT_STAGE/patient_360/ AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
            
            -- Drop existing app if it exists
            DROP STREAMLIT IF EXISTS PATIENT_360_DASHBOARD;
            
            -- Create Streamlit app
            CREATE STREAMLIT PATIENT_360_DASHBOARD
                ROOT_LOCATION = '@PHARMACY2U_STREAMLIT_STAGE/patient_360'
                MAIN_FILE = 'app.py'
                QUERY_WAREHOUSE = 'PHARMACY2U_ANALYTICS_WH'
                COMMENT = 'Patient 360 analytics dashboard for pharmaceutical insights';
            
            -- Grant permissions
            GRANT USAGE ON STREAMLIT PATIENT_360_DASHBOARD TO ROLE PUBLIC;
            """
            
            # Write to temp file and execute
            temp_sql = self.project_root / 'deployment' / 'temp_streamlit_deploy.sql'
            temp_sql.parent.mkdir(exist_ok=True)
            temp_sql.write_text(deploy_sql)
            
            cmd = ['snow', 'sql', '--filename', str(temp_sql), '--connection', self.connection_name]
            result = subprocess.run(cmd, capture_output=True, text=True, check=True)
            
            temp_sql.unlink()  # Clean up
            
            # Get app URL
            url_cmd = ['snow', 'streamlit', 'get-url', 'PATIENT_360_DASHBOARD', '--connection', self.connection_name]
            url_result = subprocess.run(url_cmd, capture_output=True, text=True)
            
            logger.info("✅ Patient 360 Dashboard deployed successfully!")
            if url_result.returncode == 0:
                logger.info(f"   📱 App URL: {url_result.stdout.strip()}")
            
            return True
            
        except subprocess.CalledProcessError as e:
            logger.error(f"❌ Deployment failed: {e.stderr}")
            return False
    
    def deploy_all(self) -> bool:
        """Deploy all Streamlit applications"""
        logger.info("=" * 80)
        logger.info("STREAMLIT APPLICATION DEPLOYMENT")
        logger.info("=" * 80)
        
        success = True
        
        # Deploy Patient 360 Dashboard
        if not self.deploy_patient_360_dashboard():
            success = False
        
        if success:
            logger.info("=" * 80)
            logger.info("🎉 ALL STREAMLIT APPS DEPLOYED SUCCESSFULLY!")
            logger.info("=" * 80)
        
        return success


def main():
    """Main execution function"""
    try:
        connection_name = sys.argv[1] if len(sys.argv) > 1 else 'pharmacy2u_demo_connection'
        
        deployer = StreamlitDeployer(connection_name)
        success = deployer.deploy_all()
        
        sys.exit(0 if success else 1)
        
    except Exception as e:
        logger.error(f"❌ Deployment failed: {str(e)}")
        sys.exit(1)


if __name__ == "__main__":
    main()
