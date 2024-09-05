--заводим нового клиента
--проверяем клиентов
SELECT [id]
      ,[username]
      ,[phone]
      ,[email]
      ,[created]
  FROM [BloggersSite].[dbo].[client]
-- where username = 'USER_372'

--Заводим нового клиента. Создаем процедуру

CREATE or Alter PROCEDURE InsertClient
    @user VARCHAR(100),  -- Предполагается, что длина username не более 50 знаков
    @phone VARCHAR(12), 
    @email VARCHAR(100)  -- Предполагается, что длина email не более 100 знаков
AS
BEGIN

DECLARE @id INT = 1 + (SELECT TOP (1) [id]
  FROM [BloggersSite].[dbo].[client]
  Order By [id] desc)

    INSERT INTO [BloggersSite].[dbo].[client] ([id], [username], [phone], [email], [created])
    VALUES (
        @id,
        @user,        -- Генерация уникального username
        @phone,       -- Генерация номера телефона с заданной структурой
        @email,       -- Генерация фиктивного email
        GETDATE()     -- Генерация текущей даты и времени
    );
END;

--Выполняем процедуру. Регистрируем нового клиента
EXEC InsertClient @user = 'exampleUser2', @phone = '79608043674', @email = 'example@example.com'

--Проверяем созданного клиента
SELECT TOP (1) [id]
      ,[username]
      ,[phone]
      ,[email]
      ,[created]
  FROM [BloggersSite].[dbo].[client]
Order By [id] desc

--Создаем процедуру на заведение заказов.

CREATE or Alter PROCEDURE GenerateSalesOrder @id_service int, @id_client int, @quantity int, @id_employee int
AS
Begin

DECLARE @id_sales INT = 1 + (SELECT TOP (1) [id_sales]
  FROM [BloggersSite].[dbo].[sales]
  order by [id_sales] desc)

    INSERT INTO [BloggersSite].[dbo].[sales] 
    ([id_sales], [id_service], [id_client], [quantity], [date_created], [expected_date], [id_employee])
	Values (@id_sales, @id_service, @id_client, @quantity, getdate (), null, @id_employee);


END;

--Выполняем процедуру. Оформляем заказ
EXEC GenerateSalesOrder @id_service = 1, @id_client = 1, @quantity = 1, @id_employee = 1

--проверяем созданный заказ
	SELECT TOP (1) [id_sales]
      ,se.name_service
	  ,se.price_service
      ,cl.username
	  ,cl.phone
      ,sa.[quantity]
	  ,se.price_service as 'Цена за 1 услугу'
	  ,sa.[quantity] * se.price_service as 'Стоимость'
  FROM [BloggersSite].[dbo].[sales] sa
  Inner join [BloggersSite].[dbo].[services] se
  On sa.id_service = se.id_service
  Inner join [BloggersSite].[dbo].[client] cl
  On sa.id_client = cl.id
  Order By [id_sales] desc

--Создаем процедуру на выполнение заказа
CREATE or Alter PROCEDURE UpdateExpectedDate
    @id_sales INT  -- Параметр для идентификатора продажи
AS
BEGIN
    -- Обновление поля expected_date на текущую дату и время для указанного id_sales
    UPDATE [BloggersSite].[dbo].[sales]
    SET expected_date = GETDATE()  -- Установка текущей даты и времени
    WHERE id_sales = @id_sales;     -- Условие обновления
END;

--Выполняем процедуру 
EXEC UpdateExpectedDate @id_sales = 135;


-- Найти фамилию и телефон клиента, оформившего заказ с заданным номером. 
 select 
	 sa.id_client as 'ИД клиента',
	 cl.[username] as 'Имя клиента',
	 cl.[phone] as 'Телефон клиента'
 from [BloggersSite].[dbo].[sales] as sa
 inner join [BloggersSite].[dbo].[client] as cl 
 on cl.id = sa.id_client
 where id_sales = 1

 --делаем процедуру

 CREATE or ALTER PROCEDURE GetClientInfoBySalesId
    @SalesId INT
