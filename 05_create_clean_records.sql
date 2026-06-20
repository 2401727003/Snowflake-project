-- 05_create_clean_records.sql
-- Финална таблица TD_CLEAN_RECORDS с приложени всички правила за почистване.

USE DATABASE ECOMERSE_DB;
USE SCHEMA RAW;

CREATE OR REPLACE TABLE TD_CLEAN_RECORDS AS
WITH typed_records AS (
    SELECT
        TRY_TO_NUMBER(Order_ID)                         AS Order_ID,
        NULLIF(TRIM(Customer_ID), '')                   AS Customer_ID,
        NULLIF(TRIM(Customer_Name), '')                 AS Customer_Name,
        TRY_TO_DATE(TRIM(Order_Date), 'YYYY-MM-DD')     AS Order_Date,
        NULLIF(TRIM(Product), '')                       AS Product,
        TRY_TO_NUMBER(Quantity)                         AS Quantity,
        TRY_TO_DECIMAL(Price, 10, 2)                    AS Price,
        TRY_TO_DECIMAL(Discount, 10, 4)                 AS Original_Discount,
        TRY_TO_DECIMAL(Total_Amount, 12, 2)             AS Original_Total_Amount,
        COALESCE(NULLIF(TRIM(Payment_Method), ''), 'Unknown') AS Payment_Method,
        NULLIF(TRIM(Shipping_Address), '')              AS Shipping_Address,
        NULLIF(TRIM(Status), '')                        AS Original_Status
    FROM TD_ORDERS_RAW
),
valid_records AS (
    SELECT *
    FROM typed_records
    WHERE Customer_ID IS NOT NULL
      AND Order_Date IS NOT NULL
      AND Quantity > 0
      AND Price > 0
),
discount_fixed AS (
    SELECT
        *,
        CASE
            WHEN Original_Discount < 0 THEN 0
            WHEN Original_Discount > 0.50 THEN 0.50
            ELSE Original_Discount
        END AS Discount
    FROM valid_records
),
status_fixed AS (
    SELECT
        *,
        CASE
            WHEN UPPER(Original_Status) = 'DELIVERED'
                 AND Shipping_Address IS NULL
            THEN 'Pending'
            ELSE Original_Status
        END AS Status
    FROM discount_fixed
),
amount_fixed AS (
    SELECT
        Order_ID,
        Customer_ID,
        Customer_Name,
        Order_Date,
        Product,
        Quantity,
        Price,
        Discount,
        ROUND(Quantity * Price * (1 - Discount), 2) AS Total_Amount,
        Payment_Method,
        Shipping_Address,
        Status
    FROM status_fixed
),
deduplicated AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY
                Order_ID,
                Customer_ID,
                Customer_Name,
                Order_Date,
                Product,
                Quantity,
                Price,
                Discount,
                Total_Amount,
                Payment_Method,
                Shipping_Address,
                Status
            ORDER BY Order_ID
        ) AS rn
    FROM amount_fixed
)
SELECT
    Order_ID,
    Customer_ID,
    Customer_Name,
    Order_Date,
    Product,
    Quantity,
    Price,
    Discount,
    Total_Amount,
    Payment_Method,
    Shipping_Address,
    Status
FROM deduplicated
WHERE rn = 1;
