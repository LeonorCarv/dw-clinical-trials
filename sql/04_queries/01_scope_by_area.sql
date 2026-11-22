-- Number of interventional trials started 2012-2024 by therapeutic area
SELECT a.area,
       COUNT(DISTINCT s.nct_id) AS n_trials
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
  AND s.start_date <  DATE '2025-01-01'
GROUP BY a.area
ORDER BY n_trials DESC;