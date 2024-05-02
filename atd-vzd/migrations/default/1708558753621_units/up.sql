create table db.units_cris (
    id serial primary key,
    autonomous_unit_id integer references lookups.autonomous_unit_lkp (id) on update cascade on delete cascade,
    contrib_factr_1_id integer references lookups.contrib_factr_lkp (id) on update cascade on delete cascade,
    contrib_factr_2_id integer references lookups.contrib_factr_lkp (id) on update cascade on delete cascade,
    contrib_factr_3_id integer references lookups.contrib_factr_lkp (id) on update cascade on delete cascade,
    contrib_factr_p1_id integer references lookups.contrib_factr_lkp (id) on update cascade on delete cascade,
    contrib_factr_p2_id integer references lookups.contrib_factr_lkp (id) on update cascade on delete cascade,
    crash_id integer not null references db.crashes_cris (crash_id) on update cascade on delete cascade,
    e_scooter_id integer references lookups.e_scooter_lkp (id) on update cascade on delete cascade,
    first_harm_evt_inv_id integer references lookups.harm_evnt_lkp (id) on update cascade on delete cascade,
    pbcat_pedalcyclist_id integer references lookups.pbcat_pedalcyclist_lkp (id) on update cascade on delete cascade,
    pbcat_pedestrian_id integer references lookups.pbcat_pedestrian_lkp (id) on update cascade on delete cascade,
    pedalcyclist_action_id integer references lookups.pedalcyclist_action_lkp (id) on update cascade on delete cascade,
    pedestrian_action_id integer references lookups.pedestrian_action_lkp (id) on update cascade on delete cascade,
    rpt_autonomous_level_engaged_id integer references lookups.autonomous_level_engaged_lkp (id) on update cascade on delete cascade,
    unit_desc_id integer references lookups.unit_desc_lkp (id) on update cascade on delete cascade,
    unit_nbr integer,
    veh_body_styl_id integer references lookups.veh_body_styl_lkp (id) on update cascade on delete cascade,
    veh_damage_description1_id integer references lookups.veh_damage_description_lkp (id) on update cascade on delete cascade,
    veh_damage_description2_id integer references lookups.veh_damage_description_lkp (id) on update cascade on delete cascade,
    veh_damage_direction_of_force1_id integer references lookups.veh_direction_of_force_lkp (id) on update cascade on delete cascade,
    veh_damage_direction_of_force2_id integer references lookups.veh_direction_of_force_lkp (id) on update cascade on delete cascade,
    veh_damage_severity1_id integer references lookups.veh_damage_severity_lkp (id) on update cascade on delete cascade,
    veh_damage_severity2_id integer references lookups.veh_damage_severity_lkp (id) on update cascade on delete cascade,
    veh_make_id integer references lookups.veh_make_lkp (id) on update cascade on delete cascade,
    veh_mod_id integer references lookups.veh_mod_lkp (id) on update cascade on delete cascade,
    veh_mod_year integer,
    veh_trvl_dir_id integer references lookups.trvl_dir_lkp (id) on update cascade on delete cascade,
    vin text
);

create table db.units_edits (
    id integer primary key references db.units_cris (id) on update cascade on delete cascade,
    atd_mode_category integer references lookups.mode_category_lkp (id) on update cascade on delete cascade,
    autonomous_unit_id integer references lookups.autonomous_unit_lkp (id) on update cascade on delete cascade,
    contrib_factr_1_id integer references lookups.contrib_factr_lkp (id) on update cascade on delete cascade,
    contrib_factr_2_id integer references lookups.contrib_factr_lkp (id) on update cascade on delete cascade,
    contrib_factr_3_id integer references lookups.contrib_factr_lkp (id) on update cascade on delete cascade,
    contrib_factr_p1_id integer references lookups.contrib_factr_lkp (id) on update cascade on delete cascade,
    contrib_factr_p2_id integer references lookups.contrib_factr_lkp (id) on update cascade on delete cascade,
    crash_id integer references db.crashes_cris (crash_id) on update cascade on delete cascade,
    e_scooter_id integer references lookups.e_scooter_lkp (id) on update cascade on delete cascade,
    first_harm_evt_inv_id integer references lookups.harm_evnt_lkp (id) on update cascade on delete cascade,
    movement_id integer references lookups.movt_lkp (id) on update cascade on delete cascade,
    pbcat_pedalcyclist_id integer references lookups.pbcat_pedalcyclist_lkp (id) on update cascade on delete cascade,
    pbcat_pedestrian_id integer references lookups.pbcat_pedestrian_lkp (id) on update cascade on delete cascade,
    pedalcyclist_action_id integer references lookups.pedalcyclist_action_lkp (id) on update cascade on delete cascade,
    pedestrian_action_id integer references lookups.pedestrian_action_lkp (id) on update cascade on delete cascade,
    rpt_autonomous_level_engaged_id integer references lookups.autonomous_level_engaged_lkp (id) on update cascade on delete cascade,
    unit_desc_id integer references lookups.unit_desc_lkp (id) on update cascade on delete cascade,
    unit_nbr integer,
    veh_body_styl_id integer references lookups.veh_body_styl_lkp (id) on update cascade on delete cascade,
    veh_damage_description1_id integer references lookups.veh_damage_description_lkp (id) on update cascade on delete cascade,
    veh_damage_description2_id integer references lookups.veh_damage_description_lkp (id) on update cascade on delete cascade,
    veh_damage_direction_of_force1_id integer references lookups.veh_direction_of_force_lkp (id) on update cascade on delete cascade,
    veh_damage_direction_of_force2_id integer references lookups.veh_direction_of_force_lkp (id) on update cascade on delete cascade,
    veh_damage_severity1_id integer references lookups.veh_damage_severity_lkp (id) on update cascade on delete cascade,
    veh_damage_severity2_id integer references lookups.veh_damage_severity_lkp (id) on update cascade on delete cascade,
    veh_make_id integer references lookups.veh_make_lkp (id) on update cascade on delete cascade,
    veh_mod_id integer references lookups.veh_mod_lkp (id) on update cascade on delete cascade,
    veh_mod_year integer,
    veh_trvl_dir_id integer references lookups.trvl_dir_lkp (id) on update cascade on delete cascade,
    vin text
);

