select top 10 * from dbo.order_details;

select top 10 * from dbo.orders;

select top 10 * from dbo.pizza_types;

select top 10 * from dbo.pizzas;

------------------------------------------------------------------------------------------------------------------------
----------------------- Q1. Total Order, Quantity, Sales, Average Sales and Quantity per Order -------------------------
------------------------------------------------------------------------------------------------------------------------

-- 1a. Total Order
SELECT COUNT(DISTINCT dbo.order_details.order_id) AS Total_orders FROM dbo.order_details;

-- 1b. Total Sales
SELECT SUM(od.quantity * p.price) AS Total_Sales
FROM dbo.order_details AS od 
INNER JOIN dbo.pizzas AS p ON od.pizza_id = p.pizza_id;

-- 1c. Average Sales per Order
SELECT SUM(od.quantity * p.price)/ COUNT(DISTINCT od.order_id) AS Average_Sales_perOrder
FROM dbo.order_details AS od 
INNER JOIN dbo.pizzas AS p ON od.pizza_id = p.pizza_id;

-- 1d. Total Pizzas Sold
SELECT SUM(dbo.order_details.quantity) AS Total_Pizza_Sold FROM dbo.order_details;

-- 1e. Average Pizza Sold per Order
SELECT CAST((CAST(SUM(dbo.order_details.quantity) AS DECIMAL(10, 2)) / 
COUNT(DISTINCT dbo.order_details.order_id)) AS decimal (10, 2)) AS Average_Pizza_Sold_perOrder FROM dbo.order_details;

------------------------------------------------------------------------------------------------------------------------
------------------ Q2. Subtotal Order, Quantity, Sales, Peak by Month, Quarter, Week, Weekday, Hour --------------------
------------------------------------------------------------------------------------------------------------------------
-------------------------------- Peak period: Subtotal Sales >= Q3(Upper Quartile)--------------------------------------
------------------------------------------------------------------------------------------------------------------------

GO

-- Create a view, calender_time, which is a detailed version of dbo.orders explicitly indicating year, month, quarter, week, weekday, hour, etc.

CREATE VIEW calender_time AS
SELECT 
    orders.order_id, 
    orders.[date], 
    DATEPART(YEAR, orders.[date]) AS yyyy,
    DATEPART(MONTH, orders.[date]) AS mm,
    DATEPART(QUARTER, orders.[date]) AS qq,
    DATEPART(WEEK, orders.[date]) AS ww,
    DATEPART(WEEKDAY, orders.[date]) AS wday,
    orders.[time],
    DATEPART(HOUR, orders.[time]) AS hh,
    CASE
        WHEN DATEPART(HOUR, orders.[time]) >= 5 AND DATEPART(HOUR, orders.[time]) < 12 THEN 'morning'
        WHEN DATEPART(HOUR, orders.[time]) >= 12 AND DATEPART(HOUR, orders.[time]) < 18 THEN 'afternoon'
        WHEN DATEPART(HOUR, orders.[time]) >= 18 THEN 'evening'
    END AS timerange
FROM dbo.orders

GO

-- 2a. Subtotal Order, Quantity, Sales vs Month 

SELECT 
    ct.mm, 
    COUNT(DISTINCT od.order_id) AS Subtotal_Order, 
    SUM(od.quantity) AS Subtotal_Quantity,
    SUM(od.quantity * p.price) AS Subtotal_Sales,
    CASE
        WHEN SUM(od.quantity * p.price) >= CAST(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY SUM(od.quantity * p.price)) OVER () AS INT)THEN 1
        ELSE 0
    END AS Peak
FROM dbo.order_details od
    JOIN dbo.calender_time ct ON od.order_id = ct.order_id
    JOIN dbo.pizzas p ON od.pizza_id = p.pizza_id
GROUP BY ct.mm
ORDER BY ct.mm

-- 2b. Subtotal Order, Quantity, Sales vs Quarter

