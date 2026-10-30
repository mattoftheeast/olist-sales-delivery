-- 03_grain_checks.sql
-- Purpose: find the grain (what one row is) and the key of each table.
-- Test: if COUNT(*) = COUNT(DISTINCT key), the key is unique.

-- Orders: row count vs distinct order_id
-- Result: 99,441 = 99,441 -> one row = one order
SELECT COUNT(*) AS n_rows, COUNT(DISTINCT order_id) AS n_order_ids
FROM stg_orders;

-- Order items: row count vs distinct order_id
-- Result: 112,650 vs 98,666 -> one row = one item in an order
SELECT COUNT(*) AS n_rows, COUNT(DISTINCT order_id) AS n_order_ids
FROM stg_order_items;

-- Payments: row count vs distinct order_id
-- Result: 103,886 vs 99,440 -> one row = one payment of an order.
-- Some orders are paid in several payments (e.g. voucher + card), numbered by payment_sequential.
SELECT COUNT(*) AS n_rows, COUNT(DISTINCT order_id) AS n_order_ids
FROM stg_payments;

-- Reviews: row count vs distinct order_id
-- Result: 99,224 vs 98,673 -> 551 extra review rows, spread over 547 orders (see below).
-- Before comparing review scores, reduce to the latest score per order, or average, so no order is counted twice
SELECT COUNT(*) AS n_rows, COUNT(DISTINCT order_id) AS n_order_ids
FROM stg_reviews;

-- Customers: row count vs distinct customer_id
-- Result: 99,441 vs 99,441 -> one row = one customer_id
-- Each customer_id appear in the list only once
SELECT COUNT(*) AS n_rows, COUNT(DISTINCT customer_id) AS n_customer_ids
FROM stg_customers;

-- Customers: distinct customer_id count vs distinct customer_unique_id
-- Result: 99,441 vs 96,096
-- Some customer_unique_ids are connected with multiple customer_ids (3,345 extra customer_ids)
SELECT COUNT(DISTINCT customer_id) AS n_customer_ids, COUNT(DISTINCT customer_unique_id) AS n_customer_unique_ids
FROM stg_customers;

-- Sellers: seller_id vs distinct seller_id
-- Result: 3,095 vs 3,095 -> one row = one seller, key: seller_id
-- Each seller_id is a distinct one
SELECT COUNT(*) AS n_rows, COUNT(DISTINCT seller_id) AS n_seller_ids
FROM stg_sellers;

-- Products: product_id vs distinct product_id
-- Result: 32,951 vs 32,951 -> one row = one product, key: product_id
-- Each product_id is a distinct one
SELECT COUNT(*) AS n_rows, COUNT(DISTINCT product_id) AS n_product_ids
FROM stg_products;

-- Category Translation: distinct product_category_name vs distinct product_category_name_english
-- Result: 71 vs 71 -> each category has a unique translation
-- No category is merged
SELECT COUNT(DISTINCT product_category_name) AS n_product_category_name, COUNT(DISTINCT product_category_name_english) AS n_product_category_name_english
FROM stg_category_translation;

-- Further investigation on stg_items
-- Orders without any items (anti-join)
-- Result: 775 (matches 99,441 - 98,666)
SELECT COUNT(*) AS n_orders_without_items
FROM stg_orders o
LEFT JOIN stg_order_items i ON o.order_id = i.order_id
WHERE i.order_id IS NULL;

-- Further investigation on stg_items
-- Orders without items, by status
-- Result: unavailable 603, canceled 164, created 5, invoiced 2, shipped 1
SELECT o.order_status, COUNT(*) AS n_orders
FROM stg_orders o
LEFT JOIN stg_order_items i ON o.order_id = i.order_id
WHERE i.order_id IS NULL
GROUP BY o.order_status
ORDER BY n_orders DESC;

-- Further investigation on stg_payments
-- Orders with more than one payment
-- Result: 2,961 orders have more than one payment (max 29)
SELECT order_id, COUNT(*) AS n_payments
FROM stg_payments
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY n_payments DESC;

-- Further investigation on stg_payments
-- Orders with zero-value payment
-- Result: 9 payments with value 0, 6 of them by vouchers, 3 not defined
SELECT payment_type, COUNT(*) 
FROM stg_payments 
WHERE payment_value = 0 
GROUP BY payment_type;

-- Further investigation on stg_payments 
-- Difference between 99,441 order_id and 99,440 distinct order_id in payments
-- Result: 1 order without payment: bfbd0f9bdef84302105ad712db648a6c - order_status: delivered
SELECT *
FROM stg_orders o
LEFT JOIN stg_payments p ON o.order_id = p.order_id
WHERE p.order_id IS NULL;

-- Further investigation on stg_reviews
-- Orders with more than one review
-- Result: 547 orders have more than one review (max 3)
SELECT order_id, COUNT(*) AS n_reviews
FROM stg_reviews
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY n_reviews DESC;

-- Further investigation on customer_id and customer_unique_id
-- Customer_unique_ids with more than 1 customer_id assigned
-- Result: 2,997 customer_unique_ids have more than one customer_id assigned (max 17)
SELECT customer_unique_id, COUNT(customer_id) AS n_customer_ids
FROM stg_customers
GROUP BY customer_unique_id
HAVING n_customer_ids > 1
ORDER BY n_customer_ids DESC;

-- Further investigation on customer_id and customer_unique_id
-- Total number of the multiple customer_ids assigned to unique_customer_ids
-- Result: 6,342 customer_id are assigned to 2,997 customer_unique_ids
WITH repeat_customers AS (
    SELECT customer_unique_id, COUNT(customer_id) AS n_customer_ids
    FROM stg_customers
    GROUP BY customer_unique_id
    HAVING COUNT(customer_id) > 1
)
SELECT COUNT(*)            AS n_people_with_several_ids,
       SUM(n_customer_ids) AS n_customer_ids_involved
FROM repeat_customers;

-- Further investigation on stg_products 
-- product_ids with no category name
-- Result: 610 products with no category name
SELECT COUNT(*)
FROM stg_products
WHERE product_category_name IS NULL;

-- Further investigation on stg_products
-- Do all categories used in products have a translation?
-- Result: two categories in stg_products have no translation: portateis_cozinha_e_preparadores_de_alimentos and pc_gamer
SELECT DISTINCT p.product_category_name
FROM stg_products p
LEFT JOIN stg_category_translation t
       ON p.product_category_name = t.product_category_name
WHERE t.product_category_name IS NULL
  AND p.product_category_name IS NOT NULL;
