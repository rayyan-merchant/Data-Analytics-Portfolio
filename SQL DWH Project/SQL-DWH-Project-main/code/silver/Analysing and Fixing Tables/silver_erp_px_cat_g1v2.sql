select
	id,
	cat,
	subcat,
	maintenance
FROM bronze.erp_px_cat_g1v2

-- We can connect this table with crm prd info table using id and prd key columns
select prd_key from silver.crm_prd_info

SELECT id
from bronze.erp_px_cat_g1v2
WHERE id NOT IN (select prd_key from silver.crm_prd_info)
-- There is no issue in the id column and can be joined directly



-- Check for unwanted spaces
SELECT * FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) 
	OR subcat != TRIM(subcat)
	OR maintenance != TRIM(maintenance)
-- No unwanted spaces found


-- Data Standardization and Consistency
select DISTINCT cat
from bronze.erp_px_cat_g1v2
-- Everything is fine

select DISTINCT subcat
FROM bronze.erp_px_cat_g1v2
-- Everything is fine

select DISTINCT maintenance
FROM bronze.erp_px_cat_g1v2
-- Everything is fine


-- The data qaulity of this table was very nice and there is no need for any transformations



-- Inserting data into silver layer
INSERT INTO silver.erp_px_cat_g1v2(
	id, cat, subcat, maintenance
)
SELECT
	id, cat, subcat, maintenance
FROM bronze.erp_px_cat_g1v2


-- Check quality of data in new table