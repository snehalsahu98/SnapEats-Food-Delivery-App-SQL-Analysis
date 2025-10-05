-- SnapEats SQL Analysis
-- Part 1: Data Exploration & Core Business Analysis
-- -----------------------------------------------

-- Preview Data
SELECT * FROM customers;
SELECT * FROM restaurants;
SELECT * FROM orders;
SELECT * FROM riders;
SELECT * FROM deliveries;

-- Check for Missing Values
SELECT * FROM customers
WHERE customer_name IS NULL OR reg_date IS NULL;

-- Handle Missing Values
INSERT INTO customers (customer_id)
VALUES (38), (65), (93);

DELETE FROM customers
WHERE customer_name IS NULL OR reg_date IS NULL;


-- -----------------------------------------------
-- Q1. Most Favored Dishes by a Customer
-- -----------------------------------------------
-- Find top 5 most ordered dishes by customer 'Arjun Mehta' in the last 1 year.

SELECT customer_name, dishes, total_orders 
FROM (
    SELECT 
        c.customer_id, 
        c.customer_name, 
        o.order_item AS dishes, 
        COUNT(*) AS total_orders,
        DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS rank
    FROM orders o
    JOIN customers c ON c.customer_id = o.customer_id
    WHERE 
        order_date >= '2023-06-01' 
        AND order_date < '2024-06-01'
        AND customer_name = 'Arjun Mehta'
    GROUP BY 1, 2, 3
    ORDER BY 4 DESC
) t1
WHERE rank <= 5;


-- -----------------------------------------------
-- Q2. Popular Time Slots
-- -----------------------------------------------
-- Identify two-hour time intervals with the highest order volume.

SELECT 
    CASE
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 0 AND 1 THEN '00:00 - 02:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 2 AND 3 THEN '02:00 - 04:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 4 AND 5 THEN '04:00 - 06:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 6 AND 7 THEN '06:00 - 08:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 8 AND 9 THEN '08:00 - 10:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 10 AND 11 THEN '10:00 - 12:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 12 AND 13 THEN '12:00 - 14:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 14 AND 15 THEN '14:00 - 16:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 16 AND 17 THEN '16:00 - 18:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 18 AND 19 THEN '18:00 - 20:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 20 AND 21 THEN '20:00 - 22:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 22 AND 23 THEN '22:00 - 00:00'
    END AS time_slot,
    COUNT(order_id) AS order_count
FROM orders
GROUP BY 1
ORDER BY order_count DESC;


-- -----------------------------------------------
-- Q3. Average Order Value (AOV)
-- -----------------------------------------------
-- Find customers with more than 750 total orders.

SELECT customer_name, AVG(o.total_amount) AS aov, COUNT(*) AS total_orders
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY 1
HAVING COUNT(*) > 750
ORDER BY total_orders DESC;


-- -----------------------------------------------
-- Q4. High-Value Customers
-- -----------------------------------------------
-- List customers who have spent more than 100K in total.

SELECT c.customer_name, SUM(o.total_amount) AS total_revenue
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
GROUP BY 1
HAVING SUM(o.total_amount) > 100000
ORDER BY total_revenue DESC;


-- -----------------------------------------------
-- Q5. Orders Without Delivery
-- -----------------------------------------------

SELECT r.restaurant_name, r.city, COUNT(*) AS undelivered_orders
FROM orders o
LEFT JOIN restaurants r ON r.restaurant_id = o.restaurant_id
LEFT JOIN deliveries d ON d.order_id = o.order_id
WHERE d.delivery_id IS NULL
GROUP BY 1, 2
ORDER BY undelivered_orders DESC;


-- -----------------------------------------------
-- Q6. Restaurant Revenue Ranking
-- -----------------------------------------------

-- City-wise ranking
SELECT 
    r.city,
    r.restaurant_name,
    SUM(o.total_amount) AS revenue,
    RANK() OVER (PARTITION BY r.city ORDER BY SUM(o.total_amount) DESC) AS rank
FROM orders o
JOIN restaurants r ON r.restaurant_id = o.restaurant_id
GROUP BY 1, 2
ORDER BY 1, 3 DESC;

-- Global ranking
SELECT 
    r.city,
    r.restaurant_name,
    SUM(o.total_amount) AS revenue,
    RANK() OVER (ORDER BY SUM(o.total_amount) DESC) AS rank
FROM orders o
JOIN restaurants r ON r.restaurant_id = o.restaurant_id
GROUP BY 1, 2
ORDER BY 3 DESC;


-- -----------------------------------------------
-- Q7. Most Popular Dish by City
-- -----------------------------------------------

SELECT r.city, o.order_item AS dish, COUNT(order_id) AS total_orders
FROM orders o
JOIN restaurants r ON r.restaurant_id = o.restaurant_id
GROUP BY 1, 2
ORDER BY 1, 3 DESC;


-- -----------------------------------------------
-- Q8. Customer Churn
-- -----------------------------------------------

SELECT DISTINCT customer_id
FROM orders 
WHERE 
    EXTRACT(YEAR FROM order_date) = 2023
    AND customer_id NOT IN (
        SELECT DISTINCT customer_id 
        FROM orders 
        WHERE EXTRACT(YEAR FROM order_date) = 2024
    );


-- -----------------------------------------------
-- Q9. Cancellation Rate Comparison (2023 vs 2024)
-- -----------------------------------------------

WITH cancel_2023 AS (
    SELECT 
        o.restaurant_id,
        COUNT(o.order_id) AS total_orders,
        COUNT(CASE WHEN d.delivery_id IS NULL THEN 1 END) AS not_delivered
    FROM orders o
    LEFT JOIN deliveries d ON o.order_id = d.order_id
    WHERE EXTRACT(YEAR FROM order_date) = 2023
    GROUP BY 1
),
cancel_2024 AS (
    SELECT 
        o.restaurant_id,
        COUNT(o.order_id) AS total_orders,
        COUNT(CASE WHEN d.delivery_id IS NULL THEN 1 END) AS not_delivered
    FROM orders o
    LEFT JOIN deliveries d ON o.order_id = d.order_id
    WHERE EXTRACT(YEAR FROM order_date) = 2024
    GROUP BY 1
)
SELECT 
    c24.restaurant_id,
    ROUND(c24.not_delivered::NUMERIC / c24.total_orders * 100, 2) AS cancel_rate_2024,
    ROUND(c23.not_delivered::NUMERIC / c23.total_orders * 100, 2) AS cancel_rate_2023
FROM cancel_2024 c24
JOIN cancel_2023 c23 ON c24.restaurant_id = c23.restaurant_id;


-- -----------------------------------------------
-- Q10. Rider Average Delivery Time
-- -----------------------------------------------

WITH rider_avg AS (
    SELECT 
        d.rider_id,
        EXTRACT(EPOCH FROM (d.delivery_time - o.order_time + 
        CASE WHEN d.delivery_time < o.order_time THEN INTERVAL '1 day' ELSE INTERVAL '0 day' END)) / 60 AS delivery_minutes
    FROM orders o
    JOIN deliveries d ON o.order_id = d.order_id
    WHERE d.delivery_status = 'Delivered'
)
SELECT rider_id, ROUND(AVG(delivery_minutes), 2) AS avg_delivery_time
FROM rider_avg
GROUP BY 1
ORDER BY 1;

-- -----------------------------------------------
-- End of Part 1
-- -----------------------------------------------