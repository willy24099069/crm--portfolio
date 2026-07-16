CREATE OR REPLACE TABLE `crm-profolio.online_retail.rfm_base` AS

WITH snapshot AS (
  SELECT DATE_ADD(MAX(DATE(InvoiceDate)), INTERVAL 1 DAY) AS snapshot_date
  FROM `crm-profolio.online_retail.orders_clean`
)

SELECT
  CustomerID,
  DATE_DIFF(s.snapshot_date, MAX(DATE(InvoiceDate)), DAY) AS Recency,
  COUNT(DISTINCT Invoice)                                  AS Frequency,
  ROUND(SUM(Revenue), 2)                                  AS Monetary
FROM `crm-profolio.online_retail.orders_clean`
CROSS JOIN snapshot s
GROUP BY CustomerID, s.snapshot_date;