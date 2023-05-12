drop database if exists churn;
-- creating database churn
create database churn;
use churn;
-- creating table codebytes
create table codebytes(
id int primary key,
subscription_start timestamp,
subscription_end timestamp,
segment double); 
-- inserting data into the table using table data import wizard 
select* from codebytes;

 

-- ==========QUESTIONS=============
-- Q-1. Select the first 100 rows of the data in the codebytes table.
select* from codebytes limit 100; 


/*Q2. Which months will you be able to calculate churn for? Check the range of months of data
 provided on subscription start.*/
 select distinct(month(subscription_start)) from codebytes;
 /*ANSWER== we have subscription start for four months only
 January
 feburary
 March
 December*/



 /* Q3. You’ll be calculating the churn rate for both segments (87 and 30) over the first 3 months of
2017 (you can’t calculate it for December, since there are no subscription_end values yet).
 To get started, create a temporary table of months that contains two columns: first-day and last-day
values containing the first day and last day of the month.*/
with months as
(select 
'2017-01-01' as 'first_day',
'2017-01-31' as 'last_day'
union
select
'2017-02-01' as 'first_day',
'2017-02-28' as 'last_day'
union
select
'2017-03-01' as 'first_day',
'2017-03-31' as 'last_day')
select* from months;




/*Q4 Create a temporary table called cross_join, from table codebytes and your months. Be
sure to SELECT every column*/
with month as
(select 
'2017-01-01' as 'first_day',
'2017-01-31' as 'last_day'
union
select
'2017-02-01' as 'first_day',
'2017-02-28' as 'last_day'
union
select
'2017-03-01' as 'first_day',
'2017-03-31' as 'last_day'),
cross_join as
(select* from codebytes
cross join month)
select* from cross_join;



/*Q5-Create a temporary table, status, from the cross_join table you created. This table should
contain:
id selected from cross_join
month as an alias of first_day
is_active_87 created using a CASE WHEN to find any users from segment 87 who existed
prior to the beginning of the month. This is 1 if true and 0 otherwise.
is_active_30 created using a CASE WHEN to find any users from segment 30 who existed prior
to the beginning of the month. This is 1 if true and 0 otherwise*/

with month as
(select 
'2017-01-01' as 'first_day',
'2017-01-31' as 'last_day'
union
select
'2017-02-01' as 'first_day',
'2017-02-28' as 'last_day'
union
select
'2017-03-01' as 'first_day',
'2017-03-31' as 'last_day'),
cross_join as
(select* from codebytes
cross join month),
status as 
(select id,first_day as month,
case
when (segment=87) and (subscription_start<first_day) and(subscription_end>first_day or subscription_end is null)
then 1 else 0
end as is_active_87,
case
when (segment=30) and (subscription_start<first_day) and(subscription_end>first_day or subscription_end is null)
then 1 else 0
end as is_active_30
from cross_join)
select* from status;
/*6. Add an is_canceled_87 and an is_canceled_30 column to the status temporary table. This
should be 1 if the subscription is canceled during the month and 0 otherwise.*/ 
with month as
(select 
'2017-01-01' as 'first_day',
'2017-01-31' as 'last_day'
union
select
'2017-02-01' as 'first_day',
'2017-02-28' as 'last_day'
union
select
'2017-03-01' as 'first_day',
'2017-03-31' as 'last_day'),
cross_join as
(select* from codebytes
cross join month),
status as 
(select id,first_day as month,
case when 
(segment=87) and (subscription_start<first_day) and(subscription_end>first_day or subscription_end is null)
then 1 else 0 end as is_active_87,
case when 
(segment=30) and (subscription_start<first_day) and(subscription_end>first_day or subscription_end is null)
then 1 else 0 end as is_active_30,
case when 
(segment=87) and (subscription_end between first_day and last_day)
then 1 else 0 end as is_cancelled_87,
case when
(segment=30) and (subscription_end between first_day and last_day)
then 1 else 0 end as is_cancelled_30
from cross_join)
select * from status;
/*
Create a status_aggregate temporary table that is a SUM of the active and canceled
subscriptions for each segment, for each month.
The resulting columns should be:
sum_active_87
sum_active_30
sum_canceled_87
Sum_canceled_30*/
with month as
(select 
'2017-01-01' as 'first_day',
'2017-01-31' as 'last_day'
union
select
'2017-02-01' as 'first_day',
'2017-02-28' as 'last_day'
union
select
'2017-03-01' as 'first_day',
'2017-03-31' as 'last_day'),
cross_join as
(select* from codebytes
cross join month),
status as 
(select id,first_day as month,
case when 
(segment=87) and (subscription_start<first_day) and(subscription_end>first_day or subscription_end is null)
then 1 else 0 end as is_active_87,
case when 
(segment=30) and (subscription_start<first_day) and(subscription_end>first_day or subscription_end is null)
then 1 else 0 end as is_active_30,
case when 
(segment=87) and (subscription_end between first_day and last_day)
then 1 else 0 end as is_cancelled_87,
case when
(segment=30) and (subscription_end between first_day and last_day)
then 1 else 0 end as is_cancelled_30
from cross_join),
status_aggregate as
(select month,
sum(is_active_87) as sum_active_87,
sum(is_active_30) as sum_active_30,
sum(is_cancelled_87) as sum_cancelled_87,
sum(is_cancelled_30) as sum_cancelled_30
from status group by month) 
select* from status_aggregate; 

