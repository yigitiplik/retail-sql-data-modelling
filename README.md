# Retail SQL Data Modelling & KPI Analysis

This project demonstrates how to build a fully normalized SQL data model from the UCI Online Retail Dataset, perform ETL processing, and prepare the database for analytical KPI queries.

The workflow covers:

* Database schema design
* Data cleaning (staging → curated dataset)
* Building a retail star-schema
* Loading normalized dimension and fact tables

Preparing analytical SQL (KPIs)

# Project Structure
'''
retail-sql-data-modelling/
├─ data/
│   └─ Online_Retail.zip               # Sample dataset (optional)
├─ sql/
│   ├─ schema.sql                      # All table definitions
│   ├─ etl_online_retail.sql           # 5-step ETL pipeline
│   ├─ kpi_total_revenue.sql
│   ├─ kpi_average_order_value.sql
│   ├─ kpi_repeat_purchase_rate.sql
│   ├─ kpi_revenue_by_country.sql
│   ├─ kpi_monthly_product_performance.sql
│   └─ kpi_top_customers.sql
└─ README.md
'''

# Dataset

This project uses the well-known Online Retail Dataset (UCI ML Repository).

## Dataset link:
https://archive.ics.uci.edu/dataset/502/online+retail+ii

A CSV-compatible version of the dataset is provided here:
/data/Online_Retail.zip

# 1. Database Schema

All table structures are defined in:

'''
sql/schema.sql
'''

It contains:

* online_retail_raw → raw CSV landing table
* online_retail_clean → cleaned staging area
* customers → customer dimension
* products → product dimension
* orders → order header fact
* order_items → order line fact

The schema also includes sample commented COPY command:
'''
-- COPY online_retail_raw
-- FROM 'C:\\path\\to\\online_retail_raw.csv'
-- DELIMITER ','
-- CSV HEADER;
'''

# 2. ETL Process (5 Steps)

The full ETL pipeline is found in:

sql/etl_online_retail.sql


It performs:

STEP 1 — Clean raw data

Remove cancelled invoices

Remove returns (negative quantities)

Remove missing customer IDs

Remove invalid prices

Parse invoice timestamp

STEP 2 — Build customers dimension

1 row per CustomerID.

STEP 3 — Build products dimension

1 row per StockCode, with:

most frequent unit price

product name

STEP 4 — Build orders fact

1 row per InvoiceNo.

STEP 5 — Build order_items fact

Aggregates line items per invoice + product.

After running ETL, row counts look like:

Table	Approx Count
online_retail_clean	~390k rows
customers	~4,300 rows
products	~3,600 rows
orders	~18,500 rows
order_items	~380,000 rows

# 3. KPI SQL Queries

Individual KPI queries are stored under /sql:

* kpi_total_revenue.sql
* kpi_average_order_value.sql
* kpi_repeat_purchase_rate.sql
* kpi_revenue_by_country.sql
* kpi_monthly_product_performance.sql
* kpi_top_customers.sql

These KPIs include:

* Total Revenue
* Average Order Value (AOV)
* Repeat Purchase Rate
* Revenue by Country
* Monthly Product Performance
* Top Customers by Spend

# 4. How to Run the Project
## 1. Create database
'''
CREATE DATABASE retail_db;
'''

## 2. Run schema

Open pgAdmin → retail_db → Query Tool → run:

'''
sql/schema.sql
'''

## 3. Import dataset into online_retail_raw

Use pgAdmin → Import/Export (recommended),
or update and run COPY command in schema file.

## 4. Run the ETL

Execute:

'''
sql/etl_online_retail.sql
'''

## 5. Run KPI queries

Each KPI is in the /sql folder.


# 5. Business Value

This project demonstrates:

* SQL data modeling best practices
* How to normalize transactional data
* How to build reusable analytics layers
* How to calculate meaningful retail metrics
