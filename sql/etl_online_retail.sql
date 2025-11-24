-- =============================================================
-- ETL: Online Retail -> Normalized Retail Data Model
-- 5-step ETL from raw staging to analytic model
-- =============================================================


-- =============================================================
-- STEP 1: Clean raw data into staging
-- (Filter cancellations, returns, missing customers, invalid prices)
-- =============================================================

TRUNCATE TABLE online_retail_clean;

INSERT INTO online_retail_clean (
    invoiceno,
    stockcode,
    description,
    quantity,
    invoicedate,
    order_timestamp,
    unitprice,
    customerid,
    country
)
SELECT
    invoiceno,
    stockcode,
    description,
    quantity,
    invoicedate,
    -- NOTE: Adjust the format mask if your date format differs
    TO_TIMESTAMP(invoicedate, 'DD/MM/YYYY HH24:MI') AS order_timestamp,
    unitprice,
    customerid,
    country
FROM online_retail_raw
WHERE invoiceno NOT LIKE 'C%'      -- exclude cancelled invoices
  AND quantity > 0                 -- exclude returns / negative quantities
  AND customerid IS NOT NULL       -- exclude anonymous customers
  AND unitprice > 0;               -- exclude zero-priced rows



-- =============================================================
-- STEP 2: Build customer dimension
-- (One row per unique customer)
-- =============================================================

INSERT INTO customers (external_customer_id, country)
SELECT DISTINCT
    customerid AS external_customer_id,
    country
FROM online_retail_clean
WHERE customerid IS NOT NULL
ON CONFLICT (external_customer_id) DO NOTHING;



-- =============================================================
-- STEP 3: Build product dimension
-- (One row per unique stock code)
-- =============================================================

WITH product_base AS (
    SELECT
        stockcode,
        MAX(description) AS product_name,
        MODE() WITHIN GROUP (ORDER BY unitprice) AS unit_price
    FROM online_retail_clean
    GROUP BY stockcode
)
INSERT INTO products (stock_code, product_name, unit_price)
SELECT
    stockcode,
    product_name,
    unit_price
FROM product_base
ON CONFLICT (stock_code) DO NOTHING;



-- =============================================================
-- STEP 4: Build order headers
-- (One row per invoice, linked to customer)
-- =============================================================

INSERT INTO orders (invoice_no, customer_id, order_date, order_status, country)
SELECT DISTINCT
    c.invoiceno            AS invoice_no,
    cu.customer_id         AS customer_id,
    c.order_timestamp      AS order_date,
    'completed'            AS order_status,
    c.country              AS country
FROM online_retail_clean c
JOIN customers cu
  ON cu.external_customer_id = c.customerid
ON CONFLICT (invoice_no) DO NOTHING;



-- =============================================================
-- STEP 5: Build order line items
-- (Aggregate quantity per product per invoice)
-- =============================================================

WITH order_items_base AS (
    SELECT
        invoiceno,
        stockcode,
        SUM(quantity) AS quantity,
        MODE() WITHIN GROUP (ORDER BY unitprice) AS unit_price
    FROM online_retail_clean
    GROUP BY invoiceno, stockcode
)
INSERT INTO order_items (order_id, product_id, quantity, unit_price, line_total)
SELECT
    o.order_id,
    p.product_id,
    b.quantity,
    b.unit_price,
    b.quantity * b.unit_price AS line_total
FROM order_items_base b
JOIN orders o
  ON o.invoice_no = b.invoiceno
JOIN products p
  ON p.stock_code = b.stockcode;
