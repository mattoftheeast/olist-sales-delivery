SELECT COUNT(*)                 AS n_rows,
       COUNT(DISTINCT order_id) AS n_order_ids
FROM stg_orders;
--
SELECT COUNT(*)                 AS n_rows,
       COUNT(DISTINCT order_id) AS n_order_ids
FROM stg_order_items;
--
SELECT COUNT(*)                 AS n_rows,
       COUNT(DISTINCT order_id) AS n_order_ids
FROM stg_payments;
--
SELECT COUNT(*)                 AS n_rows,
       COUNT(DISTINCT order_id) AS n_order_ids
FROM stg_reviews;

