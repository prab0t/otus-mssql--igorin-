/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, GROUP BY, HAVING".

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
1. Посчитать среднюю цену товара, общую сумму продажи по месяцам.
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Средняя цена за месяц по всем товарам
* Общая сумма продаж за месяц

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

  SELECT YEAR (a.[OrderDate]) as 'Год', 
  MONTH (a.[OrderDate]) as 'Месяц',
  avg (b.UnitPrice) as 'Средняя цена товара',
  sum (b.UnitPrice*b.Quantity) as 'Сумма продаж за месяц'
  FROM [WideWorldImporters].[Sales].[Orders] a 
	INNER JOIN [WideWorldImporters].[Sales].[OrderLines] b
		 ON a.[OrderID] = b.[OrderID]
  Group By (YEAR (a.[OrderDate])), (MONTH (a.[OrderDate]))
  Order By (YEAR (a.[OrderDate])), (MONTH (a.[OrderDate]))

/*
2. Отобразить все месяцы, где общая сумма продаж превысила 4 600 000

Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

  SELECT 
  YEAR (a.[InvoiceDate]) as 'Год', 
  MONTH (a.[InvoiceDate]) as 'Месяц',
 -- avg (b.UnitPrice) as 'Средняя цена товара',
  sum (b.UnitPrice*b.Quantity) as 'Сумма продаж за месяц'
  FROM [Sales].[Invoices] a 
	INNER JOIN [Sales].[InvoiceLines] b
		ON b.[InvoiceID] = a.[InvoiceID]
  Group By YEAR (a.[InvoiceDate]), MONTH (a.[InvoiceDate])
  HAVING sum(b.UnitPrice*b.Quantity) > 4600000
  Order By (YEAR (a.[InvoiceDate])), (MONTH (a.[InvoiceDate]))

/*
3. Вывести сумму продаж, дату первой продажи
и количество проданного по месяцам, по товарам,
продажи которых менее 50 ед в месяц.
Группировка должна быть по году,  месяцу, товару.

Вывести:
* Год продажи
* Месяц продажи
* Наименование товара
* Сумма продаж
* Дата первой продажи
* Количество проданного

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

  SELECT 
  YEAR (a.[InvoiceDate]) as 'Год', 
  MONTH (a.[InvoiceDate]) as 'Месяц',
  b.StockItemID as 'ид товара',
  sum (b.UnitPrice*b.Quantity) as 'Сумма продаж за месяц', 
  sum (b.Quantity) as 'Количество проданного товара',
  min (a.[InvoiceDate]) as 'Дата первой продажи'
	FROM [WideWorldImporters].[Sales].[Invoices] a 
		INNER JOIN [WideWorldImporters].[Sales].[InvoiceLines] b
			ON a.[InvoiceID] = b.[InvoiceID]
  Group By (YEAR (a.[InvoiceDate])), (MONTH (a.[InvoiceDate])), b.StockItemID
  HAVING sum (b.Quantity) < 50
  Order By (YEAR (a.[InvoiceDate])), (MONTH (a.[InvoiceDate]))

-- ---------------------------------------------------------------------------
-- Опционально
-- ---------------------------------------------------------------------------
/*
Написать запросы 2-3 так, чтобы если в каком-то месяце не было продаж,
то этот месяц также отображался бы в результатах, но там были нули.
*/
