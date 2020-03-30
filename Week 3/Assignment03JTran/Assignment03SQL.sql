--*************************************************************************--
-- Title: Assignment03
-- Author: Justin Tran
-- Desc: This file demonstrates how to select data from a database
-- Change Log: When,Who,What
-- 2020-01-24, Justin Tran,Created File
--**************************************************************************--

Use Northwind

/********************************* Questions and Answers *********************************/
-- Data Request: 0301
-- Date: 1/1/2020
-- From: Jane Encharge CEO
-- Request: I want a list of customer companies and their contact people
-- Needed By: ASAP

-- SELECT * FROM Northwind.dbo.Customers;
-- To see the column names in Customers table and choose what is appropriate
SELECT CompanyName, ContactName
FROM Northwind.dbo.Customers;

-- Data Request: 0302
-- Date: 1/2/2020
-- From: Jane Encharge CEO
-- Request: I want a list of customer companies and their contact people, but only the ones in US and Canada
-- Needed By: ASAP

SELECT CompanyName, ContactName, Country --Added Country
FROM Northwind.dbo.Customers
WHERE Country = 'USA'
    OR Country = 'Canada'
ORDER BY COUNTRY ASC, CompanyName ASC;
-- Copied code from previous question, added WHERE query and ORDER BY
-- ORDER BY added to match the screenshot in assignment specification

-- Data Request: 0303
-- Date: 1/2/2020
-- From: Jane Encharge CEO
-- Request: I want a list of products, their standard price and their categories. Order the results by Category Name
-- and then Product Name, in alphabetical order
-- Needed By: ASAP

-- SELECT * FROM Northwind.dbo.Products;
-- To see the column names in Products table and choose what is appropriate

-- SELECT * FROM Northwind.dbo.Categories;
-- To see the column names in Categories table and choose what is appropriate
-- They both share CategoryID, so I should join those two
SELECT  CategoryName, ProductName, UnitPrice as 'Standard Price'
 FROM Northwind.dbo.Products as P JOIN Northwind.dbo.Categories as C -- Simpler names
  ON P.CategoryId = C.CategoryId --The match for both tables, join them by this
ORDER BY CategoryName ASC, ProductName ASC; -- Starts at 'A' and goes up the alphabet

-- Data Request: 0304
-- Date: 1/3/2020
-- From: Jane Encharge CEO
-- Request: I want a list of how many customers we have in the US
-- Needed By: ASAP

-- SELECT * FROM Northwind.dbo.Customers;
-- Back to Customers, look over table
SELECT Count(*) as Count, Country --As Count added to name the column
FROM Northwind.dbo.Customers
WHERE Country = 'USA'
Group By Country; -- Group By clause contains the Country and stops the invalid error without it

-- Data Request: 0305
-- Date: 1/4/2020
-- From: Jane Encharge CEO
-- Request: I want a list of how many customers we have in the US and Canada, with subtotals for each
-- Needed By: ASAP

SELECT Count(*) as Count, Country --As Count added to name the column
FROM Northwind.dbo.Customers
WHERE Country = 'USA'
    OR Country = 'Canada'
Group By Country;
-- Copied the SQL query from previous question, but this time added the 'Canada' option
-- To the WHERE clause
/***************************************************************************************/
