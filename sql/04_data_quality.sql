-- Order deliveries examination
-- Result: 99,441 vs 96,476 vs 2,965
-- 2,965 order_ids are without final timestamp
SELECT COUNT(*) AS n_order_id, COUNT(order_delivered_customer_date) AS n_order_id_with_final_timestamp, COUNT(*) - COUNT(order_delivered_customer_date) AS n_order_id_without_timestamp
FROM stg_orders;

-- Missing delivery dates by status
-- Result: 2,965 missing in total (matches 99,441 - 96,476)
-- Expected: shipped, invoiced, processing, created, approved (not arrived yet), unavailable, canceled
-- Finding: 8 delivered orders have no delivery date; 6 canceled orders have one
-- Rule: lateness analysis uses delivered orders with a delivery date only (96,470)
SELECT order_status, COUNT(*) as n_order_ids, COUNT(order_delivered_customer_date) AS n_order_id_with_final_timestamp, COUNT(*) - COUNT(order_delivered_customer_date) AS n_missing_delivery_date
FROM stg_orders
GROUP BY order_status
ORDER BY n_missing_delivery_date DESC;

-- Control check: Compare total payments with total item costs including freight, per order.
-- Result: 380 orders have discrepancies greater than one cent. Payments are below item totals for some orders and above them for others.
-- Finding: The cause remains unresolved. The discrepancies do not appear to be explained by freight costs or missing installments. Totals for the 380 mismatched orders only
WITH 
	items_total_costs_per_order AS (
    SELECT order_id, SUM(price + freight_value) AS items_total
    FROM stg_order_items
    GROUP BY order_id
),
	payments_total_per_order AS(
    SELECT order_id, SUM(payment_value) AS payment_total
    FROM stg_payments
    GROUP BY order_id
)
SELECT i.order_id, i.items_total, p.payment_total, i.items_total-p.payment_total AS difference
FROM items_total_costs_per_order i JOIN payments_total_per_order p ON i.order_id = p.order_id
WHERE ABS(difference) > 0.01
ORDER BY difference DESC;

-- Further summary of payments 
-- Results: total value of the items: 70,720.23 vs total_payment_value 73,591.06, net_difference -2,870.83 and total_absolute_difference 3,269.99
-- recorded payments exceed item totals including freight by 2,870.83. The cause remains unresolved.
WITH items_total_costs_per_order AS (
    SELECT order_id, SUM(price + freight_value) AS items_total
    FROM stg_order_items
    GROUP BY order_id
),
	payments_total_per_order AS (
    SELECT order_id, SUM(payment_value) AS payment_total
    FROM stg_payments
    GROUP BY order_id
),

	differences AS (
    SELECT i.order_id, i.items_total, p.payment_total, i.items_total - p.payment_total AS difference
    FROM items_total_costs_per_order i
    JOIN payments_total_per_order p
        ON i.order_id = p.order_id
)
SELECT
    COUNT(*) AS number_of_orders,
    SUM(items_total) AS total_item_value,
    SUM(payment_total) AS total_payment_value,
    SUM(difference) AS net_difference,
    SUM(ABS(difference)) AS total_absolute_difference
FROM differences
WHERE ABS(difference) > 0.01;

-- Materiality: 3,269.99 of 15,846,280.170 across 98,665 orders, BRL = 0.02% of payments
-- Rule: revenue is measured from order items (price), not payments.
-- Payments are used for checks only. Gap noted, not corrected.
WITH items_total_costs_per_order AS (
    SELECT order_id, SUM(price + freight_value) AS items_total
    FROM stg_order_items
    GROUP BY order_id
),
	payments_total_per_order AS (
    SELECT order_id, SUM(payment_value) AS payment_total
    FROM stg_payments
    GROUP BY order_id
),

	differences AS (
    SELECT i.order_id, i.items_total, p.payment_total, i.items_total - p.payment_total AS difference
    FROM items_total_costs_per_order i
    JOIN payments_total_per_order p
        ON i.order_id = p.order_id
)
SELECT
    COUNT(*) AS n_orders_all,
    SUM(payment_total) AS total_payments_all,
    SUM(CASE WHEN ABS(difference) > 0.01 THEN ABS(difference) ELSE 0 END) AS abs_gap,
    SUM(CASE WHEN ABS(difference) > 0.01 THEN ABS(difference) ELSE 0 END)
        / SUM(payment_total) * 100 AS gap_pct
FROM differences;

-- Orders per month
-- Result: thin months at start (2016-09: 4, 2016-10: 324, 2016-12: 1; 2016-11 has 0) and end (2018-09: 16, 2018-10: 4)
-- Rule: trend and forecast analysis uses 2017-01 to 2018-08 (20 full months); 349 orders excluded (0.35%)
WITH order_ids_by_month AS(
	SELECT order_id, DATE_TRUNC('month', order_purchase_timestamp) AS order_month
	FROM stg_orders
),
SELECT
order_month, COUNT (*)
FROM order_ids_by_month
GROUP BY order_month
ORDER BY order_month;

-- Revenue share of products with no category (610 products).
-- Result: 179,535.28 of 13,591,643.70 BRL = 1.32% of item revenue
-- Rule: keep them, label category as 'unknown'; total revenue stays complete
WITH revenue_by_category AS(
	SELECT i.order_id, p.product_category_name, i.price AS item_rev
	FROM stg_order_items i JOIN stg_products p ON i.product_id =  p.product_id
)
SELECT ROUND(SUM(item_rev),2) AS total_rev, ROUND(SUM(CASE WHEN product_category_name IS NULL THEN item_rev ELSE 0 END),2) AS item_null_category_rev,
ROUND((SUM(CASE WHEN product_category_name IS NULL THEN item_rev ELSE 0 END)/SUM(item_rev)*100),2) AS no_category_pct
FROM revenue_by_category;

-- Shipped order without items
-- Result: 1 order, a68ce1686d536ca72bd2dadc4b8671e5
-- Rule: no revenue impact; excluded from item-level analysis automatically (no rows in items)
SELECT o.order_id, o.order_status
FROM stg_orders o
LEFT JOIN stg_order_items i
       ON o.order_id = i.order_id 
WHERE i.order_id IS NULL AND order_status = 'shipped'

-- Delivered order without payment
-- Result: 1 order, bfbd0f9bdef84302105ad712db648a6c
SELECT o.order_id, o.order_status
FROM stg_orders o
LEFT JOIN stg_payments p
       ON o.order_id = p.order_id 
WHERE p.order_id IS NULL AND order_status = 'delivered'

-- Delivered order without payment
-- Result: bfbd0f9b..., 3 units of one product, 134.97 BRL revenue, Sep 2016
-- Rule: kept in item revenue (immaterial); outside the 2017-01 to 2018-08 trend window anyway
SELECT (*)
FROM stg_order_items
WHERE order_id = 'bfbd0f9bdef84302105ad712db648a6c'

-- not_defined zero payments
-- Result: 3 payments, all on canceled orders, value 0
-- Rule: no action; payments are used for checks only
SELECT o.order_id, o.order_status, p.payment_type, p.payment_value
FROM stg_orders o
LEFT JOIN stg_payments p
       ON o.order_id = p.order_id 
WHERE p.payment_type = 'not_defined'
