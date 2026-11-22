# Clinical Trials Data Warehouse

Lab assignment for the Data Warehouses course (MECD, FEUP, 2026/2027).

## Data source
AACT (Aggregate Analysis of ClinicalTrials.gov), https://aact.ctti-clinicaltrials.org
Snapshot used: PostgreSQL dump from 2026-11-22.

## Scope
- Interventional trials only
- Start date between 2012-01-01 and 2024-12-31
- Four therapeutic areas, based on MeSH ancestor terms:
  oncology, neurology, cardiovascular and infectious diseases
- 118,940 trials (13,673 belong to more than one area)

## Getting the data

### Option A: load the project extract (recommended)
The subset used in the project is versioned in `data/extract/` as compressed CSV files.

1. Install PostgreSQL 14 or later and create an empty database called `aact`.
2. Run `sql/00_setup/01_create_schemas.sql`.
3. Create the staging tables with psql (pgAdmin does not accept some commands in this file):
   ```powershell
   .\psql.exe -U postgres -d aact -f "PATH\TO\REPO\sql\01_staging\03_staging_ddl.sql"
   ```
4. Copy `.env.example` to `.env` and fill in your credentials.
5. Install the dependencies and load the data:
   ```
   pip install -r requirements.txt
   python etl/load_extract.py
   ```

### Option B: rebuild the extract from the full AACT dump
Only needed to change the scope or regenerate the extract.

1. Download the AACT dump used in the project (snapshot 2026-11-22) from
   [Google Drive](https://drive.google.com/drive/folders/1pIjUbWSEmWF7qcjCbke5Alnunfh8cWyr?usp=sharing) and restore it (see `sql/00_setup/README.md`).
   The same snapshot is also available in the AACT snapshot history.
2. Run `sql/00_setup/01_create_schemas.sql`.
3. Run `sql/01_staging/01_define_scope.sql` and `sql/01_staging/02_extract_subset.sql`.
4. Export the extract with `python etl/export_extract.py`.

## Pipeline
```
ctgov (AACT source) -> staging (project subset) -> dw (dimensional model)
```

| Step | Files |
|---|---|
| Setup | `sql/00_setup/` |
| Scope and extraction | `sql/01_staging/`, `etl/export_extract.py` |
| Dimensions | `sql/02_dimensions/` |
| Facts | `sql/03_facts/` |
| Analytical queries | `sql/04_queries/` |

## Repository structure
- `data/extract/` project subset (compressed CSV), described in `data/README.md`
- `sql/` warehouse creation scripts and analytical queries
- `etl/` export and load scripts
- `docs/` documentation and diagrams
- `notebooks/` exploratory analysis
- `report/` final report