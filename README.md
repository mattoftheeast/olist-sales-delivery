# Olist sales and delivery analysis

SQL analysis of the public Brazilian E-Commerce dataset by Olist (Kaggle): about 100k real marketplace orders from 2016 to 2018, across 9 linked tables.

**Business questions** (answered in later stages):
1. Which categories and regions drive revenue, and how is that trending?
2. Where are deliveries late, and how does lateness affect review scores?
3. Which sellers carry the most risk (late deliveries, low ratings, concentration)?
4. What is a simple next-quarter sales forecast, with a range?

Note: the dataset has no product cost, so this project talks about **revenue**, not margin or profit.

**Tools:** DuckDB (SQL engine), DBeaver (SQL editor), Git and GitHub. Power BI comes in a later stage.

## Status

- [x] Week 0: setup, data loaded, 99,441 orders verified
- [x] Week 1: staging tables, row counts, grain and key checks, data types, data dictionary
- [x] Week 2: data quality checks and cleaning rules
- [ ] Weeks 3–4: data model (with relationship diagram) and answers to the business questions, with a one-page memo
- [ ] Weeks 5–6: Power BI dashboard and final story

## Cleaning rules

Decided in week 2. The full checks and results are in [`docs/data_quality_report.md`](docs/data_quality_report.md).

1. **Revenue = `SUM(price)` from order items.** Freight and payments are not revenue. Item revenue in total: 13,591,643.70 BRL.
2. **Lateness uses delivered orders that have a delivery date** (96,470 orders).
3. **Trends and the forecast use Jan 2017 to Aug 2018** (20 full months). The thin months at the start and end hold 349 orders (0.35%).
4. **One review per order: the latest one.**
5. **Payments are summed per order before any join.**
6. **Customers are counted by `customer_unique_id`.**
7. **Products with no category stay in, labelled "unknown"** (1.32% of revenue).

## Key findings from the data checks

Every number below comes from a query in `sql/03_grain_checks.sql` or `sql/04_data_quality.sql`.

1. **Payments and items match.** Paid vs items + freight differs on 380 orders, by 3,269.99 BRL in total. That's 0.02% of 15,846,280.17 in payments, so it's immaterial.
2. **775 orders have no items.** By status: 603 unavailable, 164 canceled, 5 created, 2 invoiced and 1 shipped. They carry no revenue.
3. **1 delivered order has no payment record** (`bfbd0f9bdef84302105ad712db648a6c`). It has 3 items worth 134.97, from Sep 2016. It stays in item revenue.
4. **2,965 orders have no delivery date.** Almost all haven't arrived yet or never shipped, but 8 delivered orders have no date, and 6 canceled orders have one.
5. **2,961 orders were paid with more than one payment** (up to 29). There are 9 zero-value payments: 6 vouchers and 3 `not_defined`, all on canceled orders.
6. **547 orders have more than one review** (up to 3), which gives 551 extra review rows.
7. **Olist creates a new customer_id for every order.** The 99,441 customer_ids belong to 96,096 real people. 2,997 people placed more than one order (up to 17).
8. **610 products have no category** (1.32% of revenue), and **2 categories have no English translation** (`pc_gamer`, `portateis_cozinha_e_preparadores_de_alimentos`).
9. **The data starts and ends thin:** 4 orders in Sep 2016, none in Nov 2016, and only 16 and 4 in Sep and Oct 2018.

## Grain of each table (what one row means)

| Table | One row = | Key | Unique? |
|---|---|---|---|
| stg_orders | one order | order_id | Yes (99,441) |
| stg_order_items | one item in an order | order_id + order_item_id | order_id repeats (112,650 rows, 98,666 orders) |
| stg_payments | one payment for an order | order_id + payment_sequential | order_id repeats (103,886 rows, 99,440 orders) |
| stg_reviews | one review of an order | order_id (reduced to one review per order before use) | order_id repeats (99,224 rows, 98,673 orders) |
| stg_customers | one customer per order | customer_id (person: customer_unique_id) | customer_id yes (99,441); 96,096 people |
| stg_sellers | one seller | seller_id | Yes (3,095) |
| stg_products | one product | product_id | Yes (32,951) |
| stg_category_translation | one category | product_category_name | Yes (71) |

Data types checked: dates are TIMESTAMP, money columns are DOUBLE. Column meanings are in [`docs/data_dictionary.md`](docs/data_dictionary.md).

## Row counts (raw CSV = staging table)

| Table | Rows |
|---|---|
| orders | 99,441 |
| order_items | 112,650 |
| payments | 103,886 |
| reviews | 99,224 |
| customers | 99,441 |
| sellers | 3,095 |
| products | 32,951 |
| category_translation | 71 |

All staging tables match their raw files.

## How to run

1. Download the Olist dataset from Kaggle and unzip the CSV files into `data/raw/`. The data is not stored in this repo (it is in `.gitignore`).
2. Open `olist.duckdb` in DBeaver, or with the DuckDB command line.
3. Run `sql/01_staging.sql` to create the staging tables (stg_...).
4. Run `sql/02_row_counts.sql` to check that each table matches its raw file.
5. Run `sql/03_grain_checks.sql` to check keys and grain: orders without items or payments, multiple payments and reviews per order, customers vs real people, and products without a category or translation.
6. Run `sql/04_data_quality.sql` for the data quality checks: missing delivery dates, the payments vs items control total, orders per month, and the single cases.

## Repository

```
sql/    01_staging, 02_row_counts, 03_grain_checks, 04_data_quality
docs/   data_dictionary.md, data_quality_report.md
```

## Data source

Brazilian E-Commerce Public Dataset by Olist, available on Kaggle. This is an analysis of public data, not work done for Olist.
