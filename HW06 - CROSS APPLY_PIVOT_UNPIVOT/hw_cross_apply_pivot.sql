/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "05 - Операторы CROSS APPLY, PIVOT, UNPIVOT".

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

/*
1. Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Клиентов взять с ID 2-6, это все подразделение Tailspin Toys.
Имя клиента нужно поменять так чтобы осталось только уточнение.
Например, исходное значение "Tailspin Toys (Gasport, NY)" - вы выводите только "Gasport, NY".
Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+-------------+--------------+------------
InvoiceMonth | Peeples Valley, AZ | Medicine Lodge, KS | Gasport, NY | Sylvanite, MT | Jessie, ND
-------------+--------------------+--------------------+-------------+--------------+------------
01.01.2013   |      3             |        1           |      4      |      2        |     2
01.02.2013   |      7             |        3           |      4      |      2        |     1
-------------+--------------------+--------------------+-------------+--------------+------------
*/
WITH Names AS(
	SELECT 
		[Names] = SUBSTRING(CustomerName, CHARINDEX('(', CustomerName) + 1, LEN(CustomerName) - CHARINDEX('(', CustomerName) - 1), --берем сокр имя
		--CustomerName,
		[Months] = DATEADD(MONTH, -1, DATEADD(DAY, 1, EOMONTH(Invoices.InvoiceDate))), --начало месяц
		InvoiceID
	FROM 
		Sales.Invoices
		JOIN Sales.Customers ON Invoices.CustomerID = Customers.CustomerID
	WHERE Customers.CustomerID BETWEEN 2 AND 6
)

select convert(varchar, [Months], 104),
[Peeples Valley, AZ],[Medicine Lodge, KS],[Gasport, NY],[Sylvanite, MT],[Jessie, ND]
from
(select [Names],[Months],InvoiceID from Names) --то как выглядит исходный набор данных
as SourceTable
pivot
(
count (InvoiceID)
for [Names]  --в этой колонке из SourceTable ищем названия колонок для будущей развернутой таблицы
in ([Peeples Valley, AZ],[Medicine Lodge, KS],[Jessie, ND],[Gasport, NY],[Sylvanite, MT]) --только эти названия колонок для будущей развернутой таблицы берем из строк в колонке 
)
as PivotTable
Order By [Months]

/*
select year(@dt) as [Год]  
	, [Месяц] = month(@dt)
	, datepart(quarter, @dt) as 'Квартал'
	, datename(month, @dt) as "Месяц "
	, FORMAT(@dt, 'MMMM', 'ru-ru') as [Месяц Ru]
	, FORMAT(@dt, 'D', 'ru-ru') as 'Russian'
	, FORMAT(@dt, 'D', 'en-US' ) 'US English'  
	, convert(varchar, @dt, 104) as [Дата] 
	, datetrunc(month, @dt) as begin_of_month  --c SQL2022
	, eomonth(@dt) as end_of_month
*/
/*
2. Для всех клиентов с именем, в котором есть "Tailspin Toys"
вывести все адреса, которые есть в таблице, в одной колонке.

Пример результата:
----------------------------+--------------------
CustomerName                | AddressLine
----------------------------+--------------------
Tailspin Toys (Head Office) | Shop 38
Tailspin Toys (Head Office) | 1877 Mittal Road
Tailspin Toys (Head Office) | PO Box 8975
Tailspin Toys (Head Office) | Ribeiroville
----------------------------+--------------------
*/

;WITH Names AS(
	SELECT 
		CustomerName,
		DeliveryAddressLine1, DeliveryAddressLine2
	FROM 
		Sales.Customers
	WHERE Customers.CustomerName like ('%Tailspin Toys%') 
)

select 	CustomerName, Addresline
from
(select CustomerName,DeliveryAddressLine1, DeliveryAddressLine2 from Names) --то как выглядит исходный набор данных
as SourceTable
unpivot
(
Addresline
for Addrestype  --в этой колонке из SourceTable ищем названия колонок для будущей развернутой таблицы
in (DeliveryAddressLine1,DeliveryAddressLine2) --только эти названия колонок для будущей развернутой таблицы берем из строк в колонке 
)
as unPivotTable
Order By CustomerName, Addresline

/*
3. В таблице стран (Application.Countries) есть поля с цифровым кодом страны и с буквенным.
Сделайте выборку ИД страны, названия и ее кода так, 
чтобы в поле с кодом был либо цифровой либо буквенный код.

Пример результата:
--------------------------------
CountryId | CountryName | Code
----------+-------------+-------
1         | Afghanistan | AFG
1         | Afghanistan | 4
3         | Albania     | ALB
3         | Albania     | 8
----------+-------------+-------
*/

;WITH Country AS(
	SELECT 
		[CountryID],
		[CountryName],
		CONVERT(NVARCHAR(20), IsoNumericCode) AS IsoNumericCode,
		CONVERT(NVARCHAR(20), IsoAlpha3Code) AS IsoAlpha3Code
	FROM 
		[Application].[Countries]
)
select [CountryID],[CountryName],Code
from
(select [CountryID],[CountryName],[IsoAlpha3Code]
      ,[IsoNumericCode] from Country) --то как выглядит исходный набор данных
as SourceTable
unpivot
(
Code
for Code2  --в этой колонке из SourceTable ищем названия колонок для будущей развернутой таблицы
in ([IsoAlpha3Code],[IsoNumericCode]) --только эти названия колонок для будущей развернутой таблицы берем из строк в колонке 
)
as unPivotTable

/*
4. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

SELECT DISTINCT
	SI.CustomerID,
	Customers.CustomerName,
	SIL.StockItemID,
	SIL.UnitPrice,
	SI.InvoiceDate
FROM 
	Sales.Invoices SI
	JOIN Sales.InvoiceLines SIL ON SIL.InvoiceID = SI.InvoiceID
	JOIN Sales.Customers ON Customers.CustomerID = SI.CustomerID
	CROSS APPLY 
	(SELECT DISTINCT TOP (2) WITH TIES InvoiceLines.StockItemID,InvoiceLines.UnitPrice	--добавил with ties	
		FROM 
			Sales.Invoices
			JOIN Sales.InvoiceLines ON InvoiceLines.InvoiceID = Invoices.InvoiceID
		WHERE Invoices.CustomerID = SI.CustomerID
		ORDER BY InvoiceLines.UnitPrice DESC
			) as SI2
WHERE 
	SI2.StockItemID = SIL.StockItemID
ORDER BY 
	SI.CustomerID,
	SIL.UnitPrice
;
