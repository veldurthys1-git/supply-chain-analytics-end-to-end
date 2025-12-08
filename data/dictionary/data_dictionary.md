📘 Data Dictionary — Supply Chain Analytics Project

This document defines all fields used in the cleaned datasets located in:

data/processed/


These datasets are the foundation for the ETL pipeline, EDA notebooks, SQL models, and the Power BI dashboard.

1️⃣ orders_clean.csv

Description: Customer order master dataset containing operational, fulfillment, and financial details.

📄 Orders Data Dictionary
Column	Type	Description	Example
order_id	Integer	Unique ID for each order	102344
order_date	Date	Date when the order was placed	2024-03-15
customer_region	String	Geographic region of customer	West
sku	String	Unique product SKU identifier	SKU-10327
quantity_ordered	Integer	Number of units ordered	40
unit_price	Float	Price per unit	11.25
order_value	Float	Revenue per order (quantity × unit_price)	450.00
priority_flag	String	"HIGH" or "NORMAL" priority	HIGH
expected_ship_date	Date	Expected shipping date	2024-03-16
actual_ship_date	Date	Date when the order was actually shipped	2024-03-17
shipping_delay_days	Integer	actual_ship_date - expected_ship_date	1
is_shipping_delayed	Boolean	TRUE if delay > 0	TRUE
is_completed	Boolean	TRUE if order was fulfilled	TRUE
is_cancelled	Boolean	TRUE if order was cancelled	FALSE
is_returned	Boolean	TRUE if order was returned	FALSE
2️⃣ inventory_clean.csv

Description: SKU-level inventory dataset with replenishment indicators and health classification.

📄 Inventory Data Dictionary
Column	Type	Description	Example
sku	String	Unique product identifier	SKU-10327
supplier_id	Integer	Supplier responsible for the SKU	32
inventory_level	Integer	Current on-hand quantity	1250
reorder_point	Integer	Trigger threshold for replenishment	400
reorder_qty	Integer	Suggested reorder quantity	800
on_order_qty	Integer	Quantity already ordered from supplier	600
lead_time_days	Integer	Average supplier lead time	4
inventory_status	String	Healthy / Low / Critical / Out-of-Stock	Healthy
reorder_flag	Boolean	TRUE if inventory_level <= reorder_point	FALSE
days_of_cover_estimate	Float	Estimated stock cover in days	12.5
3️⃣ shipments_clean.csv

Description: Shipment performance dataset including delivery reliability and OTIF calculation fields.

📄 Shipments Data Dictionary
Column	Type	Description	Example
shipment_id	Integer	Unique shipment ID	50482
order_id	Integer	Order linked to the shipment	102344
expected_delivery_date	Date	Target delivery date	2024-03-20
actual_delivery_date	Date	Actual delivery arrival date	2024-03-21
delivery_delay_days	Integer	Delay in days	1
is_delayed	Boolean	TRUE if delivery_delay_days > 0	TRUE
delivered_on_time_flag	Boolean	TRUE if on time	FALSE
carrier	String	Shipment carrier	FedEx
supplier_id	Integer	Supplier responsible for the shipment	32
4️⃣ suppliers_clean.csv

Description: Supplier metadata including regional details, reliability, and lead time profile.

📄 Suppliers Data Dictionary
Column	Type	Description	Example
supplier_id	Integer	Supplier identifier	32
supplier_name	String	Full supplier name	Quantum Industrial Supplies
supplier_region	String	Supplier geographic region	Midwest
reliability_score	Float	Supplier performance rating (0–1 scale)	0.82
avg_lead_time_days	Integer	Historical avg lead time	4
🔗 Dataset Relationships
suppliers_clean (supplier_id)
          ↓
inventory_clean (supplier_id)
          ↓
orders_clean (sku) ←→ shipments_clean (order_id)


This relational structure enables full supply chain visibility across:

Orders

Shipments

Inventory

Supplier performance

🎯 Business Purpose of the Data Dictionary

This document ensures clarity for:

Data analysts

Data engineers

BI developers

Hiring managers reviewing your assessment

Anyone exploring or extending the dataset

Clear documentation is a key part of production-quality analytics systems.

👤 Author

Saicharan Veldurthy
