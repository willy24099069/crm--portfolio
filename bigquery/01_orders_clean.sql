CREATE OR REPLACE TABLE `crm-profolio.online_retail.orders_clean` AS

SELECT
  *,
  FORMAT_TIMESTAMP('%Y-%m', InvoiceDate) AS year_month,
  CONCAT(
    CAST(EXTRACT(YEAR FROM InvoiceDate) AS STRING),
    ' Q',
    CAST(CEILING(EXTRACT(MONTH FROM InvoiceDate) / 3.0) AS STRING)
  )                                       AS year_quarter
FROM `crm-profolio.online_retail.vw_orders_clean`;