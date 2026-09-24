-- Q1: Total sales and profit by country
SELECT country, SUM(sales) AS total_sales, SUM(profit) AS total_profit
FROM financials
GROUP BY country
ORDER BY total_sales DESC

-- Q2: Total profit by product
SELECT product, SUM(profit) AS total_profit
FROM financials
GROUP BY product
ORDER BY total_profit DESC

-- Q3: Total sales by segment
SELECT segment, SUM(sales) AS total_sales
FROM financials
GROUP BY segment

-- Q4: Month-over-month sales growth (CTE + LAG)
-- Business question: How volatile is our month-to-month sales performance?
WITH monthly AS (
    SELECT strftime('%Y-%m', date) AS month,
           SUM(sales)  AS total_sales,
           SUM(profit) AS total_profit
    FROM financials
    GROUP BY 1
),
with_prev AS (
    SELECT month, total_sales, total_profit,
           LAG(total_sales) OVER (ORDER BY month) AS prev_sales
    FROM monthly
)
SELECT month, total_sales, prev_sales,
       ROUND(100.0 * (total_sales - prev_sales) / prev_sales, 2) AS mom_growth_pct
FROM with_prev
ORDER BY month;


-- Q5: Top 3 products by profit per segment (RANK)
-- Business question: Which products drive profit in each customer segment?
WITH product_profit AS (
    SELECT segment, product, SUM(profit) AS total_profit
    FROM financials
    GROUP BY segment, product
),
ranked AS (
    SELECT segment, product, total_profit,
           RANK() OVER (PARTITION BY segment ORDER BY total_profit DESC) AS rnk
    FROM product_profit
)
SELECT segment, rnk, product, ROUND(total_profit, 0) AS total_profit
FROM ranked
WHERE rnk <= 3
ORDER BY segment, rnk;


-- Q6: 3-month moving average of sales
-- Business question: What's the underlying sales trend once we smooth out monthly noise?
WITH monthly AS (
    SELECT strftime('%Y-%m', date) AS month, SUM(sales) AS total_sales
    FROM financials
    GROUP BY 1
)
SELECT month, total_sales,
       ROUND(AVG(total_sales) OVER (
           ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
       ), 0) AS moving_avg_3m,
       COUNT(*) OVER (
           ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
       ) AS months_in_window
FROM monthly
ORDER BY month;

