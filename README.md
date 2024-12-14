# 1. Project Overview
   
The objective of this project is to create a star/snowflake model data warehouse from the Chinook OLTP
database, in order to enable study of the data by business analysts, and create a sample report
demonstrating the functionality of the data warehouse in combination with a data analysis and
visualization tool such as Power BI.

# 2. Learning Outcomes
 
- Understand and implement the process of designing a DW, based on an existing OLTP
database.
- Implement ETL from an OLTP database to a data warehouse using SQL Server (Database
or SSIS).
- Understand the usefulness of a Data Warehouse in combination with an analytics tool.
- Implement basic reports using Power BI.

# 3. Project Steps
   
A. Data Warehouse Design
Create a DW to host the data found in the original Chinook OLTP database. The DW should
follow the star or snowflake schema principles.

B. Extract, Transform and Load Data
Create SQL scripts or an SSIS package to transfer data from the OLTP Chinook database to the
DW you created.

C. Create a Report
Create a report showcasing the basic functionality of your DW using Power BI. The report can
showcase any data you consider as the most useful from your DW. Optionally, you may also
include data from Part 2 of the project in your report, in addition to data from your DW, if you
believe they add useful context.

# 4. Deliverables
- A script to create the Data Warehouse.
- A script or SSIS package to load the DW from the OLTP database.
- A backup (.bak) of the final loaded DW.
- A Power BI report file (.pbix).
