CREATE OR REPLACE TABLE `crm-profolio.online_retail.quarterly_summary` AS

WITH quarterly AS (
  SELECT
    year_quarter,
    EXTRACT(YEAR FROM InvoiceDate)                                    AS year,
    CAST(CEILING(EXTRACT(MONTH FROM InvoiceDate) / 3.0) AS INT64)    AS quarter,
    SUM(Revenue)                    AS revenue,
    COUNT(DISTINCT Invoice)         AS orders,
    COUNT(DISTINCT CustomerID)      AS customers
  FROM `crm-profolio.online_retail.orders_clean`
  GROUP BY year_quarter, year, quarter
),

with_prev_year AS (
  SELECT
    a.year_quarter,
    a.year,
    a.quarter,
    a.revenue,
    a.orders,
    a.customers,
    b.revenue   AS prev_year_revenue,
    b.orders    AS prev_year_orders,
    b.customers AS prev_year_customers,
    ROUND(SAFE_DIVIDE(a.revenue   - b.revenue,   b.revenue)   * 100, 1) AS revenue_yoy,
    ROUND(SAFE_DIVIDE(a.orders    - b.orders,    b.orders)    * 100, 1) AS orders_yoy,
    ROUND(SAFE_DIVIDE(a.customers - b.customers, b.customers) * 100, 1) AS customers_yoy
  FROM quarterly a
  LEFT JOIN quarterly b
    ON a.year    = b.year + 1
    AND a.quarter = b.quarter
)

SELECT * FROM with_prev_year
ORDER BY year, quarter;