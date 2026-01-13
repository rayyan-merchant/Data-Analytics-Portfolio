select sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price
FROM bronze.crm_sales_details


-- We need to connect sales details table to product info table using product key column. Check if data is same in both tables column or not
SELECT *
FROM bronze.crm_sales_details
WHERE sls_prd_key NOT IN(SELECT prd_key FROM silver.crm_prd_info)

-- We need to connect sales details table to customer info table using customer id column. Check if data is same in both tables column or not
SELECT *
FROM bronze.crm_sales_details
WHERE sls_cust_id NOT IN(SELECT cst_id FROM silver.crm_cust_info)

-- No problem in Foreign keys table so no transformations needed


-- order date, ship date and due date columns are INTEGERS not DATE

-- Check for Invalid Dates

-- Negative numbers or zeros can't be cast to a date. 
-- Also in this scenario the length of the date must be 8
-- Also check for outliers by validatin the boundaries of the date range 
select sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0 
	OR LEN(sls_order_dt) != 8
	OR sls_order_dt > 20500101 
	OR sls_order_dt < 19000101
-- Replace all Zeros and Dates with len != 8 with NULL
SELECT NULLIF(sls_order_dt, 0) sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0

-- Fixing sls_order_dt
select 
	CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
	END AS sls_order_dt
FROM bronze.crm_sales_details

-- apply same rules for shipping date and due date

-- Order Date must be earlier than the Shipping Date or Due Date
SELECT *
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt
-- No issues found



-- Business Rule: Sales = Quantity * Price
-- Also Sales,Quantity and Price must not be negatives or NULLS

SELECT sls_sales, sls_quantity, sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
	OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
	OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price

/*
Rules we are applying here:
1. If Sales is negative, zero or null, derive ut using Quantity and Price
2. If Price is zero or null, calculate it using Sales and Quantity
3. If Price is negative, convert it into positive
4.
*/

select 
	CASE WHEN sls_sales IS NULL OR sls_sales <=0 OR sls_sales != sls_quantity * ABS(sls_price)
		 THEN sls_quantity * ABS(sls_price)
		 ELSE sls_sales
	END AS sls_sales,
	CASE WHEN sls_price IS NULL OR sls_price <=0
		 THEN sls_sales / NULLIF(sls_quantity,0)
		 ELSE sls_price
	END AS sls_price
from bronze.crm_sales_details



-- All modifications combined 
select	
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
	END AS sls_order_dt,
	CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
	END AS sls_ship_dt,
	CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
	END AS sls_due_dt,
	CASE WHEN sls_sales IS NULL OR sls_sales <=0 OR sls_sales != sls_quantity * ABS(sls_price)
		 THEN sls_quantity * ABS(sls_price)
		 ELSE sls_sales
	END AS sls_sales,
	sls_quantity,
	CASE WHEN sls_price IS NULL OR sls_price <=0
		 THEN sls_sales / NULLIF(sls_quantity,0)
		 ELSE sls_price
	END AS sls_price
from bronze.crm_sales_details





-- Inserting Data into Silver Table
INSERT INTO silver.crm_sales_details(
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price
)
select	
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
	END AS sls_order_dt,
	CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
	END AS sls_ship_dt,
	CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
	END AS sls_due_dt,
	CASE WHEN sls_sales IS NULL OR sls_sales <=0 OR sls_sales != sls_quantity * ABS(sls_price)
		 THEN sls_quantity * ABS(sls_price)
		 ELSE sls_sales
	END AS sls_sales,
	sls_quantity,
	CASE WHEN sls_price IS NULL OR sls_price <=0
		 THEN sls_sales / NULLIF(sls_quantity,0)
		 ELSE sls_price
	END AS sls_price
from bronze.crm_sales_details



-- Check Data Quality for Silver Table
