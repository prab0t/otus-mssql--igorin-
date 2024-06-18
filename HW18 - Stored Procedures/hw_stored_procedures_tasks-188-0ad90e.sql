/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "12 - Хранимые процедуры, функции, триггеры, курсоры".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

USE WideWorldImporters

/*
Во всех заданиях написать хранимую процедуру / функцию и продемонстрировать ее использование.
*/

/*
1) Написать функцию возвращающую Клиента с наибольшей суммой покупки.
*/

IF OBJECT_ID ('dbo.Getust') IS NOT NULL
    DROP FUNCTION dbo.Getust;

CREATE or ALTER FUNCTION dbo.Getust ()
Returns Int
AS
BEGIN
Declare @Result int
; WITH Inv AS
  (SELECT TOP (1) InvoiceID as invoice_id,
  sum (Unitprice * quantity) as price
  FROM [WideWorldImporters].[Sales].[InvoiceLines] 
  Group By InvoiceID
  Order By price desc
  )
  Select @Result = SI.CustomerId
  From [WideWorldImporters].[Sales].[Invoices] SI
  Inner Join Inv 
  On Inv.invoice_id = SI.InvoiceID 

  Return @Result;
  END;

SELECT [dbo].[Getust] ()
GO

/*
2) Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту.
Использовать таблицы :
Sales.Customers
Sales.Invoices
Sales.InvoiceLines
*/

CREATE or ALTER Procedure SumProc @CustID INT
AS
BEGIN

	Select sum (SIL.Unitprice * SIL.quantity)
	From [WideWorldImporters].[Sales].[InvoiceLines] SIL
	Inner Join [WideWorldImporters].[Sales].[Invoices] SI
	ON SI.InvoiceID = SIL.InvoiceID
	and SI.CustomerID = @CustID
  END;

DECLARE @CustID2 INT = 9;
Exec SumProc @CustID2;

/*
3) Создать одинаковую функцию и хранимую процедуру, посмотреть в чем разница в производительности и почему.
*/
-- Переписал задание 2 как функцию для примера.
CREATE or ALTER Function dbo.SumFunct (@CustomerId int)
Returns INT
AS
BEGIN
	Return (Select sum (SIL.Unitprice * SIL.quantity)
	From [WideWorldImporters].[Sales].[InvoiceLines] SIL
	Inner Join [WideWorldImporters].[Sales].[Invoices] SI
	ON SI.InvoiceID = SIL.InvoiceID
	and SI.CustomerID = @CustomerId)
  END;

--выполнение функции и процедуры
SET STATISTICS TIME ON
DECLARE @CustID2 INT = 9;
Exec SumProc @CustID2;
SELECT dbo.SumFunct (@CustID2)
GO

--Процедура - Время ЦП = 0 мс, истекшее время = 12 мс.
--Функция - Время ЦП = 0 мс, затраченное время = 6 мс.
--функция имеет больше ограничений, но для простых запросов вдиимо работает быстрее
/*
4) Создайте табличную функцию покажите как ее можно вызвать для каждой строки result set'а без использования цикла. 
*/

CREATE OR ALTER FUNCTION CustSum 
(	
    @CustomerID INT
)
RETURNS TABLE 
AS
RETURN 
(
    SELECT 
        [Total] = SUM (SIL.Quantity * SIL.UnitPrice) 
    FROM 
        [Sales].[Invoices]
        JOIN [Sales].[InvoiceLines] SIL WITH (NOLOCK) 
            ON SIL.InvoiceID = [Invoices].InvoiceID
    WHERE [Invoices].CustomerID = @CustomerID
)
GO

SELECT 
    Customers.CustomerName,
    CustomerSum.Total
FROM 
    Sales.Customers
    CROSS APPLY dbo.CustSum ([Customers].CustomerID) AS CustomerSum

/*
5) Опционально. Во всех процедурах укажите какой уровень изоляции транзакций вы бы использовали и почему. 
*/
