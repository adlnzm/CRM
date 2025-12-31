CREATE TABLE IF NOT EXISTS crm_contacts (
    contact_id UUID PRIMARY KEY,
    email TEXT UNIQUE,
    company TEXT,
    industry TEXT,
    lead_source TEXT,
    current_stage TEXT NOT NULL DEFAULT 'Lead',          -- Lead, MQL, SQL, Customer
    nurture_track TEXT NOT NULL DEFAULT 'Low',          -- Low, Mid, High
    intent_score INT,
    first_touch_channel TEXT,
    last_activity_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

INSERT INTO crm_contacts (
    contact_id,
    email,
    company,
    industry,
    current_stage,
    nurture_track,
    intent_score,
    first_touch_channel
)
SELECT
    gen_random_uuid() AS contact_id,
    r.email,
    r.company,
    r.industry,
    'Lead' AS current_stage,
    'Low' AS nurture_track,
    0 AS intent_score,
    r.channel AS first_touch_channel
FROM raw_events r 
LEFT JOIN crm_contacts c ON r.email = c.email
WHERE c.email IS NULL;

UPDATE crm_contacts c
SET 
    intent_score =
        s.views * 10 +
        s.downloads * 20 +
        s.demos_booked * 40,

    current_stage = 
        CASE
            WHEN s.demos_booked >= 1 THEN 'SQL'
            WHEN s.downloads >= 1 THEN 'MQL'
            ELSE 'Lead'
        END,

    nurture_track = 
        CASE 
            WHEN S.demos_booked >= 1 THEN 'High'
            WHEN s.downloads >= 1 THEN 'Mid'
            ELSE 'Low'
        END,

    last_activity_at = s.last_engagement,
    updated_at = NOW()
FROM crm_engagement_summary s
WHERE c.contact_id = s.contact_id;

CREATE VIEW vw_funnel AS
SELECT
    current_stage,
    COUNT(*) AS users
FROM crm_contacts
GROUP BY current_stage;

CREATE VIEW vw_channel_effectiveness AS
SELECT
    first_touch_channel,
    current_stage,
    COUNT(*) AS users
FROM crm_contacts
GROUP BY first_touch_channel, current_stage;

CREATE VIEW vw_intent_by_source AS
SELECT
    lead_source,
    AVG(intent_score) AS avg_intent
FROM crm_contacts
GROUP BY lead_source;