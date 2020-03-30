--**********************************************************************************************--
-- Title: Assigment06 - Midterm
-- Author: YourNameHere
-- Desc: This file demonstrates how to design and create; 
--       tables, constraints, views, stored procedures, and permissions
-- Change Log: When,Who,What
-- 2017-01-01,YourNameHere,Created File
--***********************************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_YourNameHere')
	 Begin 
	  Alter Database [Assignment06DB_YourNameHere] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_YourNameHere;
	 End
	Create Database Assignment06DB_YourNameHere;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_YourNameHere;

-- Create Tables (Module 01)-- 
-- Add Constraints (Module 02) -- 
-- Add Views (Module 03 and 04) -- 
-- Add Stored Procedures (Module 04 and 05) --
-- Set Permissions (Module 06) --
--< Test Views and Sprocs >-- 
--{ IMPORTANT }--
-- To get full credit, your script must run without having to highlight individual statements!!!  
/**************************************************************************************************/