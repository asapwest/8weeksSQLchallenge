CREATE SCHEMA pizza_runner;
SET search_path = pizza_runner;

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  "runner_id" INTEGER,
  "registration_date" DATE
);
INSERT INTO runners
  ("runner_id", "registration_date")
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  "order_id" INTEGER,
  "customer_id" INTEGER,
  "pizza_id" INTEGER,
  "exclusions" VARCHAR(4),
  "extras" VARCHAR(4),
  "order_time" TIMESTAMP
);

INSERT INTO customer_orders
  ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" VARCHAR(19),
  "distance" VARCHAR(7),
  "duration" VARCHAR(10),
  "cancellation" VARCHAR(23)
);

INSERT INTO runner_orders
  ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  "pizza_id" INTEGER,
  "pizza_name" TEXT
);
INSERT INTO pizza_names
  ("pizza_id", "pizza_name")
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  "pizza_id" INTEGER,
  "toppings" TEXT
);
INSERT INTO pizza_recipes
  ("pizza_id", "toppings")
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  "topping_id" INTEGER,
  "topping_name" TEXT
);
INSERT INTO pizza_toppings
  ("topping_id", "topping_name")
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  
SELECT * FROM pizza_runner.customer_orders;
SELECT * FROM pizza_runner.pizza_names;
SELECT * FROM pizza_runner.pizza_recipes;
SELECT * FROM pizza_runner.pizza_toppings;
SELECT * FROM pizza_runner.runner_orders;
SELECT * FROM pizza_runner.runners;

--create a temp table to remove the null values in customer_orders
 SELECT order_id, customer_id, pizza_id,
 	CASE WHEN exclusions = 'null' THEN '0' ELSE exclusions END AS exclusions,
	CASE WHEN extras ISNULL OR extras = 'null' THEN '0' ELSE extras 
	END AS extras 
 INTO TEMP TABLE temp_customer_orders
 FROM pizza_runner.customer_orders;

--i can query temp table for customer orders now
SELECT * from temp_customer_orders;
DROP TABLE temp_customer_orders;

--creating another temp table for runner_orders
SELECT runner_id, order_id,
  CASE WHEN duration = 'null' THEN '0' ELSE duration END AS duration,
  CASE WHEN cancellation = 'null' THEN '0' 
  WHEN cancellation ISNULL THEN '0'
  WHEN cancellation = '' THEN '0'
  ELSE cancellation END AS cancellation,
  CASE WHEN pickup_time = 'null' THEN '0'ELSE pickup_time END AS pickup_time,
  CASE WHEN distance = 'null' THEN '0' ELSE distance END AS distance
  INTO TEMP TABLE temp_runner_orders
FROM pizza_runner.runner_orders;


--we can query the temp table to see the output
SELECT * FROM temp_runner_orders
DROP TABLE temp_runner_orders;


--we can proceed to answer our questions now...

--1. How many pizzas were ordered?
SELECT COUNT(order_id) AS pizza_ordered
FROM temp_customer_orders;


--2. How many unique customer orders were made?
SELECT COUNT (DISTINCT order_id) AS unique_customer_order
FROM temp_customer_orders;


--3. How many successful orders were delivered by each runner?
SELECT runner_id, COUNT(order_id) AS successful_orders 
FROM temp_runner_orders -- Use the runner_orders table
WHERE cancellation = '0'   -- Consider only successful order
GROUP BY runner_id;


--4. How many of each type of pizza was delivered?
SELECT pn.pizza_name, COUNT(co.order_id) AS pizzas_delivered -- Count the number of orders
FROM temp_customer_orders AS co
JOIN pizza_runner.pizza_names AS pn
ON co.pizza_id = pn.pizza_id
GROUP BY pn.pizza_name;


--5. How many Vegetarian and Meatlovers were ordered by each customer?
SELECT  customer_id,
  SUM(CASE WHEN pizza_id = 1 THEN 1 ELSE 0 END) AS vegetarian_pizzas_ordered,
  SUM(CASE WHEN pizza_id = 2 THEN 1 ELSE 0 END) AS meatlovers_pizzas_ordered
FROM temp_customer_orders
GROUP BY customer_id;


--6. What was the maximum number of pizzas delivered in a single order?
SELECT order_id, customer_id, COUNT(*) AS maximum_pizza
FROM temp_customer_orders
GROUP BY order_id, customer_id
ORDER BY maximum_pizza DESC
LIMIT 1


--7. For each customer, how many delivered pizzas had at least 1 change 
--and how many had no changes?
SELECT customer_id, COUNT(*) AS pizzas_with_changes
FROM temp_customer_orders
WHERE exclusions != '' OR extras != ''
GROUP BY customer_id;

SELECT * FROM temp_customer_orders


--8. How many pizzas were delivered that had both exclusions and extras?
SELECT COUNT(*) AS pizza_delivered
FROM temp_customer_orders as co
JOIN pizza_runner.runner_orders as ro
  ON co.order_id = ro.order_id
WHERE (co.exclusions != '' OR co.exclusions IS NOT NULL)
  AND (co.extras != '' OR co.extras IS NOT NULL)
  AND (ro.cancellation = '' OR ro.cancellation IS NULL);
  
  select * from temp_customer_orders
  
--9. What was the total volume of pizzas ordered for each hour of the day?
SELECT date_part('hour', order_time) AS hour, COUNT(*) as total_pizzas_ordered
FROM pizza_runner.customer_orders
GROUP BY hour
ORDER BY hour;
select * from temp_customer_orders

--10. What was the volume of orders for each day of the week?
SELECT TO_CHAR(order_time, 'DAY') AS day_of_week, COUNT(*) as total_orders
FROM pizza_runner.customer_orders
GROUP BY day_of_week
ORDER BY day_of_week;

