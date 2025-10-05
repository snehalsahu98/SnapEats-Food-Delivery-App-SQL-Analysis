-- SnapEats Data Analysis
-- Database Schema Definition
-- --------------------------------------------------

-- Customers Table
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(55),
    reg_date DATE
);

-- Restaurants Table
CREATE TABLE restaurants (
    restaurant_id INT PRIMARY KEY,
    restaurant_name VARCHAR(55),
    city VARCHAR(25),
    opening_hours VARCHAR(55)
);

-- Orders Table
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    restaurant_id INT,
    order_item VARCHAR(55),
    order_date DATE,
    order_time TIME,
    order_status VARCHAR(55),
    total_amount FLOAT,
    CONSTRAINT fk_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT fk_restaurant FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)
);

-- Riders Table
CREATE TABLE riders (
    rider_id INT PRIMARY KEY,
    rider_name VARCHAR(55),
    sign_up DATE
);

-- Deliveries Table
CREATE TABLE deliveries (
    delivery_id INT PRIMARY KEY,
    order_id INT,
    delivery_status VARCHAR(35),
    delivery_time TIME,
    rider_id INT,
    CONSTRAINT fk_order FOREIGN KEY (order_id) REFERENCES orders(order_id),
    CONSTRAINT fk_rider FOREIGN KEY (rider_id) REFERENCES riders(rider_id)
);

-- --------------------------------------------------
-- End of Schema
-- --------------------------------------------------
