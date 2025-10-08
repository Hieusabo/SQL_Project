-- Task 1 – Monthly Revenue and Profit:
-- Calculate the total revenue and profit for each month across all years.

SELECT
    EXTRACT (YEAR FROM orderdate) AS sales_year,
    EXTRACT (MONTH FROM orderdate) AS sales_month,
    SUM(od.sales) AS total_sales,
    SUM(od.profit) AS total_profit
FROM
    final.orders o
JOIN 
	final.orderdetails od 
	ON o.orderid = od.orderid
GROUP BY
    sales_year,
    sales_month
ORDER BY
    sales_year ASC,
    sales_month ASC;

-- Task 2 – Top Customers by Orders:
-- Identify the top 10 customers who placed the most orders.

SELECT 
	c.customerid,
	c.customername,
	COUNT(o.orderid) AS total_order
FROM 
	final.customers c
JOIN 
	final.orders o
	ON c.customerid = o.customerid
GROUP BY c.customerid, c.customername
ORDER BY total_order DESC
LIMIT 10;

-- Task 3 – Fastest Shipping Method:
-- Determine which shipping method has the fastest average delivery time.

SELECT 
	shipmode, 
	ROUND(AVG(shipdate - orderdate),0) AS avg_delivery_day
FROM final.shipments s
JOIN 
	final.orders o
ON o.orderid = s.orderid
GROUP BY shipmode
ORDER BY avg_ship ASC;

-- Task 4 – Top Summer Products:
-- List the top 10 products with the highest sales during the summer months (June, July, August).

SELECT 
	productname,
	sales,
	EXTRACT(MONTH FROM orderdate) AS month
FROM 
	final.products p
JOIN 
	final.orderdetails od
	ON od.productid = p.productid
JOIN 
	final.orders o
	ON o.orderid = od.orderid 
WHERE 
	EXTRACT(MONTH FROM orderdate) IN (6,7,8)
ORDER BY sales DESC
LIMIT 10;

-- Task 5 – Product Profit Classification:
-- Create a report listing each product's ID, name, and total profit classification:

-- Over 5000 → High

-- 1000–5000 → Medium

-- 0–1000 → Low

-- Below 0 → Loss
-- Include products in stock that were never ordered, treating their total profit as 0.

SELECT 
	p.productid,
	p.productname,
	COALESCE(SUM(o.profit), 0),
CASE
	WHEN SUM(profit) >= 5000 THEN 'High'
	WHEN SUM(profit) >= 1000 AND SUM(profit) <= 5000 THEN 'Medium'
	WHEN SUM(profit) > 0 AND SUM(profit) <= 1000 THEN 'Low'
	ELSE 'Loss'
END AS report
FROM final.products p
LEFT JOIN final.orderdetails o
ON p.productid = o.productid
GROUP BY p.productid;

-- Task 6 – Product Order Quantities:
-- List each product’s ID, name, and total order quantity. For products never ordered, show the quantity as 0.


SELECT 
	p.productid,
	p.productname,
	COALESCE(SUM(od.quantity), 0)
FROM 
	final.products p
LEFT JOIN 
	final.orderdetails od
	ON p.productid = od.productid
GROUP BY p.productname, p.productid;

-- Task 7 – Average Profit per Order:
-- Calculate the average profit per order. (First sum the profit for each order, then compute the average across all orders.)

SELECT 
	AVG(sum_profit)
FROM 
	(SELECT od.orderid, SUM(profit) AS sum_profit
	FROM final.orderdetails od
	GROUP BY od.orderid) AS op
JOIN 
	final.orders o
	ON o.orderid = op.orderid


-- Task 8 – Customers Who Didn’t Buy Furniture:
-- List the ID and name of customers who have never purchased any products in the "Furniture" category.

SELECT 
	customerid,
	customername
FROM 
	final.customers c
WHERE 
	NOT EXISTS (
			SELECT 1
			FROM final.orders o
			JOIN final.orderdetails od
			ON o.orderid = od.orderid
			JOIN final.products p
			ON od.productid = p.productid
			WHERE o.customerid = c.customerid 
			AND category = 'Furniture'
	);

-- -- Task 9 – Top Office Supplies Products:
-- List the top 5 products in the "Office Supplies" category by total sales.

SELECT 
	p.productname,
	p.category,
	SUM(sales) AS sum_sales
FROM 
	final.products p
JOIN 
	final.orderdetails od
	ON p.productid = od.productid
WHERE p.category = 'Office Supplies'
GROUP BY 
	p.productname,
	p.category
ORDER BY sum_sales DESC
LIMIT 5;

-- Task 10 – 2016 Technology Orders by Specific Customers:
-- Find all orders placed in 2016 by customers in the "Consumer" or "Home Office" segments for products in the "Technology" category.

SELECT 
	o.orderid,
	c.segment,
	p.category,
	EXTRACT (YEAR FROM orderdate)
FROM 
	final.customers c
JOIN 
	final.orders o
	ON c.customerid = o.customerid
JOIN 
	final.orderdetails od
	ON o.orderid = od.orderid
JOIN 
	final.products p
	ON od.productid = p.productid
WHERE 
	EXTRACT (YEAR FROM orderdate) = '2016'
AND c.segment IN('Consumer','Home Office')
AND p.category = 'Technology';
	
-- Task 11 – Frequent Customers:
-- List the ID, name, and total number of orders for customers who placed more than 10 orders.

SELECT 
	c.customerid,
	c.customername,
	COUNT(orderid)
FROM 
	final.customers c
JOIN 
	final.orders o
	ON c.customerid = o.customerid
GROUP BY 
	c.customerid, c.customername
HAVING COUNT(orderid) > 10;

-- Task 12 – Products Related to Desks:
-- List the ID and name of all products that include "Desk" in their name.

SELECT
	productid,
	productname
FROM 
	final.products
WHERE
	productname LIKE '%Desk%';

-- Task 13 – Customer Quartiles by Sales:
-- Divide customers into four quartiles based on their total sales, listing ID, name, total sales, and corresponding quartile.

SELECT
	c.customerid,
	c.customername,
	SUM(od.sales),
	NTILE(4) OVER (ORDER BY SUM(od.sales))
FROM 
	final.customers c
JOIN 
	final.orders o
	ON c.customerid = o.customerid
JOIN
	final.orderdetails od
	ON o.orderid = od.orderid
GROUP BY c.customerid,c.customername;

-- Task 14 – Product Sales Ranking by Category:
-- For each product, calculate total sales and rank products within the same category by total sales (highest sales = rank 1).

SELECT 
	p.productname,
	p.category,
	SUM(sales) AS sum_sales,
	DENSE_RANK() OVER (PARTITION BY p.category ORDER BY SUM(sales))
FROM 
	final.products p
JOIN 
	final.orderdetails od
	ON p.productid = od.productid
GROUP BY p.productname,p.category;
ORDER BY SUM(sales)

-- Task 15 – Cumulative Product Orders Over Time:
-- Calculate the cumulative order quantity over time for each product.

SELECT
	p.productid,
	p.productname,
	o.orderdate,
	od.quantity,
	SUM (od.quantity) OVER
		(PARTITION BY p.productid ORDER BY o.orderdate)
FROM 
	final.orders o
JOIN 
	final.orderdetails od
	ON o.orderid = od.orderid
JOIN 
	final.products p
	ON od.productid = p.productid
GROUP BY o.orderdate, od.quantity, p.productname, p.productid;






















