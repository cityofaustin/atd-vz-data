drop schema if exists vz cascade;
create schema vz;


CREATE TABLE vz.atd_txdot_crashes (
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
    geocoded character varying(1),
    geocode_status character varying(16),
    latitude_geocoded double precision,
    longitude_geocoded double precision,
    latitude_primary double precision,
    longitude_primary double precision,
    geocode_date timestamp without time zone,
    geocode_provider integer,
    qa_status integer,
    last_update timestamp without time zone,
    approval_date timestamp without time zone,
    approved_by character varying(128),
    is_retired boolean,
    updated_by character varying,
    address_confirmed_primary text,
    address_confirmed_secondary text,
    est_comp_cost numeric(10,2),
    est_econ_cost numeric(10,2),
    "position" geometry(Geometry,4326),
    apd_confirmed_fatality character varying(1),
    apd_confirmed_death_count integer,
    micromobility_device_flag character varying(1),
    cr3_stored_flag character varying(1),
    apd_human_update character varying,
    speed_mgmt_points numeric(10,2),
    geocode_match_quality numeric,
    geocode_match_metadata json,
    atd_mode_category_metadata json,
    location_id character varying,
    changes_approved_date timestamp without time zone,
    austin_full_purpose character varying(1),
    original_city_id integer,
    atd_fatality_count integer,
    temp_record boolean,
    cr3_file_metadata jsonb,
    cr3_ocr_extraction_date timestamp with time zone,
    investigator_narrative_ocr text,
    est_comp_cost_crash_based numeric(10,2),
    imported_at timestamp without time zone
);

ALTER TABLE ONLY vz.atd_txdot_crashes
    ADD CONSTRAINT atd_txdot_crashes_pkey PRIMARY KEY (crash_id);


--------------------------------------------------------------------------------

CREATE TABLE vz.atd_txdot_person (
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
    prsn_ethnicity_id integer,
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
    last_update timestamp without time zone,
    updated_by character varying(64),
    person_id integer NOT NULL,
    is_retired boolean,
    years_of_life_lost integer GENERATED ALWAYS AS (
CASE
    WHEN (prsn_injry_sev_id = 4) THEN GREATEST((75 - prsn_age), 0)
    ELSE 0
END) STORED
);

CREATE SEQUENCE vz.atd_txdot_person_person_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE vz.atd_txdot_person_person_id_seq OWNED BY vz.atd_txdot_person.person_id;

ALTER TABLE ONLY vz.atd_txdot_person ALTER COLUMN person_id SET DEFAULT nextval('vz.atd_txdot_person_person_id_seq'::regclass);

ALTER TABLE ONLY vz.atd_txdot_person
    ADD CONSTRAINT atd_txdot_person_unique UNIQUE (crash_id, unit_nbr, prsn_nbr, prsn_type_id, prsn_occpnt_pos_id);


