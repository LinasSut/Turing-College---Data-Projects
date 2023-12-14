-- Calculating Frequency and monetary from RFM dataset
WITH FM_table AS (
  SELECT
    CustomerID,
    MAX(DATE_TRUNC(InvoiceDate,day)) AS last_purchase_date,
    COUNT(DISTINCT InvoiceNo) AS frequency,
    ROUND(SUM(Quantity * UnitPrice),2) AS monetary
  FROM `tc-da-1.turing_data_analytics.rfm`
  WHERE DATE_TRUNC(InvoiceDate, day) BETWEEN '2010-12-01' AND '2011-12-01'
    AND Quantity > 0
    AND unitprice > 0
  GROUP BY CustomerID
),

-- Calculating Recency for the analysis

R_table AS (
  SELECT
    CustomerID,
    frequency,
    monetary,
    DATE_DIFF(reference_date, last_purchase_date, DAY) as recency
  FROM
    (SELECT
      *,
      MAX(last_purchase_date) OVER () AS reference_date,
    FROM FM_table)
),

-- Calculating quitiles for Recency, Frequency, Monetary

quantiles AS (
  SELECT R_table.*,
    -- All Recency quntiles
    R_percentiles.percentiles[offset(25)] AS r25,
    R_percentiles.percentiles[offset(50)] AS r50,
    R_percentiles.percentiles[offset(75)] AS r75,
    R_percentiles.percentiles[offset(100)] AS r100,
      -- all Frequency Quintiles
    F_percentiles.percentiles[offset(25)] AS f25,
    F_percentiles.percentiles[offset(50)] AS f50,
    F_percentiles.percentiles[offset(75)] AS f75,
    F_percentiles.percentiles[offset(100)] AS f100,
    -- All Monetary Quitiles
    M_percentiles.percentiles[offset(25)] AS m25,
    M_percentiles.percentiles[offset(50)] AS m50,
    M_percentiles.percentiles[offset(75)] AS m75,
    M_percentiles.percentiles[offset(100)] AS m100
  FROM R_table,
    (SELECT approx_quantiles(recency, 100) AS percentiles FROM R_table) as R_percentiles,
    (SELECT approx_quantiles(frequency, 100) AS percentiles FROM R_table) as F_percentiles,
    (SELECT approx_quantiles(monetary, 100) AS percentiles FROM R_table) as M_percentiles
),

-- assigning sroces for monetary, frequency and recency

scores_assigned AS (
  SELECT
    *
  FROM
    (SELECT *,
      CASE
      WHEN monetary <= m25 THEN 1
      WHEN monetary <= m50 AND monetary > m25 THEN 2
      WHEN monetary <= m75 AND monetary > m50 THEN 3
      WHEN monetary <= m100 AND monetary > m75 THEN 4
      END AS m_score,
CASE
WHEN frequency <= f25 THEN 1
WHEN frequency <= f50 AND frequency > f25 THEN 2
WHEN frequency <= f75 AND frequency > f50 THEN 3
WHEN frequency <= f100 AND frequency > f75 THEN 4
END AS f_score,
CASE
WHEN recency <= r25 THEN 4
WHEN recency <= r50 AND recency > r25 THEN 3
WHEN recency <= r75 AND recency > r50 THEN 2
WHEN recency <= r100 AND recency > r75 THEN 1
END AS r_score,
FROM quantiles
)
),

-- Defining RFM segments

