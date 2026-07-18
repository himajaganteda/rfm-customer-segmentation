# RFM Customer Segmentation (SQL)

## Overview
This repository contains a SQL-first RFM (Recency, Frequency, Monetary) customer segmentation project. The goal is to identify high-value and at-risk customers so the business can prioritize retention and loyalty campaigns.

This update added reproducible SQL scripts, a data-cleaning script, validation queries, instructions to generate visuals, a short business objective + campaign recommendations, limitations, and a 3-slide summary (slides/summary.md). Run order and instructions are below.

## Business objective
Reduce churn and increase repeat revenue by targeting customers with personalized campaigns. Objective: increase repeat purchase rate by 10% among the "At Risk" segment over 3 months by running a targeted winback campaign; increase revenue from "Champion" customers by 15% via VIP offers.

## What I added in this update
- sql/query1_data_cleaning.sql — data ingestion & cleaning steps (blank-row removal, date parsing) and instructions.
- sql/query2_rfm_raw.sql — RFM raw metrics (last_purchase, frequency, monetary).
- sql/query3_rfm_scores.sql — NTILE scoring, rfm_string, and segmentation mapping.
- sql/query4_metrics_validation.sql — AOV, repeat rate, segment revenue share, LTV proxy and simple sanity checks.
- visuals/plot_instructions.md — Python snippets (pandas/matplotlib) to create cohort retention and revenue-share plots and save PNGs.
- slides/summary.md — 3-slide PDF-ready summary (in markdown) you can convert to PDF.
- README updated with run instructions and expected outputs.

## Reproducibility — how to run (SQLite / psql)
Recommended: run the SQL files in the order below. The SQL is written to work with SQLite (DB Browser for SQLite) and is compatible with Postgres with small tweaks (CASTs, date parsing). If you want, I can produce a Postgres-specific branch.

Run order (in DB Browser / sqlite3 / psql):
1. sql/query1_data_cleaning.sql
2. sql/query2_rfm_raw.sql
3. sql/query3_rfm_scores.sql
4. sql/query4_metrics_validation.sql

Example (sqlite3):
  sqlite3 mydb.db < sql/query1_data_cleaning.sql
  sqlite3 mydb.db < sql/query2_rfm_raw.sql

Example (psql / Postgres) — replace types/funcs as needed:
  psql -d mydb -f sql/query1_data_cleaning.sql

Expected outputs (check these tables / files):
- rfm_raw (customer_id, last_purchase, frequency, monetary)
- rfm_scores (customer_id, r_score, f_score, m_score, rfm_string, segment)
- segment_profiles (segment, users, avg_monetary, avg_frequency, revenue_share)
- CSV exports: outputs/rfm_scores.csv and outputs/segment_profiles.csv (create by running the SQL and exporting results)

## Data cleaning & provenance
See sql/query1_data_cleaning.sql for exact cleaning steps. In short:
- Removed blank rows from original CSV (artifact from Excel) using a WHERE clause that discards rows with NULL or empty key fields.
- Normalized date strings (M/D/YYYY) into ISO date format and converted to DATE/TIMESTAMP.
- Filtered canceled orders and only used completed transactions for monetary calculations.
- Documented the original raw file name and row counts (before/after) in the script as comments.

## Business actions (2–3 recommended campaigns)
1) Champions (High R & F & M): Invite to VIP program — offer early access + 10% off; goal: +15% revenue from this group.
2) At Risk (Low R, previously high F): Winback email with a personalized discount and product recommendations; goal: recover 10% into active buyers.
3) Recent but Low Frequency: Nurture with cross-sell recommendations + free shipping for next order to convert into repeat buyers.

## Metrics & validation included
The validation script (sql/query4_metrics_validation.sql) computes:
- AOV (avg order value) per segment
- Repeat rate (customers with >1 orders / total customers) per segment
- Revenue share (% of total monetary by segment)
- Simple LTV proxy = avg_order_value * avg_frequency * expected_lifetime_months (configurable)
- Sanity checks: distribution buckets for recency/frequency, and a small sample of top customers per segment

## Outputs & visuals
I included instructions to create two visuals using Python + pandas + matplotlib in visuals/plot_instructions.md:
- Cohort retention curve (monthly cohorts)
- Segment revenue share (pie or bar chart)

Run the query to export outputs/rfm_scores.csv and outputs/segment_profiles.csv, then run the Python snippets to create PNGs.

## Limitations & next steps
- Small dataset (1,000 orders) — limited statistical power; better to run across >6–12 months of transactions.
- Single currency (EUR) assumed — add an FX normalization step for multi-currency data.
- No campaign response data available — to validate actions, add post-campaign events or UTM tags.

Next steps I can do for you (choose):
A) Convert scripts to Postgres dialect and add automation (pgAgent cron example).
B) Create a small Streamlit dashboard and commit it to repo.
C) Produce PNGs from the dataset and add them to outputs/ (requires running the Python plotting steps locally or giving me permission to push images).

If you want me to commit further changes (A/B/C) to the repository, tell me which and I will proceed.

---
Author: Himaja Ganteda
Repo: https://github.com/himajaganteda/rfm-customer-segmentation
