-- 1)�������� ������� ��������
SELECT [id]
      ,[username]
      ,[phone]
      ,[email]
      ,[created]
  FROM [BloggersSite].[dbo].[client]
  WHERE username = 'exampleUser11' --������ ��� ������� � ������� ���� �� ����� ������ (���)

-- 2)������������ ������� ���� ��� ���
EXEC InsertClient @user = 'exampleUser11', @phone = '79608044001', @email = 'example@example.com'

--3) ��������� ���������� �������
	SELECT TOP (1) [id]
		  ,[username]
		  ,[phone]
		  ,[email]
		  ,[created]
	  FROM [BloggersSite].[dbo].[client]
	Order By [id] desc

--4) ��������� ����� �� ������� ��������� ������, ���������� � ���������� ������� ����� ������ ������������
--������� ��� ���� ��� �������� ������
	SELECT TOP (1000) [id_service]
		  ,[name_service]
		  ,[description_service]
		  ,[price_service]
	  FROM [BloggersSite].[dbo].[services]
--��������� �����
EXEC GenerateSalesOrder @id_service = 4, @id_client = 86, @quantity = 3, @id_employee = 2

--��������� ��������� �����
	SELECT TOP (1) [id_sales]
      ,cl.username
	  ,cl.phone
	  ,se.name_service
	  ,se.price_service as '���� �� 1 ������'
	  ,sa.[quantity]
	  ,sa.[quantity] * se.price_service as '���������'
  FROM [BloggersSite].[dbo].[sales] sa
  Inner join [BloggersSite].[dbo].[services] se
  On sa.id_service = se.id_service
  Inner join [BloggersSite].[dbo].[client] cl
  On sa.id_client = cl.id
  Order By [id_sales] desc

 --5) ������� ������ � ������
 SELECT TOP (1000) [id_sales]
      ,[id_service]
      ,[id_client]
      ,[quantity]
      ,[date_created]
      ,[expected_date]
      ,[id_employee]
  FROM [BloggersSite].[dbo].[sales]
  Where [expected_date] is Null

  -- 6) ��������� �����
 EXEC UpdateExpectedDate @id_sales = 144; --��������� ����� ������

 -- 7) ����� ������� � ������� �������, ����������� ����� � �������� �������. 
 EXEC GetClientInfoBySalesId @SalesId = 144

 -- 8) ����� ������, ����������� �������� �����������.
 EXEC GetSalesByEmployeeId @EmployeeId = 2

 -- 9) ����� ������, ��������� �� ������� �� ���� �������� ��������. 
 EXEC GetSalesUnderLimit 20000; --��������� ���������

 --10) ��������� ��������� ����� �� ��������
 EXEC UpdateServicePrices 0.95 --��������� �����. ����������/����������

