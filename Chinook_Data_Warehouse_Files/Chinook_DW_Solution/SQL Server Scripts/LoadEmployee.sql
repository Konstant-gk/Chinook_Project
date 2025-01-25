USE Chinook;
GO

SELECT 
		a.EmployeeId,
		CONCAT_WS(' ', a.FirstName, a.LastName) as EmployeeName,
		a.Title as EmployeeTitle,
		SUM(c.Total) as EmployeeTotalRevenue,
		AVG(c.Total) as EmployeeAverageSale,
		DATEDIFF(yyyy, a.BirthDate, GETDATE()) as EmployeeAge,
		DATEDIFF(yyyy, a.HireDate, GETDATE()) as EmployeeTenure,
		CASE 
			WHEN DATEDIFF(YEAR, a.HireDate, GETDATE()) = 0 THEN SUM(c.Total) -- Avoid division by zero
			ELSE SUM(c.Total) / DATEDIFF(YEAR, a.HireDate, GETDATE())
		END as EmployeeAverageAnnualSales
	FROM dbo.Employee a LEFT JOIN 
			dbo.Customer b on a.EmployeeId = b.SupportRepId LEFT JOIN
			dbo.Invoice c on b.CustomerId = c.CustomerId
	GROUP BY
		a.EmployeeId,
		a.FirstName,
		a.LastName,
		a.HireDate,
		a.BirthDate,
		a.Title
	ORDER BY EmployeeId ASC