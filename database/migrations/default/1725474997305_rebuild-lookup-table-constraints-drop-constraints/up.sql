ALTER TABLE people_cris DROP CONSTRAINT IF EXISTS people_cris_drvr_drg_cat_1_id_fkey;
ALTER TABLE people_cris DROP CONSTRAINT IF EXISTS people_cris_prsn_alc_rslt_id_fkey;
ALTER TABLE people_cris DROP CONSTRAINT IF EXISTS people_cris_prsn_alc_spec_type_id_fkey;
ALTER TABLE people_cris DROP CONSTRAINT IF EXISTS people_cris_prsn_drg_rslt_id_fkey;
ALTER TABLE people_cris DROP CONSTRAINT IF EXISTS people_cris_prsn_drg_spec_type_id_fkey;
ALTER TABLE people_cris DROP CONSTRAINT IF EXISTS people_cris_prsn_ethnicity_id_fkey;
ALTER TABLE people_cris DROP CONSTRAINT IF EXISTS people_cris_prsn_gndr_id_fkey;
ALTER TABLE people_cris DROP CONSTRAINT IF EXISTS people_cris_prsn_helmet_id_fkey;
ALTER TABLE people_cris DROP CONSTRAINT IF EXISTS people_cris_prsn_injry_sev_id_fkey;
ALTER TABLE people_cris DROP CONSTRAINT IF EXISTS people_cris_prsn_occpnt_pos_id_fkey;
ALTER TABLE people_cris DROP CONSTRAINT IF EXISTS people_cris_prsn_rest_id_fkey;
ALTER TABLE people_cris DROP CONSTRAINT IF EXISTS people_cris_prsn_type_id_fkey;
ALTER TABLE crashes DROP CONSTRAINT IF EXISTS crashes_fhe_collsn_id_fkey;
ALTER TABLE crashes DROP CONSTRAINT IF EXISTS crashes_intrsct_relat_id_fkey;
ALTER TABLE crashes DROP CONSTRAINT IF EXISTS crashes_investigat_agency_id_fkey;
ALTER TABLE crashes DROP CONSTRAINT IF EXISTS crashes_light_cond_id_fkey;
ALTER TABLE crashes DROP CONSTRAINT IF EXISTS crashes_obj_struck_id_fkey;
ALTER TABLE crashes DROP CONSTRAINT IF EXISTS crashes_rpt_city_id_fkey;
ALTER TABLE crashes DROP CONSTRAINT IF EXISTS crashes_rpt_cris_cnty_id_fkey;
ALTER TABLE crashes DROP CONSTRAINT IF EXISTS crashes_rpt_rdwy_sys_id_fkey;
ALTER TABLE crashes DROP CONSTRAINT IF EXISTS crashes_rpt_road_part_id_fkey;
ALTER TABLE crashes DROP CONSTRAINT IF EXISTS crashes_rpt_sec_rdwy_sys_id_fkey;
ALTER TABLE crashes DROP CONSTRAINT IF EXISTS crashes_rpt_sec_road_part_id_fkey;
ALTER TABLE crashes DROP CONSTRAINT IF EXISTS crashes_surf_cond_id_fkey;
ALTER TABLE crashes DROP CONSTRAINT IF EXISTS crashes_surf_type_id_fkey;
ALTER TABLE crashes DROP CONSTRAINT IF EXISTS crashes_traffic_cntl_id_fkey;
ALTER TABLE crashes DROP CONSTRAINT IF EXISTS crashes_wthr_cond_id_fkey;
ALTER TABLE people DROP CONSTRAINT IF EXISTS people_drvr_drg_cat_1_id_fkey;
ALTER TABLE people DROP CONSTRAINT IF EXISTS people_prsn_alc_rslt_id_fkey;
ALTER TABLE people DROP CONSTRAINT IF EXISTS people_prsn_alc_spec_type_id_fkey;
ALTER TABLE people DROP CONSTRAINT IF EXISTS people_prsn_drg_rslt_id_fkey;
ALTER TABLE people DROP CONSTRAINT IF EXISTS people_prsn_drg_spec_type_id_fkey;
ALTER TABLE people DROP CONSTRAINT IF EXISTS people_prsn_ethnicity_id_fkey;
ALTER TABLE people DROP CONSTRAINT IF EXISTS people_prsn_gndr_id_fkey;
ALTER TABLE people DROP CONSTRAINT IF EXISTS people_prsn_helmet_id_fkey;
ALTER TABLE people DROP CONSTRAINT IF EXISTS people_prsn_injry_sev_id_fkey;
ALTER TABLE people DROP CONSTRAINT IF EXISTS people_prsn_occpnt_pos_id_fkey;
ALTER TABLE people DROP CONSTRAINT IF EXISTS people_prsn_rest_id_fkey;
ALTER TABLE people DROP CONSTRAINT IF EXISTS people_prsn_type_id_fkey;
ALTER TABLE crashes_edits DROP CONSTRAINT IF EXISTS crashes_edits_fhe_collsn_id_fkey;
ALTER TABLE crashes_edits DROP CONSTRAINT IF EXISTS crashes_edits_intrsct_relat_id_fkey;
ALTER TABLE crashes_edits DROP CONSTRAINT IF EXISTS crashes_edits_investigat_agency_id_fkey;
ALTER TABLE crashes_edits DROP CONSTRAINT IF EXISTS crashes_edits_light_cond_id_fkey;
ALTER TABLE crashes_edits DROP CONSTRAINT IF EXISTS crashes_edits_obj_struck_id_fkey;
ALTER TABLE crashes_edits DROP CONSTRAINT IF EXISTS crashes_edits_rpt_city_id_fkey;
ALTER TABLE crashes_edits DROP CONSTRAINT IF EXISTS crashes_edits_rpt_cris_cnty_id_fkey;
ALTER TABLE crashes_edits DROP CONSTRAINT IF EXISTS crashes_edits_rpt_rdwy_sys_id_fkey;
ALTER TABLE crashes_edits DROP CONSTRAINT IF EXISTS crashes_edits_rpt_road_part_id_fkey;
ALTER TABLE crashes_edits DROP CONSTRAINT IF EXISTS crashes_edits_rpt_sec_rdwy_sys_id_fkey;
ALTER TABLE crashes_edits DROP CONSTRAINT IF EXISTS crashes_edits_rpt_sec_road_part_id_fkey;
ALTER TABLE crashes_edits DROP CONSTRAINT IF EXISTS crashes_edits_surf_cond_id_fkey;
ALTER TABLE crashes_edits DROP CONSTRAINT IF EXISTS crashes_edits_surf_type_id_fkey;
ALTER TABLE crashes_edits DROP CONSTRAINT IF EXISTS crashes_edits_traffic_cntl_id_fkey;
ALTER TABLE crashes_edits DROP CONSTRAINT IF EXISTS crashes_edits_wthr_cond_id_fkey;
ALTER TABLE crashes_cris DROP CONSTRAINT IF EXISTS crashes_cris_fhe_collsn_id_fkey;
ALTER TABLE crashes_cris DROP CONSTRAINT IF EXISTS crashes_cris_intrsct_relat_id_fkey;
ALTER TABLE crashes_cris DROP CONSTRAINT IF EXISTS crashes_cris_investigat_agency_id_fkey;
ALTER TABLE crashes_cris DROP CONSTRAINT IF EXISTS crashes_cris_light_cond_id_fkey;
ALTER TABLE crashes_cris DROP CONSTRAINT IF EXISTS crashes_cris_obj_struck_id_fkey;
ALTER TABLE crashes_cris DROP CONSTRAINT IF EXISTS crashes_cris_rpt_city_id_fkey;
ALTER TABLE crashes_cris DROP CONSTRAINT IF EXISTS crashes_cris_rpt_cris_cnty_id_fkey;
ALTER TABLE crashes_cris DROP CONSTRAINT IF EXISTS crashes_cris_rpt_rdwy_sys_id_fkey;
ALTER TABLE crashes_cris DROP CONSTRAINT IF EXISTS crashes_cris_rpt_road_part_id_fkey;
ALTER TABLE crashes_cris DROP CONSTRAINT IF EXISTS crashes_cris_rpt_sec_rdwy_sys_id_fkey;
ALTER TABLE crashes_cris DROP CONSTRAINT IF EXISTS crashes_cris_rpt_sec_road_part_id_fkey;
ALTER TABLE crashes_cris DROP CONSTRAINT IF EXISTS crashes_cris_surf_cond_id_fkey;
ALTER TABLE crashes_cris DROP CONSTRAINT IF EXISTS crashes_cris_surf_type_id_fkey;
ALTER TABLE crashes_cris DROP CONSTRAINT IF EXISTS crashes_cris_traffic_cntl_id_fkey;
ALTER TABLE crashes_cris DROP CONSTRAINT IF EXISTS crashes_cris_wthr_cond_id_fkey;
ALTER TABLE units_cris DROP CONSTRAINT IF EXISTS units_cris_autonomous_unit_id_fkey;
ALTER TABLE units_cris DROP CONSTRAINT IF EXISTS units_cris_contrib_factr_1_id_fkey;
ALTER TABLE units_cris DROP CONSTRAINT IF EXISTS units_cris_contrib_factr_2_id_fkey;
ALTER TABLE units_cris DROP CONSTRAINT IF EXISTS units_cris_contrib_factr_3_id_fkey;
ALTER TABLE units_cris DROP CONSTRAINT IF EXISTS units_cris_contrib_factr_p1_id_fkey;
ALTER TABLE units_cris DROP CONSTRAINT IF EXISTS units_cris_contrib_factr_p2_id_fkey;
ALTER TABLE units_cris DROP CONSTRAINT IF EXISTS units_cris_e_scooter_id_fkey;
ALTER TABLE units_cris DROP CONSTRAINT IF EXISTS units_cris_first_harm_evt_inv_id_fkey;
ALTER TABLE units_cris DROP CONSTRAINT IF EXISTS units_cris_pbcat_pedalcyclist_id_fkey;
ALTER TABLE units_cris DROP CONSTRAINT IF EXISTS units_cris_pbcat_pedestrian_id_fkey;
ALTER TABLE units_cris DROP CONSTRAINT IF EXISTS units_cris_pedalcyclist_action_id_fkey;
ALTER TABLE units_cris DROP CONSTRAINT IF EXISTS units_cris_pedestrian_action_id_fkey;
ALTER TABLE units_cris DROP CONSTRAINT IF EXISTS units_cris_rpt_autonomous_level_engaged_id_fkey;
ALTER TABLE units_cris DROP CONSTRAINT IF EXISTS units_cris_unit_desc_id_fkey;
ALTER TABLE units_cris DROP CONSTRAINT IF EXISTS units_cris_veh_body_styl_id_fkey;
ALTER TABLE units_cris DROP CONSTRAINT IF EXISTS units_cris_veh_damage_description1_id_fkey;
ALTER TABLE units_cris DROP CONSTRAINT IF EXISTS units_cris_veh_damage_description2_id_fkey;
ALTER TABLE units_cris DROP CONSTRAINT IF EXISTS units_cris_veh_damage_direction_of_force1_id_fkey;
ALTER TABLE units_cris DROP CONSTRAINT IF EXISTS units_cris_veh_damage_direction_of_force2_id_fkey;
ALTER TABLE units_cris DROP CONSTRAINT IF EXISTS units_cris_veh_damage_severity1_id_fkey;
ALTER TABLE units_cris DROP CONSTRAINT IF EXISTS units_cris_veh_damage_severity2_id_fkey;
ALTER TABLE units_cris DROP CONSTRAINT IF EXISTS units_cris_veh_make_id_fkey;
ALTER TABLE units_cris DROP CONSTRAINT IF EXISTS units_cris_veh_mod_id_fkey;
ALTER TABLE units_cris DROP CONSTRAINT IF EXISTS units_cris_veh_trvl_dir_id_fkey;
ALTER TABLE people_edits DROP CONSTRAINT IF EXISTS people_edits_drvr_drg_cat_1_id_fkey;
ALTER TABLE people_edits DROP CONSTRAINT IF EXISTS people_edits_prsn_alc_rslt_id_fkey;
ALTER TABLE people_edits DROP CONSTRAINT IF EXISTS people_edits_prsn_alc_spec_type_id_fkey;
ALTER TABLE people_edits DROP CONSTRAINT IF EXISTS people_edits_prsn_drg_rslt_id_fkey;
ALTER TABLE people_edits DROP CONSTRAINT IF EXISTS people_edits_prsn_drg_spec_type_id_fkey;
ALTER TABLE people_edits DROP CONSTRAINT IF EXISTS people_edits_prsn_ethnicity_id_fkey;
ALTER TABLE people_edits DROP CONSTRAINT IF EXISTS people_edits_prsn_gndr_id_fkey;
ALTER TABLE people_edits DROP CONSTRAINT IF EXISTS people_edits_prsn_helmet_id_fkey;
ALTER TABLE people_edits DROP CONSTRAINT IF EXISTS people_edits_prsn_injry_sev_id_fkey;
ALTER TABLE people_edits DROP CONSTRAINT IF EXISTS people_edits_prsn_occpnt_pos_id_fkey;
ALTER TABLE people_edits DROP CONSTRAINT IF EXISTS people_edits_prsn_rest_id_fkey;
ALTER TABLE people_edits DROP CONSTRAINT IF EXISTS people_edits_prsn_type_id_fkey;
ALTER TABLE units_edits DROP CONSTRAINT IF EXISTS units_edits_autonomous_unit_id_fkey;
ALTER TABLE units_edits DROP CONSTRAINT IF EXISTS units_edits_contrib_factr_1_id_fkey;
ALTER TABLE units_edits DROP CONSTRAINT IF EXISTS units_edits_contrib_factr_2_id_fkey;
ALTER TABLE units_edits DROP CONSTRAINT IF EXISTS units_edits_contrib_factr_3_id_fkey;
ALTER TABLE units_edits DROP CONSTRAINT IF EXISTS units_edits_contrib_factr_p1_id_fkey;
ALTER TABLE units_edits DROP CONSTRAINT IF EXISTS units_edits_contrib_factr_p2_id_fkey;
ALTER TABLE units_edits DROP CONSTRAINT IF EXISTS units_edits_e_scooter_id_fkey;
ALTER TABLE units_edits DROP CONSTRAINT IF EXISTS units_edits_first_harm_evt_inv_id_fkey;
ALTER TABLE units_edits DROP CONSTRAINT IF EXISTS units_edits_movement_id_fkey;
ALTER TABLE units_edits DROP CONSTRAINT IF EXISTS units_edits_pbcat_pedalcyclist_id_fkey;
ALTER TABLE units_edits DROP CONSTRAINT IF EXISTS units_edits_pbcat_pedestrian_id_fkey;
ALTER TABLE units_edits DROP CONSTRAINT IF EXISTS units_edits_pedalcyclist_action_id_fkey;
ALTER TABLE units_edits DROP CONSTRAINT IF EXISTS units_edits_pedestrian_action_id_fkey;
ALTER TABLE units_edits DROP CONSTRAINT IF EXISTS units_edits_rpt_autonomous_level_engaged_id_fkey;
ALTER TABLE units_edits DROP CONSTRAINT IF EXISTS units_edits_unit_desc_id_fkey;
ALTER TABLE units_edits DROP CONSTRAINT IF EXISTS units_edits_veh_body_styl_id_fkey;
ALTER TABLE units_edits DROP CONSTRAINT IF EXISTS units_edits_veh_damage_description1_id_fkey;
ALTER TABLE units_edits DROP CONSTRAINT IF EXISTS units_edits_veh_damage_description2_id_fkey;
ALTER TABLE units_edits DROP CONSTRAINT IF EXISTS units_edits_veh_damage_direction_of_force1_id_fkey;
ALTER TABLE units_edits DROP CONSTRAINT IF EXISTS units_edits_veh_damage_direction_of_force2_id_fkey;
ALTER TABLE units_edits DROP CONSTRAINT IF EXISTS units_edits_veh_damage_severity1_id_fkey;
ALTER TABLE units_edits DROP CONSTRAINT IF EXISTS units_edits_veh_damage_severity2_id_fkey;
ALTER TABLE units_edits DROP CONSTRAINT IF EXISTS units_edits_veh_make_id_fkey;
ALTER TABLE units_edits DROP CONSTRAINT IF EXISTS units_edits_veh_mod_id_fkey;
ALTER TABLE units_edits DROP CONSTRAINT IF EXISTS units_edits_veh_trvl_dir_id_fkey;
ALTER TABLE units DROP CONSTRAINT IF EXISTS units_autonomous_unit_id_fkey;
ALTER TABLE units DROP CONSTRAINT IF EXISTS units_contrib_factr_1_id_fkey;
ALTER TABLE units DROP CONSTRAINT IF EXISTS units_contrib_factr_2_id_fkey;
ALTER TABLE units DROP CONSTRAINT IF EXISTS units_contrib_factr_3_id_fkey;
ALTER TABLE units DROP CONSTRAINT IF EXISTS units_contrib_factr_p1_id_fkey;
ALTER TABLE units DROP CONSTRAINT IF EXISTS units_contrib_factr_p2_id_fkey;
ALTER TABLE units DROP CONSTRAINT IF EXISTS units_e_scooter_id_fkey;
ALTER TABLE units DROP CONSTRAINT IF EXISTS units_first_harm_evt_inv_id_fkey;
ALTER TABLE units DROP CONSTRAINT IF EXISTS units_movement_id_fkey;
ALTER TABLE units DROP CONSTRAINT IF EXISTS units_pbcat_pedalcyclist_id_fkey;
ALTER TABLE units DROP CONSTRAINT IF EXISTS units_pbcat_pedestrian_id_fkey;
ALTER TABLE units DROP CONSTRAINT IF EXISTS units_pedalcyclist_action_id_fkey;
ALTER TABLE units DROP CONSTRAINT IF EXISTS units_pedestrian_action_id_fkey;
ALTER TABLE units DROP CONSTRAINT IF EXISTS units_rpt_autonomous_level_engaged_id_fkey;
ALTER TABLE units DROP CONSTRAINT IF EXISTS units_unit_desc_id_fkey;
ALTER TABLE units DROP CONSTRAINT IF EXISTS units_veh_body_styl_id_fkey;
ALTER TABLE units DROP CONSTRAINT IF EXISTS units_veh_damage_description1_id_fkey;
ALTER TABLE units DROP CONSTRAINT IF EXISTS units_veh_damage_description2_id_fkey;
ALTER TABLE units DROP CONSTRAINT IF EXISTS units_veh_damage_direction_of_force1_id_fkey;
ALTER TABLE units DROP CONSTRAINT IF EXISTS units_veh_damage_direction_of_force2_id_fkey;
ALTER TABLE units DROP CONSTRAINT IF EXISTS units_veh_damage_severity1_id_fkey;
ALTER TABLE units DROP CONSTRAINT IF EXISTS units_veh_damage_severity2_id_fkey;
ALTER TABLE units DROP CONSTRAINT IF EXISTS units_veh_make_id_fkey;
ALTER TABLE units DROP CONSTRAINT IF EXISTS units_veh_mod_id_fkey;
ALTER TABLE units DROP CONSTRAINT IF EXISTS units_veh_trvl_dir_id_fkey;
