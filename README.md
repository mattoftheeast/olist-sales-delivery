# Olist e-commerce: sales and delivery analysis

SQL (DuckDB) and Power BI analysis of 99,441 orders from Olist,
a Brazilian online marketplace (2016–2018). Work in progress.

## Data
Public dataset: [Brazilian E-Commerce by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) (Kaggle).
Raw files are not stored in this repo.

## Progress
- [x] Week 0: setup (DuckDB, DBeaver, GitHub)
- [x] Week 1: staging tables loaded
- [ ] Week 1: grain and keys documented
- [ ] Week 2: data quality checks

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
