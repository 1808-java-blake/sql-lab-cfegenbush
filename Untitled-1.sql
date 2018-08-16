-- Part I – Working with an existing database

-- 1.0	Setting up Oracle Chinook
-- In this section you will begin the process of working with the Oracle Chinook database
-- Task – Open the Chinook_Oracle.sql file and execute the scripts within.
-- 2.0 SQL Queries
-- In this section you will be performing various queries against the Oracle Chinook database.
-- 2.1 SELECT
-- Task – Select all records from the Employee table.
SELECT * FROM "Employee";
-- Task – Select all records from the Employee table where last name is King.
SELECT * FROM "Employee"
WHERE "LastName" = 'King';
-- Task – Select all records from the Employee table where first name is Andrew and REPORTSTO is NULL.
SELECT * FROM "Employee"
WHERE "FirstName" = 'Andrew'
AND "ReportsTo" is null;
-- 2.2 ORDER BY
-- Task – Select all albums in Album table and sort result set in descending order by title.
SELECT * FROM "Album"
ORDER BY "Title" DESC;
-- Task – Select first name from Customer and sort result set in ascending order by city
SELECT "FirstName" FROM "Customer"
ORDER BY "City" ASC;
-- 2.3 INSERT INTO
-- Task – Insert two new records into Genre table
INSERT INTO "Genre" ("GenreId", "Name") VALUES (26,'Rap'), (27,'EDM');
-- Task – Insert two new records into Employee table
INSERT INTO "Employee" ("EmployeeId","LastName","FirstName","Title","ReportsTo","BirthDate","HireDate","Address","City","State","Country","PostalCode","Phone","Fax","Email")
VALUES ('9','Buck','John','Custodian',1,'1972-01-01 00:00:00','2010-01-01 00:00:00','123 Number Ln','Calgary','AB','Canada','T1K 5N8','+1 (403)456-9897','+1 (403)456-9997','john@chinookcorp.com'),
('10','Doe','Jane','Custodian',1,'1971-01-02 00:00:00','2010-01-01 00:00:00','456 Number Rd','Calgary','AB','Canada','T1K 5N8','+1 (403)456-9898','+1 (403)456-9867','janeD@chinookcorp.com');
-- Task – Insert two new records into Customer table
INSERT INTO "Customer" ("CustomerId","FirstName","LastName","Company","Address","City","State","Country","PostalCode","Phone","Fax","Email","SupportRepId")
VALUES ('60','Frodo','Baggins','Hobbit Hole Solutions','82 Baggins Rd','Bag End','Shire','Middle Earth','1',null,null,'NeoWho@gmail.com',4),
('61','Aragorn','Sonofarathorn','King','1 Minus Tirith Ln','Minus Tirith','Gondor','Middle Earth','1',null,null,'Eowyn@gmail.com',5);
-- 2.4 UPDATE
-- Task – Update Aaron Mitchell in Customer table to Robert Walter
UPDATE "Customer" SET "FirstName" = 'Robert', "LastName" = 'Walter' 
WHERE "FirstName" = 'Robert' AND "LastName" = 'Mitchell';
-- Task – Update name of artist in the Artist table “Creedence Clearwater Revival” to “CCR”
UPDATE "Artist" SET "Name" = 'CCR' 
WHERE "Name" = 'Creedence Clearwater Revival';
-- 2.5 LIKE
-- Task – Select all invoices with a billing address like “T%”
SELECT * FROM "Invoice"
WHERE "BillingAddress" LIKE 'T%';
-- 2.6 BETWEEN
-- Task – Select all invoices that have a total between 15 and 50
SELECT * FROM "Invoice"
WHERE "Total" BETWEEN 15 AND 50;
-- Task – Select all employees hired between 1st of June 2003 and 1st of March 2004
SELECT * FROM "Employee"
WHERE "HireDate" BETWEEN '2003-06-01' AND '2004-03-01';
-- 2.7 DELETE
-- Task – Delete a record in Customer table where the name is Robert Walter (There may be constraints that rely on this, find out how to resolve them).
DELETE FROM "InvoiceLine" WHERE "InvoiceId" = 342;
DELETE FROM "InvoiceLine" WHERE "InvoiceId" = 290;
DELETE FROM "InvoiceLine" WHERE "InvoiceId" = 268;
DELETE FROM "InvoiceLine" WHERE "InvoiceId" = 245;
DELETE FROM "InvoiceLine" WHERE "InvoiceId" = 116;
DELETE FROM "InvoiceLine" WHERE "InvoiceId" = 61;
DELETE FROM "InvoiceLine" WHERE "InvoiceId" = 50;
DELETE FROM "Invoice" WHERE "CustomerId" = 32;
DELETE FROM "Customer" 
WHERE "FirstName" = 'Robert'
AND "LastName" = 'Walter';
-- Robert Walter updated to Aaron Mitchell in 2.4^

-- 3.0	SQL Functions
-- In this section you will be using the Oracle system functions, as well as your own functions, to perform various actions against the database
-- 3.1 System Defined Functions
-- Task – Create a function that returns the current time.
SELECT CURRENT_TIME;
-- Task – create a function that returns the length of a mediatype from the mediatype table
SELECT LENGTH("Name") FROM "MediaType";
-- 3.2 System Defined Aggregate Functions
-- Task – Create a function that returns the average total of all invoices
SELECT CAST(AVG("Total") AS DECIMAL(10,2)) FROM "Invoice";
-- Task – Create a function that returns the most expensive track
SELECT MAX("UnitPrice") FROM "Track";
-- 3.3 User Defined Scalar Functions
-- Task – Create a function that returns the average price of invoiceline items in the invoiceline table
SELECT CAST(AVG("UnitPrice") AS DECIMAL(10,2)) FROM "InvoiceLine";
-- 3.4 User Defined Table Valued Functions
-- Task – Create a function that returns all employees who are born after 1968.
SELECT * FROM "Employee"
WHERE "BirthDate" > '1968-01-01 00:00:00';
-- 4.0 Stored Procedures
--  In this section you will be creating and executing stored procedures. You will be creating various types of stored procedures that take input and output parameters.
-- 4.1 Basic Stored Procedure
-- Task – Create a stored procedure that selects the first and last names of all the employees.
CREATE OR REPLACE FUNCTION show_all_names(ref refcursor) RETURNS refcursor AS $$
BEGIN
	OPEN ref FOR SELECT "FirstName","LastName" FROM "Employee";
	RETURN ref;
