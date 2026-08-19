use sakila;
select  date_format(p.payment_date,'%Y-%M') as Month , sum(p.amount) as Total_Revenue
from rental r inner join payment p using(rental_id)
group by Month
order by Month;

