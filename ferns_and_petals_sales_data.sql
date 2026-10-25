CREATE DATABASE ferns_and_petals_sales_data;
USE ferns_and_petals_sales_data;
SHOW TABLES FROM ferns_and_petals_sales_data;
SELECT * FROM customers;
SELECT * FROM orders;
SELECT * FROM products;

CREATE OR REPLACE VIEW ferns_and_petals AS
	SELECT 
		c.Customer_ID, c.Name, o.Order_ID, o.Product_ID, p.Product_Name, p.Category, o.Quantity, p.`Price (INR)` AS Price, 
        STR_TO_DATE(o.Order_Date, '%d-%m-%Y') AS Order_Date ,  -- Order_Date tells you which day the order was placed.
        CAST(o.Order_Time AS TIME) AS Order_Time, -- Order_Time tells you what time of day the order was placed.
        STR_TO_DATE(o.Delivery_Date, '%d-%m-%Y') AS Delivery_Date, -- Delivery_Date tells you which day it was delivered.
        CAST(o.Delivery_Time AS TIME) AS Delivery_Time, -- Delivery_Time tells you what time of day the order was delivered.
        c.City, o.Location, o.Occasion, c.Gender
    FROM customers c
    JOIN orders o ON c.Customer_ID = o.Customer_ID
    JOIN products p ON o.Product_ID = p.Product_ID;
    
SELECT * FROM ferns_and_petals;

SELECT SUM(Price) AS 'Total Revenue'
FROM ferns_and_petals;
-- The total revenue generated from the sales is 1156108 INR 
-- Get the month with the highest total revenue? February has the highest total revenue of INR 221368 followed by November then July. October has the lowest Revenue generated INR 47595
SELECT MONTH(STR_TO_DATE(Order_Date, '%d-%m-%Y')) AS Month, SUM(Price) AS 'Total Revenue'
FROM ferns_and_petals
GROUP BY Month
ORDER BY 'Total Revenue' DESC;
-- 2a. Average Order and Delivery Time: Evaluate the time taken for orders to be delivered.

-- Average Order and Delivery Time


-- Average Order and Delivery Time

SELECT
    COUNT(*) AS total_orders,
    ROUND(AVG(TIMESTAMPDIFF(
        MINUTE,
        TIMESTAMP(Order_Date, Order_Time),
        TIMESTAMP(Delivery_Date, Delivery_Time)
    )), 2) AS avg_delivery_time_minutes,

    ROUND(AVG(TIMESTAMPDIFF(
        MINUTE,
        TIMESTAMP(Order_Date, Order_Time),
        TIMESTAMP(Delivery_Date, Delivery_Time)
    )) / 60, 2) AS avg_delivery_time_hours,

    MIN(TIMESTAMPDIFF(
        MINUTE,
        TIMESTAMP(Order_Date, Order_Time),
        TIMESTAMP(Delivery_Date, Delivery_Time)
    )) AS fastest_delivery_minutes,

    MAX(TIMESTAMPDIFF(
        MINUTE,
        TIMESTAMP(Order_Date, Order_Time),
        TIMESTAMP(Delivery_Date, Delivery_Time)
    )) AS slowest_delivery_minutes

FROM ferns_and_petals
WHERE Order_Date IS NOT NULL
  AND Order_Time IS NOT NULL
  AND Delivery_Date IS NOT NULL
  AND Delivery_Time IS NOT NULL
  AND TIMESTAMP(Delivery_Date, Delivery_Time)
      >= TIMESTAMP(Order_Date, Order_Time);
-- Findings: Average delivery time: 7,921.78 minutes, equivalent to approximately 132.03 hours or 5.5 days.Fastest delivery time: 161 minutes, approximately 2 hours and 41 minutes.Slowest delivery time: 15,630 minutes, approximately 10.85 days.Number of valid orders analyzed: 1,000.This variation suggests that some orders are delivered quickly while others experience substantial delays.


