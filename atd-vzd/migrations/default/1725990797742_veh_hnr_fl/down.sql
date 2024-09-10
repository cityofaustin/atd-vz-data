-- restore to version 1715960011005_cris_insert_triggers
CREATE OR REPLACE FUNCTION public.units_cris_insert_rows()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    -- insert new combined / official record
    INSERT INTO public.units (
        autonomous_unit_id,
        contrib_factr_1_id,
        contrib_factr_2_id,
        contrib_factr_3_id,
        contrib_factr_p1_id,
        contrib_factr_p2_id,
        crash_pk,
        created_by,
        cris_crash_id,
        e_scooter_id,
        first_harm_evt_inv_id,
        id,
        is_deleted,
        pbcat_pedalcyclist_id,
        pbcat_pedestrian_id,
        pedalcyclist_action_id,
        pedestrian_action_id,
        rpt_autonomous_level_engaged_id,
        unit_desc_id,
        unit_nbr,
        updated_by,
        veh_body_styl_id,
        veh_damage_description1_id,
        veh_damage_description2_id,
        veh_damage_direction_of_force1_id,
        veh_damage_direction_of_force2_id,
        veh_damage_severity1_id,
        veh_damage_severity2_id,
        veh_make_id,
        veh_mod_id,
        veh_mod_year,
        veh_trvl_dir_id,
        vin
    ) values (
        new.autonomous_unit_id,
        new.contrib_factr_1_id,
        new.contrib_factr_2_id,
        new.contrib_factr_3_id,
        new.contrib_factr_p1_id,
        new.contrib_factr_p2_id,
        new.crash_pk,
        new.created_by,
        new.cris_crash_id,
        new.e_scooter_id,
        new.first_harm_evt_inv_id,
        new.id,
        new.is_deleted,
        new.pbcat_pedalcyclist_id,
        new.pbcat_pedestrian_id,
        new.pedalcyclist_action_id,
        new.pedestrian_action_id,
        new.rpt_autonomous_level_engaged_id,
        new.unit_desc_id,
        new.unit_nbr,
        new.updated_by,
        new.veh_body_styl_id,
        new.veh_damage_description1_id,
        new.veh_damage_description2_id,
        new.veh_damage_direction_of_force1_id,
        new.veh_damage_direction_of_force2_id,
        new.veh_damage_severity1_id,
        new.veh_damage_severity2_id,
        new.veh_make_id,
        new.veh_mod_id,
        new.veh_mod_year,
        new.veh_trvl_dir_id,
        new.vin
    );
    -- insert new (editable) vz record (only record ID)
    INSERT INTO public.units_edits (id) values (new.id);

    RETURN NULL;
END;
$function$;

delete from _column_metadata
where
    column_name = 'veh_hnr_fl'
    and record_type = 'units';

alter table units_cris drop column veh_hnr_fl;
alter table units_edits drop column veh_hnr_fl;
alter table units drop column veh_hnr_fl;
