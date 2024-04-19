/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "06 - Оконные функции".

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
1. Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года 
(в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки).
Выведите: id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом

Пример:
-------------+----------------------------
Дата продажи | Нарастающий итог по месяцу
-------------+----------------------------
 2015-01-29   | 4801725.31
 2015-01-30	 | 4801725.31
 2015-01-31	 | 4801725.31
 2015-02-01	 | 9626342.98
 2015-02-02	 | 9626342.98
 2015-02-03	 | 9626342.98
Продажи можно взять из таблицы Invoices.
Нарастающий итог должен быть без оконной функции.
*/
set statistics time, io on
;WITH InvoiceSUM AS
(
SELECT [InvoiceID] InvID, SUM ([Quantity] * [UnitPrice]) as InvoiceSum
FROM [WideWorldImporters].[Sales].[InvoiceLines]
Group By [InvoiceID]
--Order By [InvoiceID]
),
InvoiceDate AS
(
SELECT EOMONTH (SI.[InvoiceDate]) InvDate,
SUM (InvoiceSum) InvoiceSum2
  FROM [WideWorldImporters].[Sales].[Invoices] SI
JOIN InvoiceSUM on SI.[InvoiceID] = InvID
WHERE SI.[InvoiceDate] >= '2015-01-01'
Group By EOMONTH (SI.[InvoiceDate])
),
MonthAmount AS (
	SELECT 
		a.InvDate,
		SUM(b.InvoiceSum2) AS MonthSum
	FROM 
		InvoiceDate a
		JOIN InvoiceDate b ON b.InvDate <= a.InvDate
	GROUP BY a.InvDate)

Select InvID, SC.CustomerName, SI.InvoiceDate, InvoiceSum, MonthAmount.MonthSum
From [WideWorldImporters].[Sales].[Invoices] SI
JOIN InvoiceSUM ON SI.InvoiceID = InvID
JOIN MonthAmount ON EOMONTH(SI.InvoiceDate) = MonthAmount.InvDate
JOIN [WideWorldImporters].[Sales].[Customers] SC ON SI.CustomerID = SC.CustomerID
Order By InvID



/*
2. Сделайте расчет суммы нарастающим итогом в предыдущем запросе с помощью оконной функции.
   Сравните производительность запросов 1 и 2 с помощью set statistics time, io on
*/
set statistics time, io on
;WITH InvoiceSUM AS
(
SELECT [InvoiceID] InvID, SUM ([Quantity] * [UnitPrice]) as InvoiceSum
FROM [WideWorldImporters].[Sales].[InvoiceLines]
Group By [InvoiceID]
--Order By [InvoiceID]
)
Select InvID, SC.CustomerName, SI.InvoiceDate, InvoiceSum, SUM(InvoiceSum) OVER(ORDER BY EOMONTH(SI.InvoiceDate)) CumulativeSum
From [WideWorldImporters].[Sales].[Invoices] SI
JOIN InvoiceSUM ON SI.InvoiceID = InvID
JOIN [WideWorldImporters].[Sales].[Customers] SC ON SI.CustomerID = SC.CustomerID
WHERE SI.[InvoiceDate] >= '2015-01-01'
Order By InvID

/*
Запуск без окон. функции (пример 1)
 Время работы SQL Server:
   Время ЦП = 110 мс, затраченное время = 330 мс.
Completion time: 2024-04-19T12:16:48.0651104+05:00

Запуск с окон. функцией (пример 2)
 Время работы SQL Server:
   Время ЦП = 47 мс, затраченное время = 227 мс.
Completion time: 2024-04-19T12:17:40.5695761+05:00

*/
/*
3. Вывести список 2х самых популярных продуктов (по количеству проданных) 
в каждом месяце за 2016 год (по 2 самых популярных продукта в каждом месяце).
*/

