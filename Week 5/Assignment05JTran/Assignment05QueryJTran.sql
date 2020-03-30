--*************************************************************************--
-- Title: Assignment05
-- Author: Justin Tran
-- Desc: This file demonstrates how to process data in a database
-- Change Log: When,Who,What
-- 2020-02-07,Justin Tran,Created File
--**************************************************************************--
-- Step 1: Create the assignment database
Use Master;
go

If Exists(Select Name from SysDatabases Where Name = 'Assignment05DB_JustinTran')
 Begin
  Alter Database [Assignment05DB_JustinTran] set Single_user With Rollback Immediate;
  Drop Database Assignment05DB_JustinTran;
 End
go

Create Database Assignment05DB_JustinTran;
go

Use Assignment05DB_JustinTran;
go

-- Create Tables (Module 01)--
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL
,[ProductName] [nvarchar](100) NOT NULL
,[CategoryID] [int] NULL
,[UnitPrice] [money] NOT NULL
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) --
Alter Table Categories
 Add Constraint pkCategories
  Primary Key (CategoryId);
go

Alter Table Categories
 Add Constraint ukCategories
  Unique (CategoryName);
go

Alter Table Products
 Add Constraint pkProducts
  Primary Key (ProductId);
go

Alter Table Products
 Add Constraint ukProducts
  Unique (ProductName);
go

Alter Table Products
 Add Constraint fkProductsToCategories
  Foreign Key (CategoryId) References Categories(CategoryId);
go

Alter Table Products
 Add Constraint ckProductUnitPriceZeroOrHigher
  Check (UnitPrice >= 0);
go

Alter Table Inventories
 Add Constraint pkInventories
  Primary Key (InventoryId);
go

Alter Table Inventories
 Add Constraint dfInventoryDate
  Default GetDate() For InventoryDate;
go

Alter Table Inventories
 Add Constraint fkInventoriesToProducts
  Foreign Key (ProductId) References Products(ProductId);
go

Alter Table Inventories
 Add Constraint ckInventoryCountZeroOrHigher
  Check ([Count] >= 0);
go

-- Show the Current data in the Categories, Products, and Inventories Tables
/*
Select * from Categories;
go
Select * from Products;
go
Select * from Inventories;
go
*/

-- Step 2: Add some starter data to the database

/* Add the following data to this database using inserts:
Category	Product	Price	Date		Count
Beverages	Chai	18.00	2017-01-01	61
Beverages	Chang	19.00	2017-01-01	17

Beverages	Chai	18.00	2017-02-01	13
Beverages	Chang	19.00	2017-02-01	12

Beverages	Chai	18.00	2017-03-02	18
Beverages	Chang	19.00	2017-03-02	12
*/

Begin Transaction
 Insert Into Categories
 (CategoryName)
 Values
 ('Beverages')
Commit Transaction
go
Select * from Categories;
go

Begin Transaction
 Insert Into Products
 (ProductName, CategoryID, UnitPrice)
 Values
    ('Chai', 1, 18.00),
    ('Chang', 1, 19.00)
Commit Transaction
go
Select * from Products;
go

Begin Transaction
 Insert Into Inventories
 (InventoryDate, ProductID, Count)
 Values
    ('20170101', 1, 61),
    ('20170101', 2, 17),
    ('20170102', 1, 13),
    ('20170102', 2, 12),
    ('20170103', 1, 18),
    ('20170103', 2, 12)
Commit Transaction
go
Select * from Inventories;
go

-- Step 3: Create transactional stored procedures for each table using the proviced template:

