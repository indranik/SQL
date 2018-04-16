Use Sakila;

-- 1a. Display the first and last names of all actors from the table actor
SELECT `actor`.`first_name`, `actor`.`last_name` FROM `sakila`.`actor`;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name. 
SELECT concat(ucase(`actor`.`first_name`) , " " , ucase( `actor`.`last_name`)) as 'Actor Name' FROM `sakila`.`actor`;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?

SELECT `actor`.`actor_id`, `actor`.`first_name`, `actor`.`last_name` 
FROM `sakila`.`actor` 
WHERE `actor`.`first_name` = 'Joe' ;

-- 2b. Find all actors whose last name contain the letters GEN:
SELECT `actor`.`actor_id`, `actor`.`first_name`, `actor`.`last_name` 
FROM `sakila`.`actor` 
WHERE `actor`.`last_name` LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT `actor`.`actor_id`, `actor`.`first_name`, `actor`.`last_name` 
FROM `sakila`.`actor` 
WHERE `actor`.`last_name` LIKE '%LI%'
order by `actor`.`last_name` ,`actor`.`first_name` ;
-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT `country`.`country_id`,`country`.`country`
FROM `sakila`.`country`
WHERE `country`.`country` IN ('Afghanistan', 'Bangladesh','China');

-- 3a. Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type.
ALTER TABLE `sakila`.`actor`  ADD COLUMN `middle_name`  varchar(50) after `first_name`;

-- 3b. You realize that some of these actors have tremendously long last names. Change the data type of the middle_name column to blobs.
ALTER TABLE `sakila`.`actor`  MODIFY COLUMN `middle_name`  blob;
-- DESCRIBE `sakila`.`actor`;

-- 3c. Now delete the middle_name column.
ALTER TABLE `sakila`.`actor`  DROP COLUMN `middle_name`;
-- DESCRIBE `sakila`.`actor`;

-- 4a. List the last names of actors, as well as how many actors have that last name.

SELECT `actor`.`last_name`,COUNT(*) as 'Num_Actors'
FROM actor GROUP BY `actor`.`last_name`;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT `actor`.`last_name`,COUNT(*) as 'Num_Actors'
FROM actor GROUP BY `actor`.`last_name`
HAVING COUNT(*)>1 ;

-- 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.

UPDATE `sakila`.`actor`
SET
`first_name` = 'HARPO'
WHERE `actor`.`first_name` = 'GROUCHO' AND `actor`.`last_name` = 'WILLIAMS';


-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! (Hint: update the record using a unique identifier.)

UPDATE `sakila`.`actor` SET `first_name` =
CASE
    WHEN first_name = 'HARPO' THEN 'GROUCHO'
    ELSE 'MUCHO GROUCHO'
END
WHERE `actor`.`first_name` = 'GROUCHO' OR `actor`.`first_name` = 'HARPO' ;
-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it? 
SHOW CREATE TABLE address;
 
-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT `staff`.`first_name`,
    `staff`.`last_name`,
    `address`.`address`,
    `address`.`address2`,
    `address`.`district`,
    `address`.`city_id`,
    `address`.`postal_code`
FROM `sakila`.`staff`
JOIN `sakila`.`address` ON
staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment. 
SELECT `staff`.`first_name`,
    `staff`.`last_name`,
    SUM(payment.amount) as TOTAL_AMOUNT
FROM `sakila`.`staff`
JOIN `sakila`.`payment` ON
staff.staff_id = payment.staff_id AND payment.payment_date LIKE '2005-08%'
GROUP BY `staff`.`first_name`,  `staff`.`last_name`;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT 
    `film`.`title`, COUNT(`film_actor`.`actor_id`) as Num_Actors
FROM `sakila`.`film`
INNER JOIN `sakila`.`film_actor`
ON `film`.`film_id`  = `film_actor`.`film_id`
GROUP BY `film`.`title`;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT `film`.`title`, COUNT(`inventory`.`inventory_id`) as Num_Copies
FROM `sakila`.`film`
JOIN `sakila`.`inventory`
ON `film`.`film_id`  = `inventory`.`film_id`
WHERE `film`.`title`= 'Hunchback Impossible'
GROUP BY `film`.`title`;

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT 
    `customer`.`first_name`,
    `customer`.`last_name`,
    SUM(payment.amount) AS Total_Amount_Paid 