--ALTER TABLE ONLY vz.atd_txdot_person
    --ADD CONSTRAINT atd_txdot_person_prsn_injry_sev_id_fkey FOREIGN KEY (prsn_injry_sev_id) REFERENCES vz.atd_txdot__injry_sev_lkp(injry_sev_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
--------------------------------------------------------------------------------

CREATE TABLE vz.atd_txdot_primaryperson (
    crash_id integer,
    unit_nbr integer,
    prsn_nbr integer,
    prsn_type_id integer,
    prsn_occpnt_pos_id integer,
    prsn_name_honorific character varying(32),
    prsn_injry_sev_id integer,
    prsn_age integer,
    prsn_ethnicity_id integer,
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
    drvr_drg_cat_1_id integer,
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
    drvr_lic_type_id integer,
    drvr_lic_cls_id integer,
    drvr_city_name character varying(128),
    drvr_state_id integer,
    drvr_zip character varying(16),
    last_update timestamp without time zone,
    updated_by character varying(64),
    primaryperson_id integer NOT NULL,
    is_retired boolean,
    years_of_life_lost integer GENERATED ALWAYS AS (
CASE
    WHEN (prsn_injry_sev_id = 4) THEN GREATEST((75 - prsn_age), 0)
    ELSE 0
END) STORED
);

CREATE SEQUENCE vz.atd_txdot_primaryperson_primaryperson_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE vz.atd_txdot_primaryperson_primaryperson_id_seq OWNED BY vz.atd_txdot_primaryperson.primaryperson_id;

ALTER TABLE ONLY vz.atd_txdot_primaryperson ALTER COLUMN primaryperson_id SET DEFAULT nextval('vz.atd_txdot_primaryperson_primaryperson_id_seq'::regclass);

ALTER TABLE ONLY vz.atd_txdot_primaryperson
    ADD CONSTRAINT atd_txdot_primaryperson_unique UNIQUE (crash_id, unit_nbr, prsn_nbr, prsn_type_id, prsn_occpnt_pos_id);



--------------------------------------------------------------------------------


CREATE TABLE vz.atd_txdot_units (
    crash_id integer,
    unit_nbr integer,
    unit_desc_id integer,
    veh_parked_fl character varying(1),
    veh_hnr_fl character varying(1),
    veh_lic_state_id integer,
    veh_lic_plate_nbr character varying(64),
    vin character varying(128),
    veh_mod_year integer,
    veh_color_id integer,
    veh_make_id integer,
    veh_mod_id integer,
    veh_body_styl_id integer,
    emer_respndr_fl character varying(1),
    owner_lessee character varying(32),
    ownr_mid_name character varying(128),
    ownr_name_sfx character varying(32),
    ownr_name_honorific character varying(32),
    ownr_city_name character varying(128),
    ownr_state_id integer,
    ownr_zip character varying(16),
    fin_resp_proof_id integer,
    fin_resp_type_id integer,
    fin_resp_name character varying(128),
    fin_resp_policy_nbr character varying(128),
    fin_resp_phone_nbr character varying(128),
    veh_inventoried_fl character varying(1),
    veh_transp_name character varying(128),
    veh_transp_dest character varying(256),
    veh_cmv_fl character varying(1),
    cmv_fiveton_fl character varying(32),
    cmv_hazmat_fl character varying(32),
    cmv_nine_plus_pass_fl character varying(32),
    cmv_veh_oper_id integer,
    cmv_carrier_id_type_id integer,
    cmv_carrier_id_nbr text,
    cmv_carrier_corp_name character varying(64),
    cmv_carrier_street_pfx character varying(64),
    cmv_carrier_street_nbr character varying(64),
    cmv_carrier_street_name character varying(128),
    cmv_carrier_street_sfx character varying(32),
    cmv_carrier_po_box character varying(128),
    cmv_carrier_city_name character varying(128),
    cmv_carrier_state_id integer,
    cmv_carrier_zip character varying(16),
    cmv_road_acc_id integer,
    cmv_veh_type_id integer,
    cmv_gvwr text,
    cmv_rgvw character varying(64),
    cmv_hazmat_rel_fl character varying(64),
    hazmat_cls_1_id integer,
    hazmat_idnbr_1_id integer,
    hazmat_cls_2_id integer,
    hazmat_idnbr_2_id integer,
    cmv_cargo_body_id integer,
    trlr1_gvwr character varying(64),
    trlr1_rgvw character varying(64),
    trlr1_type_id integer,
    trlr2_gvwr character varying(64),
    trlr2_rgvw character varying(64),
    trlr2_type_id integer,
    cmv_evnt1_id integer,
    cmv_evnt2_id integer,
    cmv_evnt3_id integer,
    cmv_evnt4_id integer,
    cmv_tot_axle character varying(64),
    cmv_tot_tire character varying(64),
    contrib_factr_1_id integer,
    contrib_factr_2_id integer,
    contrib_factr_3_id integer,
    contrib_factr_p1_id integer,
    contrib_factr_p2_id integer,
    veh_dfct_1_id integer,
    veh_dfct_2_id integer,
    veh_dfct_3_id integer,
    veh_dfct_p1_id integer,
    veh_dfct_p2_id integer,
    veh_trvl_dir_id integer,
    first_harm_evt_inv_id integer,
    sus_serious_injry_cnt integer,
    nonincap_injry_cnt integer,
    poss_injry_cnt integer,
    non_injry_cnt integer,
    unkn_injry_cnt integer,
    tot_injry_cnt integer,
    death_cnt integer,
    cmv_disabling_damage_fl character varying(64),
    cmv_trlr1_disabling_dmag_id integer,
    cmv_trlr2_disabling_dmag_id integer,
    cmv_bus_type_id integer,
    last_update timestamp without time zone,
    updated_by character varying(64),
    unit_id integer NOT NULL,
    is_retired boolean,
    atd_mode_category integer,
    travel_direction integer,
    movement_id integer,
    veh_damage_description1_id integer,
    veh_damage_severity1_id integer,
    veh_damage_direction_of_force1_id integer,
    veh_damage_description2_id integer,
    veh_damage_severity2_id integer,
    veh_damage_direction_of_force2_id integer,
    force_dir_2_id integer,
    veh_dmag_scl_2_id integer,
    veh_dmag_area_2_id integer,
    force_dir_1_id integer,
    veh_dmag_scl_1_id integer,
    veh_dmag_area_1_id integer,
    autonomous_unit_id integer,
    pedestrian_action_id integer,
    pedalcyclist_action_id integer,
    pbcat_pedestrian_id integer,
    pbcat_pedalcyclist_id integer,
    e_scooter_id integer
);

CREATE SEQUENCE vz.atd_txdot_units_unit_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE vz.atd_txdot_units_unit_id_seq OWNED BY vz.atd_txdot_units.unit_id;

ALTER TABLE ONLY vz.atd_txdot_units ALTER COLUMN unit_id SET DEFAULT nextval('vz.atd_txdot_units_unit_id_seq'::regclass);

ALTER TABLE ONLY vz.atd_txdot_units
    ADD CONSTRAINT atd_txdot_units_unique UNIQUE (crash_id, unit_nbr);




CREATE INDEX atd_txdot_crashes_apd_confirmed_fatality_index ON vz.atd_txdot_crashes USING btree (apd_confirmed_fatality);
CREATE INDEX atd_txdot_crashes_austin_full_purpose_index ON vz.atd_txdot_crashes USING btree (austin_full_purpose);
CREATE INDEX atd_txdot_crashes_case_id_index ON vz.atd_txdot_crashes USING btree (case_id);
CREATE INDEX atd_txdot_crashes_city_id_index ON vz.atd_txdot_crashes USING btree (city_id);
CREATE INDEX atd_txdot_crashes_cr3_file_metadata_index ON vz.atd_txdot_crashes USING gin (cr3_file_metadata);
CREATE INDEX atd_txdot_crashes_cr3_stored_flag_index ON vz.atd_txdot_crashes USING btree (cr3_stored_flag);
CREATE INDEX atd_txdot_crashes_crash_date_index ON vz.atd_txdot_crashes USING btree (crash_date);
CREATE INDEX atd_txdot_crashes_crash_fatal_fl_index ON vz.atd_txdot_crashes USING btree (crash_fatal_fl);
CREATE INDEX atd_txdot_crashes_death_cnt_index ON vz.atd_txdot_crashes USING btree (death_cnt);
CREATE INDEX atd_txdot_crashes_geocode_provider_index ON vz.atd_txdot_crashes USING btree (geocode_provider);
CREATE INDEX atd_txdot_crashes_geocode_status_index ON vz.atd_txdot_crashes USING btree (geocode_status);
CREATE INDEX atd_txdot_crashes_geocoded_index ON vz.atd_txdot_crashes USING btree (geocoded);
CREATE INDEX atd_txdot_crashes_investigat_agency_id_index ON vz.atd_txdot_crashes USING btree (investigat_agency_id);
CREATE INDEX atd_txdot_crashes_is_retired_index ON vz.atd_txdot_crashes USING btree (is_retired);
CREATE INDEX atd_txdot_crashes_original_city_id_index ON vz.atd_txdot_crashes USING btree (original_city_id);
CREATE INDEX atd_txdot_crashes_position_index ON vz.atd_txdot_crashes USING gist ("position");
CREATE INDEX atd_txdot_crashes_qa_status_index ON vz.atd_txdot_crashes USING btree (qa_status);
CREATE INDEX atd_txdot_crashes_sus_serious_injry_cnt_index ON vz.atd_txdot_crashes USING btree (sus_serious_injry_cnt);
CREATE INDEX atd_txdot_crashes_temp_record_index ON vz.atd_txdot_crashes USING btree (temp_record);


CREATE INDEX atd_txdot_person_death_cnt_index ON vz.atd_txdot_person USING btree (death_cnt);
CREATE INDEX atd_txdot_person_is_retired_index ON vz.atd_txdot_person USING btree (is_retired);
CREATE INDEX atd_txdot_person_person_id_index ON vz.atd_txdot_person USING btree (person_id);
CREATE INDEX atd_txdot_person_prsn_age_index ON vz.atd_txdot_person USING btree (prsn_age);
CREATE INDEX atd_txdot_person_prsn_death_date_index ON vz.atd_txdot_person USING btree (prsn_death_date);
CREATE INDEX atd_txdot_person_prsn_death_time_index ON vz.atd_txdot_person USING btree (prsn_death_time);
CREATE INDEX atd_txdot_person_prsn_ethnicity_id_index ON vz.atd_txdot_person USING btree (prsn_ethnicity_id);
CREATE INDEX atd_txdot_person_prsn_gndr_id_index ON vz.atd_txdot_person USING btree (prsn_gndr_id);
CREATE INDEX atd_txdot_person_prsn_injry_sev_id_index ON vz.atd_txdot_person USING btree (prsn_injry_sev_id);
CREATE INDEX atd_txdot_person_sus_serious_injry_cnt_index ON vz.atd_txdot_person USING btree (sus_serious_injry_cnt);
CREATE INDEX idx_atd_txdot_person_crash_id ON vz.atd_txdot_person USING btree (crash_id);


CREATE INDEX atd_txdot_primaryperson_death_cnt_index ON vz.atd_txdot_primaryperson USING btree (death_cnt);
CREATE INDEX atd_txdot_primaryperson_is_retired_index ON vz.atd_txdot_primaryperson USING btree (is_retired);
CREATE INDEX atd_txdot_primaryperson_primaryperson_id_index ON vz.atd_txdot_primaryperson USING btree (primaryperson_id);
CREATE INDEX atd_txdot_primaryperson_prsn_age_index ON vz.atd_txdot_primaryperson USING btree (prsn_age);
CREATE INDEX atd_txdot_primaryperson_prsn_death_date_index ON vz.atd_txdot_primaryperson USING btree (prsn_death_date);
CREATE INDEX atd_txdot_primaryperson_prsn_death_time_index ON vz.atd_txdot_primaryperson USING btree (prsn_death_time);
CREATE INDEX atd_txdot_primaryperson_prsn_ethnicity_id_index ON vz.atd_txdot_primaryperson USING btree (prsn_ethnicity_id);
CREATE INDEX atd_txdot_primaryperson_prsn_gndr_id_index ON vz.atd_txdot_primaryperson USING btree (prsn_gndr_id);
CREATE INDEX atd_txdot_primaryperson_prsn_injry_sev_id_index ON vz.atd_txdot_primaryperson USING btree (prsn_injry_sev_id);
CREATE INDEX atd_txdot_primaryperson_sus_serious_injry_cnt_index ON vz.atd_txdot_primaryperson USING btree (sus_serious_injry_cnt);
CREATE INDEX idx_atd_txdot_primaryperson_crash_id ON vz.atd_txdot_primaryperson USING btree (crash_id);


CREATE INDEX atd_txdot_units_death_cnt_index ON vz.atd_txdot_units USING btree (death_cnt);
CREATE INDEX atd_txdot_units_movement_id_index ON vz.atd_txdot_units USING btree (movement_id);
CREATE INDEX atd_txdot_units_sus_serious_injry_cnt_index ON vz.atd_txdot_units USING btree (sus_serious_injry_cnt);
CREATE INDEX atd_txdot_units_unit_id_index ON vz.atd_txdot_units USING btree (unit_id);
CREATE INDEX idx_atd_txdot_units_crash_id ON vz.atd_txdot_units USING btree (crash_id);
