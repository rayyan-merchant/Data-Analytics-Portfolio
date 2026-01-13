select cid, cntry
FROM bronze.erp_loc_a101

-- erp location table will join crm cust info table using cid and cust key

select cst_key FROM silver.crm_cust_info

-- cst_key: AW00011000   ,   cid: AW-00011000
-- There is a extra '-' in between in cid.

SELECT cid,
	REPLACE(cid, '-', '') cid
FROM bronze.erp_loc_a101
WHERE REPLACE(cid, '-', '') NOT IN 
(select cst_key FROM silver.crm_cust_info)


-- Data Standarization & Consistency (country)
SELECT DISTINCT
	cntry
FROM bronze.erp_loc_a101
-- There are quality issues

SELECT DISTINCT 
	cntry,
	CASE WHEN UPPER(TRIM(cntry)) = 'DE' THEN 'Germany'
		 WHEN UPPER(TRIM(cntry)) IN('US', 'USA') THEN 'United States'
		 WHEN UPPER(TRIM(cntry)) = '' OR cntry IS NULL THEN 'n/a'
		 ELSE TRIM(cntry)
	END AS cntry
FROM bronze.erp_loc_a101


-- Combining all modifications
SELECT
	REPLACE(cid, '-', '') cid,
	CASE WHEN UPPER(TRIM(cntry)) = 'DE' THEN 'Germany'
		 WHEN UPPER(TRIM(cntry)) IN('US', 'USA') THEN 'United States'
		 WHEN UPPER(TRIM(cntry)) = '' OR cntry IS NULL THEN 'n/a'
		 ELSE TRIM(cntry)
	END AS cntry
FROM bronze.erp_loc_a101




-- Inserting into Silver Table
INSERT INTO silver.erp_loc_a101(
	cid, cntry)
SELECT
	REPLACE(cid, '-', '') cid,
	CASE WHEN UPPER(TRIM(cntry)) = 'DE' THEN 'Germany'
		 WHEN UPPER(TRIM(cntry)) IN('US', 'USA') THEN 'United States'
		 WHEN UPPER(TRIM(cntry)) = '' OR cntry IS NULL THEN 'n/a'
		 ELSE TRIM(cntry)
	END AS cntry
FROM bronze.erp_loc_a101



-- Check the data quality of new table
select * from silver.erp_loc_a101