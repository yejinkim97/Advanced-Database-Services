-- ***********************
-- Name: Ye Jin Kim 
-- ID: 163291180
-- Date: 18/11/2020
-- Purpose: Lab 6 DBS311
-- ***********************
SET SERVEROUTPUT ON

-- Question 1 – Calculates the salary based on the number of years the employee has been working in the company
-- Q1 SOLUTION –

CREATE OR REPLACE PROCEDURE  calculate_salary  (emp_num in number)
as
    fname VARCHAR2(20 BYTE);
    lname VARCHAR2(25 BYTE);
    sal number :=10000;
    hire number;
    counter number :=0;
BEGIN
select first_name, last_name, Trunc(To_char(SYSDATE - hire_date) / 365) 
    into fname, lname,  hire
from employees
where emp_num=employee_id;

LOOP
sal:=sal*1.05;
counter := counter+1;
EXIT WHEN counter=hire;
END LOOP;

DBMS_OUTPUT.PUT_LINE ('First name: ' || fname);
DBMS_OUTPUT.PUT_LINE ('Last name: ' || lname);
DBMS_OUTPUT.PUT_LINE ('Salary: $' || sal);

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
END calculate_salary;

BEGIN
calculate_salary(&input);  
END;

-- Question 2 – Print the employee_id, employee Last name and department name. If the value of the department name is null or does not exist, display “no department”.
-- Q2 Solution –

CREATE OR REPLACE PROCEDURE  employee_works_here 
as
    empid NUMBER;
    lname VARCHAR2(25 BYTE);
    depName VARCHAR2(30 BYTE);
    counter number :=17;
BEGIN

DBMS_OUTPUT.PUT_LINE ('Employee #		Last Name		Department Name');

FOR counter in 17..105 LOOP
select employee_id, last_name, nvl(d.department_name, 'no department')
    into empid, lname, depName
from employees e left join departments d
on e.department_id=d.department_id
where e.employee_id=counter;
DBMS_OUTPUT.PUT_LINE(empid || '		' || lname || '		' || depName );

END LOOP;

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
END employee_works_here ;


BEGIN
employee_works_here();  
END;
