USE master;
GO

-- Drop and recreate the database if exists
IF EXISTS (SELECT 1 
			FROM sys.databases 
			WHERE name = 'DataWareHouse')
BEGIN
	ALTER DATABASE DataWareHouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWareHouse
END;
GO

-- Create Database 'DataWareHouse'
CREATE DATABASE DataWareHouse;
GO

USE DataWareHouse;
GO

-- Creating Schema for each layer
Create SCHEMA bronze;
GO   
Create SCHEMA silver;
GO
Create SCHEMA gold;
GO



