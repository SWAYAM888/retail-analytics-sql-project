CREATE DATABASE retail_analytics;

USE retail_analytics;

## Create Tables
##  Sales Transaction Table

CREATE TABLE sales_transaction (
    transaction_id INT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    quantity_purchased INT,
    transaction_date DATE,
    price DECIMAL(10,2)
);

## Customer Profiles Table

CREATE TABLE customer_profiles (
    customer_id INT PRIMARY KEY,
    age INT,
    gender VARCHAR(20),
    location VARCHAR(100),
    join_date DATE
);

## Product Inventory Table

CREATE TABLE product_inventory (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(255),
    category VARCHAR(100),
    stock_level INT,
    price DECIMAL(10,2)
);

## Import CSV Files

## Verify Data Imported

## Check Sales Data
SELECT * FROM sales_transaction
LIMIT 10;

## Check Customer Data
SELECT * FROM customer_profiles
LIMIT 10;

## Check Product Data
SELECT * FROM product_inventory
LIMIT 10;

## Data Cleaning
## Check NULL Values 

SELECT *
FROM sales_transaction
WHERE customer_id IS NULL
   OR product_id IS NULL;
   
## Check Duplicate Transactions
SELECT transaction_id,
       COUNT(*) AS duplicate_count
FROM sales_transaction
GROUP BY transaction_id
HAVING COUNT(*) > 1;

## Remove Duplicate Records
DELETE FROM sales_transaction
WHERE transaction_id IN (
    SELECT transaction_id
    FROM (
        SELECT transaction_id,
               ROW_NUMBER() OVER(
               PARTITION BY transaction_id
               ORDER BY transaction_id) AS rn
        FROM sales_transaction
    ) t
    WHERE rn > 1
);

## Exploratory Data Analysis (EDA)

## Total Revenue

SELECT ROUND(SUM(quantity_purchased * price),2)
AS total_revenue
FROM sales_transaction;

## Total Orders

SELECT COUNT(DISTINCT transaction_id)
AS total_orders
FROM sales_transaction;

## Total Customers

SELECT COUNT(DISTINCT customer_id)
AS total_customers
FROM customer_profiles;

## Montly Sales Trend

SELECT MONTH(transaction_date) AS month,
       ROUND(SUM(quantity_purchased * price),2)
       AS monthly_sales
FROM sales_transaction
GROUP BY MONTH(transaction_date)
ORDER BY month;

## Product Performance Analysis
## Top 10 Best-Selling Products

SELECT p.product_name,
       SUM(s.quantity_purchased)
       AS total_quantity_sold,

       ROUND(SUM(s.quantity_purchased * s.price),2)
       AS revenue

FROM sales_transaction s

JOIN product_inventory p
ON s.product_id = p.product_id

GROUP BY p.product_name

ORDER BY revenue DESC

LIMIT 10;

## Low Performing Products

SELECT p.product_name,
       SUM(s.quantity_purchased)
       AS total_quantity_sold

FROM sales_transaction s

JOIN product_inventory p
ON s.product_id = p.product_id

GROUP BY p.product_name

ORDER BY total_quantity_sold ASC

LIMIT 10;

## Revenue by Category

SELECT p.category,

       ROUND(SUM(s.quantity_purchased * s.price),2)
       AS total_revenue

FROM sales_transaction s

JOIN product_inventory p
ON s.product_id = p.product_id

GROUP BY p.category

ORDER BY total_revenue DESC;

## Customer Segmentation

SELECT customer_id,

       SUM(quantity_purchased)
       AS total_quantity,

       CASE

           WHEN SUM(quantity_purchased) = 0
           THEN 'No Orders'

           WHEN SUM(quantity_purchased)
           BETWEEN 1 AND 10
           THEN 'Low'

           WHEN SUM(quantity_purchased)
           BETWEEN 11 AND 30
           THEN 'Mid'

           ELSE 'High Value'

       END AS customer_segment

FROM sales_transaction

GROUP BY customer_id;

## Customer Behaviour Analysis
## Repeat Customers

SELECT customer_id,

       COUNT(transaction_id)
       AS total_orders

FROM sales_transaction

GROUP BY customer_id

HAVING COUNT(transaction_id) > 1

ORDER BY total_orders DESC;

## Average Purchase Value

SELECT customer_id,

       ROUND(AVG(quantity_purchased * price),2)
       AS avg_purchase_value

FROM sales_transaction

GROUP BY customer_id

ORDER BY avg_purchase_value DESC;

## Average Purchase Value

SELECT customer_id,

       ROUND(AVG(quantity_purchased * price),2)
       AS avg_purchase_value

FROM sales_transaction

GROUP BY customer_id

ORDER BY avg_purchase_value DESC;

## Most Active Customers

SELECT customer_id,

       SUM(quantity_purchased)
       AS total_products_purchased

FROM sales_transaction

GROUP BY customer_id

ORDER BY total_products_purchased DESC

LIMIT 10;

## Inventory Analysis
## Low Stock Products

SELECT product_name,
       stock_level

FROM product_inventory

WHERE stock_level < 20

ORDER BY stock_level ASC;

## Overstock Products

SELECT product_name,
       stock_level

FROM product_inventory

WHERE stock_level > 500

ORDER BY stock_level DESC;

## Top Customers by Revenue

SELECT customer_id,

       ROUND(SUM(quantity_purchased * price),2)
       AS total_spent

FROM sales_transaction

GROUP BY customer_id

ORDER BY total_spent DESC

LIMIT 10;

## Customer Lifetime Value (CLV)
SELECT customer_id,

       COUNT(transaction_id)
       AS total_orders,

       ROUND(SUM(quantity_purchased * price),2)
       AS lifetime_value

FROM sales_transaction

GROUP BY customer_id

ORDER BY lifetime_value DESC;

## Sales by Location

SELECT c.location,

       ROUND(SUM(s.quantity_purchased * s.price),2)
       AS total_sales

FROM sales_transaction s

JOIN customer_profiles c
ON s.customer_id = c.customer_id

GROUP BY c.location

ORDER BY total_sales DESC;