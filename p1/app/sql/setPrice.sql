UPDATE orderdetail
SET total2 =  quantity * natural_join.price/power(1.02, (((SERGIO no se que año se poner)) - natural_join.year))
FROM (  SELECT orderid, prod_id, price, EXTRACT(YEAR FROM (DATE(orders.orderdate))) AS year
	FROM products NATURAL JOIN orderdetail NATURAL JOIN orders) AS natural_join
WHERE natural_join.orderid = orderdetail.orderid;