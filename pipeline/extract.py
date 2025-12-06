import logging
from pathlib import Path

import pandas as pd
import yaml


def load_config(config_filename: str = "config.yaml") -> dict:
    """
    Load YAML configuration from the pipeline directory.
    """
    pipeline_dir = Path(__file__).resolve().parent
    config_path = pipeline_dir / config_filename

    if not config_path.exists():
        raise FileNotFoundError(f"Config file not found at: {config_path}")

    with open(config_path, "r") as f:
        config = yaml.safe_load(f)

    logging.info(f"Loaded config from {config_path}")
    return config


def extract_raw_data(config: dict) -> dict:
    """
    Read all raw CSV files defined in the config and return a dict of DataFrames.
    Keys: inventory, orders, shipments, suppliers
    """
    raw_paths = config.get("raw_data", {})
    dataframes = {}

    for key, path_str in raw_paths.items():
        path = Path(path_str)
        if not path.exists():
            raise FileNotFoundError(f"Raw data file for '{key}' not found at: {path}")

        df = pd.read_csv(path)
        logging.info(f"Loaded raw '{key}' data from {path} with shape {df.shape}")
        dataframes[key] = df

    return dataframes