rfm_segments AS (
SELECT
customerid,
recency,
frequency,
monetary,
r_score,
f_score,
m_score,
CASE
WHEN (r_score = 4 AND f_score = 4 AND m_score = 4) THEN 'Best Customers'
WHEN (r_score = 4 AND f_score = 4 AND m_score = 3)
OR (r_score = 4 AND f_score = 4 AND m_score = 2)
OR (r_score = 3 AND f_score = 4 AND m_score = 4)
OR (r_score = 3 AND f_score = 4 AND m_score = 3)
OR (r_score = 3 AND f_score = 4 AND m_score = 2)
OR (r_score = 3 AND f_score = 4 AND m_score = 1)
OR (r_score = 2 AND f_score = 4 AND m_score = 3)
OR (r_score = 2 AND f_score = 4 AND m_score = 2)
OR (r_score = 2 AND f_score = 4 AND m_score = 1)
OR (r_score = 4 AND f_score = 4 AND m_score = 1) THEN 'Loyal Customers'
WHEN (r_score = 4 AND f_score = 3 AND m_score = 4)
OR (r_score = 3 AND f_score = 3 AND m_score = 4)
OR (r_score = 4 AND f_score = 2 AND m_score = 4)
OR (r_score = 4 AND f_score = 2 AND m_score = 3)
OR (r_score = 3 AND f_score = 2 AND m_score = 4)
OR (r_score = 4 AND f_score = 1 AND m_score = 4)
OR (r_score = 3 AND f_score = 1 AND m_score = 4)
OR (r_score = 3 AND f_score = 3 AND m_score = 3)
OR (r_score = 4 AND f_score = 3 AND m_score = 3)
OR (r_score = 3 AND f_score = 2 AND m_score = 3)
OR (r_score = 3 AND f_score = 1 AND m_score = 3) THEN 'Big Spenders'
WHEN (r_score = 4 AND f_score = 1 AND m_score = 1) THEN 'New Customers'
WHEN (r_score = 3 AND f_score = 1 AND m_score = 1)
OR (r_score = 4 AND f_score = 1 AND m_score = 2)
OR (r_score = 4 AND f_score = 2 AND m_score = 2)
OR (r_score = 4 AND f_score = 3 AND m_score = 2)
OR (r_score = 4 AND f_score = 1 AND m_score = 2)
OR (r_score = 3 AND f_score = 2 AND m_score = 2)
OR (r_score = 4 AND f_score = 3 AND m_score = 1)
OR (r_score = 4 AND f_score = 3 AND m_score = 1)
OR (r_score = 3 AND f_score = 3 AND m_score = 2)
OR (r_score = 3 AND f_score = 2 AND m_score = 1)
OR (r_score = 4 AND f_score = 2 AND m_score = 1)
OR (r_score = 4 AND f_score = 1 AND m_score = 3) THEN 'Potencial'
WHEN (r_score = 1 AND f_score = 4 AND m_score = 4)
OR (r_score = 2 AND f_score = 4 AND m_score = 4)
OR (r_score = 1 AND f_score = 1 AND m_score = 3)
OR (r_score = 1 AND f_score = 2 AND m_score = 3)
OR (r_score = 1 AND f_score = 3 AND m_score = 3)
OR (r_score = 1 AND f_score = 3 AND m_score = 2)
OR (r_score = 2 AND f_score = 3 AND m_score = 3)
OR (r_score = 2 AND f_score = 1 AND m_score = 3)
OR (r_score = 1 AND f_score = 4 AND m_score = 3)
OR (r_score = 1 AND f_score = 4 AND m_score = 2)
OR (r_score = 1 AND f_score = 4 AND m_score = 1)
OR (r_score = 1 AND f_score = 3 AND m_score = 4)
OR (r_score = 1 AND f_score = 2 AND m_score = 4)
OR (r_score = 1 AND f_score = 1 AND m_score = 4)
OR (r_score = 2 AND f_score = 3 AND m_score = 4)
OR (r_score = 2 AND f_score = 2 AND m_score = 4)
OR (r_score = 2 AND f_score = 1 AND m_score = 4)
OR (r_score = 2 AND f_score = 3 AND m_score = 1) THEN 'Customers Needing Attention'
WHEN (r_score = 2 AND f_score = 2 AND m_score = 2)
OR (r_score = 2 AND f_score = 2 AND m_score = 3)
OR (r_score = 2 AND f_score = 3 AND m_score = 2) THEN 'About to Sleep'
WHEN (r_score = 2 AND f_score = 1 AND m_score = 2)
OR (r_score = 1 AND f_score = 1 AND m_score = 2)
OR (r_score = 2 AND f_score = 2 AND m_score = 1)
OR (r_score = 1 AND f_score = 2 AND m_score = 1)
OR (r_score = 2 AND f_score = 1 AND m_score = 1) THEN 'At Risk'
WHEN (r_score = 1 AND f_score = 2 AND m_score = 2)
OR (r_score = 1 AND f_score = 3 AND m_score = 1) THEN 'Hibernating'
WHEN (r_score = 1 AND f_score = 1 AND m_score = 1) THEN 'Lost Customers'
ELSE 'Others'
END rfm_segment
FROM scores_assigned
)

SELECT *
FROM rfm_segments
