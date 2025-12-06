-- ============================================================
-- CREATE TABLES FOR PROCESSED DATASETS
-- These definitions align exactly with the processed CSV output
-- ============================================================

DROP TABLE IF EXISTS inventory_clean;
DROP TABLE IF EXISTS orders_clean;
DROP TABLE IF EXISTS shipments_clean;
DROP TABLE IF EXISTS suppliers_clean;

-- ==========================
-- INVENTORY TABLE
-- ==========================
CREATE TABLE inventory_clean (
    date DATE,
    sku VARCHAR(50),
    supplier_id VARCHAR(50),
    inventory_level INT,
    reorder_point INT,
    reorder_qty INT,
    on_order_qty INT,
    lead_time_days INT,
    reorder_flag BOOLEAN,
    inventory_status VARCHAR(50),
    days_of_cover_estimate FLOAT
);

-- ==========================
-- ORDERS TABLE
-- ==========================
CREATE TABLE orders_clean (
    order_id VARCHAR(50),
    order_date DATE,
    sku VARCHAR(50),
    quantity_ordered INT,
    unit_price DECIMAL(10,2),
    customer_region VARCHAR(50),
    order_status VARCHAR(50),
    fulfillment_center VARCHAR(50),
    expected_ship_date DATE,
    actual_ship_date DATE,
    priority_flag VARCHAR(20),
    order_value DECIMAL(12,2),
    shipping_delay_days FLOAT,
    is_high_priority BOOLEAN,
    is_cancelled BOOLEAN,
    is_returned BOOLEAN,
    is_completed BOOLEAN,
    is_shipping_delayed BOOLEAN
);

-- ==========================
-- SHIPMENTS TABLE
-- ==========================
CREATE TABLE shipments_clean (
    shipment_id VARCHAR(50),
    order_id VARCHAR(50),
    sku VARCHAR(50),
    supplier_id VARCHAR(50),
    shipment_date DATE,
    expected_delivery_date DATE,
    actual_delivery_date DATE,
    shipment_status VARCHAR(20),
    carrier VARCHAR(50),
    quantity_shipped INT,
    shipping_cost DECIMAL(10,2),
    delay_reason VARCHAR(255),
    delivery_delay_days FLOAT,
    is_delivered BOOLEAN,
    is_delayed BOOLEAN,
    is_lost BOOLEAN,
    is_in_transit BOOLEAN,
    delivered_on_time_flag BOOLEAN
);

-- ==========================
-- SUPPLIERS TABLE
-- ==========================
CREATE TABLE suppliers_clean (
    supplier_id VARCHAR(50),
    supplier_name VARCHAR(255),
    region VARCHAR(50),
    reliability_score INT,
    avg_lead_time_days INT,
    supplier_rating VARCHAR(20),
    contact_email VARCHAR(255),
    phone_number VARCHAR(50),
    contract_expiration DATE,
    supplier_rating_clean VARCHAR(20)
);
