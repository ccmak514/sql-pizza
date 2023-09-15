select top 10 * from dbo.order_details;

select top 10 * from dbo.orders;

select top 10 * from dbo.pizza_types;

select top 10 * from dbo.pizzas;

-------------------------------------------------------------------------------------

-- 1. Total Revenue
SELECT SUM(od.quantity * p.price) AS Total_Revenue
FROM dbo.order_details AS od 
INNER JOIN dbo.pizzas AS p ON od.pizza_id = p.pizza_id;

-- 2. Average Order Value
SELECT SUM(od.quantity * p.price)/ COUNT(DISTINCT od.order_id) AS Average_Order_Value
FROM dbo.order_details AS od 
INNER JOIN dbo.pizzas AS p ON od.pizza_id = p.pizza_id;

-- 3. Total Pizzas Sold
SELECT SUM(dbo.order_details.quantity) AS Total_Pizza_Sold FROM dbo.order_details;

-- 4. Total Orders
SELECT COUNT(DISTINCT dbo.order_details.order_id) AS Total_orders FROM dbo.order_details;

-- 5. Average Pizza per Order
SELECT CAST((CAST(SUM(dbo.order_details.quantity) AS DECIMAL(10, 2)) / 
COUNT(DISTINCT dbo.order_details.order_id)) AS decimal (10, 2)) FROM dbo.order_details;

-- 6. Hourly Trend for Total Pizzas Sold
SELECT DATEPART(HOUR, o.time) AS order_hour, SUM(od.quantity) AS Total_Pizzas_Sold
FROM dbo.order_details AS od
INNER JOIN dbo.orders AS o ON od.order_id = o.order_id
GROUP BY DATEPART(HOUR, o.time)
ORDER BY DATEPART(HOUR, o.time) DESC;

-- 7. Weekly Trend for Total Orders
SELECT DATEPART(ISO_WEEK, o.date) AS week_no, COUNT(DISTINCT(o.order_id)) AS total_order
FROM dbo.orders AS o
GROUP BY DATEPART(ISO_WEEK, o.date)
ORDER BY DATEPART(ISO_WEEK, o.date) ASC;

-- 8. % of Sales by Pizza Category
SELECT pt.category, CAST(SUM(p.price * od.quantity) AS DECIMAL(10, 2)) AS Total_Revenue,
CAST(

SUM(p.price * od.quantity)*100 / 
(SELECT SUM(od.quantity * p.price) AS Total_Revenue
FROM dbo.order_details AS od 
INNER JOIN dbo.pizzas AS p ON od.pizza_id = p.pizza_id)

AS DECIMAL(10, 2)

) AS percentage_sales
FROM dbo.order_details AS od
INNER JOIN dbo.pizzas AS p ON od.pizza_id = p.pizza_id 
INNER JOIN dbo.pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY percentage_sales;

-- 9. % of Sales by Pizza Size
SELECT p.size, CAST(SUM(p.price * od.quantity) AS DECIMAL(10, 2)) AS Total_Revenue,
CAST(

SUM(p.price * od.quantity)*100 / 
(SELECT SUM(od.quantity * p.price) AS Total_Revenue
FROM dbo.order_details AS od 
INNER JOIN dbo.pizzas AS p ON od.pizza_id = p.pizza_id)

AS DECIMAL(10, 2)

) AS percentage_sales
FROM dbo.order_details AS od
INNER JOIN dbo.pizzas AS p ON od.pizza_id = p.pizza_id 
GROUP BY p.size
ORDER BY p.size;

-- 10. % of Quantity by Pizza Size
SELECT pt.category, SUM(od.quantity) AS Subtotal_Quantity,
(
SUM(od.quantity)*100 / 
(SELECT SUM(dbo.order_details.quantity) FROM dbo.order_details)
) AS percentage_quantity
FROM dbo.order_details AS od
INNER JOIN dbo.pizzas AS p ON od.pizza_id = p.pizza_id 
INNER JOIN dbo.pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY percentage_quantity;

-------------------------------------------------------------------------------------