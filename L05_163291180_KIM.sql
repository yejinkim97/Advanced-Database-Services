-- ***********************
-- Name: Ye Jin Kim 
-- Student ID: 163291180    
-- Date: 12/11/2020
-- Purpose: Lab 5 DBS311
-- ***********************

SET SERVEROUTPUT ON

-- Question 1 – 	Write a stored procedure that decide if it's even or odd
-- Q1 SOLUTION –

CREATE OR REPLACE PROCEDURE  evenodd  (instuff in number)
as
BEGIN
if mod(instuff, 2) = 0 
	then dbms_output.put_line('The number is even.');
else 
	dbms_output.put_line('The number is odd.');
end if;
END evenodd;

BEGIN
evenodd(&input);  
end;

-- Question 2 – 2.	Create a stored procedure named find_employee. This procedure gets an employee number.
-- Q2 SOLUTION –
CREATE OR REPLACE PROCEDURE  find_employee  (emp_num in number)
as
    fname VARCHAR2(20 BYTE);
    lname VARCHAR2(25 BYTE);
    emai VARCHAR2(25 BYTE);
    phone VARCHAR2(20 BYTE);
    hire DATE;
    jobb VARCHAR2(10 BYTE);
BEGIN
select first_name, last_name, email, phone_number, hire_date, job_id
    into fname, lname, emai, phone, hire, jobb
from employees
where emp_num=employee_id;
DBMS_OUTPUT.PUT_LINE ('First name: ' || fname);
DBMS_OUTPUT.PUT_LINE ('Last name: ' || lname);
DBMS_OUTPUT.PUT_LINE ('Email: ' || emai);
DBMS_OUTPUT.PUT_LINE ('Phone: ' || phone);
DBMS_OUTPUT.PUT_LINE ('Hire date: ' || hire);
DBMS_OUTPUT.PUT_LINE ('Job title: ' || jobb);
EXCEPTION
	WHEN TOO_MANY_ROWS
  	THEN 
      		DBMS_OUTPUT.PUT_LINE ('Too Many Rows Returned!');
    WHEN NO_DATA_FOUND
  	THEN 
      	DBMS_OUTPUT.PUT_LINE ('No Data Found!');
    WHEN OTHERS
  	THEN 
      		DBMS_OUTPUT.PUT_LINE ('Error!');
END find_employee;

BEGIN
find_employee(&input);  
end;

-- Question 3 – Write a procedure named update_price_tents to update the price of all products in a given type and the given amount to be added to the current selling price if the price is greater than 0. The procedure shows the number of updated rows if the update is successful.

-- Q3 SOLUTION –

CREATE OR REPLACE PROCEDURE  update_price_tents (Prodd_type in products.prod_type%TYPE, amount in products.prod_sell%TYPE)
as Rows_updated number;
BEGIN
select count(prod_type) into Rows_updated from products where prod_type = Prodd_type;

if (amount>0 and Rows_updated>0) then 
update products
set prod_sell=prod_sell+amount
where prod_type=Prodd_type;
DBMS_OUTPUT.PUT_LINE ( SQL%ROWCOUNT ||' rows updated'  );
else 
DBMS_OUTPUT.PUT_LINE ( 'Zero rows updated'  );
end if;

EXCEPTION 
WHEN NO_DATA_FOUND THEN
DBMS_OUTPUT.PUT_LINE('No data');   
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('errors');     


END update_price_tents;

declare
Prodd_type varchar2(20) := 'Tents';
amount number:= 5;
BEGIN
update_price_tents(Prodd_type,amount);  
end;

rollback;

-- Question 4 –Write a stored procedure named update_low_prices_. increases the price of products by 1 or 2% (Example of 2% -- prod_sell * 1.02) based on if the selling price (prod_sell) is less than the average price of all products. 
-- Q4 SOLUTION –
CREATE OR REPLACE PROCEDURE  update_low_prices_163291180 
as aver products.prod_sell%TYPE;
    percen number;
BEGIN
select avg(prod_sell) into aver from products;

if (aver<=1000) then 
update products
set prod_sell=prod_sell*1.02
where prod_sell<aver;
DBMS_OUTPUT.PUT_LINE ( 'Number of updates:  ' || SQL%ROWCOUNT  );
elsif (aver>1000) then 
update products
set prod_sell=prod_sell*1.01
where prod_sell<aver;
DBMS_OUTPUT.PUT_LINE ('Number of updates:  ' || SQL%ROWCOUNT  );
end if;

EXCEPTION 
WHEN NO_DATA_FOUND THEN
DBMS_OUTPUT.PUT_LINE('No data');   
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('errors');     

END update_low_prices_163291180;


BEGIN
update_low_prices_163291180;  
end;
rollback;


-- Question 5 – Write a procedure named price_report_. needs a report that shows three categories of products based their prices. 
-- Q5 SOLUTION –
CREATE OR REPLACE PROCEDURE  price_report_163291180 
as min_price number;
    max_price number;
    avg_price number;
    low_count number;
    high_count number;
    fair_count number;
   
BEGIN
select min(prod_sell), max(prod_sell),avg(prod_sell) into min_price, max_price, avg_price from products;
select count(prod_sell) into low_count from products where prod_sell <(avg_price-min_price)/2;
select count(prod_sell) into high_count from products where prod_sell >(max_price-avg_price)/2;
select count(prod_sell) into fair_count from products 
    where (prod_sell >=(avg_price-min_price)/2) and (prod_sell <=(max_price-avg_price)/2);
dbms_output.put_line('Low:  ' ||low_count);
dbms_output.put_line('Fair: ' ||fair_count);
dbms_output.put_line('High: ' ||high_count);

END price_report_163291180;

BEGIN
price_report_163291180;  
end;

rollback;