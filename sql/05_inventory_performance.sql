-- ============================================================
-- INVENTORY PERFORMANCE & RISK ANALYTICS
-- Includes stockout analysis, days-of-cover, turnover, and SKU risk.
-- ============================================================


-- ==========================
-- 1. INVENTORY STATUS SUMMARY
-- ==========================
SELECT 
    inventory_status,
    COUNT(*) AS count_status
FROM inventory_clean
GROUP BY inventory_status
ORDER BY count_status DESC;


-- ==========================
-- 2. STOCKOUT & CRITICAL INVENTORY
-- ==========================

-- All SKUs currently out of stock
SELECT 
    sku,
    supplier_id,
    inventory_level,
    reorder_point,
    days_of_cover_estimate
FROM inventory_clean
WHERE inventory_status = 'Out-of-Stock'
ORDER BY inventory_level ASC;

-- All critical inventory SKUs
SELECT 
    sku,
    supplier_id,
    inventory_level,
    reorder_point,
    days_of_cover_estimate
FROM inventory_clean
WHERE inventory_status = 'Critical'
ORDER BY inventory_level ASC;


-- ==========================
-- 3. OVERSTOCK DETECTION
--    (Inventory far above reorder_qty or reorder point)
-- ==========================

SELECT
    sku,
    supplier_id,
    inventory_level,
    reorder_point,
    reorder_qty,
    inventory_level - reorder_point AS excess_inventory
FROM inventory_clean
WHERE inventory_level > (reorder_point * 4)   -- strong overstock rule
ORDER BY excess_inventory DESC;


-- ==========================
-- 4. REORDER RISK SCORE
--    (Combines inventory level, reorder flag, and days-of-cover)
-- ==========================

SELECT
    sku,
    supplier_id,
    inventory_level,
    reorder_point,
    days_of_cover_estimate,

    CASE
        WHEN inventory_status = 'Out-of-Stock' THEN 95
        WHEN inventory_status = 'Critical' THEN 85
        WHEN inventory_status = 'Low' THEN 65
        ELSE 15
    END AS inventory_risk_score

FROM inventory_clean
ORDER BY inventory_risk_score DESC, inventory_level ASC;


-- ==========================
-- 5. INVENTORY TURNOVER ANALYSIS (REQUIRES SHIPMENTS)
-- ==========================

-- Inventory turnover = total units shipped / avg inventory level
WITH shipment_totals AS (
    SELECT 
        sku,
        SUM(quantity_shipped) AS total_shipped
    FROM shipments_clean
    WHERE is_delivered = TRUE
    GROUP BY sku
),

avg_inventory AS (
    SELECT 
        sku,
        AVG(inventory_level) AS avg_inventory_level
    FROM inventory_clean
    GROUP BY sku
)

SELECT
    a.sku,
    a.avg_inventory_level,
    s.total_shipped,
    CASE 
        WHEN a.avg_inventory_level = 0 THEN NULL
        ELSE ROUND(s.total_shipped * 1.0 / a.avg_inventory_level, 2)
    END AS inventory_turnover_ratio
FROM avg_inventory a
LEFT JOIN shipment_totals s ON a.sku = s.sku
ORDER BY inventory_turnover_ratio DESC NULLS LAST;


-- ==========================
-- 6. SUPPLIER-LEVEL INVENTORY RISK
-- ==========================

-- Aggregate inventory risk by supplier
WITH risk_scores AS (
    SELECT
        supplier_id,
        COUNT(*) AS sku_count,
        SUM(CASE WHEN inventory_status IN ('Out-of-Stock', 'Critical') THEN 1 ELSE 0 END) AS high_risk_sku_count,
        AVG(days_of_cover_estimate) AS avg_days_cover
    FROM inventory_clean
    GROUP BY supplier_id
)

SELECT
    r.supplier_id,
    sup.supplier_name,
    r.sku_count,
    r.high_risk_sku_count,
    (r.high_risk_sku_count * 100.0 / r.sku_count) AS pct_high_risk_skus,
    r.avg_days_cover,
    
    CASE
        WHEN (r.high_risk_sku_count * 100.0 / r.sku_count) >= 40 THEN 'High Risk Supplier'
        WHEN (r.high_risk_sku_count * 100.0 / r.sku_count) >= 20 THEN 'Medium Risk Supplier'
        ELSE 'Low Risk Supplier'
    END AS supplier_inventory_risk_category

FROM risk_scores r
LEFT JOIN suppliers_clean sup ON r.supplier_id = sup.supplier_id
ORDER BY pct_high_risk_skus DESC;


-- ==========================
-- 7. TOP 20 SKUs BY INVENTORY RISK
-- ==========================

SELECT
    sku,
    supplier_id,
    inventory_level,
    reorder_point,
    inventory_status,
    days_of_cover_estimate,
    CASE
        WHEN inventory_status = 'Out-of-Stock' THEN 'URGENT'
        WHEN inventory_status = 'Critical' THEN 'HIGH'
        WHEN inventory_status = 'Low' THEN 'MEDIUM'
        ELSE 'LOW'
    END AS urgency_flag
FROM inventory_clean
ORDER BY 
    CASE
        WHEN inventory_status = 'Out-of-Stock' THEN 1
        WHEN inventory_status = 'Critical' THEN 2
        WHEN inventory_status = 'Low' THEN 3
        ELSE 4
    END,
    days_of_cover_estimate ASC
LIMIT 20;


-- ==========================
-- 8. INVENTORY COVERAGE ACROSS REGIONS (JOIN WITH ORDERS)
-- ==========================

-- Because orders include customer region,
-- we can backtrack SKU → region consumption patterns.

SELECT
    o.customer_region,
    o.sku,
    SUM(o.quantity_ordered) AS total_demand,
    AVG(i.inventory_level) AS avg_inventory,
    AVG(i.days_of_cover_estimate) AS avg_days_cover
FROM orders_clean o
LEFT JOIN inventory_clean i ON o.sku = i.sku
GROUP BY o.customer_region, o.sku
ORDER BY total_demand DESC, avg_days_cover ASC;
