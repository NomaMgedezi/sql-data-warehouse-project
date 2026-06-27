/* Quality Checks

Script Purpose: 
    This script perfomrs quality check to validate the integrity, consistency, and accurancy
    of the Gold Layer. These checks ensure:
    - Uniqueness of surrogate between fact and dimension tables.
    - Referentia integrity between fact and dimension tables.
    - Validation of relationships in the data model for analytical purposes.

*/

-- Check for uniqueness of Product Key in gold.dim_products 
-- Expectation: No result
SELECT
    product_key, COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;


-- Check for uniqueness of Customer Key in gold.dim_customers
-- Expectation: No result
SELECT 
    customer_key, COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;


-- Foreign Key Integrity (Dimensions)
-- Check data model conectivity between fact and dimensions
SELECT * 
FROM gold.fact_sales f 
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
WHERE p.product_key IS NULL
    
