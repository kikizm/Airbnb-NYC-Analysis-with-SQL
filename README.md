# 🏙️ Airbnb NYC 2019 Analysis

### **📌 Business Concept: Neighborhood Distribution**

Neighborhood analysis helps us understand where Airbnb properties are concentrated, which affects competition, pricing, and customer choices.

### **📌 Common Use Cases: Neighborhood Distribution**

- Identifying high-demand areas for property investment.
- Understanding competitive markets vs. underserved regions.
- Supporting pricing strategy with supply concentration insights.

### Task

### **1. Finding Top Neighborhoods with the Most Listings**

**Steps:**

- Count the number of listings by neighborhood group and neighborhood.
- Rank them to find the most concentrated areas.

**Query:**


```sql
SELECT 
    neighbourhood_group,
    neighbourhood,
    COUNT(id) AS total_listings
FROM `New.AB_NYC_2019`
GROUP BY neighbourhood_group, neighbourhood
ORDER BY total_listings DESC

```
**Result :**

<p align="center">
  <img src="https://github.com/user-attachments/assets/a40c0907-3b58-4ad4-9a91-6a2eb3a59c18" alt="Capture" width="600"/>
</p>

1 — Most listings are concentrated in Manhattan and Brooklyn, making it the dominant area for Airbnb properties. 


### **2. Price Comparison Across Boroughs**

**Steps:**

- Calculate average, minimum, and maximum prices by borough (neighbourhood_group).
- Exclude extreme outliers for a cleaner view.

**Query:**


```sql
SELECT 
  neighbourhood_group,
  ROUND(AVG(price), 2) AS avg_price,
  ROUND(MIN(price), 2) AS min_price,
  ROUND(MAX(price), 2) AS max_price
FROM `New.AB_NYC_2019`
WHERE price > 0 AND price < 1000
GROUP BY neighbourhood_group
ORDER BY avg_price DESC

```
**Result :**

<p align="center">
  <img src="https://github.com/user-attachments/assets/0e509328-dabe-4013-83d2-92ca44d0b6a5" alt="Capture" width="600"/>
</p>

2 — Manhattan is most expensive, Bronx, Queens, and Staten Island are cheaper, guiding customer targeting.


### **3. Top Hosts by Estimated Revenue**

**Steps:**

- Estimate host revenue as price * minimum_nights.
- Identify top 10 hosts.
- Focus on large hosts for retention or partnership (Pareto 80/20).

**Query:**


```sql
SELECT 
  host_id,
  host_name,
  SUM(CAST(price AS float64) * CAST(minimum_nights AS float64)) AS est_revenue
FROM (
  SELECT *
  FROM `New.AB_NYC_2019`
  WHERE price BETWEEN 10 AND 1000
) AS f
GROUP BY host_id, host_name
ORDER BY est_revenue DESC

```
**Result :**

<p align="center">
  <img src="https://github.com/user-attachments/assets/ce5eacf2-dfc9-4d90-a17d-d9b80035d552" alt="Capture" width="600"/>
</p>

3 — Revenue skews to a small set of large hosts (Pareto 80/20), highlighting who to focus retention and partnerships on.



### **4. Growth trend by year (using review year as activity proxy)** 

**Steps:**

- Use review as a proxy for listing activity.
- Count total listings per year.
- Exclude null dates.



**Query:**


```sql
SELECT
    EXTRACT(YEAR FROM SAFE_CAST(last_review AS DATE)) AS year,
    COUNT(id) AS total_listings
FROM `New.AB_NYC_2019`
WHERE last_review IS NOT NULL
GROUP BY year
ORDER BY year

```

**Result :**

<p align="center">
  <img src="https://github.com/user-attachments/assets/a3ee80de-a286-4787-b7bb-22590712194d" alt="Capture" width="244" height="216"/>
</p>

4 — Post-2015 growth signals rising adoption, supporting demand forecasting and market expansion.


### **5. Most to Least Expensive NYC Boroughs** 

**Steps:**

- Calculate average price per borough. Exclude extreme outliers (price <10 or >1000).
- Rank boroughs based on average price.


**Query:**


```sql
SELECT 
  x.neighbourhood_group,
  x.avg_price,
  RANK() OVER(ORDER BY x.avg_price DESC) AS price_rank
FROM (
  SELECT 
  neighbourhood_group,
  ROUND(AVG(CAST(price AS float64)), 2) AS avg_price
  FROM `New.AB_NYC_2019`
  WHERE price BETWEEN 10 AND 1000
  GROUP BY neighbourhood_group
) AS x

```

