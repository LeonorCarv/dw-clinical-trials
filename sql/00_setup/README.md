# Database setup (full AACT restore)

Only needed to rebuild the project extract from the full AACT database
(option B in the main README). To work on the project, loading the extract
in `data/extract/` is enough (option A).

## 1. Download the data
Download the AACT PostgreSQL dump used in the project (snapshot 2026-11-22):
- Team copy: [Google Drive](https://drive.google.com/drive/folders/1pIjUbWSEmWF7qcjCbke5Alnunfh8cWyr?usp=sharing)
- Official source: https://aact.ctti-clinicaltrials.org (Snapshots > Browse all snapshots)

Extract `postgres.dmp` to a folder outside the repository.

## 2. Install PostgreSQL
Install PostgreSQL 14 or later, including pgAdmin and the Command Line Tools.
Keep port 5432 and save the password of the `postgres` user.

## 3. Restore the database (Windows PowerShell)
Do not run these commands with a conda environment active (`conda deactivate`).
Adjust the PostgreSQL version and the path to the dump file.

```powershell
cd "C:\Program Files\PostgreSQL\18\bin"
.\createdb.exe -U postgres aact
.\pg_restore.exe -U postgres -d aact --no-owner --no-privileges -j 4 -v "PATH\TO\postgres.dmp"
```

The restore takes between 15 and 60 minutes. Messages such as
`skipping item ... ACL` are expected and can be ignored.

## 4. Check the restore
In pgAdmin, open the Query Tool on the `aact` database and run:

```sql
ANALYZE;

SELECT relname AS table_name, n_live_tup AS n_rows
FROM pg_stat_user_tables
WHERE schemaname = 'ctgov'
ORDER BY n_live_tup DESC;
```

The `studies` table should have 613,514 rows.

## 5. Create the project schemas
Run `01_create_schemas.sql` in this folder.

## 6. Rebuild the extract
1. Run `sql/01_staging/01_define_scope.sql`.
2. Run `sql/01_staging/02_extract_subset.sql`.
3. Export the staging structure:
   ```powershell
   .\pg_dump.exe -U postgres -d aact -n staging -s --no-owner --no-privileges --clean --if-exists -f "PATH\TO\REPO\sql\01_staging\03_staging_ddl.sql"
   ```
4. Export the data from the repository root:
   ```
   python etl/export_extract.py
   ```