USE MASTER
GO

BEGIN
DROP DATABASE IF EXISTS [Chinook-DW]
END

CREATE DATABASE [Chinook-DW]

GO


use [Chinook-DW]
GO



create table DimEmployee(
	EmployeeId INT NOT NULL,
	EmployeeName VARCHAR(40) NOT NULL,
	EmployeeTitle VARCHAR(40) NOT NULL,
	EmployeeReportsTo INT NOT NULL, --  only 1 line (general manager) is NULL we will handle with insert query 
    EmployeeBirthDate DATE NOT NULL,
    EmployeeHireDate DATE NOT NULL,
    EmployeeAddress VARCHAR(40) NOT NULL,
    EmployeeCity VARCHAR(40) NOT NULL,
    EmployeeState VARCHAR(15) DEFAULT 'NA' NOT NULL,
    EmployeePostalCode VARCHAR(15) NOT NULL,
    EmployeeEmail VARCHAR(40) NOT NULL,
    -- do we need anything more for employees?
	CONSTRAINT PK_EmployeeId PRIMARY KEY CLUSTERED (EmployeeId)
);


create table DimCustomer (
	CustomerId INT NOT NULL,
    CustomerName VARCHAR(40) NOT NULL,
    CustomerCompany VARCHAR(40) NOT NULL,
	CustomerCountry VARCHAR(15) NOT NULL,
	CustomerState VARCHAR(15) DEFAULT 'N/A' NOT NULL,
	CustomerCity VARCHAR(15) NOT NULL,
	CustomerPostalCode VARCHAR(10) NOT NULL,
    CustomerPhone VARCHAR(24) NOT NULL,
    CustomerSupportRepId INT NOT NULL, --Checked for null values in staging and there are none
	CONSTRAINT PK_CustomerId PRIMARY KEY CLUSTERED (CustomerId),
    CONSTRAINT FK_SupportRepId FOREIGN KEY (CustomerSupportRepId) REFERENCES DimEmployee(EmployeeId)
);


create table DimTrack
(
	TrackId INT NOT NULL,
	TrackName VARCHAR(40) NOT NULL,
	AlbumId INT NOT NULL, --Checked NOT NULL everywhere
	AlbumName VARCHAR(40) NOT NULL,
	ArtistId INT NOT NULL,
	ArtistName VARCHAR(40) NOT NULL,
	GenreId INT NOT NULL,
	GenreName VARCHAR(40) NOT NULL,
	TrackComposer VARCHAR(40) DEFAULT 'N/A' NOT NULL, --We can drop this
	TrackMilliseconds INT NOT NULL,
	TrackUnitPrice FLOAT NOT NULL,
	TrackBytes INT NOT NULL,
	CONSTRAINT PK_TrackId PRIMARY KEY CLUSTERED (TrackId)
);

--Merge Invoice and InvoiceLine to single fact table (same strategy as with Northwind -> Order table + OrderDetails table)

create table FactInvoice(
	InvoiceLineId INT NOT NULL, --Invoices are seperated by lines (independent track sales), then accumulated to one invoice in the invoice (facts are InvoiceLines)
    TrackId INT NOT NULL,
	CustomerId INT NOT NULL,
	EmployeeId INT NOT NULL, --If we want an Employee dimension we need this FK, we have to insert it from the SupportRepId in the customer table. We are assuming that the SupportRepId employee makes the sale.
	InvoiceDateKey INT NOT NULL,
	InvoiceID INT NOT NULL, --not a FK
	InvoiceBillingAddress VARCHAR(40) NOT NULL,
	InvoiceBillingCity VARCHAR(40) NOT NULL,
	InvoiceBillingState VARCHAR(40) DEFAULT 'N/A',
	InvoiceBillingCountry VARCHAR(40) NOT NULL,
	Quantity SMALLINT NOT NULL, --Mostly 1?
	ExtendedPriceAmount FLOAT NOT NULL, --Quantity * UnitPrice
	--DiscountAmount FLOAT DEFAULT 0 NOT NULL, --Are there discounts?
	UnitPrice FLOAT NOT NULL,
	Total FLOAT NOT NULL, --Introduces redundancy!? The total of the invoice is repeated for every line of the invoice in the fact table. Maybe drop it? (loss of ready info)
);

--granularity -> InvoiceLine (track sales)

--create and populate date dimension / can add more stuff

CREATE TABLE DimDate (
    DateKey INT PRIMARY KEY,         -- YYYYMMDD format
    FullDate DATE NOT NULL,          
    Year INT NOT NULL,               
    Quarter INT NOT NULL,            -- Quarter (1 to 4)
    Month INT NOT NULL,              -- Month (1 to 12)
    MonthName NVARCHAR(20) NOT NULL, -- Month name (e.g., January)
    Week INT NOT NULL,               -- Week number (1 to 53)
    Day INT NOT NULL,                -- Day of the month (1 to 31)
    DayName NVARCHAR(20) NOT NULL,   -- Day name (e.g., Monday)
    IsWeekend BIT NOT NULL           -- 1 if weekend, 0 otherwise
);

/*
report ideas: 
are average sales higher during weekends? (to apply discounts or promotions then)
*/

--populate date dimension
--Found the earliest date of invoice to be in 2009, so populate from 2005 
--What to do with birth-dates and hire-dates of employees? DimEmployee will also reference dimDate?


DECLARE @CurrentDate DATE = '2005-01-01';
DECLARE @EndDate DATE = '2025-12-31';

WHILE @CurrentDate <= @EndDate
BEGIN
    INSERT INTO DimDate (DateKey, FullDate, Year, Quarter, Month, MonthName, Week, Day, DayName, IsWeekend)
    VALUES (
        CONVERT(INT, FORMAT(@CurrentDate, 'yyyyMMdd')), -- DateKey
        @CurrentDate,                                  -- FullDate
        YEAR(@CurrentDate),                            -- Year
        DATEPART(QUARTER, @CurrentDate),               -- Quarter
        MONTH(@CurrentDate),                           -- Month
        DATENAME(MONTH, @CurrentDate),                 -- MonthName
        DATEPART(WEEK, @CurrentDate),                  -- Week
        DAY(@CurrentDate),                             -- Day
        DATENAME(WEEKDAY, @CurrentDate),               -- DayName
        CASE WHEN DATENAME(WEEKDAY, @CurrentDate) IN ('Saturday', 'Sunday') THEN 1 ELSE 0 END -- IsWeekend
    );

    SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate);
END;

--add holidays if we want for queries?

--add foreign key constraints to fact table

ALTER TABLE FactInvoice 
	ADD CONSTRAINT FactInvoice_DimCustomer_CustomerId_fk
		FOREIGN KEY (CustomerId) REFERENCES DimCustomer(CustomerId)

ALTER TABLE FactInvoice 
	ADD CONSTRAINT FactInvoice_DimEmployee_EmployeeId_fk
		FOREIGN KEY (EmployeeId) REFERENCES DimEmployee(EmployeeId)

ALTER TABLE FactInvoice 
	ADD CONSTRAINT FactInvoice_DimDate_InvoiceDateKey_fk
		FOREIGN KEY (InvoiceDateKey) REFERENCES DimDate(DateKey)
		
ALTER TABLE FactInvoice 
	ADD CONSTRAINT FactInvoice_DimTrack_TrackId_fk
		FOREIGN KEY (TrackId) REFERENCES DimTrack(TrackId)