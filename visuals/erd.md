# Entity Relationship Diagram (ERD)

This ERD describes the core tables used in the Online Retail data model.

## Tables

- **online_retail_raw**
  - Raw landing table for the original Online Retail CSV file.
  - Contains all fields exactly as provided in the source dataset.

- **online_retail_clean**
  - Cleaned staging table.
  - Filters out:
    - Cancelled invoices
    - Negative quantities (returns)
    - Rows with missing CustomerID
    - Rows with UnitPrice <= 0
  - Parses `InvoiceDate` into a proper `order_timestamp`.

- **customers**
  - Customer dimension.
  - One row per unique `CustomerID`.
  - Uses a surrogate key `customer_id` and stores the original `CustomerID` as `external_customer_id`.

- **products**
  - Product dimension.
  - One row per unique `StockCode`.
  - Stores product description and a canonical unit price.

- **orders**
  - Order header fact table.
  - One row per invoice (`InvoiceNo`).
  - Linked to `customers` via `customer_id`.

- **order_items**
  - Order line fact table.
  - One row per `(InvoiceNo, StockCode)` combination.
  - Linked to `orders` and `products`.

## Relationships

- `customers (1) ──── (n) orders`
  - `orders.customer_id` → `customers.customer_id`

- `products (1) ──── (n) order_items`
  - `order_items.product_id` → `products.product_id`

- `orders (1) ──── (n) order_items`
  - `order_items.order_id` → `orders.order_id`

- `online_retail_raw` → `online_retail_clean` → `customers / products / orders / order_items`
  - `online_retail_raw` is the raw source.
  - `online_retail_clean` is the cleaned staging layer.
  - `customers`, `products`, `orders`, `order_items` form the analytical model.
 
    ```mermaid
erDiagram
    customers {
        int customer_id
        int external_customer_id
        string country
        timestamp created_at
    }

    products {
        int product_id
        string stock_code
        string product_name
        numeric unit_price
        timestamp created_at
    }

    orders {
        int order_id
        string invoice_no
        int customer_id
        timestamp order_date
        string order_status
        string country
        timestamp created_at
    }

    order_items {
        int order_item_id
        int order_id
        int product_id
        int quantity
        numeric unit_price
        numeric line_total
    }

    online_retail_raw {
        string InvoiceNo
        string StockCode
        string Description
        int Quantity
        string InvoiceDate
        numeric UnitPrice
        int CustomerID
        string Country
    }

    online_retail_clean {
        string invoiceno
        string stockcode
        string description
        int quantity
        string invoicedate
        timestamp order_timestamp
        numeric unitprice
        int customerid
        string country
    }

    customers ||--o{ orders : "places"
    orders ||--o{ order_items : "has"
    products ||--o{ order_items : "appears in"

    online_retail_raw ||--o{ online_retail_clean : "cleaned into"

