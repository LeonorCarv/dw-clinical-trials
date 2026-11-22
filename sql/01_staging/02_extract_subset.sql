-- =====================================================================
-- Extract the project subset from the AACT source (schema ctgov)
-- into the staging schema.
--
-- Requires: 01_define_scope.sql (staging.scope_trials, staging.scope_trial_area)
-- Scope: interventional trials started 2012-2024 in four therapeutic areas
--        (oncology, neurology, cardiovascular, infectious diseases)
-- =====================================================================


-- ---------------------------------------------------------------------
-- 1. Trials: core attributes, key dates and calculated indicators
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS staging.trials;
CREATE TABLE staging.trials AS
SELECT s.nct_id,
       s.brief_title,
       s.study_type,
       s.overall_status,
       s.phase,
       s.enrollment,
       s.enrollment_type,
       s.number_of_arms,
       s.why_stopped,
       s.study_first_submitted_date,
       s.start_date,
       s.start_date_type,
       s.primary_completion_date,
       s.primary_completion_date_type,
       s.completion_date,
       s.completion_date_type,
       s.results_first_submitted_date,
       s.results_first_posted_date,
       s.last_update_submitted_date,
       s.is_fda_regulated_drug,
       s.is_fda_regulated_device,
       c.number_of_facilities,
       c.actual_duration,
       c.were_results_reported,
       c.months_to_report_results,
       c.has_us_facility,
       c.has_single_facility,
       c.number_of_sae_subjects,
       c.number_of_nsae_subjects
FROM ctgov.studies s
JOIN staging.scope_trials t USING (nct_id)
LEFT JOIN ctgov.calculated_values c USING (nct_id);

ALTER TABLE staging.trials ADD PRIMARY KEY (nct_id);


-- ---------------------------------------------------------------------
-- 2. Study design (future junk dimension)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS staging.designs;
CREATE TABLE staging.designs AS
SELECT d.nct_id,
       d.allocation,
       d.intervention_model,
       d.primary_purpose,
       d.masking,
       d.subject_masked,
       d.caregiver_masked,
       d.investigator_masked,
       d.outcomes_assessor_masked
FROM ctgov.designs d
JOIN staging.scope_trials t USING (nct_id);


-- ---------------------------------------------------------------------
-- 3. Eligibility criteria (sex and age groups)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS staging.eligibilities;
CREATE TABLE staging.eligibilities AS
SELECT e.nct_id,
       e.gender,
       e.minimum_age,
       e.maximum_age,
       e.healthy_volunteers,
       e.child,
       e.adult,
       e.older_adult
FROM ctgov.eligibilities e
JOIN staging.scope_trials t USING (nct_id);


-- ---------------------------------------------------------------------
-- 4. Sponsors (lead sponsor and collaborators)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS staging.sponsors;
CREATE TABLE staging.sponsors AS
SELECT sp.nct_id,
       sp.lead_or_collaborator,
       sp.agency_class,
       sp.name AS sponsor_name
FROM ctgov.sponsors sp
JOIN staging.scope_trials t USING (nct_id);


-- ---------------------------------------------------------------------
-- 5. Interventions (free-text descriptions excluded)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS staging.interventions;
CREATE TABLE staging.interventions AS
SELECT i.nct_id,
       i.intervention_type,
       i.name AS intervention_name
FROM ctgov.interventions i
JOIN staging.scope_trials t USING (nct_id);


-- ---------------------------------------------------------------------
-- 6. Conditions mapped to MeSH terms
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS staging.conditions;
CREATE TABLE staging.conditions AS
SELECT b.nct_id,
       b.mesh_term,
       b.mesh_type
FROM ctgov.browse_conditions b
JOIN staging.scope_trials t USING (nct_id);


-- ---------------------------------------------------------------------
-- 7. MeSH tree (hierarchy of the condition dimension)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS staging.mesh_tree;
CREATE TABLE staging.mesh_tree AS
SELECT m.tree_number,
       m.mesh_term
FROM ctgov.mesh_terms m;


-- ---------------------------------------------------------------------
-- 8. Countries where each trial takes place
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS staging.countries;
CREATE TABLE staging.countries AS
SELECT co.nct_id,
       co.name AS country
FROM ctgov.countries co
JOIN staging.scope_trials t USING (nct_id)
WHERE co.removed IS NOT TRUE;


-- ---------------------------------------------------------------------
-- 9. Number of sites per trial and country
--    (aggregated from facilities; individual addresses are not needed)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS staging.site_counts;
CREATE TABLE staging.site_counts AS
SELECT f.nct_id,
       f.country,
       COUNT(*) AS n_sites
FROM ctgov.facilities f
JOIN staging.scope_trials t USING (nct_id)
GROUP BY f.nct_id, f.country;


-- ---------------------------------------------------------------------
-- 10. Adverse events aggregated by group, event type and organ system
--     subjects_affected and event_count are additive.
--     subjects_at_risk is NOT additive across organ systems or event
--     terms (same participants), so the maximum per group is kept.
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS staging.adverse_events;
CREATE TABLE staging.adverse_events AS
SELECT r.nct_id,
       r.result_group_id,
       r.ctgov_group_code,
       r.event_type,
       r.organ_system,
       SUM(r.subjects_affected) AS subjects_affected,
       SUM(r.event_count)       AS event_count,
       MAX(r.subjects_at_risk)  AS subjects_at_risk,
       COUNT(*)                 AS n_event_terms
FROM ctgov.reported_events r
JOIN staging.scope_trials t USING (nct_id)
GROUP BY r.nct_id, r.result_group_id, r.ctgov_group_code,
         r.event_type, r.organ_system;


-- ---------------------------------------------------------------------
-- 11. Result groups referenced by the adverse events (arm titles)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS staging.result_groups;
CREATE TABLE staging.result_groups AS
SELECT g.id AS result_group_id,
       g.nct_id,
       g.ctgov_group_code,
       g.title AS group_title
FROM ctgov.result_groups g
WHERE g.id IN (SELECT DISTINCT result_group_id FROM staging.adverse_events);


-- ---------------------------------------------------------------------
-- 12. Row counts of the staging tables
-- ---------------------------------------------------------------------
SELECT 'scope_trials'     AS table_name, COUNT(*) AS n_rows FROM staging.scope_trials
UNION ALL SELECT 'scope_trial_area', COUNT(*) FROM staging.scope_trial_area
UNION ALL SELECT 'trials',           COUNT(*) FROM staging.trials
UNION ALL SELECT 'designs',          COUNT(*) FROM staging.designs
UNION ALL SELECT 'eligibilities',    COUNT(*) FROM staging.eligibilities
UNION ALL SELECT 'sponsors',         COUNT(*) FROM staging.sponsors
UNION ALL SELECT 'interventions',    COUNT(*) FROM staging.interventions
UNION ALL SELECT 'conditions',       COUNT(*) FROM staging.conditions
UNION ALL SELECT 'mesh_tree',        COUNT(*) FROM staging.mesh_tree
UNION ALL SELECT 'countries',        COUNT(*) FROM staging.countries
UNION ALL SELECT 'site_counts',      COUNT(*) FROM staging.site_counts
UNION ALL SELECT 'adverse_events',   COUNT(*) FROM staging.adverse_events
UNION ALL SELECT 'result_groups',    COUNT(*) FROM staging.result_groups;