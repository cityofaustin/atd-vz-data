create table public.change_log_crashes_edits (
    id serial primary key,
    record_id integer not null references public.crashes_edits (id) on delete cascade on update cascade,
    operation_type text not null,
    record_json jsonb not null,
    created_at timestamp with time zone default now(),
    created_by text not null
);

create index on public.change_log_crashes_edits (record_id);

create table public.crashes_edits (
    id integer primary key references public.crashes_cris (id) on update cascade on delete cascade,
    active_school_zone_fl boolean,
    at_intrsct_fl boolean,
    case_id text,
    cr3_processed_at timestamp with time zone,
    cr3_stored_fl boolean,
    crash_speed_limit integer,
    crash_timestamp timestamp with time zone,
    created_at timestamptz not null default now(),
    created_by text not null default 'system',
    cris_crash_id integer unique,
    fhe_collsn_id integer references lookups.collsn (id) on update cascade on delete cascade,
    intrsct_relat_id integer references lookups.intrsct_relat (id) on update cascade on delete cascade,
    investigat_agency_id integer references lookups.agency (id) on update cascade on delete cascade,
    investigator_narrative text,
    is_deleted boolean,
    is_temp_record boolean,
    latitude numeric,
    law_enforcement_ytd_fatality_num text,
    light_cond_id integer references lookups.light_cond (id) on update cascade on delete cascade,
    longitude numeric,
    medical_advisory_fl boolean,
    obj_struck_id integer references lookups.obj_struck (id) on update cascade on delete cascade,
    onsys_fl boolean,
    private_dr_fl boolean,
    road_constr_zone_fl boolean,
    road_constr_zone_wrkr_fl boolean,
    rpt_block_num text,
    rpt_city_id integer references lookups.city (id) on update cascade on delete cascade,
    rpt_cris_cnty_id integer references lookups.cnty (id) on update cascade on delete cascade,
    rpt_hwy_num text,
    rpt_hwy_sfx text,
    rpt_rdwy_sys_id integer references lookups.rwy_sys (id) on update cascade on delete cascade,
    rpt_ref_mark_dir text,
    rpt_ref_mark_dist_uom text,
    rpt_ref_mark_nbr text,
    rpt_ref_mark_offset_amt numeric,
    rpt_road_part_id integer references lookups.road_part (id) on update cascade on delete cascade,
    rpt_sec_block_num text,
    rpt_sec_hwy_num text,
    rpt_sec_hwy_sfx text,
    rpt_sec_rdwy_sys_id integer references lookups.rwy_sys (id) on update cascade on delete cascade,
    rpt_sec_road_part_id integer references lookups.road_part (id) on update cascade on delete cascade,
    rpt_sec_street_desc text,
    rpt_sec_street_name text,
    rpt_sec_street_pfx text,
    rpt_sec_street_sfx text,
    rpt_street_desc text,
    rpt_street_name text,
    rpt_street_pfx text,
    rpt_street_sfx text,
    rr_relat_fl boolean,
    schl_bus_fl boolean,
    surf_cond_id integer references lookups.surf_cond (id) on update cascade on delete cascade,
    surf_type_id integer references lookups.surf_type (id) on update cascade on delete cascade,
    thousand_damage_fl boolean,
    toll_road_fl boolean,
    traffic_cntl_id integer references lookups.traffic_cntl (id) on update cascade on delete cascade,
    txdot_rptable_fl boolean,
    updated_at timestamptz not null default now(),
    updated_by text not null default 'system',
    wthr_cond_id integer references lookups.wthr_cond (id) on update cascade on delete cascade
);
