----------------
--- ANALYZING---
----------------

-- Task 1: Total Listings per Neighbourhood
SELECT 
  neighbourhood_group,
  neighbourhood,
  COUNT(id) AS total_listings
FROM `New.AB_NYC_2019`
GROUP BY neighbourhood_group, neighbourhood
ORDER BY total_listings DESC
;

-- Task 2: Price Comparison Across Boroughs
SELECT 
  neighbourhood_group,
  ROUND(AVG(price), 2) AS avg_price,
  ROUND(MIN(price), 2) AS min_price,
  ROUND(MAX(price), 2) AS max_price
FROM `New.AB_NYC_2019`
WHERE price > 0 AND price < 1000
GROUP BY neighbourhood_group
ORDER BY avg_price DESC
;

-- Task 3: Top Hosts by Estimated Revenue
SELECT 
  host_id,
  host_name,
  SUM(CAST(price AS FLOAT64) * CAST(minimum_nights AS FLOAT64)) AS est_revenue
FROM (
  SELECT *
  FROM `New.AB_NYC_2019`
  WHERE price BETWEEN 10 AND 1000
) AS f
GROUP BY host_id, host_name
ORDER BY est_revenue DESC
;

-- Task 4: Growth Trend by Year
SELECT
    EXTRACT(YEAR FROM SAFE_CAST(last_review AS DATE)) AS year,
    COUNT(id) AS total_listings
FROM `New.AB_NYC_2019`
WHERE last_review IS NOT NULL
GROUP BY year
ORDER BY year
;

-- Task 5: Borough Price Ranking
SELECT 
  x.neighbourhood_group,
  x.avg_price,
  RANK() OVER(ORDER BY x.avg_price DESC) AS price_rank
FROM (
  SELECT 
    neighbourhood_group,
    ROUND(AVG(CAST(price AS FLOAT64)), 2) AS avg_price
  FROM `New.AB_NYC_2019`
  WHERE price BETWEEN 10 AND 1000
  GROUP BY neighbourhood_group
) AS x
;

-- Task 6: Room Type Price Quartiles
SELECT 
  y.room_type,
  y.avg_price,
  y.total_listings,
  NTILE(4) OVER (ORDER BY y.avg_price) AS price_quartile
FROM(
  SELECT 
    room_type,
    ROUND(AVG(CAST(price AS FLOAT64)), 2) AS avg_price,
    COUNT(id) AS total_listings
  FROM `New.AB_NYC_2019`
  WHERE price BETWEEN 10 AND 100
  GROUP BY room_type
) AS y
;

-- Task 7: Average Availability by Borough and Room Type
SELECT 
  neighbourhood_group,
  room_type,
  ROUND(AVG(CAST(availability_365 AS FLOAT64)), 1) AS avg_available
FROM `New.AB_NYC_2019`
GROUP BY neighbourhood_group, room_type
ORDER BY neighbourhood_group, room_type
;

-- Task 8: Price Distribution by Borough (Percentiles)
SELECT
    neighbourhood_group,
    PERCENTILE_CONT(CAST(price AS FLOAT64), 0.25) OVER (PARTITION BY neighbourhood_group) AS p25_price,
    PERCENTILE_CONT(CAST(price AS FLOAT64), 0.50) OVER (PARTITION BY neighbourhood_group) AS median_price,
    PERCENTILE_CONT(CAST(price AS FLOAT64), 0.75) OVER (PARTITION BY neighbourhood_group) AS p75_price
FROM `New.AB_NYC_2019`
WHERE price BETWEEN 10 AND 1000
GROUP BY neighbourhood_group, price
LIMIT 10
;

-- Task 9: Host Tier Distribution
SELECT
    CASE 
        WHEN calculated_host_listings_count >= 10 THEN '10+ listings'
        WHEN calculated_host_listings_count >= 3  THEN '3-9 listings'
        WHEN calculated_host_listings_count = 2   THEN '2 listings'
        ELSE 'Single listing'
    END AS host_tier,
    COUNT(DISTINCT host_id) AS hosts,
    COUNT(*) AS listings
FROM `New.AB_NYC_2019`
GROUP BY host_tier
ORDER BY listings DESC
;
