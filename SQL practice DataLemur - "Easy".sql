/* 1 - write a query to obtain a histogram of tweets posted per user in 2022. */
SELECT tweet_count_per_user AS tweet_bucket,
COUNT (user_id) AS users_num
FROM (
SELECT user_id,
COUNT(tweet_id) AS tweet_count_per_user
FROM tweets
WHERE tweet_date BETWEEN '2022-01-01' AND '2022-12-31'
GROUP BY user_id) AS total_tweets

GROUP BY tweet_count_per_user;

/* 1- 2nd */

SELECT 
tweet_count_per_user AS tweet_bucket,
COUNT(user_id) AS users_num
FROM (
SELECT user_id,
COUNT (tweet_id) AS tweet_count_per_user
FROM tweets
WHERE EXTRACT(YEAR FROM tweet_date) = '2022'
GROUP BY user_id) AS total_tweets

  ## amended ##
GROUP BY tweet_count_per_user;

SELECT part, assembly_step
FROM parts_assembly
WHERE finish_date is NULL
;

/* 2 - Write a query to list the candidates who possess all of the required skills for the job. */
SELECT candidate_id
FROM candidates
WHERE skill IN ('Python', 'Tableau', 'PostgreSQL')
GROUP BY candidate_id

HAVING COUNT (skill) = 3
ORDER BY candidate_id;

/* 3 - Write a query to return the IDs of the Facebook pages that have zero likes. */
SELECT pages.page_id
FROM pages
LEFT OUTER JOIN page_likes ON pages.page_id = page_likes.page_id
WHERE page_likes.page_id IS NULL;

/* 4 - Write a query to determine which parts have begun the assembly process but are not yet finished.*/
SELECT part, assembly_step
FROM parts_assembly
WHERE finish_date is NULL;

/* !5 - Write a query that calculates the total viewership for laptops and mobile devices where mobile is defined as the sum of tablet and phone viewership.*/
SELECT 
COUNT(*) FILTER (WHERE device_type = 'laptop') AS laptop_views,
COUNT(*) FILTER (WHERE device_type IN ('tablet', 'phone')) AS mobile_deviews
FROM viewership;

/* !6 - for each user who posted at least twice in 2021, 
write a query to find the number of days between each user’s first post of the year and last post of the year in the year 2021.*/
SELECT 
  user_id,
  MAX(post_date::DATE) - MIN(post_date::DATE) AS days_between
FROM posts
WHERE DATE_PART('year', post_date::DATE) = 2021
GROUP BY user_id
HAVING COUNT (post_id)>1;

/* !7 - Write a query to identify the top 2 Power Users who sent the highest number of messages on Microsoft Teams in August 2022. 
Display the IDs of these 2 users along with the total number of messages they sent. 
Output the results in descending order based on the count of the messages.*/
SELECT 
sender_id,
COUNT(message_id) AS message_count
FROM messages
WHERE sent_date BETWEEN '8/1/2022' AND '8/31/2022'
GROUP BY sender_id
ORDER BY message_count DESC
LIMIT 2;

## or ##
  
SELECT 
  sender_id,
  COUNT(message_id) AS count_messages
FROM messages
WHERE EXTRACT(MONTH FROM sent_date) = '8'
  AND EXTRACT(YEAR FROM sent_date) = '2022'
GROUP BY sender_id;

/* ! cte vs subquery !8 -  Write a query to retrieve the count of companies that have posted duplicate job listings.*/
WITH job_count_cte AS (
SELECT 
company_id,
title,
description,
COUNT (job_id) AS job_count
FROM job_listings
GROUP BY title, description, company_id
)

SELECT COUNT ( DISTINCT company_id) AS duplicate_companies
FROM job_count_cte
WHERE job_count >1;

##SYNTAX##
  
WITH cte_name (column1, column2, ...)
AS (
    -- CTE query definition here
    SELECT column1, column2, ...
    FROM table_name
    WHERE condition
)
-- Main query that uses the CTE
SELECT *
FROM cte_name;

