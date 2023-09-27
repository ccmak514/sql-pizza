# Relational Database and SQL Querying for a Pizza Shop

## ER Diagram
![ER diagram](https://github.com/ccmak514/sql-pizza/assets/101066418/c8c143b7-47e5-4662-b667-d9970d591bbd)

## Questions for SQL Querying
### Q1. Total Order, Quantity, Sales, Average Sales and Quantity per Order
##### 1a. Total Order
```SQL
SELECT COUNT(DISTINCT dbo.order_details.order_id) AS Total_orders FROM dbo.order_details;
```
##### 1b. Total Sales
```SQL
SELECT SUM(od.quantity * p.price) AS Total_Sales
FROM dbo.order_details AS od 
INNER JOIN dbo.pizzas AS p ON od.pizza_id = p.pizza_id;
```
##### 1c. Average Sales per Order
```SQL
SELECT SUM(od.quantity * p.price)/ COUNT(DISTINCT od.order_id) AS Average_Sales_perOrder
FROM dbo.order_details AS od 
INNER JOIN dbo.pizzas AS p ON od.pizza_id = p.pizza_id;
```
##### 1d. Total Pizzas Sold
```SQL
SELECT SUM(dbo.order_details.quantity) AS Total_Pizza_Sold FROM dbo.order_details;
```
##### 1e. Average Pizza Sold per Order
```SQL
SELECT CAST((CAST(SUM(dbo.order_details.quantity) AS DECIMAL(10, 2)) / 
COUNT(DISTINCT dbo.order_details.order_id)) AS decimal (10, 2)) AS Average_Pizza_Sold_perOrder FROM dbo.order_details;
```
<br>

### Q2. Subtotal Order, Quantity, Sales, Peak by Month, Quarter, Week, Weekday, Hour
Create a view, calender_time, which is a detailed version of dbo.orders explicitly indicating year, month, quarter, week, weekday, hour, etc.
```SQL
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
```
##### 2a. Subtotal Order, Quantity, Sales vs Month 
```SQL
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
```
##### 2b. Subtotal Order, Quantity, Sales vs Quarter
```SQL
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
```
##### 2c. Subtotal Order, Quantity, Sales vs Week
```SQL
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
```
##### 2d. Subtotal Order, Quantity, Sales vs Weekday
```SQL
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
```
##### 2e. Subtotal Order, Quantity, Sales vs Hour
```SQL
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
```
<br>

### Q3. Subtotal Quantity, Sales, % of Sales by Size, Pizzas, Category
##### 3a. Subtotal Quantity, Sales, pct vs Size
```SQL
SELECT 
    p.size,
    SUM(od.quantity) AS Subtotal_Quantity,
    SUM(od.quantity*p.price) AS Subtotal_Sales,
    CAST(SUM(od.quantity*p.price)*100/SUM(SUM(od.quantity*p.price)) OVER() AS DECIMAL(10,2)) AS pct_Sales
FROM dbo.order_details od 
    JOIN dbo.pizzas p ON od.pizza_id = p.pizza_id 
GROUP BY p.size
ORDER BY SUM(od.quantity*p.price) DESC
```
##### 3b. The Five Best Selling Pizza Type: Subtotal Quantity, Sales, pct vs Pizzas Type
```SQL
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
```
##### 3c. The Five Best Selling Pizza (with Size): Subtotal Quantity, Sales, pct vs Pizzas
```SQL
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
```
##### 3d. The Five Worest Selling Pizza Type: Subtotal Quantity, Sales, pct vs Pizzas Type
```SQL
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
```
##### 3e. The Five Worest Selling Pizza (with Size): Subtotal Quantity, Sales, pct vs Pizzas
```SQL
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
```
##### 3f. Subtotal Quantity, Sales, pct vs Category
```SQL
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
```
<br>

### Q4. The pizzas I should make MORE during the PEAK period
##### 4a. PEAK period: Month
```SQL
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
```
##### 4b. PEAK period: Week
```SQL
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
```
##### 4c. PEAK period: Weekday
```SQL
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
```
##### 4d. PEAK period: Hour
```SQL
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
```
<br>

### Q5. The pizzas I should make LESS during the PEAK period
##### 5a. PEAK period: Month
```SQL
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
```
##### 5b. PEAK period: Week
```SQL
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
```
##### 5c. PEAK period: Weekday
```SQL
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
```
##### 5d. PEAK period: Hour
```SQL
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
```
