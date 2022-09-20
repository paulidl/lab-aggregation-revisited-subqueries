/* Lab | Aggregation Revisited - Subqueries: In this lab, you will be using the Sakila database of movie rentals. 
You have been using this database for a couple labs already, but if you need to get the data again, refer to the official installation link.

Instructions:

Write the SQL queries to answer the following questions:
	- Select the first name, last name, and email address of all the customers who have rented a movie.
    - What is the average payment made by each customer (display the customer id, customer name (concatenated), and the average payment made).
    - Select the name and email address of all the customers who have rented the "Action" movies.
		* Write the query using multiple join statements
        * Write the query using sub queries with multiple WHERE clause and IN condition
        * Verify if the above two queries produce the same results or not
	- Use the case statement to create a new column classifying existing columns as either or high value transactions based on the amount of payment. 
    If the amount is between 0 and 2, label should be low and if the amount is between 2 and 4, the label should be medium, 
    and if it is more than 4, then it should be high.
*/

USE sakila;

-- Select the first name, last name, and email address of all the customers who have rented a movie.

SELECT * FROM sakila.customer;			# customer_id, first_name, last_name, email
SELECT * FROM sakila.rental;			# rental_id, customer_id

SELECT c.customer_id, c.first_name, c.last_name, c.email, count(c.customer_id) AS nº_rented_movies
FROM sakila.rental r
LEFT JOIN sakila.customer c USING(customer_id)
GROUP BY c.customer_id, c.first_name, c.last_name, c.email
ORDER BY nº_rented_movies DESC;

-- What is the average payment made by each customer (display the customer id, customer name (concatenated), and the average payment made).

SELECT * FROM sakila.payment;				# customer_id, payment_id, amount
SELECT * FROM sakila.customer;				# customer_id, first_name, last_name

SELECT customer_id, CONCAT(first_name, ' ', last_name) AS customer_name, ROUND(AVG(amount), 2) AS average_payment_made
FROM sakila.customer
JOIN sakila.payment USING(customer_id)
GROUP BY customer_id
ORDER BY average_payment_made DESC;

-- Select the name and email address of all the customers who have rented the "Action" movies.

SELECT * FROM sakila.customer;					# customer_id, first_name, last_name, email	
SELECT * FROM sakila.rental;					# customer_id, inventory_id
SELECT * FROM sakila.inventory;					# film_id, inventory_id 
SELECT * FROM sakila.film_category;				# film_id, category_id
SELECT * FROM sakila.category;					# category_id, name
	
# Write the query using multiple join statements.

SELECT ca.name AS category_rented, cu.customer_id, concat(first_name, ' ', last_name) AS customer_name, email
FROM sakila.customer cu
JOIN sakila.rental r ON cu.customer_id = r.customer_id
JOIN sakila.inventory i ON r.inventory_id = i.inventory_id
JOIN sakila.film_category fc ON fc.film_id = i.film_id
JOIN sakila.category ca ON fc.category_id = ca.category_id
WHERE ca.name = 'Action'
GROUP BY cu.customer_id
ORDER BY customer_name;

# Write the query using sub queries with multiple WHERE clause and IN condition.

SELECT concat(first_name, ' ', last_name) AS customer_name, email
FROM sakila.customer
WHERE customer_id IN (
	SELECT customer_id
    FROM sakila.rental
	WHERE inventory_id IN (
		SELECT inventory_id
        FROM sakila.inventory
        WHERE film_id IN (
			SELECT film_id
            FROM sakila.film_category
            WHERE category_id IN (
				SELECT category_id
                FROM sakila.category
                WHERE name = 'Action'
                )
			)
		)
	)
ORDER BY customer_name;

# Verify if the above two queries produce the same results or not.
## Yes, they do the same.

-- Use the case statement to create a new column classifying existing columns as either or high value transactions based on the amount of payment. 
-- If the amount is between 0 and 2, label should be low and if the amount is between 2 and 4, the label should be medium, and if it is more than 4, then it should be high.

SELECT * FROM sakila.customer;					# customer_id, first_name, last_name, email	
SELECT * FROM sakila.rental;					# customer_id, inventory_id
SELECT * FROM sakila.inventory;					# film_id, inventory_id 
SELECT * FROM sakila.film_category;				# film_id, category_id
SELECT * FROM sakila.category;					# category_id, name
SELECT * FROM sakila.payment;					# customer_id, rental_id

SELECT
	cu.customer_id, CONCAT(cu.first_name, " ",  cu.last_name) AS name, 
    p.amount, 
    CASE
		WHEN p.amount < 2 THEN 'low' 
        WHEN p.amount >= 2 AND p.amount < 4 THEN 'medium'
        ELSE 'high'
        END AS amount_of_payment
FROM sakila.customer cu
JOIN sakila.rental r ON cu.customer_id = r.customer_id
JOIN sakila.inventory i ON r.inventory_id = i.inventory_id
JOIN sakila.film_category fc ON i.film_id = fc.film_id
JOIN sakila.category ca ON fc.category_id = ca.category_id
JOIN sakila.payment p ON cu.customer_id = p.customer_id
WHERE ca.name = 'Action'
GROUP BY cu.customer_id, name, p.amount
ORDER BY cu.customer_id, name, p.amount;
