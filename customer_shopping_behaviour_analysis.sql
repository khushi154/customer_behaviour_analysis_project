select * from customer limit 20

--total revenue across gender male and female
select gender,sum(purchase_amount) as revenue
from customer 
group by gender

-- which customers used a discount but still spent more than average purchase amount

select customer_id,purchase_amount
from customer 
where discount_applied='Yes' and 
purchase_amount>=(select AVG(purchase_amount) from customer)

-- which are the top 5 products with the highest average review rating

--casting review rating to numeric because round dont work on double precision

select  item_purchased,round(avg(review_rating::numeric),2) as review_rating
from customer
group by item_purchased
order by review_rating desc
limit 5

-- compare avg purcase amounts bw standard and express shipping

select shipping_type,round(avg(purchase_amount),2)
from customer 
where shipping_type in ('Standard','Express')
group by shipping_type

-- do suscribed customers spend more?compare avg spend and total revenue bw subscribers and non subscribers
select subscription_status ,
count(customer_id) as total_customers,
round(avg(purchase_amount),2) as average_spend ,
sum(purchase_amount)as total_revenue
from customer 
group by subscription_status;

--5 prodcuts having highest percentage of purchases wiht discounts applied

select item_purchased,
round(100* sum(case when discount_applied='Yes' Then 1 else 0 end)/count(*),2)
as discount_rate
from customer
group by item_purchased
order by discount_rate desc
limit 5

--segment customers into new ,returning and loyal based on their total
--number of previous purchase and show count of each segement

with customer_type as (
select customer_id,previous_purchases,
case when previous_purchases=1 then 'New'
     when previous_purchases BETWEEN 2 AND 10 then 'Returning'
	 else 'Loyal'
	 end as customer_segment
	 from customer)
select customer_segment,count(*) as number_of_customers
from customer_type
group by customer_segment

-- what are top 3 purchased products within each category
with item_counts as (
select category,item_purchased,
count(customer_id) as total_orders,
row_number() over (partition by category order by count(customer_id) desc)
as item_rank
from customer
group by category,item_purchased
)
select item_rank,category,item_purchased,total_orders
from item_counts
where item_rank<=3

--are customers who are repeat buyers (more than 5 prev purchases) also likely to subscribe
select subscription_status,
count(customer_id)as repeat_buyers
from customer
where previous_purchases>5
group by subscription_status

--revenue contribution of each age group

select  age_group,sum(purchase_amount) as revenue
from customer
group by age_group
order by revenue desc
