 CREATE OR REPLACE STAGE instacart_stage
  URL = 's3://dw-with-snowflake-hp/instacart/'
  CREDENTIALS = (
    AWS_KEY_ID = '**************'
    AWS_SECRET_KEY = '********xPw+MglSKjp6kTcG9Dd5J*****'
  );
  

CREATE OR REPLACE FILE FORMAT csv_file_format
  TYPE = 'CSV'
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  SKIP_HEADER = 1
  NULL_IF = ('NULL', 'null');


CREATE OR REPLACE TABLE aisles (
  aisle_id INTEGER PRIMARY KEY,
  aisle VARCHAR
);

COPY INTO aisles (aisle_id, aisle)
FROM @instacart_stage/aisles.csv
FILE_FORMAT = (FORMAT_NAME = 'csv_file_format');


CREATE OR REPLACE TABLE departments (
  department_id INTEGER PRIMARY KEY,
  department VARCHAR
);

COPY INTO departments (department_id, department)
FROM @instacart_stage/departments.csv
FILE_FORMAT = (FORMAT_NAME = 'csv_file_format');


CREATE OR REPLACE TABLE products (
  product_id INTEGER PRIMARY KEY,
  product_name VARCHAR,
  aisle_id INTEGER,
  department_id INTEGER
);

COPY INTO products (product_id, product_name, aisle_id, department_id)
FROM @instacart_stage/products.csv
FILE_FORMAT = (FORMAT_NAME = 'csv_file_format');


CREATE OR REPLACE TABLE orders (
  order_id INTEGER PRIMARY KEY,
  user_id INTEGER,
  eval_set VARCHAR,
  order_number INTEGER,
  order_dow INTEGER,
  order_hour_of_day INTEGER,
  days_since_prior_order INTEGER
);

COPY INTO orders (order_id, user_id, eval_set, order_number, order_dow, order_hour_of_day, days_since_prior_order)
FROM @instacart_stage/orders.csv
FILE_FORMAT = (FORMAT_NAME = 'csv_file_format');




CREATE OR REPLACE TABLE order_products (
  order_id INTEGER,
  product_id INTEGER,
  add_to_cart_order INTEGER,
  reordered INTEGER
);

COPY INTO order_products (order_id, product_id, add_to_cart_order, reordered)
FROM @instacart_stage/order_products.csv
FILE_FORMAT = (FORMAT_NAME = 'csv_file_format');

SELECT * FROM aisles;
SELECT * FROM departments;
SELECT* FROM products;
SELECt * FROM orders;
SELECT* FROM order_products;

CREATE OR REPLACE TABLE dim_users as (
  SELECT DISTINCT user_id
  FROM orders
);

CREATE OR REPLACE TABLE dim_products AS
SELECT DISTINCT
  product_id,
  product_name,
  aisle_id,          -- add this
  department_id      -- (optional but useful)
FROM products;


CREATE OR REPLACE TABLE dim_aisles as (
   SELECT DISTINCT aisle_id, aisle
   FROM  aisles
);

CREATE OR REPLACE TABLE dim_departments AS (
    SELECT DISTINCT department_id, department
    FROM departments
);

CREATE OR REPLACE TABLE dim_orders AS
SELECT DISTINCT
  order_id,
  user_id,                 -- add this
  order_number,
  order_dow,
  order_hour_of_day,
  days_since_prior_order
FROM orders;



CREATE OR REPLACE TABLE fact_order_products AS (
    SELECT
        op.order_id,
        op.product_id,
        o.user_id,
        p.department_id,
        p.aisle_id,
        op.add_to_cart_order,
        op.reordered
    FROM order_products op
    JOIN orders o
        ON op.order_id = o.order_id
    JOIN products p
        ON op.product_id = p.product_id
);



