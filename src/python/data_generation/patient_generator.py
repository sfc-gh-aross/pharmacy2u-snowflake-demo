"""
Pharmacy2U Demo - Patient Data Generator
Purpose: Generate realistic UK patient data using Snowpark Python
Target: 100K+ records in <5 minutes
Method: Tier 1 - Snowpark Python server-side generation
"""

from snowflake.snowpark import Session
from snowflake.snowpark.functions import col, lit, uniform, dateadd, current_timestamp
import sys
from datetime import datetime
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)


def create_snowpark_session(connection_name: str = 'pharmacy2u_demo_connection') -> Session:
    """Create Snowpark session from Snowflake CLI connection"""
    try:
        from snowflake.cli.api.config import get_connection
        
        connection_config = get_connection(connection_name)
        
        session = Session.builder.configs({
            "account": connection_config.get('account'),
            "user": connection_config.get('user'),
            "role": connection_config.get('role', 'ACCOUNTADMIN'),
            "warehouse": connection_config.get('warehouse', 'PHARMACY2U_LOADING_WH'),
            "database": connection_config.get('database', 'PHARMACY2U_BRONZE'),
            "schema": connection_config.get('schema', 'RAW_DATA'),
            "authenticator": connection_config.get('authenticator', 'externalbrowser'),
        }).create()
        
        logger.info(f"✅ Snowpark session created successfully")
        return session
    
    except Exception as e:
        logger.error(f"❌ Failed to create Snowpark session: {str(e)}")
        try:
            from snowflake.snowpark.context import get_active_session
            session = get_active_session()
            logger.info("✅ Using active Snowpark session")
            return session
        except:
            raise Exception(f"Could not create Snowpark session: {str(e)}")


