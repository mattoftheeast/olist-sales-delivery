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
- [x] Week 1: staging tables, row counts, grain and key checks
- [ ] Week 1: data types, relationship diagram, data dictionary
- [ ] Week 2: data quality checks
- [ ] Weeks 3–4: data model and answers to the business questions, with a one-page memo
- [ ] Weeks 5–6: Power BI dashboard and final story

## Key findings so far (data checks)

Every number below comes from a query in `sql/03_grain_checks.sql`.

1. **775 orders have no items.** By status: 603 unavailable, 164 canceled, 5 created, 2 invoiced and **1 shipped**. Most make sense (the order never went ahead), but a shipped order with no items is a data error to investigate.
2. **1 delivered order has no payment record** (order_id `bfbd0f9bdef84302105ad712db648a6c`). It will be excluded from or flagged in revenue totals.
3. **2,961 orders were paid with more than one payment** (up to 29 for one order). Payments must be summed per order before joining to orders, or revenue gets double counted. There are also 9 zero-value payments: 6 vouchers and 3 with payment type `not_defined`.
4. **547 orders have more than one review** (up to 3). A rule is needed, such as the latest review or the average score per order, before reviews are joined to orders.
5. **Olist creates a new customer_id for every order.** The 99,441 customer_ids belong to 96,096 real people (customer_unique_id). 2,997 people placed more than one order (up to 17 ids for one person). Customers must be counted by customer_unique_id, or repeat customers look like new ones.
6. **610 products have no category**, and **2 categories have no English translation** (`pc_gamer` and `portateis_cozinha_e_preparadores_de_alimentos`). Their share of revenue will be checked in week 2 to decide if it matters.

## Grain of each table (what one row means)

| Table | One row = | Key | Unique? |
|---|---|---|---|
| stg_orders | one order | order_id | Yes (99,441) |
| stg_order_items | one item in an order | order_id + order_item_id | order_id repeats (112,650 rows, 98,666 orders) |
| stg_payments | one payment for an order | order_id + payment_sequential | order_id repeats (103,886 rows, 99,440 orders) |
| stg_reviews | one review | review_id (to verify) | order_id repeats (99,224 rows, 98,673 orders) |
| stg_customers | one customer per order | customer_id (person: customer_unique_id) | customer_id yes (99,441); 96,096 people |
| stg_sellers | one seller | seller_id | Yes (3,095) |
| stg_products | one product | product_id | Yes (32,951) |
| stg_category_translation | one category | product_category_name | Yes (71) |

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

## Open questions for week 2

- What share of revenue sits in products without a category?
- Why does a shipped order have no items?
- How should the delivered order without a payment be treated in revenue?
- Which review rule to use per order (latest or average)?
- Which orders do the 3 `not_defined` zero payments belong to?

## Data source

Brazilian E-Commerce Public Dataset by Olist, available on Kaggle. This is an analysis of public data, not work done for Olist.
