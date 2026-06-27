-- Quality Checks
/*
Script Purpose:
    This script perfoms various quality checks for data consistency, accurancy, and
    standardization across the 'Silver' schema. It includes checks for:
      - Null or duplicates primary keys.
      - Unwanted spaces in string fields.
      - Data standardization and consistency.
      - Invalid date ranges and orders.
      - Data consistency between related fields.

Usage Notes:
      - Run these checks after data loading silver layer.
      - Investigate and resolve any discrepancies found during checks.
*/

-- Checking silver.crm_cust_info
-- Checking For Nulls or Duplicates in Primary Key
-- Expectation: No Result
SELECT 
cst_id,
COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL

-- Checking for unwanted Spaces
-- Expectation: No Result
SELECT cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname)

-- Data Standardization and Consistency
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info

SELECT * FROM silver.crm_cust_info

	
-- Checking silver.crm_prd_info
-- Checking For Nulls or Duplicates in Primary Key
-- Expectation: No Result
SELECT 
prd_id,
COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL

-- Checking for unwanted Spaces
-- Expectation: No Result
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)

-- Checking for Nulls or Negative Numbers
-- Expectation: No Results
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL 

-- Data Standardization
SELECT DISTINCT prd_line
FROM silver.crm_prd_info

-- Checking for Invalid Date Orders
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt

SELECT *
FROM silver.crm_prd_info

-- Data Cleaning 
SELECT 
prd_id,
prd_key,
prd_nm,
prd_start_dt,
prd_end_dt,
LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) -1 AS prd_end_dt_test
FROM bronze.crm_prd_info
WHERE prd_key IN ('AC-HE-HL-U509-R', 'AC-HE-HL-U509')


-- Checking silver.crm_sales_details
-- Checking for Invalid Dates
SELECT 
NULLIF(sls_order_dt,0) sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0
  
SELECT 
NULLIF(sls_due_dt, 0) sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt < 0
	OR LEN(sls_due_dt) != 8
	OR sls_due_dt > 20500101
	OR sls_due_dt < 19000101

-- Checking for Invalid Date Orders
SELECT 
*
FROM  silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

-- Checking Data Consistency: Between Sales, Quantity, and Price
-- >> Sales = Quantity * Price
-- >> Values must not be NUll, zero, or negative.

SELECT 
	sls_sales,
	sls_quantity,
	sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price


 SELECT * FROM silver.crm_sales_details

-- >> Sales = Quantity * Price
-- >> Values must not be NULL, zero, or negative.

SELECT DISTINCT 
sls_sales AS old_sales,
sls_quantity,
sls_price AS old_sls_price,
CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
	 THEN sls_quantity * ABS(sls_price)
   ELSE sls_sales
END AS sls_sales,

CASE WHEN sls_price IS NULL OR sls_price <= 0
	  THEN sls_sales /NULLIF(sls_quantity, 0)
	ELSE sls_price
END AS sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
 OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL OR sls_price IS NULL

-- Checking for Invalid Dates
SELECT 
NULLIF(sls_due_dt, 0) sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt < 0
	OR LEN(sls_due_dt) != 8
	OR sls_due_dt > 20500101
	OR sls_due_dt < 19000101

-- Checking for Invalid Date Orders
SELECT 
*
FROM  silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

-- Checking Data Consistency: Between Sales, Quantity, and Price
-- >> Sales = Quantity * Price
-- >> Values must not be NUll, zero, or negative.

SELECT 
	sls_sales,
	sls_quantity,
	sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price


 SELECT * FROM silver.crm_sales_details


-- Checking 'silver.erp_cust_az12'
-- Identify Out-of-Range Dates
SELECT DISTINCT
bdate 
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate  > GETDATE() -- Check for birthdays in the future

-- Data Standardization and Consistency
SELECT DISTINCT 
gen
FROM silver.erp_cust_az12

SELECT * FROM silver.erp_cust_az12

SELECT 
cid,
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
	ELSE cid
END AS cid,
bdate,
gen
FROM bronze.erp_cust_az12
WHERE CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
	ELSE cid
END NOT IN (SELECT DISTINCT cst_key FROM silver.crm_cust_info)

SELECT * FROM [silver].[crm_cust_info];

INSERT INTO silver.erp_cust_az12(
cid,
bdate,
gen
)
SELECT 
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
	ELSE cid
END AS cid,
CASE WHEN bdate > GETDATE() THEN NULL 
	ELSE bdate 
END AS bdate,
CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
	 WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
	 ELSE 'n/a'
END AS gen
FROM bronze.erp_cust_az12

  
-- Checking 'silver.erp_loc_a101'
SELECT 
REPLACE(cid, '-', '' ) cid,
cntry
FROM bronze.erp_loc_a101
WHERE REPLACE(cid, '-', '' )  NOT IN 
(SELECT cst_key FROM silver.crm_cust_info)

SELECT cst_key FROM silver.crm_cust_info;

INSERT INTO silver.erp_loc_a101
(
	cid,
	cntry
)
SELECT 
REPLACE(cid, '-', '' ) cid,
CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
	 WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
	 WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
	 ELSE TRIM(cntry)
END AS cntry -- Normalize and Handle missing or blank country codes
FROM bronze.erp_loc_a101

SELECT cst_key FROM silver.crm_cust_info;

-- Data Standarrdization and Consistency
SELECT DISTINCT cntry
FROM silver.erp_loc_a101
ORDER BY cntry

SELECT * FROM silver.erp_loc_a101

  
-- Checking 'silver.erp_px_cat_g1v2'
-- Check for unwanted spaces
SELECT * FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance)

-- Data Standardization and Consinstency
SELECT DISTINCT 
maintenance
FROM  bronze.erp_px_cat_g1v2

SELECT * FROM silver.erp_px_cat_g1v2
