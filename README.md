# retail-sql-analysis

#### Project Artifacts (Start Here)
- SQL Answers (Q1–Q15): [docs/sql_answers.md](docs/sql_answers.md)
- ERD (PDF): [docs/erd.pdf](docs/erd.pdf)
- Data Dictionary (PDF): [docs/data_dictionary.pdf](docs/data_dictionary.pdf)
- SQL Script: [sql/retail_analysis.sql](sql/retail_analysis.sql)

#### Project Background
This project analyzes **B2B  retail paper sales** using a relational dataset that connects **accounts, orders, sales reps, regions, and web events**. The organization has accumulated several years of transaction and digital activity data, and this analysis converts that raw data into actionable insights for cross-functional partners including **Sales Leadership**, **Sales Operations (RevOps)**, **Marketing Analytics**, and **Finance (FP&A)**.

The work focuses on understanding:
- **Revenue and product mix** by paper type (Standard, Gloss, Poster)
- **Top account performance** using average order value as a benchmark metric
- **Digital channel activity** (web events) and its relationship to sales activity
- **Time-series trends** using running totals and moving averages to support pacing and seasonality checks

- **Artifacts**
- **ERD:** [docs/erd.pdf](docs/erd.pdf)
- **Data Dictionary:** [docs/data_dictionary.pdf](docs/data_dictionary.pdf)
- **SQL Answers (Q1–Q15):** [docs/sql_answers.md](docs/sql_answers.md)
- **SQL Script:** [sql/retail_analysis.sql](sql/retail_analysis.sql)

---

#### Data Structure & Initial Checks
The database consists of five tables: **accounts, orders, region, sales_reps, web_events**
**Table sizes (row counts)**
| Table | Rows |
|---|---:|
| accounts | **351** |
| orders | **6,912** |
| region | **4** |
| sales_reps | **50** |
| web_events | **9,073** |

**Order date coverage**
- **First order:** 2013-12-04  
- **Last order:** 2017-01-02

**How tables connect (business view)**
- **Region → Sales Reps → Accounts → Orders**
- **Accounts → Web Events**

(See ERD and Data Dictionary linked above.)

---

#### Background & Overview (Data Analyst POV)
This analysis uses SQL to answer operational and strategic questions commonly owned by a Business Analyst team: “Where is revenue coming from?”, “Which accounts are highest value?”, “Which regions are outperforming?”, and “What does demand look like over time?”.

We use SQL capabilities expected in entry-level analytics roles—**JOINs, aggregations, CTEs, subqueries, and window functions**—to produce metrics that can be consumed by stakeholders in Sales, Marketing, and Finance.

---

#### Executive Summary
Across **6,912 orders (2013–2017)**, **Standard paper** is the top revenue driver at **$9.67M**, ahead of **Gloss ($7.59M)** and **Poster ($5.88M)**, making product mix the largest lever for revenue planning. The **Northeast** generates the highest total sales at **$7.74M**, while **West** and **Midwest** are **above the company average order value** (**$3,626** and **$3,360** vs **$3,348**), implying different regional growth levers. **Direct** is the most common web channel by activity (**5,298 events**) and shows the strongest association with sales volume in account-level joins, but marketing attribution requires additional rules before budget decisions.

Detailed queries and outputs are available in **[SQL Answers](docs/sql_answers.md)** and **[SQL Script](sql/retail_analysis.sql)**.

---

#### Insights Deep Dive

##### Insight 1 — Standard leads product revenue and volume (core revenue driver)
- **Business metric(s):** product revenue (`standard_amt_usd`, `gloss_amt_usd`, `poster_amt_usd`), product units (`standard_qty`, `gloss_qty`, `poster_qty`)
- **Quantified value:**
  - **Revenue:** Standard **$9,672,346.54** | Gloss **$7,593,159.77** | Poster **$5,876,005.52**
  - **Units:** Standard **1,938,346** | Gloss **1,013,773** | Poster **723,646**
- **Historical trend story:** Over the full period (**2013–2017**), Standard remains the leading contributor across both units and revenue, indicating stable demand and making it the best candidate for forecasting and product-led planning.
- **Who uses this:** **Finance (FP&A)** for planning, **Sales Ops** for product strategy and bundles, **Operations** for supply planning.

##### Insight 2 — Northeast wins total revenue; West/Midwest win on average order value
- **Business metric(s):** total revenue (`SUM(total_amt_usd)`), **AOV proxy** (`AVG(total_amt_usd)`)
- **Quantified value:**
  - **Top region by total sales:** **Northeast = $7,744,405.36**
  - **Company avg order value:** **$3,348.02**
  - **Above-average regions:** **West = $3,626.15**, **Midwest = $3,359.52**
- **Historical trend story:** The Northeast appears to win through **volume/frequency** (highest total), while West/Midwest skew higher on **basket size**, suggesting different playbooks (retention/reorder vs upsell).
- **Who uses this:** **Regional Sales**, **RevOps**, **Finance** (targets and pacing).

##### Insight 3 — Direct dominates web activity, but attribution needs a defined model
- **Business metric(s):** web events by `channel` (activity proxy)
- **Quantified value:**
  - **Top channel by event volume:** **Direct = 5,298 events**
  - Account-level joins show Direct associated with the highest summed sales volume output.
- **Historical trend story:** Direct traffic is consistently high across the period, which may reflect repeat customers rather than acquisition; attribution logic should be defined before reallocating marketing spend.
- **Who uses this:** **Marketing Analyst** (channel measurement), **Finance** (ROI governance), **Sales Ops** (lead-source alignment).

##### Insight 4 — Time-series views support pacing and seasonality checks
- **Business metric(s):** monthly revenue + running total; daily orders + **7-day moving average**
- **Quantified value (examples from outputs):**
  - Monthly revenue varies meaningfully month-to-month (e.g., **Oct 2014 = $495,333.59** in the early sample).
  - Smoothed daily demand (7-day MA) stabilizes around **~3–5 orders/day** in early records.
- **Historical trend story:** Running totals enable executive pacing, while moving averages reduce noise and support early detection of demand shifts.
- **Who uses this:** **Business Ops**, **Finance**, **Sales Leadership**.

#### Recommendations
1) **Product strategy:** Protect Standard as the core revenue engine while partnering with **Sales Ops + Finance** to test cross-sell bundles and pricing thresholds.
2) **Regional execution:** Align playbooks to regional dynamics—**Northeast** focus on reorder cadence/retention; **West/Midwest** prioritize upsell and expansion.
3) **Marketing measurement:** Define channel attribution rules (e.g., time-window matching or last-touch by session) before making channel investment decisions.
4) **Operational reporting:** Publish a recurring KPI pack (monthly revenue pacing + weekly demand trend) for Sales and Finance stakeholders.

---

#### Caveats & Assumptions
- **Attribution caution:** Web events connect to orders through `account_id`. Without session/order-level attribution, channel-to-sales joins can inflate totals for high-activity accounts.
- **Profitability definition:** “Most profitable” is based on **revenue**, not margin (no COGS/discount fields available).
- **Time gaps:** Days with zero orders may not exist as rows; moving averages can be improved by generating a full calendar date spine.
- **Data quality:** Outlier and null validation is not fully production-hardened; additional checks are recommended for operational use.
