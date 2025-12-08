Data Dictionary — Supply Chain Analytics Project

This document defines all fields used in the cleaned datasets located in:

data/processed/


These datasets feed into the ETL pipeline, EDA notebooks, SQL models, and the Power BI dashboard.

1. orders_clean.csv

Description: Customer order master dataset containing operational, fulfillment, and revenue metrics.

Orders Data Dictionary
Column	Type	Description	Example
order_id	Integer	Unique ID for each order	102344
order_date	Date	Date when the order was placed	2024-03-15
customer_region	String	Geographic customer region	West
sku	String	SKU identifier	SKU-10327
quantity_ordered	Integer	Number of units ordered	40
unit_price	Float	Price per unit	11.25
order_value	Float	quantity × unit_price	450.00
priority_flag	String	HIGH or NORMAL	HIGH
expected_ship_date	Date	Target ship date	2024-03-16
actual_ship_date	Date	Actual ship date	2024-03-17
shipping_delay_days	Integer	actual − expected	1
is_shipping_delayed	Boolean	TRUE if delay > 0	TRUE
is_completed	Boolean	Order completed	TRUE
is_cancelled	Boolean	Order cancelled	FALSE
is_returned	Boolean	Order returned	FALSE
2. inventory_clean.csv

Description: SKU-level inventory dataset with replenishment indicators and status classification.

Inventory Data Dictionary
Column	Type	Description	Example
sku	String	Unique product identifier	SKU-10327
supplier_id	Integer	Supplier reference	32
inventory_level	Integer	Current stock	1250
reorder_point	Integer	Reorder trigger	400
reorder_qty	Integer	Suggested reorder	800
on_order_qty	Integer	Qty incoming from supplier	600
lead_time_days	Integer	Avg supplier lead time	4
inventory_status	String	Healthy / Low / Critical / Out-of-Stock	Healthy
reorder_flag	Boolean	inventory_level ≤ reorder_point	FALSE
days_of_cover_estimate	Float	Predicted days before stockout	12.5
3. shipments_clean.csv

Description: Shipment tracking dataset including delivery performance and OTIF metrics.

Shipments Data Dictionary
Column	Type	Description	Example
shipment_id	Integer	Unique shipment ID	50482
order_id	Integer	Linked order	102344
expected_delivery_date	Date	Target delivery date	2024-03-20
actual_delivery_date	Date	Actual delivery date	2024-03-21
delivery_delay_days	Integer	Delay in days	1
is_delayed	Boolean	TRUE if delay > 0	TRUE
delivered_on_time_flag	Boolean	TRUE if delay ≤ 0	FALSE
carrier	String	Shipping carrier	FedEx
supplier_id	Integer	Supplier responsible	32
4. suppliers_clean.csv

Description: Supplier profile dataset including reliability, regional mapping, and lead times.

Suppliers Data Dictionary
Column	Type	Description	Example
supplier_id	Integer	Supplier ID	32
supplier_name	String	Supplier name	Quantum Industrial Supplies
supplier_region	String	Supplier geographic region	Midwest
reliability_score	Float	Performance score (0–1)	0.82
avg_lead_time_days	Integer	Average lead time	4
5. Dataset Relationships
suppliers_clean (supplier_id)
        ↓
inventory_clean (supplier_id)
        ↓
orders_clean (sku) ←→ shipments_clean (order_id)


This enables end-to-end supply chain analysis across:

Orders

Shipments

Inventory

Supplier performance

Author

Saicharan Veldurthy
Daxwell Data Analyst Assessment — 2024