create table db.units_unified (
    id integer primary key,
    atd_mode_category integer references lookups.mode_category_lkp (id) on update cascade on delete cascade,
    autonomous_unit_id integer references lookups.autonomous_unit_lkp (id) on update cascade on delete cascade,
    contrib_factr_1_id integer references lookups.contrib_factr_lkp (id) on update cascade on delete cascade,
    contrib_factr_2_id integer references lookups.contrib_factr_lkp (id) on update cascade on delete cascade,
    contrib_factr_3_id integer references lookups.contrib_factr_lkp (id) on update cascade on delete cascade,
    contrib_factr_p1_id integer references lookups.contrib_factr_lkp (id) on update cascade on delete cascade,
    contrib_factr_p2_id integer references lookups.contrib_factr_lkp (id) on update cascade on delete cascade,
    crash_id integer not null references db.crashes_unified (crash_id) on update cascade on delete cascade,
    e_scooter_id integer references lookups.e_scooter_lkp (id) on update cascade on delete cascade,
    first_harm_evt_inv_id integer references lookups.harm_evnt_lkp (id) on update cascade on delete cascade,
    movement_id integer references lookups.movt_lkp (id) on update cascade on delete cascade,
    pbcat_pedalcyclist_id integer references lookups.pbcat_pedalcyclist_lkp (id) on update cascade on delete cascade,
    pbcat_pedestrian_id integer references lookups.pbcat_pedestrian_lkp (id) on update cascade on delete cascade,
    pedalcyclist_action_id integer references lookups.pedalcyclist_action_lkp (id) on update cascade on delete cascade,
    pedestrian_action_id integer references lookups.pedestrian_action_lkp (id) on update cascade on delete cascade,
    rpt_autonomous_level_engaged_id integer references lookups.autonomous_level_engaged_lkp (id) on update cascade on delete cascade,
    unit_desc_id integer references lookups.unit_desc_lkp (id) on update cascade on delete cascade,
    unit_nbr integer,
    veh_body_styl_id integer references lookups.veh_body_styl_lkp (id) on update cascade on delete cascade,
    veh_damage_description1_id integer references lookups.veh_damage_description_lkp (id) on update cascade on delete cascade,
    veh_damage_description2_id integer references lookups.veh_damage_description_lkp (id) on update cascade on delete cascade,
    veh_damage_direction_of_force1_id integer references lookups.veh_direction_of_force_lkp (id) on update cascade on delete cascade,
    veh_damage_direction_of_force2_id integer references lookups.veh_direction_of_force_lkp (id) on update cascade on delete cascade,
    veh_damage_severity1_id integer references lookups.veh_damage_severity_lkp (id) on update cascade on delete cascade,
    veh_damage_severity2_id integer references lookups.veh_damage_severity_lkp (id) on update cascade on delete cascade,
    veh_make_id integer references lookups.veh_make_lkp (id) on update cascade on delete cascade,
    veh_mod_id integer references lookups.veh_mod_lkp (id) on update cascade on delete cascade,
    veh_mod_year integer,
    veh_trvl_dir_id integer references lookups.trvl_dir_lkp (id) on update cascade on delete cascade,
    vin text
);