import logging
from typing import Dict

import numpy as np
import pandas as pd


def _parse_date(series: pd.Series) -> pd.Series:
    """
    Safely parse dates, returning NaT for invalid values.
    """
    return pd.to_datetime(series, errors="coerce")


def transform_inventory(df: pd.DataFrame) -> pd.DataFrame:
    """
    Clean and enrich inventory data.
    """
    df = df.copy()

    # Basic type handling
    df["date"] = _parse_date(df["date"])
    numeric_cols = [
        "inventory_level",
        "reorder_point",
        "reorder_qty",
        "on_order_qty",
        "lead_time_days",
    ]
    for col in numeric_cols:
        df[col] = pd.to_numeric(df[col], errors="coerce").fillna(0).astype(int)

    # Remove obvious bad rows
    before = len(df)
    df = df[df["sku"].notna() & df["supplier_id"].notna()]
    after = len(df)
    if after < before:
        logging.warning(
            f"Inventory: dropped {before - after} rows due to missing sku/supplier_id."
        )

    # Clip negatives just in case
    df["inventory_level"] = df["inventory_level"].clip(lower=0)
    df["on_order_qty"] = df["on_order_qty"].clip(lower=0)

    # Derived fields
    df["reorder_flag"] = df["inventory_level"] < df["reorder_point"]

    # Inventory status banding
    conditions = [
        df["inventory_level"] <= 0,
        df["inventory_level"] < 0.5 * df["reorder_point"],
        df["inventory_level"] < df["reorder_point"],
        df["inventory_level"] >= df["reorder_point"],
    ]
    choices = ["Out-of-Stock", "Critical", "Low", "Healthy"]
    df["inventory_status"] = np.select(conditions, choices, default="Unknown")

    # Simple days-of-cover heuristic
    # Avoid div by zero
    avg_daily_usage = (df["reorder_qty"] / 10).replace(0, np.nan)
    df["days_of_cover_estimate"] = (df["inventory_level"] / avg_daily_usage).round(1)
    df["days_of_cover_estimate"] = df["days_of_cover_estimate"].fillna(0)

    logging.info(f"Inventory transformed. Final shape: {df.shape}")
    return df


def transform_orders(df: pd.DataFrame) -> pd.DataFrame:
    """
    Clean and enrich orders data.
    """
    df = df.copy()

    # Parse dates
    df["order_date"] = _parse_date(df["order_date"])
    df["expected_ship_date"] = _parse_date(df["expected_ship_date"])
    df["actual_ship_date"] = _parse_date(df["actual_ship_date"])

    # Basic numeric conversions
    df["quantity_ordered"] = pd.to_numeric(df["quantity_ordered"], errors="coerce").fillna(0).astype(int)
    df["unit_price"] = pd.to_numeric(df["unit_price"], errors="coerce").fillna(0.0).astype(float)

    # Derived fields
    df["order_value"] = (df["quantity_ordered"] * df["unit_price"]).round(2)

    # Shipping delay in days
    mask_valid = df["actual_ship_date"].notna() & df["expected_ship_date"].notna()
    df["shipping_delay_days"] = np.where(
        mask_valid,
        (df["actual_ship_date"] - df["expected_ship_date"]).dt.days,
        np.nan,
    )

    df["shipping_delay_days"] = df["shipping_delay_days"].astype("float")

    # Flags
    df["is_high_priority"] = df["priority_flag"].fillna("").str.upper().eq("HIGH")
    df["is_cancelled"] = df["order_status"].fillna("").str.upper().eq("CANCELLED")
    df["is_returned"] = df["order_status"].fillna("").str.upper().eq("RETURNED")
    df["is_completed"] = df["order_status"].fillna("").str.upper().eq("COMPLETED")

    df["is_shipping_delayed"] = df["shipping_delay_days"] > 0

    logging.info(f"Orders transformed. Final shape: {df.shape}")
    return df


def transform_shipments(df: pd.DataFrame) -> pd.DataFrame:
    """
    Clean and enrich shipments data.
    """
    df = df.copy()

    df["shipment_date"] = _parse_date(df["shipment_date"])
    df["expected_delivery_date"] = _parse_date(df["expected_delivery_date"])
    df["actual_delivery_date"] = _parse_date(df["actual_delivery_date"])

    df["quantity_shipped"] = pd.to_numeric(df["quantity_shipped"], errors="coerce").fillna(0).astype(int)
    df["shipping_cost"] = pd.to_numeric(df["shipping_cost"], errors="coerce").fillna(0.0).astype(float)

    # Delivery delay in days
    mask_valid = df["actual_delivery_date"].notna() & df["expected_delivery_date"].notna()
    df["delivery_delay_days"] = np.where(
        mask_valid,
        (df["actual_delivery_date"] - df["expected_delivery_date"]).dt.days,
        np.nan,
    )
    df["delivery_delay_days"] = df["delivery_delay_days"].astype("float")

    # Flags
    status = df["shipment_status"].fillna("").str.upper()
    df["is_delivered"] = status.eq("DELIVERED")
    df["is_delayed"] = status.eq("DELAYED") | (df["delivery_delay_days"] > 0)
    df["is_lost"] = status.eq("LOST")
    df["is_in_transit"] = status.eq("IN-TRANSIT")

    df["delivered_on_time_flag"] = df["is_delivered"] & (df["delivery_delay_days"] <= 0)

    logging.info(f"Shipments transformed. Final shape: {df.shape}")
    return df