-- 8. Calculate the churn rates for the two segments over the three month period. Which segment has a lower churn rate
with month as
(select 
'2017-01-01' as 'first_day',
'2017-01-31' as 'last_day'
union
select
'2017-02-01' as 'first_day',
'2017-02-28' as 'last_day'
union
select
'2017-03-01' as 'first_day',
'2017-03-31' as 'last_day'),
cross_join as
(select* from codebytes
cross join month),
status as 
(select id,first_day as month,
case when 
(segment=87) and (subscription_start<first_day) and(subscription_end>first_day or subscription_end is null)
then 1 else 0 end as is_active_87,
case when 
(segment=30) and (subscription_start<first_day) and(subscription_end>first_day or subscription_end is null)
then 1 else 0 end as is_active_30,
case when 
(segment=87) and (subscription_end between first_day and last_day)
then 1 else 0 end as is_cancelled_87,
case when
(segment=30) and (subscription_end between first_day and last_day)
then 1 else 0 end as is_cancelled_30
from cross_join)
select * from status;
/*
Create a status_aggregate temporary table that is a SUM of the active and canceled
subscriptions for each segment, for each month.
The resulting columns should be:
sum_active_87
sum_active_30
sum_canceled_87
Sum_canceled_30*/
with month as
(select 
'2017-01-01' as 'first_day',
'2017-01-31' as 'last_day'
union
select
'2017-02-01' as 'first_day',
'2017-02-28' as 'last_day'
union
select
'2017-03-01' as 'first_day',
'2017-03-31' as 'last_day'),
cross_join as
(select* from codebytes
cross join month),
status as 
(select id,first_day as month,
case when 
(segment=87) and (subscription_start<first_day) and(subscription_end>first_day or subscription_end is null)
then 1 else 0 end as is_active_87,
case when 
(segment=30) and (subscription_start<first_day) and(subscription_end>first_day or subscription_end is null)
then 1 else 0 end as is_active_30,
case when 
(segment=87) and (subscription_end between first_day and last_day)
then 1 else 0 end as is_cancelled_87,
case when
(segment=30) and (subscription_end between first_day and last_day)
then 1 else 0 end as is_cancelled_30
from cross_join),
status_aggregate as
(select month,
sum(is_active_87) as sum_active_87,
sum(is_active_30) as sum_active_30,
sum(is_cancelled_87) as sum_cancelled_87,
sum(is_cancelled_30) as sum_cancelled_30
from status group by month) 
select month,
100 * sum_cancelled_87/sum_active_87 as chrun_rate_87,
100 * sum_cancelled_30/sum_active_30 as chrun_rate_30
from status_aggregate
order by month; 
 
 -- from the above table we can see that segment_30 has lower churn rate for all months than segment_87


