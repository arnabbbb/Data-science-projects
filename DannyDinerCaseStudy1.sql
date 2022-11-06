USE japanese_hotel;

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 
 CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);
  
INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

  -- What is the total amount each customer spent at the restaurant?

  WITH cte AS(
  SELECT S.customer_id, S.product_id, M.price
  FROM sales AS S
  JOIN menu AS M
  ON S.product_id = M.product_id
  )
  
  SELECT customer_id, SUM(price) AS amount_spent
  FROM cte
  GROUP BY customer_id;

  --How many days has each customer visited the restaurant?

  WITH cte2 AS(
  SELECT customer_id, order_date,
  ROW_NUMBER() OVER(PARTITION BY order_date, customer_id ORDER BY order_date) AS ranked
  FROM sales

  ),
  cte3 AS(
  SELECT * FROM cte2
  WHERE ranked = 1
  )
  SELECT customer_id, COUNT(*)
  FROM cte3
  GROUP BY customer_id;
  
  --What was the first item from the menu purchased by each customer?

  WITH cte4 AS(
  SELECT *,
  ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date) AS ranker
  FROM sales
  )
  SELECT customer_id,product_id
  FROM cte4
  WHERE ranker = 1;

  --What is the most purchased item on the menu and how many times was it purchased by all customers?

  WITH cte5 AS(
  SELECT product_id, COUNT(product_id) AS product_count
  FROM sales
  GROUP BY product_id
  ),
  cte6 AS(
  SELECT product_id 
  FROM cte5 
  WHERE product_count = 
  (SELECT MAX(product_count) FROM cte5)
  ),
  cte7 AS(
  SELECT * FROM sales
  WHERE product_id = 
  (SELECT * FROM cte6)
  )
  SELECT customer_id, COUNT(product_id) AS count_prod3
  FROM cte7
  GROUP BY customer_id;

  SELECT product_name FROM menu
  WHERE product_id = 3

  --Which item was the most popular for each customer?

  WITH cte8 AS(
  SELECT S.*, M.product_name
  FROM sales AS S
  JOIN menu AS M
  ON S.product_id = M.product_id
  ),
  cte9 AS(
  SELECT customer_id, product_name, COUNT(*) AS counter
  FROM cte8
  GROUP BY customer_id, product_name
  ),
  cte10 AS(
 SELECT customer_id,MAX(counter) AS max_count
 FROM cte9
 GROUP BY customer_id
 )
 SELECT A.*, B.product_name
 FROM cte10 AS A
 JOIN cte9 AS B
 ON A.customer_id = B.customer_id 
 AND A.max_count = B.counter
 ORDER BY customer_id

 --Which item was purchased first by the customer after they became a member?

 WITH cte10 AS(
 SELECT M.*, S.order_date, S.product_id, DATEDIFF(day, M.join_date,S.order_date) AS date_dif
 FROM members AS M
 JOIN sales AS S
 ON M.customer_id = S.customer_id
  WHERE DATEDIFF(day, M.join_date,S.order_date) >= 0
  ),
  cte11 AS(
  SELECT customer_id, MIN(date_dif) AS min_date
  FROM cte10
  GROUP BY customer_id
  ),
  cte12 AS(
  SELECT A.*, B.product_id
  FROM cte11 AS A
  JOIN cte10 AS B
  ON A.customer_id = B.customer_id
  AND A.min_date = B.date_dif
  )
  SELECT C.customer_id, C.min_date, D.product_name
  FROM cte12 AS C
  JOIN menu AS D
  ON C.product_id = D.product_id
  ;
 
 --Which item was purchased just before the customer became a member?

 WITH cte13 AS(
 SELECT S.customer_id, S.product_id , DATEDIFF(day, join_date, order_date) AS date_dif
 FROM sales AS S
 JOIN members AS M
 ON S.customer_id = M.customer_id
 WHERE DATEDIFF(day, join_date, order_date) < 0
 ),
 cte14 AS(
 SELECT customer_id, MAX(date_dif) AS min_date
 FROM cte13
 GROUP BY customer_id
 ),
 cte15 AS(
 SELECT A.customer_id, A.min_date, B.product_id 
 FROM cte14 AS A
 JOIN cte13 AS B
 ON A.customer_id = B.customer_id
 AND A.min_date = B.date_dif
 )
  SELECT C.customer_id, C.min_date, D.product_name
  FROM cte15 AS C
  JOIN menu AS D
  ON C.product_id = D.product_id

  --What is the total items and amount spent for each member before they became a member?
  WITH cte16 AS(
  SELECT S.*, M.join_date, 
  DATEDIFF(day, join_date, order_date) AS date_dif
  FROM sales AS S
  JOIN members AS M
  ON S.customer_id = M.customer_id
  WHERE DATEDIFF(day, join_date, order_date) < 0
  ),
  cte17 AS(
  SELECT C.customer_id, C.product_id, M.price
  FROM cte16 AS C
  JOIN menu AS M
  ON C.product_id = M.product_id
  )
  SELECT customer_id, 
  SUM(price) AS total_price,
  COUNT(product_id) AS prod_count
  FROM cte17
  GROUP BY customer_id
  ;

  --If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

  WITH cte18 AS(
  SELECT S.customer_id, S.product_id, M.price,M.product_name, 
  CASE 
  WHEN M.product_name = 'sushi' THEN M.price*20
  ELSE price*10 END AS points
  FROM sales AS S
  JOIN menu AS M
  ON S.product_id = M.product_id
  )
  SELECT customer_id, SUM(points)
  FROM cte18
  GROUP BY customer_id

  --In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

  WITH cte19 AS(
  SELECT S.*, M.join_date, DATEADD(day,7,M.join_date) AS week_after_join
  FROM sales AS S
  JOIN members AS M
  ON S.customer_id = M.customer_id 
  WHERE DATEDIFF(day,order_date,'2021-01-31') >= 0 
  ),
  cte20 AS(
  SELECT A.*, B.product_name,B.price
  FROM cte19 AS A
  JOIN menu AS B
  ON A.product_id = B.product_id
  ),
  cte21 AS(
  SELECT *,
  CASE
  WHEN DATEDIFF(day,join_date,order_date) >= 0 
  AND DATEDIFF(day,order_date, week_after_join) >= 0
  OR product_name = 'sushi'
  THEN price*20 
  ELSE price*10 END AS points
  FROM cte20
  )

  SELECT customer_id, SUM(points)
  FROM cte21
  GROUP BY customer_id
  