SELECT DISTINCT Category
FROM ferns_and_petals;
-- BY USING CTE BELOW
WITH time_metrics AS (
	SELECT 
		Category,
        Quantity,
        TIMESTAMPDIFF(
			HOUR,
            TIMESTAMP(Order_Date, Order_Time),
            TIMESTAMP(Delivery_Date, Delivery_Time)
		) AS order_delivery_by_hours
	FROM ferns_and_petals)
SELECT 
	Category,
    SUM(Quantity) AS quantity_sold,
    ROUND(AVG (order_delivery_by_hours), 2) AS avg_delivery_hours
FROM time_metrics
GROUP BY Category
ORDER BY avg_delivery_hours;

-- Plants have 306 units sold and the least avg_delivery time(121.91 hours) while cake has the most avg delivert time(143.84 hours) and 375 units sold.
-- Breakdown: Category, quantity_sold, avg_delivery_hours ,'Plants', '306', '121.91','Soft Toys', '503', '124.69','Raksha Bandhan', '278', '126.62','Mugs', '232', '128.38','Colors', '810', '133.41','Sweets', '541', '136.46','Cake', '375', '143.83'
-- 2b.  what time of day customers place orders?

SELECT 
	HOUR(Order_Time) AS order_hour,
	COUNT(*) AS orders
FROM ferns_and_petals
GROUP BY order_hour
ORDER BY orders DESC;
-- The top 3 hours with the most orders are 7PM, 7AM and 9AM. Time of day with the least orders is 10AM.

-- 3. Monthly Sales Performance: Examine how sales fluctuate across the months of 2023.
SELECT 
	MONTH(Order_Date) AS month,
    COUNT(*) AS orders,
    SUM(Quantity) AS quantity_sold,
    SUM(Quantity*Price) AS revenue
FROM ferns_and_petals
WHERE YEAR(Order_Date) = 2023
GROUP BY month
ORDER BY month;
-- February had the highest quantity sold follwed by March then August which is simmiar with number of orders made. But August had the highest revenue made followed by February then March. January had the least in all categories,  making it the weakest-performing month.
-- Breakdown: month, orders, quantity_sold,revenue, 1	34	92	95468,2	213	673	7045093	166	474	511823,4	40	122	140393,5	43	139	150346,6	45	149	157913,7	39	117	135826,8	165	517	737389,9	40	116	136938,10	39	119	151619,11	134	410	449169,12	42	117	149591

-- 4a. Top Products by Revenue: Determine which products are the top revenue generators.
SELECT 
	Product_Name,
    SUM(Quantity*Price) AS revenue
FROM ferns_and_petals
GROUP BY Product_Name
ORDER BY revenue DESC;
-- The top 5 product are Magnam Set(121905), Quia Gift(114476), Dolores Gift(106624),Harum Pack(101556),Deserunt Box(97665)
-- These products are the strongest revenue contributors and should be prioritized for inventory availability, targeted promotions, and marketing campaigns to sustain their strong performance.
-- 4b. Top Determine which products are the top revenue generators per month.
SELECT 
	MONTH(Order_Date) AS month,
	Product_Name,
    SUM(Quantity*Price) AS revenue
FROM ferns_and_petals
GROUP BY month,Product_Name
ORDER BY month ASC, revenue DESC;
-- The top product for each month is January - Dignissimos Pack(19764), Feb - Eius Gift(85904), Mar - Harum Pack(60606), April - Deserunt Box(26810), May - Expedita Gift(20928), June - Error Gift(18461), July- Magnam Set(17415), AUG - Dolores Gift(106624), Sep- Provident Pack(19230), Oct- Deserunt Box(19150), Nov -Aut Box(81057), Dec -Expedita Gift(17440) 
-- Product preferences vary significantly by month. This seasonal variation suggests that customer demand changes throughout the year, highlighting an opportunity to plan inventory, promotions, and marketing campaigns around monthly product trends.
-- Each month has its most purchased product generting revenue ensure its stocked for maximum revenue/sales
-- 5a. Customer Spending Analysis: Understand how much customers are spending on average. In general category wise and occassion wise, are males more spenders?

SELECT 
	COUNT(DISTINCT Customer_ID),
    AVG(Price*Quantity) AS avg_revenue
    FROM ferns_and_petals;