FROM `sakila`.`customer`
JOIN `sakila`.`payment` ON
customer.customer_id = payment.customer_id
GROUP BY `customer`.`first_name`, `customer`.`last_name`;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English. 
 
 SELECT title
 FROM film
 WHERE (title LIKE 'Q%' OR title LIKE 'K%') AND language_id in 
  (SELECT `language`.`language_id`
	FROM `sakila`.`language`
	WHERE `language`.`name` = 'English');
  
-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT
    `actor`.`first_name`,
    `actor`.`last_name`
FROM `sakila`.`actor`
WHERE `actor`.`actor_id` IN 
	(SELECT `film_actor`.`actor_id`
	FROM `sakila`.`film_actor`
	WHERE `film_actor`.`film_id` IN 
		(SELECT `film`.`film_id`
		FROM `sakila`.`film`
		WHERE  `film`.`title` = 'Alone Trip')
	);

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT 
    `customer`.`email`,
    `customer`.`first_name`,
    `customer`.`last_name`
FROM `sakila`.`customer`
JOIN address ON customer.address_id = address.address_id 
JOIN city ON address.city_id = city.city_id 
JOIN country ON city.country_id = country.country_id 
WHERE `country`.`country` = 'Canada';
-- the following code accomplishes the same with sub queries.
Select * from customer where customer.address_id IN (
Select address.address_id FROM address where address.city_id IN
(SELECT city_id FROM city 
WHERE country_id IN
(SELECT country_id  FROM `sakila`.`country`
			   WHERE  `country`.`country` = 'Canada')));





-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as famiy films.

SELECT `film`.`title`
FROM `sakila`.`film` 
WHERE `film`.`film_id` IN 
(SELECT `film_category`.`film_id`
  FROM `sakila`.`film_category`
 WHERE `film_category`.`category_id` IN 
(SELECT `category`.`category_id`
FROM `sakila`.`category` WHERE  `category`.`name` = 'Family'));

-- 7e. Display the most frequently rented movies in descending order.
SELECT 
    `film`.`title`,
    COUNT(`rental`.`rental_ID`) AS  'Num_Times_Rented'
FROM `sakila`.`inventory` 
JOIN `sakila`.`film` ON `inventory`.`film_id` = `film`.`film_id`
JOIN rental On`inventory`.`inventory_id`=  `rental`.`inventory_id`
group by `film`.`title` 
order by  Num_Times_Rented DESC;

 
-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT staff.store_id,
    SUM(`payment`.`amount`)
FROM `sakila`.`payment`
JOIN staff ON payment.staff_id = staff.staff_id
GROUP BY 
 staff.store_id;
 


-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT `store`.`store_id`,
    city.city,
    country.country
FROM `sakila`.`store`
JOIN address ON store.address_id = address.address_id
JOIN city ON address.city_id = city.city_id
JOIN country ON city.country_id = country.country_id ;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

# Creating a view for aggregating the total revenue per film
CREATE VIEW RevenuePerFilmID AS
(Select inventory.film_id, SUM(payment.amount) AS Amount
FROM payment
JOIN rental ON payment.rental_id = rental.rental_id
JOIN inventory ON rental.inventory_id = inventory.inventory_id
GROUP BY inventory.film_id);

# 8a : creating a view to display the top 5 revenue generating genres.
CREATE VIEW TOP_Five_Revenue_Generating_Genres AS
(select Category.name AS 'Category',SUM(RevenuePerFilmID.Amount) As 'Revenue'
FROM RevenuePerFilmID
JOIN film_category ON RevenuePerFilmID.film_id = film_Category.film_id
JOIN category ON film_category.category_id = category.category_id
GROUP BY Category
order by Revenue DESC LIMIT 5);
-- 8b. How would you display the view that you created in 8a?
SELECT * FROM TOP_Five_Revenue_Generating_Genres;
-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW TOP_Five_Revenue_Generating_Genres;


