# SnapEats Data Analysis

---

## Table of Contents

* Project Overview
* Data Source
* Tools
* Data Cleaning
* Exploratory Data Analysis
* Results
* Recommendations
* Limitations
* References

---

## Project Overview

*image placeholder*

The purpose of this analysis is to evaluate the operational and business performance of **SnapEats**, a food delivery platform.
The project focuses on analyzing key metrics related to **customer behavior, restaurant performance, rider efficiency, and order trends** using SQL.
Insights from the analysis aim to support **data-driven decision-making** for improving customer satisfaction, optimizing delivery operations, and increasing overall revenue.

---

## Data Source

**SQL Dataset:**
The project uses a relational SQL database comprising the following tables:

* **customers:** Customer information and registration dates.
* **restaurants:** Restaurant details, including name, city, and operating hours.
* **orders:** Order information such as items, timestamps, and total amount.
* **riders:** Rider details and sign-up information.
* **deliveries:** Delivery details including status, time, and associated riders.

The dataset is stored as `.sql` scripts that include schema definitions and analytical queries.

---

## Tools

* **SQL Server / PostgreSQL:** Used for executing analytical queries, joins, and aggregations.

<!-- Hidden Content

* **Power BI (optional):** Can be used for creating visual dashboards based on SQL outputs.

-->
---

## Data Cleaning

Data cleaning and preparation steps included:

* Checking for and handling **NULL values** in key tables.
* **Removing incomplete or invalid records** from customer and order datasets.
* Ensuring **foreign key relationships** were properly maintained.
* Formatting **date and time fields** for accurate temporal analysis.
* Validating **numeric values** (e.g., order amounts, delivery times) for consistency.

---

## Exploratory Data Analysis

Key questions explored during analysis:

* Which dishes are most frequently ordered by customers?
* What are the **most active time slots** for placing orders?
* Who are the **top customers** based on spending and order frequency?
* Which **restaurants generate the highest revenue** overall and by city?
* How do **delivery success rates and average delivery times** vary by rider?
* What are the **monthly trends** in orders and revenues?
* Which **customer segments** contribute most to total spending?
* How do **order cancellations and churn** differ between years?
* Which **dishes and regions** show seasonal or city-specific popularity?

---

## Results

* Identified **most popular dishes** and peak **order times** across different cities.
* Determined **high-value customers** and frequent order patterns.
* Ranked **restaurants** by total revenue, both city-wise and globally.
* Calculated **average delivery times** and **efficiency rankings** for riders.
* Analyzed **customer churn**, revealing retention and re-engagement patterns.
* Segmented customers into **Gold** and **Silver** categories based on spending.
* Measured **monthly restaurant growth ratios** and **revenue trends**.

---

## Recommendations

Based on the analysis, the following actions are suggested:

* **Promote top-performing dishes** and offer bundle deals during peak times.
* **Incentivize riders** with the fastest delivery times to improve service quality.
* **Retarget inactive customers** through re-engagement campaigns.
* **Enhance restaurant visibility** for high-growth outlets and cities.
* **Monitor monthly KPIs** (orders, revenue, delivery efficiency) for continuous improvement.

---

## Limitations

* The dataset covers a **limited time period**, which may not reflect long-term patterns.
* Potential **data entry inconsistencies** could influence aggregation accuracy.
* Some analyses assume **complete delivery and order timestamps**, which may vary across records.

---

## References

* SQL documentation for **window functions**, **CTEs**, and **date/time operations**.
* PostgreSQL and SQL Server official resources for query optimization.
* Power BI documentation for creating **performance dashboards**.

---