SELECT 
    ct.qq, 
    COUNT(DISTINCT od.order_id) AS Subtotal_Order, 
    SUM(od.quantity) AS Subtotal_Quantity,
    SUM(od.quantity * p.price) AS Subtotal_Sales,
    CASE
        WHEN SUM(od.quantity * p.price) >= CAST(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY SUM(od.quantity * p.price)) OVER () AS INT)THEN 1
        ELSE 0
    END AS Peak
FROM dbo.order_details od
    JOIN dbo.calender_time ct ON od.order_id = ct.order_id
    JOIN dbo.pizzas p ON od.pizza_id = p.pizza_id
GROUP BY ct.qq
ORDER BY ct.qq

-- 2c. Subtotal Order, Quantity, Sales vs Week

SELECT 
    ct.ww, 
    COUNT(DISTINCT od.order_id) AS Subtotal_Order, 
    SUM(od.quantity) AS Subtotal_Quantity,
    SUM(od.quantity * p.price) AS Subtotal_Sales,
    CASE
        WHEN SUM(od.quantity * p.price) >= CAST(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY SUM(od.quantity * p.price)) OVER () AS INT)THEN 1
        ELSE 0
    END AS Peak
FROM dbo.order_details od
    JOIN dbo.calender_time ct ON od.order_id = ct.order_id
    JOIN dbo.pizzas p ON od.pizza_id = p.pizza_id
GROUP BY ct.ww
ORDER BY ct.ww

-- 2d. Subtotal Order, Quantity, Sales vs Weekday

SELECT 
    ct.wday, 
    COUNT(DISTINCT od.order_id) AS Subtotal_Order, 
    SUM(od.quantity) AS Subtotal_Quantity,
    SUM(od.quantity * p.price) AS Subtotal_Sales,
    CASE
        WHEN SUM(od.quantity * p.price) >= CAST(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY SUM(od.quantity * p.price)) OVER () AS INT)THEN 1
        ELSE 0
    END AS Peak
FROM dbo.order_details od
    JOIN dbo.calender_time ct ON od.order_id = ct.order_id
    JOIN dbo.pizzas p ON od.pizza_id = p.pizza_id
GROUP BY ct.wday
ORDER BY ct.wday

-- 2e. Subtotal Order, Quantity, Sales vs Hour

SELECT 
    ct.hh, 
    COUNT(DISTINCT od.order_id) AS Subtotal_Order, 
    SUM(od.quantity) AS Subtotal_Quantity,
    SUM(od.quantity * p.price) AS Subtotal_Sales,
    CASE
        WHEN SUM(od.quantity * p.price) >= CAST(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY SUM(od.quantity * p.price)) OVER () AS INT)THEN 1
        ELSE 0
    END AS Peak
FROM dbo.order_details od
    JOIN dbo.calender_time ct ON od.order_id = ct.order_id
    JOIN dbo.pizzas p ON od.pizza_id = p.pizza_id
GROUP BY ct.hh
ORDER BY ct.hh

------------------------------------------------------------------------------------------------------------------------
----------------------- Q3. Subtotal Quantity, Sales, % of Sales by Size, Pizzas, Category -----------------------------
------------------------------------------------------------------------------------------------------------------------

-- There could be more than multiple sizes in a particular order. Don't consider subtotal order because of double count!
-- E.g. Different size (M, L) in the same order.

-- SELECT *
-- FROM order_details od 
--     JOIN pizzas p ON od.pizza_id = p.pizza_id 


-- 3a. Subtotal Quantity, Sales, pct vs Size

SELECT 
    p.size,
    SUM(od.quantity) AS Subtotal_Quantity,
    SUM(od.quantity*p.price) AS Subtotal_Sales,
    CAST(SUM(od.quantity*p.price)*100/SUM(SUM(od.quantity*p.price)) OVER() AS DECIMAL(10,2)) AS pct_Sales
FROM dbo.order_details od 
    JOIN dbo.pizzas p ON od.pizza_id = p.pizza_id 
GROUP BY p.size
ORDER BY SUM(od.quantity*p.price) DESC

-- 3b. The Five Best Selling Pizza Type: Subtotal Quantity, Sales, pct vs Pizzas Type

