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


