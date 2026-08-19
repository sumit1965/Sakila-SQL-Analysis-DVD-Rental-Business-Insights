USE sakila;

SELECT
    store_id,
    payment_date,
    amount,
    SUM(amount) OVER (
        PARTITION BY store_id
        ORDER BY payment_date
    ) AS Running_Total
FROM payment
ORDER BY store_id, payment_date;

select * from payment;