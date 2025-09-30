"""
Pharmacy2U Demo - Marketing Events Generator
Purpose: Generate realistic marketing event JSON files for ADLS Gen2 ingestion demo
Target: 1M+ events in <3 minutes
Method: Tier 3 - Local Python generation with JSON output
"""

import json
import random
from datetime import datetime, timedelta
from pathlib import Path
import logging
import sys

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# Marketing campaign configurations
CAMPAIGNS = [
    {"id": "CAMP-001", "name": "Heart Health Month", "channel": "email"},
    {"id": "CAMP-002", "name": "Flu Season Reminder", "channel": "sms"},
    {"id": "CAMP-003", "name": "Prescription Refill Alert", "channel": "push"},
    {"id": "CAMP-004", "name": "Diabetes Awareness", "channel": "email"},
    {"id": "CAMP-005", "name": "Summer Allergy Relief", "channel": "sms"},
    {"id": "CAMP-006", "name": "Winter Wellness", "channel": "email"},
    {"id": "CAMP-007", "name": "Mental Health Support", "channel": "push"},
    {"id": "CAMP-008", "name": "NHS Prescription Savings", "channel": "email"},
]

EVENT_TYPES = ["email_open", "click", "conversion", "app_open", "sms_delivered", "push_notification"]


def generate_marketing_events(target_records: int = 1000000, output_dir: str = "data/synthetic") -> None:
    """
    Generate realistic marketing event JSON data
    
    Args:
        target_records: Number of events to generate (default 1M)
        output_dir: Output directory for JSON files
    """
    logger.info(f"🚀 Starting marketing events generation - Target: {target_records:,} events")
    start_time = datetime.now()
    
    # Create output directory
    output_path = Path(output_dir)
    output_path.mkdir(parents=True, exist_ok=True)
    
    events = []
    end_date = datetime.now()
    start_date = end_date - timedelta(days=730)  # 2 years of data
    
    logger.info(f"📧 Generating {target_records:,} marketing events...")
    
    for i in range(target_records):
        # Generate random event timestamp
        random_days = random.randint(0, 730)
        random_seconds = random.randint(0, 86400)
        event_timestamp = start_date + timedelta(days=random_days, seconds=random_seconds)
        
        # Select campaign and event type
        campaign = random.choice(CAMPAIGNS)
        event_type = random.choice(EVENT_TYPES)
        
        # Determine conversion (higher for certain event types)
        conversion_probability = 0.15 if event_type == "conversion" else (
            0.08 if event_type == "click" else 0.02
        )
        conversion_flag = random.random() < conversion_probability
        
        event = {
            "event_id": f"EVT-{i+1:010d}",
            "patient_id": f"PT-{random.randint(1, 100000):08d}",
            "campaign_id": campaign["id"],
            "campaign_name": campaign["name"],
            "event_type": event_type,
            "event_timestamp": event_timestamp.isoformat(),
            "channel": campaign["channel"],
            "conversion_flag": conversion_flag,
            "metadata": {
                "device_type": random.choice(["mobile", "desktop", "tablet"]),
                "browser": random.choice(["Chrome", "Safari", "Firefox", "Edge"]),
                "location": random.choice(["London", "Manchester", "Birmingham", "Leeds", "Glasgow"])
            }
        }
        
        events.append(event)
        
        # Progress logging
        if (i + 1) % 100000 == 0:
            logger.info(f"   Generated {i+1:,} events...")
    
    # Write to JSON file
    output_file = output_path / "marketing_events.json"
    logger.info(f"💾 Writing events to {output_file}...")
    
    with open(output_file, 'w') as f:
        json.dump(events, f, indent=2)
    
    # Calculate performance metrics
    end_time = datetime.now()
    duration = (end_time - start_time).total_seconds()
    events_per_second = len(events) / duration if duration > 0 else 0
    file_size_mb = output_file.stat().st_size / (1024 * 1024)
    
    logger.info(f"✅ Marketing events generation completed!")
    logger.info(f"   📊 Events generated: {len(events):,}")
    logger.info(f"   💾 File size: {file_size_mb:.2f} MB")
    logger.info(f"   ⏱️  Duration: {duration:.2f} seconds")
    logger.info(f"   🚀 Performance: {events_per_second:,.0f} events/second")
    
    # Benchmark validation (target: 500K+ events in <180 seconds)
    if duration < 180 and len(events) >= target_records * 0.95:
        logger.info(f"   ✅ BENCHMARK PASSED: Generated {len(events):,} events in {duration:.2f}s")
    else:
        logger.warning(f"   ⚠️  BENCHMARK CONCERN: Review performance metrics")
    
    logger.info(f"   📁 Output file: {output_file}")


def main():
    """Main execution function"""
    try:
        # Handle optional connection name argument (skip it for local generation)
        arg_offset = 0
        if len(sys.argv) > 1 and not sys.argv[1].isdigit():
            # First arg is connection name, skip it
            arg_offset = 1
        
        target_records = int(sys.argv[1 + arg_offset]) if len(sys.argv) > (1 + arg_offset) else 1000000
        output_dir = sys.argv[2 + arg_offset] if len(sys.argv) > (2 + arg_offset) else "data/synthetic"
        
        generate_marketing_events(target_records, output_dir)
        logger.info("🎉 Marketing events generation workflow completed successfully!")
        
    except Exception as e:
        logger.error(f"❌ ERROR: {str(e)}")
        sys.exit(1)


if __name__ == "__main__":
    main()
