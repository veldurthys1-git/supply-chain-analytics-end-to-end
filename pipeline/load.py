import logging
from pathlib import Path
from typing import Dict

import pandas as pd


def load_processed_data(processed_data: Dict[str, pd.DataFrame], config: dict) -> None:
    """
    Persist processed DataFrames to CSV paths defined in config.
    """
    processed_paths = config.get("processed_data", {})

    for key, df in processed_data.items():
        if key not in processed_paths:
            logging.warning(f"No processed path configured for key '{key}'. Skipping.")
            continue

        path = Path(processed_paths[key])
        path.parent.mkdir(parents=True, exist_ok=True)

        df.to_csv(path, index=False)
        logging.info(f"Wrote processed '{key}' data to {path} with shape {df.shape}")
