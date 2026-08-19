# Sakila SQL Analysis — DVD Rental Business Insights

SQL-only analysis of a fictional DVD rental chain, using the **Sakila** sample database (MySQL). Sakila is a synthetic dataset originally developed by MySQL AB — not real business data — but it's an industry-standard, fully normalized relational schema, widely used to demonstrate SQL proficiency because of its genuine multi-table complexity (16 base tables, 7 views, stored procedures).

This project answers 8 business questions using raw SQL: joins, subqueries, window functions, and one query optimization exercise — no BI tool, no pre-aggregated data.

## Tech Used
- MySQL 8.x
- MySQL Workbench

## Schema Overview
Sakila models a DVD rental store: customers rent films (via `inventory`, which tracks physical copies) from one of two stores, and each rental generates a `payment`. Supporting tables cover actors, categories, staff, and location hierarchy (`address` → `city` → `country`).

<img width="1219" height="805" alt="sakila" src="https://github.com/user-attachments/assets/b0b1b993-e58e-4b58-a806-05c59cde573c" />



## Business Questions Answered
1. What are the top 5 highest-revenue films in each category?
2. What's the monthly rental revenue trend across both stores?
3. Which customers rent more often than the average customer?
4. What's the running total of revenue per store over time?
5. How do customers rank by total spend within their store?
6. Which customers haven't rented anything in the last 90 days?
7. Which actor appears in the most films within each category?
8. How much does an index improve a filtered query on `payment`?

## Query Breakdown

**1. Top 5 films by category** (`queries/01_top5_films_by_category.sql`)
Joined `film → film_category → category → inventory → rental → payment`, aggregated revenue per film, then used `ROW_NUMBER() OVER (PARTITION BY category ORDER BY revenue DESC)` to rank within each category and filtered to the top 5.

**2. Monthly revenue trend** (`queries/02_monthly_revenue_trend.sql`)
Used `DATE_FORMAT(payment_date, '%Y-%m')` to bucket by calendar month *and year* — grouping by month name alone would silently merge Jan 2005 with Jan 2006. Sorting on the `YYYY-MM` string sorts correctly both alphabetically and chronologically.

**3. Above-average renters** (`queries/03_customers_above_avg_rentals.sql`)
Used a `HAVING` clause with a subquery computing the average rental count per customer, rather than a correlated subquery — cheaper here since the average only needs to be computed once, not per row.

**4. Running total of revenue per store** (`queries/04_running_total_revenue_by_store.sql`)
`SUM(amount) OVER (PARTITION BY store_id ORDER BY payment_date)` — partitioning is essential here; without it the running total would blend both stores into a single meaningless number.

**5. Customer ranking by spend** (`queries/05_customer_ranking_by_spend.sql`)
Aggregated total spend per customer in a derived table, then applied `DENSE_RANK() OVER (PARTITION BY store_id ORDER BY spend DESC)` so ties share a rank without skipping numbers.

**6. Inactive customers (90 days)** (`queries/06_inactive_customers_90days.sql`)
Solved two ways — `NOT IN` and `NOT EXISTS` — and verified both return an identical 441 customers. `NOT EXISTS` is the safer default in production: `NOT IN` silently returns zero rows if the subquery ever produces a NULL, a risk that doesn't materialize here only because `rental.customer_id` is NOT NULL.

**7. Top actor per category** (`queries/07_top_actor_per_category.sql`)
4-table join (`actor → film_actor → film → film_category → category`), grouped by actor and category, ranked with `DENSE_RANK()` partitioned by category, filtered to rank 1.

**8. Query optimization** (`queries/08_index_optimization.sql`)
See below.

## Query Optimization
Ran `EXPLAIN` on a filtered query against `payment.amount` before and after adding an index. `amount` was chosen to clearly demonstrate the scan → seek mechanism, not because it reflects a typical business filter.

| | type | rows examined | key used |
|---|---|---|---|
| Before | ALL (full table scan) | 16,500 | none |
| After | ref (index lookup) | 1,299 | idx_payment |

~92% reduction in rows scanned for this filter.

![Before]<img width="900" height="401" alt="Screenshot 2026-08-19 144520" src="https://github.com/user-attachments/assets/a4ec5e5c-13cf-42a9-8428-451c1b8c6fcc" />

![After]<img width="975" height="299" alt="Screenshot 2026-08-19 144557" src="https://github.com/user-attachments/assets/e02316e6-2a6d-4ec8-ad5f-312d17c0ffad" />


## What I'd Do Differently
- Add indexes proactively based on expected query patterns instead of reactively.
- Connect this schema to Power BI or Tableau for a dashboard layer on top of these queries.
- Extend the inactivity analysis into a full customer segmentation/cohort model.

## Author
Sumit Suryavanshi
sumitsuryavanshi1965@gmail.com
