USE ChinookDW

-- Only for the first load
DELETE FROM Fact_Sales;
DELETE FROM Dim_Product;
DELETE FROM Dim_Customer;
DELETE FROM Dim_Employee;
DELETE FROM Dim_Sales_Info;
DELETE FROM Dim_Date;

-- 0
INSERT INTO Dim_Sales_Info (Invoice_Line_Id, Invoice_Id, Billing_Address, Billing_State, Billing_City, Billing_Country, Billing_Postal_Code)
  SELECT EmployeeID, [FirstName] + ' ' + [LastName], Title FROM ChinookStaging.dbo.Employee

-- 1
INSERT INTO Dim_Employee (EmployeeID, EmployeeName, EmployeeTitle)
  SELECT EmployeeID, [FirstName] + ' ' + [LastName], Title FROM NorthwindStaging.dbo.Employees

--2
INSERT INTO Dim_Customer(CustomerID, CompanyName, ContactName, ContactTitle,
CustomerCountry, CustomerRegion, CustomerCity, CustomerPostalCode)
    SELECT CustomerID, CompanyName, ContactName, ContactTitle,
    Country, ISNULL(Region,'N/A'), City, ISNULL(PostalCode,'')
        FROM NorthwindStaging.dbo.Customers

--3
INSERT INTO Dim_Product(ProductID, ProductName, Discontinued,
    SupplierName, CategoryName )
SELECT ProductID, ProductName, Discontinued, [CompanyName], CategoryName
        FROM NorthwindStaging.dbo.Products

--4
INSERT INTO Fact_Sales(
    ProductKey, CustomerKey, EmployeeKey, OrderDateKey, ShippedDateKey,
    OrderID, Quantity, ExtendedPriceAmount, DiscountAmount, SoldAmount)
SELECT ProductKey, CustomerKey, EmployeeKey,
    CAST(FORMAT(OrderDate,'yyyyMMdd') AS INT),
    CAST(FORMAT(ShippedDate,'yyyyMMdd') AS INT),
    OrderID, Quantity, [UnitPrice]*[Quantity], ([UnitPrice]*[Discount])*[Quantity],
	([UnitPrice]*(1-[Discount]))*[Quantity]
        FROM NorthwindStaging.dbo.Sales
INNER JOIN NorthwindDW.dbo.DimCustomer
    ON NorthwindDW.dbo.DimCustomer.CustomerID=NorthwindStaging.dbo.Sales.CustomerId
INNER JOIN NorthwindDW.dbo.DimEmployee
    ON NorthwindDW.dbo.DimEmployee.EmployeeID=NorthwindStaging.dbo.Sales.EmployeeId
INNER JOIN NorthwindDW.dbo.DimProduct
    ON NorthwindDW.dbo.DimProduct.ProductID=NorthwindStaging.dbo.Sales.ProductID


