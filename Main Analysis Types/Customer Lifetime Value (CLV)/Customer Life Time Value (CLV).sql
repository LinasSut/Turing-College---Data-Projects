-- In cohorts CTE calculating unique users and their first event date parsed as a start week
WITH
  cohorts AS (
    SELECT 
      DISTINCT user_pseudo_id,
      DATE_TRUNC(MIN((PARSE_DATE('%Y%m%d', event_date))),week) AS start_week
    FROM `turing_data_analytics.raw_events`
    GROUP BY user_pseudo_id
),

-- In orders CTE selecting only the users who purchased and their purchase event date parsed as purchase week
orders AS (
  SELECT
    user_pseudo_id,
    purchase_revenue_in_usd AS purchase,
    DATE_TRUNC((PARSE_DATE('%Y%m%d', event_date)),week) AS purchase_week
  FROM `turing_data_analytics.raw_events`
  WHERE event_name = 'purchase'
),

-- In main data CTE I joining cohorts and orders CTE's and extracting data, with unique users and their start week, week they purchase something and purchase amount filtering only required cohort weeks
main_data AS (
  SELECT 
    cohorts.user_pseudo_id,
    cohorts.start_week,
    orders.purchase,
    orders.purchase_week,
  FROM cohorts
  LEFT JOIN orders
    ON cohorts.user_pseudo_id = orders.user_pseudo_id
 WHERE cohorts.start_week <= '2021-01-24'
)

-- In main querry, taking my cohort week and calculating each week average purchases.

SELECT 
  main_data.start_week AS cohort_week,
  SUM(CASE WHEN main_data.purchase_week = main_data.start_week THEN main_data.purchase END) / (COUNT(DISTINCT user_pseudo_id)) AS week_0,
  SUM(CASE WHEN main_data.purchase_week = DATE_ADD (main_data.start_week, INTERVAL 1 WEEK) THEN main_data.purchase END) / (COUNT(DISTINCT user_pseudo_id)) AS week_1,
  SUM(CASE WHEN main_data.purchase_week = DATE_ADD (main_data.start_week, INTERVAL 2 WEEK) THEN main_data.purchase END) / (COUNT(DISTINCT user_pseudo_id)) AS week_2,
  SUM(CASE WHEN main_data.purchase_week = DATE_ADD (main_data.start_week, INTERVAL 3 WEEK) THEN main_data.purchase END) / (COUNT(DISTINCT user_pseudo_id)) AS week_3,
  SUM(CASE WHEN main_data.purchase_week = DATE_ADD (main_data.start_week, INTERVAL 4 WEEK) THEN main_data.purchase END) / (COUNT(DISTINCT user_pseudo_id)) AS week_4,
  SUM(CASE WHEN main_data.purchase_week = DATE_ADD (main_data.start_week, INTERVAL 5 WEEK) THEN main_data.purchase END) / (COUNT(DISTINCT user_pseudo_id)) AS week_5,
  SUM(CASE WHEN main_data.purchase_week = DATE_ADD (main_data.start_week, INTERVAL 6 WEEK) THEN main_data.purchase END) / (COUNT(DISTINCT user_pseudo_id)) AS week_6,
  SUM(CASE WHEN main_data.purchase_week = DATE_ADD (main_data.start_week, INTERVAL 7 WEEK) THEN main_data.purchase END) / (COUNT(DISTINCT user_pseudo_id)) AS week_7,
  SUM(CASE WHEN main_data.purchase_week = DATE_ADD (main_data.start_week, INTERVAL 8 WEEK) THEN main_data.purchase END) / (COUNT(DISTINCT user_pseudo_id)) AS week_8,
  SUM(CASE WHEN main_data.purchase_week = DATE_ADD (main_data.start_week, INTERVAL 9 WEEK) THEN main_data.purchase END) / (COUNT(DISTINCT user_pseudo_id)) AS week_9,
  SUM(CASE WHEN main_data.purchase_week = DATE_ADD (main_data.start_week, INTERVAL 10 WEEK) THEN main_data.purchase END) / (COUNT(DISTINCT user_pseudo_id)) AS week_10,
  SUM(CASE WHEN main_data.purchase_week = DATE_ADD (main_data.start_week, INTERVAL 11 WEEK) THEN main_data.purchase END) / (COUNT(DISTINCT user_pseudo_id)) AS week_11,
  SUM(CASE WHEN main_data.purchase_week = DATE_ADD (main_data.start_week, INTERVAL 12 WEEK) THEN main_data.purchase END) / (COUNT(DISTINCT user_pseudo_id)) AS week_12,

FROM main_data
GROUP BY cohort_week
ORDER BY cohort_week