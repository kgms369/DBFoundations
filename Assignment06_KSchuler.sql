--*************************************************************************--
-- Title: Assignment06
-- Author: KSchuler
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2026-02-21,KSchuler,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_KSchuler')
	 Begin 
	  Alter Database [Assignment06DB_KSchuler] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_KSchuler;
	 End
	Create Database Assignment06DB_KSchuler;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_KSchuler;

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
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

GO -- required at the start to make sure CREATE VIEW is first
CREATE VIEW vCategories -- a view for Categories
WITH SCHEMABINDING
AS
  SELECT CategoryID
  , CategoryName 
  FROM dbo.Categories
;
GO

GO
CREATE VIEW vProducts -- a view for Products
WITH SCHEMABINDING
AS
  SELECT ProductID
  , ProductName
  , CategoryID
  , UnitPrice 
  FROM dbo.Products
;
GO

GO
CREATE VIEW vEmployees -- a view for Employees
WITH SCHEMABINDING
AS
  SELECT EmployeeID
  , EmployeeFirstName
  , EmployeeLastName
  , ManagerID 
  FROM dbo.Employees
;
GO

GO
CREATE VIEW vInventories -- a view for Inventories
WITH SCHEMABINDING
AS
  SELECT InventoryID
  , InventoryDate
  , EmployeeID
  , ProductID
  , [Count]
  FROM dbo.Inventories
;
GO

-- the Views
SELECT * FROM dbo.vCategories;
SELECT * FROM dbo.vProducts;
SELECT * FROM dbo.vEmployees;
SELECT * FROM dbo.vInventories;


-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

-- Ensure users can only interact with the data using the views

DENY SELECT ON Categories TO public; -- deny public access to the tables so they can't be changed
DENY SELECT ON Products TO public;
DENY SELECT ON Employees TO public;
DENY SELECT ON Inventories TO public;
GO

GRANT SELECT ON vCategories TO public; -- grant access to the views
GRANT SELECT ON vProducts TO public;
GRANT SELECT ON vEmployees TO public;
GRANT SELECT ON vInventories TO public;
GO


-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

-- Note from above - 3) You must use the BASIC views for each table after they are created in Question 1
-- Create a joined view

GO
CREATE VIEW vProductsByCategories
AS
  SELECT C.CategoryName
  , P.ProductName
  , P.UnitPrice
  FROM dbo.vCategories AS C -- using the basic views
  INNER JOIN dbo.vProducts AS P -- an inner join to see items that match from both tables
  ON C.CategoryID = P.CategoryID
;
GO

-- the View
SELECT * FROM dbo.vProductsByCategories ORDER BY CategoryName, ProductName;


-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

GO
CREATE VIEW vInventoriesByProductsByDates
AS
  SELECT P.ProductName
  , I.InventoryDate
  , I.[Count]
  FROM dbo.vProducts AS P
  INNER JOIN dbo.vInventories AS I 
    ON P.ProductID = I.ProductID
;
GO

-- the View
SELECT * FROM dbo.vInventoriesByProductsByDates ORDER BY ProductName, InventoryDate, [Count];


-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

GO
CREATE VIEW vInventoriesByEmployeesByDates
AS
  SELECT DISTINCT I.InventoryDate -- results in one row per date
  , E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName -- combines fields for first and last name
  FROM dbo.vInventories AS I
  INNER JOIN dbo.vEmployees AS E 
  ON I.EmployeeID = E.EmployeeID
;
GO

-- the View
SELECT * FROM dbo.vInventoriesByEmployeesByDates ORDER BY InventoryDate;


-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

-- Need to join Categories, Products, and then Inventory

GO
CREATE VIEW vInventoriesByProductsByCategories
AS
  SELECT C.CategoryName
    , P.ProductName
	, I.InventoryDate
	, I.[Count]
  FROM dbo.vCategories AS C
  INNER JOIN dbo.vProducts AS P 
  ON C.CategoryID = P.CategoryID
  INNER JOIN dbo.vInventories AS I 
  ON P.ProductID = I.ProductID
;
GO

-- the View
SELECT * FROM dbo.vInventoriesByProductsByCategories ORDER BY CategoryName, ProductName, InventoryDate, [Count];



-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

GO
CREATE VIEW vInventoriesByProductsByEmployees
AS
  SELECT C.CategoryName
    , P.ProductName
	, I.InventoryDate
	, I.[Count]
	, [EmployeeName] = E.EmployeeFirstName + ' ' + E.EmployeeLastName -- defines the alias so it can be used in the ORDER BY clause
  FROM dbo.vCategories AS C
  INNER JOIN dbo.vProducts AS P 
  ON C.CategoryID = P.CategoryID
  INNER JOIN dbo.vInventories AS I 
  ON P.ProductID = I.ProductID
  INNER JOIN dbo.vEmployees AS E
  ON I.EmployeeID = E.EmployeeID
;
GO

-- the View
SELECT * FROM dbo.vInventoriesByProductsByEmployees ORDER BY InventoryDate, CategoryName, ProductName, EmployeeName;



-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

