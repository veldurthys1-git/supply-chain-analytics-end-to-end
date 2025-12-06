import logging

from extract import load_config, extract_raw_data
from transform import transform_all
from load import load_processed_data


def main():
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s - %(levelname)s - %(message)s",
    )

    logging.info("Starting Daxwell Supply Chain ETL pipeline...")

    # 1) Load config
    config = load_config()

    # 2) Extract
    raw_data = extract_raw_data(config)

    # 3) Transform
    processed_data = transform_all(raw_data)

    # 4) Load
    load_processed_data(processed_data, config)

    logging.info("ETL pipeline completed successfully.")


if __name__ == "__main__":
    main()
