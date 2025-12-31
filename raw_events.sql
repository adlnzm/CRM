CREATE TABLE IF NOT EXISTS raw_events (
    event_id UUID PRIMARY KEY,
    email TEXT NOT NULL,
    company TEXT,
    industry TEXT,
    event_type TEXT NOT NULL,
    channel TEXT NOT NULL,
    event_time TIMESTAMP NOT NULL,
    ingested_at TIMESTAMP DEFAULT NOW()
);

SELECT
    r.event_id,
    c.contact_id,
    r.event_type,
    r.channel,
    r.event_time
FROM raw_events r 
JOIN crm_contacts c ON r.email = c.email;