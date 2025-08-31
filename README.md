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


### **Task 2 — Price Comparison Across Boroughs**

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


### **Task 3 — Top Hosts by Estimated Revenue**

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



### **Task 4 — Growth trend by year (using review year as activity proxy)** 

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
