/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, JOIN".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД WideWorldImporters можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/

SELECT [StockItemID] as 'ИД товара'
      ,[StockItemName] as 'Название товара'
  FROM [WideWorldImporters].[Warehouse].[StockItems]
  WHERE [StockItemName] like '%urgent%' or [StockItemName] like 'Animal%'

/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/

SELECT PS.SupplierID as 'ИД поставщика', PS.SupplierName 'Наименование поставщика'
  FROM [WideWorldImporters].[Purchasing].[Suppliers] PS
	left JOIN [WideWorldImporters].[Purchasing].[PurchaseOrders] PP
	ON PS.SupplierID = PP.SupplierID
  WHERE PP.SupplierID is NULL

/*
3. Заказы (Orders) с ценой товара (UnitPrice) более 100$ 
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
* название месяца, в котором был сделан заказ
* номер квартала, в котором был сделан заказ
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.

Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).

Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/

--Первый вариант 

SELECT 
SO.OrderID ,
convert(varchar, SO.OrderDate, 104) as dd_mm_year,
FORMAT(SO.OrderDate, 'MMMM', 'ru-ru') as Month,
datepart(quarter, SO.OrderDate) AS Quarter,
CEILING(
    DATEPART(MONTH, SO.OrderDate) / 4.
  ) AS ThirdYear,
SC.CustomerName 
	FROM [WideWorldImporters].[Sales].[Orders] SO
		INNER Join [WideWorldImporters].[Sales].[OrderLines] OL
			ON SO.OrderID = OL.OrderID
			and (OL.[UnitPrice] > 100 or OL.[Quantity]>20)
			and NOT OL.[PickingCompletedWhen] is NULL
		INNER JOIN [WideWorldImporters].[Sales].[Customers] SC
			ON SO.CustomerID = SC.CustomerID
	ORDER BY Quarter, ThirdYear, SO.OrderDate

-- Второй вариант
SELECT 
SO.OrderID ,
convert(varchar, SO.OrderDate, 104) as dd_mm_year,
FORMAT(SO.OrderDate, 'MMMM', 'ru-ru') as Month,
datepart(quarter, SO.OrderDate) AS Quarter,
CEILING(
    DATEPART(MONTH, SO.OrderDate) / 4.
  ) AS ThirdYear,
SC.CustomerName 
	FROM [WideWorldImporters].[Sales].[Orders] SO
		INNER Join [WideWorldImporters].[Sales].[OrderLines] OL
			ON SO.OrderID = OL.OrderID
			and (OL.[UnitPrice] > 100 or OL.[Quantity]>20)
			and NOT OL.[PickingCompletedWhen] is NULL
		INNER JOIN [WideWorldImporters].[Sales].[Customers] SC
			ON SO.CustomerID = SC.CustomerID
	ORDER BY Quarter, ThirdYear, SO.OrderDate
OFFSET 1000 ROWS FETCH FIRST 100 ROWS ONLY


/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)

Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

SELECT 
AD.[DeliveryMethodName] AS 'Способ доставки',
PO.[ExpectedDeliveryDate] AS 'Дата доставки',
PS.[SupplierName] AS 'Имя поставщика',
AP.[FullName] AS 'Имя контактного лица принимавшего заказ'
	FROM [WideWorldImporters].[Purchasing].[Suppliers] PS
		JOIN [WideWorldImporters].[Purchasing].[PurchaseOrders] PO
			ON PS.[SupplierID] = PO.[SupplierID] 
			and PO.[IsOrderFinalized] = 1
			and PO.[ExpectedDeliveryDate] BETWEEN '2013-01-01' and '2013-01-31'
			JOIN [WideWorldImporters].[Application].[People] AP
			ON AP.[PersonID] = PO.[ContactPersonID]
		JOIN [WideWorldImporters].[Application].[DeliveryMethods] AD
			ON PS.[DeliveryMethodID] = AD.[DeliveryMethodID] 
			and	AD.[DeliveryMethodName] IN ('Air Freight','Refrigerated Air Freight') 


/*
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/
SELECT TOP 10
       SI.[InvoiceID] AS 'Заказ на продажу'
	  ,SI.[InvoiceDate] AS 'Дата подажи'
	  ,SC.[CustomerName] AS 'Имя клиента'
	  ,AP.[FullName] AS 'Имя сотрудника'
  FROM [WideWorldImporters].[Sales].[Invoices] SI
  Join [WideWorldImporters].[Sales].[Customers] SC
  ON SI.[CustomerID] = SC.[CustomerID]
  Join [WideWorldImporters].[Application].[People] AP
  ON SI.[SalespersonPersonID] = AP.[PersonID]
  Order By SI.[InvoiceDate] DESC


/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
*/

SELECT DISTINCT
	SO.[CustomerID] AS 'ИД клиента'
	,SC.[CustomerName] AS 'Имя клиента'
	,SC.[PhoneNumber] AS 'Номер клиента'
	,OL.[Description] AS 'Товар'
	FROM [WideWorldImporters].[Sales].[Orders] SO
		INNER JOIN [WideWorldImporters].[Sales].[OrderLines] OL
			ON SO.OrderID = OL.OrderID 
		INNER JOIN [WideWorldImporters].[Warehouse].[StockItems] SI
			ON SI.[StockItemID] = OL.[StockItemID]
			and OL.[Description] = 'Chocolate frogs 250g'
		INNER JOIN [WideWorldImporters].[Sales].[Customers] SC
			ON SO.[CustomerID] = SC.[CustomerID]
			

