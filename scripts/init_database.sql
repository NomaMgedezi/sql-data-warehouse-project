-- Create Database 'DataWarehouse'

/* 
======================================================================
Create Database and Schemas
======================================================================
Script Purpose:
	This script creates a new database named 'DataWarehouse' after checking if it already exists.
	If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas within the databse: 'bronze', 'silver', and 'gold'.


WARNING:
	Running this script will drop the entire 'DataWarehouse' database if it exists.
	All data in the database will be permanemtly deleted. Proceed with caustion and ensure you have proper backups before running this script.

*/

USE master;
GO

-- Drop and recreate the 'DataWarehouse' database if it exixts.
IF EXISTS (SELECT 1FROM sys.databases WHERE  name = 'DataWarehouse')
BEGIN 
	ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse;
	END;
	GO

-- Create the 'DataWarehouse' database

CREATE DATABASE DataWarehouse;

USE DataWarehouse;
GO

CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