--Which 10 products have the highest reorder rate (percentage of times reordered), and what is their total order count?
-- Top 10 products by reorder rate (min 100 line-items to avoid tiny samples)
WITH prod_stats AS (
  SELECT
      p.product_id,
      p.product_name,
      COUNT(*)                                 AS line_items,         -- times the product appears in baskets
      COUNT(DISTINCT f.order_id)               AS total_orders,       -- number of distinct orders containing it
      COUNT_IF(f.reordered = 1)                AS reorder_count       -- times marked as reordered
  FROM fact_order_products f
  JOIN dim_products p
    ON p.product_id = f.product_id
  GROUP BY 1, 2
),
ranked AS (
  SELECT
      product_id,
      product_name,
      total_orders,
      line_items,
      reorder_count,
      reorder_count::FLOAT / NULLIF(line_items, 0) AS reorder_rate,
      ROW_NUMBER() OVER (
        ORDER BY (reorder_count::FLOAT / NULLIF(line_items, 0)) DESC,
                 line_items DESC
      ) AS rn
  FROM prod_stats
  WHERE line_items >= 100    -- <-- adjust threshold as you like
)
SELECT
  product_id,
  product_name,
  total_orders,
  line_items,
  reorder_count,
  ROUND(reorder_rate, 4) AS reorder_rate
FROM ranked
WHERE rn <= 10;

---Which departments have the highest total number of orders?

SELECT 
    d.department, 
    COUNT(*) AS total_orders
From  fact_order_products f 
JOIN dim_departments d ON d.department_id=f.department_id
group by d.department
order by total_orders DESC
lIMIT 10;

--2 Which aisles contain the most unique products?
SELECT
    d.department,
    COUNT(*) AS total_orders
FROM fact_order_products f
JOIN dim_departments d ON d.department_id = f.department_id
GROUP BY d.department
ORDER BY total_orders DESC
LIMIT 10;


--3 Which aisles contain the most unique products?

-- 3️⃣ Which aisles contain the most unique products?
SELECT
  a.aisle_id,
  a.aisle,
  COUNT(DISTINCT dp.product_id) AS unique_product_count
FROM dim_products dp
JOIN dim_aisles a
  ON dp.aisle_id = a.aisle_id
GROUP BY a.aisle_id, a.aisle
ORDER BY unique_product_count DESC
LIMIT 10;

--4️⃣ What are the busiest days of the week for orders?
SELECT
    order_dow AS day_of_week,
    COUNT(DISTINCT order_id) AS total_orders
FROM dim_orders
GROUP BY order_dow
ORDER BY total_orders DESC;

--5️⃣ What are the busiest hours of the day for orders?
SELECT
    order_hour_of_day AS hour,
    COUNT(DISTINCT order_id) AS total_orders
FROM dim_orders
GROUP BY order_hour_of_day
ORDER BY total_orders DESC;


--6️⃣ Which products appear most frequently in customer baskets?

SELECT
    p.product_name,
    COUNT(*) AS times_purchased
FROM fact_order_products f
JOIN dim_products p ON f.product_id = p.product_id
GROUP BY p.product_name
ORDER BY times_purchased DESC
LIMIT 10;

--7️⃣ What’s the average basket size (number of products per order)?
SELECT
    ROUND(AVG(product_count), 2) AS avg_basket_size
FROM (
    SELECT order_id, COUNT(product_id) AS product_count
    FROM fact_order_products
    GROUP BY order_id
);



--8️⃣ Which users place the most orders?
SELECT
  user_id,
  COUNT(DISTINCT order_id) AS total_orders
FROM dim_orders
GROUP BY user_id
ORDER BY total_orders DESC
LIMIT 10;


--9️⃣ Which departments have the highest reorder rate?
SELECT
    d.department,
    ROUND(COUNT_IF(f.reordered = 1) / COUNT(*), 3) AS reorder_rate
FROM fact_order_products f
JOIN dim_departments d ON f.department_id = d.department_id
GROUP BY d.department
ORDER BY reorder_rate DESC
LIMIT 10;


--🔟 What are the top 10 most popular product–department pairs?
SELECT
    d.department,
    p.product_name,
    COUNT(*) AS total_orders
FROM fact_order_products f
JOIN dim_products p ON f.product_id = p.product_id
JOIN dim_departments d ON f.department_id = d.department_id
GROUP BY d.department, p.product_name
ORDER BY total_orders DESC
LIMIT 10;








    

