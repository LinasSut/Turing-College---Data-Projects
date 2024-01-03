WITH purchases as 
(
  SELECT
    user_pseudo_id,
    country,
    category,
    mobile_brand_name,
    purchase_revenue_in_usd,
    timestamp_micros(event_timestamp) as purchase_date,
  FROM `turing_data_analytics.raw_events`
  WHERE event_name = 'purchase'  
), 

page_view as 
(
  SELECT 
    user_pseudo_id,
   timestamp_micros(event_timestamp) as page_view_date
  FROM `turing_data_analytics.raw_events`
  WHERE event_name = 'page_view' 
),

Joined as 
(
  SELECT 
    p.user_pseudo_id,
    p.country,
    p.category,
    p.mobile_brand_name,
    p.purchase_revenue_in_usd,
    p.purchase_date,
    CASE 
      WHEN EXTRACT(hour FROM p.purchase_date) BETWEEN 0 AND 5 THEN 'Night'
      WHEN EXTRACT(hour FROM p.purchase_date) BETWEEN 6 AND 11 THEN 'Morning'
      WHEN EXTRACT(hour FROM p.purchase_date) BETWEEN 12 AND 17 THEN 'Afternoon'
      WHEN EXTRACT(hour FROM p.purchase_date) BETWEEN 18 AND 23 THEN 'Evening'
    END AS purchase_time_of_the_day,
    MIN(pw.page_view_date) as first_page_view_date
  FROM purchases  as p
  JOIN page_view as pw
    ON p.user_pseudo_id = pw.user_pseudo_id
    AND (DATE(p.purchase_date) = DATE(pw.page_view_date))
  GROUP BY p.user_pseudo_id, p.country, p.category, p.mobile_brand_name, p.purchase_revenue_in_usd, p.purchase_date, purchase_time_of_the_day
)

SELECT
  *
FROM joined