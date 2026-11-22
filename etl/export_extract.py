"""Export the staging tables to compressed CSV files in data/extract/.

Run from the repository root:
    python etl/export_extract.py

Database credentials are read from the .env file in the repository root
(see .env.example).
"""

import gzip
import os
from pathlib import Path

import psycopg2

from tables import STAGING_TABLES

ROOT = Path(__file__).resolve().parents[1]
OUTPUT_DIR = ROOT / "data" / "extract"
SIZE_WARNING_MB = 50


def load_env(path: Path) -> None:
    """Load KEY=VALUE pairs from a .env file into the environment."""
    if not path.exists():
        return
    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if line and not line.startswith("#") and "=" in line:
            key, value = line.split("=", 1)
            os.environ.setdefault(key.strip(), value.strip())


def connect():
    return psycopg2.connect(
        host=os.environ.get("PGHOST", "localhost"),
        port=os.environ.get("PGPORT", "5432"),
        dbname=os.environ.get("PGDATABASE", "aact"),
        user=os.environ.get("PGUSER", "postgres"),
        password=os.environ.get("PGPASSWORD", ""),
    )


def main() -> None:
    load_env(ROOT / ".env")
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    with connect() as conn, conn.cursor() as cur:
        for table in STAGING_TABLES:
            path = OUTPUT_DIR / f"{table}.csv.gz"
            with gzip.open(path, "wt", encoding="utf-8", newline="") as f:
                cur.copy_expert(
                    f"COPY staging.{table} TO STDOUT WITH (FORMAT csv, HEADER true)",
                    f,
                )
            size_mb = path.stat().st_size / 1024 ** 2
            warning = "  <-- too large for GitHub" if size_mb > SIZE_WARNING_MB else ""
            print(f"{table:<20} {size_mb:8.1f} MB{warning}")


if __name__ == "__main__":
    main()