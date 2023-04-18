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
-- Name: atd_txdot_crashes; Type: TABLE; Schema: public; Owner: visionzero
--

CREATE TABLE public.atd_txdot_crashes (
    crash_id integer NOT NULL,
    crash_fatal_fl character varying(1),
    cmv_involv_fl character varying(1),
    schl_bus_fl character varying(1),
    rr_relat_fl character varying(1),
    medical_advisory_fl character varying(1),
    amend_supp_fl character varying(1),
    active_school_zone_fl character varying(1),
    crash_date date,
    crash_time time without time zone,
    case_id character varying(32),
    local_use character varying(32),
    rpt_cris_cnty_id integer,
    rpt_city_id integer,
    rpt_outside_city_limit_fl character varying(1),
    thousand_damage_fl character varying(1),
    rpt_latitude double precision,
    rpt_longitude double precision,
    rpt_rdwy_sys_id integer,
    rpt_hwy_num character varying(32),
    rpt_hwy_sfx character varying(32),
    rpt_road_part_id integer,
    rpt_block_num character varying(32),
    rpt_street_pfx character varying(32),
    rpt_street_name character varying(256),
    rpt_street_sfx character varying(32),
    private_dr_fl character varying(1),
    toll_road_fl character varying(1),
    crash_speed_limit integer,
    road_constr_zone_fl character varying(1),
    road_constr_zone_wrkr_fl character varying(1),
    rpt_street_desc character varying(256),
    at_intrsct_fl character varying(1),
    rpt_sec_rdwy_sys_id integer,
    rpt_sec_hwy_num character varying(32),
    rpt_sec_hwy_sfx character varying(25),
    rpt_sec_road_part_id integer,
    rpt_sec_block_num character varying(32),
    rpt_sec_street_pfx character varying(32),
    rpt_sec_street_name character varying(256),
    rpt_sec_street_sfx character varying(32),
    rpt_ref_mark_offset_amt double precision,
    rpt_ref_mark_dist_uom character varying(16),
    rpt_ref_mark_dir character varying(16),
    rpt_ref_mark_nbr character varying(32),
    rpt_sec_street_desc character varying(256),
    rpt_crossingnumber character varying(32),
    wthr_cond_id integer,
    light_cond_id integer,
    entr_road_id integer,
    road_type_id integer,
    road_algn_id integer,
    surf_cond_id integer,
    traffic_cntl_id integer,
    investigat_notify_time time without time zone,
    investigat_notify_meth character varying(32),
    investigat_arrv_time time without time zone,
    report_date date,
    investigat_comp_fl character varying(1),
    investigator_name character varying(128),
    id_number character varying(32),
    ori_number character varying(32),
    investigat_agency_id integer,
    investigat_area_id integer,
    investigat_district_id integer,
    investigat_region_id integer,
    bridge_detail_id integer,
    harm_evnt_id integer,
    intrsct_relat_id integer,
    fhe_collsn_id integer,
    obj_struck_id integer,
    othr_factr_id integer,
    road_part_adj_id integer,
    road_cls_id integer,
    road_relat_id integer,
    phys_featr_1_id integer,
    phys_featr_2_id integer,
    cnty_id integer,
    city_id integer,
    latitude double precision,
    longitude double precision,
    hwy_sys character varying(32),
    hwy_nbr character varying(32),
    hwy_sfx character varying(32),
    dfo double precision,
    street_name character varying(256),
    street_nbr character varying(32),
    control integer,
    section integer,
    milepoint double precision,
    ref_mark_nbr integer,
    ref_mark_displ double precision,
    hwy_sys_2 character varying(32),
    hwy_nbr_2 character varying(32),
    hwy_sfx_2 character varying(32),
    street_name_2 character varying(256),
    street_nbr_2 character varying(32),
    control_2 integer,
    section_2 integer,
    milepoint_2 double precision,
    txdot_rptable_fl character varying(1),
    onsys_fl character varying(1),
    rural_fl character varying(1),
    crash_sev_id integer,
    pop_group_id integer,
    located_fl character varying(1),
    day_of_week character varying(8),
    hwy_dsgn_lane_id character varying(25),
    hwy_dsgn_hrt_id character varying(25),
    hp_shldr_left character varying(25),
    hp_shldr_right character varying(25),
    hp_median_width character varying(25),
    base_type_id character varying(25),
    nbr_of_lane character varying(25),
    row_width_usual character varying(25),
    roadbed_width character varying(25),
    surf_width character varying(25),
    surf_type_id character varying(25),
    curb_type_left_id integer,
    curb_type_right_id integer,
    shldr_type_left_id integer,
    shldr_width_left integer,
    shldr_use_left_id integer,
    shldr_type_right_id integer,
    shldr_width_right integer,
    shldr_use_right_id integer,
    median_type_id integer,
    median_width integer,
    rural_urban_type_id integer,
    func_sys_id integer,
    adt_curnt_amt integer,
    adt_curnt_year integer,
    adt_adj_curnt_amt integer,
    pct_single_trk_adt double precision,
    pct_combo_trk_adt double precision,
    trk_aadt_pct double precision,
    curve_type_id integer,
    curve_lngth integer,
    cd_degr integer,
    delta_left_right_id integer,
    dd_degr integer,
    feature_crossed character varying(32),
    structure_number character varying(32),
    i_r_min_vert_clear character varying(32),
    approach_width character varying(32),
    bridge_median_id character varying(32),
    bridge_loading_type_id character varying(32),
    bridge_loading_in_1000_lbs character varying(32),
    bridge_srvc_type_on_id character varying(32),
    bridge_srvc_type_under_id character varying(32),
    culvert_type_id character varying(32),
    roadway_width character varying(32),
    deck_width character varying(32),
    bridge_dir_of_traffic_id character varying(32),
    bridge_rte_struct_func_id character varying(32),
    bridge_ir_struct_func_id character varying(32),
    crossingnumber character varying(32),
    rrco character varying(32),
    poscrossing_id character varying(32),
    wdcode_id character varying(32),
    standstop character varying(32),
    yield character varying(32),
    sus_serious_injry_cnt integer,
    nonincap_injry_cnt integer,
    poss_injry_cnt integer,
    non_injry_cnt integer,
    unkn_injry_cnt integer,
    tot_injry_cnt integer,
    death_cnt integer,
    mpo_id integer,
    investigat_service_id integer,
    investigat_da_id integer,
    investigator_narrative text,
    geocoded character varying(1) DEFAULT 'N'::character varying,
    geocode_status character varying(16) DEFAULT 'NA'::character varying NOT NULL,
    latitude_geocoded double precision,
    longitude_geocoded double precision,
    latitude_primary double precision,
    longitude_primary double precision,
    geocode_date timestamp without time zone,
    geocode_provider integer DEFAULT 0,
    qa_status integer DEFAULT 0 NOT NULL,
    last_update timestamp without time zone DEFAULT now(),
    approval_date timestamp without time zone,
    approved_by character varying(128),
    is_retired boolean DEFAULT false,
    updated_by character varying,
    address_confirmed_primary text,
    address_confirmed_secondary text,
    est_comp_cost numeric(10,2) DEFAULT 0.00,
    est_econ_cost numeric(10,2) DEFAULT 0.00,
    "position" public.geometry(Geometry,4326),
    apd_confirmed_fatality character varying(1) DEFAULT 'N'::character varying NOT NULL,
    apd_confirmed_death_count integer,
    micromobility_device_flag character varying(1) DEFAULT 'N'::character varying NOT NULL,
    cr3_stored_flag character varying(1) DEFAULT 'N'::character varying NOT NULL,
    apd_human_update character varying DEFAULT 'N'::character varying NOT NULL,
    speed_mgmt_points numeric(10,2) DEFAULT 0.00,
    geocode_match_quality numeric,
    geocode_match_metadata json,
    atd_mode_category_metadata json,
    location_id character varying,
    changes_approved_date timestamp without time zone,
    austin_full_purpose character varying(1) DEFAULT 'N'::character varying NOT NULL,
    original_city_id integer,
    atd_fatality_count integer,
    temp_record boolean DEFAULT false,
    cr3_file_metadata jsonb,
    cr3_ocr_extraction_date timestamp with time zone,
    investigator_narrative_ocr text,
    est_comp_cost_crash_based numeric(10,2) DEFAULT 0,
    imported_at timestamp without time zone DEFAULT now(),
    law_enforcement_num integer
);


