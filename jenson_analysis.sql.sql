#find the total number of products sold by each store along with  the store name.
select s.store_name, sum(oi.quantity) as total_products_sold 
from stores s join orders o on s.store_id = o.store_id 
join order_items oi on o.order_id = oi.order_id
group by s.store_name;

#calculate the cumulative sum of quantities sold for each product over time.
select oi.product_id, o.order_date, sum(oi.quantity) over (partition by oi.product_id order by o.order_date)
as cumulative_quantity from order_items oi join orders o on oi.order_id = o.order_id order by oi.product_id, o.order_date;

#find the product with the highest total sales(quantity*price)or each category.
select * from (select c.category_name , p.product_name , sum(oi.quantity * oi.list_price) as total_sales ,
rank() over (partition by c.category_name order by sum(oi.quantity * oi.list_price) desc) as rnk
from order_items oi join products p on oi.product_id = p.product_id join categories c on p.category_id = c.category_id
group by c.category_name , p.product_name ) ranked_products where rnk = 1;

#find the customer who spent the most money on orders.
select c.first_name , c.last_name , sum(oi.quantity * oi.list_price) as total_spent from customers c join orders o 
on c.customer_id = o.customer_id join order_items oi on o.order_id = oi.order_id group by c.customer_id , 
c.first_name , c.last_name order by total_spent desc limit 1;

#find the highest priced product in each category along with the category name.
select c.category_name , p.product_name , p.list_price from products p join categories c on p.category_id = c.category_id
where p.list_price = (select max(p2.list_price) from products p2 where p2.category_id = p.category_id);

#find the total number of orders placed by each customer per store.
select c.first_name , c.last_name , s.store_name , COUNT(o.order_id) as total_orders from customers c join orders o 
on c.customer_id = o.customer_id join stores s on o.store_id = s.store_id group by c.customer_id , s.store_id , 
c.first_name , c.last_name , s.store_name;

##find the staff members who have made no sales.
select s.first_name , s.last_name from staffs s left join orders o on s.staff_id = o.staff_id where o.order_id is null;

#find the top 3 most sold products based on quantity.
select p.product_name , sum(oi.quantity) as total_quantity from products p join order_items oi 
on p.product_id = oi.product_id group by p.product_name order by total_quantity desc limit 3;

#find the median value of product prices.
select avg(list_price) as median_price from ( select list_price , row_number() over (order by list_price)
as row_num , count(*) over () as total_rows from products) as median_table 
where row_num in (floor((total_rows + 1) / 2) , floor((total_rows + 2) / 2));

#find the products that have never been ordered.
select p.product_name from products p where not exists ( select 1 from order_items oi where oi.product_id = p.product_id); 

#find the staff members whose total sales are greater than the average sales of all staff.
select s.first_name , s.last_name , sum(oi.quantity * oi.list_price) as total_sales from staffs s join orders o 
on s.staff_id = o.staff_id join order_items oi on o.order_id = oi.order_id group by s.staff_id , s.first_name, s.last_name
having total_sales > ( select avg(staff_sales) from (select sum(oi.quantity * oi.list_price)
as staff_sales from orders o join order_items oi on o.order_id = oi.order_id group by o.staff_id) as avg_sales);

#find customers who have ordered products from every category.
SELECT c.customer_id, c.first_name, c.last_name FROM customers c JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id JOIN products p ON oi.product_id = p.product_id
GROUP BY c.customer_id, c.first_name, c.last_name HAVING COUNT(DISTINCT p.category_id) = (SELECT COUNT(*) FROM categories);

