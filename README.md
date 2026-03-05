# Retail SQL Analysis — B2B Paper Sales (Portfolio)

#### Project Artifacts (Start Here)
- SQL Answers (Q1–Q15): [docs/sql_answers.md](docs/sql_answers.md)
- ERD (PDF): [docs/erd.pdf](docs/erd.pdf)
- Data Dictionary (PDF): [docs/data_dictionary.pdf](docs/data_dictionary.pdf)
- SQL Script: [sql/retail_analysis.sql](sql/retail_analysis.sql)

---

#### 1) Background & Overview (Data Analyst POV)
This analysis translates raw retail transactions and digital activity into decision-ready metrics used by **Sales Leadership**, **Sales Operations**, **Marketing Analytics**, and **Finance**. The work answers practical Business Analyst questions: **where revenue is coming from**, **which customers are highest value**, **which regions outperform**, and **how demand behaves over time**.

The solution demonstrates core analytics SQL techniques—**JOINs**, **aggregations**, **CTEs/subqueries**, and **window functions**—to produce repeatable KPI outputs that support planning and performance reviews.

---

#### 2) Data Structure Overview (Business View)

![ERD](docs/Erd.png)

**Database entities (scope)**
| Table | Rows | What it represents |
|---|---:|---|
| accounts | 351 | Customer accounts, assigned to a sales rep |
| orders | 6,912 | Transactions (units + USD amounts by product type) |
| sales_reps | 50 | Sales reps, assigned to a region |
| region | 4 | Region lookup (e.g., Northeast, West) |
| web_events | 9,073 | Account-level web interactions by channel |

**Date coverage (orders)**
- **First order:** 2013-12-04  
- **Last order:** 2017-01-02  

**How the tables connect (high level)**
- **Region → Sales Reps → Accounts → Orders**
- **Accounts → Web Events**

(See: [ERD](docs/erd.pdf) and [Data Dictionary](docs/data_dictionary.pdf).)

---

#### 3) Executive Summary
Across **6,912 orders (2013–2017)**, **Standard** paper is the largest revenue driver at **$9.67M**, ahead of **Gloss ($7.59M)** and **Poster ($5.88M)**—making product mix the primary lever for revenue planning. The **Northeast** generates the highest total sales (**$7.74M**), while **West** and **Midwest** post **above-average order values** (**$3,626** and **$3,360** vs. company average **$3,348**), suggesting different regional growth playbooks. **Direct** is the largest web channel by activity (**5,298 events**) and shows the strongest association with sales volume in account-level joins; however, attribution is not order-level and should not be used alone for budget decisions.

Full technical details and reproducible outputs are available in [SQL Answers](docs/sql_answers.md) and the [SQL Script](sql/retail_analysis.sql).

---

#### 4) Insights Deep Dive
<details>
  <summary><b>Insights Deep Dive (click to expand)</b></summary>

  <!-- **Business metric(s):** Product revenue (USD) and units sold by paper type  
- **Qualified value:**  
  - **Revenue:** Standard **$9,672,346.54** | Gloss **$7,593,159.77** | Poster **$5,876,005.52**  
  - **Units:** Standard **1,938,346** | Gloss **1,013,773** | Poster **723,646**
- **Simple trend story (2013–2017):** Standard remains the leading contributor across both units and revenue over the observed period, indicating stable demand and making it the best candidate for forecasting and product-led planning.
- **Who uses this:** **Finance** (planning/forecasting), **Sales Ops** (product strategy & bundles), **Operations/Supply** (capacity and inventory planning). -->
  
</details>

##### Insight 1 — Standard is the core revenue engine (revenue + volume leader)
- **Business metric(s):** Product revenue (USD) and units sold by paper type  
- **Qualified value:**  
  - **Revenue:** Standard **$9,672,346.54** | Gloss **$7,593,159.77** | Poster **$5,876,005.52**  
  - **Units:** Standard **1,938,346** | Gloss **1,013,773** | Poster **723,646**
- **Simple trend story (2013–2017):** Standard remains the leading contributor across both units and revenue over the observed period, indicating stable demand and making it the best candidate for forecasting and product-led planning.
- **Who uses this:** **Finance** (planning/forecasting), **Sales Ops** (product strategy & bundles), **Operations/Supply** (capacity and inventory planning).