-- On average acustomer spends 3520.99 INR and we have 100 unique customers
--  This indicates a solid average customer value and provides an opportunity to increase overall revenue by retaining existing customers and encouraging repeat purchases.
-- Understand how much customers are spending on average, gender wise

SELECT 
	Gender,
    SUM(Quantity),
    ROUND((SUM(Quantity*Price)/COUNT(*)),2) AS avg_order_value
    FROM ferns_and_petals
    GROUP BY Gender;
					-- OR --
WITH spending AS (
	SELECT 
		Gender,
        SUM(Quantity) AS quantity_purchased,
        SUM(Quantity*Price) AS revenue,
        COUNT(*) AS orders
	FROM ferns_and_petals
    GROUP BY Gender )
SELECT
	Gender,
    quantity_purchased,
    ROUND(revenue/orders , 2) AS avg_order_value
FROM spending
ORDER BY avg_order_value DESC;
-- Female are high-value spenders 3524.97 compared to males 3517.14 while else males purchased more products 1563 compared to females 1482
-- The business could use gender-specific promotions to increase spending among male customers and further strengthen sales from female customers.
-- 6. Sales Performance by Top 5 Product: Track the sales performance of top 5 products.
SELECT
	Product_Name,
    SUM(Quantity) AS quantity_sold,
    COUNT(*) AS orders
FROM ferns_and_petals
GROUP BY Product_Name
ORDER BY quantity_sold DESC 
LIMIT 5;
-- the top 5 purchased products are Dignissimos Pack (82), Quia Gift (80), Error Gift (74), Ad Box (72), and Aliquam Box (65).
-- These products show the strongest customer demand and could be prioritized for inventory planning, promotions, and availability to avoid stockouts.

SELECT
	Category,
	Product_Name,
    SUM(Quantity) AS quantity_sold,
    COUNT(*) AS orders
FROM ferns_and_petals
GROUP BY Category, Product_Name
ORDER BY quantity_sold DESC 
LIMIT 5;
-- What you can say from this data: Dignissimos Pack is the best-selling product, with 82 units sold across 27 orders.Ad Box is second, with 72 units across 23 orders.Aliquam Box sold 65 units across 23 orders.Fugit Set and Magnam Set both sold 63 units, but Fugit Set had more orders (23 vs. 19).Soft Toys appears twice in the top 5, indicating that two of its products performed strongly.
-- Dignissimos Pack was the top-selling product by quantity, while Soft Toys had two products among the top five, indicating strong demand for products in this category.
-- 7. Top 10 Cities by Number of Orders: Find out which cities are placing the highest number of orders.
SELECT City, COUNT(*) AS Orders -- Quantity*Price AS Revenue
FROM ferns_and_petals
GROUP BY City
ORDER BY Orders DESC
LIMIT 10;

-- Top 10 cities with the highest orders are:'Imphal', '29','Dhanbad', '28','Kavali', '27','Haridwar', '24','Bidhannagar', '21','Dibrugarh', '21','Guntakal', '20','North Dumdum', '19','Bhatpara', '18','Bilaspur', '18',
-- What you can say from this data:Imphal, Dhanbad, and Kavali are the top three cities by order volume, making them useful for understanding customer demand and identify successful strategies that drives orders that could be replicated elsewhere. The remaining cities also show order activity, ranging from 18 to 24.
SELECT  Customer_ID, City, Location
FROM ferns_and_petals
WHERE Customer_ID = 'C096'; -- 'C029'   'C011'  'C041'
-- What you can say from this data: Is that a customer can order for diferent Locations but in the same city 

-- 8. Order Quantity vs. Delivery Time: Analyze if higher order quantities impact delivery times.
SELECT * FROM ferns_and_petals;
SELECT COUNT(DISTINCT Product_ID) FROM ferns_and_petals;
WITH Timelines AS (
	SELECT 
		Customer_ID,
        Name,
        Quantity,
        Quantity*Price AS Revenue,
        TIMESTAMPDIFF(	
			QWHOUR, 
            TIMESTAMP(Order_Date, Order_Time),
            TIMESTAMP(Delivery_Date, Delivery_Time) 
            ) AS order_delivery_time
	FROM ferns_and_petals)