-- Use the script in #7 and filter for Chai and Chang
-- Assuming same ORDER BY as in #7

GO
CREATE VIEW vInventoriesForChaiAndChangByEmployees
AS
  SELECT C.CategoryName
    , P.ProductName
	, I.InventoryDate
	, I.[Count]
	, [EmployeeName] = E.EmployeeFirstName + ' ' + E.EmployeeLastName -- defines the alias so it can be used in the ORDER BY clause
  FROM dbo.vCategories AS C
  INNER JOIN dbo.vProducts AS P 
  ON C.CategoryID = P.CategoryID
  INNER JOIN dbo.vInventories AS I 
  ON P.ProductID = I.ProductID
  INNER JOIN dbo.vEmployees AS E
  ON I.EmployeeID = E.EmployeeID
  WHERE P.ProductName IN ('Chai','Chang')
;
GO

-- the View
SELECT * FROM dbo.vInventoriesForChaiAndChangByEmployees ORDER BY InventoryDate, CategoryName, ProductName, EmployeeName;


-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

-- The employees and managers are in the same table, requires a self-join

GO
CREATE VIEW vEmployeesByManager
AS
  SELECT [Manager] = M.EmployeeFirstName + ' ' + M.EmployeeLastName -- defines the alias so it can be used in the ORDER BY clause
	,[Employee] = E.EmployeeFirstName + ' ' + E.EmployeeLastName -- defines the alias so it can be used in the ORDER BY clause
  FROM dbo.vEmployees AS E
  INNER JOIN dbo.vEmployees AS M -- staff without a manage (such as a CEO) won't appear in this list
  ON E.ManagerID = M.EmployeeID -- the self-join to get the manager name
;
GO

-- the View
SELECT * FROM dbo.vEmployeesByManager ORDER BY Manager, Employee; -- groups staff who report to the same manager



-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

GO
CREATE VIEW vInventoriesByProductsByCategoriesByEmployees
AS
  SELECT C.CategoryID -- all data from all four basic views
    , C.CategoryName
    , P.ProductID
    , P.ProductName
    , P.UnitPrice
    , I.InventoryID
    , I.InventoryDate
    , I.[Count]
    , E.EmployeeID
    , [EmployeeName] = E.EmployeeFirstName + ' ' + E.EmployeeLastName
    , [ManagerName] = M.EmployeeFirstName + ' ' + M.EmployeeLastName
  FROM dbo.vCategories AS C
  INNER JOIN dbo.vProducts AS P -- products in each category
  ON C.CategoryID = P.CategoryID
  INNER JOIN dbo.vInventories AS I -- items to stock levels
  ON P.ProductID = I.ProductID
  INNER JOIN dbo.vEmployees AS E -- employee who performed the inventory
  ON I.EmployeeID = E.EmployeeID
  INNER JOIN dbo.vEmployees AS M -- manager of each employee
  ON E.ManagerID = M.EmployeeID  -- the self-join to get the manager name
;
GO

-- the View
SELECT * FROM dbo.vInventoriesByProductsByCategoriesByEmployees ORDER BY CategoryName, ProductName, InventoryID, EmployeeName;


-- Test your Views (NOTE: You must change the your view names to match what I have below!)

SELECT * FROM dbo.vCategories;
SELECT * FROM dbo.vProducts;
SELECT * FROM dbo.vEmployees;
SELECT * FROM dbo.vInventories;

SELECT * FROM dbo.vProductsByCategories ORDER BY CategoryName, ProductName; --#3
SELECT * FROM dbo.vInventoriesByProductsByDates ORDER BY ProductName, InventoryDate, [Count]; --#4
SELECT * FROM dbo.vInventoriesByEmployeesByDates ORDER BY InventoryDate; --#5
SELECT * FROM dbo.vInventoriesByProductsByCategories ORDER BY CategoryName, ProductName, InventoryDate, [Count]; --#6
SELECT * FROM dbo.vInventoriesByProductsByEmployees ORDER BY InventoryDate, CategoryName, ProductName, EmployeeName; --#7
SELECT * FROM dbo.vInventoriesForChaiAndChangByEmployees ORDER BY InventoryDate, CategoryName, ProductName, EmployeeName; --#8
SELECT * FROM dbo.vEmployeesByManager ORDER BY Manager, Employee; --#9
SELECT * FROM dbo.vInventoriesByProductsByCategoriesByEmployees ORDER BY CategoryName, ProductName, InventoryID, EmployeeName; --#10


--Print 'Note: You will get an error until the views are created!'
--Select * From [dbo].[vCategories]
--Select * From [dbo].[vProducts]
--Select * From [dbo].[vInventories]
--Select * From [dbo].[vEmployees]

--Select * From [dbo].[vProductsByCategories]
--Select * From [dbo].[vInventoriesByProductsByDates]
--Select * From [dbo].[vInventoriesByEmployeesByDates]
--Select * From [dbo].[vInventoriesByProductsByCategories]
--Select * From [dbo].[vInventoriesByProductsByEmployees] 
--Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
--Select * From [dbo].[vEmployeesByManager]
--Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/