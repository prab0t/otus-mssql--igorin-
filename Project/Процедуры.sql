--������� ������ �������
--��������� ��������
SELECT [id]
      ,[username]
      ,[phone]
      ,[email]
      ,[created]
  FROM [BloggersSite].[dbo].[client]
-- where username = 'USER_372'

--������� ������ �������. ������� ���������

CREATE or Alter PROCEDURE InsertClient
    @user VARCHAR(100),  -- ��������������, ��� ����� username �� ����� 50 ������
    @phone VARCHAR(12), 
    @email VARCHAR(100)  -- ��������������, ��� ����� email �� ����� 100 ������
AS
BEGIN

DECLARE @id INT = 1 + (SELECT TOP (1) [id]
  FROM [BloggersSite].[dbo].[client]
  Order By [id] desc)

    INSERT INTO [BloggersSite].[dbo].[client] ([id], [username], [phone], [email], [created])
    VALUES (
        @id,
        @user,        -- ��������� ����������� username
        @phone,       -- ��������� ������ �������� � �������� ����������
        @email,       -- ��������� ���������� email
        GETDATE()     -- ��������� ������� ���� � �������
    );
END;

--��������� ���������. ������������ ������ �������
EXEC InsertClient @user = 'exampleUser2', @phone = '79608043674', @email = 'example@example.com'

--��������� ���������� �������
SELECT TOP (1) [id]
      ,[username]
      ,[phone]
      ,[email]
      ,[created]
  FROM [BloggersSite].[dbo].[client]
Order By [id] desc

--������� ��������� �� ��������� �������.

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

--��������� ���������. ��������� �����
EXEC GenerateSalesOrder @id_service = 1, @id_client = 1, @quantity = 1, @id_employee = 1

--��������� ��������� �����
	SELECT TOP (1) [id_sales]
      ,se.name_service
	  ,se.price_service
      ,cl.username
	  ,cl.phone
      ,sa.[quantity]
	  ,se.price_service as '���� �� 1 ������'
	  ,sa.[quantity] * se.price_service as '���������'
  FROM [BloggersSite].[dbo].[sales] sa
  Inner join [BloggersSite].[dbo].[services] se
  On sa.id_service = se.id_service
  Inner join [BloggersSite].[dbo].[client] cl
  On sa.id_client = cl.id
  Order By [id_sales] desc

--������� ��������� �� ���������� ������
CREATE or Alter PROCEDURE UpdateExpectedDate
    @id_sales INT  -- �������� ��� �������������� �������
AS
BEGIN
    -- ���������� ���� expected_date �� ������� ���� � ����� ��� ���������� id_sales
    UPDATE [BloggersSite].[dbo].[sales]
    SET expected_date = GETDATE()  -- ��������� ������� ���� � �������
    WHERE id_sales = @id_sales;     -- ������� ����������
END;

--��������� ��������� 
EXEC UpdateExpectedDate @id_sales = 135;


-- ����� ������� � ������� �������, ����������� ����� � �������� �������. 
 select 
	 sa.id_client as '�� �������',
	 cl.[username] as '��� �������',
	 cl.[phone] as '������� �������'
 from [BloggersSite].[dbo].[sales] as sa
 inner join [BloggersSite].[dbo].[client] as cl 
 on cl.id = sa.id_client
 where id_sales = 1

 --������ ���������

 CREATE or ALTER PROCEDURE GetClientInfoBySalesId
    @SalesId INT
AS
BEGIN
    SELECT 
        sa.id_client AS '�� �������',
        cl.[username] AS '��� �������',
        cl.[phone] AS '������� �������'
    FROM 
        [BloggersSite].[dbo].[sales] AS sa
    INNER JOIN 
        [BloggersSite].[dbo].[client] AS cl 
        ON cl.id = sa.id_client
    WHERE 
        sa.id_sales = @SalesId;
END

--�������� ���������
EXEC GetClientInfoBySalesId @SalesId = 1

--����� ������, ����������� �������� �����������.
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

--������� ���������
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

--�������� ���������

EXEC GetSalesByEmployeeId @EmployeeId = 1

 --����� ������, ��������� �� ������� �� ���� �������� ��������. 
 SELECT 
		sa.[id_sales] as '����� �������'
      ,sa.[id_service] as '������'
	  ,se.name_service as '�������� ������'
      ,sa.[quantity] as '����������'
	  ,se.price_service as '��������� ������'
	  ,sa.quantity*se.price_service as '����� ������'
  FROM [BloggersSite].[dbo].[sales] sa
  inner join [BloggersSite].[dbo].[services] se
  ON se.id_service = sa.id_service and sa.quantity*se.price_service <=5000

--�������� ���������
CREATE or Alter PROCEDURE GetSalesUnderLimit @limit Numeric (19,2) --�������� ������ ���� ������
AS
BEGIN
    SELECT 
        sa.[id_sales] AS '����� �������',
        sa.[id_service] AS '������',
        se.name_service AS '�������� ������',
        sa.[quantity] AS '����������',
        se.price_service AS '��������� ������',
        sa.quantity * se.price_service AS '����� ������'
    FROM 
        [BloggersSite].[dbo].[sales] sa
    INNER JOIN 
        [BloggersSite].[dbo].[services] se ON se.id_service = sa.id_service
    WHERE 
        sa.quantity * se.price_service <= @limit;
END

--�������� ���������
EXEC GetSalesUnderLimit 5000;

--��������� �� 5% ��������� �����
SELECT TOP (1000) [id_service]
      ,[name_service]
      ,[description_service]
      ,[price_service]
  FROM [BloggersSite].[dbo].[services]

--UPDATE [BloggersSite].[dbo].[services] 
--SET price_service = 7000
--Where id_service = 5

--������� ���������
CREATE or Alter PROCEDURE UpdateServicePrices @coefficient DECIMAL(10, 2)
AS
BEGIN
    UPDATE [BloggersSite].[dbo].[services] 
    SET price_service = price_service * @coefficient;
END
--��������� ���������
EXEC UpdateServicePrices 1.05


