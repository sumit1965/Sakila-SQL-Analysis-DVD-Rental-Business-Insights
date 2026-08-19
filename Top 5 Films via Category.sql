USE sakila;
SELECT
    category_name,
    film_title,
    total_revenue,
    revenue_rank
FROM (
    SELECT
        c.name AS Category_Name,
        f.title AS film_title,
        SUM(p.amount) AS total_revenue,
        ROW_NUMBER() OVER (
            PARTITION BY c.name
            ORDER BY SUM(p.amount) DESC
        ) AS revenue_rank
    FROM film f
    INNER JOIN film_category fc
        USING (film_id)
    INNER JOIN category c
        USING (category_id)
    INNER JOIN inventory i
        USING (film_id)
    INNER JOIN rental r
        USING (inventory_id)
    INNER JOIN payment p
        USING (rental_id)
    GROUP BY
        c.name,
        f.film_id,
        f.title
) AS ranked_films
WHERE revenue_rank <= 5
ORDER BY
    Category_name,
    revenue_rank;