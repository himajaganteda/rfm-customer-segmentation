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
