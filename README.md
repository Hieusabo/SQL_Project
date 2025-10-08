SQL Analytics Portfolio Project
1. Project Overview:

This project covers tasks including revenue analysis, customer behavior insights, product performance evaluation, and cumulative order tracking. 
The goal is to showcase proficiency in writing complex queries, aggregations, window functions, and report generation.

Database: orders.csv
Tables: Customers, Orders, OrderDetails, Products, Categories, ShippingMethods

2. Project Objectives:

The project focuses on answering key business questions such as:

Monthly revenue and profit trends

Top customers and products

Shipping performance analysis

Product classification by profitability

Customer segmentation by purchase behavior

Each task demonstrates a different SQL technique including aggregation, filtering, joins, window functions, and ranking.

3. Tasks Overview:
   
Task	Description
1	Calculate total revenue and profit for each month across all years.
2	Identify the top 10 customers by number of orders placed.
3	Determine which shipping method has the fastest average delivery time.
4	List top 10 products purchased most during summer (June, July, August).
5	Generate a product profit classification report (High, Medium, Low, Loss), including products never ordered.
6	List each product’s total order quantity, showing 0 for products never ordered.
7	Calculate average profit per order (sum per order, then average across all orders).
8	List customers who have never purchased products in the "Furniture" category.
9	List top 5 products in "Office Supplies" by total sales.
10	Find all 2016 orders by customers in "Consumer" or "Home Office" segments for "Technology" products.
11	List customers with more than 10 orders (ID, name, order count).
12	List all products containing "Desk" in the name.
13	Segment customers into four quartiles based on total sales.
14	Rank products within each category by total sales.
15	Calculate cumulative product order quantity over time.
   
5. Technical Skills Demonstrated

SQL Aggregations (SUM, AVG, COUNT)

Joins (INNER JOIN, LEFT JOIN)

Conditional logic (CASE WHEN)

Filtering and segmentation (WHERE, EXISTS, LIKE)

Window functions (ROW_NUMBER(), RANK(), NTILE(), SUM() OVER())

Handling missing data and zero-order products

Data classification and quartile segmentation

5. Usage:

Import the dataset into a SQL database (PostgreSQL).

Execute each SQL query in the order of tasks to reproduce reports and insights.

Modify queries to adapt to different date ranges, categories, or customer segments.

6. Project Outcome:

This project results in a set of analytical reports that can be used by business stakeholders to:

Track sales performance and profit trends

Identify top customers and products

Optimize shipping methods

Classify product profitability

Segment customers for marketing strategies
