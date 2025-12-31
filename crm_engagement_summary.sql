CREATE TABLE IF NOT EXISTS crm_engagement_summary (
    contact_id UUID PRIMARY KEY,
    clicks INT DEFAULT 0,
    "views" INT DEFAULT 0,
    downloads INT DEFAULT 0,
    demos_booked INT DEFAULT 0,
    last_engagement TIMESTAMP
);

INSERT INTO crm_engagement_summary (contact_id)
SELECT DISTINCT contact_id
FROM crm_activity_events
ON CONFLICT (contact_id) DO NOTHING;

    UPDATE crm_engagement_summary s
    SET
        clicks = sub.clicks,
        "views" = sub."views",
        downloads = sub.downloads,
        demos_booked = sub.demos_booked,
        last_engagement = sub.last_event
    FROM (
        SELECT
            contact_id,
            COUNT(*) FILTER (WHERE event_type = 'click') AS clicks,
            COUNT(*) FILTER (WHERE event_type = 'view') AS "views",
            COUNT(*) FILTER (WHERE event_type = 'download') AS downloads,
            COUNT(*) FILTER (WHERE event_type = 'demo_booked') AS demos_booked,
            MAX(event_time) AS last_event
        FROM crm_activity_events
        GROUP BY contact_id
    ) sub
    WHERE s.contact_id = sub.contact_id;