-- Step 4：訓練 K-Means 模型
-- 使用 log1p 轉換處理 Frequency 和 Monetary 的右偏分布
-- standardize_features = TRUE 自動做 StandardScaler

CREATE OR REPLACE MODEL `crm-profolio.online_retail.kmeans_rfm`
OPTIONS (
  model_type           = 'kmeans',
  num_clusters         = 5,
  kmeans_init_method   = 'kmeans++',
  standardize_features = TRUE
) AS

SELECT
  CustomerID,
  Recency,
  LN(1 + Frequency) AS Frequency_log,
  LN(1 + Monetary)  AS Monetary_log
FROM `crm-profolio.online_retail.rfm_base`;