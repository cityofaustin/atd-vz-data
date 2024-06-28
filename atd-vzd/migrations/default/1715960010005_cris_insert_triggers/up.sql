create or replace function public.crashes_cris_insert_rows()
returns trigger
language plpgsql
as
$$
BEGIN
    -- insert new combined / official record
    INSERT INTO public.crashes (active_school_zone_fl, at_intrsct_fl, case_id, crash_id, crash_speed_limit, crash_timestamp, fhe_collsn_id, id, intrsct_relat_id, investigat_agency_id, investigator_narrative, latitude, light_cond_id, longitude, medical_advisory_fl, obj_struck_id, onsys_fl, private_dr_fl, road_constr_zone_fl, road_constr_zone_wrkr_fl, rpt_block_num, rpt_city_id, rpt_cris_cnty_id, rpt_hwy_num, rpt_rdwy_sys_id, rpt_ref_mark_dir, rpt_ref_mark_dist_uom, rpt_ref_mark_offset_amt, rpt_road_part_id, rpt_sec_block_num, rpt_sec_hwy_num, rpt_sec_rdwy_sys_id, rpt_sec_road_part_id, rpt_sec_street_desc, rpt_sec_street_name, rpt_sec_street_pfx, rpt_sec_street_sfx, rpt_street_desc, rpt_street_name, rpt_street_pfx, rpt_street_sfx, rr_relat_fl, schl_bus_fl, surf_cond_id, surf_type_id, thousand_damage_fl, toll_road_fl, traffic_cntl_id, txdot_rptable_fl, wthr_cond_id, created_by, updated_by) values (
        new.active_school_zone_fl, new.at_intrsct_fl, new.case_id, new.crash_id, new.crash_speed_limit, new.crash_timestamp, new.fhe_collsn_id, new.id, new.intrsct_relat_id, new.investigat_agency_id, new.investigator_narrative, new.latitude, new.light_cond_id, new.longitude, new.medical_advisory_fl, new.obj_struck_id, new.onsys_fl, new.private_dr_fl, new.road_constr_zone_fl, new.road_constr_zone_wrkr_fl, new.rpt_block_num, new.rpt_city_id, new.rpt_cris_cnty_id, new.rpt_hwy_num, new.rpt_rdwy_sys_id, new.rpt_ref_mark_dir, new.rpt_ref_mark_dist_uom, new.rpt_ref_mark_offset_amt, new.rpt_road_part_id, new.rpt_sec_block_num, new.rpt_sec_hwy_num, new.rpt_sec_rdwy_sys_id, new.rpt_sec_road_part_id, new.rpt_sec_street_desc, new.rpt_sec_street_name, new.rpt_sec_street_pfx, new.rpt_sec_street_sfx, new.rpt_street_desc, new.rpt_street_name, new.rpt_street_pfx, new.rpt_street_sfx, new.rr_relat_fl, new.schl_bus_fl, new.surf_cond_id, new.surf_type_id, new.thousand_damage_fl, new.toll_road_fl, new.traffic_cntl_id, new.txdot_rptable_fl, new.wthr_cond_id, new.created_by, new.updated_by
    );
    -- insert new (editable) vz record (only record ID)
    INSERT INTO public.crashes_edits (id) values (new.id);

    RETURN NULL;
END;
$$;


create or replace trigger insert_new_crashes_cris
after insert on public.crashes_cris
for each row
execute procedure public.crashes_cris_insert_rows();


create or replace function public.units_cris_insert_rows()
returns trigger
language plpgsql
as
$$
BEGIN
    -- insert new combined / official record
    INSERT INTO public.units (autonomous_unit_id, contrib_factr_1_id, contrib_factr_2_id, contrib_factr_3_id, contrib_factr_p1_id, contrib_factr_p2_id, crash_id, cris_crash_id, e_scooter_id, first_harm_evt_inv_id, id, pbcat_pedalcyclist_id, pbcat_pedestrian_id, pedalcyclist_action_id, pedestrian_action_id, rpt_autonomous_level_engaged_id, unit_desc_id, unit_nbr, veh_body_styl_id, veh_damage_description1_id, veh_damage_description2_id, veh_damage_direction_of_force1_id, veh_damage_direction_of_force2_id, veh_damage_severity1_id, veh_damage_severity2_id, veh_make_id, veh_mod_id, veh_mod_year, veh_trvl_dir_id, vin, created_by, updated_by) values (
        new.autonomous_unit_id, new.contrib_factr_1_id, new.contrib_factr_2_id, new.contrib_factr_3_id, new.contrib_factr_p1_id, new.contrib_factr_p2_id, new.crash_id, new.cris_crash_id, new.e_scooter_id, new.first_harm_evt_inv_id, new.id, new.pbcat_pedalcyclist_id, new.pbcat_pedestrian_id, new.pedalcyclist_action_id, new.pedestrian_action_id, new.rpt_autonomous_level_engaged_id, new.unit_desc_id, new.unit_nbr, new.veh_body_styl_id, new.veh_damage_description1_id, new.veh_damage_description2_id, new.veh_damage_direction_of_force1_id, new.veh_damage_direction_of_force2_id, new.veh_damage_severity1_id, new.veh_damage_severity2_id, new.veh_make_id, new.veh_mod_id, new.veh_mod_year, new.veh_trvl_dir_id, new.vin, new.created_by, new.updated_by
    );
    -- insert new (editable) vz record (only record ID)
    INSERT INTO public.units_edits (id) values (new.id);

    RETURN NULL;
END;
$$;


create or replace trigger insert_new_units_cris
after insert on public.units_cris
for each row
execute procedure public.units_cris_insert_rows();


create or replace function public.people_cris_insert_rows()
returns trigger
language plpgsql
as
$$
BEGIN
    -- insert new combined / official record
    INSERT INTO public.people (drvr_city_name, drvr_drg_cat_1_id, drvr_zip, id, is_primary_person, prsn_age, prsn_alc_rslt_id, prsn_alc_spec_type_id, prsn_bac_test_rslt, prsn_death_timestamp, prsn_drg_rslt_id, prsn_drg_spec_type_id, prsn_ethnicity_id, prsn_exp_homelessness, prsn_first_name, prsn_gndr_id, prsn_helmet_id, prsn_injry_sev_id, prsn_last_name, prsn_mid_name, prsn_name_sfx, prsn_nbr, prsn_occpnt_pos_id, prsn_rest_id, prsn_taken_by, prsn_taken_to, prsn_type_id, unit_id, created_by, updated_by) values (
        new.drvr_city_name, new.drvr_drg_cat_1_id, new.drvr_zip, new.id, new.is_primary_person, new.prsn_age, new.prsn_alc_rslt_id, new.prsn_alc_spec_type_id, new.prsn_bac_test_rslt, new.prsn_death_timestamp, new.prsn_drg_rslt_id, new.prsn_drg_spec_type_id, new.prsn_ethnicity_id, new.prsn_exp_homelessness, new.prsn_first_name, new.prsn_gndr_id, new.prsn_helmet_id, new.prsn_injry_sev_id, new.prsn_last_name, new.prsn_mid_name, new.prsn_name_sfx, new.prsn_nbr, new.prsn_occpnt_pos_id, new.prsn_rest_id, new.prsn_taken_by, new.prsn_taken_to, new.prsn_type_id, new.unit_id, new.created_by, new.updated_by
    );
    -- insert new (editable) vz record (only record ID)
    INSERT INTO public.people_edits (id) values (new.id);

    RETURN NULL;
END;
$$;


create or replace trigger insert_new_people_cris
after insert on public.people_cris
for each row
execute procedure public.people_cris_insert_rows();

