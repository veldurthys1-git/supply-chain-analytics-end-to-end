-- ============================================================
-- SUPPLIER PERFORMANCE SCORECARD
-- Combines shipment performance + reliability + lead-time data.
-- ============================================================

-- ==========================
-- 1. Base Supplier Aggregation
-- ==========================
WITH supplier_base AS (
    SELECT
        s.supplier_id,
        COUNT(*) AS total_shipments,
        SUM(CASE WHEN s.is_delivered = TRUE THEN 1 ELSE 0 END) AS delivered_shipments,
        SUM(CASE WHEN s.delivered_on_time_flag = TRUE THEN 1 ELSE 0 END) AS on_time_shipments,
        SUM(CASE WHEN s.is_delayed = TRUE THEN 1 ELSE 0 END) AS delayed_shipments,
        SUM(CASE WHEN s.is_lost = TRUE THEN 1 ELSE 0 END) AS lost_shipments,
        AVG(s.delivery_delay_days) AS avg_delivery_delay,
        SUM(s.shipping_cost) AS total_shipping_cost
    FROM shipments_clean s
    GROUP BY s.supplier_id
),

-- ==========================
-- 2. Supplier OTIF Calculation
-- ==========================
supplier_otif AS (
    SELECT
        supplier_id,
        on_time_shipments * 100.0 / NULLIF(delivered_shipments, 0) AS otif_percentage
    FROM supplier_base
),

-- ==========================
-- 3. Merge Supplier Master Data
-- ==========================
supplier_enriched AS (
    SELECT
        sb.supplier_id,
        sb.total_shipments,
        sb.delivered_shipments,
        sb.on_time_shipments,
        sb.delayed_shipments,
        sb.lost_shipments,
        sb.avg_delivery_delay,
        sb.total_shipping_cost,
        ot.otif_percentage,
        sup.supplier_name,
        sup.region,
        sup.reliability_score,
        sup.avg_lead_time_days,
        sup.supplier_rating_clean
    FROM supplier_base sb
    LEFT JOIN supplier_otif ot ON sb.supplier_id = ot.supplier_id
    LEFT JOIN suppliers_clean sup ON sb.supplier_id = sup.supplier_id
),

-- ==========================
-- 4. Supplier Grade Assignment (Business Rule)
-- ==========================
supplier_scores AS (
    SELECT
        supplier_id,
        supplier_name,
        region,
        total_shipments,
        delivered_shipments,
        delayed_shipments,
        lost_shipments,
        on_time_shipments,
        otif_percentage,
        avg_delivery_delay,
        reliability_score,
        avg_lead_time_days,
        supplier_rating_clean,

        -- Composite Supplier Score (weighted KPI model)
        (
            (COALESCE(otif_percentage, 0) * 0.40) +            -- OTIF weight
            ((100 - COALESCE(avg_delivery_delay, 0)) * 0.20) + -- Delay performance
            (COALESCE(reliability_score, 0) * 0.30) -         -- Reliability adds points
            (lost_shipments * 0.10)                           -- Lost shipments reduce score
        ) AS supplier_score
    FROM supplier_enriched
)

-- ==========================
-- 5. FINAL SUPPLIER SCORECARD OUTPUT
-- ==========================
SELECT
    supplier_id,
    supplier_name,
    region,
    supplier_rating_clean AS original_rating,
    total_shipments,
    delivered_shipments,
    delayed_shipments,
    lost_shipments,
    otif_percentage,
    avg_delivery_delay,
    reliability_score,
    avg_lead_time_days,
    ROUND(supplier_score, 2) AS final_supplier_score,

    CASE
        WHEN supplier_score >= 85 THEN 'Top Performer'
        WHEN supplier_score >= 70 THEN 'Strong'
        WHEN supplier_score >= 55 THEN 'Average'
        ELSE 'High Risk'
    END AS performance_category

FROM supplier_scores
ORDER BY final_supplier_score DESC;
