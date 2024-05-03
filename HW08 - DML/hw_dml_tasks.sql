/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "10 - Операторы изменения данных".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Довставлять в базу пять записей используя insert в таблицу Customers или Suppliers 
*/
	INSERT INTO [Sales].[Customers]
    ( --[CustomerID]
      [CustomerName]
      ,[BillToCustomerID]
      ,[CustomerCategoryID]
      ,[BuyingGroupID]
      ,[PrimaryContactPersonID]
      ,[AlternateContactPersonID]
      ,[DeliveryMethodID]
      ,[DeliveryCityID]
      ,[PostalCityID]
      ,[CreditLimit]
      ,[AccountOpenedDate]
      ,[StandardDiscountPercentage]
      ,[IsStatementSent]
      ,[IsOnCreditHold]
      ,[PaymentDays]
      ,[PhoneNumber]
      ,[FaxNumber]
      ,[DeliveryRun]
      ,[RunPosition]
      ,[WebsiteURL]
      ,[DeliveryAddressLine1]
      ,[DeliveryAddressLine2]
      ,[DeliveryPostalCode]
      ,[DeliveryLocation]
      ,[PostalAddressLine1]
      ,[PostalAddressLine2]
      ,[PostalPostalCode]
      ,[LastEditedBy])
	SELECT TOP (5) 
	 --  [CustomerID] = NEXT VALUE FOR Sequences.[CustomerID]
      [CustomerName] = 'TEST_' + [CustomerName]
      ,[BillToCustomerID]
      ,[CustomerCategoryID]
      ,[BuyingGroupID]
      ,[PrimaryContactPersonID]
      ,[AlternateContactPersonID]
      ,[DeliveryMethodID]
      ,[DeliveryCityID]
      ,[PostalCityID]
      ,[CreditLimit]
      ,[AccountOpenedDate]
      ,[StandardDiscountPercentage]
      ,[IsStatementSent]
      ,[IsOnCreditHold]
      ,[PaymentDays]
      ,[PhoneNumber]
      ,[FaxNumber]
      ,[DeliveryRun]
      ,[RunPosition]
      ,[WebsiteURL]
      ,[DeliveryAddressLine1]
      ,[DeliveryAddressLine2]
      ,[DeliveryPostalCode]
      ,[DeliveryLocation]
      ,[PostalAddressLine1]
      ,[PostalAddressLine2]
      ,[PostalPostalCode]
      ,[LastEditedBy]
  FROM [Sales].[Customers]
  Order by [CustomerID] desc

Select *
  FROM [Sales].[Customers]
  Order by [CustomerID] desc

/*
VALUES
    ( NEXT VALUE FOR Sequences.[CustomerID]
    , 'ZZZ_' + CONVERT(NVARCHAR(20), [CustomerID])
    , 1
    , 3
    , 1
    , 1001
	, 1002
    , 3
    , 19586
    , 19586
    , GETDATE()
    , 0
	, 0
	, 0
	, 7
	, '(308) 555-0100'
	, '(308) 555-0100'
	, 'http://www.tailspintoys.com'
	, 'Shop 38'
	, '1877 Mittal Road'
	, '90410'
	, DEFAULT
	, 'PO Box 8975'
	, 'Ribeiroville'
	, 90410
	, 1);
	--, GETDATE()
	--, 9999-12-31);
*/

/*
2. Удалите одну запись из Customers, которая была вами добавлена
*/

DELETE TOP (1) FROM [Sales].[Customers]
WHERE [CustomerName] like 'Test%'

Select *
FROM [Sales].[Customers]
WHERE [CustomerName] like 'Test%'


/*
3. Изменить одну запись, из добавленных через UPDATE
*/

UPDATE  TOP (1) [Sales].[Customers]
SET [CustomerName] = '2Test'
WHERE [CustomerName] like 'Test%'

Select *
FROM [Sales].[Customers]
WHERE [CustomerName] like '%Test%'

/*
4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть
*/
-- перед выполнением данного шага необходимо сгенерировать новых клиентов. Выполнить задания 1-3
-- данное задание наверное можно было бы выполнить более фективно, я решил тут все сразу попробовать, по экспериментировать. 

SELECT TOP (4) * INTO SourceTable --создаем копию таблицу для копирования
FROM [Sales].[Customers]
Order By [CustomerID] desc;

Select *
from SourceTable

DELETE TOP (2) FROM SourceTable --оставляем 2 записи в таблице для вставки
WHERE [CustomerName] like 'Test%'; 

Select *
from SourceTable

