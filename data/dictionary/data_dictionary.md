📘 Data Dictionary — Supply Chain Analytics Project

This document describes the structure and meaning of all fields used in the cleaned datasets located in:

data/processed/


These datasets form the foundation of the ETL pipeline, EDA analysis, SQL models, and Power BI dashboard.

## 1. orders_clean.csv

Description: Customer orders with key operational and financial metrics.

Column	Type	Description	Example
order_id	Integer	Unique ID for each order	102344
order_date	Date	Date on which the order was placed	2024-03-15
customer_region	String	Geographic customer region (North, South, West, East)	West
sku	String	Product SKU identifier	SKU-10327
quantity_ordered	Integer	Number of units ordered	40
unit_price	Float	Price per unit	11.25
order_value	Float	Total revenue from the order (qty × price)	450.00
priority_flag	String	Indicates if the order is HIGH or NORMAL priority	HIGH
expected_ship_date	Date	Expected shipping date	2024-03-16
actual_ship_date	Date	Actual date when the product shipped	2024-03-17
shipping_delay_days	Integer	(actual_ship_date − expected_ship_date)	1
is_shipping_delayed	Boolean	TRUE if delay > 0	TRUE
is_completed	Boolean	TRUE if the order was completed	TRUE
is_cancelled	Boolean	TRUE if the order was cancelled	FALSE
is_returned	Boolean	TRUE if the order was returned	FALSE
## 2. inventory_clean.csv

Description: Inventory levels, status, and replenishment metadata for all SKUs.

Column	Type	Description	Example
sku	String	Unique product identifier	SKU-10327
supplier_id	Integer	Supplier providing this SKU	32
inventory_level	Integer	Current stock level	1,250
reorder_point	Integer	Threshold below which reorder is triggered	400
reorder_qty	Integer	Suggested reorder quantity	800
on_order_qty	Integer	Quantity currently on the way from supplier	600
lead_time_days	Integer	Average supplier lead time	4
inventory_status	String	Healthy, Low, Critical, or Out-of-Stock	Healthy
reorder_flag	Boolean	TRUE if inventory_level <= reorder_point	FALSE
days_of_cover_estimate	Float	Predicted days inventory will last	12.5
## 3. shipments_clean.csv

Description: Shipment performance data capturing delivery reliability and OTIF indicators.

Column	Type	Description	Example
shipment_id	Integer	Unique shipment identifier	50482
order_id	Integer	ID linking shipment to an order	102344
expected_delivery_date	Date	Target delivery date	2024-03-20
actual_delivery_date	Date	Final date shipment arrived	2024-03-21
delivery_delay_days	Integer	Delay in days	1
is_delayed	Boolean	TRUE if delay > 0	TRUE
delivered_on_time_flag	Boolean	TRUE if delivery delay ≤ 0	FALSE
carrier	String	Shipping carrier name	FedEx
supplier_id	Integer	Supplier responsible for shipping	32
## 4. suppliers_clean.csv

Description: Supplier metadata including reliability and region mapping.

Column	Type	Description	Example
supplier_id	Integer	Unique identifier for supplier	32
supplier_name	String	Name of supplier	Quantum Industrial Supplies
supplier_region	String	Geographic region of supplier	Midwest
reliability_score	Float	Supplier performance rating (0–1)	0.82
avg_lead_time_days	Integer	Average lead time for deliveries	4
## Relationships Summary

The datasets connect as follows:

suppliers_clean (supplier_id)
     ↓               ↓
inventory_clean (supplier_id) ← orders_clean (sku) → shipments_clean (order_id)


This enables full supply chain analysis across:

Orders

Shipments

Inventory

Suppliers

## Business Purpose

This dictionary ensures clarity for:

Analysts

Engineers

BI developers

Interview reviewers

Anyone consuming the data

Clear documentation is a key part of production-quality analytics systems.

✔ Author

Saicharan Veldurthy
Daxwell Data Analyst Assessment, 2024