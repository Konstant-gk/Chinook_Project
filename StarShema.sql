-- STAR SCHEMA FOR CHINOOK DATABASE

-- 1. Creating the Fact Table: invoice_dm
CREATE TABLE invoice_dm (
    invoice_id INT PRIMARY KEY,
    customer_id INT,
    employee_id INT,
    track_id INT,
    invoice_date DATE,
    total_amount DECIMAL(10, 2),
    quantity INT,
    FOREIGN KEY (customer_id) REFERENCES customer_dim(customer_id),
    FOREIGN KEY (employee_id) REFERENCES employee_dim(employee_id),
    FOREIGN KEY (track_id) REFERENCES track_dim(track_id)
);

-- 2. Creating Dimension Tables

-- 2.1 Customer Dimension with Hierarchy Relationships
CREATE TABLE customer_dim (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(40),
    last_name VARCHAR(40),
    email VARCHAR(60),
    phone VARCHAR(24),
    address VARCHAR(100),
    city VARCHAR(40),
    state VARCHAR(40),
    postal_code VARCHAR(20),
    country VARCHAR(40),
    region VARCHAR(40)
);

-- 2.2 Employee Dimension
CREATE TABLE employee_dim (
    employee_id INT PRIMARY KEY,
    first_name VARCHAR(40),
    last_name VARCHAR(40),
    title VARCHAR(40),
    hire_date DATE,
    reports_to INT,
    FOREIGN KEY (reports_to) REFERENCES employee_dim(employee_id)
);

-- 2.3 Track Dimension with Hierarchy Relationships
CREATE TABLE track_dim (
    track_id INT PRIMARY KEY,
    track_name VARCHAR(200),
    album_title VARCHAR(160),
    artist_name VARCHAR(120),
    genre VARCHAR(120),
    composer VARCHAR(220),
    media_type VARCHAR(40)
);

-- 2.4 Time Dimension
CREATE TABLE time_dim (
    time_id INT PRIMARY KEY AUTO_INCREMENT,
    invoice_date DATE,
    year INT,
    quarter INT,
    month INT,
    day INT,
    week_of_year INT
);

-- Populating the Dimension Tables

-- Populate customer_dim
INSERT INTO customer_dim (customer_id, first_name, last_name, email, phone, address, city, state, postal_code, country, region)
SELECT CustomerId, FirstName, LastName, Email, Phone, Address, City, State, PostalCode, Country, 
    CASE 
        WHEN Country IN ('USA', 'Canada') THEN 'North America'
        WHEN Country IN ('France', 'Germany', 'UK') THEN 'Europe'
        ELSE 'Other' 
    END AS region
FROM Customer;

-- Populate employee_dim
INSERT INTO employee_dim (employee_id, first_name, last_name, title, hire_date, reports_to)
SELECT EmployeeId, FirstName, LastName, Title, HireDate, ReportsTo
FROM Employee;

-- Populate track_dim
INSERT INTO track_dim (track_id, track_name, album_title, artist_name, genre, composer, media_type)
SELECT t.TrackId, t.Name, a.Title, ar.Name, g.Name, t.Composer, m.Name
FROM Track t
JOIN Album a ON t.AlbumId = a.AlbumId
JOIN Artist ar ON a.ArtistId = ar.ArtistId
JOIN Genre g ON t.GenreId = g.GenreId
JOIN MediaType m ON t.MediaTypeId = m.MediaTypeId;

-- Populate time_dim
INSERT INTO time_dim (invoice_date, year, quarter, month, day, week_of_year)
SELECT DISTINCT InvoiceDate, YEAR(InvoiceDate), 
    CEILING(MONTH(InvoiceDate) / 3.0) AS quarter, 
    MONTH(InvoiceDate), 
    DAY(InvoiceDate), 
    DATEPART(WEEK, InvoiceDate) AS week_of_year
FROM Invoice;

-- Populating the Fact Table
INSERT INTO invoice_dm (invoice_id, customer_id, employee_id, track_id, invoice_date, total_amount, quantity)
SELECT i.InvoiceId, i.CustomerId, e.EmployeeId, il.TrackId, i.InvoiceDate, il.UnitPrice * il.Quantity, il.Quantity
FROM Invoice i
JOIN InvoiceLine il ON i.InvoiceId = il.InvoiceId
JOIN Customer c ON i.CustomerId = c.CustomerId
JOIN Employee e ON c.SupportRepId = e.EmployeeId;
