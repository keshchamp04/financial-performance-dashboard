--Total sales and profit by country--
SELECT country, SUM(sales) AS total_sales, SUM(profit) AS total_profit
FROM financials
GROUP BY country
ORDER BY total_sales DESC

--total profit by product--
SELECT product, SUM(profit) AS total_profit
FROM financials
GROUP BY product
ORDER BY total_profit DESC

--total sales by segment--
SELECT segment, SUM(sales) AS total_sales
FROM financials
GROUP BY segment