SELECT 
	Customer_ID,
	Name,
	SUM(Quantity) AS Total_Quantity,
    SUM(Revenue),
    ROUND(AVG(order_delivery_time), 2) AS Delivery_time
FROM Timelines
GROUP BY Customer_ID, Name
ORDER BY Delivery_time DESC;

-- What you can say from this data: From querying groups data by customer, larger order quantities do not automatically translate into longer delivery times. Case example is C083, Aaryahi Sodi has a total quantity of 45 and average delivery time of 174.64 hourd which is lower than C010, Drchit Dave whose total quantity was 21 and average delivery time is 186.13.
-- Customer_ID,Name,Total_Quantity,    SUM(Revenue), Delivery_time: 'C027', 'Kashvi Sur', '24', '33149', '200.63','C010', 'Darshit Dave', '21', '24931', '186.13','C083', 'Aaryahi Sodhi', '45', '42088', '174.64','C080', 'Mohanlal Garde', '17', '22226', '174.25','C029', 'Badal Sathe', '41', '46420', '167.00'
-- Comparing using order groups:  individual order quantity and average delivery time in minutes


WITH Timelines AS (
    SELECT
        Customer_ID,
        Name,
        Quantity,
        TIMESTAMPDIFF(
            MINUTE,
            TIMESTAMP(Order_Date, Order_Time),
            TIMESTAMP(Delivery_Date, Delivery_Time)
        ) AS Order_Delivery_Minutes
    FROM ferns_and_petals
    WHERE Order_Date IS NOT NULL
      AND Order_Time IS NOT NULL
      AND Delivery_Date IS NOT NULL
      AND Delivery_Time IS NOT NULL
),
Order_Categories AS (
    SELECT
        Customer_ID,
        Name,
        Quantity,
        Order_Delivery_Minutes,
        CASE
            WHEN Quantity = 1 THEN '(1)'
            WHEN Quantity = 2 THEN '(2)'
            WHEN Quantity = 3 THEN '(3)'
            WHEN Quantity = 4 THEN '(4)'
            WHEN Quantity = 5 THEN '(5)'
            WHEN Quantity = 6 THEN '(6)'
            WHEN Quantity = 7 THEN '(7)'
            WHEN Quantity = 8 THEN '(8)'
            WHEN Quantity = 9 THEN '(9)'
            ELSE '(10+)'
        END AS Order_Size
    FROM Timelines
    WHERE Order_Delivery_Minutes >= 0
)
SELECT
    Order_Size,
    COUNT(*) AS Total_Orders,
    COUNT(DISTINCT Customer_ID) AS Total_Clients,
    SUM(Quantity) AS Total_Quantity,
    ROUND(AVG(Quantity), 2) AS Avg_Quantity,
    ROUND(AVG(Order_Delivery_Minutes), 2)
        AS Avg_Delivery_Minutes
FROM Order_Categories
GROUP BY Order_Size
ORDER BY
    CASE Order_Size
        WHEN '(1)' THEN 1
        WHEN '(2)' THEN 2
        WHEN '(3)' THEN 3
        WHEN '(4)' THEN 4
        WHEN '(5)' THEN 5
        WHEN '(6)' THEN 6
        WHEN '(7)' THEN 7
        WHEN '(8)' THEN 8
        WHEN '(9)' THEN 9
        ELSE 10
    END;
