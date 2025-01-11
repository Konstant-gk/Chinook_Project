USE master
--create db
GO

ALTER DATABASE [ChinookStaging] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
drop database if exists [ChinookStaging];
GO

create database [ChinookStaging];
GO


use [ChinookStaging];
GO

select 
	a.TrackId, a.Name as Track, b.Title as  Album, b.AlbumId, c.ArtistId, c.Name as Artist,d.Name as Genre,a.GenreId, a.Composer, a.Milliseconds,a.UnitPrice, a.Bytes
	into Tracks
from Chinook.dbo.Track a 
	inner join Chinook.dbo.Album b on a.AlbumId=b.AlbumId
	inner join Chinook.dbo.Artist c on b.ArtistId = c.ArtistId
	inner join Chinook.dbo.Genre d on a.GenreId = d.GenreId;
	

select 
	*
	into InvoiceLines
from Chinook.dbo.InvoiceLine ;



select 
	*
	into Invoices
from Chinook.dbo.Invoice;


select 
*
into Employees
from Chinook.dbo.Employee;

select 
*
into Customers
from Chinook.dbo.Customer;
