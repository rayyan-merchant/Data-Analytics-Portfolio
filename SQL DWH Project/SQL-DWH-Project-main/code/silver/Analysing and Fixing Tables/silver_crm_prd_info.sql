select prd_id, prd_key, prd_nm, prd_cost,
	prd_line, prd_start_dt, prd_end_dt
from bronze.crm_prd_info


-- Check for Nulls or Duplicates in Primary Key
select prd_id, COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL


-- The product key contain a lot of information. So we need to split it into two columns so we can use it in meaningful way
select prd_key
from bronze.crm_prd_info
-- We will derive two new columns
-- 1. CategoryID: First 5 characters are Category ID that can acts as foreign key joining erp_px_cat_g1v2 table
select distinct id 
from bronze.erp_px_cat_g1v2

select SUBSTRING(prd_key, 1, 5) AS cat_id
from bronze.crm_prd_info

-- But in our table we have - as seperator but in the erp_cat table '_' as seperator
select REPLACE(SUBSTRING(prd_key,1,5), '-', '_') as cat_id
from bronze.crm_prd_info

-- 2. Product Key. We need this to join/connect sales details table
SELECT sls_prd_key
FROM bronze.crm_sales_details

select SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key
from bronze.crm_prd_info



-- Check for unwanted spaces
select prd_nm
from bronze.crm_prd_info
where prd_nm != TRIM(prd_nm)

-- Check for NULLS or Negative Numbers
select prd_cost
from bronze.crm_prd_info
where prd_cost < 0 or prd_cost IS NULL
-- Our column have  NULL values. Replace NULL with 0
select ISNULL(prd_cost, 0) AS prd_cost
FROM bronze.crm_prd_info


-- Data Standardization and Consistency
select prd_line,
	CASE UPPER(TRIM(prd_line)) 
		WHEN 'M' THEN 'Mountain'
		WHEN 'R' THEN 'Road'
		WHEN 'S' THEN 'Other Sales'
		WHEN 'T' THEN 'Touring'
		Else 'n/a'
	END AS prd_line
FROM bronze.crm_prd_info


-- Check for Invalid Date Order
-- End date must not be earlier than the start date
select *
from bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt

-- For complex transformation in SQL, typically narrow it down to a specific example and brainstorm multiple solution approaches
-- Each record must has a start date
-- Derive the End Date from the Start Date
-- End Date = Start Date of the Next Record - 1
select *,
	LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS prd_end_dt_test
FROM bronze.crm_prd_info
WHERE prd_key IN('AC-HE-HL-U509-R', 'AC-HE-HL-U509')


-- Also there is not use of keeping track of time stamp start and end date. Convert it into DATE
select CAST(prd_start_dt AS DATE) AS prd_start_dt,
	CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS DATE) AS prd_end_dt
from bronze.crm_prd_info



-- All modifications combined
SELECT prd_id,
	REPLACE(SUBSTRING(prd_key,1,5), '-', '_') as cat_id,   -- Extract category ID
	SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,  -- Extract product key
	prd_nm,
	ISNULL(prd_cost, 0) AS prd_cost,  -- Replace NULL cost with 0
	CASE UPPER(TRIM(prd_line)) 
		WHEN 'M' THEN 'Mountain'
		WHEN 'R' THEN 'Road'
		WHEN 'S' THEN 'Other Sales'
		WHEN 'T' THEN 'Touring'
		Else 'n/a'
	END AS prd_line,  -- Map product line codes to descriptive values
	CAST(prd_start_dt AS DATE) AS prd_start_dt,
	CAST(
		LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS DATE
		) AS prd_end_dt   -- Calculate end date as one day before the next start date
FROM bronze.crm_prd_info


-- Inserting Data
INSERT INTO silver.crm_prd_info(
	prd_id,
	cat_id,
	prd_key,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
)
SELECT prd_id,
	REPLACE(SUBSTRING(prd_key,1,5), '-', '_') as cat_id,
	SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
	prd_nm,
	ISNULL(prd_cost, 0) AS prd_cost,
	CASE UPPER(TRIM(prd_line)) 
		WHEN 'M' THEN 'Mountain'
		WHEN 'R' THEN 'Road'
		WHEN 'S' THEN 'Other Sales'
		WHEN 'T' THEN 'Touring'
		Else 'n/a'
	END AS prd_line,
	CAST(prd_start_dt AS DATE) AS prd_start_dt,
	CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS DATE) AS prd_end_dt
FROM bronze.crm_prd_info


-- Do all the checks again for silver table to make sure quality is fine


