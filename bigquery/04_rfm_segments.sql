-- Step 5：取得分群結果並動態命名
CREATE OR REPLACE TABLE `crm-profolio.online_retail.rfm_segments` AS

WITH predicted AS (
  SELECT
    CustomerID,
    CENTROID_ID AS Cluster
  FROM ML.PREDICT(
    MODEL `crm-profolio.online_retail.kmeans_rfm`,
    (
      SELECT
        CustomerID,
        Recency,
        LN(1 + Frequency) AS Frequency_log,
        LN(1 + Monetary)  AS Monetary_log
      FROM `crm-profolio.online_retail.rfm_base`
    )
  )
),

cluster_stats AS (
  SELECT
    p.Cluster,
    AVG(r.Recency)   AS avg_recency,
    AVG(r.Frequency) AS avg_frequency,
    AVG(r.Monetary)  AS avg_monetary
  FROM predicted p
  JOIN `crm-profolio.online_retail.rfm_base` r
    ON p.CustomerID = r.CustomerID
  GROUP BY p.Cluster
),

cluster_ranked AS (
  SELECT
    Cluster,
    avg_recency,
    avg_frequency,
    avg_monetary,
    RANK() OVER (ORDER BY avg_recency ASC)    AS rank_r,
    RANK() OVER (ORDER BY avg_frequency DESC) AS rank_f,
    RANK() OVER (ORDER BY avg_monetary DESC)  AS rank_m
  FROM cluster_stats
),

cluster_named AS (
  SELECT
    Cluster,
    avg_recency,
    avg_frequency,
    avg_monetary,
    CASE RANK() OVER (ORDER BY rank_r + rank_f + rank_m ASC)
      WHEN 1 THEN '高價值客戶'
      WHEN 2 THEN '一般活躍客戶'
      WHEN 3 THEN '沉睡客戶'
      WHEN 4 THEN '低頻低消客戶'
      WHEN 5 THEN '深度流失客戶'
    END AS Segment
  FROM cluster_ranked
)

SELECT
  r.CustomerID,
  r.Recency,
  r.Frequency,
  r.Monetary,
  p.Cluster,
  n.Segment
FROM predicted p
JOIN `crm-profolio.online_retail.rfm_base` r ON p.CustomerID = r.CustomerID
JOIN cluster_named n ON p.Cluster = n.Cluster;