UPDATE TOP (1)  SourceTable --обновляем одну из записей
SET [CustomerName] = 'Test obn'
WHERE [CustomerName] like 'Test%';

DELETE FROM [Sales].[Customers] --удаляем из основной таблице запись для проверки вставки
WHERE [CustomerName] = '2Test';

Select *
FROM SourceTable

Select *
FROM [Sales].[Customers]
ORDER BY [CustomerID] DESC

MERGE [Sales].[Customers] AS Cust
USING SourceTable AS SourceT
    ON (Cust.[CustomerID] = SourceT.[CustomerID])
WHEN MATCHED 
    THEN UPDATE 
        SET Cust.[CustomerName] = SourceT.[CustomerName]
WHEN NOT MATCHED 
    THEN INSERT 
	(
			[CustomerName]
           ,[BillToCustomerID]
           ,[CustomerCategoryID]
           ,[BuyingGroupID]
           ,[PrimaryContactPersonID]
           ,[AlternateContactPersonID]
           ,[DeliveryMethodID]
           ,[DeliveryCityID]
           ,[PostalCityID]
           ,[CreditLimit]
           ,[AccountOpenedDate]
           ,[StandardDiscountPercentage]
           ,[IsStatementSent]
           ,[IsOnCreditHold]
           ,[PaymentDays]
           ,[PhoneNumber]
           ,[FaxNumber]
           ,[DeliveryRun]
           ,[RunPosition]
           ,[WebsiteURL]
           ,[DeliveryAddressLine1]
           ,[DeliveryAddressLine2]
           ,[DeliveryPostalCode]
           ,[DeliveryLocation]
           ,[PostalAddressLine1]
           ,[PostalAddressLine2]
           ,[PostalPostalCode]
           ,[LastEditedBy] )
        VALUES (
       SourceT.[CustomerName] 
      ,SourceT.[BillToCustomerID]
      ,SourceT.[CustomerCategoryID]
      ,SourceT.[BuyingGroupID]
      ,SourceT.[PrimaryContactPersonID]
      ,SourceT.[AlternateContactPersonID]
      ,SourceT.[DeliveryMethodID]
      ,SourceT.[DeliveryCityID]
      ,SourceT.[PostalCityID]
      ,SourceT.[CreditLimit]
      ,SourceT.[AccountOpenedDate]
      ,SourceT.[StandardDiscountPercentage]
      ,SourceT.[IsStatementSent]
      ,SourceT.[IsOnCreditHold]
      ,SourceT.[PaymentDays]
      ,SourceT.[PhoneNumber]
      ,SourceT.[FaxNumber]
      ,SourceT.[DeliveryRun]
      ,SourceT.[RunPosition]
      ,SourceT.[WebsiteURL]
      ,SourceT.[DeliveryAddressLine1]
      ,SourceT.[DeliveryAddressLine2]
      ,SourceT.[DeliveryPostalCode]
      ,SourceT.[DeliveryLocation]
      ,SourceT.[PostalAddressLine1]
      ,SourceT.[PostalAddressLine2]
      ,SourceT.[PostalPostalCode]
      ,SourceT.[LastEditedBy]
		)
	OUTPUT deleted.*, $action, inserted.*;

DROP TABLE if Exists SourceTable --зачищаем таблицу
/*
5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bcp in
*/

EXEC sp_configure 'show advanced options', 1;  
GO  
-- To update the currently configured value for advanced options.  
RECONFIGURE;  
GO  
-- To enable the feature.  
EXEC sp_configure 'xp_cmdshell', 1;  
GO  
-- To update the currently configured value for this feature.  
RECONFIGURE;  
GO  

--выгрузка
DROP TABLE IF EXISTS [Sales].[Customers_demo]
SELECT TOP 10 [CustomerID], [CustomerName] INTO Sales.Customers_demo
FROM Sales.Customers;

DECLARE @bcp VARCHAR(500) = 'bcp'
SET @bcp += ' "WideWorldImporters.Sales.Customers_demo"'
SET @bcp += ' out "C:\Demo\demo.txt" -T -w -t"@" -S ' + @@SERVERNAME

exec master..xp_cmdshell @bcp;
--загрузка
DELETE FROM [Sales].[Customers_demo];

BULK INSERT [WideWorldImporters].[Sales].[Customers_demo]
        FROM "C:\Demo\demo.txt"
		WITH 
            (
                DATAFILETYPE = 'widechar',
                FIELDTERMINATOR = '@'  
                );

SELECT * FROM [Sales].[Customers_demo]
DROP TABLE IF EXISTS [Sales].[Customers_demo]