Create Procedure pInsCategories
(@CategoryName NVarchar(100))
/* Author: <Justin Tran>
** Desc: Processes insertion of category data
** Change Log: When,Who,What
** <2020-02-07>,<Justin Tran>,Created stored procedure.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction
    -- Transaction Code --
     Insert Into Categories(CategoryName)
     Values (@CategoryName)
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   If(@@Trancount > 0) Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

Create Procedure pUpdCategories
(@CategoryName NVarchar(100))
/* Author: <Justin Tran>
** Desc: Processes updating of categories
** Change Log: When,Who,What
** <2020-02-07>,<Justin Tran>,Created stored procedure.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction
    -- Transaction Code --
     Update Categories
     Set CategoryName =  @CategoryName
     Where CategoryID = IDENT_CURRENT('Categories')
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   If(@@Trancount > 0) Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

Create Procedure pDelCategories
(@CategoryID int)
/* Author: <Justin Tran>
** Desc: Processes deletion of categories
** Change Log: When,Who,What
** <2020-02-07>,<Justin Tran>,Created stored procedure.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction
    -- Transaction Code --
     Delete From Categories
     Where CategoryID = @CategoryID
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   If(@@Trancount > 0) Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

Create Procedure pInsProducts
(@ProductName NVarchar(100),
@UnitPrice money)
/* Author: <Justin Tran>
** Desc: Processes insertion of products data
** Change Log: When,Who,What
** <2020-02-07>,<Justin Tran>,Created stored procedure.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction
    -- Transaction Code --
     Insert Into Products(ProductName, CategoryID, UnitPrice)
     Values (@ProductName, IDENT_CURRENT('Categories'), @UnitPrice)
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   If(@@Trancount > 0) Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

Create Procedure pUpdProducts
(@ProductName NVarchar(100),
@UnitPrice money)
/* Author: <Justin Tran>
** Desc: Processes updating of products
** Change Log: When,Who,What
** <2020-02-07>,<Justin Tran>,Created stored procedure.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction
    -- Transaction Code --
     Update Products
     Set ProductName =  @ProductName,
     UnitPrice = @UnitPrice,
     CategoryID = IDENT_CURRENT('Categories')
     Where ProductID = IDENT_CURRENT('Products')
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   If(@@Trancount > 0) Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

Create Procedure pDelProducts
/* Author: <Justin Tran>
** Desc: Processes deletion of products
** Change Log: When,Who,What
** <2020-02-07>,<Justin Tran>,Created stored procedure.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction
    -- Transaction Code --
     Delete From Products
     Where ProductID = IDENT_CURRENT('Products')
     Delete From Categories
     Where CategoryID = IDENT_CURRENT('Categories')
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   If(@@Trancount > 0) Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

Create Procedure pInsInventories
(@InventoryDate date,
@Count int)
/* Author: <Justin Tran>
** Desc: Processes insertion of inventories data
** Change Log: When,Who,What
** <2020-02-07>,<Justin Tran>,Created stored procedure.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction
    -- Transaction Code --
     Insert Into Inventories(InventoryDate, ProductID, Count)
     Values (@InventoryDate, IDENT_CURRENT('Products'), @Count)
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   If(@@Trancount > 0) Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

Create Procedure pUpdInventories
(@InventoryDate date,
@Count int)
/* Author: <Justin Tran>
** Desc: Processes update of inventories
** Change Log: When,Who,What
** <2020-02-07>,<Justin Tran>,Created stored procedure.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction
    -- Transaction Code --
     Update Inventories
     Set InventoryDate =  @InventoryDate,
     Count = @Count,
     ProductID = IDENT_CURRENT('Products')
     Where InventoryID = IDENT_CURRENT('Inventories')
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   If(@@Trancount > 0) Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

Create Procedure pDelInventories
/* Author: <Justin Tran>
** Desc: Processes deletion of inventories
** Change Log: When,Who,What
** <2020-02-07>,<Justin Tran>,Created stored procedure.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction
    -- Transaction Code --
     Delete From Inventories
     Where InventoryID = IDENT_CURRENT('Inventories')
     Delete From Products
     Where ProductID = IDENT_CURRENT('Products')
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   If(@@Trancount > 0) Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go
-- Step 4: Create code to test each transactional stored procedure.
-- I run them individually to see if they work. Products depends on categories and inventories depends on products
/* Testing Code:
 Declare @Status int;
 Exec @Status = pInsCategories @CategoryName = 'Test';
 Select Case @Status
  When +1 Then 'Insert was successful!'
  When -1 Then 'Insert failed!'
  End as [Status]
Select * from Categories;
go

 Declare @Status int;
 Exec @Status = pUpdCategories @CategoryName = 'TestA'
 Select Case @Status
  When +1 Then 'Update was successful!'
  When -1 Then 'Update failed! Check your categories.'
  End as [Status]
Select * from Categories;
go

 Declare @Status int;
 Exec @Status = pDelCategories @CategoryID = @@Identity
 Select Case @Status
  When +1 Then 'Deletion was successful!'
  When -1 Then 'Deletion failed!'
  End as [Status]
Select * from Categories;
go

 Declare @Status int;
 Exec @Status = pInsProducts @ProductName = 'Test1', @UnitPrice = 42.00;
 Select Case @Status
  When +1 Then 'Insert was successful!'
  When -1 Then 'Insert failed! Check your categories if one exists.'
  End as [Status]
Select * from Products;
go

 Declare @Status int;
 Exec @Status = pUpdProducts @ProductName = 'Test1-2', @UnitPrice = 7.00;
 Select Case @Status
  When +1 Then 'Update was successful!'
  When -1 Then 'Update failed! Check your categories.'
  End as [Status]
Select * from Products;
go

 Declare @Status int;
 Exec @Status = pDelProducts
 Select Case @Status
  When +1 Then 'Deletion was successful!'
  When -1 Then 'Deletion failed!'
  End as [Status]
Select * from Products;
go

 Declare @Status int;
 Exec @Status = pInsInventories @InventoryDate = '20200210', @Count = 6;
 Select Case @Status
  When +1 Then 'Insert was successful!'
  When -1 Then 'Insert failed! Check if there is a product.'
  End as [Status]
Select * from Inventories;
go

 Declare @Status int;
 Exec @Status = pUpdInventories @InventoryDate = '20200314', @Count = 24;
 Select Case @Status
  When +1 Then 'Update was successful!'
  When -1 Then 'Update failed! Check your products'
  End as [Status]
Select * from Inventories;
go

 Declare @Status int;
 Exec @Status = pDelInventories
 Select Case @Status
  When +1 Then 'Deletion was successful!'
  When -1 Then 'Deletion failed!'
  End as [Status]
Select * from Inventories;
go
*/

/*
Select * from Categories;
go
Select * from Products;
go
Select * from Inventories;
go
*/ --Use these to see how tables look after running stored procedures (inserts and updates and deletes)