**Result :**


<p align="center">
  <img src="https://github.com/user-attachments/assets/9536d7bd-1425-4524-a721-21c19f52f0cf" alt="Capture" width="403" height="130"/>
</p>

5 — Manhattan is ranked highest in average price, followed by Brooklyn, highlighting premium vs. budget boroughs.



### **6. Room Types Segmented by Price** 

**Steps:**

- Analyze Airbnb listings by room type. Determine average price and total listings per room type.
- Divide room types into four price tiers to understand pricing segmentation.


  **Query:**


```sql
SELECT 
  y.room_type,
  y.avg_price,
  y.total_listings,
  NTILE(4) OVER (ORDER BY y.avg_price) AS price_quartile
FROM(
  SELECT 
    room_type,
    ROUND(AVG(CAST(price AS float64)), 2) AS avg_price,
    COUNT(id) AS total_listings
    FROM `New.AB_NYC_2019`
    WHERE price BETWEEN 10 AND 100
    GROUP BY room_type
) AS y

```

**Result :**

<p align="center">
  <img src="https://github.com/user-attachments/assets/c1a0ee35-7d26-46fd-9f04-1cb61fe7d974" alt="Capture" width="502" height="85"/>
</p>

6 — Entire homes are the priciest, shared rooms the cheapest, showing clear pricing tiers for different room types.


### **7. Borough & Room Type Availability Patterns**

**Steps:**

- Examine how many days listings are available per year, by borough and room type.
- Calculate average availability to understand listing activity and potential booking opportunities.


 **Query:**


```sql
SELECT 
  neighbourhood_group,
  room_type,
  ROUND(AVG(CAST(availability_365 AS float64)), 1) AS avg_available
FROM `New.AB_NYC_2019`
GROUP BY neighbourhood_group, room_type
ORDER BY neighbourhood_group, room_type

```

**Result :**


<p align="center">
  <img src="https://github.com/user-attachments/assets/343fd5ca-001c-4323-b62d-c6806631a7ce" alt="Capture" width="502" height="85"/>
</p>


7 — Availability varies across boroughs and room types, helping identify where supply is high or limited for better booking strategies.


### **8. NYC Airbnb Pricing Quartiles Across Boroughs**

**Steps:**

- Analyze price distribution per borough. Calculate 25th percentile, median, and 75th percentile to understand price spread.
- Focus on standard range by excluding extreme outliers (price <10 or >1000).


**Query:**


```sql
SELECT
    neighbourhood_group,
    PERCENTILE_CONT(CAST(price AS FLOAT64), 0.25) OVER (PARTITION BY neighbourhood_group) AS p25_price,
    PERCENTILE_CONT(CAST(price AS FLOAT64), 0.50) OVER (PARTITION BY neighbourhood_group) AS median_price,
    PERCENTILE_CONT(CAST(price AS FLOAT64), 0.75) OVER (PARTITION BY neighbourhood_group) AS p75_price
FROM `New.AB_NYC_2019`
WHERE price BETWEEN 10 AND 1000
GROUP BY neighbourhood_group, price
LIMIT 10

```

**Result :**

<p align="center">
  <img src="https://github.com/user-attachments/assets/74b59782-b0b2-469d-9f23-918878d94824" alt="Capture" width="502" height="234"/>
</p>


8 — Price distribution varies by borough, highlighting where mid-range or premium listings dominate and helping guide pricing strategies.


### **9. Airbnb Host Tier Analysis**

**Steps:**

- Segment hosts based on the number of listings they manage.
- Count how many hosts are in each tier and how many listings they have.
- Identify concentration of listings among large vs. small hosts.


**Query:**


```sql
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
GROUP BY CASE 
        WHEN calculated_host_listings_count >= 10 THEN '10+ listings'
        WHEN calculated_host_listings_count >= 3  THEN '3-9 listings'
        WHEN calculated_host_listings_count = 2   THEN '2 listings'
        ELSE 'Single listing'
    END
ORDER BY listings DESC

```

**Result :**

<p align="center">
  <img src="https://github.com/user-attachments/assets/b4e87238-c812-4e6f-bf28-99189b0bc980" alt="Capture" width="405" height="109"/>
</p>


9 — Most listings are managed by hosts with multiple properties, showing that a small number of large hosts dominate the market, highlighting targets for retention and partnerships.
