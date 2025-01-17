USE Chinook
GO

SELECT 
    a.[EmployeeId],
    a.[LastName] AS Employee_LastName,
    a.[FirstName] AS Employee_FirstName,
    a.[HireDate] AS Employee_HireDate,
	a.[ReportsTo],
	a.[Title] AS Employee_Role,
	a.[BirthDate],
	a.[Country] AS Employee_Country,
	a.[City] AS Employee_City,
	c.[Total],
    COUNT(c.[InvoiceId]) AS TotalInvoices,
    SUM(c.[Total]) AS TotalRevenue,
    AVG(c.[Total]) AS AvgRevenue
FROM [Chinook].[dbo].[Employee] a
LEFT JOIN [Chinook].[dbo].[Customer] b ON a.[EmployeeId] = b.[SupportRepId]
LEFT JOIN [Chinook].[dbo].[Invoice] c ON b.[CustomerId] = c.[CustomerId]
GROUP BY  
	a.[EmployeeId],
    a.[LastName],
    a.[FirstName],
    a.[HireDate],
	a.[ReportsTo],
	a.[Title],
	a.[BirthDate],
	a.[Country],
	a.[City],
	c.[Total]
ORDER BY TotalRevenue DESC;