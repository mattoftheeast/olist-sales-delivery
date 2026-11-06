# Data dictionary

The columns this project uses, one line each. Other columns in the raw files (e.g. product dimensions, zip codes) are not used yet and are left out.

Types are as loaded by DuckDB into the staging tables (checked with `information_schema.columns`).

## stg_orders (one row = one order)

| Column | Type | Meaning | Notes |
|---|---|---|---|
| order_id | VARCHAR | Unique id of the order | Key. 99,441 orders |
| customer_id | VARCHAR | Customer id for this order | New id for every order, see stg_customers |
| order_status | VARCHAR | Status: delivered, shipped, canceled, unavailable, etc. | |
| order_purchase_timestamp | TIMESTAMP | When the customer placed the order | Main date for revenue trends |
| order_approved_at | TIMESTAMP | When payment was approved | |
| order_delivered_carrier_date | TIMESTAMP | When the seller handed the order to the carrier | |
| order_delivered_customer_date | TIMESTAMP | When the customer received the order | Empty if not delivered |
| order_estimated_delivery_date | TIMESTAMP | Delivery date promised to the customer | Late = delivered after this date |

## stg_order_items (one row = one item in an order)

| Column | Type | Meaning | Notes |
|---|---|---|---|
| order_id | VARCHAR | Order the item belongs to | 775 orders have no items |
| order_item_id | BIGINT | Item number within the order (1, 2, 3…) | Key = order_id + order_item_id |
| product_id | VARCHAR | Product sold | Links to stg_products |
| seller_id | VARCHAR | Seller who sold the item | Links to stg_sellers |
| shipping_limit_date | TIMESTAMP | Deadline for the seller to hand over to the carrier | |
| price | DOUBLE | Item price (BRL) | Revenue = sum of price |
| freight_value | DOUBLE | Shipping cost charged for the item (BRL) | |

## stg_payments (one row = one payment for an order)

| Column | Type | Meaning | Notes |
|---|---|---|---|
| order_id | VARCHAR | Order paid | 2,961 orders have more than one payment; sum per order before joining |
| payment_sequential | BIGINT | Payment number within the order | Key = order_id + payment_sequential |
| payment_type | VARCHAR | credit_card, boleto, voucher, debit_card, not_defined | |
| payment_installments | BIGINT | Number of instalments the payment is split into | Not the same as number of payments |
| payment_value | DOUBLE | Amount paid (BRL) | 9 zero values: 6 voucher, 3 not_defined |

## stg_reviews (one row = one review)

| Column | Type | Meaning | Notes |
|---|---|---|---|
| review_id | VARCHAR | Id of the review | |
| order_id | VARCHAR | Order reviewed | 547 orders have more than one review |
| review_score | BIGINT | Score from 1 to 5 | Reduce to one score per order before analysis |
| review_creation_date | TIMESTAMP | When the review survey was sent | |
| review_answer_timestamp | TIMESTAMP | When the customer answered | |

## stg_customers (one row = one customer_id, i.e. one order)

| Column | Type | Meaning | Notes |
|---|---|---|---|
| customer_id | VARCHAR | Customer id for one order | Key. Links to stg_orders |
| customer_unique_id | VARCHAR | The real person | 96,096 people. Count customers by this column |
| customer_city | VARCHAR | Customer's city | |
| customer_state | VARCHAR | Customer's state (e.g. SP, RJ) | Used for regions |

## stg_sellers (one row = one seller)

| Column | Type | Meaning | Notes |
|---|---|---|---|
| seller_id | VARCHAR | Unique id of the seller | Key. 3,095 sellers |
| seller_state | VARCHAR | Seller's state | |

## stg_products (one row = one product)

| Column | Type | Meaning | Notes |
|---|---|---|---|
| product_id | VARCHAR | Unique id of the product | Key. 32,951 products |
| product_category_name | VARCHAR | Category in Portuguese | 610 products have no category |

## stg_category_translation (one row = one category)

| Column | Type | Meaning | Notes |
|---|---|---|---|
| product_category_name | VARCHAR | Category in Portuguese | Key. 71 categories |
| product_category_name_english | VARCHAR | Category in English | 2 categories used in products are missing here |
