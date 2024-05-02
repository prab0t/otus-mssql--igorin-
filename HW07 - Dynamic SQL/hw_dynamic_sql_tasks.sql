/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "07 - Динамический SQL".

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

Это задание из занятия "Операторы CROSS APPLY, PIVOT, UNPIVOT."
Нужно для него написать динамический PIVOT, отображающий результаты по всем клиентам.
Имя клиента указывать полностью из поля CustomerName.

Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+----------------+----------------------
InvoiceMonth | Aakriti Byrraju    | Abel Spirlea       | Abel Tatarescu | ... (другие клиенты)
-------------+--------------------+--------------------+----------------+----------------------
01.01.2013   |      3             |        1           |      4         | ...
01.02.2013   |      7             |        3           |      4         | ...
-------------+--------------------+--------------------+----------------+----------------------
*/

DECLARE 
	@Command NVARCHAR(MAX), 
	@Param NVARCHAR(MAX) = NULL

SELECT @Param = ISNULL(@Param + ', ', '') + QUOTENAME(CustomerName)
FROM 
	Sales.Invoices
	JOIN Sales.Customers ON Invoices.CustomerID = Customers.CustomerID
--	and Customers.CustomerID BETWEEN 2 AND 6 Не знаю нужно ли это условие брать. С данным условием также отрабатывает если взять клиентов с ID 2-6
GROUP BY CustomerName
ORDER BY CustomerName
--SELECT @Param
SET @Command = '
WITH Names AS(
	SELECT 
		[Names] = CustomerName,
		[Months] = DATEADD(MONTH, -1, DATEADD(DAY, 1, EOMONTH(Invoices.InvoiceDate))),
		InvoiceID
	FROM 
		Sales.Invoices
		JOIN Sales.Customers ON Invoices.CustomerID = Customers.CustomerID
)
select convert(varchar(10), [Months], 104),' + @Param + '
from Names
PIVOT (
count (InvoiceID)
for [Names]  
in (' + @Param + ') 
)
as PivotTable
Order By [Months] '

EXEC(@Command)
;

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