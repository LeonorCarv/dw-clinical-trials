"""Load the compressed CSV files in data/extract/ into the staging schema.

The staging tables must exist first (run sql/01_staging/03_staging_ddl.sql
with psql). Run from the repository root:
    python etl/load_extract.py
"""

import gzip

import psycopg2  # noqa: F401  (imported for a clear error if missing)

from export_extract import OUTPUT_DIR, ROOT, connect, load_env
from tables import STAGING_TABLES


def main() -> None:
    load_env(ROOT / ".env")

    with connect() as conn, conn.cursor() as cur:
        for table in STAGING_TABLES:
            path = OUTPUT_DIR / f"{table}.csv.gz"
            cur.execute(f"TRUNCATE staging.{table}")
            with gzip.open(path, "rt", encoding="utf-8", newline="") as f:
                cur.copy_expert(
                    f"COPY staging.{table} FROM STDIN WITH (FORMAT csv, HEADER true)",
                    f,
                )
            cur.execute(f"SELECT COUNT(*) FROM staging.{table}")
            print(f"{table:<20} {cur.fetchone()[0]:>10,} rows")


if __name__ == "__main__":
    main()