/* 
=======================================================================================================================
Create Database and Schemas 

=========================================================================================================================
Script Purpose:
  This script creates a new database and named as 'DataWarehouse' after checking if it already exits.
If the database exits, it is dropped and recreated. Additionally, the script set up three schemas within the database:
'Bronze' 'Silver' 'Gold'

Warning:
  Running this script will drop the entire 'DataWarehouse' database if exits.
  All data in database will be permenantly deleted.proceed with caution and ensure
  you have proper backups before running the scripts.

*/



--Create database ' DataWarehouse'

use master
--creating database
create database DataWarehouse
--using the database 
use DataWarehouse

--creating the schema
-- it is and logical container use to store the database objects like tables
-- stored procedures and views 

create schema Bronze;
GO
create schema Silver;
GO
create schema Gold;
GO
