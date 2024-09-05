--создал БД
CREATE DATABASE BloggersSiteDW
--создаем табл
CREATE TABLE [sales] (
    [id_sales] integer  NOT NULL ,
    [id_service] integer  NOT NULL ,
    [id_client] integer  NOT NULL ,
    [quantity] integer  NOT NULL ,
    [date_created] datetime  DEFAULT GETDATE () ,
    [expected_date] datetime,
    [id_employee] integer  NOT NULL,
    CONSTRAINT [PK_sales] PRIMARY KEY CLUSTERED (
        [id_sales] ASC
    )
)

CREATE TABLE [services] (
    [id_service] integer  NOT NULL ,
    [name_service] varchar (100) NOT NULL ,
    [description_service] varchar (100) NOT NULL ,
    [price_service] Numeric(19,2) NOT NULL  ,
    CONSTRAINT [PK_services] PRIMARY KEY CLUSTERED (
        [id_service] ASC
    ),
    CONSTRAINT [UK_services_name_service] UNIQUE (
        [name_service]
    ))

--копируем данные из BloggerSite
INSERT INTO sales (id_sales, id_service, id_client, quantity, date_created,expected_date,id_employee)
SELECT *
FROM BloggersSite.dbo.sales;

INSERT INTO [services] (id_service, name_service,description_service,price_service)
SELECT *
FROM BloggersSite.dbo.services;

--связь
ALTER TABLE [sales] WITH CHECK ADD CONSTRAINT [FK_sales_id_service] FOREIGN KEY([id_service])
REFERENCES [services] ([id_service])
