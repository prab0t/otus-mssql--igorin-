/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "03 - Подзапросы, CTE, временные таблицы".

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
-- Для всех заданий, где возможно, сделайте два варианта запросов:
--  1) через вложенный запрос
--  2) через WITH (для производных таблиц)
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. 
Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
*/

SELECT AP.[PersonID],
AP.[FullName]
  FROM [WideWorldImporters].[Application].[People] AP
  WHERE 
  (AP.[IsSalesperson] = 1)
  and 
	 Not Exists 
	(select 1
	from [WideWorldImporters].[Sales].[Invoices] as I
	where (I.[InvoiceDate] = '2015-07-04') 
	and (AP.[PersonID] = i.[SalespersonPersonID])) 
/*
Через WITH
*/
; WITH TEST AS
	(SELECT AP.[PersonID], AP.[FullName]
		FROM [WideWorldImporters].[Application].[People] AP
			Left JOIN [WideWorldImporters].[Sales].[Invoices] as I
				on AP.[PersonID] = I.[SalespersonPersonID] and I.[InvoiceDate] = '2015-07-04'
		WHERE (AP.[IsSalesperson] = 1) and I.InvoiceID is null
	)
Select * from TEST


/*
2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена.
*/

DECLARE @MinPrice Decimal (18,2) = (select min ([UnitPrice])
  from [WideWorldImporters].[Warehouse].[StockItems])

SELECT SI.[StockItemID]
      ,SI.[StockItemName]
      ,SI.[UnitPrice]
  FROM [WideWorldImporters].[Warehouse].[StockItems] as SI
  WHERE @MinPrice = SI.[UnitPrice]
  go

/*
Через WITH Первый вариант
*/
; WITH TEST AS
 (
SELECT TOP (1)
	   SI.[StockItemID]
      ,SI.[StockItemName]
      ,SI.[UnitPrice]
  FROM [WideWorldImporters].[Warehouse].[StockItems] as SI
  Order By UnitPrice 
 )
SELECT * FROM TEST
go
/*
Второй вариант с WITH:
*/
; WITH TEST2 (a) AS
 (
select min([UnitPrice]) 
FROM [WideWorldImporters].[Warehouse].[StockItems]
 )
SELECT SI.[StockItemID], SI.[StockItemName], SI.[UnitPrice] FROM TEST2
JOIN [WideWorldImporters].[Warehouse].[StockItems] as SI
ON SI.UnitPrice = a
go

/*
3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей 
из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE). 
*/

SELECT C.CustomerID, C.CustomerName
  FROM [WideWorldImporters].[Sales].[Customers] as C
  WHERE C.[CustomerID] IN
(
SELECT TOP (5) 
      [CustomerID]
  FROM [WideWorldImporters].[Sales].[CustomerTransactions]
  Order by [AmountExcludingTax] desc
  )
/*
Через WITH
*/
;WITH TEST AS
(
SELECT TOP (5) 
      [CustomerID]
  FROM [WideWorldImporters].[Sales].[CustomerTransactions]
  Order by [AmountExcludingTax] desc
)
SELECT DISTINCT C.CustomerID, C.CustomerName FROM TEST
JOIN [WideWorldImporters].[Sales].[Customers] as C
ON TEST.CustomerID = C.CustomerID


/*
4. Выберите города (ид и название), в которые были доставлены товары, 
входящие в тройку самых дорогих товаров, а также имя сотрудника, 
который осуществлял упаковку заказов (PackedByPersonID).
*/

SELECT 
	CP.DeliveryCityID as 'Ид города',
	C.CityName as 'Название города',
	ISNULL(P.FullName, '--') as 'Сотрудник'
FROM 
	(SELECT DISTINCT C.DeliveryCityID, SO.PickedByPersonID
		FROM Sales.Orders AS SO
		JOIN Sales.Customers C ON C.CustomerID = SO.CustomerID
		WHERE SO.OrderId IN (
			SELECT OrderId 
				FROM (
					SELECT DISTINCT OrderID
						FROM Sales.OrderLines
						WHERE StockItemID IN (
							SELECT StockItemID 
								FROM (
									SELECT TOP (3) WITH TIES StockItemID
										FROM Warehouse.StockItems
										ORDER BY UnitPrice DESC
								) AS Items
						)
				    ) AS OrderIds
			)
	) AS CP	
	INNER JOIN Application.Cities AS C
		ON C.CityId = CP.DeliveryCityID
	LEFT JOIN Application.People P 
		ON P.PersonID = CP.PickedByPersonID
/*
Через WITH
*/
;WITH Items (StockItemID) AS (
	SELECT TOP (3) WITH TIES StockItemID
	FROM Warehouse.StockItems
	ORDER BY UnitPrice DESC
), 
OrderIds (OrderId) AS (
	SELECT DISTINCT OrderID
	FROM Sales.OrderLines
	WHERE StockItemID IN (SELECT StockItemID FROM Items)
), 
CP (CityID, PickerId) AS (
	SELECT DISTINCT C.DeliveryCityID, O.PickedByPersonID
	FROM 
		Sales.Orders AS O
		JOIN Sales.Customers C
			ON C.CustomerID = O.CustomerID
	WHERE O.OrderId IN (SELECT OrderId FROM OrderIds)
)

SELECT 
	CP.CityID AS 'Ид города',
	C.CityName AS 'Название города',
	ISNULL(p.FullName, '--') AS 'Сотрудник'
FROM 
	cp
	INNER JOIN Application.Cities AS C
		ON C.CityId = CP.CityID
	LEFT JOIN Application.People P 
		ON P.PersonID = CP.PickerId
;

-- ---------------------------------------------------------------------------
-- Опциональное задание
-- ---------------------------------------------------------------------------
-- Можно двигаться как в сторону улучшения читабельности запроса, 
-- так и в сторону упрощения плана\ускорения. 
-- Сравнить производительность запросов можно через SET STATISTICS IO, TIME ON. 
-- Если знакомы с планами запросов, то используйте их (тогда к решению также приложите планы). 
-- Напишите ваши рассуждения по поводу оптимизации. 

-- 5. Объясните, что делает и оптимизируйте запрос

SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	(SELECT People.FullName
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL	
				AND Orders.OrderId = Invoices.OrderId)	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
	JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
		ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC

-- --

