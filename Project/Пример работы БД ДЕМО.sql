-- 1)Проверка текущих клиентов
SELECT [id]
      ,[username]
      ,[phone]
      ,[email]
      ,[created]
  FROM [BloggersSite].[dbo].[client]
  WHERE username = 'exampleUser11' --вводим имя клиента и смотрим есть ли такой клиент (ник)

-- 2)Регистрируем клиента если его нет
EXEC InsertClient @user = 'exampleUser11', @phone = '79608044001', @email = 'example@example.com'

--3) Проверяем созданного клиента
	SELECT TOP (1) [id]
		  ,[username]
		  ,[phone]
		  ,[email]
		  ,[created]
	  FROM [BloggersSite].[dbo].[client]
	Order By [id] desc

--4) Оформляем заказ на клиента указываем услугу, количество и сотрудника который будет услугу осуществлять
--Выводим для себя для удобсвта услуги
	SELECT TOP (1000) [id_service]
		  ,[name_service]
		  ,[description_service]
		  ,[price_service]
	  FROM [BloggersSite].[dbo].[services]
--Оформляем заказ
EXEC GenerateSalesOrder @id_service = 4, @id_client = 86, @quantity = 3, @id_employee = 2

--проверяем созданный заказ
	SELECT TOP (1) [id_sales]
      ,cl.username
	  ,cl.phone
	  ,se.name_service
	  ,se.price_service as 'Цена за 1 услугу'
	  ,sa.[quantity]
	  ,sa.[quantity] * se.price_service as 'Стоимость'
  FROM [BloggersSite].[dbo].[sales] sa
  Inner join [BloggersSite].[dbo].[services] se
  On sa.id_service = se.id_service
  Inner join [BloggersSite].[dbo].[client] cl
  On sa.id_client = cl.id
  Order By [id_sales] desc

 --5) Смотрим заказы в работе
 SELECT TOP (1000) [id_sales]
      ,[id_service]
      ,[id_client]
      ,[quantity]
      ,[date_created]
      ,[expected_date]
      ,[id_employee]
  FROM [BloggersSite].[dbo].[sales]
  Where [expected_date] is Null

  -- 6) Выполняем заказ
 EXEC UpdateExpectedDate @id_sales = 144; --указываем номер заказа

 -- 7) Найти фамилию и телефон клиента, оформившего заказ с заданным номером. 
 EXEC GetClientInfoBySalesId @SalesId = 144

 -- 8) Найти заказы, оформленные заданным сотрудником.
 EXEC GetSalesByEmployeeId @EmployeeId = 2

 -- 9) Найти заказы, стоимость на которых не выше заданной величины. 
 EXEC GetSalesUnderLimit 20000; --указываем стоимость

 --10) Увеличить стоимость услуг на проценты
 EXEC UpdateServicePrices 0.95 --указываем коэфф. увеличения/уменьшения