END;
$$ LANGUAGE plpgsql;

BEGIN;
SELECT show_all_names('names_cur');
FETCH ALL IN "names_cur";
-- 4.2 Stored Procedure Input Parameters
-- Task – Create a stored procedure that updates the personal information of an employee.
CREATE OR REPLACE FUNCTION update_info(ref refcursor, address VARCHAR, employeeid int) RETURNS refcursor AS $$
BEGIN
	UPDATE "Employee" SET "Address" = address
	WHERE "EmployeeId" = employeeid;
	OPEN ref FOR SELECT * FROM "Employee" WHERE "EmployeeId" = employeeid;
	RETURN ref;
END;
$$ LANGUAGE plpgsql;

BEGIN;
SELECT update_info('update', '321 jlkdf st', 10);
FETCH ALL IN "update";
-- Task – Create a stored procedure that returns the managers of an employee.
CREATE OR REPLACE FUNCTION get_manager(ref refcursor, employeeid int) RETURNS refcursor AS $$
BEGIN
	OPEN ref FOR SELECT * FROM "Employee" 
	WHERE "EmployeeId" = (SELECT "ReportsTo" FROM "Employee" WHERE "EmployeeId" = employeeid);
	RETURN ref;
END;
$$ LANGUAGE plpgsql;

BEGIN;
SELECT get_manager('manager', 3);
FETCH ALL IN "manager";
-- 4.3 Stored Procedure Output Parameters
-- Task – Create a stored procedure that returns the name and company of a customer.
CREATE OR REPLACE FUNCTION get_cust_name_company(IN custid int, OUT firstname VARCHAR,
												OUT lastname VARCHAR, OUT company VARCHAR) RETURNS record AS $$
BEGIN
	SELECT "FirstName", "LastName","Company"
	INTO firstname, lastname, company
	FROM "Customer" 
	WHERE "CustomerId" = custid; 
	RETURN;
END;
$$ LANGUAGE plpgsql;

BEGIN;
SELECT get_cust_name_company(10);
-- 5.0 Transactions
-- In this section you will be working with transactions. Transactions are usually nested within a stored procedure. You will also be working with handling errors in your SQL.
-- Task – Create a transaction that given a invoiceId will delete that invoice (There may be constraints that rely on this, find out how to resolve them).
BEGIN;
	DELETE FROM "InvoiceLine" WHERE "InvoiceId" = 54;
	DELETE FROM "Invoice" WHERE "InvoiceId" = 54;
END;
-- Task – Create a transaction nested within a stored procedure that inserts a new record in the Customer table
CREATE OR REPLACE FUNCTION add_customer(ref refcursor, custid int, firstname VARCHAR, lastname VARCHAR,
									   company VARCHAR, address VARCHAR, city VARCHAR, state VARCHAR,
									   country VARCHAR, postal VARCHAR, phone VARCHAR, fax VARCHAR,
									   email VARCHAR, suppid int) RETURNS refcursor AS $$
BEGIN
	INSERT INTO "Customer" ("CustomerId","FirstName","LastName","Company","Address","City","State",
						   "Country","PostalCode","Phone","Fax","Email","SupportRepId") 
						   VALUES (custid,firstname,lastname,company,address,city,state,
								  country,postal,phone,fax,email,suppid);
	OPEN ref FOR SELECT * FROM "Customer" 
	WHERE "CustomerId" = custid;
	RETURN ref;
END;
$$ LANGUAGE plpgsql;

BEGIN;
SELECT add_customer('customer',62,'joewjn','sfhoh','wfhoe','wofeij','wofi','wofihe','woiehf','weh','wueifh','hfui',
				   'soif',4);
FETCH ALL IN "customer";

-- 6.0 Triggers
-- In this section you will create various kinds of triggers that work when certain DML statements are executed on a table.
-- 6.1 AFTER/FOR
-- Task - Create an after insert trigger on the employee table fired after a new record is inserted into the table.
-- Task – Create an after update trigger on the album table that fires after a row is inserted in the table
-- Task – Create an after delete trigger on the customer table that fires after a row is deleted from the table.

-- 6.2 INSTEAD OF
-- Task – Create an instead of trigger that restricts the deletion of any invoice that is priced over 50 dollars.
-- 7.0 JOINS
-- In this section you will be working with combing various tables through the use of joins. You will work with outer, inner, right, left, cross, and self joins.
-- 7.1 INNER
-- Task – Create an inner join that joins customers and orders and specifies the name of the customer and the invoiceId.

-- 7.2 OUTER
-- Task – Create an outer join that joins the customer and invoice table, specifying the CustomerId, firstname, lastname, invoiceId, and total.
-- 7.3 RIGHT
-- Task – Create a right join that joins album and artist specifying artist name and title.
-- 7.4 CROSS
-- Task – Create a cross join that joins album and artist and sorts by artist name in ascending order.
-- 7.5 SELF
-- Task – Perform a self-join on the employee table, joining on the reportsto column.








