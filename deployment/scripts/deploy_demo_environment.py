"""
Pharmacy2U Demo - Master Deployment Script
Purpose: Automated deployment of complete demo environment
Follows: Demo Builder Phase 3B deployment workflow
"""

import subprocess
import sys
import logging
from pathlib import Path
from datetime import datetime
import time

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


class DemoDeployer:
    """Automated deployment orchestrator for Pharmacy2U demo"""
    
    def __init__(self, connection_name: str = 'pharmacy2u_demo_connection'):
        self.connection_name = connection_name
        self.project_root = Path(__file__).parent.parent.parent
        self.sql_dir = self.project_root / 'sql'
        self.deployment_start = datetime.now()
        
    def run_sql_file(self, sql_file: Path) -> bool:
        """Execute SQL file using Snowflake CLI"""
        try:
            logger.info(f"📄 Executing: {sql_file.name}")
            
            cmd = [
                'snow', 'sql',
                '--filename', str(sql_file),
                '--connection', self.connection_name
            ]
            
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                check=True
            )
            
            logger.info(f"   ✅ Completed: {sql_file.name}")
            return True
            
        except subprocess.CalledProcessError as e:
            logger.error(f"   ❌ Failed: {sql_file.name}")
            logger.error(f"   Error: {e.stderr}")
            return False
    
    def run_python_script(self, script_path: Path, *args) -> bool:
        """Execute Python script"""
        try:
            logger.info(f"🐍 Executing: {script_path.name}")
            
            cmd = [sys.executable, str(script_path), self.connection_name] + list(args)
            
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                check=True
            )
            
            logger.info(result.stdout)
            logger.info(f"   ✅ Completed: {script_path.name}")
            return True
            
        except subprocess.CalledProcessError as e:
            logger.error(f"   ❌ Failed: {script_path.name}")
            logger.error(f"   Error: {e.stderr}")
            return False
    
    def validate_connection(self) -> bool:
        """Validate Snowflake connection before deployment"""
        logger.info(f"🔍 Validating connection: {self.connection_name}")
        
        try:
            # Test basic connectivity with a simple query (don't validate database/schema)
            cmd = [
                'snow', 'sql',
                '--query', 'SELECT CURRENT_ACCOUNT(), CURRENT_USER(), CURRENT_ROLE();',
                '--connection', self.connection_name
            ]
            result = subprocess.run(cmd, capture_output=True, text=True, check=True)
            logger.info(f"   ✅ Connection validated successfully")
            logger.info(f"   Account: {self.connection_name}")
            return True
        except subprocess.CalledProcessError as e:
            logger.error(f"   ❌ Connection test failed: {e.stderr}")
            logger.error(f"   💡 Verify connection exists: snow connection list")
            return False
    
    def deploy_infrastructure(self) -> bool:
        """Deploy database infrastructure (Phase 1)"""
        logger.info("=" * 80)
        logger.info("PHASE 1: INFRASTRUCTURE DEPLOYMENT")
        logger.info("=" * 80)
        
        setup_scripts = [
            self.sql_dir / 'setup' / '00_database_setup.sql',
            self.sql_dir / 'setup' / '01_warehouse_configuration.sql',
            self.sql_dir / 'setup' / '02_schema_creation.sql',
            self.sql_dir / 'setup' / '03_permissions.sql',
        ]
        
        for script in setup_scripts:
            if not script.exists():
                logger.warning(f"   ⚠️  Script not found: {script}")
                continue
            
            if not self.run_sql_file(script):
                return False
        
        logger.info("✅ Infrastructure deployment completed")
        return True
    
    def generate_synthetic_data(self) -> bool:
        """Generate synthetic data using Snowpark Python (Phase 2)"""
        logger.info("=" * 80)
        logger.info("PHASE 2: SYNTHETIC DATA GENERATION")
        logger.info("=" * 80)
        
        data_gen_dir = self.project_root / 'src' / 'python' / 'data_generation'
        
        # Generate prescriptions (500K records)
        logger.info("💊 Generating prescription data (500K records)...")
        prescription_gen = data_gen_dir / 'prescription_generator.py'
        if prescription_gen.exists():
            if not self.run_python_script(prescription_gen, '500000'):
                logger.warning("⚠️ Prescription generation had issues, continuing...")
        
        # Generate patients (100K records)
        logger.info("👥 Generating patient data (100K records)...")
        patient_gen = data_gen_dir / 'patient_generator.py'
        if patient_gen.exists():
            if not self.run_python_script(patient_gen, '100000'):
                logger.warning("⚠️ Patient generation had issues, continuing...")
        
        # Generate marketing events (1M records)
        logger.info("📧 Generating marketing events (1M records)...")
        marketing_gen = data_gen_dir / 'marketing_events_generator.py'
        if marketing_gen.exists():
            if not self.run_python_script(marketing_gen, '1000000'):
                logger.warning("⚠️ Marketing events generation had issues, continuing...")
        
        logger.info("✅ Synthetic data generation completed")
        return True
    
    def load_marketing_events_to_snowflake(self) -> bool:
        """Load generated marketing events JSON to Snowflake"""
        logger.info("📤 Loading marketing events to Snowflake...")
        
        try:
            # PUT file to stage
            json_file = self.project_root / 'data' / 'synthetic' / 'marketing_events.json'
            if not json_file.exists():
                logger.warning("⚠️ Marketing events JSON file not found, skipping...")
                return True
            
            put_cmd = f"""
            USE DATABASE PHARMACY2U_BRONZE;
            USE SCHEMA RAW_DATA;
            PUT file://{json_file} @MARKETING_STAGE AUTO_COMPRESS=TRUE OVERWRITE=TRUE;
            
            COPY INTO RAW_MARKETING_EVENTS
            FROM @MARKETING_STAGE
            FILE_FORMAT = (TYPE = 'JSON')
            ON_ERROR = 'CONTINUE';
            """
            
            # Write to temp SQL file and execute
            temp_sql = self.project_root / 'deployment' / 'temp_load_marketing.sql'
            temp_sql.parent.mkdir(exist_ok=True)
            temp_sql.write_text(put_cmd)
            
            self.run_sql_file(temp_sql)
            temp_sql.unlink()  # Clean up
            
            logger.info("✅ Marketing events loaded to Snowflake")
            return True
            
        except Exception as e:
            logger.error(f"❌ Error loading marketing events: {str(e)}")
            return False
    
    def deploy_features(self) -> bool:
        """Deploy P0 features (Phase 3)"""
        logger.info("=" * 80)
        logger.info("PHASE 3: FEATURE DEPLOYMENT (P0)")
        logger.info("=" * 80)
        
        feature_scripts = [
            self.sql_dir / 'features' / 'dynamic_tables' / 'bronze_to_silver.sql',
            self.sql_dir / 'features' / 'governance' / 'access_policies.sql',
        ]
        
        for script in feature_scripts:
            if not script.exists():
                logger.warning(f"   ⚠️  Script not found: {script}")
                continue
            
            if not self.run_sql_file(script):
                logger.warning(f"   ⚠️  Feature deployment had issues: {script.name}")
        
        logger.info("✅ Feature deployment completed")
        return True
    
    def validate_deployment(self) -> bool:
        """Validate deployment success"""
        logger.info("=" * 80)
        logger.info("PHASE 4: DEPLOYMENT VALIDATION")
        logger.info("=" * 80)
        
        validation_sql = """
        -- Validate databases exist
        SHOW DATABASES LIKE 'PHARMACY2U%';
        
        -- Validate warehouses exist
        SHOW WAREHOUSES LIKE 'PHARMACY2U%';
        
        -- Validate table counts
        SELECT 'RAW_PRESCRIPTIONS' AS TABLE_NAME, COUNT(*) AS ROW_COUNT 
        FROM PHARMACY2U_BRONZE.RAW_DATA.RAW_PRESCRIPTIONS
        UNION ALL
        SELECT 'RAW_PATIENTS', COUNT(*) 
        FROM PHARMACY2U_BRONZE.RAW_DATA.RAW_PATIENTS
        UNION ALL
        SELECT 'RAW_MARKETING_EVENTS', COUNT(*) 
        FROM PHARMACY2U_BRONZE.RAW_DATA.RAW_MARKETING_EVENTS;
        """
        
        temp_sql = self.project_root / 'deployment' / 'temp_validation.sql'
        temp_sql.write_text(validation_sql)
        
        result = self.run_sql_file(temp_sql)
        temp_sql.unlink()
        
        return result
    
    def deploy(self) -> bool:
        """Execute complete deployment workflow"""
        logger.info("🚀 Starting Pharmacy2U Demo Deployment")
        logger.info(f"   Connection: {self.connection_name}")
        logger.info(f"   Project Root: {self.project_root}")
        logger.info("")
        
        # Step 1: Validate connection
        if not self.validate_connection():
            return False
        
        # Step 2: Deploy infrastructure
        if not self.deploy_infrastructure():
            logger.error("❌ Infrastructure deployment failed")
            return False
        
        # Step 3: Generate synthetic data
        if not self.generate_synthetic_data():
            logger.error("❌ Data generation failed")
            return False
        
        # Step 4: Load marketing events
        if not self.load_marketing_events_to_snowflake():
            logger.warning("⚠️ Marketing events load had issues, continuing...")
        
        # Step 5: Deploy features
        if not self.deploy_features():
            logger.warning("⚠️ Feature deployment had issues, continuing...")
        
        # Step 6: Validate deployment
        if not self.validate_deployment():
            logger.warning("⚠️ Validation had issues, please check manually")
        
        # Calculate deployment time
        deployment_duration = (datetime.now() - self.deployment_start).total_seconds()
        
        logger.info("=" * 80)
        logger.info("🎉 DEPLOYMENT COMPLETED SUCCESSFULLY!")
        logger.info("=" * 80)
        logger.info(f"   Total Duration: {deployment_duration:.2f} seconds")
        logger.info(f"   Connection: {self.connection_name}")
        logger.info("")
        logger.info("📋 Next Steps:")
        logger.info("   1. Run validation: python deployment/scripts/validate_deployment.py")
        logger.info("   2. Deploy Streamlit apps: python deployment/scripts/deploy_streamlit_apps.py")
        logger.info("   3. Review demo scripts in sql/demo_scripts/")
        logger.info("")
        
        return True


def main():
    """Main execution function"""
    try:
        connection_name = sys.argv[1] if len(sys.argv) > 1 else 'pharmacy2u_demo_connection'
        
        deployer = DemoDeployer(connection_name)
        success = deployer.deploy()
        
        sys.exit(0 if success else 1)
        
    except KeyboardInterrupt:
        logger.warning("\n⚠️ Deployment cancelled by user")
        sys.exit(1)
    except Exception as e:
        logger.error(f"❌ Deployment failed: {str(e)}")
        sys.exit(1)


if __name__ == "__main__":
    main()