AS
BEGIN
    SELECT 
        sa.id_client AS 'ИД клиента',
        cl.[username] AS 'Имя клиента',
        cl.[phone] AS 'Телефон клиента'
    FROM 
        [BloggersSite].[dbo].[sales] AS sa
    INNER JOIN 
        [BloggersSite].[dbo].[client] AS cl 
        ON cl.id = sa.id_client
    WHERE 
        sa.id_sales = @SalesId;
END

--вызываем процедуру
EXEC GetClientInfoBySalesId @SalesId = 1

--Найти заказы, оформленные заданным сотрудником.
SELECT sa.[id_sales]
      ,sa.[id_service]
      ,sa.[quantity]
      ,sa.[date_created]
      ,sa.[expected_date]
      ,sa.[id_employee]
	  ,em.username
  FROM [BloggersSite].[dbo].[sales] sa
  inner join [BloggersSite].[dbo].[employee] em
  ON em.id = sa.id_employee
  where sa.[id_employee] = 1

--генерим процедуру
CREATE or ALTER PROCEDURE GetSalesByEmployeeId
    @EmployeeId INT
AS
BEGIN
    SELECT 
        sa.[id_sales],
        sa.[id_service],
        sa.[quantity],
        sa.[date_created],
        sa.[expected_date],
        sa.[id_employee],
        em.username
    FROM 
        [BloggersSite].[dbo].[sales] sa
    INNER JOIN 
        [BloggersSite].[dbo].[employee] em ON em.id = sa.id_employee
    WHERE 
        sa.[id_employee] = @EmployeeId;
END;

--вызываем процедуру

EXEC GetSalesByEmployeeId @EmployeeId = 1

 --Найти заказы, стоимость на которых не выше заданной величины. 
 SELECT 
		sa.[id_sales] as 'номер продажи'
      ,sa.[id_service] as 'услуга'
	  ,se.name_service as 'название услуги'
      ,sa.[quantity] as 'количество'
	  ,se.price_service as 'стоимость услуги'
	  ,sa.quantity*se.price_service as 'сумма оплаты'
  FROM [BloggersSite].[dbo].[sales] sa
  inner join [BloggersSite].[dbo].[services] se
  ON se.id_service = sa.id_service and sa.quantity*se.price_service <=5000

--сгенерил процедуру
CREATE or Alter PROCEDURE GetSalesUnderLimit @limit Numeric (19,2) --получаем заказы ниже лимита
AS
BEGIN
    SELECT 
        sa.[id_sales] AS 'номер продажи',
        sa.[id_service] AS 'услуга',
        se.name_service AS 'название услуги',
        sa.[quantity] AS 'количество',
        se.price_service AS 'стоимость услуги',
        sa.quantity * se.price_service AS 'сумма оплаты'
    FROM 
        [BloggersSite].[dbo].[sales] sa
    INNER JOIN 
        [BloggersSite].[dbo].[services] se ON se.id_service = sa.id_service
    WHERE 
        sa.quantity * se.price_service <= @limit;
END

--вызываем процедуру
EXEC GetSalesUnderLimit 5000;

--Увеличить на 5% стоимость услуг
SELECT TOP (1000) [id_service]
      ,[name_service]
      ,[description_service]
      ,[price_service]
  FROM [BloggersSite].[dbo].[services]

--UPDATE [BloggersSite].[dbo].[services] 
--SET price_service = 7000
--Where id_service = 5

--генерим процедуру
CREATE or Alter PROCEDURE UpdateServicePrices @coefficient DECIMAL(10, 2)
AS
BEGIN
    UPDATE [BloggersSite].[dbo].[services] 
    SET price_service = price_service * @coefficient;
END
--выполняем процедуру
EXEC UpdateServicePrices 1.05