SELECT TOP 5
    pt.name,
    SUM(od.quantity) AS Subtotal_Quantity,
    SUM(od.quantity*p.price) AS Subtotal_Sales,
    CAST(SUM(od.quantity*p.price)*100/SUM(SUM(od.quantity*p.price)) OVER() AS DECIMAL(10,2)) AS pct_Sales
FROM dbo.order_details od 
    JOIN dbo.pizzas p ON od.pizza_id = p.pizza_id
    JOIN dbo.pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY SUM(od.quantity*p.price) DESC

-- 3c. The Five Best Selling Pizza (with Size): Subtotal Quantity, Sales, pct vs Pizzas

SELECT TOP 5
    pt.name,
    p.size,
    SUM(od.quantity) AS Subtotal_Quantity,
    SUM(od.quantity*p.price) AS Subtotal_Sales,
    CAST(SUM(od.quantity*p.price)*100/SUM(SUM(od.quantity*p.price)) OVER() AS DECIMAL(10,2)) AS pct_Sales
FROM dbo.order_details od 
    JOIN dbo.pizzas p ON od.pizza_id = p.pizza_id
    JOIN dbo.pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name, p.size
ORDER BY SUM(od.quantity*p.price) DESC

-- 3d. The Five Worest Selling Pizza Type: Subtotal Quantity, Sales, pct vs Pizzas Type

SELECT TOP 5
    pt.name,
    SUM(od.quantity) AS Subtotal_Quantity,
    SUM(od.quantity*p.price) AS Subtotal_Sales,
    CAST(SUM(od.quantity*p.price)*100/SUM(SUM(od.quantity*p.price)) OVER() AS DECIMAL(10,2)) AS pct_Sales
FROM dbo.order_details od 
    JOIN dbo.pizzas p ON od.pizza_id = p.pizza_id
    JOIN dbo.pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY SUM(od.quantity*p.price) ASC

-- 3e. The Five Worest Selling Pizza (with Size): Subtotal Quantity, Sales, pct vs Pizzas

SELECT TOP 5
    pt.name,
    p.size,
    SUM(od.quantity) AS Subtotal_Quantity,
    SUM(od.quantity*p.price) AS Subtotal_Sales,
    CAST(SUM(od.quantity*p.price)*100/SUM(SUM(od.quantity*p.price)) OVER() AS DECIMAL(10,2)) AS pct_Sales
FROM dbo.order_details od 
    JOIN dbo.pizzas p ON od.pizza_id = p.pizza_id
    JOIN dbo.pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name, p.size
ORDER BY SUM(od.quantity*p.price) ASC

-- 3f. Subtotal Quantity, Sales, pct vs Category

SELECT 
    pt.category, 
    SUM(od.quantity) AS Subtotal_Quantity,
    SUM(od.quantity*p.price) AS Subtotal_Sales,
    CAST(SUM(od.quantity*p.price)*100/SUM(SUM(od.quantity*p.price)) OVER() AS DECIMAL(10,2)) AS pct_Sales
FROM dbo.order_details od 
    JOIN dbo.pizzas p ON od.pizza_id = p.pizza_id
    JOIN dbo.pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY SUM(od.quantity*p.price) DESC

------------------------------------------------------------------------------------------------------------------------
---------------------------- Q4. The pizzas I should make MORE during the PEAK period ----------------------------------
------------------------------------------------------------------------------------------------------------------------

-- Only concern the Month, Week, Weekday and Hour Peak period

GO

-- 4a. PEAK period: Month

