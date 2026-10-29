# Olist e-commerce: sales and delivery analysis
SQL (DuckDB) and Power BI analysis of 99,441 orders from Olist,
a Brazilian online marketplace (2016–2018). Work in progress.
## Data
Public dataset: [Brazilian E-Commerce by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) (Kaggle).
Raw files are not stored in this repo.
## Progress
- [x] Week 0: setup (DuckDB, DBeaver, GitHub)
- [x] Week 1: staging tables loaded
- [x] Week 1: grain and keys documented
- [ ] Week 2: data quality checks
## Findings so far
- **775 orders (0.8%) have no items.** Almost all never went through:
  603 unavailable, 164 canceled, 5 created, 2 invoiced.
  **1 order is "shipped" but has no items**: a data anomaly to check in week 2.
- **1 order has no payment record** (order_id `bfbd0f9bdef84302105ad712db648a6c`, status: delivered).
- **2,961 orders were paid in more than one payment** (up to 29 per order), e.g. vouchers plus a card.
  9 payments have a value of 0, all vouchers.
- **547 orders have more than one review** (up to 3). Before comparing review scores,
  keep the latest review per order or average per order, so no order is counted twice.
## Grain and keys
| Table | One row is | Key |
|---|---|---|
| stg_orders | one order | order_id |
| stg_order_items | one product line in an order | order_id + order_item_id |
| stg_payments | one payment of an order | order_id + payment_sequential |
| stg_reviews | one review of an order | review_id (to verify) |
## Staging: row counts (control total)
| Table | Rows loaded | Olist published | Match |
|---|---|---|---|
| stg_orders | 99,441 | 99,441 | yes |
| stg_order_items | 112,650 | 112,650 | yes |
| stg_payments | 103,886 | 103,886 | yes |
| stg_reviews | 99,224 | 99,224 | yes |
| stg_customers | 99,441 | 99,441 | yes |
| stg_sellers | 3,095 | 3,095 | yes |
| stg_products | 32,951 | 32,951 | yes |
| stg_category_translation | 71 | 71 | yes |
| stg_geolocation | 1,000,163 | 1,000,163 | yes |
## How to run
1. Download the CSVs from Kaggle into `data/raw/`
2. Run `sql/01_staging.sql` in DuckDB
3. Run `sql/02_row_counts.sql` to check the loads
4. Run `sql/03_grain_checks.sql` to check keys, orphan orders, payments and reviews