/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "08 - Выборки из XML и JSON полей".

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
Примечания к заданиям 1, 2:
* Если с выгрузкой в файл будут проблемы, то можно сделать просто SELECT c результатом в виде XML. 
* Если у вас в проекте предусмотрен экспорт/импорт в XML, то можете взять свой XML и свои таблицы.
* Если с этим XML вам будет скучно, то можете взять любые открытые данные и импортировать их в таблицы (например, с https://data.gov.ru).
* Пример экспорта/импорта в файл https://docs.microsoft.com/en-us/sql/relational-databases/import-export/examples-of-bulk-import-and-export-of-xml-documents-sql-server
*/


/*
1. В личном кабинете есть файл StockItems.xml.
Это данные из таблицы Warehouse.StockItems.
Преобразовать эти данные в плоскую таблицу с полями, аналогичными Warehouse.StockItems.
Поля: StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice 

Загрузить эти данные в таблицу Warehouse.StockItems: 
существующие записи в таблице обновить, отсутствующие добавить (сопоставлять записи по полю StockItemName). 

Сделать два варианта: с помощью OPENXML и через XQuery.
*/

DECLARE @xmlDocument XML, @docHandle int;
SET @xmlDocument = (SELECT * FROM OPENROWSET (BULK 'C:\demo\StockItems.xml', SINGLE_BLOB)  AS d);
EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument --преоб. xml в таб
--копия

MERGE Warehouse.StockItems AS SI 
    USING (SELECT *
            FROM OPENXML(@docHandle, N'/StockItems/Item')
            WITH ( 
                [StockItemName] nvarchar(100) '@Name',
                [SupplierID] int 'SupplierID',
                [UnitPackageID] int 'Package/UnitPackageID',
                [OuterPackageID] int 'Package/OuterPackageID',
                [QuantityPerOuter] int 'Package/QuantityPerOuter',
                [TypicalWeightPerUnit] decimal(18,3) 'Package/TypicalWeightPerUnit',
                [LeadTimeDays] int 'LeadTimeDays',
                [IsChillerStock] bit 'IsChillerStock',
                [TaxRate] decimal(18,3) 'TaxRate',
                [UnitPrice] decimal(18,6) 'UnitPrice')
            ) 
            AS copies (
                StockItemName,
                SupplierID,
                UnitPackageID,
                OuterPackageID,
                LeadTimeDays,
                QuantityPerOuter,
                IsChillerStock,
                TaxRate,
                UnitPrice,
                TypicalWeightPerUnit) 
            ON (SI.StockItemName = copies.StockItemName) 
    WHEN MATCHED 
        THEN UPDATE SET  
                [SupplierID]            = copies.[SupplierID]
                ,[UnitPackageID]        = copies.[UnitPackageID]
                ,[OuterPackageID]       = copies.[OuterPackageID]
                ,[QuantityPerOuter]     = copies.[QuantityPerOuter]
                ,[TypicalWeightPerUnit] = copies.[TypicalWeightPerUnit]
                ,[LeadTimeDays]         = copies.[LeadTimeDays]
                ,[IsChillerStock]       = copies.[IsChillerStock]
                ,[TaxRate]              = copies.[TaxRate]
                ,[UnitPrice]            = copies.[UnitPrice]                    
    WHEN NOT MATCHED 
        THEN INSERT (
                [StockItemName],
                [SupplierID],
                [UnitPackageID],
                [OuterPackageID],
                [LeadTimeDays],
                [QuantityPerOuter],
                [IsChillerStock],
                [TaxRate],
                [UnitPrice],
                [TypicalWeightPerUnit],
                [LastEditedBy])
        VALUES (
                copies.[StockItemName],
                copies.[SupplierID],
                copies.[UnitPackageID],
                copies.[OuterPackageID],
                copies.[LeadTimeDays],
                copies.[QuantityPerOuter],
                copies.[IsChillerStock],
                copies.[TaxRate],
                copies.[UnitPrice],
                copies.[TypicalWeightPerUnit],1)
        OUTPUT deleted.*, $action, inserted.*;

-- чисти doc
EXEC sp_xml_removedocument @docHandle
GO
-- xquery 
DECLARE @xmlDocument XML, @docHandle int;
SET @xmlDocument = (SELECT * FROM OPENROWSET (BULK 'C:\demo\StockItems.xml', SINGLE_BLOB)  AS d);
--------------------------------------------------------------------------
MERGE Warehouse.StockItems AS SI
	USING (SELECT  
                SI2.StockItems.value('(@Name)[1]', 'nvarchar(100)') as [StockItemName],   
                SI2.StockItems.value('(SupplierID)[1]', 'int') as [SupplierID], 
                SI2.StockItems.value('(Package/UnitPackageID)[1]', 'int') as [UnitPackageID],
                SI2.StockItems.value('(Package/OuterPackageID)[1]', 'int') as [OuterPackageID],
                SI2.StockItems.value('(Package/QuantityPerOuter)[1]', 'int') as [QuantityPerOuter],
                SI2.StockItems.value('(Package/TypicalWeightPerUnit)[1]', 'decimal(18,3)') as [TypicalWeightPerUnit],
                SI2.StockItems.value('(LeadTimeDays)[1]', 'int') as [LeadTimeDays],
                SI2.StockItems.value('(IsChillerStock)[1]', 'bit') as [IsChillerStock],
                SI2.StockItems.value('(TaxRate)[1]', 'decimal(18,3)') as [TaxRate],
                SI2.StockItems.value('(UnitPrice)[1]', 'decimal(18,6)') as [UnitPrice]
            FROM @xmlDocument.nodes('/StockItems/Item') as SI2(StockItems)
            )
            AS copies (
                [StockItemName],
                [SupplierID],
                [UnitPackageID],
                [OuterPackageID],
                [QuantityPerOuter],
                [TypicalWeightPerUnit],
                [LeadTimeDays],
                [IsChillerStock],
                [TaxRate],
                [UnitPrice]) 
			ON (SI.StockItemName = copies.StockItemName) 
    WHEN MATCHED 
        THEN UPDATE SET  
                [SupplierID]           = copies.[SupplierID],
                [UnitPackageID]        = copies.[UnitPackageID],
                [OuterPackageID]       = copies.[OuterPackageID],
                [QuantityPerOuter]     = copies.[QuantityPerOuter],
                [TypicalWeightPerUnit] = copies.[TypicalWeightPerUnit],
                [LeadTimeDays]         = copies.[LeadTimeDays],
                [IsChillerStock]       = copies.[IsChillerStock],
                [TaxRate]              = copies.[TaxRate],
                [UnitPrice]            = copies.[UnitPrice]                    
        WHEN NOT MATCHED 
        THEN INSERT (
                [StockItemName],
                [SupplierID],
                [UnitPackageID],
                [OuterPackageID],
                [QuantityPerOuter],
                [TypicalWeightPerUnit],
                [LeadTimeDays],				
                [IsChillerStock],
                [TaxRate],
                [UnitPrice],				
                [LastEditedBy])
         VALUES (
                copies.[StockItemName],
                copies.[SupplierID],
                copies.[UnitPackageID],
                copies.[OuterPackageID],
                copies.[TypicalWeightPerUnit],
                copies.[QuantityPerOuter],
                copies.[LeadTimeDays],				
                copies.[IsChillerStock],
                copies.[TaxRate],
                copies.[UnitPrice],
                1)
        OUTPUT deleted.*, $action, inserted.*;

/*
2. Выгрузить данные из таблицы StockItems в такой же xml-файл, как StockItems.xml
*/

DECLARE @fileName VARCHAR(50)  = 'C:\demo\StockItems2.xml'
DECLARE @sqlStr VARCHAR(1000)
DECLARE @sqlCmd VARCHAR(1000)
 
SET @sqlStr  = 'SELECT [StockItemName] AS [@Name], [SupplierID], [UnitPackageID] AS [Package/UnitPackageID], '
SET @sqlStr += '[OuterPackageID] AS [Package/OuterPackageID], [QuantityPerOuter] AS [Package/QuantityPerOuter], '
SET @sqlStr += '[TypicalWeightPerUnit] AS [Package/TypicalWeightPerUnit], [LeadTimeDays], [IsChillerStock], '
SET @sqlStr += '[TaxRate], [UnitPrice] FROM [WideWorldImporters].[Warehouse].[StockItems] ORDER BY [StockItemID] DESC '
SET @sqlStr += 'FOR XML PATH(''Item''), ROOT(''StockItems'')'

SET @sqlCmd = 'bcp "' + @sqlStr + '" queryout ' + @fileName + ' -w -t' + char(13) + ' -T -S ' + @@SERVERNAME
EXEC master..xp_cmdshell @sqlCmd


/*
3. В таблице Warehouse.StockItems в колонке CustomFields есть данные в JSON.
Написать SELECT для вывода:
- StockItemID
- StockItemName
- CountryOfManufacture (из CustomFields)
- FirstTag (из поля CustomFields, первое значение из массива Tags)
*/

SELECT
    [StockItemID], 
    [StockItemName],
    [CountryOfManufacture] = JSON_VALUE(CustomFields, '$.CountryOfManufacture'),
    [FirstTag] = JSON_VALUE(CustomFields, '$.Tags[1]')
--	,[MinimumAge] = JSON_VALUE(CustomFields, '$.MinimumAge')
--  ,[Range] = JSON_VALUE(CustomFields, '$.Range')
FROM
    [Warehouse].[StockItems]


/*
4. Найти в StockItems строки, где есть тэг "Vintage".
Вывести: 
- StockItemID
- StockItemName
- (опционально) все теги (из CustomFields) через запятую в одном поле

Тэги искать в поле CustomFields, а не в Tags.
Запрос написать через функции работы с JSON.
Для поиска использовать равенство, использовать LIKE запрещено.

Должно быть в таком виде:
... where ... = 'Vintage'

Так принято не будет:
... where ... Tags like '%Vintage%'
... where ... CustomFields like '%Vintage%' 
*/

SELECT
    s.StockItemID,
    s.StockItemName,
    [Tags] = JSON_QUERY(s.CustomFields, '$.Tags')
FROM
    Warehouse.StockItems as s
    CROSS APPLY OPENJSON(s.CustomFields, '$.Tags') AS t
WHERE
    t.value = 'Vintage'
