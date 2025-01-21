use Chinook;
GO


DECLARE @Aggregations TABLE(EmployeeId INT, Total FLOAT,  CustomersEarned INT);
INSERT INTO @Aggregations(EmployeeId, Total, CustomersEarned) (
SELECT 
	e.EmployeeId,
	SUM(i.Total) as Total,
	COUNT(DISTINCT c.CustomerId) as CustomersEarned
FROM  Customer c INNER JOIN
	Employee e ON c.SupportRepId = e.EmployeeId INNER JOIN
	Invoice i ON c.CustomerId = i.CustomerId
GROUP BY e.[EmployeeId]
);

SELECT *, w.EmployeeTotalSales/CAST(w.EmployeeTenure AS FLOAT) as EmployeeAverageAnnualSales
FROM (SELECT 
	e.EmployeeId,
	CONCAT(e.FirstName, ' ', e.LastName) as EmployeeName,
	DATEDIFF(year,e.BirthDate,GETDATE()) as EmployeeAge,
	DATEDIFF(year,e.HireDate,GETDATE()) as EmployeeTenure,
	a.Total as EmployeeTotalSales,
	a.CustomersEarned as EmployeeCustomers
FROM Employee e INNER JOIN @Aggregations a on e.EmployeeId = a.EmployeeId) w


