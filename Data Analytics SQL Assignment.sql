-- Databricks notebook source
-- DBTITLE 1,TASK 1
-- Task 1 - Channel performance 
SELECT so.channel,
     ROUND(SUM(CASE WHEN so.order_date <= '2024-6-30' THEN sl.line_revenue ELSE 0 END), 2) AS FY2024,
ROUND((SUM(CASE WHEN so.order_date > '2024-6-30' THEN sl.line_revenue ELSE 0 END) - SUM(CASE WHEN so.order_date <= '2024-6-30' THEN sl.line_revenue ELSE 0 END)) / NULLIF(SUM(CASE WHEN so.order_date <= '2024-6-30' THEN sl.line_revenue ELSE 0 END), 0)  * 100.0, 2) AS Growth_Rate,
     ROUND(SUM(CASE WHEN so.order_date > '2024-6-30' THEN sl.line_revenue ELSE 0 END),2) AS FY2025       
FROM sizwe_sales_orders AS so
JOIN sizwe_sales_lines AS sl 
ON so.order_id = sl.order_id
GROUP BY so.channel

-- COMMAND ----------

-- DBTITLE 1,TASK 2
--Task 2 - Where the profit actually comes from

SELECT p.product_line,ROUND(SUM(sl.line_revenue), 2) AS revenue, ROUND(SUM(sl.cogs), 2) AS cost_of_goods_sold,
    ROUND(SUM(sl.line_revenue - sl.cogs), 2) AS gross_profit,
    ROUND((SUM(sl.line_revenue - sl.cogs) / NULLIF(SUM(sl.line_revenue), 0)) * 100, 2) AS gross_margin
FROM sizwe_products AS p
JOIN sizwe_sales_lines AS sl
ON p.sku = sl.sku
GROUP BY p.product_line
ORDER BY gross_profit DESC

--Based on result from the query, House Blend is the most profitable product sizwe coffee has although its gross margin is not the highest.

-- COMMAND ----------

-- DBTITLE 1,TASK 3
--Task 3 - The collections problem
WITH collection_prob AS(
    
    SELECT c.channel, COUNT(*) AS total_invoices, 
    SUM(CASE WHEN ar.amount_settled > 0 OR ar.settlement_date IS NOT NULL THEN 1 ELSE 0 END) AS Invoices_settled,
    COUNT(*) -  SUM(CASE
                        WHEN ar.amount_settled > 0 OR ar.settlement_date IS NOT NULL THEN 1 
                        ELSE 0 END) AS still_open,
    ROUND(AVG(CASE
                  WHEN ar.amount_settled > 0 OR ar.settlement_date IS NOT NULL THEN ((EXTRACT(DAY FROM settlement_date) - (EXTRACT(DAY FROM invoice_date)))) END), 2) AS average_days,
    ROUND(SUM(ar.invoice_amount - ar.amount_settled),2) AS aamount_outstanding
FROM sizwe_customers AS c
JOIN sizwe_ar_ledger AS ar
ON c.customer_id = ar.customer_id
GROUP BY c.channel)

SELECT * FROM collection_prob

-- there is more open invoices for the wholesale channel than Subscription hence this needs to be the first channel to invastigate and figure out why most of the invoices remain unpayed.

-- COMMAND ----------

-- DBTITLE 1,TASK 4
--Task 4 - The ten accounts that matter most 

WITH important_accounts AS (
        
        SELECT c.customer_id, c.trading_name, c.segment, c.province, c.rep_id,
        ROUND(SUM(CASE WHEN so.order_date > '2024-6-30' THEN sl.line_revenue END),2) AS revenue
    FROM sizwe_customers AS c
    LEFT JOIN sizwe_sales_orders AS so
    ON c.customer_id = so.customer_id 
    LEFT JOIN sizwe_sales_lines AS sl
    ON so.order_id = sl.order_id  
    GROUP BY c.customer_id, c.trading_name, c.segment, c.province, c.rep_id, sl.line_revenue)

SELECT * 
FROM important_accounts
ORDER BY revenue DESC
LIMIT 10

-- COMMAND ----------

-- DBTITLE 1,TASK 5
--Task 5 - A commercial gap

SELECT c.customer_id, c.channel, c.segment, c.province,
         ROUND(SUM(sl.line_revenue), 2) AS revenue
FROM sizwe_customers AS c
JOIN sizwe_sales_orders AS so ON c.customer_id = so.customer_id
JOIN sizwe_sales_lines AS sl ON so.order_id = sl.order_id
LEFT JOIN sizwe_trade_promotions as tp ON c.customer_id = tp.customer_id
WHERE c.channel = 'Wholesale' AND tp.promo_id IS NULL
GROUP BY c.customer_id, c.channel, c.segment, c.province
ORDER BY revenue DESC
LIMIT 15

--With the top three being the highest revenue, provisions should be made for them to get trade promotions

-- COMMAND ----------

-- DBTITLE 1,TASK 6
--Task 6 - Are the sales representatives hitting target? 

WITH rep_revenue AS (
    SELECT r.rep_id, r.territory, r.target_monthly, DATE_TRUNC('month', so.order_date) AS month,
           SUM(CASE WHEN so.order_date > '2024-6-30' THEN sl.line_revenue END) AS monthly_revenue
    FROM sizwe_reps AS r
    LEFT JOIN sizwe_sales_orders AS so ON r.rep_id = so.rep_id
    JOIN sizwe_sales_lines AS sl ON so.order_id = sl.order_id
    GROUP BY r.rep_id, r.territory, r.target_monthly, month
)
SELECT rep_id, territory, target_monthly,
      ROUND(AVG(monthly_revenue), 2) AS FY2025_average,
      ROUND(AVG(100 * (monthly_revenue / NULLIF(target_monthly, 0))), 2) AS target_perc
FROM rep_revenue
GROUP BY rep_id, territory, target_monthly
ORDER BY target_perc DESC

-- COMMAND ----------

-- DBTITLE 1,TASK 7
--Task 7 - The shape of the year 

WITH monthly_revenue AS (
    SELECT DATE_TRUNC('month', so.order_date) AS month, ROUND(SUM(sl.line_revenue), 2) AS revenue
    FROM sizwe_sales_orders AS so
    JOIN sizwe_sales_lines AS sl ON so.order_id = sl.order_id
    GROUP BY month
)
SELECT month, revenue,
       LAG(revenue) OVER (ORDER BY month) AS previous_month,
       ROUND(revenue - LAG(revenue) OVER (ORDER BY month), 2) AS change,
       ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY month)) / NULLIF(LAG(revenue) OVER (ORDER BY month), 0), 1) AS percent_change,
       ROUND(AVG(revenue) OVER (ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ), 2) AS rolling_3_month_avg
FROM monthly_revenue

--From the results of this query, from August to December of every financial year there is a drop in the monthly revenue making these months the quietest months especially December with the highest percengtage change.

-- COMMAND ----------

-- DBTITLE 1,TASK 8
--Task 8 - Why has the margin moved? 

SELECT p.product_line, ROUND(SUM(sl.line_revenue), 2) AS revenue,
      ROUND((SUM(sl.line_revenue - sl.cogs)), 2) AS gross_margin,
    ROUND(((SUM(sl.line_revenue - sl.cogs)) / NULLIF(SUM(sl.line_revenue), 0)) * 100, 2) AS share_percent
FROM sizwe_products AS p
JOIN sizwe_sales_lines AS sl
ON p.sku = sl.sku
GROUP BY p.product_line