create table _column_metadata (
    id serial primary key,
    column_name text not null,
    column_label text not null,
    record_type text not null,
    is_imported_from_cris boolean not null default false
);


insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('id', 'id', 'charges', false);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('crash_id', 'crash_id', 'charges', false);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('cris_crash_id', 'cris_crash_id', 'charges', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('person_id', 'person_id', 'charges', false);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('prsn_nbr', 'prsn_nbr', 'charges', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('cris_schema_version', 'cris_schema_version', 'charges', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('unit_nbr', 'unit_nbr', 'charges', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('charge_cat_id', 'charge_cat_id', 'charges', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('charge', 'charge', 'charges', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('citation_nbr', 'citation_nbr', 'charges', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('id', 'id', 'crashes', false);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('crash_id', 'crash_id', 'crashes', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('cris_schema_version', 'cris_schema_version', 'crashes', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('rpt_city_id', 'rpt_city_id', 'crashes', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('fhe_collsn_id', 'fhe_collsn_id', 'crashes', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('intrsct_relat_id', 'intrsct_relat_id', 'crashes', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('investigat_agency_id', 'investigat_agency_id', 'crashes', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('light_cond_id', 'light_cond_id', 'crashes', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('address_primary', 'address_primary', 'crashes', false);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('address_secondary', 'address_secondary', 'crashes', false);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('years_of_life_lost', 'years_of_life_lost', 'people', false);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('years_of_life_lost', 'years_of_life_lost', 'people', false);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('est_comp_cost_crash_based', 'est_comp_cost_crash_based', 'people', false);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('obj_struck_id', 'obj_struck_id', 'crashes', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('rpt_cris_cnty_id', 'rpt_cris_cnty_id', 'crashes', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('rpt_rdwy_sys_id', 'rpt_rdwy_sys_id', 'crashes', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('rpt_road_part_id', 'rpt_road_part_id', 'crashes', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('rpt_sec_rdwy_sys_id', 'rpt_sec_rdwy_sys_id', 'crashes', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('rpt_sec_road_part_id', 'rpt_sec_road_part_id', 'crashes', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('surf_cond_id', 'surf_cond_id', 'crashes', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('surf_type_id', 'surf_type_id', 'crashes', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('traffic_cntl_id', 'traffic_cntl_id', 'crashes', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('wthr_cond_id', 'wthr_cond_id', 'crashes', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('crash_timestamp', 'crash_timestamp', 'crashes', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('rpt_sec_street_pfx', 'rpt_sec_street_pfx', 'crashes', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('rpt_sec_street_sfx', 'rpt_sec_street_sfx', 'crashes', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('rpt_street_pfx', 'rpt_street_pfx', 'crashes', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('rpt_street_sfx', 'rpt_street_sfx', 'crashes', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('rpt_ref_mark_dir', 'rpt_ref_mark_dir', 'crashes', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('rpt_ref_mark_dist_uom', 'rpt_ref_mark_dist_uom', 'crashes', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('active_school_zone_fl', 'active_school_zone_fl', 'crashes', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('at_intrsct_fl', 'at_intrsct_fl', 'crashes', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('engineering_area', 'engineering_area', 'crashes', false);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('location_id', 'location_id', 'crashes', false);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('case_id', 'case_id', 'crashes', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('crash_speed_limit', 'crash_speed_limit', 'crashes', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('law_enforcement_fatality_num', 'law_enforcement_fatality_num', 'crashes', false);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('cr3_file_metadata', 'cr3_file_metadata', 'crashes', false);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('cr3_stored_flag', 'cr3_stored_flag', 'crashes', false);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('cr3_ocr_extraction_date', 'cr3_ocr_extraction_date', 'crashes', false);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('investigator_narrative', 'investigator_narrative', 'crashes', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('latitude', 'latitude', 'crashes', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('longitude', 'longitude', 'crashes', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('medical_advisory_fl', 'medical_advisory_fl', 'crashes', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('onsys_fl', 'onsys_fl', 'crashes', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('council_district', 'council_district', 'crashes', false);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('in_austin_full_purpose', 'in_austin_full_purpose', 'crashes', false);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('private_dr_fl', 'private_dr_fl', 'crashes', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('position', 'position', 'crashes', false);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('road_constr_zone_fl', 'road_constr_zone_fl', 'crashes', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('road_constr_zone_wrkr_fl', 'road_constr_zone_wrkr_fl', 'crashes', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('rpt_block_num', 'rpt_block_num', 'crashes', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('rpt_hwy_num', 'rpt_hwy_num', 'crashes', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('rpt_ref_mark_offset_amt', 'rpt_ref_mark_offset_amt', 'crashes', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('rpt_sec_block_num', 'rpt_sec_block_num', 'crashes', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('rpt_sec_hwy_num', 'rpt_sec_hwy_num', 'crashes', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('rpt_sec_street_desc', 'rpt_sec_street_desc', 'crashes', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('rpt_sec_street_name', 'rpt_sec_street_name', 'crashes', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('rpt_street_desc', 'rpt_street_desc', 'crashes', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('rpt_street_name', 'rpt_street_name', 'crashes', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('rr_relat_fl', 'rr_relat_fl', 'crashes', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('schl_bus_fl', 'schl_bus_fl', 'crashes', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('thousand_damage_fl', 'thousand_damage_fl', 'crashes', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('toll_road_fl', 'toll_road_fl', 'crashes', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('txdot_rptable_fl', 'txdot_rptable_fl', 'crashes', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('id', 'id', 'people', false);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('prsn_exp_homelessness', 'prsn_exp_homelessness', 'people', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('prsn_exp_homelessness', 'prsn_exp_homelessness', 'people', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('cris_schema_version', 'cris_schema_version', 'people', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('unit_id', 'unit_id', 'people', false);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('cris_crash_id', 'cris_crash_id', 'people', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('cris_crash_id', 'cris_crash_id', 'people', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('drvr_city_name', 'drvr_city_name', 'people', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('drvr_drg_cat_1_id', 'drvr_drg_cat_1_id', 'people', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('drvr_zip', 'drvr_zip', 'people', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('investigator_narrative_ocr', 'investigator_narrative_ocr', 'crashes', false);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('is_primary_person', 'is_primary_person', 'people', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('prsn_age', 'prsn_age', 'people', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('prsn_age', 'prsn_age', 'people', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('prsn_alc_rslt_id', 'prsn_alc_rslt_id', 'people', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('prsn_alc_rslt_id', 'prsn_alc_rslt_id', 'people', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('prsn_alc_spec_type_id', 'prsn_alc_spec_type_id', 'people', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('prsn_alc_spec_type_id', 'prsn_alc_spec_type_id', 'people', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('prsn_bac_test_rslt', 'prsn_bac_test_rslt', 'people', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('prsn_bac_test_rslt', 'prsn_bac_test_rslt', 'people', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('prsn_death_timestamp', 'prsn_death_timestamp', 'people', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('prsn_drg_rslt_id', 'prsn_drg_rslt_id', 'people', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('prsn_drg_rslt_id', 'prsn_drg_rslt_id', 'people', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('prsn_drg_spec_type_id', 'prsn_drg_spec_type_id', 'people', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('prsn_drg_spec_type_id', 'prsn_drg_spec_type_id', 'people', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('prsn_ethnicity_id', 'prsn_ethnicity_id', 'people', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('prsn_ethnicity_id', 'prsn_ethnicity_id', 'people', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('prsn_first_name', 'prsn_first_name', 'people', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('prsn_gndr_id', 'prsn_gndr_id', 'people', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('prsn_gndr_id', 'prsn_gndr_id', 'people', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('ems_id', 'ems_id', 'people', false);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('ems_id', 'ems_id', 'people', false);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('prsn_helmet_id', 'prsn_helmet_id', 'people', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('prsn_first_name', 'prsn_first_name', 'people', false);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('prsn_helmet_id', 'prsn_helmet_id', 'people', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('prsn_injry_sev_id', 'prsn_injry_sev_id', 'people', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('prsn_injry_sev_id', 'prsn_injry_sev_id', 'people', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('prsn_last_name', 'prsn_last_name', 'people', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('prsn_mid_name', 'prsn_mid_name', 'people', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('prsn_name_sfx', 'prsn_name_sfx', 'people', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('prsn_nbr', 'prsn_nbr', 'people', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('prsn_last_name', 'prsn_last_name', 'people', false);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('prsn_nbr', 'prsn_nbr', 'people', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('prsn_mid_name', 'prsn_mid_name', 'people', false);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('prsn_occpnt_pos_id', 'prsn_occpnt_pos_id', 'people', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('prsn_occpnt_pos_id', 'prsn_occpnt_pos_id', 'people', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('prsn_rest_id', 'prsn_rest_id', 'people', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('prsn_rest_id', 'prsn_rest_id', 'people', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('prsn_taken_by', 'prsn_taken_by', 'people', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('prsn_taken_by', 'prsn_taken_by', 'people', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('prsn_taken_to', 'prsn_taken_to', 'people', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('prsn_taken_to', 'prsn_taken_to', 'people', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('prsn_type_id', 'prsn_type_id', 'people', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('prsn_type_id', 'prsn_type_id', 'people', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('unit_nbr', 'unit_nbr', 'people', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('unit_nbr', 'unit_nbr', 'people', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('id', 'id', 'units', false);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('cris_schema_version', 'cris_schema_version', 'units', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('crash_id', 'crash_id', 'units', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('cris_crash_id', 'cris_crash_id', 'units', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('atd_mode_category', 'atd_mode_category', 'units', false);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('movement_id', 'movement_id', 'units', false);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('veh_body_styl_id', 'veh_body_styl_id', 'units', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('unit_desc_id', 'unit_desc_id', 'units', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('veh_trvl_dir_id', 'veh_trvl_dir_id', 'units', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('contrib_factr_1_id', 'contrib_factr_1_id', 'units', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('contrib_factr_2_id', 'contrib_factr_2_id', 'units', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('contrib_factr_3_id', 'contrib_factr_3_id', 'units', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('veh_damage_direction_of_force1_id', 'veh_damage_direction_of_force1_id', 'units', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('autonomous_unit_id', 'autonomous_unit_id', 'units', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('contrib_factr_p1_id', 'contrib_factr_p1_id', 'units', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('contrib_factr_p2_id', 'contrib_factr_p2_id', 'units', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('e_scooter_id', 'e_scooter_id', 'units', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('first_harm_evt_inv_id', 'first_harm_evt_inv_id', 'units', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('pbcat_pedalcyclist_id', 'pbcat_pedalcyclist_id', 'units', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('pbcat_pedestrian_id', 'pbcat_pedestrian_id', 'units', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('pedalcyclist_action_id', 'pedalcyclist_action_id', 'units', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('pedestrian_action_id', 'pedestrian_action_id', 'units', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('rpt_autonomous_level_engaged_id', 'rpt_autonomous_level_engaged_id', 'units', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('veh_damage_description1_id', 'veh_damage_description1_id', 'units', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('veh_damage_description2_id', 'veh_damage_description2_id', 'units', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('veh_damage_direction_of_force2_id', 'veh_damage_direction_of_force2_id', 'units', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('veh_damage_severity1_id', 'veh_damage_severity1_id', 'units', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('veh_damage_severity2_id', 'veh_damage_severity2_id', 'units', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('veh_make_id', 'veh_make_id', 'units', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('veh_mod_id', 'veh_mod_id', 'units', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('unit_nbr', 'unit_nbr', 'units', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('veh_mod_year', 'veh_mod_year', 'units', true);
insert into _column_metadata (column_name, column_label, record_type, is_imported_from_cris)
        values ('vin', 'vin', 'units', true)
