-- Using Bulk Insert method to load data from a file to table in one go
-- Here we are doing TRUNC INSERT - meaning deleting all rows from a table, resetting it to an empty state, then inserting data (FULL LOAD)
 
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN

	DECLARE @start_time DATETIME,
			@end_time DATETIME,
			@batch_start_time DATETIME,
			@batch_end_time DATETIME;
			

	BEGIN TRY

	SET @batch_start_time = GETDATE();

		PRINT 'Loading BRONZE LAYER';

		PRINT '--------------------------';

		PRINT 'Loading CRM Tables';

		PRINT '--------------------------';

		SET @start_time = GETDATE();
		PRINT'Truncating Table: crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info;

		PRINT 'Inserting Data Into: crm_cust_info';
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\ND.COM\Downloads\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK  -- Locking the whole table while data is loading
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

		PRINT '--------------------------';

		SET @start_time = GETDATE();
		PRINT'Truncating Table: crm_prd_info';
		TRUNCATE TABLE bronze.crm_prd_info;

		PRINT 'Inserting Data Into: crm_prd_info';
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\ND.COM\Downloads\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK  
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

		PRINT '--------------------------';

		SET @start_time = GETDATE();
		PRINT'Truncating Table: crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details;

		PRINT 'Inserting Data Into: crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\ND.COM\Downloads\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK  
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

		PRINT '--------------------------';

		PRINT 'Loading ERP Tables';

		PRINT '--------------------------';

		SET @start_time = GETDATE();
		PRINT'Truncating Table: erp_cust_az12';
		TRUNCATE TABLE bronze.erp_cust_az12;

		PRINT 'Inserting Data Into: erp_cust_az12';
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Users\ND.COM\Downloads\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK  
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

		PRINT '--------------------------';

		SET @start_time = GETDATE();
		PRINT'Truncating Table: erp_loc_a101';
		TRUNCATE TABLE bronze.erp_loc_a101;

		PRINT 'Inserting Data Into: erp_loc_a101';
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Users\ND.COM\Downloads\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK  
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

		PRINT '--------------------------';

		SET @start_time = GETDATE();
		PRINT'Truncating Table: erp_px_cat_g1v2';
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;

		PRINT 'Inserting Data Into: erp_px_cat_g1v2';
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Users\ND.COM\Downloads\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK  
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

		PRINT '--------------------------';

		SET @batch_end_time = GETDATE();
		PRINT 'Bronze Layer Loading is completed';
		PRINT '>> Total Load Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';

	END TRY

	BEGIN CATCH

		-- You can create error logging table and add error messages there
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
		PRINT 'Error Message: ' + ERROR_MESSAGE();
		PRINT 'ERROR Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'ERROR State: ' + CAST(ERROR_STATE() AS NVARCHAR);

	END CATCH

END