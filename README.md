# RFM Customer Segmentation (SQL)

## Overview
This project segments customers from a retail sales dataset (1,000 orders, 15 countries) using **RFM analysis** — a widely used customer segmentation technique based on:

- **Recency (R)** — how recently a customer placed their last order
- **Frequency (F)** — how often a customer places orders
- **Monetary (M)** — how much a customer has spent in total

The goal is to identify which customers are high-value and engaged versus which ones are at risk of churning, so a business can prioritize retention, re-engagement, or loyalty efforts accordingly.

All analysis was done in **SQL** using **DB Browser for SQLite**.

## Dataset
- Source: retail sales dataset (same dataset used in the accompanying Excel and Python analyses in this portfolio)
- Fields used: `customer_name`, `order_id`, `order_value_EUR`, `date`
- Cleaning step: the raw CSV import included ~1,047,575 blank rows (a common artifact of Excel-exported CSVs). These were identified and removed, leaving the true dataset of 1,000 orders.

## Approach

### 1. Date Conversion
Dates were stored as text in `M/D/YYYY` format. Since SQLite doesn't natively parse this format, a query was built to break the string into month, day, and year components and reassemble it into ISO format (`YYYY-MM-DD`) for accurate date calculations.

### 2. RFM Base Metrics
For each customer, calculated:
- `recency_days` — days since their most recent order (relative to the most recent date in the dataset)
- `frequency` — total number of orders placed
- `monetary` — total amount spent

### 3. NTILE Scoring
Used SQLite's `NTILE(5)` window function to split all customers into 5 equal-sized groups (1–5) for Recency and Frequency, where **bucket 1 represents the best-performing group** (most recent, most frequent).

### 4. Segmentation
Combined R and F scores into four customer segments using a `CASE` statement:

| Segment | Definition |
|---|---|
| **Champions** | Recent AND frequent buyers |
| **Recent but Low Frequency** | Ordered recently, but infrequently overall |
| **Frequent but Fading** | Used to order often, but haven't recently |
| **At Risk / Lost** | Neither recent nor frequent |

## Key Findings

| Segment | Customers | % of Total |
|---|---|---|
| At Risk / Lost | 35 | 46.7% |
| Champions | 20 | 26.7% |
| Recent but Low Frequency | 10 | 13.3% |
| Frequent but Fading | 10 | 13.3% |

**Takeaway:** Nearly half of all customers (46.7%) fall into the "At Risk / Lost" segment, while just over a quarter (26.7%) are "Champions." This suggests the business has a strong core of loyal, high-value customers, but also a significant re-engagement opportunity — targeted win-back campaigns for the At Risk segment could meaningfully improve overall customer retention.