WITH mm_calender_time AS
(
    SELECT 
        ct.mm, 
        COUNT(DISTINCT od.order_id) AS Subtotal_Order, 
        SUM(od.quantity) AS Subtotal_Quantity,
        SUM(od.quantity * p.price) AS Subtotal_Sales,
        CASE
            WHEN SUM(od.quantity * p.price) >= CAST(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY SUM(od.quantity * p.price)) OVER () AS INT)THEN 1
            ELSE 0
        END AS Peak
    FROM dbo.order_details od
        JOIN dbo.calender_time ct ON od.order_id = ct.order_id
        JOIN dbo.pizzas p ON od.pizza_id = p.pizza_id
    GROUP BY ct.mm
)
SELECT TOP 5
    pt.name,
    p.size,
    SUM(od.quantity) AS Subtotal_Quantity,
    SUM(od.quantity*p.price) AS Subtotal_Sales,
    CAST(SUM(od.quantity*p.price)*100/SUM(SUM(od.quantity*p.price)) OVER() AS DECIMAL(10,2)) AS pct_Sales
FROM dbo.order_details od 
    JOIN dbo.calender_time ct ON od.order_id = ct.order_id
    JOIN mm_calender_time mct ON mct.mm = ct.mm
    JOIN dbo.pizzas p ON od.pizza_id = p.pizza_id
    JOIN dbo.pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
WHERE peak = 1
GROUP BY pt.name, p.size
ORDER BY SUM(od.quantity*p.price) DESC

GO

-- 4b. PEAK period: Week

WITH ww_calender_time AS
(
    SELECT 
        ct.ww, 
        COUNT(DISTINCT od.order_id) AS Subtotal_Order, 
        SUM(od.quantity) AS Subtotal_Quantity,
        SUM(od.quantity * p.price) AS Subtotal_Sales,
        CASE
            WHEN SUM(od.quantity * p.price) >= CAST(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY SUM(od.quantity * p.price)) OVER () AS INT)THEN 1
            ELSE 0
        END AS Peak
    FROM dbo.order_details od
        JOIN dbo.calender_time ct ON od.order_id = ct.order_id
        JOIN dbo.pizzas p ON od.pizza_id = p.pizza_id
    GROUP BY ct.ww
)
SELECT TOP 5
    pt.name,
    p.size,
    SUM(od.quantity) AS Subtotal_Quantity,
    SUM(od.quantity*p.price) AS Subtotal_Sales,
    CAST(SUM(od.quantity*p.price)*100/SUM(SUM(od.quantity*p.price)) OVER() AS DECIMAL(10,2)) AS pct_Sales
FROM dbo.order_details od 
    JOIN dbo.calender_time ct ON od.order_id = ct.order_id
    JOIN ww_calender_time wct ON wct.ww = ct.ww
    JOIN dbo.pizzas p ON od.pizza_id = p.pizza_id
    JOIN dbo.pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
WHERE peak = 1
GROUP BY pt.name, p.size
ORDER BY SUM(od.quantity*p.price) DESC

GO

-- 4c. PEAK period: Weekday

WITH wday_calender_time AS
(
    SELECT 
        ct.wday, 
        COUNT(DISTINCT od.order_id) AS Subtotal_Order, 
        SUM(od.quantity) AS Subtotal_Quantity,
        SUM(od.quantity * p.price) AS Subtotal_Sales,
        CASE
            WHEN SUM(od.quantity * p.price) >= CAST(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY SUM(od.quantity * p.price)) OVER () AS INT)THEN 1
            ELSE 0
        END AS Peak
    FROM dbo.order_details od
        JOIN dbo.calender_time ct ON od.order_id = ct.order_id
        JOIN dbo.pizzas p ON od.pizza_id = p.pizza_id
    GROUP BY ct.wday
)
SELECT TOP 5
    pt.name,
    p.size,
    SUM(od.quantity) AS Subtotal_Quantity,
    SUM(od.quantity*p.price) AS Subtotal_Sales,
    CAST(SUM(od.quantity*p.price)*100/SUM(SUM(od.quantity*p.price)) OVER() AS DECIMAL(10,2)) AS pct_Sales
FROM dbo.order_details od 
    JOIN dbo.calender_time ct ON od.order_id = ct.order_id
    JOIN wday_calender_time wdayct ON wdayct.wday = ct.wday
    JOIN dbo.pizzas p ON od.pizza_id = p.pizza_id
    JOIN dbo.pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
