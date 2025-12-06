Supply Chain Analytics Project

An end-to-end data analytics solution built for the Daxwell Data Analyst assessment, showcasing skills in:

Data Engineering (ETL)

Data Cleaning & Transformation

SQL Modeling

Exploratory Data Analysis (EDA)

Dashboard Development (Power BI)

Supply Chain Insights & KPI Reporting

This project simulates a real supply-chain environment involving orders, inventory, shipments, and supplier performance.

🧱 Project Architecture
DAXWELL-SUPPLYCHAIN-ANALYTICS
│
├── data
│   ├── raw/                # Raw datasets generated via Python
│   ├── processed/          # Cleaned datasets produced by ETL pipeline
│   └── dictionary/         # Data dictionary for all features
│
├── pipeline/
│   ├── extract.py
│   ├── transform.py
│   ├── load.py
│   ├── run_pipeline.py     # Orchestrates the ETL steps
│   └── config.yaml
│
├── sql/
│   ├── 01_create_tables.sql
│   ├── 02_cleaning_queries.sql
│   ├── 03_kpi_queries.sql
│   ├── 04_supplier_scorecard.sql
│   └── 05_inventory_performance.sql
│
├── notebooks/
│   ├── EDA_Inventory.ipynb
│   ├── EDA_Orders.ipynb
│   ├── KPI_Analysis.ipynb
│
├── dashboard/powerbi/
│   ├── supply_chain_dashboard.pbix
│   └── screenshots/
│       ├── executive_overview.png
│       ├── kpi_cards.png
│       ├── revenue_trend.png
│       ├── inventory_status_pie.png
│       ├── orders_revenue_page.png
│       ├── orders_trend.png
│       ├── revenue_by_region.png
│       ├── top_skus.png
│
├── visuals/architecture/   # Pipeline/Model diagrams
├── README.md
└── requirements.txt

📦 1. Dataset Overview

The project includes four primary datasets (10k–50k rows each):

📌 orders_clean.csv

order_id, order_date

customer_region

sku

order_value

priority_flag

shipping_delay_days

is_completed, is_cancelled, is_returned

📌 inventory_clean.csv

sku, supplier_id

inventory_level

reorder_point

reorder_qty

lead_time_days

inventory_status

📌 shipments_clean.csv

order_id

shipment_id

actual_delivery_date

expected_delivery_date

delivery_delay_days

is_delivered, is_delayed

delivered_on_time_flag

carrier

📌 suppliers_clean.csv

supplier_id

supplier_name

region

reliability_score

avg_lead_time_days

All raw datasets were generated using Python to simulate realistic supply chain operations.

⚙️ 2. ETL Pipeline

The ETL pipeline includes:

🔹 extract.py

Loads raw CSV files into pandas DataFrames.

🔹 transform.py

Cleans data and applies transformations:

Standardizing date formats

Deriving flags (OTIF, delay)

Inventory risk scoring

KPI feature creation

🔹 load.py

Exports cleaned datasets to /processed.

🔹 run_pipeline.py

Runs the full ETL workflow using config.yaml.

📊 3. Exploratory Data Analysis (EDA)

Performed using Jupyter notebooks:

📌 EDA_Inventory

Inventory levels over time

Status distribution

Days of cover

Risk segmentation

📌 EDA_Orders

Daily order volume

Revenue patterns

Cancellation trends

Region performance

📌 KPI_Analysis

OTIF %

Delivery delays

Supplier reliability

High-risk SKU identification

Screenshots of EDA visuals are included in the visuals/charts_from_notebook/ folder.

🗂 4. SQL Modeling

SQL scripts include:

Table creation

Cleaning & standardization

KPI calculations

Supplier performance scorecard

Inventory performance model

These scripts simulate how a real analytics engineer prepares production data for BI tools.

📊 5. Power BI Dashboard

The final dashboard has two pages, designed for executives and supply-chain analysts.

⭐ PAGE 1 — Executive Overview
KPIs:

Total Revenue

Total Orders

OTIF %

Avg Delivery Delay

High Risk Inventory %

Visuals:

📈 Daily Revenue Trend

🥧 Inventory Status Distribution

🔍 Slicers: Date, Region, SKU, Supplier

Screenshot:

dashboard/powerbi/screenshots/Full Executive Overview page.png

⭐ PAGE 2 — Orders & Revenue Analytics
Visuals:

📈 Daily Orders Trend

📊 Revenue by Region

🥯 Order Priority Mix

📊 Top 10 SKUs by Revenue

Screenshot:

dashboard/powerbi/screenshots/Full Orders & Revenue page.png

💡 6. Key Business Insights
📌 Revenue

Strong daily revenue performance (~$56M+ total).

Regional revenue concentration with variations in Northeast/Midwest.

📌 Orders

Daily orders vary between 240–300, indicating stable demand.

Priority orders represent < 5%, suggesting efficient planning.

📌 Inventory

Majority of inventory is Healthy (>80%).

~8% at critical or low levels → requires monitoring.

📌 Shipments & OTIF

~50% OTIF → indicates room for improvement.

Average delivery delay: 1.1 days.

These insights help optimize planning, supplier engagement, and logistics.

▶️ 7. Video Walkthrough

A 5–10 minute video demonstrates:

ETL pipeline

EDA exploration

Power BI dashboard

Business insights

📌 Link will be added here after recording.

🛠 8. How to Run the Project
Install dependencies
pip install -r requirements.txt

Run ETL pipeline
python pipeline/run_pipeline.py

Open Power BI dashboard

Open file:

dashboard/powerbi/supply_chain_dashboard.pbix

🧑‍🏫 9. Skills Demonstrated

Python (pandas, numpy)

SQL (analytics, modeling, KPI design)

Data Cleaning & Feature Engineering

ETL Pipeline Engineering

Exploratory Data Analysis

DAX Measures

Power BI Dashboard Design

Supply Chain Analytics

Business Storytelling

✔️ 10. Author

Saicharan Veldurthy
Daxwell Data Analyst Assessment — 2024