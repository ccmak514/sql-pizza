# Relational Database and SQL Querying for a Pizza Shop

## ER Diagram
![ER diagram](https://github.com/ccmak514/sql-pizza/assets/101066418/c8c143b7-47e5-4662-b667-d9970d591bbd)

## Questions for SQL Querying
### Q1. Total Order, Quantity, Sales, Average Sales and Quantity per Order
##### 1a. Total Order
```SQL
SELECT COUNT(DISTINCT dbo.order_details.order_id) AS Total_orders FROM dbo.order_details;
```
|   | Total_orders |
|:-:|:------------:|
| 1 |     21350    |
##### 1b. Total Sales
```SQL
SELECT SUM(od.quantity * p.price) AS Total_Sales
FROM dbo.order_details AS od 
INNER JOIN dbo.pizzas AS p ON od.pizza_id = p.pizza_id;
```
|   | Total_Sales |
|:-:|:-----------:|
| 1 |  817860.05  |
##### 1c. Average Sales per Order
```SQL
SELECT SUM(od.quantity * p.price)/ COUNT(DISTINCT od.order_id) AS Average_Sales_perOrder
FROM dbo.order_details AS od 
INNER JOIN dbo.pizzas AS p ON od.pizza_id = p.pizza_id;
```
|   | Average_Sales_perOrder |
|:-:|:----------------------:|
| 1 |         38.3072        |
##### 1d. Total Pizzas Sold
```SQL
SELECT SUM(dbo.order_details.quantity) AS Total_Pizza_Sold FROM dbo.order_details;
```
|   | Total_Pizza_Sold |
|:-:|:----------------:|
| 1 |       49574      |
##### 1e. Average Pizza Sold per Order
```SQL
SELECT CAST((CAST(SUM(dbo.order_details.quantity) AS DECIMAL(10, 2)) / 
COUNT(DISTINCT dbo.order_details.order_id)) AS decimal (10, 2)) AS Average_Pizza_Sold_perOrder FROM dbo.order_details;
```
|   | Average_Pizza_Sold_perOrder |
|:-:|:---------------------------:|
| 1 |             2.32            |
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
|    | mm | Subtotal_Order | Subtotal_Quantity | Subtotal_Sales | Peak |
|:---:|:---:|:--------------:|:-----------------:|:--------------:|:----:|
| 1  | 1  | 1845           | 4232              | 69793.30       | 0    |
| 2  | 2  | 1685           | 3961              | 65159.60       | 0    |
| 3  | 3  | 1840           | 4261              | 70397.10       | 1    |
| 4  | 4  | 1799           | 4151              | 68736.80       | 0    |
| 5  | 5  | 1853           | 4328              | 71402.75       | 1    |
| 6  | 6  | 1773           | 4107              | 68230.20       | 0    |
| 7  | 7  | 1935           | 4392              | 72557.90       | 1    |
| 8  | 8  | 1841           | 4168              | 68278.25       | 0    |
| 9  | 9  | 1661           | 3890              | 64180.05       | 0    |
| 10 | 10 | 1646           | 3883              | 64027.60       | 0    |
| 11 | 11 | 1792           | 4266              | 70395.35       | 1    |
| 12 | 12 | 1680           | 3935              | 64701.15       | 0    |

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
|   | qq | Subtotal_Order | Subtotal_Quantity | Subtotal_Sales | Peak |
|:---:|:---:|:--------------:|:-----------------:|:--------------:|:----:|
| 1 | 1  | 5370           | 12454             | 205350.00      | 0    |
| 2 | 2  | 5425           | 12586             | 208369.75      | 1    |
| 3 | 3  | 5437           | 12450             | 205016.20      | 0    |
| 4 | 4  | 5118           | 12084             | 199124.10      | 0    |

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
|    | ww | Subtotal_Order | Subtotal_Quantity | Subtotal_Sales | Peak |
|:---:|:---:|:--------------:|:-----------------:|:--------------:|:----:|
| 1  | 1  | 202            | 485               | 8108.15        | 0    |
| 2  | 2  | 427            | 962               | 15882.20       | 0    |
| 3  | 3  | 401            | 911               | 15011.40       | 0    |
| 4  | 4  | 422            | 988               | 16012.10       | 0    |
| 5  | 5  | 393            | 886               | 14779.45       | 0    |
| 6  | 6  | 456            | 1055              | 17329.90       | 1    |
| 7  | 7  | 421            | 972               | 15979.30       | 0    |
| 8  | 8  | 411            | 964               | 15907.20       | 0    |
| 9  | 9  | 397            | 970               | 15943.20       | 0    |
| 10 | 10 | 407            | 960               | 15974.85       | 0    |
| 11 | 11 | 417            | 969               | 15940.10       | 0    |
| 12 | 12 | 428            | 1003              | 16521.60       | 1    |
| 13 | 13 | 410            | 899               | 14794.25       | 0    |
| 14 | 14 | 437            | 1040              | 17196.05       | 1    |
| 15 | 15 | 405            | 965               | 16076.40       | 0    |
| 16 | 16 | 417            | 992               | 16554.85       | 1    |
| 17 | 17 | 431            | 959               | 15888.55       | 0    |
| 18 | 18 | 430            | 931               | 15159.40       | 0    |
| 19 | 19 | 393            | 958               | 15794.10       | 0    |
| 20 | 20 | 464            | 1078              | 17599.65       | 1    |
| 21 | 21 | 404            | 928               | 15539.85       | 0    |
| 22 | 22 | 399            | 950               | 15779.35       | 0    |
| 23 | 23 | 418            | 988               | 16407.1        | 1    |
| 24 | 24 | 425            | 966               | 15985.65       | 0    |
| 25 | 25 | 407            | 918               | 15328.55       | 0    |
| 26 | 26 | 422            | 1000              | 16572.3        | 1    |
| 27 | 27 | 478            | 1065              | 17487.75       | 1    |
| 28 | 28 | 400            | 918               | 15294.5        | 0    |
| 29 | 29 | 425            | 988               | 16421.2        | 1    |
| 30 | 30 | 429            | 994               | 16502.8        | 1    |
| 31 | 31 | 428            | 924               | 14946.45       | 0    |
| 32 | 32 | 419            | 943               | 15519.45       | 0    |
| 33 | 33 | 440            | 992               | 16140.95       | 0    |
| 34 | 34 | 409            | 982               | 16114.55       | 0    |
| 35 | 35 | 401            | 877               | 14486.8        | 0    |
| 36 | 36 | 391            | 947               | 15545.7        | 0    |
| 37 | 37 | 433            | 993               | 16370.5        | 1    |
| 38 | 38 | 424            | 974               | 15989          | 0    |
| 39 | 39 | 275            | 643               | 10540.7        | 0    |
| 40 | 40 | 442            | 1019              | 16988.05       | 1    |
| 41 | 41 | 344            | 804               | 13249.15       | 0    |
| 42 | 42 | 383            | 946               | 15603.65       | 0    |
| 43 | 43 | 352            | 867               | 14384          | 0    |
| 44 | 44 | 361            | 800               | 13112.85       | 0    |
| 45 | 45 | 401            | 967               | 15999.2        | 0    |
| 46 | 46 | 403            | 958               | 15736.8        | 0    |
| 47 | 47 | 394            | 937               | 15313.5        | 0    |
| 48 | 48 | 488            | 1155              | 19223.6        | 1    |
| 49 | 49 | 415            | 984               | 16162.55       | 1    |
| 50 | 50 | 420            | 973               | 15772.6        | 0    |
| 51 | 51 | 429            | 968               | 16111.25       | 0    |
| 52 | 52 | 316            | 728               | 12113.75       | 0    |
| 53 | 53 | 206            | 531               | 8663.25        | 0    |

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
|   | wday | Subtotal_Order | Subtotal_Quantity | Subtotal_Sales | Peak |
|:---:|:---:|:--------------:|:-----------------:|:--------------:|:----:|
| 1 | 1  | 2624           | 6035              | 99203.50       | 0    |
| 2 | 2  | 2794           | 6485              | 107329.55      | 0    |
| 3 | 3  | 2973           | 6895              | 114133.80      | 0    |
| 4 | 4  | 3024           | 6946              | 114408.40      | 0    |
| 5 | 5  | 3239           | 7478              | 123528.50      | 1    |
| 6 | 6  | 3538           | 8242              | 136073.90      | 1    |
| 7 | 7  | 3158           | 7493              | 123182.40      | 0    |

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
|    | hh | Subtotal_Order | Subtotal_Quantity | Subtotal_Sales | Peak |
|:---:|:---:|:--------------:|:-----------------:|:--------------:|:----:|
| 9  | 9  | 1              | 4                 | 83.00          | 0    |
| 10 | 10 | 8              | 18                | 303.65         | 0    |
| 11 | 11 | 1231           | 2728              | 44935.80       | 0    |
| 12 | 12 | 2520           | 6776              | 111877.90      | 1    |
| 13 | 13 | 2455           | 6413              | 106065.70      | 1    |
| 14 | 14 | 1472           | 3613              | 59201.40       | 0    |
| 15 | 15 | 1468           | 3216              | 52992.30       | 0    |
| 16 | 16 | 1920           | 4239              | 70055.40       | 0    |
| 17 | 17 | 2336           | 5211              | 86237.45       | 1    |
| 18 | 18 | 2399           | 5417              | 89296.85       | 1    |
| 19 | 19 | 2009           | 4406              | 72628.90       | 0    |
| 20 | 20 | 1642           | 3534              | 58215.40       | 0    |
| 21 | 21 | 1198           | 2545              | 42029.80       | 0    |
| 22 | 22 | 663            | 1386              | 22815.15       | 0    |
| 23 | 23 | 28             | 68                | 1121.35        | 0    |

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
|   | size | Subtotal_Quantity | Subtotal_Sales | pct_Sales |
|:---:|:----:|:-----------------:|:--------------:|:---------:|
| 1 | L    | 18956             | 375318.70      | 45.89     |
| 2 | M    | 15635             | 249382.25      | 30.49     |
| 3 | S    | 14403             | 178076.50      | 21.77     |
| 4 | XL   | 552               | 14076.00       | 1.72      |
| 5 | XXL  | 28                | 1006.60        | 0.12      |

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
|   | name                         | Subtotal_Quantity | Subtotal_Sales | pct_Sales |
|:---:|:----------------------------:|:-----------------:|:--------------:|:---------:|
| 1 | The Thai Chicken Pizza       | 2371              | 43434.25       | 5.31      |
| 2 | The Barbecue Chicken Pizza   | 2432              | 42768.00       | 5.23      |
| 3 | The California Chicken Pizza | 2370              | 41409.50       | 5.06      |
| 4 | The Classic Deluxe Pizza     | 2453              | 38180.50       | 4.67      |
| 5 | The Spicy Italian Pizza      | 1924              | 34831.25       | 4.26      |

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
|   | name                    | size | Subtotal_Quantity | Subtotal_Sales | pct_Sales |
|:---:|:-----------------------:|:----:|:-----------------:|:--------------:|:---------:|
| 1 | The Thai Chicken Pizza  | L    | 1410              | 29257.50       | 3.58      |
| 2 | The Five Cheese Pizza   | L    | 1409              | 26066.50       | 3.19      |
| 3 | The Four Cheese Pizza   | L    | 1316              | 23622.20       | 2.89      |
| 4 | The Spicy Italian Pizza | L    | 1109              | 23011.75       | 2.81      |
| 5 | The Big Meat Pizza      | S    | 1914              | 22968.00       | 2.81      |

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
|   | name                      | Subtotal_Quantity | Subtotal_Sales | pct_Sales |
|:---:|:-------------------------:|:-----------------:|:--------------:|:---------:|
| 1 | The Brie Carre Pizza      | 490               | 11588.50       | 1.42      |
| 2 | The Green Garden Pizza    | 997               | 13955.75       | 1.71      |
| 3 | The Spinach Supreme Pizza | 950               | 15277.75       | 1.87      |
| 4 | The Mediterranean Pizza   | 934               | 15360.50       | 1.88      |
| 5 | The Spinach Pesto Pizza   | 970               | 15596.00       | 1.91      |

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
|   | name                      | size | Subtotal_Quantity | Subtotal_Sales | pct_Sales |
|:---:|:-------------------------:|:----:|:-----------------:|:--------------:|:---------:|
| 1 | The Greek Pizza           | XXL  | 28                | 1006.60        | 0.12      |
| 2 | The Calabrese Pizza       | S    | 99                | 1212.75        | 0.15      |
| 3 | The Chicken Alfredo Pizza | S    | 96                | 1224.00        | 0.15      |
| 4 | The Green Garden Pizza    | L    | 95                | 1923.75        | 0.24      |
| 5 | The Mexicana Pizza        | S    | 162               | 1944.00        | 0.24      |

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
|   | name    | Subtotal_Quantity | Subtotal_Sales | pct_Sales |   
|:---:|:-------:|:-----------------:|:--------------:|:---------:|
| 1 | Classic | 14888             | 220053.10      | 26.91     |   
| 2 | Supreme | 11987             | 208197.00      | 25.46     |   
| 3 | Chicken | 11050             | 195919.50      | 23.96     |   
| 4 | Veggie  | 11649             | 193690.45      | 23.68     |   


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
|   | name                    | size | Subtotal_Quantity | Subtotal_Sales | pct_Sales |
|:---:|:-----------------------:|:----:|:-----------------:|:--------------:|:---------:|
| 1 | The Thai Chicken Pizza  | L    | 487               | 10105.25       | 3.55      |
| 2 | The Five Cheese Pizza   | L    | 497               | 9194.50        | 3.23      |
| 3 | The Spicy Italian Pizza | L    | 426               | 8839.50        | 3.10      |
| 4 | The Big Meat Pizza      | S    | 725               | 8700.00        | 3.06      |
| 5 | The Four Cheese Pizza   | L    | 458               | 8221.10        | 2.89      |

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
|   | name                    | size | Subtotal_Quantity | Subtotal_Sales | pct_Sales |
|:---:|:-----------------------:|:----:|:-----------------:|:--------------:|:---------:|
| 1 | The Thai Chicken Pizza  | L    | 411               | 8528.25        | 3.59      |
| 2 | The Five Cheese Pizza   | L    | 409               | 7566.50        | 3.19      |
| 3 | The Spicy Italian Pizza | L    | 355               | 7366.25        | 3.10      |
| 4 | The Four Cheese Pizza   | L    | 393               | 7054.35        | 2.97      |
| 5 | The Big Meat Pizza      | S    | 539               | 6468.00        | 2.73      |

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
|   | name                    | size | Subtotal_Quantity | Subtotal_Sales | pct_Sales |
|:---:|:-----------------------:|:----:|:-----------------:|:--------------:|:---------:|
| 1 | The Thai Chicken Pizza  | L    | 457               | 9482.75        | 3.65      |
| 2 | The Five Cheese Pizza   | L    | 469               | 8676.50        | 3.34      |
| 3 | The Four Cheese Pizza   | L    | 425               | 7628.75        | 2.94      |
| 4 | The Spicy Italian Pizza | L    | 364               | 7553.00        | 2.91      |
| 5 | The Big Meat Pizza      | S    | 577               | 6924.00        | 2.67      |

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
|   | name                    | size | Subtotal_Quantity | Subtotal_Sales | pct_Sales |
|:---:|:-----------------------:|:----:|:-----------------:|:--------------:|:---------:|
| 1 | The Thai Chicken Pizza  | L    | 659               | 13674.25       | 3.48      |
| 2 | The Five Cheese Pizza   | L    | 675               | 12487.50       | 3.17      |
| 3 | The Big Meat Pizza      | S    | 959               | 11508.00       | 2.92      |
| 4 | The Four Cheese Pizza   | L    | 639               | 11470.05       | 2.92      |
| 5 | The Spicy Italian Pizza | L    | 540               | 11205.00       | 2.85      |

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
|   | name                      | size | Subtotal_Quantity | Subtotal_Sales | pct_Sales |
|:---:|:-------------------------:|:----:|:-----------------:|:--------------:|:---------:|
| 1 | The Greek Pizza           | XXL  | 9                 | 323.55         | 0.11      |
| 2 | The Chicken Alfredo Pizza | S    | 33                | 420.75         | 0.15      |
| 3 | The Calabrese Pizza       | S    | 44                | 539.00         | 0.19      |
| 4 | The Mexicana Pizza        | S    | 51                | 612.00         | 0.21      |
| 5 | The Green Garden Pizza    | L    | 32                | 648.00         | 0.23      |

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
|   | name                      | size | Subtotal_Quantity | Subtotal_Sales | pct_Sales |
|:---:|:-------------------------:|:----:|:-----------------:|:--------------:|:---------:|
| 1 | The Greek Pizza           | XXL  | 7                 | 251.65         | 0.11      |
| 2 | The Chicken Alfredo Pizza | S    | 24                | 306.00         | 0.13      |
| 3 | The Calabrese Pizza       | S    | 36                | 441.00         | 0.19      |
| 4 | The Mexicana Pizza        | S    | 47                | 564.00         | 0.24      |
| 5 | The Italian Supreme Pizza | S    | 50                | 625.00         | 0.26      |

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
|   | name                      | size | Subtotal_Quantity | Subtotal_Sales | pct_Sales |
|:---:|:-------------------------:|:----:|:-----------------:|:--------------:|:---------:|
| 1 | The Greek Pizza           | XXL  | 7                 | 251.65         | 0.10      |
| 2 | The Calabrese Pizza       | S    | 31                | 379.75         | 0.15      |
| 3 | The Chicken Alfredo Pizza | S    | 31                | 395.25         | 0.15      |
| 4 | The Mexicana Pizza        | S    | 41                | 492.00         | 0.19      |
| 5 | The Green Garden Pizza    | L    | 30                | 607.50         | 0.23      |

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
|   | name                      | size | Subtotal_Quantity | Subtotal_Sales | pct_Sales |
|:---:|:-------------------------:|:----:|:-----------------:|:--------------:|:---------:|
| 1 | The Greek Pizza           | XXL  | 11                | 395.45         | 0.10      |
| 2 | The Chicken Alfredo Pizza | S    | 39                | 497.25         | 0.13      |
| 3 | The Calabrese Pizza       | S    | 47                | 575.75         | 0.15      |
| 4 | The Mexicana Pizza        | S    | 72                | 864.00         | 0.22      |
| 5 | The Green Garden Pizza    | L    | 43                | 870.75         | 0.22      |

