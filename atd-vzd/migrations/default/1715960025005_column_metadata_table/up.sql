create table _column_metadata (
    id serial primary key,
    column_name text not null,
    record_type text not null,
    is_imported_from_cris boolean not null default false,
    UNIQUE (column_name, record_type)
);

comment on table _column_metadata is 'Table which tracks column metadata for crashes, units, people, and charges records. Is the used by CRIS import to determine which fields will be processed/upserted.';
comment on column _column_metadata.column_name is 'The name of the column in the db';
comment on column _column_metadata.record_type is 'The type of record tables associated with this colum: crashes/units/people/charges';
comment on column _column_metadata.is_imported_from_cris is 'If this column is populated via the CRIS import ETL';


insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('id', 'charges', false);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('crash_pk', 'charges', false);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('cris_crash_id', 'charges', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('is_deleted', 'crashes', false);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('is_deleted', 'units', false);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('is_deleted', 'people', false);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('is_temp_record', 'crashes', false);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('person_id', 'charges', false);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('prsn_nbr', 'charges', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('cris_schema_version', 'charges', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('unit_nbr', 'charges', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('charge', 'charges', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('citation_nbr', 'charges', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('id', 'crashes', false);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('cris_crash_id', 'crashes', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('cris_schema_version', 'crashes', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('rpt_city_id', 'crashes', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('fhe_collsn_id', 'crashes', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('intrsct_relat_id', 'crashes', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('investigat_agency_id', 'crashes', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('light_cond_id', 'crashes', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('address_primary', 'crashes', false);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('address_secondary', 'crashes', false);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('years_of_life_lost', 'people', false);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('est_comp_cost_crash_based', 'people', false);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('obj_struck_id', 'crashes', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('rpt_cris_cnty_id', 'crashes', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('rpt_rdwy_sys_id', 'crashes', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('rpt_road_part_id', 'crashes', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('rpt_sec_rdwy_sys_id', 'crashes', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('rpt_sec_road_part_id', 'crashes', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('surf_cond_id', 'crashes', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('surf_type_id', 'crashes', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('traffic_cntl_id', 'crashes', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('wthr_cond_id', 'crashes', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('crash_timestamp', 'crashes', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('rpt_sec_street_pfx', 'crashes', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('rpt_sec_street_sfx', 'crashes', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('rpt_street_pfx', 'crashes', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('rpt_street_sfx', 'crashes', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('rpt_ref_mark_nbr', 'crashes', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('rpt_ref_mark_dir', 'crashes', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('rpt_ref_mark_dist_uom', 'crashes', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('active_school_zone_fl', 'crashes', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('at_intrsct_fl', 'crashes', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('engineering_area', 'crashes', false);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('location_id', 'crashes', false);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('case_id', 'crashes', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('crash_speed_limit', 'crashes', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('law_enforcement_ytd_fatality_num', 'crashes', false);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('cr3_processed_at', 'crashes', false);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('cr3_stored_fl', 'crashes', false);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('investigator_narrative', 'crashes', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('latitude', 'crashes', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('longitude', 'crashes', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('medical_advisory_fl', 'crashes', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('onsys_fl', 'crashes', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('council_district', 'crashes', false);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('in_austin_full_purpose', 'crashes', false);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('private_dr_fl', 'crashes', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('position', 'crashes', false);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('road_constr_zone_fl', 'crashes', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('road_constr_zone_wrkr_fl', 'crashes', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('rpt_block_num', 'crashes', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('rpt_hwy_num', 'crashes', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('rpt_hwy_sfx', 'crashes', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('rpt_ref_mark_offset_amt', 'crashes', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('rpt_sec_block_num', 'crashes', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('rpt_sec_hwy_num', 'crashes', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('rpt_sec_hwy_sfx', 'crashes', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('rpt_sec_street_desc', 'crashes', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('rpt_sec_street_name', 'crashes', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('rpt_street_desc', 'crashes', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('rpt_street_name', 'crashes', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('rr_relat_fl', 'crashes', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('schl_bus_fl', 'crashes', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('thousand_damage_fl', 'crashes', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('toll_road_fl', 'crashes', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('txdot_rptable_fl', 'crashes', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('record_locator', 'crashes', false);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('id', 'people', false);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('prsn_exp_homelessness', 'people', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('cris_schema_version', 'people', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('unit_id', 'people', false);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('cris_crash_id', 'people', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('drvr_city_name', 'people', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('drvr_drg_cat_1_id', 'people', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('drvr_zip', 'people', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('is_primary_person', 'people', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('prsn_age', 'people', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('prsn_alc_rslt_id', 'people', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('prsn_alc_spec_type_id', 'people', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('prsn_bac_test_rslt', 'people', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('prsn_death_timestamp', 'people', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('prsn_drg_rslt_id', 'people', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('prsn_drg_spec_type_id', 'people', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('prsn_ethnicity_id', 'people', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('prsn_first_name', 'people', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('prsn_gndr_id', 'people', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('ems_id', 'people', false);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('prsn_helmet_id', 'people', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('prsn_injry_sev_id', 'people', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('prsn_last_name', 'people', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('prsn_mid_name', 'people', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('prsn_name_sfx', 'people', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('prsn_nbr', 'people', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('prsn_occpnt_pos_id', 'people', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('prsn_rest_id', 'people', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('prsn_taken_by', 'people', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('prsn_taken_to', 'people', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('prsn_type_id', 'people', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('unit_nbr', 'people', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('id', 'units', false);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('cris_schema_version', 'units', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('crash_pk', 'units', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('cris_crash_id', 'units', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('vz_mode_category_id', 'units', false);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('movement_id', 'units', false);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('veh_body_styl_id', 'units', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('unit_desc_id', 'units', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('veh_trvl_dir_id', 'units', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('contrib_factr_1_id', 'units', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('contrib_factr_2_id', 'units', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('contrib_factr_3_id', 'units', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('veh_damage_direction_of_force1_id', 'units', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('autonomous_unit_id', 'units', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('contrib_factr_p1_id', 'units', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('contrib_factr_p2_id', 'units', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('e_scooter_id', 'units', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('first_harm_evt_inv_id', 'units', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('pbcat_pedalcyclist_id', 'units', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('pbcat_pedestrian_id', 'units', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('pedalcyclist_action_id', 'units', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('pedestrian_action_id', 'units', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('rpt_autonomous_level_engaged_id', 'units', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('veh_damage_description1_id', 'units', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('veh_damage_description2_id', 'units', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('veh_damage_direction_of_force2_id', 'units', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('veh_damage_severity1_id', 'units', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('veh_damage_severity2_id', 'units', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('veh_make_id', 'units', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('veh_mod_id', 'units', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('unit_nbr', 'units', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('veh_mod_year', 'units', true);
insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('vin', 'units', true)
