-- 1) How much revenue is generated each month?

SELECT 
    MONTHNAME(Date) AS Month_name, 
    ROUND(SUM(Unit_price * Quantity), 2) AS Revenue
FROM 
    sales_data
GROUP BY 
    Month_name
ORDER BY 
    Revenue DESC;
    
-- 2) In which month did the cost of goods sold reach its peak?

SELECT 
    MONTHNAME(Date) AS Month_name, 
    ROUND(SUM(COGS), 2) AS Maximum_COGS
FROM 
    sales_data
GROUP BY 
    Month_name 
ORDER BY 
    Maximum_COGS DESC
LIMIT 1;

-- 3) Determine the city with the highest VAT percentage.

SELECT 
    City, 
    Round((SUM(Tax) / SUM(Total)) * 100,2) AS vat_percentage
FROM 
    sales_data
GROUP BY 
    City
ORDER BY 
    vat_percentage DESC
LIMIT 
    1;
    
-- 4) For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad.

WITH cte1 As (
SELECT Product_line, ROUND(Sum(total),2) As Total_sales
FROM sales_data 
GROUP BY Product_line
),
cte2 As (
SELECT ROUND(AVG(Total_sales),2) As AVG_sales
FROM cte1
)
SELECT product_line, Total_sales, AVG_sales,
CASE
    WHEN cte1.Total_sales > cte2.AVG_sales THEN 'GOOD'
    ELSE 'BAD'
    END AS Indicating
FROM cte1, cte2;

-- 5) Which product line is most frequently associated with each gender?

WITH cte1 AS (
    SELECT 
        Product_line, 
        Gender, 
        COUNT(Gender) AS NO_of_count
    FROM sales_data
    GROUP BY Product_line, Gender
),
cte2 AS (
    SELECT 
        MAX(NO_of_count) AS Max_count
    FROM cte1
)
SELECT 
    cte1.Product_line, 
    cte1.Gender, 
    cte1.NO_of_count
FROM 
    cte1, cte2
ORDER BY 
    cte1.Product_line ASC, 
    cte1.NO_of_count DESC;
    
-- 6) Identify the customer type with the highest purchase frequency.

SELECT 
    customer_type, 
    COUNT(Invoice_ID) AS Purchase_frequency
FROM 
    sales_data
GROUP BY 
    customer_type
ORDER BY 
    Purchase_frequency DESC
LIMIT 
    1;
    
-- 7) Examine the distribution of genders within each branch.

SELECT 
    Branch,
    Gender,
    COUNT(Gender) AS Gender_count
FROM 
    sales_data
GROUP BY 
    Branch, 
    Gender
ORDER BY 
    Branch,
    Gender_count DESC;
    
-- 8) Determine the day of the week with the highest average ratings for each branch.

WITH cte1 AS (
    SELECT 
        Branch, 
        DAYNAME(Date) AS Day_name, 
        ROUND(AVG(Rating), 2) AS Avg_rating 
    FROM 
        sales_data
    GROUP BY 
        Branch, Day_name
),
cte2 AS (
    SELECT 
        Branch, 
        Day_name, 
        Avg_rating,
        DENSE_RANK() OVER (
            PARTITION BY Branch 
            ORDER BY Avg_rating DESC
        ) AS rn
    FROM 
        cte1
)
SELECT 
    Branch, 
    Day_name, 
    Avg_rating
FROM 
    cte2
WHERE 
    rn = 1;

-- 9) Identify the branch that exceeded the average number of products sold.

WITH branch_sales AS (
    SELECT 
        Branch, 
        SUM(Quantity) AS Total_sales
    FROM 
        sales_data 
    GROUP BY 
        Branch
),
branch_avg AS (
    SELECT 
        ROUND(AVG(Total_sales),2) AS Avg_sales
    FROM 
        branch_sales
)
SELECT 
    branch_sales.Branch, 
    branch_avg.Avg_sales
FROM 
    branch_sales
CROSS JOIN 
    branch_avg
WHERE 
    branch_sales.Total_sales > branch_avg.Avg_sales;
    
-- 10) Identify the customer type contributing the highest revenue.

WITH cte1 AS (
    SELECT 
        Customer_type, 
        (Unit_price * Quantity) AS Revenue
    FROM 
        sales_data
),
cte2 AS (
    SELECT 
        Customer_type, 
        ROUND(SUM(Revenue), 2) AS Total_Revenue
    FROM 
        cte1
    GROUP BY 
        Customer_type
)
SELECT 
    Customer_type, 
    Total_Revenue
FROM 
    cte2
ORDER BY 
    Total_Revenue DESC
LIMIT 1;

