use WideWorldImporters

--Файловая группа
alter database WideWorldImporters add filegroup YearData
go

--добавляем пустой файл 
alter database WideWorldImporters 
	add file (name = N'Years', filename = N'C:\Yeardata.ndf') 
	to filegroup YearData
go


--создаем функцию партиционирования по годам
create partition function fnYearPartition(date)  -- тип данных тип InvoiceDate
	as range right -- куда войдет граница (по умолчанию left)
	for values ('20160101','20170101','20180101','20190101','20200101', '20210101',
 '20220101', '20230101', '20240101') -- границы
go

-- схема секционирования
create partition scheme [schmYearPartition] AS PARTITION [fnYearPartition] 
ALL TO ([YearData])
GO

SELECT count(*) 
FROM Sales.Invoices;

--создадим секционированные таблицы
select * into Sales.InvoicesPartitioned
from Sales.Invoices;

--запускаем созданный скрипт по секционированию 

USE [WideWorldImporters]
GO
BEGIN TRANSACTION
CREATE CLUSTERED INDEX [ClusteredIndex] ON [Sales].[InvoicesPartitioned]
(
	[InvoiceDate]
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [schmYearPartition]([InvoiceDate])


DROP INDEX [ClusteredIndex] ON [Sales].[InvoicesPartitioned]

COMMIT TRANSACTION

--смотрим какие таблицы у нас партиционированы
select distinct t.name
from sys.partitions p
inner join sys.tables t
	on p.object_id = t.object_id
where p.partition_number <> 1

--смотрим как по диапазонам попали наши данные
SELECT  $PARTITION.fnYearPartition(InvoiceDate) AS Partition
		,COUNT(*) AS [COUNT] 
		,MIN(InvoiceDate) AS 'MINDATA'
		,MAX(InvoiceDate) AS 'MAXDATA'
FROM Sales.InvoicesPartitioned
GROUP BY $PARTITION.fnYearPartition(InvoiceDate) 
ORDER BY Partition ; 

--получил данные
-- 1	61320	2013-01-01	2015-12-31
-- 2	9190	2016-01-01	2016-05-31

--разделим 1 секцию на 2

Alter Partition Function fnYearPartition() SPLIT RANGE ('20140101');
--смотрим как по диапазонам попали наши данные
SELECT  $PARTITION.fnYearPartition(InvoiceDate) AS Partition
		,COUNT(*) AS [COUNT] 
		,MIN(InvoiceDate) AS 'MINDATA'
		,MAX(InvoiceDate) AS 'MAXDATA'
FROM Sales.InvoicesPartitioned
GROUP BY $PARTITION.fnYearPartition(InvoiceDate) 
ORDER BY Partition ; 

--получил данные
--1	18767	2013-01-01	2013-12-31
--2	42553	2014-01-01	2015-12-31
--3	9190	2016-01-01	2016-05-31
