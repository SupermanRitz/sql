-- Cross Join
/*1. Suppose every vendor in the `vendor_inventory` table had 5 of each of their products to sell to **every** 
customer on record. How much money would each vendor make per product? 
Show this by vendor_name and product name, rather than using the IDs.

HINT: Be sure you select only relevant columns and rows. 
Remember, CROSS JOIN will explode your table rows, so CROSS JOIN should likely be a subquery. 
Think a bit about the row counts: how many distinct vendors, product names are there (x)?
How many customers are there (y). 
Before your final group by you should have the product of those two queries (x*y).  */

SELECT  S.vendor_name , S.product_name , SUM(sale_per_customer) AS Total_sales

FROM		(
				SELECT DISTINCT
						V.vendor_name , P.product_name , VI.original_price , C.customer_id , VI.original_price*5 AS sale_per_customer
					
				FROM vendor_inventory VI
				--
				CROSS JOIN (SELECT  customer_id from customer) C
				--
				INNER JOIN	vendor V ON VI.vendor_id =  V.vendor_id
				--
				INNER JOIN 	product P ON VI.product_id = P.product_id
			) S
				 
GROUP BY S.vendor_name , S.product_name 


-- INSERT
/*1.  Create a new table "product_units". 
This table will contain only products where the `product_qty_type = 'unit'`. 
It should use all of the columns from the product table, as well as a new column for the `CURRENT_TIMESTAMP`.  
Name the timestamp column `snapshot_timestamp`. */

DROP TABLE IF EXISTS product_units;


CREATE TEMP TABLE product_units AS

SELECT *, CURRENT_TIMESTAMP AS snapshot_timestamp
FROM product
WHERE product_qty_type = 'unit'
;


/*2. Using `INSERT`, add a new row to the product_units table (with an updated timestamp). 
This can be any product you desire (e.g. add another record for Apple Pie). */

DROP TABLE IF EXISTS product_units;


CREATE TEMP TABLE product_units AS

SELECT *, CURRENT_TIMESTAMP AS snapshot_timestamp
FROM product
WHERE product_qty_type = 'unit'
;

INSERT INTO product_units
VALUES ( 32 , 'Maple Syrup - Jar' , '16oz' , 2 , 'unit', CURRENT_TIMESTAMP );

SELECT *
FROM product_units

-- DELETE
/* 1. Delete the older record for the whatever product you added. 

HINT: If you don't specify a WHERE clause, you are going to have a bad time.*/

DELETE FROM product_units
WHERE product_id = 23;

-- UPDATE
/* 1.We want to add the current_quantity to the product_units table. 
First, add a new column, current_quantity to the table using the following syntax.

ALTER TABLE product_units
ADD current_quantity INT;

Then, using UPDATE, change the current_quantity equal to the last quantity value from the vendor_inventory details.

HINT: This one is pretty hard. 
First, determine how to get the "last" quantity per product. 
Second, coalesce null values to 0 (if you don't have null values, figure out how to rearrange your query so you do.) 
Third, SET current_quantity = (...your select statement...), remembering that WHERE can only accommodate one column. 
Finally, make sure you have a WHERE statement to update the right row, 
	you'll need to use product_units.product_id to refer to the correct row within the product_units table. 
When you have all of these components, you can run the update statement. */

DROP TABLE IF EXISTS product_units;
DROP TABLE IF EXISTS last_date;

CREATE TEMP TABLE product_units AS

SELECT *, CURRENT_TIMESTAMP AS snapshot_timestamp
FROM product
WHERE product_qty_type = 'unit'
;

INSERT INTO product_units
VALUES ( 32 , 'Maple Syrup - Jar' , '16oz' , 2 , 'unit', CURRENT_TIMESTAMP );

DELETE FROM product_units
WHERE product_id = 23;

ALTER TABLE product_units
ADD current_quantity INT;


				
CREATE TEMP TABLE last_date AS
SELECT		market_date 
					,	 product_id 
					,	quantity 
					,	ROW_NUMBER() OVER (PARTITION BY product_id  ORDER BY market_date DESC) AS ordered_product_dates
FROM 		vendor_inventory
;
			
UPDATE product_units
SET current_quantity =  COALESCE((SELECT last_date.quantity FROM last_date WHERE last_date.product_id = product_units.product_id AND last_date.ordered_product_dates = 1) , 0)
;
 

SELECT *
FROM product_units 