def generate_patient_data(session: Session, target_records: int = 100000) -> None:
    """
    Generate realistic UK patient data using Snowpark
    
    Args:
        session: Active Snowpark session
        target_records: Number of patient records to generate (default 100K)
    """
    logger.info(f"🚀 Starting patient data generation - Target: {target_records:,} records")
    start_time = datetime.now()
    
    # Set context
    session.sql("USE DATABASE PHARMACY2U_BRONZE").collect()
    session.sql("USE SCHEMA RAW_DATA").collect()
    session.sql("USE WAREHOUSE PHARMACY2U_LOADING_WH").collect()
    
    # Generate patient data using Snowflake's GENERATOR function
    logger.info(f"👥 Generating {target_records:,} patient records...")
    
    patient_sql = f"""
    INSERT INTO RAW_PATIENTS (
        PATIENT_ID,
        FIRST_NAME,
        LAST_NAME,
        DATE_OF_BIRTH,
        GENDER,
        NHS_NUMBER,
        POSTCODE,
        EMAIL,
        PHONE,
        REGISTRATION_DATE,
        INGESTION_TIMESTAMP,
        SOURCE_SYSTEM
    )
    SELECT
        'PT-' || LPAD(SEQ4(), 8, '0') AS PATIENT_ID,
        CASE UNIFORM(1, 20, RANDOM())
            WHEN 1 THEN 'James' WHEN 2 THEN 'Mary' WHEN 3 THEN 'John'
            WHEN 4 THEN 'Patricia' WHEN 5 THEN 'Robert' WHEN 6 THEN 'Jennifer'
            WHEN 7 THEN 'Michael' WHEN 8 THEN 'Linda' WHEN 9 THEN 'William'
            WHEN 10 THEN 'Elizabeth' WHEN 11 THEN 'David' WHEN 12 THEN 'Barbara'
            WHEN 13 THEN 'Richard' WHEN 14 THEN 'Susan' WHEN 15 THEN 'Joseph'
            WHEN 16 THEN 'Jessica' WHEN 17 THEN 'Thomas' WHEN 18 THEN 'Sarah'
            WHEN 19 THEN 'Charles' ELSE 'Karen'
        END AS FIRST_NAME,
        CASE UNIFORM(1, 20, RANDOM())
            WHEN 1 THEN 'Smith' WHEN 2 THEN 'Jones' WHEN 3 THEN 'Williams'
            WHEN 4 THEN 'Brown' WHEN 5 THEN 'Taylor' WHEN 6 THEN 'Davies'
            WHEN 7 THEN 'Wilson' WHEN 8 THEN 'Evans' WHEN 9 THEN 'Thomas'
            WHEN 10 THEN 'Johnson' WHEN 11 THEN 'Roberts' WHEN 12 THEN 'Walker'
            WHEN 13 THEN 'Wright' WHEN 14 THEN 'Robinson' WHEN 15 THEN 'Thompson'
            WHEN 16 THEN 'White' WHEN 17 THEN 'Hughes' WHEN 18 THEN 'Edwards'
            WHEN 19 THEN 'Green' ELSE 'Lewis'
        END AS LAST_NAME,
        DATEADD(
            DAY, 
            -UNIFORM(18*365, 90*365, RANDOM()),
            CURRENT_DATE()
        ) AS DATE_OF_BIRTH,
        CASE WHEN UNIFORM(1, 100, RANDOM()) <= 51 THEN 'Female' ELSE 'Male' END AS GENDER,
        LPAD(UNIFORM(100000000, 999999999, RANDOM()), 10, '0') AS NHS_NUMBER,
        CASE UNIFORM(1, 10, RANDOM())
            WHEN 1 THEN 'SW1A 1AA' WHEN 2 THEN 'M1 1AD' WHEN 3 THEN 'B2 4QA'
            WHEN 4 THEN 'LS1 1BA' WHEN 5 THEN 'NE1 1EE' WHEN 6 THEN 'G1 1AA'
            WHEN 7 THEN 'CF10 1DD' WHEN 8 THEN 'EH1 1YZ' WHEN 9 THEN 'BS1 1AA'
            ELSE 'L1 1AA'
        END AS POSTCODE,
        LOWER(
            CASE UNIFORM(1, 20, RANDOM())
                WHEN 1 THEN 'james' WHEN 2 THEN 'mary' WHEN 3 THEN 'john'
                WHEN 4 THEN 'patricia' WHEN 5 THEN 'robert' WHEN 6 THEN 'jennifer'
                ELSE 'patient'
            END || '.' || 
            CASE UNIFORM(1, 10, RANDOM())
                WHEN 1 THEN 'smith' WHEN 2 THEN 'jones' WHEN 3 THEN 'williams'
                ELSE 'user'
            END || 
            UNIFORM(100, 9999, RANDOM()) || '@email.com'
        ) AS EMAIL,
        '07' || LPAD(UNIFORM(100000000, 999999999, RANDOM()), 9, '0') AS PHONE,
        DATEADD(
            DAY, 
            -UNIFORM(0, 1825, RANDOM()),
            CURRENT_DATE()
        ) AS REGISTRATION_DATE,
        CURRENT_TIMESTAMP() AS INGESTION_TIMESTAMP,
        'POSTGRESQL' AS SOURCE_SYSTEM
    FROM TABLE(GENERATOR(ROWCOUNT => {target_records}))
    """
    
    session.sql(patient_sql).collect()
    
    # Validate data generation
    count_result = session.sql("SELECT COUNT(*) as COUNT FROM RAW_PATIENTS").collect()
    actual_count = count_result[0]['COUNT']
    
    # Calculate performance metrics
    end_time = datetime.now()
    duration = (end_time - start_time).total_seconds()
    records_per_second = actual_count / duration if duration > 0 else 0
    
    logger.info(f"✅ Patient data generation completed!")
    logger.info(f"   📊 Records generated: {actual_count:,}")
    logger.info(f"   ⏱️  Duration: {duration:.2f} seconds")
    logger.info(f"   🚀 Performance: {records_per_second:,.0f} records/second")
    
    # Benchmark validation
    if duration < 300 and actual_count >= target_records * 0.95:
        logger.info(f"   ✅ BENCHMARK PASSED: Generated {actual_count:,} records in {duration:.2f}s")
    else:
        logger.warning(f"   ⚠️  BENCHMARK CONCERN: Review performance metrics")
    
    # Show sample data
    logger.info("📋 Sample patient data:")
    sample_df = session.table("RAW_PATIENTS").limit(5)
    sample_df.show()


def main():
    """Main execution function"""
    try:
        connection_name = sys.argv[1] if len(sys.argv) > 1 else 'pharmacy2u_demo_connection'
        target_records = int(sys.argv[2]) if len(sys.argv) > 2 else 100000
        
        session = create_snowpark_session(connection_name)
        generate_patient_data(session, target_records)
        session.close()
        
        logger.info("🎉 Patient data generation workflow completed successfully!")
        
    except Exception as e:
        logger.error(f"❌ ERROR: {str(e)}")
        sys.exit(1)


if __name__ == "__main__":
    main()
