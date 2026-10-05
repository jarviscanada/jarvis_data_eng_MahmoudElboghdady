-- Show table schema
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'retail' 
ORDER BYordinal_position;

-- Q1: Show first 10 rows
SELECT * 
FROM retail 
LIMIT 10;

-- Q2: Check # of records
SELECT COUNT(*) AS “count”
FROM retail;

-- Q3: Number of unique clients
SELECT COUNT(DISTINCT customer_id) AS “count”
FROM retail;

-- Q4: Invoice date range
SELECT MAX(invoice_date) AS “max”
	  , MIN(invoice_date) AS “min” 
FROM retail;

-- Q5: Number of unique SKUs
SELECT COUNT(DISTINCT stock_code) AS “count”
FROM retail;

-- Q6: Average invoice amount excluding negative invoices
SELECT AVG(invoice_total) AS “avg”
FROM (
  	SELECT invoice_no, SUM(unit_price * quantity) AS invoice_total
  	FROM retail
  	GROUP BY invoice_no
  	HAVING SUM(unit_price * quantity) > 0
	) AS positive_invoices;

-- Q7: Total revenue
SELECT SUM(unit_price * quantity) AS “sum”
FROM retail;

-- Q8: Total revenue by YYYYMM
SELECT
  CAST(EXTRACT(YEAR FROM invoice_date) * 100 + EXTRACT(MONTH FROM invoice_date) AS 	INTEGER) AS yyyymm,
  	SUM(unit_price * quantity) AS sum
FROM retail
GROUP BY yyyymm
ORDER BY yyyymm;
