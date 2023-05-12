# Churn-Analysis-of-a-Comapny 
Here in this Mysql based query
we had to calculate the churn rate for both segments (87 and 30) over the first 3 months of
2017 (we can’t calculate it for December, since there are no subscription_end values yet). 
We create a temporary table of months that contains two columns: first-day and last-day
values containing the first day and last day of the month.
We created a temporary table called cross_join, from table codebytes and  months
We created a temporary table, status, from the cross_join table you created. This table should
contain:
id selected from cross_join
month as an alias of first_day
is_active_87 created using a CASE WHEN to find any users from segment 87 who existed
prior to the beginning of the month. This is 1 if true and 0 otherwise.
is_active_30 created using a CASE WHEN to find any users from segment 30 who existed prior
to the beginning of the month. This is 1 if true and 0 otherwise.
We an is_canceled_87 and an is_canceled_30 column to the status temporary table. This
should be 1 if the subscription is canceled during the month and 0 otherwise.
We created a status_aggregate temporary table that is a SUM of the active and canceled
subscriptions for each segment, for each month.
The resultant columns are:sum_active_87,sum_active_30,sum_canceled_87,sum_canceled_3