ALTER TABLE public.atd_txdot_crashes OWNER TO visionzero;

--
-- Name: atd_txdot_crashes atd_txdot_crashes_pkey; Type: CONSTRAINT; Schema: public; Owner: visionzero
--

ALTER TABLE ONLY public.atd_txdot_crashes
    ADD CONSTRAINT atd_txdot_crashes_pkey PRIMARY KEY (crash_id);


--
-- Name: atd_txdot_crashes_apd_confirmed_fatality_index; Type: INDEX; Schema: public; Owner: visionzero
--

CREATE INDEX atd_txdot_crashes_apd_confirmed_fatality_index ON public.atd_txdot_crashes USING btree (apd_confirmed_fatality);


--
-- Name: atd_txdot_crashes_austin_full_purpose_index; Type: INDEX; Schema: public; Owner: visionzero
--

CREATE INDEX atd_txdot_crashes_austin_full_purpose_index ON public.atd_txdot_crashes USING btree (austin_full_purpose);


--
-- Name: atd_txdot_crashes_case_id_index; Type: INDEX; Schema: public; Owner: visionzero
--

CREATE INDEX atd_txdot_crashes_case_id_index ON public.atd_txdot_crashes USING btree (case_id);


--
-- Name: atd_txdot_crashes_city_id_index; Type: INDEX; Schema: public; Owner: visionzero
--

