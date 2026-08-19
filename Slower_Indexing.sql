USE sakila;

-- BEFORE
EXPLAIN
SELECT *
FROM payment
WHERE amount = 5.99;


-- CREATE INDEX
CREATE INDEX idx_payment
ON payment(amount);


-- AFTER
EXPLAIN
SELECT *
FROM payment
WHERE amount = 5.99;