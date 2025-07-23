CREATE DATABASE supply_chain;   -- creating Database

USE supply_chain;

-- Creating Table

CREATE TABLE shipment_data (
    ID INT,
    Warehouse_block VARCHAR(10),
    Mode_of_Shipment VARCHAR(50),
    Customer_care_calls INT,
    Customer_rating FLOAT,
    Cost_of_the_Product FLOAT,
    Prior_purchases INT,
    Product_importance VARCHAR(20),
    Gender VARCHAR(10),
    `Discount_offered%` FLOAT,
    Weight_in_gms INT,
    `Reached.on.Time_Y.N` INT,
    Final_Price FLOAT,
    Delivery_Status VARCHAR(20),
    Product_Tier VARCHAR(20),
    Shipment_Date DATE,
    `Discount_Amount` FLOAT
);

SELECT * FROM shipment_data LIMIT 10;

-- Total Orders

SELECT COUNT(*) AS total_orders
FROM supply_chain.shipment_data;

-- On Time Delivery Rate

SELECT 
  ROUND(SUM(CASE WHEN `Reached.on.Time_Y.N` = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS on_time_delivery_rate
FROM supply_chain.shipment_data;

-- Average Customer Rating

SELECT ROUND(AVG(Customer_rating), 2) AS avg_customer_rating
FROM supply_chain.shipment_data;

-- Total Sales

SELECT ROUND(SUM(Final_Price), 2) AS total_sales
FROM supply_chain.shipment_data;

-- Average Discount

SELECT ROUND(AVG(`Discount_offered%`), 2) AS avg_discount_percentage
FROM supply_chain.shipment_data;

-- Total Discount Given

SELECT ROUND(SUM(Discount_Amount), 2) AS total_discount_given
FROM supply_chain.shipment_data;

-- Average Discount Given Per Order

SELECT ROUND(AVG(Discount_Amount), 2) AS avg_discount_per_order
FROM supply_chain.shipment_data;

-- Total Orders and On-Time Delivery Rate

SELECT 
    COUNT(*) AS total_orders,
    ROUND(SUM(CASE WHEN `Reached.on.Time_Y.N` = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS on_time_delivery_rate
FROM shipment_data;

-- Monthly Shipment Volume

SELECT 
    DATE_FORMAT(Shipment_Date, '%Y-%m') AS shipment_month,
    COUNT(*) AS total_shipments
FROM shipment_data
WHERE Shipment_Date IS NOT NULL
GROUP BY shipment_month
ORDER BY shipment_month;

-- Average Customer Rating by Shipping Mode
SELECT 
    Mode_of_Shipment,
    ROUND(AVG(Customer_rating), 2) AS avg_rating
FROM shipment_data
GROUP BY Mode_of_Shipment;

-- Top 3 Warehouses with Most Late Deliveries

SELECT 
    Warehouse_block,
    COUNT(*) AS late_deliveries
FROM shipment_data
WHERE `Reached.on.Time_Y.N` = 0
GROUP BY Warehouse_block
ORDER BY late_deliveries DESC
LIMIT 3;

-- Average Discount And Final Price by Product Tier

SELECT 
    Product_Tier,
    ROUND(AVG(`Discount_offered%`), 2) AS avg_discount,
    ROUND(AVG(Final_Price), 2) AS avg_final_price
FROM shipment_data
GROUP BY Product_Tier;

-- Delivery Performance by Gender

SELECT 
    Gender,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN `Reached.on.Time_Y.N` = 1 THEN 1 ELSE 0 END) AS on_time_orders,
    ROUND(SUM(CASE WHEN `Reached.on.Time_Y.N` = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS on_time_percentage
FROM shipment_data
GROUP BY Gender;

-- Top 2 Shipment Modes by On-Time Delivery Rate
SELECT 
    Mode_of_Shipment,
    COUNT(*) AS total_shipments,
    SUM(CASE WHEN `Reached.on.Time_Y.N` = 1 THEN 1 ELSE 0 END) AS on_time_deliveries,
    ROUND(SUM(CASE WHEN `Reached.on.Time_Y.N` = 1 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS on_time_delivery_rate
FROM shipment_data
GROUP BY Mode_of_Shipment
ORDER BY on_time_delivery_rate DESC
LIMIT 2;

--  Warehouse Performance: On-Time Rate by Warehouse Block

SELECT 
    Warehouse_block,
    COUNT(*) AS total_orders,
    ROUND(SUM(CASE WHEN `Reached.on.Time_Y.N` = 1 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS on_time_delivery_rate
FROM shipment_data
GROUP BY Warehouse_block
ORDER BY on_time_delivery_rate DESC;

--  Customer Satisfaction by Product Importance

SELECT 
    Product_importance,
    ROUND(AVG(Customer_rating), 2) AS avg_rating,
    COUNT(*) AS total_orders
FROM shipment_data
GROUP BY Product_importance
ORDER BY avg_rating DESC;

-- High Discount Impact on Delay Probability

SELECT 
    CASE 
        WHEN `Discount_offered%` >= 20 THEN 'High Discount'
        WHEN `Discount_offered%` BETWEEN 10 AND 19.99 THEN 'Medium Discount'
        ELSE 'Low Discount'
    END AS discount_range,
    COUNT(*) AS total_orders,
    ROUND(SUM(CASE WHEN `Reached.on.Time_Y.N` = 2 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS delay_rate
FROM shipment_data
GROUP BY discount_range
ORDER BY delay_rate DESC;

--  Average Delivery Delay by Shipment Mode

SELECT 
    Mode_of_Shipment,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN `Reached.on.Time_Y.N` = 2 THEN 1 ELSE 0 END) AS delayed_orders,
    ROUND(SUM(CASE WHEN `Reached.on.Time_Y.N` = 2 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS delay_rate
FROM shipment_data
GROUP BY Mode_of_Shipment
ORDER BY delay_rate DESC;

-- Month-over-Month Change in On-Time Delivery Rate

SELECT 
    DATE_FORMAT(Shipment_date, '%Y-%m') AS month,
    ROUND(SUM(CASE WHEN `Reached.on.Time_Y.N` = 1 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS on_time_rate
FROM shipment_data
GROUP BY month
HAVING month IS NOT NULL
ORDER BY month;

-- Delay Rate by Product Category

SELECT 
    Product_importance,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN `Reached.on.Time_Y.N` = 1 THEN 1 ELSE 0 END) AS on_time_deliveries,
    ROUND(AVG(Cost_of_the_Product), 2) AS avg_cost,
    ROUND(
        100 * SUM(CASE WHEN `Reached.on.Time_Y.N` = 1 THEN 1 ELSE 0 END) / COUNT(*), 
        2
    ) AS on_time_rate
FROM shipment_data
GROUP BY Product_importance
ORDER BY FIELD(Product_importance, 'high', 'medium', 'low');

-- Delivery Performance by Product Tier

SELECT 
    Product_Tier,
    COUNT(*) AS total_orders,
    ROUND(AVG(`Final_Price`), 2) AS avg_final_price,
    ROUND(AVG(`Discount_offered%`), 2) AS avg_discount,
    ROUND(
        100 * SUM(CASE WHEN `Reached.on.Time_Y.N` = 1 THEN 1 ELSE 0 END) / COUNT(*), 
        2
    ) AS on_time_delivery_rate
FROM shipment_data
GROUP BY Product_Tier
ORDER BY Product_Tier;

-- Warehouse Block Performance Analysis

SELECT 
    Warehouse_block,
    COUNT(*) AS total_orders,
    ROUND(AVG(`Cost_of_the_Product`), 2) AS avg_cost,
    ROUND(AVG(`Discount_offered%`), 2) AS avg_discount,
    ROUND(
        100 * SUM(CASE WHEN `Reached.on.Time_Y.N` = 1 THEN 1 ELSE 0 END) / COUNT(*), 
        2
    ) AS on_time_rate
FROM shipment_data
GROUP BY Warehouse_block
ORDER BY on_time_rate ASC;

-- Monthly Sales Trends

SELECT 
    DATE_FORMAT(Shipment_Date, '%Y-%m') AS month,
    ROUND(SUM(Cost_of_the_Product * (1 - 'Discount_offered%')), 2) AS net_sales
FROM shipment_data
GROUP BY month
ORDER BY month;

-- Monthly unhappy customers 

SELECT 
    DATE_FORMAT(Shipment_Date, '%Y-%m') AS month,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN Customer_rating = 1 THEN 1 ELSE 0 END) AS dissatisfied_orders,
    ROUND(SUM(CASE WHEN Customer_rating = 1 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS dissatisfaction_rate
FROM shipment_data
GROUP BY month
ORDER BY month;

-- Customers Ratings Per Month

SELECT  
    DATE_FORMAT(Shipment_Date, '%Y-%m') AS month,
    COUNT(*) AS total_orders,
    COUNT(CASE WHEN Customer_rating = 1 THEN 1 END) AS rating_1,
    COUNT(CASE WHEN Customer_rating = 2 THEN 1 END) AS rating_2,
    COUNT(CASE WHEN Customer_rating = 3 THEN 1 END) AS rating_3,
    COUNT(CASE WHEN Customer_rating = 4 THEN 1 END) AS rating_4,
    COUNT(CASE WHEN Customer_rating = 5 THEN 1 END) AS rating_5
FROM shipment_data
GROUP BY month
ORDER BY month;

-- Query to Generate the Temporal Insights Table

SELECT
    DATE_FORMAT(Shipment_Date, '%Y-%m') AS Month,
    COUNT(*) AS Total_Orders,
    ROUND(100 * SUM(CASE WHEN `Reached.on.Time_Y.N` = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS On_Time_Delivery_Rate,
    ROUND(AVG(Customer_rating), 2) AS Avg_Customer_Rating,
    ROUND(AVG(`Discount_offered%`), 2) AS Avg_Discount_Offered,
    ROUND(SUM(Final_Price), 2) AS Total_Sales
FROM
    shipment_data
GROUP BY
    DATE_FORMAT(Shipment_Date, '%Y-%m')
ORDER BY
    Month;