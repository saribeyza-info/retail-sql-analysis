Beyza Sarı– Udacity Retail Analysis Project
	
Retail SQL Analysis – Answers & SQL Code
	
EDA (Q1–Q8)

Q1. How many rows are in each table?

I counted the rows in each table to understand the dataset size.

SELECT  COUNT(*) FROM   accounts;
SELECT  COUNT(*) FROM   orders;
SELECT  COUNT(*) FROM   region;
SELECT  COUNT(*) FROM   sales_reps;
SELECT  COUNT(*) FROM   web_events;

Q2: What is the date range of orders?

I used MIN and MAX on the date column to find the order date range.

SELECT
       MIN (occurred_at)  AS first_order, 
       MAX(occurred_at) AS last_order
FROM orders;

      
Q3: How many of each type of paper has been sold?

I summed each paper type column to see total quantities sold.

SELECT  
      SUM(standard_qty) AS sum_standard,
      SUM(gloss_qty) AS sum_gloss,
      SUM(poster_qty) AS sum_poster
 FROM  orders;


Q4: How much, in dollars, have each of the paper types sold?

I summed the USD amount for each paper type to find total revenue.

SELECT  
      SUM(standard_amt_usd) AS standard_total_usd,
      SUM(gloss_amt_usd) AS gloss_total_usd,
      SUM(poster_amt_usd) AS poster_total_usd
 FROM  orders;


Q5: What is the most profitable paper type?

Standard paper is the most profitable option by total revenue, because it has the highest total USD sales.


Q6: What are the top five accounts by average total amount?

I grouped by account and used AVG to find top accounts by average sales, also used Round for easy reading.

SELECT  a.name AS account_name,
       o.account_id,
       ROUND(AVG(o.total_amt_usd),2) AS avg_total
FROM orders o
JOIN accounts a
ON o.account_id=a.id
GROUP BY 
o.account_id,a.name
ORDER BY 
AVG(total_amt_usd) DESC
LIMIT 5;


Q7: What channel do most of the online sales come from?

I treated web_events table as online activity. I counted web events by grouping them in order to find highest activity. 

SELECT channel,
       COUNT(*) AS count_events
FROM web_events
GROUP BY 
channel
ORDER BY 
COUNT(*) DESC
LIMIT 1;


Q8: Which region_id has the largest number of sales persons?

By grouping the regions, I found out how many sales representatives were assigned to each region. So we can see how the team is spread out.
I found the top region by sorting it from largest to smallest using order by.

SELECT region_id,
       COUNT(*) AS count_sales_reps
FROM sales_reps 
GROUP BY 
region_id
ORDER BY  
count_sales_reps DESC
LIMIT 1;


Joins

Q9: Which web events channel had the highest total quantity sold of all three types of paper?

I joined web_events to orders through accounts to see which channel drives the most sales.

SELECT w.channel,
       SUM(o.total) AS sum_total
FROM web_events w
JOIN accounts a
ON a.id =w.account_id
JOIN orders o
ON o.account_id =a.id
GROUP BY 
1
ORDER BY 
2 DESC
LIMIT 1;


Q10: Which region, by  name, has the highest amount of sales in USD?


I joined  orders, sales_reps, accounts and region to calculate total sales for each region by name. .then used order by to sort descending.


SELECT r.name,
      SUM(o.total_amt_usd) AS sum_total_usd
FROM region r
JOIN sales_reps s
      ON r.id= s.region_id
JOIN accounts a
      ON s.id =a.sales_rep_id
JOIN orders o
      ON o.account_id=a.id
GROUP BY 
r.name
ORDER BY 
sum_total_usd DESC
LIMIT 1;


CTEs, Sub queries, and temp tables

Q11: Categorize each region’s average sales as “Above Average” or “Below Average” based on the average for the company as a whole.

This solution uses two CTEs: 
1: region_avg computes the average order value per region
2: while overall_avg computes the company-wide average as a single value. 
In the final SELECT, since overall_avg returns one row, we attach it to every region row using ON 1=1. 

Then a CASE WHEN compares the region average to the company average and labels it Above Average if greater than or equal, otherwise Below Average.

