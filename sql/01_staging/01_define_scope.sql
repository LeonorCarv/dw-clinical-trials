-- Trials in scope: interventional, started 2012-2024, in four therapeutic areas
DROP TABLE IF EXISTS staging.scope_trial_area;
CREATE TABLE staging.scope_trial_area AS
SELECT DISTINCT s.nct_id, a.area
FROM ctgov.studies s
JOIN ctgov.browse_conditions b
  ON b.nct_id = s.nct_id
JOIN (VALUES
        ('neoplasms',               'Oncology'),
        ('nervous system diseases', 'Neurology'),
        ('cardiovascular diseases', 'Cardiovascular'),
        ('infections',              'Infectious diseases')
     ) AS a(mesh_term, area)
  ON b.downcase_mesh_term = a.mesh_term
WHERE s.study_type ILIKE 'interventional'
  AND s.start_date >= DATE '2012-01-01'
  AND s.start_date <  DATE '2025-01-01';

-- One row per trial
DROP TABLE IF EXISTS staging.scope_trials;
CREATE TABLE staging.scope_trials AS
SELECT DISTINCT nct_id
FROM staging.scope_trial_area;

ALTER TABLE staging.scope_trials ADD PRIMARY KEY (nct_id);