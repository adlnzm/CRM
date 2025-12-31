import uuid
import json
import psycopg2
from datetime import datetime
import os

conn = psycopg2.connect(
    host='localhost',
    database='crm',
    user='postgres',
    password='3452'
)
cursor = conn.cursor()

def ingest_event(event) :
    cursor.execute("""
        INSERT INTO raw_events (
            event_id,
            email,
            company,
            industry,
            event_type,
            channel,
            event_time     
        )
        VALUES (%s,%s,%s,%s,%s,%s,%s) ON CONFLICT (event_id) DO NOTHING;
    """, (
        event.get("event_id", str(uuid.uuid4())),
        event['email'].lower(),
        event.get('company'),
        event.get('industry'),
        event['event_type'],
        event['channel'],
        event['event_time']
    ))

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(BASE_DIR)

json_path = os.path.join(BASE_DIR, "data", "raw_events.json")

with open(json_path, "r") as f:
    events = json.load(f)

for event in events :
    ingest_event(event)

conn.commit()
cursor.close()
conn.close()

print("Raw events ingested successfully")