USE MASTER
GO

ALTER DATABASE ChinookDW SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP DATABASE IF EXISTS ChinookDW;
GO

CREATE DATABASE ChinookDW;
GO

USE ChinookDW;
GO

DROP TABLE IF EXISTS Dim_Employee;
DROP TABLE IF EXISTS Dim_Customer;
DROP TABLE IF EXISTS Dim_Product_Music;
DROP TABLE IF EXISTS Fact_Sales;
DROP TABLE IF EXISTS Dim_Sales_Info;
DROP TABLE IF EXISTS Dim_Date;


---- DimEmployee dimension will need to include:
CREATE TABLE Dim_Employee (
    Employee_Id INT NOT NULL,
    Employee_Last_Name VARCHAR(50) NOT NULL,
	Employee_First_Name VARCHAR(50) NOT NULL,
	Employee_Title VARCHAR(50) NOT NULL,
	Employee_Reports_To VARCHAR(50) NOT NULL, 
    Employee_Address VARCHAR(50) NOT NULL,
	Employee_City VARCHAR(50) NOT NULL,
	Employee_State VARCHAR(50) DEFAULT 'NA' NOT NULL,
	Employee_Country VARCHAR(50) NOT NULL,
	Employee_Postal_Code INT NOT NULL,
	Employee_Phone NVARCHAR(15) NOT NULL,
	Employee_Fax NVARCHAR(15) DEFAULT 'NA' NOT NULL,
	Employee_Email VARCHAR(50) NOT NULL,
    Employee_Birth_Date DATE DEFAULT '1899-12-31' NOT NULL,
    Employee_Hire_Date DATE DEFAULT '1899-12-31' NOT NULL,
	CONSTRAINT PK_Employee_Id PRIMARY KEY CLUSTERED (Employee_Id)
);

-- DimCustomer dimension will need to include:
CREATE TABLE Dim_Customer (
    Customer_Id INT NOT NULL,
	Customer_First_Name VARCHAR(50) NOT NULL,
	Customer_Last_Name VARCHAR(50) NOT NULL,
    Customer_Company VARCHAR(150) NOT NULL,
	Customer_Address VARCHAR(50) NOT NULL,
	Customer_City VARCHAR(50) NOT NULL,
	Customer_State VARCHAR(50) DEFAULT 'NA' NOT NULL,
	Customer_Country VARCHAR(50) NOT NULL,
	Customer_Postal_Code INT NOT NULL,
	Customer_Phone NVARCHAR(15) NOT NULL,
	Customer_Fax NVARCHAR(15) DEFAULT 'NA' NOT NULL,
	Customer_Email VARCHAR(50) NOT NULL,
	Customer_Support_Rep_Id INT NOT NULL,
	CONSTRAINT PK_Customer_Id PRIMARY KEY CLUSTERED (Customer_Id),
	CONSTRAINT UQ_Customer_Support_Rep_Id UNIQUE (Customer_Support_Rep_Id)
);

-- Dim_Sales_Info dimension will need to include:
CREATE TABLE Dim_Sales_Info (
	Invoice_Line_Id INT NOT NULL,
	Invoice_Id INT NOT NULL,
	Billing_Address VARCHAR(50) NOT NULL,
	Billing_State VARCHAR(50) DEFAULT 'NA' NOT NULL,
	Billing_City VARCHAR(50) NOT NULL,
	Billing_Country VARCHAR(50) NOT NULL,
	Billing_Postal_Code NCHAR(6) NOT NULL,
	CONSTRAINT PK_Invoice_Line_Id PRIMARY KEY CLUSTERED (Invoice_Line_Id)
);

-- Dim_Date dimension will need to include:
CREATE TABLE Dim_Date (
    Date_Id INT NOT NULL,
    Full_Date DATE NOT NULL,
	Quarter INT NOT NULL,
    Year INT NOT NULL,
	Month INT NOT NULL,
    MonthName VARCHAR(20) NOT NULL,
	Week INT NOT NULL,
    Day INT NOT NULL,
   	DayName VARCHAR(20) NOT NULL,
    PRIMARY KEY (Date_Id)
);



-- DimProductMusic dimension will need to include:
CREATE TABLE Dim_Product_Music (
	Track_Id INT NOT NULL,
	Track_Name VARCHAR(150) NOT NULL,
	Track_Composer VARCHAR(200) DEFAULT 'NA' NOT NULL,
	Track_Miliseconds INT NOT NULL,
	Track_Bytes INT NOT NULL,
	Track_Unit_Price FLOAT NOT NULL,
	Album_Id INT NOT NULL,
	Album_Title VARCHAR(150) NOT NULL,
	Artist_Id INT NOT NULL,
	Artist_Name VARCHAR(50) DEFAULT 'NA' NOT NULL,
	Playlist_Id INT NOT NULL,
	Playlist_Name VARCHAR(50) NOT NULL,
	Media_Type_Id INT NOT NULL,
	Media_Type_Name VARCHAR(50) NOT NULL,
	Genre_Id INT NOT NULL,
	Genre_Name VARCHAR(50) DEFAULT 'NA' NOT NULL,
	CONSTRAINT PK_Track_Id PRIMARY KEY CLUSTERED (Track_Id)
);


-- Fact_Sales dimension will need to include:
CREATE TABLE Fact_Sales(
	Invoice_Id INT NOT NULL,
	Customer_Id INT NOT NULL,
	Invoice_Date DATE NOT NULL,
	Employee_Id INT NOT NULL,
	Date_Id INT NOT NULL,
	Total FLOAT NOT NULL,
	Track_Unit_Price FLOAT NOT NULL,
	Track_Id INT NOT NULL,
	Extended_Price_Amount FLOAT NOT NULL,
	Invoice_Line_Id INT NOT NULL,
	Quantity SMALLINT NOT NULL,
	Discount_Amount FLOAT DEFAULT 0 NOT NULL,
	CONSTRAINT PK_Invoice_Id PRIMARY KEY CLUSTERED (Invoice_Id)
	);
--Specify Start Date and End date here
--Value of Start Date Must be Less than Your End Date

DECLARE @CurrentDate DATETIME = '2005-01-01' --Starting value of Date Range
DECLARE @EndDate DATETIME = '2021-12-31' --End Value of Date Range

WHILE @CurrentDate <= @EndDate
BEGIN
    INSERT INTO Dim_Date (Date_Id, Full_Date, Year, Quarter, Month, MonthName, Week, Day, DayName)
    VALUES (
        CONVERT(INT, FORMAT(@CurrentDate, 'yyyyMMdd')), -- Dateid
        @CurrentDate,                                  -- FullDate
        YEAR(@CurrentDate),                            -- Year
        DATEPART(QUARTER, @CurrentDate),               -- Quarter
        MONTH(@CurrentDate),                           -- Month
        DATENAME(MONTH, @CurrentDate),                 -- MonthName
        DATEPART(WEEK, @CurrentDate),                  -- Week
        DAY(@CurrentDate),                             -- Day
        DATENAME(WEEKDAY, @CurrentDate)               -- DayName
    );

    SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate);
END;


--add foreign key to fact_sales table

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


SELECT * FROM Dim_Customer

