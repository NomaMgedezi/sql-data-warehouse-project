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

-- Checking 'silver.crm_cust_info'

-- Check For Nulls or Duplicates in Primary Key
-- Expectation: No Result
SELECT 
cst_id,
COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL

-- Check for unwanted Spaces
-- Expectation: No Result
SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)

SELECT cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname)

-- Data Standardization and Consistency
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info

SELECT * FROM silver.crm_cust_info

-- Checking 'silver.crm_prd_info'
-- Check For Nulls or Duplicates in Primary Key
-- Expectation: No Result
SELECT 
prd_id,
COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL

-- Check for unwanted Spaces
-- Expectation: No Result
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)

-- Check for NULLS or Negative Numbers
-- Expectation: No Result
SELECT prd_cost
FROM silver.crm_prd_info
WHERE  prd_cost < 0 OR prd_cost IS NULL

-- Data Standardization and Consistency
SELECT DISTINCT prd_line
FROM silver.crm_prd_info


-- Check for Invalid Date Orders
SELECT 
*
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt

SELECT * FROM silver.crm_prd_info


-- Checking 'silver.crm_sales_details'
-- Check for Invalid Dates
-- Expectation: No Invalid Dates
SELECT 
NULLIF(sls_due_dt,0) sls_due_dt 
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0 
	OR LEN(sls_due_dt) != 8 
	OR  sls_due_dt > 20500101 
	OR sls_due_dt < 19900101

-- Check for Invalid Date Orders (Order date > Shipping/Due dates)
-- Expectation: No result
SELECT 
*
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

-- Check Data Consistency: Sales = Quantity * Price
-- >> Values must not be NULL, zero or negative
SELECT 
	sls_sales ,
	sls_quantity,
	sls_price 
	FROM bronze.crm_sales_details
	WHERE sls_sales != sls_quantity * sls_price
	OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
	OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
	ORDER BY sls_sales, sls_quantity, sls_price


	-- Checking 'silver.erp_cust_az12'
	-- Identify Out-of-Range Dates
-- Expectation: Birthdates between 1924-01-01 and Tooday
SELECT DISTINCT
bdate 
FROM bronze.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate  > GETDATE() -- Check for birthdays in the future

-- Data Standardization and Consistency
SELECT DISTINCT
gen
FROM silver.erp_cust_az12


-- Checking 'silver.erp_loc_a101'
-- Data Standardazation & Consistency
SELECT DISTINCT cntry
FROM silver.erp_loc_a101
ORDER BY cntry


-- Checking 'silver.erp_px_cat_g1v2'
-- Check for unwanted spaces
SELECT * FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance)

-- Data Standardization and Consinstency
SELECT DISTINCT 
cat
FROM  bronze.erp_px_cat_g1v2