WITH region_avg AS (
    SELECT
        r.name AS region_name,
        ROUND(AVG(o.total_amt_usd), 2) AS region_avg_usd
    FROM region r
    JOIN sales_reps s
      ON r.id = s.region_id
    JOIN accounts a
      ON s.id = a.sales_rep_id
    JOIN orders o
      ON o.account_id = a.id
    GROUP BY 
r.name
),
overall_avg AS (
    SELECT
        ROUND(AVG(total_amt_usd), 2) AS company_avg
    FROM orders
)
SELECT
    ra.region_name,
    ra.region_avg_usd,
    oa.company_avg,
    CASE
        WHEN ra.region_avg_usd >= oa.company_avg THEN 'Above Average'
        ELSE 'Below Average'
    	   END AS comparison
FROM region_avg ra
JOIN overall_avg oa
  ON 1 = 1
ORDER BY 
ra.region_avg_usd DESC;



Q12: What are the total quantities of each paper type sold for the top region?

I first use a top_region CTE to select the top-performing region as a single row.

Then I link that region back to orders via sales_reps.region_id.

Next calculate SUM(standard_qty), SUM(gloss_qty), and SUM(poster_qty) to get total quantities for each paper type in that top region.

WITH top_region AS (
    SELECT 
        r.id AS top_region_id,
        r.name as top_region_name,
        SUM(total_amt_usd) AS total_usd
    FROM region r
    JOIN sales_reps s
      ON r.id = s.region_id
    JOIN accounts a
      ON s.id = a.sales_rep_id
    JOIN orders o
      ON o.account_id = a.id
    GROUP BY
 top_region_name, top_region_id
    ORDER BY 
total_usd DESC
    LIMIT 1
  )
 SELECT 
        tr.top_region_name,
        SUM(o.standard_qty) AS total_standard,
        SUM(o.gloss_qty) AS total_gloss,
        SUM(o.poster_qty) AS total_poster     
FROM top_region tr
JOIN sales_reps s 
    ON s.region_id = tr.top_region_id
JOIN accounts a  
    ON a.sales_rep_id = s.id
JOIN orders o     
    ON o.account_id = a.id
GROUP BY  
    tr.top_region_name;


Windowing Functions 

Q13: What are the average sales in USD by region and sales person? Include region name, sales person’s name, and account name. Include first 20 rows

I joined region, sales rep, and account data and calculated the average order value in USD per account.
This lets me compare which accounts perform better on average within each region and sales rep.

SELECT DISTINCT
    r.name AS region_name,
    sr.name AS sales_rep_name,
    a.name AS account_name,
    ROUND(
AVG(o.total_amt_usd) 
    		OVER (PARTITION BY r.name, sr.name,a.name),2) 
AS avg_sales_usd
FROM region r
JOIN sales_reps sr 
    ON r.id = sr.region_id
JOIN accounts a 
    ON sr.id = a.sales_rep_id
JOIN orders o 
ON a.id = o.account_id
ORDER BY 
    avg_sales_usd
LIMIT 20;


Q14: What is the running total of sales by month? Return the first twenty rows.

In this question, With using CTE, firstly I found total us sales by month. in order to do that I grouped months. 

Secondly, with the window function I found running total.


WITH monthly_total AS (
  SELECT
    TO_CHAR(DATE_TRUNC('month', occurred_at), 'YYYY-MM-01') AS month,
    SUM(total_amt_usd) AS total_by_month
  FROM orders
  GROUP BY 1
)
SELECT
  month,
  total_by_month,
  SUM(total_by_month) OVER (ORDER BY month) AS running_total
FROM monthly_total
ORDER BY month
LIMIT 20;


Q15: Create a seven-day moving average of orders (hint: CTE, temp table, or subquery).

I interpreted 'orders' as order count.
First, I created a CTE to count orders per day using DATE_TRUNC and COUNT.
Then, I used a window function to find moving average which is average each day with the previous 6 days.
This smooths out daily fluctuations and helps identify order trends over time.

WITH daily_orders AS (
  SELECT
    TO_CHAR(CAST(occurred_at AS date), 'YYYY-MM-DD') AS order_date,
    COUNT(*) AS orders_count
  FROM orders
  GROUP BY 1
)
SELECT
  order_date,
  orders_count,
  ROUND(
    AVG(orders_count) OVER (
      ORDER BY order_date
      ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ),
    2
  ) AS moving_avg_7d
FROM daily_orders
ORDER BY order_date
LIMIT 20;

