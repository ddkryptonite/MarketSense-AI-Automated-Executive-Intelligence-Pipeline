
WITH raw_data AS (
  SELECT 
    -- splitting the string by comma to create an array
    SPLIT(name, ',') AS names_array,
    SPLIT(symbol, ',') AS symbols_array,
    SPLIT(price_usd, ',') AS prices_array,
    SPLIT(market_cap, ',') AS market_cap_array,
    SPLIT(change_24h, ',') AS changes_24_array,
    SPLIT(change_1h, ',') AS changes_1_array,
    SPLIT(change_7d, ',') AS changes_7_array,
    SPLIT(change_30d, ',') AS changes_30_array,
    SPLIT(change_60d, ',') AS changes_60_array,
    SPLIT(change_90d, ',') AS changes_90_array,
    SPLIT(volume_24h, ',') AS volume_24_array,
    SPLIT(last_updated, ',') AS updates_array
  FROM  (SELECT *
FROM (

  SELECT *, ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) as row_count -- this subquery allows us to assign a row number to the various versions of ingested data from the API  in order to select the most recent data , came in the form of one string , which will be broken down later, because 
  FROM `analytics-engineering-493415.production.staging-analytics`
)
ORDER BY row_count DESC
LIMIT 1)  

)


SELECT
  --  OFFSET allows us  to ensure the 1st name matches the 1st price,
  TRIM(val_name) AS asset_name,
  TRIM(symbols_array[OFFSET(pos)]) AS symbol,
  SAFE_CAST(TRIM(market_cap_array[OFFSET(pos)]) AS FLOAT64) AS market_cap,
  SAFE_CAST(TRIM(prices_array[OFFSET(pos)]) AS FLOAT64) AS price_usd,
  SAFE_CAST(TRIM(changes_1_array[OFFSET(pos)]) AS FLOAT64) AS change_1h,
  SAFE_CAST(TRIM(changes_24_array[OFFSET(pos)]) AS FLOAT64) AS change_24h,
  SAFE_CAST(TRIM(changes_7_array[OFFSET(pos)]) AS FLOAT64) AS change_7d,
  SAFE_CAST(TRIM(changes_30_array[OFFSET(pos)]) AS FLOAT64) AS change_30d,
  SAFE_CAST(TRIM(changes_60_array[OFFSET(pos)]) AS FLOAT64) AS change_60d,
  SAFE_CAST(TRIM(changes_90_array[OFFSET(pos)]) AS FLOAT64) AS change_90d,
  SAFE_CAST(TRIM(volume_24_array[OFFSET(pos)]) AS FLOAT64) AS volume_24h,

  
  
  COALESCE(
    SAFE.PARSE_TIMESTAMP('%Y-%m-%dT%H:%M:%E*S%Ez', TRIM(updates_array[OFFSET(pos)])),
    SAFE.PARSE_TIMESTAMP('%Y-%m-%dT%H:%M:%SZ', TRIM(updates_array[OFFSET(pos)])),
    SAFE_CAST(TRIM(updates_array[OFFSET(pos)]) AS TIMESTAMP)
  ) AS last_refreshed
FROM 
  raw_data,
  UNNEST(names_array) AS val_name WITH OFFSET pos;