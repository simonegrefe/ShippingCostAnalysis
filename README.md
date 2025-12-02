# 📦 Shipping Cost Analysis Project

## 🧾 Project Overview

This project focuses on analyzing how shipping cost structures affect business profitability, particularly when multiple items are shipped together. Using **SQL** for data cleaning, transformation, and modeling, and **Tableau** for visualization, the analysis compares two shipping cost models — a **Baseline Model** and a **Hypothesis Model** — to uncover cost-saving and profit-improving opportunities.

Four raw CSV datasets (`sales`, `products`, `customers`, and `state-region mapping`) were merged and normalized to create a consistent analytical dataset. Missing values in key fields such as quantity, sales, and unit price were recalculated, and profit per unit was derived from landed and unit costs.

Two models were then applied:

- **Baseline Model:** Each additional unit in a shipment incurs **70%** of the individual shipping cost.
- **Hypothesis Model:** Introduces **tiered discounts** based on quantity thresholds (from `0.8` to `0.3` factor).

The resulting dataset was visualized in Tableau to compare profitability across both models and identify patterns by order size and region.

Objective Question: *How can we improve business profit based on the shipping of multiple items?*



## 🎯 Objectives

- **Evaluate** how different shipping cost models (Baseline vs. Hypothesis) impact overall business profitability.
- **Analyze** the relationship between shipping costs, product quantity, and profit to identify cost-efficient strategies for multi-item orders.
- **Visualize** key insights in Tableau to support data-driven decision-making.
- **Recommend** adjustments to shipping cost structures that improve profit margins without reducing customer satisfaction.



## 📂 Data Sources

| **Table** | **Description** |
| --- | --- |
| `sales` | Contains information about each sale, including product, quantity, and price. |
| `customers` | Includes customer identifiers and location information. |
| `products` | Contains product descriptions, landed and shipping costs, weight, and category. |
| `state_region_mapping` | Maps multiple variations of state codes and descriptions to standardized values. |




## 🔄 Transformation Process

The transformation process involved cleaning, normalizing, and enriching data from four raw CSV files — `sales`, `products`, `customers`, and `state_region_mapping` — to prepare it for profitability and shipping-cost analysis in Tableau.

### 1. Data Cleaning and Integration

- Combined all datasets using unique identifiers.
- Replaced missing product descriptions using data from the product table.
- Filtered out invalid records where `quantity`, `sales`, or `unit_price` were missing.

### 2. Data Normalization

- Recalculated missing values in key numeric fields:
    - If **quantity** was missing → `sales / unit_price`.
    - If **sales** was missing → `quantity * unit_price`.
    - If **unit_price** was missing → `sales / quantity`.
- Converted all cost-related fields (shipping and landed costs) to **decimal format** for consistency.

### 3. Feature Creation

- Created a new field `profit_per_unit = unit_price - landed_cost` to measure per-item profitability.
- Added geolocation and regional mapping data for regional performance analysis.

### 4. Model Preparation

- Filtered dataset to include only valid entries with **positive quantity** and **shipping cost** values.
- Prepared output metrics for both shipping models (Baseline and Hypothesis), including:
    - Shipping cost per model
    - Profit before shipping
    - Profit after shipping (for each model)

### 5. Aggregation in Tableau

- Imported the transformed dataset into **Tableau** for visualization and analysis.
- aggregated **product line** to the **invoice/order level (Order)** using **Level of Detail (LOD)** expressions.
- LOD calculations ensured accurate aggregation of measures, allowing precise comparison between the **Baseline** and **Hypothesis** shipping models.



## 📊 Visualization

![Dashboard pdf preview](Tableau_dashboard)


📁 Tableau Dashboard: [**Shipping Cost Analysis**](https://public.tableau.com/app/profile/simone.grefe.schoerner/viz/BarkAndPurr-ShippingCostPricingAnalysis/productbundleshypothesismodel)



## 🧭 Key Takeaways

- The **Hypothesis Model** demonstrates strong potential for **cost optimization** in multi-item shipments.
- By applying **tiered shipping discounts**, businesses can reduce total shipping expenses while maintaining profit margins.
- **Larger orders** benefit the most, suggesting that encouraging customers to purchase multiple items per order can further improve profitability.
- A **data-driven shipping strategy** helps balance customer value and operational efficiency, supporting sustainable profit growth.



## 💡 Recommendations

Based on the analysis of shipping cost models and profitability:

- **Encourage multi-item purchases** by offering **product bundles** or **volume-based discounts**, leveraging lower incremental shipping costs per item.
- **Promote combined shipping options** to allow customers to consolidate multiple purchases into a single shipment.
- **Segment customers** by order behavior to target promotions that maximize profitability among frequent or high-volume buyers.
- **Reevaluate pricing strategy** to align with the cost advantages of larger orders while maintaining competitiveness.


## 🧩 Tools & Technologies

- **DB Browser SQLite** - Data Base Management System to connect all csv-files and write SQL query
- **SQL** – Data cleaning, integration, transformation, and profit modeling.
- **Tableau** – Visualization and profitability comparison across shipping models.



## 🗂️ Directory Structure

```
shipping-cost-analysis/
│
├── raw-csv-files/
│      ├── raw_sales.csv
│      ├── raw_products.csv
│      ├── raw_customers.csv
│      └── raw_state_region_mapping.csv
│
├── sql_data-preparation.sql        
│
├── dataset_shipping_cost_analysis.csv  
│
├── Tableau_dashboard.pdf           
│
├── README.md                       

```




## 🪪 License

This project is licensed for **educational and demonstration purposes only**. All data used is **fictional** and does not represent real business information.
