WITH date_parts AS (
    SELECT 
        customer_name,
        order_id,
        order_value_EUR,
        substr(date, 1, instr(date,'/') - 1) AS month,
        substr(date, instr(date,'/') + 1) AS rest
    FROM sales_details
),
date_parts2 AS (
    SELECT
        customer_name,
        order_id,
        order_value_EUR,
        month,
        substr(rest, 1, instr(rest,'/') - 1) AS day,
        substr(rest, instr(rest,'/') + 1) AS year
    FROM date_parts
),
converted_dates AS (
    SELECT
        customer_name,
        order_id,
        order_value_EUR,
        date(year || '-' || substr('0' || month, -2) || '-' || substr('0' || day, -2)) AS order_date
    FROM date_parts2
),
rfm_base AS (
    SELECT
        customer_name,
        MAX(order_date) AS last_order_date,
        CAST(julianday((SELECT MAX(order_date) FROM converted_dates)) - julianday(MAX(order_date)) AS INTEGER) AS recency_days,
        COUNT(order_id) AS frequency,
        ROUND(SUM(order_value_EUR), 2) AS monetary
    FROM converted_dates
    GROUP BY customer_name
),
rfm_scored AS (
    SELECT
        customer_name,
        last_order_date,
        recency_days,
        frequency,
        monetary,
        NTILE(5) OVER (ORDER BY recency_days ASC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency DESC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary DESC) AS m_score
    FROM rfm_base
)
SELECT
    customer_name,
    last_order_date,
    recency_days,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    CASE
        WHEN r_score <= 2 AND f_score <= 2 THEN 'Champions'
        WHEN r_score <= 2 AND f_score > 2 THEN 'Recent but Low Frequency'
        WHEN r_score > 2 AND f_score <= 2 THEN 'Frequent but Fading'
        ELSE 'At Risk / Lost'
    END AS segment
FROM rfm_scored
ORDER BY monetary DESC;s