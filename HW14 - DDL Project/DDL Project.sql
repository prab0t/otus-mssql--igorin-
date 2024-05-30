-- Exported from QuickDBD: https://www.quickdatabasediagrams.com/
-- NOTE! If you have used non-SQL datatypes in your design, you will have to change these here.

--1. Создать базу данных.
CREATE database Blog

--2. Основные таблицы для своего проекта. 1-2 индекса на таблицы.
SET XACT_ABORT ON

BEGIN TRANSACTION Blog

CREATE TABLE [services] (
    [id_service] integer  NOT NULL ,
    [name_service] varchar (100) NOT NULL ,
    [description_service] varchar (100) NOT NULL ,
    [price_service] integer  NOT NULL ,
    CONSTRAINT [PK_services] PRIMARY KEY CLUSTERED (
        [id_service] ASC
    ),
    CONSTRAINT [UK_services_name_service] UNIQUE (
        [name_service]
    )
)

CREATE TABLE [sales] (
    [id_sales] integer  NOT NULL ,
    [id_service] integer  NOT NULL ,
    [id_client] integer  NOT NULL ,
    [quantity] integer  NOT NULL ,
    [price] integer  NOT NULL ,
    [date_created] datetime  DEFAULT GETDATE () ,
    [expected_date] datetime  NOT NULL ,
    [actual_date] datetime  ,
    [id_employee] integer  NOT NULL ,
    [status] integer  NOT NULL ,
    CONSTRAINT [PK_sales] PRIMARY KEY CLUSTERED (
        [id_sales] ASC
    )
)

CREATE TABLE [client] (
    [id] integer  NOT NULL ,
    [username] varchar (100) NOT NULL ,
    [phone] integer  NOT NULL ,
    [email] varchar (100) NOT NULL ,
    [created] datetime  NOT NULL ,
    CONSTRAINT [PK_client] PRIMARY KEY CLUSTERED (
        [id] ASC
    ),
    CONSTRAINT [UK_client_username] UNIQUE (
        [username]
    )
)

CREATE TABLE [employee] (
    [id] integer  NOT NULL ,
    [username] varchar (100) NOT NULL ,
    [phone] integer  NOT NULL ,
    [email] varchar (100) NOT NULL ,
    [created] datetime  NOT NULL ,
    [skill] integer  NOT NULL ,
    CONSTRAINT [PK_employee] PRIMARY KEY CLUSTERED (
        [id] ASC
    ),
    CONSTRAINT [UK_employee_username] UNIQUE (
        [username]
    )
)

CREATE TABLE [skill] (
    [id] integer  NOT NULL ,
    [name] varchar (100) NOT NULL ,
    [speed] integer  NOT NULL ,
    CONSTRAINT [PK_skill] PRIMARY KEY CLUSTERED (
        [id] ASC
    )
)
--3.Первичные и внешние ключи для всех созданных таблиц. 

ALTER TABLE [sales] WITH CHECK ADD CONSTRAINT [FK_sales_id_service] FOREIGN KEY([id_service])
REFERENCES [services] ([id_service])

ALTER TABLE [sales] CHECK CONSTRAINT [FK_sales_id_service]

ALTER TABLE [sales] WITH CHECK ADD CONSTRAINT [FK_sales_id_client] FOREIGN KEY([id_client])
REFERENCES [client] ([id])

ALTER TABLE [sales] CHECK CONSTRAINT [FK_sales_id_client]

ALTER TABLE [sales] WITH CHECK ADD CONSTRAINT [FK_sales_id_employee] FOREIGN KEY([id_employee])
REFERENCES [employee] ([id])

ALTER TABLE [sales] CHECK CONSTRAINT [FK_sales_id_employee]

ALTER TABLE [employee] WITH CHECK ADD CONSTRAINT [FK_employee_skill] FOREIGN KEY([skill])
REFERENCES [skill] ([id])

ALTER TABLE [employee] CHECK CONSTRAINT [FK_employee_skill]

COMMIT TRANSACTION Blog

--5. Наложите по одному ограничению в каждой таблице на ввод данных

--ограничение неверного ввода телефона
ALTER TABLE Client
ADD
CHECK (Phone LIKE '([0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9])')
GO
--ограничение неверного ввода телефона
ALTER TABLE employee
ADD
CHECK (Phone LIKE '([0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9])')
GO
--ограничение ожидаемой даты выполнения. нельзя вводить прошлую дату позднее чем создан заказ
ALTER TABLE sales
ADD
CHECK (expected_date >= date_created)
GO
--на таблицу скилла сотрудников нет ограниченй. Там будет просто добавлено 3 вида уровня сотрудников (junior,middle,senior)
--но решил сделать чисто ограничение на ввод 1-3
ALTER TABLE skill
ADD
CHECK (Id = 1 or Id = 2 or Id = 3)
GO

--Стоимость услуги не может быть 0 или минус
ALTER TABLE [services]
ADD
CHECK (price_service >= 0)
GO




