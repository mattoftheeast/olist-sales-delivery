-- 03_grain_checks.sql
-- Purpose: find the grain (what one row is) and the key of each table.
-- Test: if COUNT(*) = COUNT(DISTINCT key), the key is unique.

-- Orders: row count vs distinct order_id
-- Result: 99,441 = 99,441 -> one row = one order
SELECT COUNT(*) AS n_rows, COUNT(DISTINCT order_id) AS n_order_ids
FROM stg_orders;

-- Order items: row count vs distinct order_id
-- Result: 112,650 vs 98,666 -> one row = one product line in an order
SELECT COUNT(*) AS n_rows, COUNT(DISTINCT order_id) AS n_order_ids
FROM stg_order_items;

-- Payments: row count vs distinct order_id
-- Result: 103,886 vs 99,440 -> one row = one payment of an order.
-- Some orders are paid in several payments (e.g. voucher + card), numbered by payment_sequential.
SELECT COUNT(*) AS n_rows, COUNT(DISTINCT order_id) AS n_order_ids
FROM stg_payments;

-- Reviews: row count vs distinct order_id
-- Result: 99,224 vs 98,673 -> some orders have more reviews (up to 3 reviews per order). 
-- Before comparing reviews scores, reduce to the latest score per order, or average, so no order is counted twice
SELECT COUNT(*) AS n_rows, COUNT(DISTINCT order_id) AS n_order_ids
FROM stg_reviews;

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
-- Result: 9 payments with value 0, all vouchers
SELECT COUNT(order_id)
FROM stg_payments
WHERE payment_value = 0;

-- Further investigation on stg_payments 
-- Difference between 99,441 order_id and 99,440 distinct order_id in payments
-- Result: 1 order without payment: bfbd0f9bdef84302105ad712db648a6c - order_status: delivered
SELECT (*)
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
