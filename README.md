# 🏙️ Airbnb NYC 2019 Analysis

### **📌 Business Concept: Neighborhood Distribution**

Neighborhood analysis helps us understand where Airbnb properties are concentrated, which affects competition, pricing, and customer choices.

### **📌 Common Use Cases: Neighborhood Distribution**

- Identifying high-demand areas for property investment.
- Understanding competitive markets vs. underserved regions.
- Supporting pricing strategy with supply concentration insights.

### Task

## 1. Finding Top Neighborhoods with the Most Listings

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
ORDER BY total_listings DESC;

```
**Result :**


