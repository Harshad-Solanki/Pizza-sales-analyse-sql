--1.Retrieve the total number of orders placed.
select count(*) from orders;

--2.Calculate the total revenue generated from pizza sales.
select sum(od.quantity * p.price) 
from pizzas p
join order_details od 
on p.pizza_id = od.pizza_id;

--3.Identify the highest-priced pizza.
select p.price , pt.name 
from pizza_types pt 
join pizzas p 
on pt.pizza_type_id = p.pizza_type 
order by p.price desc limit 1;

--4.Identify the most common pizza size ordered.
select p.size ,count(od.order_details_id) 
from pizzas p 
join order_details od 
on p.pizza_id = od.pizza_id 
group by p.size
order by count(od.order_details_id) desc;

--5.List the top 5 most ordered pizza types along with their quantities.
select p.pizza_type , sum(od.quantity) 
from pizzas p 
join order_details od
on p.pizza_id = od.pizza_id
group by p.pizza_type
order by sum(od.quantity) desc
limit 5;

--6.Join the necessary tables to find the total quantity of each pizza category ordered.
select pt.category , sum(od.quantity) as quantity
from pizza_types pt join pizzas p on pt.pizza_type_id = p.pizza_type
join order_details od 
on p.pizza_id = od.pizza_id 
group by pt.category
order by quantity desc; 

--7.Determine the distribution of orders by hour of the day.
select EXTRACT(HOUR FROM order_time) AS hours, count(order_id) from orders
group by hours; 

--8.Join relevant tables to find the category-wise distribution of pizzas.
select category , count(name) from pizza_types
group by category;


--9.Group the orders by date and calculate the average number of pizzas ordered per day.
select round(avg(quantity),2) from (select o.order_date , sum(od.quantity) as quantity from orders o 
join order_details od on o.order_id = od.order_id
group by o.order_date) as order_quantity;

--10.Determine the top 3 most ordered pizza types based on revenue.
select p.pizza_type , sum(od.quantity * p.price) as revenue from pizzas p
join order_details od 
on p.pizza_id = od.pizza_id
group by p.pizza_type
order by revenue desc
limit 3;

--11.Calculate the percentage contribution of each pizza type to total revenue.
select pt.category, round(sum(od.quantity * p.price) / (select round(sum(od.quantity * p.price),2) from pizzas p
join order_details od 
on p.pizza_id = od.pizza_id) * 100,2) as revenue
from pizza_types pt
join pizzas p on pt.pizza_type_id = p.pizza_type
join order_details od on p.pizza_id = od.pizza_id
group by pt.category
order by revenue desc;

--12.Analyze the cumulative revenue generated over time.
select order_date , sum(revenue) over(order by order_date) as cum_revenue from
(select o.order_date , sum(od.quantity * p.price) as revenue 
from order_details od join pizzas p 
on od.pizza_id = p.pizza_id
join orders o 
on od.order_id = o.order_id
group by o.order_date) as sales;

--13.Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select category , name , revenue from
(select category , name , revenue , rank()
over(partition by category order by revenue) from(select pt.category , pt.name , sum(od.quantity * p.price) as revenue 
from pizza_types pt join pizzas p
on pt.pizza_type_id = p.pizza_type
join order_details od 
on p.pizza_id = od.pizza_id
group by pt.category , pt.name ) as a) as b
where rank <=3;


select * from order_details;
select * from pizzas;
select * from pizza_types;
select * from orders;