/* Project: Sales Growth & Trend Analysis
   Description: Using Window Functions to analyze Year-over-Year (YoY) sales, 
                identifying next year's trends, and capturing first/last records.
*/

WITH CTE_table AS (
    SELECT 
        YEAR(f.order_date) AS sales_year,
        p.product_name,
        SUM(f.sales_amount) AS total_sales
    FROM fact_sales f 
    INNER JOIN products p ON f.product_key = p.product_key
    GROUP BY YEAR(f.order_date), p.product_name
)

SELECT  
    sales_year,
    product_name,
    total_sales,
    
    -- 1. Get previous year sales (Lag)
    LAG(total_sales) OVER(PARTITION BY product_name ORDER BY sales_year) AS previous_value,
    
    -- 2. Get next year sales forecast (Lead)
    LEAD(total_sales) OVER(PARTITION BY product_name ORDER BY sales_year) AS Next_value,
    
    -- 3. Get the first recorded sales for this product
    FIRST_VALUE(total_sales) OVER(PARTITION BY product_name ORDER BY sales_year) AS first_recorded_sales,
    
    -- 4. Get the latest sales (Corrected Frame for Last_Value)
    LAST_VALUE(total_sales) OVER(
        PARTITION BY product_name 
        ORDER BY sales_year 
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS latest_recorded_sales

FROM CTE_table;
