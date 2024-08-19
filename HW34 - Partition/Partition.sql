use WideWorldImporters

--�������� ������
alter database WideWorldImporters add filegroup YearData
go

--��������� ������ ���� 
alter database WideWorldImporters 
	add file (name = N'Years', filename = N'C:\Yeardata.ndf') 
	to filegroup YearData
go


--������� ������� ����������������� �� �����
create partition function fnYearPartition(date)  -- ��� ������ ��� InvoiceDate
	as range right -- ���� ������ ������� (�� ��������� left)
	for values ('20160101','20170101','20180101','20190101','20200101', '20210101',
 '20220101', '20230101', '20240101') -- �������
go

-- ����� ���������������
create partition scheme [schmYearPartition] AS PARTITION [fnYearPartition] 
ALL TO ([YearData])
GO

SELECT count(*) 
FROM Sales.Invoices;

--�������� ���������������� �������
select * into Sales.InvoicesPartitioned
from Sales.Invoices;

--��������� ��������� ������ �� ��������������� 

USE [WideWorldImporters]
GO
BEGIN TRANSACTION
CREATE CLUSTERED INDEX [ClusteredIndex] ON [Sales].[InvoicesPartitioned]
(
	[InvoiceDate]
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [schmYearPartition]([InvoiceDate])


DROP INDEX [ClusteredIndex] ON [Sales].[InvoicesPartitioned]

COMMIT TRANSACTION

--������� ����� ������� � ��� ����������������
select distinct t.name
from sys.partitions p
inner join sys.tables t
	on p.object_id = t.object_id
where p.partition_number <> 1

--������� ��� �� ���������� ������ ���� ������
SELECT  $PARTITION.fnYearPartition(InvoiceDate) AS Partition
		,COUNT(*) AS [COUNT] 
		,MIN(InvoiceDate) AS 'MINDATA'
		,MAX(InvoiceDate) AS 'MAXDATA'
FROM Sales.InvoicesPartitioned
GROUP BY $PARTITION.fnYearPartition(InvoiceDate) 
ORDER BY Partition ; 

--������� ������
-- 1	61320	2013-01-01	2015-12-31
-- 2	9190	2016-01-01	2016-05-31

--�������� 1 ������ �� 2

Alter Partition Function fnYearPartition() SPLIT RANGE ('20140101');
--������� ��� �� ���������� ������ ���� ������
SELECT  $PARTITION.fnYearPartition(InvoiceDate) AS Partition
		,COUNT(*) AS [COUNT] 
		,MIN(InvoiceDate) AS 'MINDATA'
		,MAX(InvoiceDate) AS 'MAXDATA'
FROM Sales.InvoicesPartitioned
GROUP BY $PARTITION.fnYearPartition(InvoiceDate) 
ORDER BY Partition ; 

--������� ������
--1	18767	2013-01-01	2013-12-31
--2	42553	2014-01-01	2015-12-31
--3	9190	2016-01-01	2016-05-31