-- Conclusion: Based on the analysis of 1,000 orders with quantities ranging from 1 to 5 items, there is no consistent relationship between order quantity and delivery time. Orders containing 3 items had the longest average delivery time (8,303.24 minutes), while orders containing 4 items had the shortest (7,545.18 minutes). This suggests that increasing order quantity does not necessarily result in longer delivery times within the observed data.



    
   WITH Order_Timelines AS (
    SELECT
        Quantity,
        TIMESTAMPDIFF(
            MINUTE,
            TIMESTAMP(Order_Date, Order_Time),
            TIMESTAMP(Delivery_Date, Delivery_Time)
        ) AS Delivery_Minute
    FROM ferns_and_petals
    WHERE Order_Date IS NOT NULL
      AND Order_Time IS NOT NULL
      AND Delivery_Date IS NOT NULL
      AND Delivery_Time IS NOT NULL
)
SELECT
    COUNT(*) AS Total_Orders,
    ROUND(
        (
            COUNT(*) * SUM(Quantity * Delivery_Minute)
            - SUM(Quantity) * SUM(Delivery_Minute)
        ) /
        NULLIF(
            SQRT(
                (
                    COUNT(*) * SUM(Quantity * Quantity)
                    - POW(SUM(Quantity), 2)
                ) *
                (
                    COUNT(*) * SUM(Delivery_Minute * Delivery_Minute)
                    - POW(SUM(Delivery_Minute), 2)
                )
            ),
            0
        ),
        4
    ) AS Correlation_Coefficient
FROM Order_Timelines
WHERE Delivery_Minute IS NOT NULL; 
      -- -- 8. Order Quantity vs. Delivery Time: Analyze if higher order quantities impact delivery times. Finding: The Pearson correlation analysis of 1,000 orders produced a coefficient of 0.0041, indicating a negligible linear relationship between order quantity and delivery time. Therefore, order quantity alone does not appear to be a useful predictor of delivery duration in this dataset. I.E order quantity does not appear to be associated with delivery time

-- SELECT DISTINCT Quantity FROM ferns_and_petals;
-- 9. Revenue Comparison Between Occasions: Compare revenue generated across different occasions.
SELECT 
	Occasion,
    SUM(Quantity * Price) AS Total_Revenue,
    ROUND(100.0 * SUM(Quantity * Price) / SUM( SUM(Quantity * Price)) OVER(), 1 ) AS Percentage_Revenue
FROM ferns_and_petals
GROUP BY Occasion
ORDER BY Total_Revenue DESC;
-- Findings:  Anniversary 674634 is the highest-revenue occasion, while Diwali 313783 is the lowest. The results suggest that occasion-based marketing and inventory planning could help the business focus on its strongest revenue opportunities.
-- Occasion, Total_Revenue, Percentage_Revenue: Anniversary	674634	19.2,Raksha Bandhan	631585	17.9,All Occasions	586176	16.6,Holi	574682	16.3,Birthday	408194	11.6,Valentine's Day	331930	9.4,Diwali	313783	8.9
-- 10. Product Popularity by Occasion: Identify which products are most popular during specific occasions.
SELECT 
	Product_Name,
    SUM(COUNT(Product_ID)) AS Quantity_sold
FROM ferns_and_petals;
-- GROUP BY Product_Name;


-- 10. Product Popularity by Occasion
WITH Product_Sales AS (
    SELECT
        Occasion,
        Product_Name,
        SUM(Quantity) AS Total_Quantity_Sold
    FROM ferns_and_petals
    GROUP BY Occasion, Product_Name
),
Ranked_Products AS (
    SELECT
        Occasion,
        Product_Name,
        Total_Quantity_Sold,
        RANK() OVER (
            PARTITION BY Occasion
            ORDER BY Total_Quantity_Sold DESC
        ) AS Product_Rank
    FROM Product_Sales
)
SELECT
    Occasion,
    Product_Name,
    Total_Quantity_Sold
FROM Ranked_Products
WHERE Product_Rank = 1
ORDER BY Occasion;
-- Finding: Occasion,Product_Name,Total_Quantity_Sold:'All Occasions', 'Magnam Set', '63','All Occasions', 'Fugit Set', '63','Anniversary', 'Dignissimos Pack', '82','Birthday', 'Ad Box', '72','Diwali', 'Quisquam Pack', '56','Holi', 'Aliquam Box', '65','Raksha Bandhan', 'Dolores Gift', '56','Raksha Bandhan', 'Aperiam Box', '56','Valentine\'s Day', 'Voluptate Pack', '57'
-- Finding: The results indicate that product preferences vary by occasion.













