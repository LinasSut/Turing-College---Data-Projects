-- Find unique values of each user

WITH unique_events AS (
    SELECT
        user_pseudo_id,
        MIN(event_timestamp) as first_event,
        event_name,
        country
    FROM `turing_data_analytics.raw_events`
    GROUP BY user_pseudo_id, event_name,country
),

-- Shows Top 3 countries and their number of events
top_countries AS (
    SELECT
        country,
        COUNT(unique_events.first_event) AS event_count
        FROM unique_events
        GROUP BY country
    ORDER BY event_count DESC
LIMIT 3
),

-- Funnel stages and their order in each top country
funnel AS (
    SELECT
        unique_events.country,
        event_name,
        COUNT(*) AS event_count,
        (CASE event_name
            WHEN "page_view" THEN 1
            WHEN "view_item" THEN 2
            WHEN "add_to_cart" THEN 3
            WHEN "begin_checkout" THEN 4
            WHEN "purchase" THEN 5
            ELSE 0
        END) AS event_order
    FROM unique_events
    JOIN top_countries
        ON unique_events.country = top_countries.country
    GROUP BY country , event_name
)

-- Main table where calculating each country events per stage and each country percentage drop

SELECT
    event_order,
    event_name,
        SUM(CASE WHEN country = "United States" THEN event_count END) AS United_States_events,
    SUM(CASE WHEN country = "Canada" THEN event_count END) AS Canada_events,
    SUM(CASE WHEN country = "India" THEN event_count END) AS India_events,
    SUM(event_count) / MAX(SUM(event_count)) OVER () AS Full_perc,
    SUM((CASE WHEN country = 'United States' THEN event_count END)) / (SELECT MAX(event_count) FROM funnel WHERE country = 'United States') AS US_country_perc_drop,
    SUM((CASE WHEN country = 'India' THEN event_count END)) / (SELECT MAX(event_count) FROM funnel WHERE country = 'India') AS India_country_perc_drop,
    SUM((CASE WHEN country = 'Canada' THEN event_count END)) / (SELECT MAX(event_count) FROM funnel WHERE country = 'Canada') AS Canada_country_perc_drop,
FROM funnel
WHERE event_order != 0
GROUP BY event_order, event_name
ORDER BY event_order