/*Common Table Expression (CTE) CONCEPT*/

WITH cte_name (column1, column2, ...)
AS (
    -- CTE query definition here
    SELECT column1, column2, ...
    FROM table_name
    WHERE condition
)
-- Main query that uses the CTE
SELECT *
FROM cte_name;

/***************/

/* ! 9 - Write a query to retrieve the top three cities that have the highest number of completed trade orders listed in descending order. 
  Output the city name and the corresponding number of completed trade orders.*/

SELECT 
  users.city, 
  COUNT(trades.order_id) AS total_orders 
FROM trades 
INNER JOIN users 
  ON trades.user_id = users.user_id 
WHERE trades.status = 'Completed' 
GROUP BY users.city 
ORDER BY total_orders DESC
LIMIT 3;

/* ! 10 write a query to retrieve the average star rating for each product, grouped by month.*/
## Try #1 ##
SELECT product_id,
AVG(stars) AS avg_stars
FROM reviews
WHERE product_id AS product
EXTRACT(MONTH from submit_date) AS mth
GROUP BY product
ORDER BY mth;

## 10 Try #2 ##
  SELECT product_id,
EXTRACT(MONTH from submit_date) AS mth,
ROUND (AVG(stars), 2) AS avg_stars,
FROM reviews
WHERE product_id AS product
GROUP BY product
ORDER BY mth;

## 10 Try 3 ##
SELECT 
product_id,
EXTRACT(MONTH from submit_date) AS mth,
ROUND(AVG(stars), 2) AS avg_stars,
FROM reviews
SORT BY mth, product_id;

## 10 Correct ##
SELECT 
  EXTRACT(MONTH FROM submit_date) AS mth,
  product_id,
  ROUND(AVG(stars), 2) AS avg_stars
FROM reviews
GROUP BY 
  EXTRACT(MONTH FROM submit_date), 
  product_id
ORDER BY mth, product_id;

## 10 Highlight ##
  GROUP BY 
EXTRACT(MONTH from submit_date),
product_id
ORDER BY mth, product_id;

/* !11 Write a query to calculate the click-through rate (CTR) for the app in 2022 and round the results to 2 decimal places.*/
## Try 1 ##

SELECT app_id,
ctr
FROM (
SELECT event_type, timestamp
FROM events
WHERE event_type
)
GROUP BY app_id;


## 11 Correct ##

SELECT
  app_id,
  ROUND(100.0 *
    SUM(CASE WHEN event_type = 'click' THEN 1 ELSE 0 END) /
    SUM(CASE WHEN event_type = 'impression' THEN 1 ELSE 0 END), 2)  AS ctr_rate
FROM events
WHERE timestamp >= '2022-01-01' 
  AND timestamp < '2023-01-01'
GROUP BY app_id;

/* 12 Write a query to calculate the total drug sales for each manufacturer. 
  Round the answer to the nearest million and report your results in descending order of total sales. 
  In case of any duplicates, sort them alphabetically by the manufacturer name. */
## Try 1 ##
SELECT manufacturer,
ROUND(SUM(),10) AS sale,
FROM pharmacy_sales
GROUP BY manufacturer
ORDER BY manufacturer;

## Try 2 ##
  SELECT manufacturer,
ROUND(SUM(total_sales),1000000) AS sale
FROM pharmacy_sales
GROUP BY manufacturer
ORDER BY manufacturer,
total_sales DESC;

## Try 3 ##
  SELECT manufacturer,
ROUND(SUM(total_sales),1000000), 'million') AS sale_mil
FROM pharmacy_sales
GROUP BY manufacturer
ORDER BY manufacturer,
ROUND(SUM(total_sales),1000000, 'million') DESC;

## Correct ##

SELECT 
  manufacturer, 
  CONCAT( '$', ROUND(SUM(total_sales) / 1000000), ' million') AS sales_mil 
FROM pharmacy_sales 
GROUP BY manufacturer 
ORDER BY SUM(total_sales) DESC, manufacturer;
