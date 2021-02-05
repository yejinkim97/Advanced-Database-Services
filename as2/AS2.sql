
SET SERVEROUTPUT ON 
-- find_customer
CREATE OR REPLACE PROCEDURE find_customer (customer_id IN NUMBER, found OUT NUMBER) AS
BEGIN
    SELECT COUNT(*) INTO found FROM customers WHERE cust_no = customer_id;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        found := 0;
END;

-- find_product
CREATE OR REPLACE PROCEDURE find_product(productId IN NUMBER, price OUT products.prod_sell%TYPE) AS
BEGIN
    SELECT  prod_sell
    INTO    price
    FROM    products
    WHERE   prod_no = productId;
    
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        price := 0;
END;

-- add_order
CREATE OR REPLACE PROCEDURE add_order(customerId IN NUMBER, new_order_id OUT NUMBER) 
AS
max_order_id NUMBER;
BEGIN
    SELECT  MAX(order_no)INTO max_order_id FROM orders;
    
    new_order_id := max_order_id + 1;
    
    INSERT INTO orders
    (order_no, cust_no, status, rep_no, order_dt)
    VALUES
    (max_order_id + 1, customerId, 'C', 36, SYSDATE); --BECAREFUL HERE
END;
/
select  MAX(order_no) FROM orders;lines;
-- add_order_item
CREATE OR REPLACE PROCEDURE add_orderline (orderId IN orderlines.order_no%type,
                                itemId IN orderlines.line_no%type, 
                                 productId IN orderlines.prod_no%type, 
                                 quantity IN orderlines.qty%type,
                                  price IN orderlines.price%type) AS
BEGIN
    INSERT INTO orderlines
    (order_no, line_no, prod_no, qty, price)
    VALUES
    (orderId, itemId, productId, quantity, price);
    
END;

