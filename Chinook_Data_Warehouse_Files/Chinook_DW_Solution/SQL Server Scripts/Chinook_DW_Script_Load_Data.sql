USE ChinookDW

-- Only for the first load
DELETE FROM Fact_Sales;
DELETE FROM Dim_Product;
DELETE FROM Dim_Customer;
DELETE FROM Dim_Employee;
DELETE FROM Dim_Sales_Info;
DELETE FROM Dim_Date;

-- 0
INSERT INTO Dim_Sales_Info (Invoice_Line_Id, Invoice_Id)
SELECT [InvoiceLineId], [InvoiceId]
FROM [ChinookStaging].[dbo].[Invoice_Line]

INSERT INTO Dim_Sales_Info (Billing_Address, Billing_State, Billing_City, Billing_Country, Billing_Postal_Code)
SELECT [BillingAddress], [BillingState], [BillingCity], [BillingCountry], [BillingPostalCode]
FROM [ChinookStaging].[dbo].[Invoice]


-- 1
INSERT INTO Dim_Employee (
	[Employee_Id], [Last_Name], [First_Name], [Title], [Reports_To], [Employee_Address], 
	[City], [Employee_State], [Country], [Postal_Code], [Phone], [Fax], [Email], [Birth_Date], [Hire_Date])
SELECT 
	[EmployeeID], [LastName], [FirstName], [Title], [ReportsTo], [Address], 
	[City], [State], [Country], [PostalCode], [Phone], [Fax], [Email], [BirthDate], [HireDate]
FROM [ChinookStaging].[dbo].[Employee]


--2
INSERT INTO Dim_Customer(
	[Customer_Id], [First_Name], [Last_Name], [Company], [Customer_Address], [City], [Customer_State], [Country], 
	[Postal_Code], [Phone], [Fax], [Email], [Support_Rep_Id])
SELECT 
	[CustomerId], [FirstName], [LastName], [Company], [Address], [City], [State], [Country], 
	[PostalCode], [Phone], [Fax], [Email], [SupportRepId]
FROM [ChinookStaging].[dbo].[Customer]


--3
INSERT INTO Dim_Product(
	[Track_Id], [Track_Name], [Album_Id], [Media_Type_Id], [Genre_Id], [Track_Composer], 
	[Track_Miliseconds],[Track_Bytes], [Unit_Price])
SELECT 
	[TrackId], [Name], [AlbumId], [MediaTypeId], [GenreId], [Composer], 
	[Milliseconds], [Bytes], [UnitPrice]
FROM [ChinookStaging].[dbo].[Track]

INSERT INTO Dim_Product([Playlist_Id], [Playlist_Name])
SELECT [PlaylistId], [Name]
FROM [ChinookStaging].[dbo].[Playlist]

INSERT INTO Dim_Product([Genre_Name])
SELECT [Name]
FROM [ChinookStaging].[dbo].[Genre]

INSERT INTO Dim_Product([Media_Type_Name])
SELECT [Name]
FROM [ChinookStaging].[dbo].[Media_Type]

INSERT INTO Dim_Product([Album_Title])
SELECT [Title]
FROM [ChinookStaging].[dbo].[Album]

INSERT INTO Dim_Product([Artist_Id], [Artist_Name])
SELECT [ArtistId], [Name]
FROM [ChinookStaging].[dbo].[Artist]


--4
INSERT INTO Fact_Sales([Invoice_Id], [Invoice_Line_Id], [Track_Id], [Unit_Price], [Quantity])
SELECT [InvoiceId], [InvoiceLineId], [TrackId], [UnitPrice], [Quantity]
FROM [ChinookStaging].[dbo].[Invoice_Line]

INSERT INTO Fact_Sales([Customer_Id], [Invoice_Date], [Total])
SELECT [CustomerId], [InvoiceDate], [Total]
FROM [ChinookStaging].[dbo].[Invoice]

INSERT INTO Fact_Sales([Employee_Id])
SELECT [EmployeeID]
FROM [ChinookStaging].[dbo].[Employee]


INNER JOIN NorthwindDW.dbo.DimCustomer
    ON NorthwindDW.dbo.DimCustomer.CustomerID=NorthwindStaging.dbo.Sales.CustomerId
INNER JOIN NorthwindDW.dbo.DimEmployee
    ON NorthwindDW.dbo.DimEmployee.EmployeeID=NorthwindStaging.dbo.Sales.EmployeeId
INNER JOIN NorthwindDW.dbo.DimProduct
    ON NorthwindDW.dbo.DimProduct.ProductID=NorthwindStaging.dbo.Sales.ProductID


