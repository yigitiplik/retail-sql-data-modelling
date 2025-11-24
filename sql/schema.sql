-- =============================================================
-- SCHEMA: Online Retail - Staging + Normalized Model
-- Target: PostgreSQL
-- =============================================================

-- =============================================================
-- SECTION 0: Drop existing tables (for clean re-runs)
-- =============================================================

DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS online_retail_clean;
DROP TABLE IF EXISTS online_retail_raw;


-- =============================================================
-- SECTION 1: Raw staging table
-- (Matches the Online Retail CSV structure)
-- =============================================================

CREATE TABLE online_retail_raw (
    InvoiceNo      TEXT,
    StockCode      TEXT,
    Description    TEXT,
    Quantity       INT,
    InvoiceDate    TEXT,               -- kept as TEXT for flexible parsing
    UnitPrice      NUMERIC(12, 4),
    CustomerID     INT,
    Country        TEXT
);

-- =============================================================
-- OPTIONAL: Load data into online_retail_raw
-- Use pgAdmin "Import" tool or manual COPY command.
-- IMPORTANT: Update the file path according to your system.
-- =============================================================

-- Example COPY command (commented out by default):
-- COPY online_retail_raw
-- FROM 'C:\\path\\to\\online_retail_raw.csv'
-- DELIMITER ','
-- CSV HEADER;


-- =============================================================
-- SECTION 2: Cleaned staging table
-- (Parsed timestamp, filtered rows will be loaded here)
-- =============================================================

CREATE TABLE online_retail_clean (
    invoiceno       TEXT,
    stockcode       TEXT,
    description     TEXT,
    quantity        INT,
    invoicedate     TEXT,
    order_timestamp TIMESTAMP,
    unitprice       NUMERIC(12, 4),
    customerid      INT,
    country         TEXT
);


-- =============================================================
-- SECTION 3: Customer dimension
-- (One row per unique customer)
-- =============================================================

CREATE TABLE customers (
    customer_id          SERIAL PRIMARY KEY,
    external_customer_id INT UNIQUE,
    country              TEXT,
    created_at           TIMESTAMP DEFAULT NOW()
);


-- =============================================================
-- SECTION 4: Product dimension
-- (One row per unique stock code)
-- =============================================================

CREATE TABLE products (
    product_id    SERIAL PRIMARY KEY,
    stock_code    TEXT UNIQUE,
    product_name  TEXT,
    unit_price    NUMERIC(12, 4),
    created_at    TIMESTAMP DEFAULT NOW()
);


-- =============================================================
-- SECTION 5: Order headers
-- (One row per invoice, linked to customer)
-- =============================================================

CREATE TABLE orders (
    order_id        SERIAL PRIMARY KEY,
    invoice_no      TEXT UNIQUE,
    customer_id     INT REFERENCES customers(customer_id),
    order_date      TIMESTAMP,
    order_status    TEXT,
    country         TEXT,
    created_at      TIMESTAMP DEFAULT NOW()
);


-- =============================================================
-- SECTION 6: Order line items
-- (One row per product per invoice)
-- =============================================================

CREATE TABLE order_items (
    order_item_id  SERIAL PRIMARY KEY,
    order_id       INT REFERENCES orders(order_id),
    product_id     INT REFERENCES products(product_id),
    quantity       INT,
    unit_price     NUMERIC(12, 4),
    line_total     NUMERIC(12, 4)
);


-- =============================================================
-- SECTION 7: Helpful indexes
-- =============================================================

CREATE INDEX idx_orders_customer_id   ON orders(customer_id);
CREATE INDEX idx_orders_order_date    ON orders(order_date);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product  ON order_items(product_id);
CREATE INDEX idx_customers_ext_id     ON customers(external_customer_id);
CREATE INDEX idx_products_stock_code  ON products(stock_code);
