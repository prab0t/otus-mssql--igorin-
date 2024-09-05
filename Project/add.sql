
--заполняем скилл
  INSERT INTO [BloggersSite].[dbo].[skill] (id, name, speed)
VALUES 
(1, 'Junior', 5),
(2, 'Middle', 3),
(3, 'High', 1);
--заполняем сотрудников
INSERT INTO [BloggersSite].[dbo].[employee] ([id], [username], [phone], [email], [created], [skill])
VALUES
(1, 'AnastasiaZueva', '79031234568', 'anastasia.zueva@email.ru', '2024-07-04', 1),
(2, 'IgorSokolov', '79031234569', 'igor.sokolov@email.ru', '2024-07-04', 1),
(3, 'EkaterinaFedorova', '79031234570', 'ekaterina.fedorova@email.ru', '2024-07-04', 1),
(4, 'DmitryIvanov', '79031234571', 'dmitry.ivanov@email.ru', '2024-07-04', 1),
(5, 'OlgaPetrova', '79031234572', 'olga.petrova@email.ru', '2024-07-04', 2),
(6, 'SergeyAlekseev', '79031234573', 'sergey.alekseev@email.ru', '2024-07-04', 1),
(7, 'MariaNikitina', '79031234574', 'maria.nikitina@email.ru', '2024-07-04', 1),
(8, 'VladimirKuznetsov', '79031234575', 'vladimir.kuznetsov@email.ru', '2024-07-04', 1),
(9, 'TatianaMorozova', '79031234576', 'tatiana.morozova@email.ru', '2024-07-04', 3)


--заполняем клиентов

DECLARE @i INT = 0;
DECLARE @id INT = 1;
WHILE @i < 1000
BEGIN
    INSERT INTO [BloggersSite].[dbo].[client] ([id],[username], [phone], [email], [created])
    VALUES (
		@id,
        CONCAT('USER_', @i), -- Генерация уникального username
        CONCAT('7903', RIGHT(REPLACE(NEWID(), '-', ''), 7)), -- Генерация номера телефона с заданной структурой
        CONCAT('user', @i, '@example.com'), -- Генерация фиктивного email
        DATEADD(YEAR, - (ABS(CHECKSUM(NEWID())) % 3), GETDATE()) -- Генерация даты создания в пределах последних 3 лет
    );
    SET @i = @i + 1;
	SET @id = @i + 1;
END;

--изменяем ид клиентов

  WITH OrderedIDs AS (
  SELECT TOP (1000)
    ROW_NUMBER() OVER (ORDER BY NEWID()) AS SequentialID,
    [username],
    [phone],
    [email],
    [created]
  FROM [BloggersSite].[dbo].[client]
)
UPDATE c
SET c.[id] = o.SequentialID % 75 + 1
FROM [BloggersSite].[dbo].[client] c
JOIN OrderedIDs o ON c.[username] = o.[username] AND c.[phone] = o.[phone] AND c.[email] = o.[email] AND c.[created] = o.[created]
--заполняем услуги

INSERT INTO [BloggersSite].[dbo].[services] (id_service, name_service, description_service, price_service)
VALUES 
(1, 'Статья на сайт', 'Рекламная статья на сайте', 10000),
(2, 'Ютуб', 'Видео обзор продукции в ютуб', 20000),
(3, 'Пост в телеграмм', 'Пост в группе в телеграмм', 5000),
(4, 'Пост в вк', 'Пост в группе в вк', 4000),
(5, 'Тик ток', 'Видео обзор продукции в тик ток', 7000);

--заполняем продажи
WITH DateRange AS (
  SELECT TOP (1000)
    DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 152, CAST('2024-01-01' AS DATETIME)) AS date_created
  FROM sys.objects
),
RandomData AS (
  SELECT
    NEWID() AS id,
    ABS(CHECKSUM(NEWID())) % 5 + 1 AS id_service, -- Пример для id_service от 1 до 5
    ABS(CHECKSUM(NEWID())) % 75 + 1 AS id_client, -- Пример для id_client от 1 до 75
    ABS(CHECKSUM(NEWID())) % 3 + 1 AS quantity, -- Для quantity от 1 до 3
    d.date_created,
    DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 2 * 2 + 3, d.date_created) AS expected_date, -- Добавление 3 или 5 дней к date_created
    ABS(CHECKSUM(NEWID())) % 9 + 1 AS id_employee -- Пример для id_employee от 1 до 9
  FROM DateRange d
)
INSERT INTO [BloggersSite].[dbo].[sales]
([id_sales], [id_service], [id_client], [quantity], [date_created], [expected_date], [id_employee])
SELECT
  ROW_NUMBER() OVER (ORDER BY id) AS id_sales,
  id_service,
  id_client,
  quantity,
  date_created,
  expected_date,
  id_employee
FROM RandomData