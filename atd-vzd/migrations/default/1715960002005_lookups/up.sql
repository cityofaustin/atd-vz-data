create table lookups.agency_lkp (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.autonomous_level_engaged_lkp (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.autonomous_unit_lkp (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.charge_cat_lkp (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.city_lkp (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.cnty_lkp (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.collsn_lkp (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.contrib_factr_lkp (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.drvr_ethncty_lkp (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.e_scooter_lkp (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.gndr_lkp (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.harm_evnt_lkp (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.helmet_lkp (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.injry_sev_lkp (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.intrsct_relat_lkp (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.light_cond_lkp (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.mode_category_lkp (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.movt_lkp (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.obj_struck_lkp (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.occpnt_pos_lkp (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.pbcat_pedalcyclist_lkp (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.pbcat_pedestrian_lkp (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.pedalcyclist_action_lkp (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.pedestrian_action_lkp (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.prsn_type_lkp (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.rest_lkp (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.road_part_lkp (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.rwy_sys_lkp (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.specimen_type_lkp (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.substnc_cat_lkp (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.substnc_tst_result_lkp (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.surf_cond_lkp (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.surf_type_lkp (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.traffic_cntl_lkp (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.trvl_dir_lkp (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.unit_desc_lkp (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.veh_body_styl_lkp (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.veh_damage_description_lkp (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.veh_damage_severity_lkp (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.veh_direction_of_force_lkp (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.veh_make_lkp (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.veh_mod_lkp (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.wthr_cond_lkp (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);
