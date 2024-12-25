
CREATE DATABASE ChinookDW;
GO

USE ChinookDW;
GO

DROP TABLE IF EXISTS DimCustomer;
DROP TABLE IF EXISTS DimArtist;
DROP TABLE IF EXISTS DimAlbum;
DROP TABLE IF EXISTS DimTrack;
DROP TABLE IF EXISTS FactInvoiceLine;

CREATE TABLE DimCustomers(
    Customerkey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    CustomerId INT NOT NULL,
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
	
    Company NVARCHAR(100),
    CustomerAddress NVARCHAR(100),
    City NVARCHAR(50),
    CustomerState NVARCHAR(50),
    Country NVARCHAR(50),
    PostalCode NVARCHAR(10),
    Phone NVARCHAR(20),
    Fax NVARCHAR(20),
    Email NVARCHAR(50)NOT NULL
);

CREATE TABLE DimArtist (
   Artistkey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
   ArtistID INT,
   ArtistName  NVARCHAR(120)
);

CREATE TABLE DimAlbum (
   Albumkey INT IDENTITY(1,1) NOT NULL PRIMARY KEY, 
   AlbumID INT NOT NULL,
   TITLE NVARCHAR(160) NOT NULL
);

CREATE TABLE DimTrack (
   Trackkey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
   TrackID INT NOT NULL,
   TrackName NVARCHAR(200)
);

CREATE TABLE DimEmployee
(
    Employeekey INT NOT NULL PRIMARY KEY,
    EmployeeId INT NOT NULL,
    LastName VARCHAR(20) NOT NULL,
    FirstName VARCHAR(20) NOT NULL,
    Title VARCHAR(30),
    ReportsTo INT,
    BirthDate DATE,
    HireDate DATE,
    Address VARCHAR(70),
    City VARCHAR(40),
    State VARCHAR(40),
    Country VARCHAR(40),
    PostalCode VARCHAR(10),
    Phone VARCHAR(24),
    Fax VARCHAR(24),
    Email VARCHAR(60),
);

CREATE TABLE FactInvoiceLine (
       Customerkey INT NOT NULL,
       Artistkey INT NOT NULL,
       Albumkey INT NOT NULL,
       Trackkey INT NOT NULL,
       Employeekey INT NOT NULL,
       InvoiceLineId INT NOT NULL,
       UnitPrice NUMERIC(10,2) NOT NULL,
       Quantity INT NOT NULL,
       Total INT NOT NULL,
       
);