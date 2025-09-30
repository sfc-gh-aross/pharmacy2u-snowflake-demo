"""
Pharmacy2U Demo - Prescription Data Generator
Purpose: Generate realistic UK prescription data using Snowpark Python
Target: 500K+ records in <5 minutes
Method: Tier 1 - Snowpark Python server-side generation
"""

from snowflake.snowpark import Session
from snowflake.snowpark.functions import (
    col, lit, uniform, dateadd, current_timestamp, 
    to_date, seq4, concat, floor
)
from snowflake.snowpark.types import (
    StructType, StructField, StringType, IntegerType, 
    DoubleType, DateType, TimestampType
)
import sys
from datetime import datetime, timedelta
import logging

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)


# UK BNF drug codes and common prescriptions
UK_DRUGS = [
    ('0212000B0', 'Atorvastatin', 28, 14.50),
    ('0601023Z0', 'Metformin', 56, 8.20),
    ('0205051R0', 'Ramipril', 28, 6.30),
    ('0604011L0', 'Levothyroxine', 28, 4.80),
    ('0501130R0', 'Omeprazole', 28, 5.90),
    ('0407010H0', 'Salbutamol Inhaler', 1, 12.50),
    ('0407020A0', 'Fluticasone Inhaler', 1, 18.90),
    ('0101010T0', 'Gaviscon', 12, 9.40),
    ('0403010A0', 'Aspirin', 28, 3.20),
    ('0304010G0', 'Chlorphenamine', 28, 2.80),
    ('0106070A0', 'Bisacodyl', 20, 3.50),
    ('0402010N0', 'Amlodipine', 28, 5.60),
    ('0410010N0', 'Citalopram', 28, 7.80),
    ('0602010Y0', 'Insulin Glargine', 5, 32.50),
    ('0301011R0', 'Amoxicillin', 21, 6.90),
]


def create_snowpark_session(connection_name: str = 'pharmacy2u_demo_connection') -> Session:
    """Create Snowpark session from Snowflake CLI connection"""
    try:
        from snowflake.cli.api.secure_path import SecurePath
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
        
        logger.info(f"✅ Snowpark session created successfully using connection: {connection_name}")
        return session
    
    except Exception as e:
        logger.error(f"❌ Failed to create Snowpark session: {str(e)}")
        logger.info("💡 Attempting to use get_active_session() as fallback...")
        try:
            from snowflake.snowpark.context import get_active_session
            session = get_active_session()
            logger.info("✅ Using active Snowpark session")
            return session
        except:
            raise Exception(f"Could not create Snowpark session: {str(e)}")


