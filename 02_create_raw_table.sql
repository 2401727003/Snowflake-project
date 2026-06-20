-- 02_create_raw_table.sql

USE DATABASE ECOMERSE_DB;
USE SCHEMA RAW;

CREATE OR REPLACE TABLE TD_ORDERS_RAW (
    Order_ID          VARCHAR,
    Customer_ID       VARCHAR,
    Customer_Name     VARCHAR,
    Order_Date        VARCHAR,
    Product           VARCHAR,
    Quantity          VARCHAR,
    Price             VARCHAR,
    Discount          VARCHAR,
    Total_Amount      VARCHAR,
    Payment_Method    VARCHAR,
    Shipping_Address  VARCHAR,
    Status            VARCHAR
);
