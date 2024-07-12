exec sp_configure 'clr enabled', 1;  
--внес праки по запятой в функции
exec sp_configure 'clr strict security', 0;  
GO 
RECONFIGURE;  

ALTER DATABASE WideWorldImporters SET TRUSTWORTHY ON;

CREATE ASSEMBLY CLRFunctions FROM 'C:\SQLServerCLRSortString2.dll'  
WITH PERMISSION_SET = SAFE;
GO 

CREATE FUNCTION dbo.SortString    
(    
 @name AS NVARCHAR(255)    
)     
RETURNS NVARCHAR(255)    
AS EXTERNAL NAME CLRFunctions.CLRFunctions.SortString 
GO 

select * from sys.assemblies

CREATE TABLE testSort (data VARCHAR(255)) 
GO

INSERT INTO testSort VALUES('apple,pear,orange,banana,grape,kiwi') 
INSERT INTO testSort VALUES('pineapple,grape,banana,apple') 
INSERT INTO testSort VALUES('apricot,pear,strawberry,banana') 
INSERT INTO testSort VALUES('cherry,watermelon,orange,melon,grape') 

SELECT data, dbo.sortString(data) as sorted FROM testSort 


DROP FUNCTION dbo.SortString  
GO 
DROP ASSEMBLY CLRFunctions 
GO 
DROP TABLE testSort 
GO 