USE sakila;

#1 Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.

-- select * from inventory;
-- select COUNT(inventory_id) as number_of_copies, film_id from inventory group by film_id;
-- select * from film where title = "Hunchback Impossible";

SELECT 
	(SELECT f.title FROM film f WHERE f.title = 'Hunchback Impossible') as move_title,
    COUNT(i.inventory_id) AS number_of_copies
FROM inventory i
WHERE i.film_id = (SELECT f.film_id FROM film f WHERE f.title = 'Hunchback Impossible');

#2 List all films whose length is longer than the average length of all the films in the Sakila database.

-- select avg(length) as avg_length from film;
select * from film where length > (select avg(length) from film);

#3 Use a subquery to display all actors who appear in the film "Alone Trip".
select * from actor; -- film_id & title
select * from film_actor; -- actor_id & film_id
select * from actor; -- actor_id

-- select title, film_id from film where title = "alone trip";
-- select * from film_actor where film_id = 17;
-- select actor_id, first_name, last_name from actor where actor_id in (select actor_id from film_actor where film_id = 17);

select actor_id, first_name, last_name from actor where actor_id in (select actor_id from film where title = "alone trip");

#4 Identify all movies categorized as family films.

select * from film;
select * from category; -- category_id = 8 & name "Family"
select * from film_category; -- category_id & film_id

select * 
from film 
where film_id in (
	select film_id
    from film_category
    where category_id = 
		(select category_id
        from category
        where name = "Family"));
        
#5 Retrieve the name and email of customers from Canada using both subqueries and joins. To use joins, you will need to identify the relevant tables and their primary and foreign keys.

select * from customer; -- first_name, last_name, email, customer_id > address_id
select * from address; -- address_id > city_id
select * from city; -- city_id > country_id
select * from country; -- country_id > country

-- select country_id, country from country where country = "canada";

select cu.first_name, cu.last_name, cu.email, cu.customer_id from customer cu where (
	cu.address_id in (
		select a.address_id
		from address a
		join city c on c.city_id = a.city_id
		join country co on co.country_id = c.country_id
		where co.country = "canada"
		)
);

#6 Determine which films were starred by the most prolific actor in the Sakila database. 
-- A prolific actor is defined as the actor who has acted in the most number of films. 
-- First, you will need to find the most prolific actor and then use that actor_id to find the different films that he or she starred in.

select * from film; -- film_id, title
select * from film_actor; -- film_id, actor_id
select * from actor; -- actor_id, first_name, last_name

-- select actor_id, count(actor_id) from film_actor group by actor_id order by count(actor_id) desc limit 1;
-- select first_name, last_name from actor where actor_id = 107;

select film_id, title from film where film_id in (
	select film_id
    from film_actor
    where actor_id = (
		select actor_id 
        from film_actor 
        group by actor_id 
        order by count(actor_id) desc 
        limit 1)
);

#7 Find the films rented by the most profitable customer in the Sakila database. 
-- You can use the customer and payment tables to find the most profitable customer, i.e., the customer who has made the largest sum of payments.

select * from film; -- film_id
select * from customer; -- customer_id
select * from payment; -- customer_id, amount, rental_id
select * from rental; -- rental_id, customer_id, inventory_id
select * from inventory; -- inventory_id > film_id

-- customer_id = 526 (most profitable customer)
select customer_id, sum(amount) as total_paid from payment group by customer_id order by total_paid desc limit 1;

select film_id, title 
from film 
where film_id in (
	-- select film ids from inventory using inventory ids
	select film_id
    from inventory
    where inventory_id in (
		-- select inventory ids from rental subset where customer_id = most amount spent
		select inventory_id
        from rental
        where customer_id = (
			select customer_id 
			from payment 
			group by customer_id 
			order by sum(amount) desc 
			limit 1)
		)
);

#8 Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client. You can use subqueries to accomplish this.

select * from customer; -- customer_id
select * from payment; -- customer_id, amount, rental_id

-- avg total amount paid by customers
select avg(total_paid) as avg_total_paid
from 
(select customer_id, sum(amount) as total_paid
from payment 
group by customer_id 
) as customer_totals
;

-- total mount paid by customers where their total amount spent is > to the average total amount spent
select c.customer_id, c.first_name, c.last_name, sum(amount) as total_paid
from payment p 
join customer c on c.customer_id = p.customer_id
group by customer_id
having sum(amount) > (
	select avg(total_paid) as avg_total_paid
	from 
		(select customer_id, sum(amount) as total_paid
		from payment 
		group by customer_id 
		) as customer_totals
);
            




