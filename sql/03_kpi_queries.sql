-- ============================================================
-- KPI QUERIES FOR OPERATIONS, SUPPLY CHAIN, AND INVENTORY
-- These are high-value insights used by analysts & leadership.
-- ============================================================


-- ==========================
-- 1. REVENUE KPIs
-- ==========================

-- Total revenue
SELECT 
    SUM(order_value) AS total_revenue
FROM orders_clean
WHERE is_completed = TRUE;

-- Revenue by region
SELECT 
    customer_region,
    SUM(order_value) AS revenue
FROM orders_clean
WHERE is_completed = TRUE
GROUP BY customer_region
ORDER BY revenue DESC;

-- Revenue by SKU (top 10 products)
SELECT 
    sku,
    SUM(order_value) AS total_revenue
FROM orders_clean
WHERE is_completed = TRUE
GROUP BY sku
ORDER BY total_revenue DESC
LIMIT 10;


-- ==========================
-- 2. ORDER MANAGEMENT KPIs
-- ==========================

-- Completed vs Returned vs Cancelled
SELECT 
    order_status,
    COUNT(*) AS order_count
FROM orders_clean
GROUP BY order_status;

-- High priority orders delayed
SELECT 
    COUNT(*) AS delayed_high_priority_orders
FROM orders_clean
WHERE is_high_priority = TRUE
  AND is_shipping_delayed = TRUE;

-- Average order value
SELECT 
    AVG(order_value) AS avg_order_value
FROM orders_clean
WHERE is_completed = TRUE;


-- ==========================
-- 3. FULFILLMENT & LOGISTICS KPIs
-- ==========================

-- On-Time Shipment Rate (shipping perspective)
SELECT
    SUM(CASE WHEN shipping_delay_days <= 0 THEN 1 ELSE 0 END) * 100.0 /
    COUNT(*) AS on_time_ship_rate
FROM orders_clean
WHERE is_completed = TRUE;

-- Shipment delivered on time (OTD)
SELECT
    SUM(CASE WHEN delivered_on_time_flag = TRUE THEN 1 ELSE 0 END) * 100.0 /
    COUNT(*) AS on_time_delivery_rate
FROM shipments_clean
WHERE is_delivered = TRUE;

-- Overall OTIF (On Time In Full)
SELECT
    SUM(CASE WHEN delivered_on_time_flag = TRUE THEN 1 ELSE 0 END) * 100.0 /
    COUNT(*) AS OTIF_percentage
FROM shipments_clean
WHERE is_delivered = TRUE;


-- ==========================
-- 4. SHIPMENT DELAY & COST KPIs
-- ==========================

-- Average delivery delay (days)
SELECT 
    AVG(delivery_delay_days) AS avg_delivery_delay
FROM shipments_clean
WHERE delivery_delay_days IS NOT NULL;

-- Carrier performance: delay %
SELECT
    carrier,
    SUM(CASE WHEN is_delayed = TRUE THEN 1 ELSE 0 END) * 100.0 /
    COUNT(*) AS delay_percentage
FROM shipments_clean
GROUP BY carrier
ORDER BY delay_percentage ASC;

-- Shipment costs by carrier
SELECT
    carrier,
    SUM(shipping_cost) AS total_shipping_cost
FROM shipments_clean
GROUP BY carrier
ORDER BY total_shipping_cost DESC;


-- ==========================
-- 5. INVENTORY KPIs
-- ==========================

-- Inventory status distribution
SELECT 
    inventory_status,
    COUNT(*) AS count_status
FROM inventory_clean
GROUP BY inventory_status;

-- SKUs at risk of stockout
SELECT 
    sku,
    supplier_id,
    inventory_level,
    reorder_point,
    inventory_status
FROM inventory_clean
WHERE inventory_status IN ('Out-of-Stock', 'Critical')
ORDER BY inventory_level ASC;

-- Average days of cover
SELECT 
    AVG(days_of_cover_estimate) AS avg_days_of_cover
FROM inventory_clean;


-- ==========================
-- 6. SUPPLIER PERFORMANCE KPIs
-- ==========================

-- Supplier reliability ranking
SELECT
    supplier_id,
    AVG(delivery_delay_days) AS avg_delay,
    SUM(CASE WHEN delivered_on_time_flag = TRUE THEN 1 ELSE 0 END) * 100.0 /
    COUNT(*) AS supplier_OTIF,
    COUNT(*) AS total_shipments
FROM shipments_clean
WHERE is_delivered = TRUE
GROUP BY supplier_id
HAVING COUNT(*) > 50  -- ensure enough shipments for accuracy
ORDER BY supplier_OTIF DESC;

-- Lead time analysis by supplier
SELECT
    supplier_id,
    AVG(avg_lead_time_days) AS avg_lead_time
FROM suppliers_clean
GROUP BY supplier_id
ORDER BY avg_lead_time ASC;


-- ==========================
-- 7. CROSS-DATASET KPI (MOST IMPORTANT)
-- ==========================

-- Full supply chain merge KPI: Revenue impact from shipment delays
SELECT
    o.sku,
    SUM(o.order_value) AS revenue,
    SUM(CASE WHEN s.is_delayed = TRUE THEN o.order_value ELSE 0 END) AS delayed_revenue_risk
FROM orders_clean o
LEFT JOIN shipments_clean s 
    ON o.order_id = s.order_id
GROUP BY o.sku
ORDER BY delayed_revenue_risk DESC
LIMIT 10;


-- Orders vs Shipments: Fulfillment completeness
SELECT
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT s.order_id) AS shipped_orders,
    COUNT(DISTINCT o.order_id) - COUNT(DISTINCT s.order_id) AS unshipped_orders
FROM orders_clean o
LEFT JOIN shipments_clean s ON o.order_id = s.order_id;
