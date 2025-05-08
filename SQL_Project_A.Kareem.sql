use company;

-- Adding Column 'Total_Sales 'in Table 'Orderdetails'
alter table orderdetails add total_sales
int;

set SQL_SAFE_UPDATES = 0;

update orderdetails set total_sales = quantity*price;
-- Total sales
select sum(total_sales) as Total_Sales from orderdetails;

-- Total Customers
select count(customer_id) as Total_Customers from customers;

-- Total Orders
select count(order_id) as Total_oders from orders;

-- Total cities
select count(distinct customer_city) as Total_cities from customers;

-- Total products
select count(product_id) as Total_Products from products;



-- Questions
-- 1. Retrieve Customer Information:
-- Write a query to select the customer names and their corresponding cities.
select customer_name,customer_city 
from customers;

-- 2. List All Orders:
-- Write a query to display the order ID, order date, and total amount for all orders.
select order_id,order_date,total_amount from orders;

-- 3. Find Products in a Specific Category:
-- Write a query to list all products that belong to the category "Electronics."
select product_name,category from products
where category = 'Electronics';

-- 4. Total Sales by Customer:
-- Write a query to find the total amount spent by each customer.
 
select customers.customer_name,orders.total_amount 
from customers join orders 
on customers.customer_id=orders.customer_id;

-- 5. Count Orders Per City:
-- Write a query to count the number of orders placed by customers in each city.
with Orders_city as (
select customers.customer_city, orders.order_id 
from customers 
join orders on customers.customer_id=orders.customer_id)

select customer_city,count(order_id) as Total_No_of_Orders  from orders_city
group by customer_city;

-- 6. Average Quantity per Product:
-- Write a query to find the average quantity ordered for each product.

with  product_quantity as(
select products.product_name,orderdetails.quantity 
from products join orderdetails on products.product_id=orderdetails.product_id)
select product_name,avg(quantity) as Avg_quantity 
from product_quantity 
group by product_name; 

-- 7. Top 5 Most Expensive Products:
-- Write a query to rank the products by price and list the top 5 most expensive ones.

select product_name,dense_rank() 
over(order by price desc) as Rank1
from products;

-- 8. Customer Spending Rank:
-- Write a query to rank customers based on their total spending.
select * from customers;
with customer_spending as(
select customers.customer_name,orders.total_amount  
from customers join orders on customers.customer_id=orders.customer_id)
select customer_name,dense_rank() over(order by total_amount desc) as Rank_based_on_Spending
from customer_spending;

-- 9. Customers with Above-Average Orders:
-- Write a query to find customers who have placed orders above the average order amount.

with customer_orderamount as(
select customers.customer_name,orders.total_amount  
from customers join orders on customers.customer_id=orders.customer_id)
select * from customer_orderamount
where total_amount > (select avg(total_amount) from customer_orderamount);

-- 10. Products with Highest Sales in Each Category:
-- Write a query to find the product with the highest sales in each category.



WITH ProductSales AS (
    SELECT 
        products.product_id,
        Products.product_name,
        Products.category,
        SUM(orderdetails.total_sales) AS total_sales,
        DENSE_RANK() OVER (PARTITION BY products.category ORDER BY SUM(orderdetails.total_sales) DESC) AS rnk
    FROM products
    JOIN orderdetails ON products.product_id = orderdetails.product_id
    GROUP BY products.product_id, products.product_name, products.category
)
SELECT *
FROM ProductSales
WHERE rnk = 1;

-- 11. Customers with Multiple Orders:
-- Write a query to list all customers who have placed more than one order, including their customer names and the number of orders they have placed.
select customers.customer_name,count(orders.order_id) as Total_no_of_Orders
from customers join orders 
on customers.customer_id=orders.customer_id
group by customers.customer_name
having count(orders.order_id) > 1;

-- 12. Products Ordered by Each Customer:
-- Write a query to display each customer and the products they have ordered, including the customer name, product name, and quantity ordered.
select customers.customer_name,products.product_name,orderdetails.quantity
from customers join orders on customers.customer_id =orders.customer_id 
join orderdetails on orders.order_id=orderdetails.order_id join products on orderdetails.product_id=products.product_id;

-- 13. Total Revenue by Category:
-- Write a query to calculate the total revenue generated for each product category, displaying the category name and total revenue.

select p.category,sum(od.total_sales) as Total_Revenue
from products p join orderdetails od on
p.product_id=od.product_id
group by p.category;

-- 14. Order Frequency by Month:
-- Write a query to count how many orders were placed in each month of the current year, displaying the month and the number of orders.
 select monthname(order_date) as Month_name,count(order_id) as Number_of_orders
 from orders
 group by Month_name;
 
 -- 15. Products with Low Stock:
-- Write a query to list products that have been ordered fewer than 10 times, displaying the product name and the total quantity ordered.

select p.product_name,sum(od.quantity) as Quantity_ordered,count(od.order_id) as total_Orders_placed
from products p join orderdetails od on 
p.product_id = od.product_id
group by p.product_name
having count(od.order_id) < 10 ;

-- 16. Customer Loyalty:
-- Write a query to list customers who have placed more than 10 orders, displaying the customer name and the total number of orders they’ve placed.
select customers.customer_name,count(orders.order_id) as Total_no_of_Orders
from customers join orders 
on customers.customer_id=orders.customer_id
group by customers.customer_name
having count(orders.order_id) > 10;


-- 17. Top Cities by Revenue:
-- Write a query to rank cities based on the total revenue generated from orders placed by customers residing in each city, displaying the city name and total revenue.
with city_revenue as (
select c.customer_city,sum(od.total_sales) as Total_Revenue
from customers c join orders o on
c.customer_id=o.customer_id join orderdetails od on o.order_id=od.order_id
group by c.customer_city)
select customer_city,Total_Revenue,dense_rank() over (order by Total_Revenue desc) as rnk
from city_revenue;

-- 18. Orders with More than 3 Products:
-- Write a query to find all orders where more than 3 different products were ordered, displaying the order ID, order date, and customer name.
select c.customer_name,o.order_id,o.order_date
from customers c join orders o on c.customer_id=o.customer_id join orderdetails od on o.order_id=od.order_id 
join products p on od.product_id=p.product_id
group by c.customer_name,o.order_id,o.order_date
having count(distinct p.product_id)> 3;

-- 19. Product Popularity by Region:
-- Write a query to display the most popular product (based on quantity ordered) in each region, including the region name and product name.
with city_product as(
 select c.customer_city as Region,p.product_name,sum(od.quantity) as Total_quantity
from customers c join orders o on c.customer_id=o.customer_id 
join orderdetails od on o.order_id=od.order_id 
join products p on od.product_id=p.product_id
group  by c.customer_city,p.product_name)
select Region,product_name,dense_rank() over(order by Total_quantity desc) as Rnk
from city_product;