## How to Run
1. Download `Sales-details.csv` and this repository's `.sql` files.
2. Open [DB Browser for SQLite](https://sqlitebrowser.org/) (free).
3. Create a new database, then **File → Import → Table from CSV file** and import `Sales-details.csv`.
4. Go to the **Execute SQL** tab, open `query1.sql`, and run it to produce the base RFM metrics (Recency, Frequency, Monetary per customer).
5. Open `query2.sql` and run it to produce the full NTILE scoring and segment labels.
6. (Optional) These queries are written in SQLite syntax; minor adjustments (e.g., date functions) would be needed to run in PostgreSQL or another RDBMS.

## Data Cleaning & Provenance
The raw CSV import initially produced **1,048,575 rows** in the table — a known artifact of Excel-exported CSVs, where Excel writes out rows up to its maximum row limit even when most are empty. This was diagnosed and fixed as follows:

1. Confirmed the true row count by filtering on a required field:
   ```sql
   SELECT COUNT(*) FROM sales_details WHERE customer_name IS NOT NULL AND customer_name != '';
   ```
   This returned exactly **1,000** — confirming the real dataset was intact underneath the blank rows.
2. Removed the blank rows:
   ```sql
   DELETE FROM sales_details WHERE customer_name IS NULL OR customer_name = '';
   ```
3. Re-validated the row count returned to exactly 1,000 before proceeding with any analysis.

Dates were also stored as text in `M/D/YYYY` format (not zero-padded, e.g. `2/5/2019`), which SQLite cannot parse or sort natively. `query1.sql` includes the logic used to split and reconstruct these into ISO format (`YYYY-MM-DD`) before any recency calculations.

## Business Objective & Recommendations
**Objective:** Identify which customers are disengaging so retention efforts can be targeted rather than blanket, with the goal of converting a meaningful share of the "At Risk / Lost" segment (currently 46.7% of customers) into repeat, active customers over the next quarter.

**Recommended actions by segment:**
- **Champions (26.7%)** — Reward with early access, loyalty perks, or referral incentives. These customers already drive disproportionate revenue; the priority is retention, not re-acquisition.
- **Recent but Low Frequency (13.3%)** — Encourage a second/third purchase quickly (e.g., a limited-time follow-up discount) before they drift toward "At Risk."
- **Frequent but Fading (13.3%)** — Send a targeted win-back offer referencing their past purchase history; these customers previously showed strong engagement and may respond to a direct nudge.
- **At Risk / Lost (46.7%)** — Run a re-engagement campaign (e.g., "we miss you" offer); if no response after one or two attempts, deprioritize further spend on this group to focus resources on higher-response segments.

## Segment-Level Validation Metrics
To validate that these segments are meaningfully different (not just artifacts of the NTILE split), the following metrics can be computed per segment:
- **Average Order Value (AOV)** per segment
- **% of total revenue** contributed by each segment
- **Repeat purchase rate** (customers with frequency > 1) per segment

Example validation query (average order value and revenue share by segment):
```sql
-- run this after query2.sql's rfm_scored/segmented logic
SELECT
    segment,
    COUNT(*) AS customers,
    ROUND(SUM(monetary), 2) AS total_revenue,
    ROUND(SUM(monetary) * 100.0 / (SELECT SUM(monetary) FROM rfm_base), 1) AS pct_of_total_revenue,
    ROUND(AVG(monetary / frequency), 2) AS avg_order_value
FROM (
    -- segmented CTE from query2.sql
) 
GROUP BY segment
ORDER BY total_revenue DESC;
```
*(Results to be added once run — this shows what share of total revenue each segment represents, not just what share of customers.)*

## Limitations & Next Steps
- **Dataset size:** 1,000 orders / ~75 unique customers is small for segmentation; thresholds (NTILE quintiles) are more sensitive to outliers than they would be on a larger customer base.
- **No long-term time series:** the dataset spans a fixed window, so seasonality (e.g., holiday spikes) isn't accounted for and could distort recency/frequency for some customers.
- **Currency assumption:** all values are in EUR (`order_value_EUR`); no multi-currency conversion was needed, but this should be re-verified if the dataset is extended with other currencies.
- **No campaign feedback loop:** this analysis identifies segments but doesn't yet incorporate actual campaign response data, which would be the natural next step to close the loop.
- **Proposed follow-ups:**
  - Extend the dataset with transaction timestamps over a longer period to observe true seasonality and repeat-purchase cycles.
  - Integrate campaign response data (e.g., email open/click/purchase) to measure whether the recommended actions per segment actually improve retention.
  - Add a cohort retention curve and segment revenue-share chart (see below).

## Outputs & Visuals
*(To add: a segment revenue-share bar chart and a simple repeat-purchase/cohort view — planned as a follow-up using the validation query above, exported to Excel/Python for charting.)*

## Files in this repository

| File | Description |
|---|---|
| `Sales-details.csv` | Raw dataset used for the analysis |
| `query1.sql` | RFM base metric calculation (Recency, Frequency, Monetary per customer) |
| `query1_output` | Output of the base RFM query |
| `query2.sql` | Full RFM scoring and segmentation query (NTILE scoring + segment labels) |
| `query2_output` | Final segmented customer output |

## Tools Used
- SQL (SQLite)
- DB Browser for SQLite

## Author
Himaja Ganteda
[GitHub](https://github.com/himajaganteda)
