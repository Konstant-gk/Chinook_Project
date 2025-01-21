USE Chinook
GO

/*
-- Add the 'Sex' column to the Employee table
ALTER TABLE dbo.Employee
ADD [Sex] VARCHAR(15);
*/

-- Now, update the 'Sex' for specific Male employees
UPDATE dbo.Employee
SET [Sex] = 'M'
WHERE [EmployeeId] IN (1, 5, 6, 7);  

-- Update the 'Sex' for specific Female employees
UPDATE dbo.Employee
SET [Sex] = 'F'
WHERE [EmployeeId] IN (2, 3, 4, 8); 