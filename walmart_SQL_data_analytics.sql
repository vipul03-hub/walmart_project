SELECT * FROM walmart
SELECT COUNT(*) FROM walmart
SELECT
DISTINCT payment_method FROM walmart;




--Business Problems
--Q1. Find different payment method and number of transactions , number of quantity sold
SELECT
    payment_method,
	COUNT(*),
	SUM(quantity) AS number_of_quantity_sold
FROM walmart
GROUP BY payment_method;

--Q2. Identify the highest rated category in each branch, displaying the branch , category
--AVG RATING
SELECT *
FROM
(
SELECT "Branch", category, AVG(rating) as avg_category,RANK() OVER(PARTITION BY "Branch" ORDER BY AVG(rating)DESC )
FROM walmart
GROUP BY 1,2
)
WHERE rank=1

--Q3. Identify the busiest day for each branch based on the number of transactions
SELECT *
FROM
(
	SELECT
	    "Branch",
		TO_CHAR(TO_DATE(date,'DD/MM/YY'),'DAY') as day_name,
		COUNT(*) as NO_TRANSACTIONS, 
		RANK() OVER(PARTITION BY "Branch" ORDER BY COUNT(*) DESC)
	FROM walmart
	GROUP BY 1,2
)
WHERE rank =1

--Q4.calculate the total quantity of items sold per payment method. List payment_method and total_quantity
SELECT payment_method,
       SUM(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method

--Q5.Determine the average, minimum, maxmium rating of products for each city,list of city, average_rating,min_rating and max_rating
SELECT "City",category,AVG(rating),MIN(rating),MAX(rating)
FROM walmart
GROUP BY 1,2

--Q6. Calculate the total profit for each category by considering total_profit as (unit_price * quantity * profit_margin). List category and total_profit , ordered from highest to lowest profit.
SELECT category,SUM(unit_price * quantity * profit_margin) as total_profit
FROM walmart
GROUP BY 1

--Q7. Determine the most common payment method for each Branch. Display Branch and the prefered_payment_method.
WITH cte 
AS
(
SELECT "Branch",
     payment_method,
	 COUNT(*) as total_trans,
	 RANK() OVER(PARTITION BY "Branch" ORDER BY COUNT(*) DESC)
FROM walmart
GROUP BY 1,2
)
SELECT *
FROM cte
WHERE rank =1

--Q8. categorize sales into 3 group MORNING , AFTERNOON, EVENING. Findout which of the shift and number of invoices
SELECT 
"Branch",
    CASE 
	    WHEN EXTRACT (HOUR FROM (time::time))<12 THEN 'Morning'
        WHEN EXTRACT (HOUR FROM (time::time)) BETWEEN 12 AND 17 THEN 'AFTERNOON'
		ELSE 'EVENING'
	END day_time,
	COUNT(*)
FROM walmart
GROUP BY 1,2
ORDER BY 1,3 DESC


--Q9. Identify 5 branch with highest decrease ratio in revenue compare to last year(current year 2023 and last year 2022)
WITH revenue_2022
AS
(
SELECT 
    "Branch",
	SUM(total) as revenue
FROM walmart
WHERE EXTRACT (YEAR FROM TO_DATE(date,'DD/MM/YY'))=2022
GROUP BY 1
),
revenue_2023
AS
(
SELECT 
    "Branch",
	SUM(total) as revenue
FROM walmart
WHERE EXTRACT (YEAR FROM TO_DATE(date,'DD/MM/YY'))=2023
GROUP BY 1
)
SELECT 
    ls."Branch",
	ls.revenue as last_year,
	cs.revenue as cr_year_revenue,
	ROUND((ls.revenue - cs.revenue)::numeric/ls.revenue::numeric*100,2) as rev_dec_ratio
FROM revenue_2022 as ls
JOIN
revenue_2023 as cs
ON ls."Branch"=cs."Branch"
WHERE
    ls.revenue>cs.revenue
ORDER BY 4 DESC
LIMIT 5      
 