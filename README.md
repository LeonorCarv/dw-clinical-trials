# Clinical Trials Data Warehouse

Lab assignment for the Data Warehouses course (MECD, FEUP, 2026/2027).

## Data source
AACT (Aggregate Analysis of ClinicalTrials.gov), https://aact.ctti-clinicaltrials.org
Snapshot used: PostgreSQL dump from 2026-11-22

## Getting the data
1. Ask the team for the postgres.dmp file (do not download a new one, so everyone uses the same snapshot).
2. Install PostgreSQL 14 or later.
3. Follow the steps in sql/00_setup/README.md.

## Repository structure
- sql/ warehouse creation scripts and analytical queries
- etl/ extraction and transformation scripts
- docs/ documentation and diagrams
- report/ final report