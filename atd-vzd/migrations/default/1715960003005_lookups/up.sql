create table lookups.agency (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.autonomous_level_engaged (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.autonomous_unit (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.city (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.cnty (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.collsn (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.contrib_factr (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.drvr_ethncty (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.e_scooter (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.gndr (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.harm_evnt (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.helmet (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.injry_sev (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.intrsct_relat (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.light_cond (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.mode_category (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.movt (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.obj_struck (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.occpnt_pos (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.pbcat_pedalcyclist (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.pbcat_pedestrian (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.pedalcyclist_action (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.pedestrian_action (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.prsn_type (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.rest (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.road_part (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.rwy_sys (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.specimen_type (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.substnc_cat (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.substnc_tst_result (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.surf_cond (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.surf_type (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.traffic_cntl (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.trvl_dir (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.unit_desc (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.veh_body_styl (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.veh_damage_description (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.veh_damage_severity (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.veh_direction_of_force (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.veh_make (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.veh_mod (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);

create table lookups.wthr_cond (
    id integer primary key,
    label text not null,
    source text not null default 'cris'
);
