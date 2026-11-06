# Data quality report

What was checked before any analysis, what was found, and the rule chosen for each finding. Every number comes from a query in `sql/03_grain_checks.sql` or `sql/04_data_quality.sql`. Currency is BRL.

## Summary of rules

| # | Rule | Why |
|---|---|---|
| 1 | Revenue = `SUM(price)` from order items. Freight and payments are not revenue. | Category and seller exist only on items. Payments include freight and instalment interest. |
| 2 | Lateness uses delivered orders with a delivery date only (96,470 orders). | Orders that haven't arrived can't be late. 8 delivered orders have no date. |
| 3 | Trends and the forecast use Jan 2017 to Aug 2018 (20 full months). | The start and end months are thin (349 orders, 0.35%). |
| 4 | One review per order: the latest one. | 547 orders have more than one review. Joining all of them would count those orders twice. |
| 5 | Payments are summed per order before any join. | 2,961 orders have more than one payment. |
| 6 | Customers are counted by `customer_unique_id`. | `customer_id` is new for every order: 99,441 ids belong to 96,096 people. |
| 7 | Products with no category stay in, labelled "unknown". | 1.32% of revenue. Dropping them would make totals wrong. |

## 1. Missing delivery dates

| Result | Number |
|---|---|
| Orders without a delivery date | 2,965 of 99,441 |
| ...of which status delivered | 8 |
| Canceled orders that have a delivery date | 6 |

The other missing dates are expected: shipped, invoiced, processing, created and approved orders had not arrived yet, and unavailable and canceled orders never shipped. The breakdown adds back up to 2,965.

**Rule 2.** The 8 delivered orders without a date are excluded from lateness. The 6 canceled orders are not used, because their status isn't delivered.

## 2. Duplicates and grain

Covered in week 1 (`03_grain_checks.sql`, README grain table).

- Orders: unique, 99,441.
- Reviews: 99,224 rows for 98,673 orders. 547 orders have more than one review (up to 3), which gives 551 extra rows. **Rule 4.**
- Payments: 103,886 rows for 99,440 orders. 2,961 orders have more than one payment (up to 29). **Rule 5.**
- Customers: 99,441 customer_ids, 96,096 people. 2,997 people placed more than one order (up to 17). **Rule 6.**

## 3. Control total: payments vs items + freight

For each order, the sum of payments was compared with the sum of item price + freight. Each side was summed per order in its own CTE first, so the join is 1 : 1 and nothing is double counted.

| Result | Number |
|---|---|
| Orders where the two differ by more than 0.01 | 380 |
| Net difference on those orders (items − payments) | −2,870.83 (payments higher) |
| Absolute difference | 3,269.99 |
| Total payments, all orders | 15,846,280.17 |
| **Absolute difference as a share of payments** | **0.02%** |

The cause is not resolved. Instalment interest on card payments is one likely reason why payments are higher. At 0.02% it is immaterial. **Rule 1:** revenue is measured from items, payments are used for checks only, and the gap is noted, not corrected.

## 4. Orders per month

| Month | Orders |
|---|---|
| 2016-09 | 4 |
| 2016-10 | 324 |
| 2016-11 | 0 (no row) |
| 2016-12 | 1 |
| 2017-01 to 2018-08 | steady, rising to ~6,500 a month |
| 2018-09 | 16 |
| 2018-10 | 4 |

**Rule 3.** 349 orders (0.35%) fall outside the window. Note for the lateness analysis: orders from summer 2018 had less time to be delivered and reviewed before the data ends.

## 5. Single cases

| Case | Result | Rule |
|---|---|---|
| Products with no category | 610 products, 179,535.28 of 13,591,643.70 revenue = 1.32% | Rule 7: keep, label "unknown" |
| Categories with no English translation | 2 (`pc_gamer`, `portateis_cozinha_e_preparadores_de_alimentos`) | Use the Portuguese name |
| Shipped order with no items | 1 order (`a68ce168...`) | No revenue impact, so no action needed |
| Delivered order with no payment | 1 order (`bfbd0f9b...`), 3 units of one product, 134.97, Sep 2016 | Kept in item revenue; outside the trend window anyway |
| Zero-value payments | 9: 6 vouchers, 3 `not_defined` | The 3 `not_defined` all belong to canceled orders. No action needed. |
| Orders with no items | 775 (603 unavailable, 164 canceled, 5 created, 2 invoiced, 1 shipped) | They carry no revenue. Excluded from item analysis automatically. |