CREATE INDEX atd_txdot_crashes_city_id_index ON public.atd_txdot_crashes USING btree (city_id);


--
-- Name: atd_txdot_crashes_cr3_file_metadata_index; Type: INDEX; Schema: public; Owner: visionzero
--

CREATE INDEX atd_txdot_crashes_cr3_file_metadata_index ON public.atd_txdot_crashes USING gin (cr3_file_metadata);


--
-- Name: atd_txdot_crashes_cr3_stored_flag_index; Type: INDEX; Schema: public; Owner: visionzero
--

CREATE INDEX atd_txdot_crashes_cr3_stored_flag_index ON public.atd_txdot_crashes USING btree (cr3_stored_flag);


--
-- Name: atd_txdot_crashes_crash_date_index; Type: INDEX; Schema: public; Owner: visionzero
--

CREATE INDEX atd_txdot_crashes_crash_date_index ON public.atd_txdot_crashes USING btree (crash_date);


--
-- Name: atd_txdot_crashes_crash_fatal_fl_index; Type: INDEX; Schema: public; Owner: visionzero
--

CREATE INDEX atd_txdot_crashes_crash_fatal_fl_index ON public.atd_txdot_crashes USING btree (crash_fatal_fl);


--
-- Name: atd_txdot_crashes_death_cnt_index; Type: INDEX; Schema: public; Owner: visionzero
--

CREATE INDEX atd_txdot_crashes_death_cnt_index ON public.atd_txdot_crashes USING btree (death_cnt);


--
-- Name: atd_txdot_crashes_geocode_provider_index; Type: INDEX; Schema: public; Owner: visionzero
--

CREATE INDEX atd_txdot_crashes_geocode_provider_index ON public.atd_txdot_crashes USING btree (geocode_provider);


--
-- Name: atd_txdot_crashes_geocode_status_index; Type: INDEX; Schema: public; Owner: visionzero
--

CREATE INDEX atd_txdot_crashes_geocode_status_index ON public.atd_txdot_crashes USING btree (geocode_status);


--
-- Name: atd_txdot_crashes_geocoded_index; Type: INDEX; Schema: public; Owner: visionzero
--

CREATE INDEX atd_txdot_crashes_geocoded_index ON public.atd_txdot_crashes USING btree (geocoded);


