																									
	-- Calculating Frequency and Monetary from RFM dataset where show only customers data who had quantity and unitprice more than zero																								
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
        AND CustomerID IS NOT NULL																								
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
	( SELECT																								
	    *,																								
	    MAX(last_purchase_date) OVER () AS reference_date,																								
	FROM FM_table)																								
	),																								
																									
	-- Calculating quantiles for Recency, Frequency, Monetary																								
																									
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
	( SELECT *,																								
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
																									
	-- Defining RFM segments by their R,F,M scores and grouping them by segments																								
																									
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
	    WHEN (r_score = 4 AND f_score = 4 AND m_score = 4) THEN 'Top Customers' -- Our Top customers which spends the most, boughts recently and most offen																								
	    WHEN (r_score = 4 AND f_score = 4 AND m_score = 3)																								
            OR (r_score = 4 AND f_score = 4 AND m_score = 2)																								
            OR (r_score = 3 AND f_score = 4 AND m_score = 4)																								
            OR (r_score = 3 AND f_score = 4 AND m_score = 3)																								
            OR (r_score = 3 AND f_score = 4 AND m_score = 2)																								
            OR (r_score = 3 AND f_score = 4 AND m_score = 1)																								
            OR (r_score = 2 AND f_score = 4 AND m_score = 3)																								
            OR (r_score = 2 AND f_score = 4 AND m_score = 2)																								
            OR (r_score = 2 AND f_score = 4 AND m_score = 1)																								
            OR (r_score = 4 AND f_score = 4 AND m_score = 1) THEN 'Loyal Customers' -- buying the most often, but spends not much																								
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
            OR (r_score = 3 AND f_score = 1 AND m_score = 3) THEN 'Cant Lose Them' -- really potential customers, spends a lot and bought recently																								
	    WHEN (r_score = 4 AND f_score = 1 AND m_score = 1) THEN 'New Customers' -- our new customers who bouth recently																								
	    WHEN (r_score = 3 AND f_score = 1 AND m_score = 1)																								
            OR (r_score = 4 AND f_score = 1 AND m_score = 2)																								
            OR (r_score = 4 AND f_score = 2 AND m_score = 2)																								
            OR (r_score = 4 AND f_score = 3 AND m_score = 2)																								
            OR (r_score = 3 AND f_score = 1 AND m_score = 2)																								
            OR (r_score = 3 AND f_score = 2 AND m_score = 2)																								
            OR (r_score = 3 AND f_score = 3 AND m_score = 1)																								
            OR (r_score = 4 AND f_score = 3 AND m_score = 1)																								
            OR (r_score = 3 AND f_score = 3 AND m_score = 2)																								
            OR (r_score = 3 AND f_score = 2 AND m_score = 1)																								
            OR (r_score = 4 AND f_score = 2 AND m_score = 1)																								
            OR (r_score = 4 AND f_score = 1 AND m_score = 3) THEN 'Promising' -- don't spend a lot but bought recently and frequently																								
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
            OR (r_score = 2 AND f_score = 3 AND m_score = 1) THEN 'Customers Needing Attention' -- above average recency, frequency and motenetary customers, who bough very recent																								
	    WHEN (r_score = 2 AND f_score = 2 AND m_score = 2)																								
            OR (r_score = 2 AND f_score = 2 AND m_score = 3)																								
            OR (r_score = 2 AND f_score = 3 AND m_score = 2) THEN 'About to Sleep' -- below average customer, which we might loose if we do not pay more attention																								
	    WHEN (r_score = 2 AND f_score = 1 AND m_score = 2)																								
            OR (r_score = 1 AND f_score = 1 AND m_score = 2)																								
            OR (r_score = 2 AND f_score = 2 AND m_score = 1)																								
            OR (r_score = 1 AND f_score = 2 AND m_score = 1)																								
            OR (r_score = 2 AND f_score = 1 AND m_score = 1) THEN 'At Risk' -- purchase long time ago and spend lot of money																								
	    WHEN (r_score = 1 AND f_score = 2 AND m_score = 2)																								
	        OR (r_score = 1 AND f_score = 3 AND m_score = 1) THEN 'Hibernating' -- Last purchase was long ago																								
	    WHEN (r_score = 1 AND f_score = 1 AND m_score = 1) THEN 'Lost Customers' -- Customers with lowest scores.																								
	    ELSE 'Others'																								
	END rfm_segment																								
	FROM scores_assigned																								
	)																								
																									
	SELECT *																								
	FROM rfm_segments																								
