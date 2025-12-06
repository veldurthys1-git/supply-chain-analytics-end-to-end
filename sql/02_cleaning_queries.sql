-- ============================================================
-- DATA QUALITY & CLEANING QUERIES
-- These checks validate processed datasets before analysis.
-- ============================================================

-- ==========================
-- 1. NULL VALUE ANALYSIS
-- ==========================

-- Inventory NULL checks
SELECT 
    SUM(CASE WHEN sku IS NULL THEN 1 ELSE 0 END) AS null_sku,
    SUM(CASE WHEN supplier_id IS NULL THEN 1 ELSE 0 END) AS null_supplier,
    SUM(CASE WHEN inventory_level IS NULL THEN 1 ELSE 0 END) AS null_inventory_level
FROM inventory_clean;

-- Orders NULL checks
SELECT
    SUM(CASE WHEN order_id IS NULL THEN 1 END) AS null_order_id,
    SUM(CASE WHEN sku IS NULL THEN 1 END) AS null_sku,
    SUM(CASE WHEN order_date IS NULL THEN 1 END) AS null_order_date,
    SUM(CASE WHEN quantity_ordered IS NULL THEN 1 END) AS null_quantity
FROM orders_clean;

-- Shipment NULL checks
SELECT
    SUM(CASE WHEN shipment_id IS NULL THEN 1 END) AS null_shipment_id,
    SUM(CASE WHEN order_id IS NULL THEN 1 END) AS null_order_id,
    SUM(CASE WHEN expected_delivery_date IS NULL THEN 1 END) AS null_expected_delivery
FROM shipments_clean;

-- Supplier NULL checks
SELECT
    SUM(CASE WHEN supplier_id IS NULL THEN 1 END) AS null_supplier_id,
    SUM(CASE WHEN reliability_score IS NULL THEN 1 END) AS null_reliability
FROM suppliers_clean;


-- ==========================
-- 2. DUPLICATE DETECTION
-- ==========================

-- Duplicate orders
SELECT order_id, COUNT(*) 
FROM orders_clean
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Duplicate shipments
SELECT shipment_id, COUNT(*)
FROM shipments_clean
GROUP BY shipment_id
HAVING COUNT(*) > 1;

-- Duplicate inventory records (same sku + date)
SELECT sku, date, COUNT(*)
FROM inventory_clean
GROUP BY sku, date
HAVING COUNT(*) > 1;


-- ==========================
-- 3. REFERENTIAL INTEGRITY CHECKS
-- ==========================

-- Orders referencing SKUs not in inventory
SELECT o.sku
FROM orders_clean o
LEFT JOIN inventory_clean i ON o.sku = i.sku
WHERE i.sku IS NULL
GROUP BY o.sku;

-- Shipments referencing unknown orders
SELECT s.order_id
FROM shipments_clean s
LEFT JOIN orders_clean o ON s.order_id = o.order_id
WHERE o.order_id IS NULL
GROUP BY s.order_id;

-- Shipments referencing unknown suppliers
SELECT s.supplier_id
FROM shipments_clean s
LEFT JOIN suppliers_clean sup ON s.supplier_id = sup.supplier_id
WHERE sup.supplier_id IS NULL
GROUP BY s.supplier_id;


-- ==========================
-- 4. OUTLIER ANALYSIS
-- ==========================

-- Unusually high inventory levels
SELECT *
FROM inventory_clean
WHERE inventory_level > (reorder_qty * 5)
ORDER BY inventory_level DESC;

-- Orders with extreme unit prices
SELECT *
FROM orders_clean
WHERE unit_price > 500
ORDER BY unit_price DESC;

-- Shipping costs outliers
SELECT *
FROM shipments_clean
WHERE shipping_cost > 500
ORDER BY shipping_cost DESC;


-- ==========================
-- 5. DATE CONSISTENCY CHECKS
-- ==========================

-- Orders where actual ship date < order date
SELECT *
FROM orders_clean
WHERE actual_ship_date < order_date;

-- Shipments received before they were shipped
SELECT *
FROM shipments_clean
WHERE actual_delivery_date < shipment_date;

-- Delivery dates earlier than expected date
SELECT *
FROM shipments_clean
WHERE actual_delivery_date < expected_delivery_date;


-- ==========================
-- 6. BASIC DESCRIPTIVE STATS (VALIDATION)
-- ==========================

-- Inventory distribution health check
SELECT 
    AVG(inventory_level) AS avg_inventory,
    MIN(inventory_level) AS min_inventory,
    MAX(inventory_level) AS max_inventory,
    COUNT(*) AS total_rows
FROM inventory_clean;

-- Order value distribution
SELECT
    AVG(order_value) AS avg_order_value,
    MIN(order_value) AS min_order_value,
    MAX(order_value) AS max_order_value,
    SUM(order_value) AS total_revenue
FROM orders_clean;

-- Shipment delay statistics
SELECT
    AVG(delivery_delay_days) AS avg_delay,
    MIN(delivery_delay_days) AS min_delay,
    MAX(delivery_delay_days) AS max_delay
FROM shipments_clean
WHERE delivery_delay_days IS NOT NULL;
