-- 04_create_review_tables.sql
-- Таблици за записи, които трябва да бъдат отделени за проверка.

USE DATABASE ECOMERSE_DB;
USE SCHEMA RAW;

-- Delivered записи без адрес за доставка
CREATE OR REPLACE TABLE TD_FOR_REVIEW AS
SELECT *
FROM TD_ORDERS_RAW
WHERE UPPER(TRIM(Status)) = 'DELIVERED'
  AND NULLIF(TRIM(Shipping_Address), '') IS NULL;

-- Записи без Customer_ID
CREATE OR REPLACE TABLE TD_SUSPICIOUS_RECORDS AS
SELECT *
FROM TD_ORDERS_RAW
WHERE NULLIF(TRIM(Customer_ID), '') IS NULL;

-- Записи с невалиден формат/стойност на дата
CREATE OR REPLACE TABLE TD_INVALID_DATE_FORMAT AS
SELECT *
FROM TD_ORDERS_RAW
WHERE TRY_TO_DATE(TRIM(Order_Date), 'YYYY-MM-DD') IS NULL;

-- Записи с отрицателно или нулево количество/цена
CREATE OR REPLACE TABLE TD_INVALID_QUANTITY_PRICE AS
SELECT *
FROM TD_ORDERS_RAW
WHERE TRY_TO_NUMBER(Quantity) <= 0
   OR TRY_TO_NUMBER(Price) <= 0
   OR TRY_TO_NUMBER(Quantity) IS NULL
   OR TRY_TO_NUMBER(Price) IS NULL;
