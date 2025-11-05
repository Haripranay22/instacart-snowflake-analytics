# 🧊 Instacart Snowflake Analytics Project  

A complete **data warehousing and analytics project** built on **Snowflake** using the **Instacart Online Grocery dataset**.  
This project demonstrates how to design a scalable **data pipeline**, build a **star schema**, and perform **SQL analytics** to extract real-world business insights.  

---

## 📘 Table of Contents  

1. [Project Overview](#project-overview)  
2. [Objectives](#objectives)  
3. [Dataset Description](#dataset-description)  
4. [Project Architecture](#project-architecture)  
5. [Project Stages](#project-stages)  
   - [Stage 1: Data Staging](#stage-1-data-staging)  
   - [Stage 2: Data Loading](#stage-2-data-loading)  
   - [Stage 3: Data Modeling (Star Schema)](#stage-3-data-modeling-star-schema)  
   - [Stage 4: Analytics & Insights](#stage-4-analytics--insights)  
6. [Sample Queries](#sample-queries)  
7. [Project Structure](#project-structure)  
8. [Tech Stack](#tech-stack)  
9. [How to Run](#how-to-run)  
10. [Future Improvements](#future-improvements)  
11. [Author](#author)  

---

## 🧩 Project Overview  

This project simulates a **real-world e-commerce analytics workflow** using the popular **Instacart dataset**.  
You’ll see how raw CSV files are ingested from **Amazon S3**, modeled in **Snowflake**, and transformed into a **clean star schema** ready for analytics.  

---

## 🎯 Objectives  

- Build a **data warehouse** in Snowflake from raw CSV data.  
- Implement a **star schema** with one fact and multiple dimension tables.  
- Run **SQL analytics** to uncover actionable business insights.  
- Showcase **data engineering & analytics skills** for portfolio demonstration.  

---

## 📦 Dataset Description  

| Table | Description | Key Columns |
|--------|--------------|-------------|
| `aisles` | Store aisle list | `aisle_id`, `aisle` |
| `departments` | Department list | `department_id`, `department` |
| `products` | Product catalog | `product_id`, `product_name`, `aisle_id`, `department_id` |
| `orders` | Customer order metadata | `order_id`, `user_id`, `order_dow`, `order_hour_of_day` |
| `order_products` | Product-order relationships | `order_id`, `product_id`, `add_to_cart_order`, `reordered` |

---

## 🏗️ Project Architecture  
Amazon S3 → Snowflake Stage → Raw Tables → Star Schema → Analytics


1. **Data Source**: CSV files stored in S3.  
2. **Staging Layer**: External stage in Snowflake to connect with S3.  
3. **Storage Layer**: Raw tables created via `COPY INTO`.  
4. **Model Layer**: Fact & dimension tables for analytics.  
5. **Analytics Layer**: SQL queries for KPIs and business insights.

## 🧱 Project Stages  

### 🔹 Stage 1: Data Staging  

Create an **external stage** in Snowflake to connect to S3.  

```sql
CREATE OR REPLACE STAGE instacart_stage
  URL = 's3://dw-with-snowflake-hp/instacart/'
  STORAGE_INTEGRATION = s3_instacart_int;

CREATE OR REPLACE FILE FORMAT csv_file_format
  TYPE = 'CSV'
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  SKIP_HEADER = 1
  NULL_IF = ('NULL', 'null');

### 🔹 Stage 2: Data Loading
CREATE OR REPLACE TABLE products (
  product_id INTEGER,
  product_name VARCHAR,
  aisle_id INTEGER,
  department_id INTEGER
);

COPY INTO products (product_id, product_name, aisle_id, department_id)
FROM @instacart_stage/products.csv
FILE_FORMAT = (FORMAT_NAME = 'csv_file_format');

### 🔹 Stage 3: Data Modeling (Star Schema)

Transform raw data into a star schema for analytics.

Dimension Tables

dim_users

dim_products

dim_aisles

dim_departments

dim_orders

Fact Table

fact_order_products

### 🔹 Stage 4: Analytics & Insights

Perform moderate-level business analytics using SQL.

#	Analytical Question	Business Purpose
1	Which products have the highest reorder rate?	Product loyalty
2	Which departments have the most total orders?	Department performance
3	Which aisles have the most unique products?	Product variety
4	What are the busiest days of the week for orders?	Customer demand pattern
5	What are the peak order hours?	Time-based behavior
6	Which products appear most frequently in baskets?	Popular products
7	What is the average basket size?	Order behavior
8	Which users place the most orders?	Top customers
9	Which departments have the highest reorder rate?	Customer retention by department
10	Which product-department pairs dominate sales?	Category performance
