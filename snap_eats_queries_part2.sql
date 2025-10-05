-- SnapEats SQL Analysis
-- Part 2: Advanced Performance Analysis
-- -----------------------------------------------

-- Q11. Monthly Restaurant Growth Ratio

WITH growth_ratio AS (
    SELECT 
        o.restaurant_id,
        TO_CHAR(o.order_date, 'MM-YY') AS month,
        COUNT(o.order_id) AS current_month_orders,
        LAG(COUNT(o.order_id), 1) OVER (PARTITION BY o.restaurant_id ORDER BY TO_CHAR(o.order_date, 'MM-YY')) AS previous_month_orders
    FROM orders o
    JOIN deliveries d ON o.order_id = d.order_id
    WHERE d.delivery_status = 'Delivered'
    GROUP BY 1, 2
)
SELECT 
    restaurant_id, 
    month,
    previous_month_orders,
    current_month_orders,
    ROUND((current_month_orders::NUMERIC - previous_month_orders::NUMERIC) / previous_month_orders::NUMERIC * 100, 2) AS growth_ratio
FROM growth_ratio;


-- Q12. Customer Segmentation (Gold / Silver)

SELECT 
    cx_cat, 
    SUM(total_orders) AS total_orders, 
    SUM(total_spent) AS total_revenue
FROM (
    SELECT 
        customer_id, 
        SUM(total_amount) AS total_spent, 
        COUNT(order_id) AS total_orders,
        CASE 
            WHEN AVG(total_amount) > (SELECT AVG(total_amount) FROM orders) THEN 'Gold'
            ELSE 'Silver'
        END AS cx_cat
    FROM orders
    GROUP BY 1
) t1
GROUP BY 1;


-- Q13. Rider Monthly Earnings (8% of Order Amount)

SELECT 
    d.rider_id, 
    TO_CHAR(o.order_date, 'MM-YY') AS month,
    SUM(total_amount) AS total_revenue,
    ROUND(SUM(total_amount::NUMERIC) * 0.08, 2) AS rider_earnings
FROM orders o
JOIN deliveries d ON o.order_id = d.order_id
GROUP BY 1, 2
ORDER BY 1, 2;


-- Q14. Rider Rating Analysis

SELECT rider_id, stars, COUNT(stars) AS total_ratings
FROM (
    SELECT 
        rider_id,
        CASE 
            WHEN delivery_time_minutes < 15 THEN '5 Star'
            WHEN delivery_time_minutes BETWEEN 15 AND 20 THEN '4 Star'
            ELSE '3 Star'
        END AS stars
    FROM (
        SELECT 
            d.rider_id,
            EXTRACT(EPOCH FROM (d.delivery_time - o.order_time + 
            CASE WHEN d.delivery_time < o.order_time THEN INTERVAL '1 day' ELSE INTERVAL '0 day' END)) / 60 AS delivery_time_minutes
        FROM orders o
        JOIN deliveries d ON o.order_id = d.order_id
        WHERE delivery_status = 'Delivered'
    ) t1
) t2
GROUP BY 1, 2
ORDER BY 1, 2 DESC;


-- Q15. Order Frequency by Day

SELECT restaurant_name, day_of_week, total_orders
FROM (
    SELECT 
        r.restaurant_name,
        TO_CHAR(o.order_date, 'Day') AS day_of_week,
        COUNT(o.order_id) AS total_orders,
        RANK() OVER (PARTITION BY r.restaurant_name ORDER BY COUNT(o.order_id) DESC) AS rank
    FROM orders o
    JOIN restaurants r ON o.restaurant_id = r.restaurant_id
    GROUP BY 1, 2
) t1
WHERE rank = 1;


-- Q16. Customer Lifetime Value (CLV)

SELECT 
    o.customer_id, 
    c.customer_name, 
    SUM(o.total_amount) AS clv
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY 1, 2
ORDER BY clv DESC;


-- Q17. Monthly Sales Trends

SELECT 
    year, 
    month, 
    total_sales,
    ROUND((total_sales::NUMERIC - prev_month_sales::NUMERIC) / prev_month_sales::NUMERIC * 100, 2) AS growth_ratio
FROM (
    SELECT 
        EXTRACT(YEAR FROM order_date) AS year,
        EXTRACT(MONTH FROM order_date) AS month,
        SUM(total_amount) AS total_sales,
        LAG(SUM(total_amount)) OVER (ORDER BY EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date)) AS prev_month_sales
    FROM orders
    GROUP BY 1, 2
) t1;


-- Q18. Rider Efficiency

WITH delivery_data AS (
    SELECT 
        d.rider_id,
        EXTRACT(EPOCH FROM (d.delivery_time - o.order_time + 
        CASE WHEN d.delivery_time < o.order_time THEN INTERVAL '1 day' ELSE INTERVAL '0 day' END)) / 60 AS delivery_time
    FROM orders o
    JOIN deliveries d ON o.order_id = d.order_id
    WHERE d.delivery_status = 'Delivered'
),
rider_avg AS (
    SELECT rider_id, ROUND(AVG(delivery_time), 2) AS avg_time
    FROM delivery_data
    GROUP BY 1
)
SELECT * 
FROM (
    SELECT *, RANK() OVER (ORDER BY avg_time) AS rank
    FROM rider_avg
) ranked
WHERE rank = 1 OR rank = (SELECT MAX(rank) FROM ranked);


-- Q19. Order Item Popularity by Season

SELECT * FROM (
    SELECT 
        season, 
        order_item, 
        SUM(total_orders) AS total_orders,
        RANK() OVER (PARTITION BY order_item ORDER BY SUM(total_orders) DESC) AS rank
    FROM (
        SELECT 
            CASE 
                WHEN month BETWEEN 1 AND 3 THEN 'Winter'
                WHEN month BETWEEN 4 AND 6 THEN 'Spring'
                WHEN month BETWEEN 7 AND 9 THEN 'Summer'
                WHEN month BETWEEN 10 AND 12 THEN 'Autumn'
            END AS season,
            order_item,
            COUNT(order_item) AS total_orders
        FROM (
            SELECT 
                order_item,
                EXTRACT(MONTH FROM order_date) AS month
            FROM orders
        ) sub
        GROUP BY 1, 2
    ) t1
    GROUP BY 1, 2
) final
WHERE rank = 1
ORDER BY order_item;


-- Q20. City Revenue Ranking (2023)

SELECT 
    r.city,
    SUM(total_amount) AS total_revenue,
    RANK() OVER (ORDER BY SUM(total_amount) DESC) AS city_rank
FROM orders o
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
WHERE EXTRACT(YEAR FROM order_date) = 2023
GROUP BY 1
ORDER BY city_rank;


-- -----------------------------------------------
-- End of Part 2
-- -----------------------------------------------
