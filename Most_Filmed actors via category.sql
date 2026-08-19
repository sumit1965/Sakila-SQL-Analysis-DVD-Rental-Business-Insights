use sakila;
SELECT
    category,
    actor,
    film_count
FROM (
    SELECT
        c.name AS category,
        CONCAT(a.first_name, ' ', a.last_name) AS actor,
        COUNT(fa.film_id) AS film_count,
        DENSE_RANK() OVER (
            PARTITION BY c.name
            ORDER BY COUNT(fa.film_id) DESC
        ) AS film_rank
    FROM actor a
    INNER JOIN film_actor fa
        USING(actor_id)
    INNER JOIN film f
        USING(film_id)
    INNER JOIN film_category fc
        USING(film_id)
    INNER JOIN category c
        USING(category_id)
    GROUP BY
        c.name,
        a.actor_id,
        a.first_name,
        a.last_name
) AS ranked_actors
WHERE film_rank = 1;