-- Row counts of the main source tables within the scope
SELECT 'scope_trials' AS table_name, COUNT(*) AS n_rows FROM staging.scope_trials
UNION ALL
SELECT 'trials in more than one area', COUNT(*) FROM (
    SELECT nct_id FROM staging.scope_trial_area GROUP BY nct_id HAVING COUNT(*) > 1
) x
UNION ALL
SELECT 'sponsors', COUNT(*) FROM ctgov.sponsors JOIN staging.scope_trials USING (nct_id)
UNION ALL
SELECT 'browse_conditions', COUNT(*) FROM ctgov.browse_conditions JOIN staging.scope_trials USING (nct_id)
UNION ALL
SELECT 'interventions', COUNT(*) FROM ctgov.interventions JOIN staging.scope_trials USING (nct_id)
UNION ALL
SELECT 'countries', COUNT(*) FROM ctgov.countries JOIN staging.scope_trials USING (nct_id)
UNION ALL
SELECT 'facilities', COUNT(*) FROM ctgov.facilities JOIN staging.scope_trials USING (nct_id)
UNION ALL
SELECT 'reported_events', COUNT(*) FROM ctgov.reported_events JOIN staging.scope_trials USING (nct_id)
UNION ALL
SELECT 'trials with results', COUNT(*) FROM ctgov.calculated_values JOIN staging.scope_trials USING (nct_id)
WHERE were_results_reported;