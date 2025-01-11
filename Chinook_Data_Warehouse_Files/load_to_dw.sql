use ChinookDW;
GO

/*
ALTER TABLE dbo.FactInvoice NOCHECK CONSTRAINT ALL;
ALTER TABLE dbo.DimCustomer NOCHECK CONSTRAINT ALL;
GO
--DOES NOT HELP WITH TRUNCATION!!!
*/
--Drop constraints and recreate them after
ALTER TABLE dbo.FactInvoice DROP CONSTRAINT IF EXISTS FactInvoice_DimCustomer_CustomerId_fk;
ALTER TABLE dbo.FactInvoice DROP CONSTRAINT IF EXISTS FactInvoice_DimEmployee_EmployeeId_fk;
ALTER TABLE dbo.FactInvoice DROP CONSTRAINT IF EXISTS FactInvoice_DimTrack_TrackId_fk;
ALTER TABLE dbo.FactInvoice DROP CONSTRAINT IF EXISTS FactInvoice_DimDate_InvoiceDateKey_fk;
GO
-- Temporary solution, should use MERGE TARGET-SOURCE to insert generally, to handle primary key conflicts or SCD
TRUNCATE TABLE dbo.FactInvoice;
TRUNCATE TABLE dbo.DimCustomer;
TRUNCATE TABLE dbo.DimEmployee;
TRUNCATE TABLE dbo.DimTrack;
GO

INSERT INTO dbo.[DimEmployee](EmployeeId,EmployeeName,EmployeeTitle,EmployeeReportsTo,EmployeeBirthDate,EmployeeHireDate,EmployeeAddress,EmployeeCity,EmployeeState,EmployeePostalCode,EmployeeEmail)
    (SELECT [EmployeeId], CONCAT([FirstName], [LastName]), [Title], 
    CASE WHEN [ReportsTo] IS NULL THEN 0 ELSE [ReportsTo] END, 
    [BirthDate], 
    [HireDate], 
    CASE WHEN [Address] IS NULL THEN 'N/A' ELSE [Address] END,
    CASE WHEN [City] IS NULL THEN 'N/A' ELSE [City] END,
    CASE WHEN [State] IS NULL THEN 'N/A' ELSE [STATE] END, 
    CASE WHEN [PostalCode] IS NULL THEN 'N/A' ELSE [PostalCode] END,
    [Email]
    FROM ChinookStaging.dbo.[Employees]);

INSERT INTO dbo.[DimCustomer](CustomerId, CustomerName, CustomerCompany, CustomerCountry, CustomerState,CustomerCity, CustomerPostalCode, CustomerPhone, CustomerSupportRepId)
    (SELECT CustomerId, CONCAT(FirstName, LastName), 
    CASE WHEN Company IS NULL THEN 'N/A' ELSE Company END,
    CASE WHEN Country IS NULL THEN 'N/A' ELSE Country END, 
    CASE WHEN [State] IS NULL THEN 'N/A' ELSE [State] END,  
    CASE WHEN City IS NULL THEN 'N/A' ELSE City END, 
    CASE WHEN PostalCode IS NULL THEN 'N/A' ELSE PostalCode END, 
    CASE WHEN Phone IS NULL THEN 'N/A' ELSE Phone END, 
    SupportRepId
    FROM ChinookStaging.dbo.Customers);

INSERT INTO dbo.DimTrack(TrackId, TrackName, AlbumId, AlbumName, ArtistId, ArtistName, GenreId, GenreName, TrackComposer, TrackMilliseconds, TrackUnitPrice, TrackBytes)
    (SELECT TrackId, Track, AlbumId, Album, ArtistId, Artist, GenreId, Genre,
    CASE WHEN Composer IS NULL THEN 'N/A' ELSE Composer END, 
    Milliseconds, UnitPrice, Bytes 
    FROM ChinookStaging.dbo.Tracks);

-- We assume that SupportRepId (EmployeeId in CustomerTable) is the one making the sale?
INSERT INTO dbo.FactInvoice(InvoiceLineId, TrackId, CustomerId,EmployeeId, InvoiceDateKey, InvoiceId, InvoiceFullDate, InvoiceBillingAddress, InvoiceBillingCity, InvoiceBillingState, InvoiceBillingCountry,Quantity, UnitPrice, ExtendedPriceAmount,Total)
    (SELECT a.InvoiceLineId, a.TrackId, b.CustomerId, c.SupportRepId, d.DateKey, a.InvoiceId, d.FullDate, 
    CASE WHEN b.BillingAddress IS NULL THEN 'N/A' ELSE b.BillingAddress END,
    CASE WHEN b.BillingCity IS NULL THEN 'N/A' ELSE b.BillingCity END,
    CASE WHEN b.BillingState IS NULL THEN 'N/A' ELSE b.BillingState END, 
    CASE WHEN b.BillingCountry IS NULL THEN 'N/A' ELSE b.BillingCountry END, 
    a.Quantity, 
    a.UnitPrice, 
    a.Quantity * a.UnitPrice as ExtendedPriceAmount, b.Total 
    FROM ChinookStaging.dbo.InvoiceLines a inner join ChinookStaging.dbo.Invoices b on a.InvoiceId = b.InvoiceId
    inner join ChinookStaging.dbo.Customers c on c.CustomerId = b.CustomerId
    inner join dbo.DimDate d on b.InvoiceDate = d.FullDate);


--Recreate constraints
ALTER TABLE dbo.FactInvoice 
	ADD CONSTRAINT FactInvoice_DimCustomer_CustomerId_fk
		FOREIGN KEY (CustomerId) REFERENCES DimCustomer(CustomerId);

ALTER TABLE dbo.FactInvoice 
	ADD CONSTRAINT FactInvoice_DimEmployee_EmployeeId_fk
		FOREIGN KEY (EmployeeId) REFERENCES DimEmployee(EmployeeId);

ALTER TABLE dbo.FactInvoice 
	ADD CONSTRAINT FactInvoice_DimDate_InvoiceDateKey_fk
		FOREIGN KEY (InvoiceDateKey) REFERENCES DimDate(DateKey);
		
ALTER TABLE dbo.FactInvoice 
	ADD CONSTRAINT FactInvoice_DimTrack_TrackId_fk
		FOREIGN KEY (TrackId) REFERENCES DimTrack(TrackId);