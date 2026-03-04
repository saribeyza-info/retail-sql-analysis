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

A:
Table_name	Row_count
accounts	351
orders	6912
region	4
sales_reps	50
web_events  	9073



Q2: What is the date range of orders?

I used MIN and MAX on the date column to find the order date range.

SELECT
       MIN (occurred_at)  AS first_order, 
       MAX(occurred_at) AS last_order
FROM orders;

Orders range from 2013-12-04 to 2017-01-02.
      
Q3: How many of each type of paper has been sold?

I summed each paper type column to see total quantities sold.

SELECT  
      SUM(standard_qty) AS sum_standard,
      SUM(gloss_qty) AS sum_gloss,
      SUM(poster_qty) AS sum_poster
 FROM  orders;

A:
sum_standard	sum_gloss	sum_poster
1938346	1013773	723646


Q4: How much, in dollars, have each of the paper types sold?

I summed the USD amount for each paper type to find total revenue.

SELECT  
      SUM(standard_amt_usd) AS standard_total_usd,
      SUM(gloss_amt_usd) AS gloss_total_usd,
      SUM(poster_amt_usd) AS poster_total_usd
 FROM  orders;

A:
standard_total_usd	gloss_total_usd	poster_total_usd
9672346.54	7593159.77	5876005.52


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

A:
account_name	account_id	avg_total
Pacific Life	4251	19639.94
Fidelity National Financial	4101	13753.41
Kohl's	2441	12872.17
State Farm Insurance Cos.	1341	12423.39
AmerisourceBergen	1111	9685.45


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
A:
channel	Count_events
direct	5298


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

A:
region_id	count_sales_reps
	1		21







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


A:

channel	sum_total
direct	102408010



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

A:
name	sum_total_usd
Northeast	7744405.36


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


A:
region_name	region_avg_usd	company_avg	comparison
West	3626.15	3348.02	Above Average
Midwest	3359.52	3348.02	Above Average
Northeast	3285.70	3348.02	Below Average
Southeast	3190.96	3348.02	Below Average


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


A:
top_region_name	total_standard	total_gloss	total_poster
Northeast	646871	351679	231828


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

A:
region_name	sales_rep_name	account_name	avg_sales_usd
Northeast	Sibyl Lauria	Nike	390.25
Northeast	Elna Condello	Massachusetts Mutual Life Insurance	654.51
Southeast	Calvin Ollison	J.C. Penney	813.26
Northeast	Eugena Esser	Delta Air Lines	859.64
West	Arica Stoltzfus	Level 3 Communications	881.73
Northeast	Elba Felder	Deere	1036.57
Southeast	Babette Soukup	NextEra Energy	1064.25
Southeast	Calvin Ollison	Bed Bath & Beyond	1069.64
Southeast	Maren Musto	Las Vegas Sands	1113.29
West	Georgianna Chisholm	SpartanNash	1125.32
Northeast	Michel Averette	Tyson Foods	1128.99
Southeast	Dorotha Seawell	PBF Energy	1142.87
West	Elwood Shutt	Veritiv	1147.08
Southeast	Calvin Ollison	Computer Sciences	1167.17
Midwest	Julie Starr	Lear	1185.92
West	Marquetta Laycock	Sherwin-Williams	1186.48
Northeast	Renetta Carew	Microsoft	1188.77
Northeast	Elba Felder	Exelon	1198.19
Northeast	Necole Victory	AT&T	1201.11
West	Soraya Fulton	WestRock	1207.49



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



A:
month	total_by_month	running_total
2013-12-01	377331.00	377331.00
2014-01-01	286140.27	663471.27
2014-02-01	349721.34	1013192.61
2014-03-01	341512.32	1354704.93
2014-04-01	344893.99	1699598.92
2014-05-01	319210.40	2018809.32
2014-06-01	297655.65	2316464.97
2014-07-01	289128.19	2605593.16
2014-08-01	366685.41	2972278.57
2014-09-01	299968.38	3272246.95
2014-10-01	495333.59	3767580.54
2014-11-01	311893.88	4079474.42
2014-12-01	366963.12	4446437.54
2015-01-01	347804.30	4794241.84
2015-02-01	333688.01	5127929.85
2015-03-01	519403.40	5647333.25
2015-04-01	451753.57	6099086.82
2015-05-01	390830.84	6489917.66
2015-06-01	420906.13	6910823.79
2015-07-01	461895.49	7372719.28


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
A:
order_date	orders_count	moving_avg_7d
2013-12-04	3	3.00
2013-12-05	2	2.50
2013-12-06	7	4.00
2013-12-08	8	5.00
2013-12-09	3	4.60
2013-12-10	4	4.50
2013-12-11	6	4.71
2013-12-12	6	5.14
2013-12-13	2	5.14
2013-12-14	5	4.86
2013-12-15	1	3.86
2013-12-16	3	3.86
2013-12-17	4	3.86
2013-12-18	3	3.43
2013-12-19	4	3.14
2013-12-21	3	3.29
2013-12-22	6	3.43
2013-12-23	2	3.57
2013-12-24	2	3.43
2013-12-25	3	3.29