WHERE peak = 1
GROUP BY pt.name, p.size
ORDER BY SUM(od.quantity*p.price) DESC

GO

-- 4d. PEAK period: Hour

WITH hh_calender_time AS
(
    SELECT 
        ct.hh, 
        COUNT(DISTINCT od.order_id) AS Subtotal_Order, 
        SUM(od.quantity) AS Subtotal_Quantity,
        SUM(od.quantity * p.price) AS Subtotal_Sales,
        CASE
            WHEN SUM(od.quantity * p.price) >= CAST(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY SUM(od.quantity * p.price)) OVER () AS INT)THEN 1
            ELSE 0
        END AS Peak
    FROM dbo.order_details od
        JOIN dbo.calender_time ct ON od.order_id = ct.order_id
        JOIN dbo.pizzas p ON od.pizza_id = p.pizza_id
    GROUP BY ct.hh
)
SELECT TOP 5
    pt.name,
    p.size,
    SUM(od.quantity) AS Subtotal_Quantity,
    SUM(od.quantity*p.price) AS Subtotal_Sales,
    CAST(SUM(od.quantity*p.price)*100/SUM(SUM(od.quantity*p.price)) OVER() AS DECIMAL(10,2)) AS pct_Sales
FROM dbo.order_details od 
    JOIN dbo.calender_time ct ON od.order_id = ct.order_id
    JOIN hh_calender_time hct ON hct.hh = ct.hh
    JOIN dbo.pizzas p ON od.pizza_id = p.pizza_id
    JOIN dbo.pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
WHERE peak = 1
GROUP BY pt.name, p.size
ORDER BY SUM(od.quantity*p.price) DESC

GO

------------------------------------------------------------------------------------------------------------------------
---------------------------- Q5. The pizzas I should make LESS during the PEAK period ----------------------------------
------------------------------------------------------------------------------------------------------------------------

-- Only concern the Month, Week, Weekday and Hour Peak period

-- 5a. PEAK period: Month

WITH mm_calender_time AS
(
    SELECT 
        ct.mm, 
        COUNT(DISTINCT od.order_id) AS Subtotal_Order, 
        SUM(od.quantity) AS Subtotal_Quantity,
        SUM(od.quantity * p.price) AS Subtotal_Sales,
        CASE
            WHEN SUM(od.quantity * p.price) >= CAST(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY SUM(od.quantity * p.price)) OVER () AS INT)THEN 1
            ELSE 0
        END AS Peak
    FROM dbo.order_details od
        JOIN dbo.calender_time ct ON od.order_id = ct.order_id
        JOIN dbo.pizzas p ON od.pizza_id = p.pizza_id
    GROUP BY ct.mm
)
SELECT TOP 5
    pt.name,
    p.size,
    SUM(od.quantity) AS Subtotal_Quantity,
    SUM(od.quantity*p.price) AS Subtotal_Sales,
    CAST(SUM(od.quantity*p.price)*100/SUM(SUM(od.quantity*p.price)) OVER() AS DECIMAL(10,2)) AS pct_Sales
FROM dbo.order_details od 
    JOIN dbo.calender_time ct ON od.order_id = ct.order_id
    JOIN mm_calender_time mct ON mct.mm = ct.mm
    JOIN dbo.pizzas p ON od.pizza_id = p.pizza_id
    JOIN dbo.pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
WHERE peak = 1
GROUP BY pt.name, p.size
ORDER BY SUM(od.quantity*p.price) ASC

GO

-- 5b. PEAK period: Week

WITH ww_calender_time AS
(
    SELECT 
        ct.ww, 
        COUNT(DISTINCT od.order_id) AS Subtotal_Order, 
        SUM(od.quantity) AS Subtotal_Quantity,
        SUM(od.quantity * p.price) AS Subtotal_Sales,
        CASE
            WHEN SUM(od.quantity * p.price) >= CAST(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY SUM(od.quantity * p.price)) OVER () AS INT)THEN 1
            ELSE 0
        END AS Peak
    FROM dbo.order_details od
        JOIN dbo.calender_time ct ON od.order_id = ct.order_id
        JOIN dbo.pizzas p ON od.pizza_id = p.pizza_id
    GROUP BY ct.ww
)
SELECT TOP 5
    pt.name,
    p.size,
    SUM(od.quantity) AS Subtotal_Quantity,
    SUM(od.quantity*p.price) AS Subtotal_Sales,
    CAST(SUM(od.quantity*p.price)*100/SUM(SUM(od.quantity*p.price)) OVER() AS DECIMAL(10,2)) AS pct_Sales
