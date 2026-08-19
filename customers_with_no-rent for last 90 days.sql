use sakila;
#Using Not IN
select c.customer_id,c.first_name,c.last_name
from customer c
where c.customer_id NOT IN(
select customer_id
from rental
where rental_date >=(
select max(rental_date)
from rental
)- INTERVAL 90 day
);

#---------------------------------------------

# Uisng Not Exist()
SELECT
    c.customer_id,
    c.first_name,
    c.last_name
FROM customer c
WHERE NOT EXISTS (
    SELECT 1
    FROM rental r
    WHERE r.customer_id = c.customer_id
      AND r.rental_date >= (
          SELECT MAX(rental_date)
          FROM rental
          ) - INTERVAL 90 DAY
);
      
