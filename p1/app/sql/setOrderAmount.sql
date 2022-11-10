CREATE OR REPLACE FUNCTION setAmountOrder() RETURNS VOID
AS $$
BEGIN
	UPDATE orders
	SET amount = sum
	FROM 	(SELECT orderid, SUM(total2)
			FROM orderdetail GROUP BY orderid) AS aux
	WHERE orders.orderid = aux.orderid;
	UPDATE orders
	SET total = amount + (amount * (tax/100));	
END;
$$ LANGUAGE plpgsql;

SELECT setAmountOrder();