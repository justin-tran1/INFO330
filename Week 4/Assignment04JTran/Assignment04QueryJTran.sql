--*************************************************************************--
-- Title: Assignment04
-- Author: Justin Tran
-- Desc: This file demonstrates how to process data in a database
-- Change Log: When,Who,What
-- 2020-01-30,Justin Tran,Created File
--**************************************************************************--
Use Master;
go

If Exists(Select Name from SysDatabases Where Name = 'Assignment04DB_JTran')
 Begin
  Alter Database [Assignment04DB_JTran] set Single_user With Rollback Immediate;
  Drop Database Assignment04DB_JTran;
 End
go

Create Database Assignment04DB_JTran;
go

Use Assignment04DB_JTran;
go --Provided code by Module

-- Add Your Code Below ---------------------------------------------------------------------

-- Data Request: 0301
-- Request: I want a list of customer companies and their contact people
/*
  -- Columns
  c.CompanyName
  c.ContactName

  -- Tables
  Northwind.dbo.Customers
*/

CREATE VIEW vCustomerContacts AS
  SELECT c.CompanyName, c.ContactName
    FROM Northwind.dbo.Customers as c;
go

Select * from vCustomerContacts;

-- Data Request: 0302
-- Request: I want a list of customer companies and their contact people, but only the ones in US and Canada
/*
  -- Columns
  c.CompanyName
  c.ContactName
  c.Country

  -- Tables
  Northwind.dbo.Customers
*/
go
CREATE VIEW vUSAandCanadaCustomerContacts AS
  SELECT TOP 100000 c.CompanyName, c.ContactName, c.Country
    FROM Northwind.dbo.Customers as c
      WHERE c.Country = 'USA'
        OR c.Country = 'Canada'
ORDER BY Country ASC, CompanyName ASC --This order results by Canada first and alphabetical company name
go

Select * from vUSAandCanadaCustomerContacts;

-- Data Request: 0303
-- Request: I want a list of products, their standard price and their categories.
-- Order the results by Category Name and then Product Name, in alphabetical order.
/*
  -- Columns
  c.CategoryName
  p.ProductName
  p.UnitPrice

  -- Tables
  Northwind.dbo.Products
  Northwind.dbo.Categories

  -- Connections
  ???
*/
go
CREATE VIEW vProductPricesByCategories AS
SELECT TOP 100000 CategoryName, ProductName, '$' + cast(UnitPrice as varchar(30)) as 'Standard Price' --This shows column result with $ sign
  FROM Northwind.dbo.Products as P JOIN Northwind.dbo.Categories as C -- Simpler names
    ON P.CategoryId = C.CategoryId --The match for both tables, join them by this
ORDER BY CategoryName ASC, ProductName ASC; -- Starts at 'A' and goes up the alphabet
go

Select * from vProductPricesByCategories;

-- Data Request: 0323
-- Request: I want a list of products, their standard price and their categories.
-- Order the results by Category Name and then Product Name, in alphabetical order but only for the seafood category
/*
  -- Columns
  c.CategoryName
  p.ProductName
  p.UnitPrice

  -- Tables
  Northwind.dbo.Products
  Northwind.dbo.Categories

  -- Connections
  ???
*/
go
CREATE FUNCTION fProductPricesByCategories(@CategoryName varchar(30))
RETURNS TABLE AS
    RETURN (
        SELECT TOP 100000 CategoryName, ProductName, '$' + cast(UnitPrice as varchar(30)) as 'Standard Price' --Get $ sign
            FROM Northwind.dbo.Products as P JOIN Northwind.dbo.Categories as C -- Simpler names
                ON P.CategoryId = C.CategoryId --The match for both tables, join them by this
                    WHERE CategoryName = @CategoryName --Uses the parameter given, in this case 'seafood'
                    ORDER BY CategoryName ASC, ProductName ASC
            )-- Starts at 'A' and goes up the alphabet

go

Select * from dbo.fProductPricesByCategories('seafood');

-- Data Request: 0317
-- Request: I want a list of how many orders our customers have placed each year
/*
  -- Columns
  c.CompanyName
  od.OrderID
  o.OrderDate

  -- Tables
  Northwind.dbo.Customers
  Northwind.dbo.Orders

  -- Connections
  ???

  -- Functions
  Year()
  Count()
*/
go
CREATE VIEW vCustomerOrderCounts AS
SELECT TOP 100000
CompanyName, 'NumberOfOrders' = Count(OrderID), 'Order Year' = YEAR(OrderDate) -- Uses function to get year
  FROM Northwind.dbo.Customers as C JOIN Northwind.dbo.Orders as O -- Simpler names
    ON C.CustomerId = O.CustomerId -- The match for both tables, join them by this
      GROUP BY CompanyName, YEAR(OrderDate) -- Groups by oldest year first and by company
        ORDER BY CompanyName ASC -- Orders by company name alphabetical
go

Select * from vCustomerOrderCounts

-- Data Request: 0318
-- Request: I want a list of total order dollars our customers have placed each year
/*
  -- Columns
  c.CompanyName
  od.OrderID
  od.Quantity
  od.UnitPrice
  o.OrderDate

  -- Tables
  Northwind.dbo.Customers
  Northwind.dbo.Orders
  Northwind.dbo.[Order Details]

  -- Connections
  ???

  -- Functions
  Year()
  Count()
  Sum()
  Format()
*/
go
CREATE VIEW vCustomerOrderDollars AS
SELECT TOP 100000
CompanyName,
'TotalDollars' = '$' + cast(SUM(UnitPrice * Quantity) as varchar(30)), -- Get $ sign
'Order Year' = YEAR(OrderDate) -- Get year
    FROM Northwind.dbo.Customers as C JOIN Northwind.dbo.Orders as O -- Simpler names
        ON C.CustomerId = O.CustomerId --The match for both tables, join them by this
    JOIN Northwind.dbo.[Order Details] as OD -- Double join
        ON O.OrderID = OD.OrderID
            GROUP BY CompanyName, YEAR(OrderDate) -- Groups by oldest year first and by company
            ORDER BY CompanyName ASC -- Orders by company name alphabetical
go

Select * from vCustomerOrderDollars;
