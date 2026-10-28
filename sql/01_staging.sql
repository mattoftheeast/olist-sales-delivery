-- 01_staging.sql
-- Load the 9 raw Olist CSVs into staging tables, 1:1, with types guessed by DuckDB.
-- Safe to re-run: OR REPLACE rebuilds each table from the CSV.
-- Orders: one row per order
CREATE OR REPLACE TABLE stg_orders AS
SELECT * FROM read_csv('/Users/maciejkaplucha/olist/data/raw/olist_orders_dataset.csv');
-- Order items: one row per product line in an order
CREATE OR REPLACE TABLE stg_order_items AS
SELECT * FROM read_csv('/Users/maciejkaplucha/olist/data/raw/olist_order_items_dataset.csv');
-- Payments: one row per payment of an order (an order can have several)
CREATE OR REPLACE TABLE stg_payments AS
SELECT * FROM read_csv('/Users/maciejkaplucha/olist/data/raw/olist_order_payments_dataset.csv');
-- Reviews: one row per customer review of an order
CREATE OR REPLACE TABLE stg_reviews AS
SELECT * FROM read_csv('/Users/maciejkaplucha/olist/data/raw/olist_order_reviews_dataset.csv');
-- Customers: one row per customer id, with city and state
CREATE OR REPLACE TABLE stg_customers AS
SELECT * FROM read_csv('/Users/maciejkaplucha/olist/data/raw/olist_customers_dataset.csv');
-- Sellers: one row per seller, with city and state
CREATE OR REPLACE TABLE stg_sellers AS
SELECT * FROM read_csv('/Users/maciejkaplucha/olist/data/raw/olist_sellers_dataset.csv');
-- Products: one row per product, with category and size
CREATE OR REPLACE TABLE stg_products AS
SELECT * FROM read_csv('/Users/maciejkaplucha/olist/data/raw/olist_products_dataset.csv');
-- Category translation: Portuguese category name -> English
CREATE OR REPLACE TABLE stg_category_translation AS
SELECT * FROM read_csv('/Users/maciejkaplucha/olist/data/raw/product_category_name_translation.csv');
-- Geolocation: one row per zip-code prefix point (has many duplicates)
CREATE OR REPLACE TABLE stg_geolocation AS
SELECT * FROM read_csv('/Users/maciejkaplucha/olist/data/raw/olist_geolocation_dataset.csv');