--
-- Name: atd_txdot_crashes_investigat_agency_id_index; Type: INDEX; Schema: public; Owner: visionzero
--

CREATE INDEX atd_txdot_crashes_investigat_agency_id_index ON public.atd_txdot_crashes USING btree (investigat_agency_id);


--
-- Name: atd_txdot_crashes_is_retired_index; Type: INDEX; Schema: public; Owner: visionzero
--

CREATE INDEX atd_txdot_crashes_is_retired_index ON public.atd_txdot_crashes USING btree (is_retired);


--
-- Name: atd_txdot_crashes_original_city_id_index; Type: INDEX; Schema: public; Owner: visionzero
--

CREATE INDEX atd_txdot_crashes_original_city_id_index ON public.atd_txdot_crashes USING btree (original_city_id);


--
-- Name: atd_txdot_crashes_position_index; Type: INDEX; Schema: public; Owner: visionzero
--

CREATE INDEX atd_txdot_crashes_position_index ON public.atd_txdot_crashes USING gist ("position");


--
-- Name: atd_txdot_crashes_qa_status_index; Type: INDEX; Schema: public; Owner: visionzero
--

CREATE INDEX atd_txdot_crashes_qa_status_index ON public.atd_txdot_crashes USING btree (qa_status);


--
-- Name: atd_txdot_crashes_sus_serious_injry_cnt_index; Type: INDEX; Schema: public; Owner: visionzero
--

CREATE INDEX atd_txdot_crashes_sus_serious_injry_cnt_index ON public.atd_txdot_crashes USING btree (sus_serious_injry_cnt);


--
-- Name: atd_txdot_crashes_temp_record_index; Type: INDEX; Schema: public; Owner: visionzero
--

CREATE INDEX atd_txdot_crashes_temp_record_index ON public.atd_txdot_crashes USING btree (temp_record);


--
-- Name: atd_txdot_crashes atd_txdot_crashes_audit_log; Type: TRIGGER; Schema: public; Owner: visionzero
--

CREATE TRIGGER atd_txdot_crashes_audit_log BEFORE INSERT OR UPDATE ON public.atd_txdot_crashes FOR EACH ROW EXECUTE FUNCTION public.atd_txdot_crashes_updates_audit_log();


--
-- Name: atd_txdot_crashes notify_hasura_jurisdiction_from_latlon_INSERT; Type: TRIGGER; Schema: public; Owner: visionzero
--

CREATE TRIGGER "notify_hasura_jurisdiction_from_latlon_INSERT" AFTER INSERT ON public.atd_txdot_crashes FOR EACH ROW EXECUTE FUNCTION hdb_catalog."notify_hasura_jurisdiction_from_latlon_INSERT"();


--
-- Name: atd_txdot_crashes notify_hasura_jurisdiction_from_latlon_UPDATE; Type: TRIGGER; Schema: public; Owner: visionzero
--

CREATE TRIGGER "notify_hasura_jurisdiction_from_latlon_UPDATE" AFTER UPDATE ON public.atd_txdot_crashes FOR EACH ROW EXECUTE FUNCTION hdb_catalog."notify_hasura_jurisdiction_from_latlon_UPDATE"();


--
-- Name: atd_txdot_crashes notify_hasura_location_from_latlon_INSERT; Type: TRIGGER; Schema: public; Owner: visionzero
--

CREATE TRIGGER "notify_hasura_location_from_latlon_INSERT" AFTER INSERT ON public.atd_txdot_crashes FOR EACH ROW EXECUTE FUNCTION hdb_catalog."notify_hasura_location_from_latlon_INSERT"();


--
-- Name: atd_txdot_crashes notify_hasura_location_from_latlon_UPDATE; Type: TRIGGER; Schema: public; Owner: visionzero
--

CREATE TRIGGER "notify_hasura_location_from_latlon_UPDATE" AFTER UPDATE ON public.atd_txdot_crashes FOR EACH ROW EXECUTE FUNCTION hdb_catalog."notify_hasura_location_from_latlon_UPDATE"();


--
-- PostgreSQL database dump complete
--
