CREATE TABLE IF NOT EXISTS crm_activity_events (
    event_id UUID PRIMARY KEY REFERENCES raw_events(event_id) ON DELETE CASCADE,
    contact_id UUID REFERENCES crm_contacts(contact_id) ON DELETE CASCADE,
    event_type TEXT NOT NULL,            -- click, view, download, demo_booked
    channel TEXT NOT NULL,               -- Facebook, Email, LinkedIn
    event_time TIMESTAMP NOT NULL,
    metadata JSONB DEFAULT '{}'
);

INSERT INTO crm_activity_events (
    event_id,
    contact_id,
    event_type,
    channel,
    event_time
)