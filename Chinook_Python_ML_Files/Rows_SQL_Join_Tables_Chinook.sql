USE Chinook
GO

SELECT
    a.[EmployeeId],
	a.[FirstName] AS Employee_FirstName,
    a.[LastName] AS Employee_LastName,
    a.[HireDate] AS Employee_HireDate,
	a.[BirthDate] AS Employee_BirthDate,
	DATEDIFF(YEAR, a.[BirthDate], GETDATE()) -
        CASE 
            WHEN DATEADD(YEAR, DATEDIFF(YEAR, a.[BirthDate], GETDATE()), a.[BirthDate]) > GETDATE() 
            THEN 1 
            ELSE 0 
        END AS Employee_Age,
	a.[ReportsTo],
	a.[Title] AS Employee_Role,
	b.[Country] AS Customer_Country,
	b.[CustomerId],
	b.[FirstName] + ' ' + b.[LastName] AS Customer_FullName,
	d.[UnitPrice],
    COUNT(c.[InvoiceId]) AS TotalInvoices,
    SUM(c.[Total]) AS TotalRevenue,
    AVG(c.[Total]) AS AvgRevenue
FROM [Chinook].[dbo].[Employee] a
LEFT JOIN [Chinook].[dbo].[Customer] b ON a.[EmployeeId] = b.[SupportRepId]
LEFT JOIN [Chinook].[dbo].[Invoice] c ON b.[CustomerId] = c.[CustomerId]
LEFT JOIN [Chinook].[dbo].[InvoiceLine] d ON d.[InvoiceId] = c.[InvoiceId]
GROUP BY 
	a.[EmployeeId],
	a.[FirstName],
	a.[LastName],
	a.[HireDate],
	a.[BirthDate],
	a.[ReportsTo],
	a.[Title],
	b.[Country],
	b.[CustomerId],
	b.[FirstName] + ' ' + b.[LastName],
	d.[UnitPrice]
ORDER BY [EmployeeId] ASC;