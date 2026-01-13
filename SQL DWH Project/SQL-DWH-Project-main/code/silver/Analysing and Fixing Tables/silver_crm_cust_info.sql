-- First step is to explore the data in each table and find data quality issues

SELECT *
FROM bronze.crm_cust_info

  -- Checking if there are duplicates or any id is NULL in Primary Key

SELECT cst_id, Count(*)
from bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL

-- we have duplicates and nulls here here
		
SELECT * 
from bronze.crm_cust_info
where cst_id = 29466
-- removing duplicates and keeping the latest record only
SELECT *
FROM (
	SELECT *, 
		ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
	from bronze.crm_cust_info
	WHERE cst_id IS NOT NULL
)t WHERE flag_last = 1


-- Check for unwanted spaces in strings (check for all columns of string data type)
select cst_firstname 
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)

-- Removing unwanting spaces by placing trim function on columns where there are unwanted spaces
SELECT cst_id, cst_key, cst_key, 
	TRIM(cst_firstname) AS cst_firstname,
	TRIM(cst_lastname) AS cst_lastname, 
	cst_marital_status, cst_gndr, cst_create_date
FROM (
	SELECT *, 
		ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
	from bronze.crm_cust_info
	WHERE cst_id IS NOT NULL
)t WHERE flag_last = 1


-- Check the consistency of values in low cardinality columns

-- In columns marital status and gender we have low cardinality
Select DISTINCT cst_gndr
from bronze.crm_cust_info
-- In our data warehouse, we aim to store clear and meaningful values rather than using abbreviated terms
-- Instead of gender values of F or M, we will store it as Female and Male


-- Fixing Standardization
SELECT cst_id, cst_key, cst_key, 
	TRIM(cst_firstname) AS cst_firstname,
	TRIM(cst_lastname) AS cst_lastname, 
	CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
		WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
		ELSE 'n/a'
	END cst_marital_status,
	CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
		WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
		ELSE 'n/a'
	END cst_gndr,
	cst_create_date
FROM (
	SELECT *, 
		ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
	from bronze.crm_cust_info
	WHERE cst_id IS NOT NULL
)t WHERE flag_last = 1


-- we want to make sure that create date column is of DATE datatype not string
select cst_create_date
from bronze.crm_cust_info
WHERE cst_create_date != CAST(cst_create_date AS DATE)
-- All are DATE so no changes




-- Finally write insert statement for this table
INSERT INTO silver.crm_cust_info(
	cst_id,
	cst_key,
	cst_firstname,
	cst_lastname,
	cst_marital_status,
	cst_gndr,
	cst_create_date)

SELECT cst_id, cst_key, 
	TRIM(cst_firstname) AS cst_firstname,
	TRIM(cst_lastname) AS cst_lastname, 
	CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
		WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
		ELSE 'n/a'
	END cst_marital_status,
	CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
		WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
		ELSE 'n/a'
	END cst_gndr,
	cst_create_date
FROM (
	SELECT *, 
		ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
	from bronze.crm_cust_info
	WHERE cst_id IS NOT NULL
)t WHERE flag_last = 1



-- Just to make sure, do a quality check of the silver table
SELECT cst_id, Count(*)
from silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL


select cst_firstname 
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)


Select DISTINCT cst_gndr
from silver.crm_cust_info


-- Final Look
SELECT * FROM silver.crm_cust_info



/*
1. Removed Unwanted spaces
2. Data Normalization and Standardization (mapped coded values to meaningful user_friendly descroptions)
3. Handling Missing Data(Instead of having Null or empty string replace it to n/a
4. Removed duplicates and nulls from primary key
*/