def transform_suppliers(df: pd.DataFrame) -> pd.DataFrame:
    """
    Clean and enrich supplier master data.
    """
    df = df.copy()

    df["reliability_score"] = pd.to_numeric(df["reliability_score"], errors="coerce").fillna(0).astype(int)
    df["avg_lead_time_days"] = pd.to_numeric(df["avg_lead_time_days"], errors="coerce").fillna(0).astype(int)
    df["contract_expiration"] = _parse_date(df["contract_expiration"])

    # Normalize rating, recompute from reliability just to ensure consistency
    conditions = [
        df["reliability_score"] >= 93,
        df["reliability_score"].between(83, 92),
        df["reliability_score"] < 83,
    ]
    choices = ["Gold", "Silver", "Bronze"]
    df["supplier_rating_clean"] = np.select(conditions, choices, default="Bronze")

    logging.info(f"Suppliers transformed. Final shape: {df.shape}")
    return df


def transform_all(raw_data: Dict[str, pd.DataFrame]) -> Dict[str, pd.DataFrame]:
    """
    Apply all table-level transforms plus cross-table integrity checks.
    """
    inventory_raw = raw_data["inventory"]
    orders_raw = raw_data["orders"]
    shipments_raw = raw_data["shipments"]
    suppliers_raw = raw_data["suppliers"]

    inventory_clean = transform_inventory(inventory_raw)
    orders_clean = transform_orders(orders_raw)
    shipments_clean = transform_shipments(shipments_raw)
    suppliers_clean = transform_suppliers(suppliers_raw)

    # --- Cross-table integrity checks & basic metrics ---

    # 1) SKUs in orders but not in inventory
    sku_inventory = set(inventory_clean["sku"].unique())
    sku_orders = set(orders_clean["sku"].unique())
    missing_skus_in_inventory = sku_orders - sku_inventory
    if missing_skus_in_inventory:
        logging.warning(
            f"{len(missing_skus_in_inventory)} SKUs appear in orders but not inventory. "
            f"Examples: {list(missing_skus_in_inventory)[:5]}"
        )

    # 2) Order IDs in shipments but not in orders
    orders_ids = set(orders_clean["order_id"].unique())
    shipment_order_ids = set(shipments_clean["order_id"].unique())
    missing_orders_for_shipments = shipment_order_ids - orders_ids
    if missing_orders_for_shipments:
        logging.warning(
            f"{len(missing_orders_for_shipments)} shipment records reference unknown orders. "
            f"Examples: {list(missing_orders_for_shipments)[:5]}"
        )

    # 3) Supplier IDs in inventory/shipments but not in supplier master
    supplier_ids_master = set(suppliers_clean["supplier_id"].unique())
    supplier_ids_inventory = set(inventory_clean["supplier_id"].unique())
    supplier_ids_shipments = set(shipments_clean["supplier_id"].unique())

    missing_suppliers_from_inventory = supplier_ids_inventory - supplier_ids_master
    missing_suppliers_from_shipments = supplier_ids_shipments - supplier_ids_master

    if missing_suppliers_from_inventory:
        logging.warning(
            f"{len(missing_suppliers_from_inventory)} suppliers in inventory not in supplier master. "
            f"Examples: {list(missing_suppliers_from_inventory)[:5]}"
        )

    if missing_suppliers_from_shipments:
        logging.warning(
            f"{len(missing_suppliers_from_shipments)} suppliers in shipments not in supplier master. "
            f"Examples: {list(missing_suppliers_from_shipments)[:5]}"
        )

    # 4) Simple high-level metrics log
    logging.info(
        f"Orders: {len(orders_clean)} rows | "
        f"Shipments: {len(shipments_clean)} rows | "
        f"Inventory snapshots: {len(inventory_clean)} rows | "
        f"Suppliers: {len(suppliers_clean)} rows"
    )

    return {
        "inventory": inventory_clean,
        "orders": orders_clean,
        "shipments": shipments_clean,
        "suppliers": suppliers_clean,
    }