/* Recreate the following table output using the available data:
customer_id 	order_date 	product_name 	price 	member
A 	2021-01-01 	curry 	15 	N
A 	2021-01-01 	sushi 	10 	N
A 	2021-01-07 	curry 	15 	Y
A 	2021-01-10 	ramen 	12 	Y
A 	2021-01-11 	ramen 	12 	Y
A 	2021-01-11 	ramen 	12 	Y
B 	2021-01-01 	curry 	15 	N
B 	2021-01-02 	curry 	15 	N
B 	2021-01-04 	sushi 	10 	N
B 	2021-01-11 	sushi 	10 	Y
B 	2021-01-16 	ramen 	12 	Y
B 	2021-02-01 	ramen 	12 	Y
C 	2021-01-01 	ramen 	12 	N
C 	2021-01-01 	ramen 	12 	N
C 	2021-01-07 	ramen 	12 	N */


SELECT S.customer_id , S.order_date, M.product_name,M.price ,
CASE WHEN Me.customer_id IS NULL OR DATEDIFF(day,Me.join_date, S.order_date) < 0 THEN 'N' 
ELSE 'Y' END AS member
FROM sales AS S
JOIN menu AS M 
ON S.product_id = M.product_id
LEFT JOIN members AS Me
ON S.customer_id = Me.customer_id


