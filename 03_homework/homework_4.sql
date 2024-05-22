-- COALESCE
/* 1. Our favourite manager wants a detailed long list of products, but is afraid of tables! 
We tell them, no problem! We can produce a list with all of the appropriate details. 

Using the following syntax you create our super cool and not at all needy manager a list:

SELECT 
product_name || ', ' || product_size|| ' (' || product_qty_type || ')'
FROM product

But wait! The product table has some bad data (a few NULL values). 
Find the NULLs and then using COALESCE, replace the NULL with a 
blank for the first problem, and 'unit' for the second problem. 

HINT: keep the syntax the same, but edited the correct components with the string. 
The `||` values concatenate the columns into strings. 
Edit the appropriate columns -- you're making two edits -- and the NULL rows will be fixed. 
All the other rows will remain the same.) */

SELECT  product_name || ', ' || COALESCE(product_size, '') || ' (' || COALESCE(product_qty_type, 'unit') || ')'

FROM    product



--Windowed Functions
/* 1. Write a query that selects from the customer_purchases table and numbers each customer’s  
visits to the farmer’s market (labeling each market date with a different number). 
Each customer’s first visit is labeled 1, second visit is labeled 2, etc. 

You can either display all rows in the customer_purchases table, with the counter changing on
each new market date for each customer, or select only the unique market dates per customer 
(without purchase details) and number those visits. 
HINT: One of these approaches uses ROW_NUMBER() and one uses DENSE_RANK(). */


SELECT 	    *
			,	ROW_NUMBER() OVER( PARTITION BY customer_id ORDER BY market_date, transaction_time ASC) AS [Order]
            
FROM    customer_purchases


/* 2. Reverse the numbering of the query from a part so each customer’s most recent visit is labeled 1, 
then write another query that uses this one as a subquery (or temp table) and filters the results to 
only the customer’s most recent visit. */

SELECT		X.*

FROM		(
                SELECT 	*
                                    ,	ROW_NUMBER() OVER( PARTITION BY customer_id ORDER BY market_date DESC, transaction_time DESC) AS [Order]
                FROM customer_purchases
			) X
--
WHERE		X.[Order] = 1

/* 3. Using a COUNT() window function, include a value along with each row of the 
customer_purchases table that indicates how many different times that customer has purchased that product_id. */
SELECT 		X.*

FROM		(
                SELECT 	*
                        ,	COUNT(*) OVER( PARTITION BY customer_id, product_id ORDER BY product_id ) AS Product_Purchases_Count
                FROM    customer_purchases
            ) X




--Solution below removes repeats and shows breakdown by customer AND product_id
SELECT DISTINCT		X.product_id
                ,	X.customer_id
                ,	X.Product_Purchases_Count
                ,	X.Total_purchased_by_customer

FROM			(

                    SELECT 	    *
                            ,	COUNT(*) OVER( PARTITION BY customer_id, product_id ORDER BY product_id ) AS Product_purchases_count
                            ,	SUM(quantity) OVER( PARTITION BY customer_id, product_id ORDER BY product_id) AS Total_purchased_by_customer
                    FROM    customer_purchases
                ) X
						
;	
		