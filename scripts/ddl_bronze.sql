/* 
================================================
DDL Scripts : Create Bronze Table
            this scripts creates the tables in the bronze schema dropping exisiting tables
            if they already exits 
            run the scripts to redefine the ddl structure of bronze tables 
======================================
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


create table Bronze.crm_cust_info(
cst_id int,
cst_key nvarchar(50),
cst_firstname nvarchar(50),
cst_lastname nvarchar(50),
cst_material_status nvarchar(50),
cst_gndr nvarchar(50),
cst_create_date date
);


create table Bronze.crm_prd_info(
prd_id int,
prd_key nvarchar(50),
prd_nm nvarchar(50),
prd_cost int,
prd_line nvarchar(50),
prd_start_dt datetime,
prd_end_dt datetime
);

create table Bronze.crm_sales_details(
sls_ord_num nvarchar(50),
sls_prd_key nvarchar(50),
sls_cust_id int,
sls_order_dt int,
sls_ship_dt int,
sls_due_dt int,
sls_sales int,
sls_quantity int,
sls_price int
);

create table Bronze.erp_loc_a101(
cid nvarchar(50),
cntry nvarchar(50)

);


create table Bronze.erp_cust_az12(
cid nvarchar(50),
bdate date,
gen nvarchar(50)

);

create table Bronze.erp_px_cat_g1v2(
id nvarchar(50),
cat nvarchar(50),
subcat nvarchar(50),
maintenance nvarchar(50)

);


--- inserting bulk file to the tables 

create or alter procedure Bronze.load_bronze as
begin
	declare @starttime datetime,@endtime datetime
	begin try 
		print '======================================================'
		print'loding bronze layer'
		print '======================================================='


		print 'loading CRM tables '
		set @starttime =getdate()
		print '>>truncating table : Bronze.crm_cust_info'
		truncate table Bronze.crm_cust_info
		print '>>inserting into :Bronze.crm_cust_info'
		bulk insert Bronze.crm_cust_info
		from 'C:\Users\sai\Downloads\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		with (
		firstrow=2,
		fieldterminator=',',
		tablock
		);
		set @endtime= getdate()
		print ' loading duration'+cast(datediff(second,@starttime,@endtime) as nvarchar) + 'seconds'
		print ' ---------'

		set @starttime =getdate()
		print '>>truncating table : Bronze.crm_prd_info'
		truncate table Bronze.crm_prd_info
		print '>>inserting data into: Bronze.crm_prd_info'
		bulk insert Bronze.crm_prd_info
		from 'C:\Users\sai\Downloads\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		with (
		firstrow=2,
		fieldterminator=',',
		tablock
		);
		set @endtime= getdate()
		print ' loading duration'+cast(datediff(second,@starttime,@endtime) as nvarchar) + 'seconds'
		print ' ---------'
		set @starttime =getdate()
		print '>>truncating table :Bronze.crm_sales_details'
		truncate table Bronze.crm_sales_details
		print '>>inserting data into :Bronze.crm_sales_details'
		bulk insert Bronze.crm_sales_details
		from 'C:\Users\sai\Downloads\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		with (
		firstrow=2,
		fieldterminator=',',
		tablock
		);
		set @endtime= getdate()
		print ' loading duration'+cast(datediff(second,@starttime,@endtime) as nvarchar) + 'seconds'
		print ' ---------'
	
		print 'loading ERP tables '
		set @starttime =getdate()
		print '>>truncating table :Bronze.erp_cust_az12'
		truncate table Bronze.erp_cust_az12
		print '>>inserting data into :Bronze.erp_cust_az12'
		bulk insert Bronze.erp_cust_az12
		from 'C:\Users\sai\Downloads\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		with (
		firstrow=2,
		fieldterminator=',',
		tablock

		);
		set @endtime= getdate()
		print ' loading duration'+cast(datediff(second,@starttime,@endtime) as nvarchar) + 'seconds'
		print ' ---------'
		set @starttime =getdate()
		print '>>truncating table :Bronze.erp_loc_a101'
		truncate table Bronze.erp_loc_a101
		print '>>inserting data into :Bronze.erp_loc_a101'
		bulk insert Bronze.erp_loc_a101
		from 'C:\Users\sai\Downloads\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		with (
		firstrow=2,
		fieldterminator=',',
		tablock
		);
		set @endtime= getdate()
		print ' loading duration'+cast(datediff(second,@starttime,@endtime) as nvarchar) + 'seconds'
		print ' ---------'
		set @starttime =getdate()
		print '>>truncating table :Bronze.erp_px_cat_g1v2'
		truncate table Bronze.erp_px_cat_g1v2
		print '>>inserting data into:Bronze.erp_px_cat_g1v2'
		bulk insert Bronze.erp_px_cat_g1v2
		from 'C:\Users\sai\Downloads\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		with (
		firstrow=2,
		fieldterminator=',',
		tablock
		);
		set @endtime= getdate()
		print ' loading duration'+cast(datediff(second,@starttime,@endtime) as nvarchar) + 'seconds'
		print ' ---------'
	end try
	begin catch 
		print '======================================='
		print 'Error occoured during bronze layer'
		print 'error message'+error_message()
		print 'error message'+cast(error_number() as nvarchar)
		print 'error message'+cast(error_state()as nvarchar)

		print '======================================='
	end catch 

end

exec Bronze.load_bronze




