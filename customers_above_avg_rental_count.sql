USE sakila;

SELECT 
    customer_id,
    COUNT(*) AS rental_count
FROM rental
GROUP BY customer_id
HAVING COUNT(*) > (
    SELECT AVG(rental_count)
    FROM (
        SELECT 
            customer_id,
            COUNT(*) AS rental_count
        FROM rental
        GROUP BY customer_id
    ) AS customer_rentals
)
ORDER BY rental_count DESC;