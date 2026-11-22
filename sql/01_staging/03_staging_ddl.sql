--
-- PostgreSQL database dump
--

\restrict CcpjaNrQxaGeqbCKIt2G2lhrk1c6fgIfB9vl3JqNjQXhveGBramEVIrl3AKFSED

-- Dumped from database version 18.6
-- Dumped by pg_dump version 18.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE IF EXISTS ONLY staging.trials DROP CONSTRAINT IF EXISTS trials_pkey;
ALTER TABLE IF EXISTS ONLY staging.scope_trials DROP CONSTRAINT IF EXISTS scope_trials_pkey;
DROP TABLE IF EXISTS staging.trials;
DROP TABLE IF EXISTS staging.sponsors;
DROP TABLE IF EXISTS staging.site_counts;
DROP TABLE IF EXISTS staging.scope_trials;
DROP TABLE IF EXISTS staging.scope_trial_area;
DROP TABLE IF EXISTS staging.result_groups;
DROP TABLE IF EXISTS staging.mesh_tree;
DROP TABLE IF EXISTS staging.interventions;
DROP TABLE IF EXISTS staging.eligibilities;
DROP TABLE IF EXISTS staging.designs;
DROP TABLE IF EXISTS staging.countries;
DROP TABLE IF EXISTS staging.conditions;
DROP TABLE IF EXISTS staging.adverse_events;
DROP SCHEMA IF EXISTS staging;
--
-- Name: staging; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA staging;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: adverse_events; Type: TABLE; Schema: staging; Owner: -
--

CREATE TABLE staging.adverse_events (
    nct_id character varying,
    result_group_id integer,
    ctgov_group_code character varying,
    event_type character varying,
    organ_system character varying,
    subjects_affected bigint,
    event_count bigint,
    subjects_at_risk integer,
    n_event_terms bigint
);


--
-- Name: conditions; Type: TABLE; Schema: staging; Owner: -
--

CREATE TABLE staging.conditions (
    nct_id character varying,
    mesh_term character varying,
    mesh_type character varying
);


--
-- Name: countries; Type: TABLE; Schema: staging; Owner: -
--

CREATE TABLE staging.countries (
    nct_id character varying,
    country character varying
);


--
-- Name: designs; Type: TABLE; Schema: staging; Owner: -
--

CREATE TABLE staging.designs (
    nct_id character varying,
    allocation character varying,
    intervention_model character varying,
    primary_purpose character varying,
    masking character varying,
    subject_masked boolean,
    caregiver_masked boolean,
    investigator_masked boolean,
    outcomes_assessor_masked boolean
);


--
-- Name: eligibilities; Type: TABLE; Schema: staging; Owner: -
--

CREATE TABLE staging.eligibilities (
    nct_id character varying,
    gender character varying,
    minimum_age character varying,
    maximum_age character varying,
    healthy_volunteers boolean,
    child boolean,
    adult boolean,
    older_adult boolean
);


--
-- Name: interventions; Type: TABLE; Schema: staging; Owner: -
--

CREATE TABLE staging.interventions (
    nct_id character varying,
    intervention_type character varying,
    intervention_name character varying
);


--
-- Name: mesh_tree; Type: TABLE; Schema: staging; Owner: -
--

CREATE TABLE staging.mesh_tree (
    tree_number character varying,
    mesh_term character varying
);


--
-- Name: result_groups; Type: TABLE; Schema: staging; Owner: -
--

CREATE TABLE staging.result_groups (
    result_group_id integer,
    nct_id character varying,
    ctgov_group_code character varying,
    group_title character varying
);


--
-- Name: scope_trial_area; Type: TABLE; Schema: staging; Owner: -
--

CREATE TABLE staging.scope_trial_area (
    nct_id character varying,
    area text
);


--
-- Name: scope_trials; Type: TABLE; Schema: staging; Owner: -
--

CREATE TABLE staging.scope_trials (
    nct_id character varying NOT NULL
);


--
-- Name: site_counts; Type: TABLE; Schema: staging; Owner: -
--

CREATE TABLE staging.site_counts (
    nct_id character varying,
    country character varying,
    n_sites bigint
);


--
-- Name: sponsors; Type: TABLE; Schema: staging; Owner: -
--

CREATE TABLE staging.sponsors (
    nct_id character varying,
    lead_or_collaborator character varying,
    agency_class character varying,
    sponsor_name character varying
);


--
-- Name: trials; Type: TABLE; Schema: staging; Owner: -
--

CREATE TABLE staging.trials (
    nct_id character varying NOT NULL,
    brief_title text,
    study_type character varying,
    overall_status character varying,
    phase character varying,
    enrollment integer,
    enrollment_type character varying,
    number_of_arms integer,
    why_stopped character varying,
    study_first_submitted_date date,
    start_date date,
    start_date_type character varying,
    primary_completion_date date,
    primary_completion_date_type character varying,
    completion_date date,
    completion_date_type character varying,
    results_first_submitted_date date,
    results_first_posted_date date,
    last_update_submitted_date date,
    is_fda_regulated_drug boolean,
    is_fda_regulated_device boolean,
    number_of_facilities integer,
    actual_duration integer,
    were_results_reported boolean,
    months_to_report_results integer,
    has_us_facility boolean,
    has_single_facility boolean,
    number_of_sae_subjects integer,
    number_of_nsae_subjects integer
);


--
-- Name: scope_trials scope_trials_pkey; Type: CONSTRAINT; Schema: staging; Owner: -
--

ALTER TABLE ONLY staging.scope_trials
    ADD CONSTRAINT scope_trials_pkey PRIMARY KEY (nct_id);


--
-- Name: trials trials_pkey; Type: CONSTRAINT; Schema: staging; Owner: -
--

ALTER TABLE ONLY staging.trials
    ADD CONSTRAINT trials_pkey PRIMARY KEY (nct_id);


--
-- PostgreSQL database dump complete
--

\unrestrict CcpjaNrQxaGeqbCKIt2G2lhrk1c6fgIfB9vl3JqNjQXhveGBramEVIrl3AKFSED

