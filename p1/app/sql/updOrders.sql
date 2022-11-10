CREATE OR REPLACE FUNCTION updOrders()
RETURNS TRIGGER
AS $$
BEGIN
	-- Para insertar en ordertails
	IF (TG_OP = 'INSERT') THEN
		NEW.total2 = (SELECT price FROM products WHERE products.prod_id = NEW.prod_id) * NEW.quantity;

		UPDATE orders
		SET netamount = netamount + NEW.total2
		WHERE orders.orderid = NEW.orderid;

		UPDATE orders
		SET totalamount = netamount + (netamount * (tax/100))
		WHERE orders.orderid = NEW.orderid;
		RETURN NEW;
		
	-- Borrar en ordertails
	ELSIF (TG_OP = 'DELETE') THEN
		UPDATE orders
		SET netamount = netamount - OLD.total2
		WHERE orders.orderid = OLD.orderid;
		
		UPDATE orders
		SET totalamount = netamount + (netamount * (tax/100))
		WHERE orders.orderid = OLD.orderid;
		RETURN OLD;
		
	-- Update en ordertails
	ELSE
		NEW.total2 = (SELECT price FROM products WHERE products.prod_id = OLD.prod_id) * NEW.quantity;

		UPDATE orders
		SET netamount = netamount + (NEW.total2 - OLD.total2)
		WHERE orders.orderid = NEW.orderid;

		UPDATE orders
		SET totalamount = netamount + (netamount * (tax/100))
		WHERE orders.orderid = NEW.orderid;
		RETURN NEW;		
	END IF;
	
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER t_updOrders BEFORE INSERT OR UPDATE OR DELETE
ON orderdetail FOR EACH ROW 
EXECUTE PROCEDURE updOrders();