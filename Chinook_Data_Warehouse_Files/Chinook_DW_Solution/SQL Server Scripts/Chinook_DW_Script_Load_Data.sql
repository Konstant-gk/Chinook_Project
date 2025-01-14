USE ChinookDW;
GO

-- Only for the first load
TRUNCATE TABLE dbo.Fact_Sales;
TRUNCATE TABLE dbo.Dim_Product_Music;
TRUNCATE TABLE dbo.Dim_Customer;
TRUNCATE TABLE dbo.Dim_Employee;
TRUNCATE TABLE dbo.Dim_Sales_Info;


--Drop constraints and recreate them after
ALTER TABLE dbo.Fact_Sales DROP CONSTRAINT IF EXISTS FactSales_DimDate_DateId_FK;
ALTER TABLE dbo.Fact_Sales DROP CONSTRAINT IF EXISTS FactSales_DimSalesInfo_InvoiceLineId_FK;
ALTER TABLE dbo.Fact_Sales DROP CONSTRAINT IF EXISTS FactSales_DimCustomer_CustomerSupportRepId_FK;
ALTER TABLE dbo.Fact_Sales DROP CONSTRAINT IF EXISTS FactSales_DimCustomer_CustomerId_FK;
ALTER TABLE dbo.Fact_Sales DROP CONSTRAINT IF EXISTS FactSales_DimEmployee_EmployeeId_FK;
ALTER TABLE dbo.Fact_Sales DROP CONSTRAINT IF EXISTS FactSales_DimProductMusic_TrackId_FK;
GO


-- Load values to Dim_Sales_Info
INSERT INTO Dim_Sales_Info (
	Invoice_Line_Id, 
	Invoice_Id, 
	Billing_Address, 
	Billing_State, 
	Billing_City, 
	Billing_Country, 
	Billing_Postal_Code)
SELECT 
	b.[InvoiceLineId], 
	a.[InvoiceId],
	a.[BillingAddress],
	a.[BillingState],
	a.[BillingCity],
	a.[BillingCountry],
	a.[BillingPostalCode]
FROM [ChinookStaging].[dbo].[Invoice] a
	INNER JOIN [ChinookStaging].[dbo].[Invoice_Line] b ON a.InvoiceId = b.InvoiceId;



-- Load values to Dim_Employee
INSERT INTO Dim_Employee (
	[Employee_Id],
	[Employee_Last_Name],
	[Employee_First_Name],
	[Employee_Title],
	[Employee_Reports_To],
	[Employee_Address], 
	[Employee_City],
	[Employee_State],
	[Employee_Country],
	[Employee_Postal_Code],
	[Employee_Phone],
	[Employee_Fax],
	[Employee_Email],
	[Employee_Birth_Date],
	[Employee_Hire_Date])
SELECT 
	[EmployeeID],
	[LastName],
	[FirstName],
	[Title],
    CASE WHEN [ReportsTo] IS NULL THEN 0 ELSE [ReportsTo] END,
	CASE WHEN [Address] IS NULL THEN 'N/A' ELSE [Address] END,
    CASE WHEN [City] IS NULL THEN 'N/A' ELSE [City] END,
    CASE WHEN [State] IS NULL THEN 'N/A' ELSE [STATE] END, 
    CASE WHEN [Country] IS NULL THEN 'N/A' ELSE [Country] END,
	CASE WHEN [PostalCode] IS NULL THEN 'N/A' ELSE [PostalCode] END,
	[Phone],
	[Fax],
	[Email],
	[BirthDate],
	[HireDate]
FROM [ChinookStaging].[dbo].[Employee];


-- Load values to Dim_Customer
INSERT INTO Dim_Customer(
	[Customer_Id],
	[Customer_First_Name],
	[Customer_Last_Name],
	[Customer_Company],
	[Customer_Address],
	[Customer_City],
	[Customer_State],
	[Customer_Country], 
	[Customer_Postal_Code],
	[Customer_Phone],
	[Customer_Fax],
	[Customer_Email],
	[Customer_Support_Rep_Id])
SELECT 
	[CustomerId],
	[FirstName],
	[LastName],
	CASE WHEN [Company] IS NULL THEN 'N/A' ELSE [Company] END,
	CASE WHEN [Address] IS NULL THEN 'N/A' ELSE [Address] END,
	CASE WHEN [City] IS NULL THEN 'N/A' ELSE [City] END,
	CASE WHEN [State] IS NULL THEN 'N/A' ELSE [STATE] END, 
    CASE WHEN [Country] IS NULL THEN 'N/A' ELSE [Country] END,
	CASE WHEN [PostalCode] IS NULL THEN 'N/A' ELSE [PostalCode] END,
	[Phone],
	[Fax],
	[Email],
	[SupportRepId]
FROM [ChinookStaging].[dbo].[Customer];


-- Load values to Dim_Product_Music
INSERT INTO Dim_Product_Music(
	[Track_Id],
	[Track_Name],
	[Track_Composer],
	[Track_Miliseconds],
	[Track_Bytes],
	[Track_Unit_Price],
	[Album_Id],
	[Album_Title],
	[Artist_Id],
	[Artist_Name],
	[Playlist_Id],
	[Playlist_Name],
	[Media_Type_Id],
	[Media_Type_Name],
	[Genre_Id],
	[Genre_Name]
SELECT 
	a.[TrackId], 
	a.[Name], 
	a.[Composer],
	a.[Milliseconds],
	a.[Bytes],
	a.[UnitPrice],
	a.[AlbumId],
	b.[Title],
	b.[ArtistId],
	--c.[Name],
	d.[PlaylistId],
	--d.[Name],
	a.[MediaTypeId],
	e.[Name],
	a.[GenreId],
	f.[Name]

FROM [ChinookStaging].[dbo].[Track] a
	INNER JOIN [ChinookStaging].[dbo].[Album] b ON 
	INNER JOIN [ChinookStaging].[dbo].[Playlist] ON
	INNER JOIN [ChinookStaging].[dbo].[Genre] ON
	INNER JOIN [ChinookStaging].[dbo].[Media_Type] ON
	INNER JOIN [ChinookStaging].[dbo].[Artist] ON



-- Load values to Fact_Sales
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


--recreate the constraints Foreign Keys

ALTER TABLE Fact_Sales ADD CONSTRAINT FactSales_DimDate_DateId_FK FOREIGN KEY (Date_Id)
    REFERENCES Dim_Date(Date_Id);

ALTER TABLE Fact_Sales ADD CONSTRAINT FactSales_DimSalesInfo_InvoiceLineId_FK FOREIGN KEY (Invoice_Line_Id)
    REFERENCES Dim_Sales_Info (Invoice_Line_Id);

ALTER TABLE Fact_Sales ADD CONSTRAINT FactSales_DimCustomer_CustomerSupportRepId_FK FOREIGN KEY (Employee_Id)
    REFERENCES Dim_Customer (Customer_Support_Rep_Id);

ALTER TABLE Fact_Sales ADD CONSTRAINT FactSales_DimCustomer_CustomerId_FK FOREIGN KEY (Customer_Id)
    REFERENCES Dim_Customer (Customer_Id);

ALTER TABLE Fact_Sales ADD CONSTRAINT FactSales_DimEmployee_EmployeeId_FK FOREIGN KEY (Employee_Id)
    REFERENCES Dim_Employee (Employee_Id);

ALTER TABLE Fact_Sales ADD CONSTRAINT FactSales_DimProductMusic_TrackId_FK FOREIGN KEY (Track_Id)
    REFERENCES Dim_Product_Music (Track_Id);