def generate_prescription_data(session: Session, target_records: int = 500000) -> None:
    """
    Generate realistic UK prescription data using Snowpark
    
    Args:
        session: Active Snowpark session
        target_records: Number of prescription records to generate (default 500K)
    """
    logger.info(f"🚀 Starting prescription data generation - Target: {target_records:,} records")
    start_time = datetime.now()
    
    # Set context
    session.sql("USE DATABASE PHARMACY2U_BRONZE").collect()
    session.sql("USE SCHEMA RAW_DATA").collect()
    session.sql("USE WAREHOUSE PHARMACY2U_LOADING_WH").collect()
    
    # Create temporary drug reference table
    logger.info("📋 Creating drug reference data...")
    drug_data = []
    for drug_code, drug_name, typical_qty, avg_cost in UK_DRUGS:
        drug_data.append((drug_code, drug_name, typical_qty, avg_cost))
    
    drug_schema = StructType([
        StructField("DRUG_CODE", StringType()),
        StructField("DRUG_NAME", StringType()),
        StructField("TYPICAL_QTY", IntegerType()),
        StructField("AVG_COST", DoubleType())
    ])
    
    drug_df = session.create_dataframe(drug_data, schema=drug_schema)
    drug_df.write.mode("overwrite").save_as_table("TEMP_DRUG_REFERENCE", mode="overwrite")
    
    # Generate prescription data using Snowflake's GENERATOR function
    logger.info(f"💊 Generating {target_records:,} prescription records...")
    
    prescription_sql = f"""
    INSERT INTO RAW_PRESCRIPTIONS (
        PRESCRIPTION_ID,
        PATIENT_ID,
        DRUG_CODE,
        DRUG_NAME,
        QUANTITY,
        DAYS_SUPPLY,
        PRESCRIPTION_DATE,
        PRESCRIBER_ID,
        PHARMACY_ID,
        COST_GBP,
        INGESTION_TIMESTAMP,
        SOURCE_SYSTEM
    )
    SELECT
        'RX-' || LPAD(SEQ4(), 10, '0') AS PRESCRIPTION_ID,
        'PT-' || LPAD(UNIFORM(1, 100000, RANDOM()), 8, '0') AS PATIENT_ID,
        drugs.DRUG_CODE,
        drugs.DRUG_NAME,
        drugs.TYPICAL_QTY + UNIFORM(-5, 10, RANDOM()) AS QUANTITY,
        CASE 
            WHEN UNIFORM(1, 100, RANDOM()) <= 60 THEN 28
            WHEN UNIFORM(1, 100, RANDOM()) <= 85 THEN 56
            ELSE 84
        END AS DAYS_SUPPLY,
        DATEADD(
            DAY, 
            -UNIFORM(0, 730, RANDOM()),
            CURRENT_DATE()
        ) AS PRESCRIPTION_DATE,
        'DR-' || LPAD(UNIFORM(1, 500, RANDOM()), 5, '0') AS PRESCRIBER_ID,
        'PH-' || LPAD(UNIFORM(1, 50, RANDOM()), 3, '0') AS PHARMACY_ID,
        ROUND(
            drugs.AVG_COST * (1 + (UNIFORM(-20, 30, RANDOM()) / 100.0)), 
            2
        ) AS COST_GBP,
        CURRENT_TIMESTAMP() AS INGESTION_TIMESTAMP,
        'SQL_SERVER' AS SOURCE_SYSTEM
    FROM 
        TABLE(GENERATOR(ROWCOUNT => {target_records})) gen
    CROSS JOIN (
        SELECT * FROM TEMP_DRUG_REFERENCE 
        QUALIFY ROW_NUMBER() OVER (ORDER BY RANDOM()) = UNIFORM(1, 15, RANDOM())
    ) drugs
    """
    
    session.sql(prescription_sql).collect()
    
    # Validate data generation
    count_result = session.sql("SELECT COUNT(*) as COUNT FROM RAW_PRESCRIPTIONS").collect()
    actual_count = count_result[0]['COUNT']
    
    # Cleanup temporary table
    session.sql("DROP TABLE IF EXISTS TEMP_DRUG_REFERENCE").collect()
    
    # Calculate performance metrics
    end_time = datetime.now()
    duration = (end_time - start_time).total_seconds()
    records_per_second = actual_count / duration if duration > 0 else 0
    
    logger.info(f"✅ Prescription data generation completed!")
    logger.info(f"   📊 Records generated: {actual_count:,}")
    logger.info(f"   ⏱️  Duration: {duration:.2f} seconds")
    logger.info(f"   🚀 Performance: {records_per_second:,.0f} records/second")
    
    # Benchmark validation (target: 1M+ records in <300 seconds)
    if duration < 300 and actual_count >= target_records * 0.95:
        logger.info(f"   ✅ BENCHMARK PASSED: Generated {actual_count:,} records in {duration:.2f}s")
    else:
        logger.warning(f"   ⚠️  BENCHMARK CONCERN: Review performance metrics")
    
    # Show sample data
    logger.info("📋 Sample prescription data:")
    sample_df = session.table("RAW_PRESCRIPTIONS").limit(5)
    sample_df.show()


def main():
    """Main execution function"""
    try:
        # Get connection name from command line or use default
        connection_name = sys.argv[1] if len(sys.argv) > 1 else 'pharmacy2u_demo_connection'
        target_records = int(sys.argv[2]) if len(sys.argv) > 2 else 500000
        
        # Create Snowpark session
        session = create_snowpark_session(connection_name)
        
        # Generate prescription data
        generate_prescription_data(session, target_records)
        
        # Close session
        session.close()
        logger.info("🎉 Prescription data generation workflow completed successfully!")
        
    except Exception as e:
        logger.error(f"❌ ERROR: {str(e)}")
        sys.exit(1)


if __name__ == "__main__":
    main()
