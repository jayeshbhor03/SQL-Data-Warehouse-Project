create or alter procedure Silver.load_silver as
Begin 
	---cleaning all things and inserting
	truncate table Silver.crm_cust_info
	insert into Silver.crm_cust_info (
	cst_id,
	cst_key,
	cst_firstname,
	cst_lastname,
	cst_material_status,
	cst_gndr,
	cst_create_date)
	select 
	cst_id,
	cst_key,
	trim(cst_firstname) cst_firstname,
	trim(cst_lastname) cst_lastname,

	case when upper(trim(cst_material_status))='S' then 'Single'
	when upper(trim(cst_material_status))='M' then 'Married'
	else 'N/A'
	end cst_material_status,
	case when upper(trim(cst_gndr))='F' then 'Female'
	when upper(trim(cst_gndr))='M' then 'Male'
	else 'N/A'
	end cst_gndr,

	cst_create_date
	from(
	select *,
	row_number() over(partition by cst_id order by cst_create_date desc) as flag_last
	from Bronze.crm_cust_info 
	where cst_id is not null
	)t
	where flag_last=1

	-----clean and load crm_prd_info


	--find is their any duplicate prd id 



	

	



	---inserting data to silver layer 

	truncate table Silver.crm_prd_info
	insert into Silver.crm_prd_info( prd_id,
	cat_id,
	prd_key,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt)
	select 
	prd_id ,

	replace(substring(prd_key,1,5),'-','_') as cat_id,
	substring(prd_key,7,len(prd_key)) as prd_key,
	prd_nm ,
	isnull(prd_cost,0) as prd_cost ,
	case 
	when upper(trim(prd_line))='M' then 'Mountain'
	when upper(trim(prd_line))='R' then 'Road'
	when upper(trim(prd_line))='S' then 'Other Sales'
	when upper(trim(prd_line))='T' then 'Touring'
	else 'N/A'
	end
	prd_line ,
	cast(prd_start_dt as date) as prd_start_dt,
	cast(lead(prd_start_dt) over (partition by prd_key order by prd_start_dt)-1 as date) as prd_end_dt
	from
	Bronze.crm_prd_info




	-- cleaning crm_sales Details from bronze and add it to silver
	truncate table Silver.crm_sales_details
	insert into Silver.crm_sales_details(
	sls_ord_num ,
	sls_prd_key ,
	sls_cust_id ,
	sls_order_dt ,
	sls_ship_dt ,
	sls_due_dt ,
	sls_sales ,
	sls_quantity ,
	sls_price)

	select  
	sls_ord_num,
	sls_prd_key ,
	sls_cust_id ,
	case 
	when sls_order_dt=0  or len(sls_order_dt) !=8 then null
	else cast(cast(sls_order_dt as nvarchar)as date) 
	end 
	sls_order_dt,
	case 
	when sls_ship_dt=0  or len(sls_ship_dt) !=8 then null
	else cast(cast(sls_ship_dt as nvarchar)as date) 
	end 
	sls_ship_dt ,
	case 
	when sls_due_dt=0  or len(sls_due_dt) !=8 then null
	else cast(cast(sls_due_dt as nvarchar)as date) 
	end 
	sls_due_dt,
	case 
	when sls_sales is null or sls_sales <=0 or sls_sales  !=sls_quantity*abs(sls_price)
	then sls_quantity*abs(sls_price)
	else 
	sls_sales
	end as sls_sales,
	sls_quantity,
	case 
	when sls_price is null or sls_price<=0
	then sls_sales/nullif(sls_quantity,0)
	else sls_price
	end as sls_price

	from Bronze.crm_sales_details




	--clean erp cust az12 from bronze and load to silver

	
	truncate table Silver.erp_cust_az12
	insert into Silver.erp_cust_az12
	(cid,
	bdate,
	gen )
	select 
	case 
	when cid like 'NAS%' then substring(cid,4,len(cid))
	else cid
	end 
	cid,
	case
	when bdate> getdate() then null 
	else bdate
	end
	bdate,
	case 
	when upper(trim(gen)) in ('F','FEMALE') then 'Female'
	when upper(trim(gen)) in ('M' , 'MALE') then 'Male'
	else 'N/A'
	end
	gen 
	from Bronze.erp_cust_az12


	--clean erp loc a101 from bronze and load to silver

	
	truncate table Silver.erp_loc_a101
	insert into Silver.erp_loc_a101(
	cid,
	cntry)
	select 
	replace(cid,'-',''),
	case 
	when trim(cntry)='DE' then 'Germany'
	when trim(cntry) In ('US','USA','united States') then 'united States'
	when trim(cntry)='' or cntry is null then 'N/A'
	else trim(cntry)
	end
	cntry
	from Bronze.erp_loc_a101

	--clean erp px cat g1v2 from bronze and load to silver

	
	truncate table Silver.erp_px_cat_g1v2

	insert into Silver.erp_px_cat_g1v2
	(id,
	cat,
	subcat,
	maintenance)
	select 
	id,
	cat,
	subcat,
	maintenance
	from  Bronze.erp_px_cat_g1v2
end


exec Silver.load_silver
