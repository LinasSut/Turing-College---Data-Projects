-- Selecting all relevant data for futher analysis
 WITH main_data AS (
  SELECT 
    user_pseudo_id,
    event_name,
    TIMESTAMP_MICROS(event_timestamp) AS event_time,
    campaign,
    country,
    purchase_revenue_in_usd,
  FROM `turing_data_analytics.raw_events`
),

last_session as  (
  SELECT 
    user_pseudo_id,
    event_name,
    event_time, 
    campaign,
    country,
    purchase_revenue_in_usd,
    LAG(main_data.event_time) OVER (PARTITION BY user_pseudo_id ORDER BY main_data.event_time) AS last_event
  FROM main_data
),

-- Calculating a new session as new session from 60 minutes of inactivity
new_session as (
  SELECT *, 
    CASE WHEN (event_time - last_event) >= INTERVAL '60' MINUTE OR last_event IS NULL THEN 1 ELSE 0 END as is_new_session
  FROM last_session
),

-- Calculating unique global session ID and User session ID
global_sessions as (
  SELECT 
    user_pseudo_id,
    event_name,
    event_time,
    SUM(is_new_session) OVER (ORDER BY user_pseudo_id, event_time) AS global_session_id,
    SUM(is_new_session) OVER (PARTITION BY user_pseudo_id ORDER BY event_time) AS user_session_id,
    campaign,
    country,
    purchase_revenue_in_usd
  FROM new_session
),

-- Finding the sessions campaing name
campaign as (
  SELECT 
  user_pseudo_id,
  global_session_id,
  adsense_campaing.Campaign_name,
FROM global_sessions
JOIN 
    (SELECT DISTINCT (Campaign) as Campaign_name
      FROM `turing_data_analytics.adsense_monthly`) as adsense_campaing
  ON global_sessions.campaign = adsense_campaing.Campaign_name
 ), 

-- Calculating each session Revenue
session_revenue as (
  SELECT 
    user_pseudo_id,
    global_session_id,
    SUM(purchase_revenue_in_usd) as revenue
  FROM global_sessions
  GROUP BY user_pseudo_id, global_session_id
),


-- Calculating each session session times in minutes
session_time as (
  SELECT 
    user_pseudo_id, 
    global_session_id,
    user_session_id,
    MIN(event_time) as first_event_time,
    MAX(event_time) as last_event_time,
    country,
    (DATE_DIFF(MAX(event_time),MIN(event_time),second)) as session_time,
  FROM global_sessions
    GROUP BY user_pseudo_id, global_session_id, user_session_id, country
),

-- Joining session time data and session revenues
combined_data as (
  SELECT 
    session_time.user_pseudo_id, 
    session_time.global_session_id,
    session_time.user_session_id,
    session_time.first_event_time,
    session_time.last_event_time,
    session_time.country,
    campaign.campaign_name,
    session_time.session_time,
    CASE 
      WHEN EXTRACT(hour FROM session_time.first_event_time) BETWEEN 0 AND 5 THEN 'Night'
      WHEN EXTRACT(hour FROM session_time.first_event_time) BETWEEN 6 AND 11 THEN 'Morning'
      WHEN EXTRACT(hour FROM session_time.first_event_time) BETWEEN 12 AND 17 THEN 'Afternoon'
      WHEN EXTRACT(hour FROM session_time.first_event_time) BETWEEN 18 AND 23 THEN 'Evening'
    END AS session_time_of_the_day,
    CASE
      WHEN session_time.session_time = 0 THEN 1 ELSE 0 END AS bounce_status,
    session_revenue.revenue
  FROM session_time
  JOIN campaign
    ON session_time.global_session_id = campaign.global_session_id
  JOIN session_revenue
    ON session_time.global_session_id = session_revenue.global_session_id
    GROUP BY user_pseudo_id, global_session_id, user_session_id, first_event_time, last_event_time, campaign.campaign_name, country, session_time,session_revenue.revenue
   
)

-- main query where selecting all the data for futher analysis
SELECT 
*
FROM combined_data