FROM dbo.order_details od 
    JOIN dbo.calender_time ct ON od.order_id = ct.order_id
    JOIN ww_calender_time wct ON wct.ww = ct.ww
    JOIN dbo.pizzas p ON od.pizza_id = p.pizza_id
    JOIN dbo.pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
WHERE peak = 1
GROUP BY pt.name, p.size
ORDER BY SUM(od.quantity*p.price) ASC

GO

-- 5c. PEAK period: Weekday

WITH wday_calender_time AS
(
    SELECT 
        ct.wday, 
        COUNT(DISTINCT od.order_id) AS Subtotal_Order, 
        SUM(od.quantity) AS Subtotal_Quantity,
        SUM(od.quantity * p.price) AS Subtotal_Sales,
        CASE
            WHEN SUM(od.quantity * p.price) >= CAST(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY SUM(od.quantity * p.price)) OVER () AS INT)THEN 1
            ELSE 0
        END AS Peak
    FROM dbo.order_details od
        JOIN dbo.calender_time ct ON od.order_id = ct.order_id
        JOIN dbo.pizzas p ON od.pizza_id = p.pizza_id
    GROUP BY ct.wday
)
SELECT TOP 5
    pt.name,
    p.size,
    SUM(od.quantity) AS Subtotal_Quantity,
    SUM(od.quantity*p.price) AS Subtotal_Sales,
    CAST(SUM(od.quantity*p.price)*100/SUM(SUM(od.quantity*p.price)) OVER() AS DECIMAL(10,2)) AS pct_Sales
FROM dbo.order_details od 
    JOIN dbo.calender_time ct ON od.order_id = ct.order_id
    JOIN wday_calender_time wdayct ON wdayct.wday = ct.wday
    JOIN dbo.pizzas p ON od.pizza_id = p.pizza_id
    JOIN dbo.pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
WHERE peak = 1
GROUP BY pt.name, p.size
ORDER BY SUM(od.quantity*p.price) ASC

GO

-- 5d. PEAK period: Hour

WITH hh_calender_time AS
(
    SELECT 
        ct.hh, 
        COUNT(DISTINCT od.order_id) AS Subtotal_Order, 
        SUM(od.quantity) AS Subtotal_Quantity,
        SUM(od.quantity * p.price) AS Subtotal_Sales,
        CASE
            WHEN SUM(od.quantity * p.price) >= CAST(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY SUM(od.quantity * p.price)) OVER () AS INT)THEN 1
            ELSE 0
        END AS Peak
    FROM dbo.order_details od
        JOIN dbo.calender_time ct ON od.order_id = ct.order_id
        JOIN dbo.pizzas p ON od.pizza_id = p.pizza_id
    GROUP BY ct.hh
)
SELECT TOP 5
    pt.name,
    p.size,
    SUM(od.quantity) AS Subtotal_Quantity,
    SUM(od.quantity*p.price) AS Subtotal_Sales,
    CAST(SUM(od.quantity*p.price)*100/SUM(SUM(od.quantity*p.price)) OVER() AS DECIMAL(10,2)) AS pct_Sales
FROM dbo.order_details od 
    JOIN dbo.calender_time ct ON od.order_id = ct.order_id
    JOIN hh_calender_time hct ON hct.hh = ct.hh
    JOIN dbo.pizzas p ON od.pizza_id = p.pizza_id
    JOIN dbo.pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
WHERE peak = 1
GROUP BY pt.name, p.size
ORDER BY SUM(od.quantity*p.price) ASC

GO
