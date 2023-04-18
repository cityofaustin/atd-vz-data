--
-- PostgreSQL database dump
--

-- Dumped from database version 14.6 (Debian 14.6-1.pgdg110+1)
-- Dumped by pg_dump version 14.7 (Ubuntu 14.7-0ubuntu0.22.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: atd_txdot_person; Type: TABLE; Schema: public; Owner: visionzero
--

CREATE TABLE public.atd_txdot_person (
    crash_id integer,
    unit_nbr integer,
    prsn_nbr integer,
    prsn_type_id integer,
    prsn_occpnt_pos_id integer,
    prsn_name_honorific character varying(32),
    prsn_last_name character varying(128),
    prsn_first_name character varying(128),
    prsn_mid_name character varying(128),
    prsn_name_sfx character varying(32),
    prsn_injry_sev_id integer,
    prsn_age integer,
    prsn_ethnicity_id integer DEFAULT 0,
    prsn_gndr_id integer,
    prsn_ejct_id integer,
    prsn_rest_id integer,
    prsn_airbag_id integer,
    prsn_helmet_id integer,
    prsn_sol_fl character varying(1),
    prsn_alc_spec_type_id integer,
    prsn_alc_rslt_id integer,
    prsn_bac_test_rslt character varying(64),
    prsn_drg_spec_type_id integer,
    prsn_drg_rslt_id integer,
    prsn_taken_to character varying(256),
    prsn_taken_by character varying(256),
    prsn_death_date date,
    prsn_death_time time without time zone,
    sus_serious_injry_cnt integer,
    nonincap_injry_cnt integer,
    poss_injry_cnt integer,
    non_injry_cnt integer,
    unkn_injry_cnt integer,
    tot_injry_cnt integer,
    death_cnt integer,
    last_update timestamp without time zone DEFAULT now(),
    updated_by character varying(64),
    person_id integer NOT NULL,
    is_retired boolean DEFAULT false,
    years_of_life_lost integer GENERATED ALWAYS AS (
CASE
    WHEN (prsn_injry_sev_id = 4) THEN GREATEST((75 - prsn_age), 0)
    ELSE 0
END) STORED
);


ALTER TABLE public.atd_txdot_person OWNER TO visionzero;

--
-- Name: atd_txdot_person_person_id_seq; Type: SEQUENCE; Schema: public; Owner: visionzero
--

CREATE SEQUENCE public.atd_txdot_person_person_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.atd_txdot_person_person_id_seq OWNER TO visionzero;

--
-- Name: atd_txdot_person_person_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: visionzero
--

ALTER SEQUENCE public.atd_txdot_person_person_id_seq OWNED BY public.atd_txdot_person.person_id;


--
-- Name: atd_txdot_person person_id; Type: DEFAULT; Schema: public; Owner: visionzero
--

ALTER TABLE ONLY public.atd_txdot_person ALTER COLUMN person_id SET DEFAULT nextval('public.atd_txdot_person_person_id_seq'::regclass);


--
-- Name: atd_txdot_person atd_txdot_person_person_id_key; Type: CONSTRAINT; Schema: public; Owner: visionzero
--

ALTER TABLE ONLY public.atd_txdot_person
    ADD CONSTRAINT atd_txdot_person_person_id_key UNIQUE (person_id);


--
-- Name: atd_txdot_person atd_txdot_person_pkey; Type: CONSTRAINT; Schema: public; Owner: visionzero
--

ALTER TABLE ONLY public.atd_txdot_person
    ADD CONSTRAINT atd_txdot_person_pkey PRIMARY KEY (person_id);


--
-- Name: atd_txdot_person atd_txdot_person_unique; Type: CONSTRAINT; Schema: public; Owner: visionzero
--

ALTER TABLE ONLY public.atd_txdot_person
    ADD CONSTRAINT atd_txdot_person_unique UNIQUE (crash_id, unit_nbr, prsn_nbr, prsn_type_id, prsn_occpnt_pos_id);


--
-- Name: atd_txdot_person_death_cnt_index; Type: INDEX; Schema: public; Owner: visionzero
--

CREATE INDEX atd_txdot_person_death_cnt_index ON public.atd_txdot_person USING btree (death_cnt);


--
-- Name: atd_txdot_person_is_retired_index; Type: INDEX; Schema: public; Owner: visionzero
--

CREATE INDEX atd_txdot_person_is_retired_index ON public.atd_txdot_person USING btree (is_retired);


--
-- Name: atd_txdot_person_person_id_index; Type: INDEX; Schema: public; Owner: visionzero
--

CREATE INDEX atd_txdot_person_person_id_index ON public.atd_txdot_person USING btree (person_id);


--
-- Name: atd_txdot_person_prsn_age_index; Type: INDEX; Schema: public; Owner: visionzero
--

CREATE INDEX atd_txdot_person_prsn_age_index ON public.atd_txdot_person USING btree (prsn_age);


--
-- Name: atd_txdot_person_prsn_death_date_index; Type: INDEX; Schema: public; Owner: visionzero
--

CREATE INDEX atd_txdot_person_prsn_death_date_index ON public.atd_txdot_person USING btree (prsn_death_date);


--
-- Name: atd_txdot_person_prsn_death_time_index; Type: INDEX; Schema: public; Owner: visionzero
--

CREATE INDEX atd_txdot_person_prsn_death_time_index ON public.atd_txdot_person USING btree (prsn_death_time);


--
-- Name: atd_txdot_person_prsn_ethnicity_id_index; Type: INDEX; Schema: public; Owner: visionzero
--

CREATE INDEX atd_txdot_person_prsn_ethnicity_id_index ON public.atd_txdot_person USING btree (prsn_ethnicity_id);


--
-- Name: atd_txdot_person_prsn_gndr_id_index; Type: INDEX; Schema: public; Owner: visionzero
--

CREATE INDEX atd_txdot_person_prsn_gndr_id_index ON public.atd_txdot_person USING btree (prsn_gndr_id);


--
-- Name: atd_txdot_person_prsn_injry_sev_id_index; Type: INDEX; Schema: public; Owner: visionzero
--

CREATE INDEX atd_txdot_person_prsn_injry_sev_id_index ON public.atd_txdot_person USING btree (prsn_injry_sev_id);


--
-- Name: atd_txdot_person_sus_serious_injry_cnt_index; Type: INDEX; Schema: public; Owner: visionzero
--

CREATE INDEX atd_txdot_person_sus_serious_injry_cnt_index ON public.atd_txdot_person USING btree (sus_serious_injry_cnt);


--
-- Name: idx_atd_txdot_person_crash_id; Type: INDEX; Schema: public; Owner: visionzero
--

CREATE INDEX idx_atd_txdot_person_crash_id ON public.atd_txdot_person USING btree (crash_id);


--
-- Name: atd_txdot_person atd_txdot_person_audit_log; Type: TRIGGER; Schema: public; Owner: visionzero
--

CREATE TRIGGER atd_txdot_person_audit_log BEFORE UPDATE ON public.atd_txdot_person FOR EACH ROW EXECUTE FUNCTION public.atd_txdot_person_updates_audit_log();

ALTER TABLE public.atd_txdot_person DISABLE TRIGGER atd_txdot_person_audit_log;


--
-- Name: atd_txdot_person atd_txdot_person_fatal_insert; Type: TRIGGER; Schema: public; Owner: visionzero
--

CREATE TRIGGER atd_txdot_person_fatal_insert AFTER INSERT ON public.atd_txdot_person FOR EACH ROW WHEN ((new.prsn_injry_sev_id = 4)) EXECUTE FUNCTION public.fatality_insert();


--
-- Name: atd_txdot_person atd_txdot_person_crash_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: visionzero
--

ALTER TABLE ONLY public.atd_txdot_person
    ADD CONSTRAINT atd_txdot_person_crash_id_fkey FOREIGN KEY (crash_id) REFERENCES public.atd_txdot_crashes(crash_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: atd_txdot_person atd_txdot_person_prsn_injry_sev_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: visionzero
--

ALTER TABLE ONLY public.atd_txdot_person
    ADD CONSTRAINT atd_txdot_person_prsn_injry_sev_id_fkey FOREIGN KEY (prsn_injry_sev_id) REFERENCES public.atd_txdot__injry_sev_lkp(injry_sev_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--