##### Insight 2 — Northeast leads total revenue; West/Midwest lead on average order value (AOV)
- **Business metric(s):** Total revenue by region; **AOV proxy** = average order value (USD)  
- **Qualified value:**  
  - **Top region by total sales:** Northeast = **$7,744,405.36**  
  - **Company AOV:** **$3,348.02**  
  - **Above-average AOV regions:** West = **$3,626.15**, Midwest = **$3,359.52**
- **Simple trend story:** Regional performance splits into **volume vs. basket size**—Northeast appears to win through higher frequency/volume, while West/Midwest skew higher on order value, implying different target-setting and pipeline strategies.
- **Who uses this:** **Regional Sales leadership**, **Sales Ops** (coverage model & targets), **Finance** (pacing and goal-setting).

##### Insight 3 — High-value accounts stand out by average order value (AOV benchmark)
- **Business metric(s):** Average order value (AOV proxy) by account = `AVG(total_amt_usd)`  
- **Qualified value (Top 5 by AOV):**
  - **Pacific Life:** **$19,639.94**
  - **Fidelity National Financial:** **$13,753.41**
  - **Kohl's:** **$12,872.17**
  - **State Farm Insurance Cos.:** **$12,423.39**
  - **AmerisourceBergen:** **$9,685.45**
- **Simple trend story:** AOV highlights accounts with consistently larger baskets, helping differentiate **high-volume** customers from **high-value-per-order** customers for account planning.
- **Who uses this:** **Account Managers / Sales**, **Sales Ops** (segmentation), **Finance** (revenue concentration and risk review).

##### Insight 4 — Direct dominates web activity; attribution requires a defined model
- **Business metric(s):** Web events by channel (engagement proxy) + account-level association to sales volume  
- **Qualified value:**  
  - **Top channel by activity:** Direct = **5,298 events**
  - **Account-level joins:** Direct-linked accounts show the highest total quantity sold (directional signal).
- **Simple trend story:** Direct traffic may reflect repeat customers rather than acquisition; without session/order-level linkage, channel conclusions should be treated as directional rather than causal.
- **Who uses this:** **Marketing Analytics** (channel measurement), **Sales Ops** (lead-source alignment), **Finance** (ROI governance).

##### Insight 5 — Time-series views support pacing and seasonality checks
- **Business metric(s):** Monthly revenue + running total; daily order count + **7-day moving average**  
- **Qualified value (examples from outputs):**
  - Monthly revenue varies meaningfully month-to-month (e.g., **Oct 2014 = $495,333.59** in the sample output).
  - Early daily demand smooths to roughly **~3–5 orders/day** via 7-day moving average.
- **Simple trend story:** Running totals support executive pacing, while moving averages reduce noise and help detect demand shifts earlier than raw daily counts.
- **Who uses this:** **Business Operations**, **Sales Leadership**, **Finance** (forecasting and pacing).

---

#### 5) Recommendations (Next Steps)
- **Product strategy:** Protect **Standard** as the primary revenue driver; partner with **Sales Ops + Finance** to test bundle offers and pricing thresholds for cross-sell into Gloss/Poster where appropriate.
- **Regional execution:** Align playbooks to regional dynamics—**Northeast** focus on retention/reorder cadence; **West/Midwest** prioritize upsell/expansion motions to capitalize on higher AOV.
- **Marketing measurement:** Implement an attribution approach (e.g., defined time window + touch rules) before reallocating spend based on channel-level signals.
- **Operational reporting:** Publish a recurring KPI pack (monthly revenue pacing + weekly demand trend) for Sales and Finance stakeholders.

---

#### Caveats & Assumptions
- **Attribution caution:** Web events connect to orders through `account_id`. Without session/order-level keys, channel-to-sales joins can inflate results for high-activity accounts.
- **Profitability definition:** “Most profitable” is interpreted as highest **revenue**, not margin (COGS/discount data not available).
- **Time gaps:** Days with zero orders may not appear as rows; moving averages improve with a complete calendar date spine.
- **Data quality:** Outlier/null validation is not production-hardened; additional QA checks are recommended before operational use.
