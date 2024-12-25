
CREATE DATABASE ChinookDW
GO

USE ChinookDW
GO

DROP TABLE IF EXISTS Dim_Employee;
DROP TABLE IF EXISTS Dim_Customer;
DROP TABLE IF EXISTS Dim_Product;
DROP TABLE IF EXISTS Fact_Sales;
DROP TABLE IF EXISTS Dim_Sales_Info;
DROP TABLE IF EXISTS Dim_Date;


---- DimEmployee dimension will need to include:
CREATE TABLE Dim_Employee (
    Employee_Id INT NOT NULL,
    Last_Name VARCHAR(50) NOT NULL,
	First_Name VARCHAR(50) NOT NULL,
	Title VARCHAR(50) NOT NULL,
	Reports_To VARCHAR(50) NOT NULL, 
    Employee_Address VARCHAR(50) NOT NULL,
	City VARCHAR(50) NOT NULL,
	Employee_State VARCHAR(50),
	Country VARCHAR(50) NOT NULL,
	Postal_Code INT NOT NULL,
	Phone NVARCHAR(10) NOT NULL,
	Fax NVARCHAR(10),
	Email VARCHAR(50) NOT NULL,
    Birth_Date DATE NOT NULL,
    Hire_Date DATE NOT NULL,
	PRIMARY KEY (Employee_Id)
);

-- DimCustomer dimension will need to include:
CREATE TABLE Dim_Customer(
    Customer_Id INT NOT NULL,
	First_Name VARCHAR(50) NOT NULL,
	Last_Name VARCHAR(50) NOT NULL,
    Company VARCHAR(50) NOT NULL,
	Customer_Address VARCHAR(50) NOT NULL,
	City VARCHAR(50) NOT NULL,
	Customer_State VARCHAR(50) NOT NULL,
	Country VARCHAR(50) NOT NULL,
	Postal_Code INT NOT NULL,
	Phone NVARCHAR(10) NOT NULL,
	Fax NVARCHAR(10),
	Email VARCHAR(50) NOT NULL,
	Support_Rep_Id INT NOT NULL,
	PRIMARY KEY (Customer_Id),
	FOREIGN KEY (Support_Rep_Id) REFERENCES Dim_Employee (Employee_Id)
);

-- Dim_Sales_Info dimension will need to include:

CREATE TABLE Dim_Sales_Info(
	Invoice_Line_Id INT NOT NULL,
	Invoice_Id INT NOT NULL,
	Billing_Address VARCHAR(50) NOT NULL,
	Billing_State VARCHAR(50) NOT NULL,
	Billing_City VARCHAR(50) NOT NULL,
	Billing_Country VARCHAR(50) NOT NULL,
	Billing_Postal_Code NCHAR(6) NOT NULL,
	PRIMARY KEY (Invoice_Line_Id)
);

CREATE TABLE Dim_Date(
		Date_Id INT NOT NULL,
        Date DATETIME,
        [DayOfMonth] VARCHAR(2), -- Field will hold day number of Month
        [DaySuffix] VARCHAR(4), -- Apply suffix as 1st, 2nd ,3rd etc
        [DayName] VARCHAR(9), -- Contains name of the day, Sunday, Monday
        [DayOfWeekInMonth] VARCHAR(2), --1st Monday or 2nd Monday in Month
        [DayOfWeekInYear] VARCHAR(2),
        [DayOfQuarter] VARCHAR(3),
        [DayOfYear] VARCHAR(3),
        [WeekOfMonth] VARCHAR(1),-- Week Number of Month
        [WeekOfQuarter] VARCHAR(2), --Week Number of the Quarter
        [WeekOfYear] VARCHAR(2),--Week Number of the Year
        [Month] VARCHAR(2), --Number of the Month 1 to 12
        [MonthName] VARCHAR(9),--January, February etc
        [MonthOfQuarter] VARCHAR(2),-- Month Number belongs to Quarter
        [Quarter] CHAR(1),
        [QuarterName] VARCHAR(9),--First,Second..
        [Year] CHAR(4),-- Year value of Date stored in Row
        [YearName] CHAR(7), --CY 2012,CY 2013
        [MonthYear] CHAR(10), --Jan-2013,Feb-2013
        [MMYYYY] CHAR(6),
		PRIMARY KEY (Date_Id)
    )
;



-- DimProduct dimension will need to include:
CREATE TABLE Dim_Product(
	Track_Id INT NOT NULL,
	Track_Name VARCHAR(50) NOT NULL,
	Track_Composer VARCHAR(50),
	Track_Miliseconds INT,
	Track_Bytes INT,
	Unit_Price FLOAT NOT NULL,
	Album_Id INT NOT NULL,
	Album_Title VARCHAR(50) NOT NULL,
	Artist_Id INT NOT NULL,
	Artist_Name VARCHAR(50) NOT NULL,
	Playlist_Id INT NOT NULL,
	Playlist_Name VARCHAR(50) NOT NULL,
	Media_Type_Id INT NOT NULL,
	Media_Type_Name VARCHAR(50) NOT NULL,
	Genre_Id INT NOT NULL,
	Genre_Name VARCHAR(50) NOT NULL,
	PRIMARY KEY (Track_Id),
);


-- Fact_Sales dimension will need to include:
CREATE TABLE Fact_Sales(
	Invoice_Id INT NOT NULL,
	Customer_Id INT NOT NULL,
	Invoice_Date DATE NOT NULL,
	Employee_Id INT NOT NULL,
	Date_Id INT NOT NULL,
	Total FLOAT NOT NULL,
	Unit_Price FLOAT NOT NULL,
	Track_Id INT NOT NULL,
	Invoice_Line_Id INT NOT NULL,
	Quantity SMALLINT NOT NULL,
	PRIMARY KEY (Invoice_Id),
	FOREIGN KEY (Customer_Id) REFERENCES Dim_Customer (Customer_Id),
	FOREIGN KEY (Employee_Id) REFERENCES Dim_Employee (Employee_Id),
	FOREIGN KEY (Date_Id) REFERENCES Dim_Date (Date_Id),
	FOREIGN KEY (Track_Id) REFERENCES Dim_Product (Track_Id),
	FOREIGN KEY (Invoice_Line_Id) REFERENCES Dim_Sales_Info (Invoice_Line_Id)
);




