select
	cst_id,
	cst_key,
	cst_firstname,
	cst_lastname,
	cst_marital_status,
	cst_gndr,
	cst_create_date,
	bdate,
	gen,
	la.cntry
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid


-- After Joining Table, check if any duplicates were introduced by the join logic
select cst_id, COUNT(*) FROM
(
	select
		cst_id,
		cst_key,
		cst_firstname,
		cst_lastname,
		cst_marital_status,
		cst_gndr,
		cst_create_date,
		bdate,
		gen,
		la.cntry
	FROM silver.crm_cust_info AS ci
	LEFT JOIN silver.erp_cust_az12 AS ca
	ON ci.cst_key = ca.cid
	LEFT JOIN silver.erp_loc_a101 la
	ON ci.cst_key = la.cid
)t GROUP BY cst_id
HAVING COUNT(*) > 1
-- No duplicates found


-- Currently gender information is coming from two sources crm customer table and erp cust table
-- So here we will do Data Integration
select DISTINCT
	ci.cst_gndr,
	ca.gen
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid
ORDER BY 1,2
-- There are data quality issue here. In some instances both the columns are not matching and giving different results

-- If there is a mismatch we need to check which data source is master for these values. And that source should be given priority

-- Assuming crm cust info table is master source
select DISTINCT
	ci.cst_gndr,
	ca.gen,
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
		 ELSE COALESCE(ca.gen, 'n/a')
	END AS new_gen
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid


-- RENAMING Columns to friendly, meaningful names
select
	cst_id AS customer_id,
	cst_key as customer_number,
	cst_firstname as first_name,
	cst_lastname as last_name,
	cst_marital_status as marital_status,
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
		 ELSE COALESCE(ca.gen, 'n/a')
	END AS gender,
	cst_create_date as create_date,
	bdate as birth_date,
	la.cntry as country
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid


-- Sort the columns into logical groups to improce readability
select
	cst_id AS customer_id,
	cst_key as customer_number,
	cst_firstname as first_name,
	cst_lastname as last_name,
	la.cntry as country,
	cst_marital_status as marital_status,
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
		 ELSE COALESCE(ca.gen, 'n/a')
	END AS gender,
	bdate as birth_date,
	cst_create_date as create_date
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid


-- Is it Fact Table or Dimension?
-- This table is describing customers and has no info about transaction
-- Therefore it is a Dimension Table

-- In dimension table you need a primary key for the dimension
-- If there is no clear primary key, you can create a surrogate key
-- Surrogate key is a system generated unique identifuer assigned to each record in a table
-- We can create it by either defining it in DDL or in Query using Window Function(Row_Number)
select
	ROW_NUMBER() OVER(Order by cst_id) AS customer_key,
	cst_id AS customer_id,
	cst_key as customer_number,
	cst_firstname as first_name,
	cst_lastname as last_name,
	la.cntry as country,
	cst_marital_status as marital_status,
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
		 ELSE COALESCE(ca.gen, 'n/a')
	END AS gender,
	bdate as birth_date,
	cst_create_date as create_date
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid




-- Now Lastly create Virtual Objects(Views)
CREATE VIEW gold.dim_customers AS
select
	ROW_NUMBER() OVER(Order by cst_id) AS customer_key,
	cst_id AS customer_id,
	cst_key as customer_number,
	cst_firstname as first_name,
	cst_lastname as last_name,
	la.cntry as country,
	cst_marital_status as marital_status,
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
			ELSE COALESCE(ca.gen, 'n/a')
	END AS gender,
	bdate as birth_date,
	cst_create_date as create_date
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid

-- Now check quality of new object(Dimension Table) View