WITH Product AS
(
SELECT
[DateEND] = EOMONTH(SI.InvoiceDate),
sum (IL.Quantity) QTY,
ROW_NUMBER() OVER (PARTITION BY EOMONTH(SI.InvoiceDate) ORDER BY SUM(IL.Quantity) DESC) RowNumber,
StockItems.StockItemName ItemName
FROM [Sales].[InvoiceLines] IL
JOIN [Sales].[Invoices] SI ON IL.InvoiceID = SI.InvoiceID
JOIN [Warehouse].[StockItems] ON StockItems.StockItemID = IL.StockItemID
WHERE SI.InvoiceDate BETWEEN '2016-01-01' and '2016-12-31'
GROUP BY EOMONTH(SI.InvoiceDate), StockItems.StockItemName
--Order By EOMONTH(SI.InvoiceDate), sum (IL.Quantity) desc
)
SELECT 
[DateEND], QTY, ItemName
FROM Product
WHERE RowNumber < 3
ORDER BY [DateEND], RowNumber

/*
4. Функции одним запросом
Посчитайте по таблице товаров (в вывод также должен попасть ид товара, название, брэнд и цена):
* пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
* посчитайте общее количество товаров и выведете полем в этом же запросе
* посчитайте общее количество товаров в зависимости от первой буквы названия товара
* отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
* предыдущий ид товара с тем же порядком отображения (по имени)
* названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
* сформируйте 30 групп товаров по полю вес товара на 1 шт

Для этой задачи НЕ нужно писать аналог без аналитических функций.
*/

SELECT 
	StockItemID, 
	StockItemName, 
	Brand, 
	UnitPrice,
	ROW_NUMBER() OVER(PARTITION BY LEFT(StockItemName, 1) ORDER BY StockItemName) row_n,
	COUNT (QuantityPerOuter) OVER() stock,
	COUNT (QuantityPerOuter) OVER(PARTITION BY LEFT(StockItemName, 1)) stock2,
	lead(StockItemID) over (ORDER BY StockItemName) next_id_item,
	lag(StockItemID) over (ORDER BY StockItemName) pr_id_item,
	lag(StockItemName,2, 'No items') over (ORDER BY StockItemName) pr_item_2,
	ntile(30) over (order by TypicalWeightPerUnit) Weight_item
FROM 
	Warehouse.StockItems
ORDER BY 
	StockItemName

/*
5. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал.
   В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки.
*/

SELECT TOP(1) WITH TIES 
	People.PersonID, 
	People.FullName, 
	Customers.CustomerID, 
	Customers.CustomerName, 
	Invoices.InvoiceDate, 
	SUM (InvoiceLines.Quantity * InvoiceLines.UnitPrice)  OVER(PARTITION BY Invoices.InvoiceID) SummInv
FROM 
	Sales.Invoices
	INNER JOIN Sales.Customers ON Customers.CustomerID = Invoices.CustomerID
	INNER JOIN Sales.InvoiceLines ON InvoiceLines.InvoiceID = Invoices.InvoiceID
	INNER JOIN Application.People ON People.PersonID = Invoices.SalespersonPersonID 
ORDER BY 
ROW_NUMBER() OVER(PARTITION BY Invoices.SalespersonPersonID ORDER BY InvoiceDate DESC)

/*
6. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/
WITH Cust AS 
(
	SELECT 
		Customers.CustomerID,
		Customers.CustomerName,
		StockItemID,
		UnitPrice,
		Invoices.InvoiceDate, 
		DENSE_RANK() OVER(PARTITION BY Customers.CustomerID ORDER BY UnitPrice DESC) DenseRank
	FROM 
		Sales.Invoices
		JOIN Sales.Customers ON Customers.CustomerID = Invoices.CustomerID
		JOIN Sales.InvoiceLines ON InvoiceLines.InvoiceID = Invoices.InvoiceID
)
SELECT DISTINCT
	CustomerID,
	CustomerName,
	StockItemID,
	UnitPrice,
	InvoiceDate 
FROM 
	Cust
WHERE DenseRank < 3
Order By CustomerID

