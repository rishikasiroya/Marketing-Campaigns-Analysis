create database telecom_connect_db;
use telecom_connect_db;
select * from customers;
select * from campaigns;
select * from responses;
select * from subscriptions;

# Calculate the total number of customers.
select count(distinct customer_id) as totalcustomers from customers;

# Find the number of customers by age group and gender.
select gender, count(customer_id) as gender_count from customers
group by gender;

select case
	when age < 20 then '>20'
    when age between 20 and 40 then '20-40'
    when age between 40 and 60 then '40-60'
    when age > 60 then '<60'
    else Null
end as age_group, gender,
count(*) as customer_count
from customers
group by age_group, gender
order by age_group, gender;

#Determine the geographic distribution of customers by state and city.
select state, count(*) as customercount from customers
group by state
order by count(*) desc;

#Find the total number of active and cancelled subscriptions.
select status, count(*) as totalsubscription from subscriptions
group by status;

# Identify the most popular subscription plans.
select plan_name, count(*) from subscriptions
group by plan_name
order by plan_name desc;

#Calculate the average subscription duration for active and cancelled plans.
select status,
avg(dateiff(str_to_date(end_date, '%d/%m/%Y'), str_to_date(start_date, '%d/%m/%Y'))) as avg_days
from subscriptions
group by status;
select s.status , avg(datediff(str_to_date(end_date, '%d/%m/%Y'),str_to_date(start_date, '%d/%m/%Y'))) as AVG_DAYS from subscriptions s group by s.status;

#Calculate the total number of campaigns run in the past year.
select count(campaign_name) from campaigns
where end_date like '__/__/2024';

#Determine the total budget spent on campaigns.
select sum(budget) from campaigns;

# Find the number of customers targeted in each campaign.
select c.campaign_name as campaignname,
count(r.customer_id) as customercount
from campaigns c
left join responses r
on c.campaign_id = r.campaign_id
group by c.campaign_name;

# Calculate the response rate for each campaign (`number of responses / number of targeted customers`). 
select c.campaign_name,
count(r.response_id) as no_of_responses,
count(r.customer_id) as no_of_targeted_customers,
case
	when count(distinct r.customer_id) > 0 then count(r.response_id)/count(distinct r.customer_id)
    else 0
end as response_rate
from campaigns c
left join responses r on c.campaign_id = r.campaign_id
group by c.campaign_id, c.campaign_name
order by response_rate desc;

#Identify the most effective channels (`email`, `SMS`, `social media`) based on response rates.
select channel,
count(response_id) as no_of_response,
count(distinct customer_id) as no_of_targeted_customers,
case
	when count(distinct customer_id) > 0 then count(response_id)/count(distinct customer_id)
    else 0
end as response_rate
from responses
group by channel
order by response_rate desc;

#Analyze customer response types (`clicked`, `signed up`, `ignored`) for each campaign.
select c.campaign_id,
c.campaign_name,
r.response_type,
count(*) as no_of_responses
from campaigns c
inner join responses r on c.campaign_id = r.campaign_id
group by c.campaign_id, c.campaign_name, r.response_type
order by 1,2,3;

#Segment customers based on their response to campaigns: responders vs. non-responders.
select customer_id, case
	when response_type <> 'Ignored' then 'Responder'
    when response_type = 'Ignored' then 'Non-responder'
    else null
    end as segment
from responses
order by customer_id;

#Identify characteristics of high-engagement customers (e.g., age group, gender, location).
select c.customer_id, c.age, c.gender, c.state, r.response_type
from customers c
inner join responses r on c.customer_id = r.customer_id
where r.response_type = 'Signed Up'
group by c.customer_id, c.age, c.gender, c.state, r.response_type
order by 1;

#Identify customers who have cancelled their subscriptions in the past year.
select customer_id, status, end_date from subscriptions
where status = 'Cancelled' and end_date like '%2024'
order by 1;

#Analyze the churn rate (`number of churned customers / total customers`).
select count(c.customer_id) as total_customers,
count(s.status) as no_of_churned_customers,
case
	when count(c.customer_id) > 0 then count(s.status)/count(c.customer_id)
    else 0
end as churned_rate
from customers c
left join subscriptions s on c.customer_id = s.customer_id
where s.status = 'Cancelled'
group by c.customer_id;

#Find common characteristics of churned customers.
select c.customer_id, c.age, c.gender, c.state
from customers c
left join subscriptions s on c.customer_id = s.customer_id
where s.status = 'Cancelled'
group by c.customer_id, c.age, c.gender, c.state;

#Rank campaigns based on their performance using `RANK()`.
select c.campaign_id, c.campaign_name, r.response_type, rank() over (partition by r.response_type order by count(response_type) desc) as campaigns_rank
from campaigns c
inner join responses r on c.campaign_id = r.campaign_id
group by c.campaign_id, c.campaign_name, r.response_type;