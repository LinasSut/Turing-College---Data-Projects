-- First query takes nesserary information from adsence table

WITH adsence_monthly AS (
    SELECT
        campaign,
        month,
        Impressions
    FROM `tc-da-1.turing_data_analytics.adsense_monthly`
)

-- In the main query we using adsence_monthly table joined with raw_events table for gathering information about impresions and actual page_views from campaigns
SELECT
    adsence_monthly.campaign,
    adsence_monthly.impressions,
    COUNT(DISTINCT user_pseudo_id) AS page_view
FROM `turing_data_analytics.raw_events` as raw_events
JOIN adsence_monthly
    ON raw_events.campaign = adsence_monthly.campaign
WHERE raw_events.event_name ='page_view'
    AND (adsence_monthly.Campaign IN ('NewYear_V1', 'NewYear_V2', 'BlackFriday_V1', 'BlackFriday_V2')
    AND ((adsence_monthly.Month = 202011) OR adsence_monthly.Month = 202101) )
GROUP BY adsence_monthly.campaign, adsence_monthly.impressions
ORDER BY adsence_monthly.campaign