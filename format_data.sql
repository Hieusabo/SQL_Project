CREATE TABLE final.raw_orders (
	rowid VARCHAR(255),
	orderid VARCHAR(255),
	orderdate VARCHAR(255),
	shipdate VARCHAR(255),
	shipmode VARCHAR(255),
	customerid VARCHAR(255),
	customername VARCHAR(255),
	segment VARCHAR(255),
	country VARCHAR(255),
	city VARCHAR(255),
	state VARCHAR(255),
	postalcode VARCHAR(255),
	region VARCHAR(255),
	productid VARCHAR(255),
	category VARCHAR(255),
	subcategory VARCHAR(255),
	productname VARCHAR(255),
	sales VARCHAR(255),
	quantity VARCHAR(255),
	discount VARCHAR(255),
	profit VARCHAR(255)
);

CREATE TABLE final.customers (
	customerid VARCHAR(255) PRIMARY KEY,
	customername VARCHAR(255)NOT NULL,
	segment VARCHAR(255) NOT NULL
);

CREATE TABLE final.products (
	productid VARCHAR(255) PRIMARY KEY,
	productname TEXT NOT NULL,
	category VARCHAR(255) NOT NULL,
	subcategory VARCHAR(255) NOT NULL
);

CREATE TABLE final.orders (
	orderid VARCHAR(255) PRIMARY KEY,
	orderdate DATE NOT NULL,
	customerid VARCHAR(255) NOT NULL,
	FOREIGN KEY (customerid) REFERENCES final.customers(customerid)
);

CREATE TABLE final.orderdetails (
	orderdetailid serial PRIMARY KEY,
	orderid VARCHAR(255) NOT NULL,
	productid VARCHAR(255) NOT NULL,
	quantity numeric(10,2) NOT NULL,
    sales numeric(10,2) NOT NULL,
	discount numeric(10,2) NOT NULL,
	profit numeric(10,2) NOT NULL,
	FOREIGN KEY (orderid) REFERENCES final.orders(orderid),
	FOREIGN KEY (productid) REFERENCES final.products(productid)
);

CREATE TABLE final.shipment (
	shipmentid serial PRIMARY KEY,
	orderid character varying(255) NOT NULL,
	shipdate date NOT NULL,
	shipmode character varying(255) NOT NULL,
	country character varying(255) NOT NULL,
	city character varying(255) NOT NULL,
	state character varying(255) NOT NULL,
	postalcode character varying(255) NOT NULL,
	region character varying(255) NOT NULL,
	FOREIGN KEY (orderid) REFERENCES final.orders(orderid)
);

-- Format Date
WITH check_date_format AS (
  SELECT
    orderid,
    orderdate AS orderdate_raw,
    CASE
      WHEN orderdate ~ '^\d{1,2}/\d{1,2}/\d{4}$' THEN 'DATE FORMAT MM/DD/YYYY'
      ELSE 'UNKNOWN FORMAT'
    END AS orderdate_format,
    shipdate AS shipdate_raw,
    CASE
      WHEN shipdate ~ '^\d{1,2}/\d{1,2}/\d{4}$' THEN 'DATE FORMAT MM/DD/YYYY'
      ELSE 'UNKNOWN FORMAT'
    END AS shipdate_format
  FROM final.raw_orders
)
SELECT * 
FROM check_date_format
WHERE shipdate_format = 'UNKNOWN FORMAT' 
   OR orderdate_format = 'UNKNOWN FORMAT';


WITH check_orderdate_shipdate AS (
  SELECT
    orderid,
    TO_DATE(orderdate, 'MM/DD/YYYY') AS order_date,
    TO_DATE(shipdate, 'MM/DD/YYYY') AS ship_date
  FROM final.raw_orders
  WHERE TO_DATE(shipdate, 'MM/DD/YYYY') < TO_DATE(orderdate, 'MM/DD/YYYY')
)
SELECT * FROM check_orderdate_shipdate;

-- check float format
WITH check_float_format AS (
    SELECT
        orderid,

        -- quantity
        quantity AS quantity_raw,
        CASE
            WHEN quantity ~ '^-?[0-9]+(\.[0-9]+)?$' THEN 'VALID FLOAT'
            ELSE 'INVALID FLOAT'
        END AS quantity_format,

        -- sales
        sales AS sales_raw,
        CASE
            WHEN sales ~ '^-?[0-9]+(\.[0-9]+)?$' THEN 'VALID FLOAT'
            ELSE 'INVALID FLOAT'
        END AS sales_format,

        -- discount
        discount AS discount_raw,
        CASE
            WHEN discount ~ '^-?[0-9]+(\.[0-9]+)?$' THEN 'VALID FLOAT'
            ELSE 'INVALID FLOAT'
        END AS discount_format,

        -- profit
        profit AS profit_raw,
        CASE
            WHEN profit ~ '^-?[0-9]+(\.[0-9]+)?$' THEN 'VALID FLOAT'
            ELSE 'INVALID FLOAT'
        END AS profit_format

    FROM final.raw_orders
)

SELECT *
FROM check_float_format
WHERE quantity_format = 'INVALID FLOAT'
   OR sales_format = 'INVALID FLOAT'
   OR discount_format = 'INVALID FLOAT'
   OR profit_format = 'INVALID FLOAT'
LIMIT 100;

-- check legit discount range
SELECT *
FROM final.raw_orders
WHERE discount::NUMERIC < 0
   OR discount::NUMERIC > 1;
   
-- Insert data
INSERT INTO final.customers (customerid, customername, segment)
SELECT DISTINCT customerid, customername, segment
FROM final.raw_orders;

INSERT INTO final.products (productid, productname, category, subcategory)
SELECT DISTINCT productid, productname, category, subcategory
FROM final.raw_orders
ON CONFLICT (productid) DO NOTHING;

INSERT INTO final.orders (orderid, orderdate, customerid)
SELECT DISTINCT
    orderid,
    TO_DATE(orderdate, 'MM/DD/YYYY'),
    customerid
FROM final.raw_orders;

INSERT INTO final.orderdetails (orderid, productid, quantity, sales, discount, profit)
SELECT DISTINCT
    orderid,
    productid,
    quantity::NUMERIC(10, 2), 
    sales::NUMERIC(10, 2),
    discount::NUMERIC(5, 2),
    profit::NUMERIC(10, 2)
FROM 
    final.raw_orders;

INSERT INTO final.shipments (orderid, shipmode, shipdate, country, city, state, postalcode, region)
SELECT DISTINCT
    orderid,
    shipmode,
    TO_DATE(shipdate, 'MM/DD/YYYY'), 
    country,
    city,
    state,
    postalcode,
    region
FROM final.raw_orders;


