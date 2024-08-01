create table public.people_cris (
    id serial primary key,
    cris_crash_id integer references public.crashes_cris (cris_crash_id) on delete cascade on update cascade,
    cris_schema_version text not null,
    drvr_city_name text,
    drvr_drg_cat_1_id integer references lookups.substnc_cat_lkp (id) on update cascade on delete cascade,
    drvr_zip text,
    is_deleted boolean not null default false,
    is_primary_person boolean,
    prsn_age integer,
    prsn_alc_rslt_id integer references lookups.substnc_tst_result_lkp (id) on update cascade on delete cascade,
    prsn_alc_spec_type_id integer references lookups.specimen_type_lkp (id) on update cascade on delete cascade,
    prsn_bac_test_rslt text,
    prsn_death_timestamp timestamptz,
    prsn_drg_rslt_id integer references lookups.substnc_tst_result_lkp (id) on update cascade on delete cascade,
    prsn_drg_spec_type_id integer references lookups.specimen_type_lkp (id) on update cascade on delete cascade,
    prsn_ethnicity_id integer references lookups.drvr_ethncty_lkp (id) on update cascade on delete cascade,
    prsn_exp_homelessness boolean not null default false,
    prsn_first_name text,
    prsn_gndr_id integer references lookups.gndr_lkp (id) on update cascade on delete cascade,
    prsn_helmet_id integer references lookups.helmet_lkp (id) on update cascade on delete cascade,
    prsn_injry_sev_id integer references lookups.injry_sev_lkp (id) on update cascade on delete cascade,
    prsn_last_name text,
    prsn_mid_name text,
    prsn_name_sfx text,
    prsn_nbr integer,
    prsn_occpnt_pos_id integer references lookups.occpnt_pos_lkp (id) on update cascade on delete cascade,
    prsn_rest_id integer references lookups.rest_lkp (id) on update cascade on delete cascade,
    prsn_taken_by text,
    prsn_taken_to text,
    prsn_type_id integer references lookups.prsn_type_lkp (id) on update cascade on delete cascade,
    unit_id integer not null references public.units_cris (id) on update cascade on delete cascade,
    unit_nbr integer
);

create table public.people_edits (
    id integer primary key references public.people_cris (id) on update cascade on delete cascade,
    drvr_city_name text,
    drvr_drg_cat_1_id integer references lookups.substnc_cat_lkp (id) on update cascade on delete cascade,
    drvr_zip text,
    ems_id integer references public.ems__incidents (id) on update cascade on delete set null,
    is_deleted boolean,
    is_primary_person boolean,
    prsn_age integer,
    prsn_alc_rslt_id integer references lookups.substnc_tst_result_lkp (id) on update cascade on delete cascade,
    prsn_alc_spec_type_id integer references lookups.specimen_type_lkp (id) on update cascade on delete cascade,
    prsn_bac_test_rslt text,
    prsn_death_timestamp timestamptz,
    prsn_drg_rslt_id integer references lookups.substnc_tst_result_lkp (id) on update cascade on delete cascade,
    prsn_drg_spec_type_id integer references lookups.specimen_type_lkp (id) on update cascade on delete cascade,
    prsn_ethnicity_id integer references lookups.drvr_ethncty_lkp (id) on update cascade on delete cascade,
    prsn_exp_homelessness boolean,
    prsn_first_name text,
    prsn_gndr_id integer references lookups.gndr_lkp (id) on update cascade on delete cascade,
    prsn_helmet_id integer references lookups.helmet_lkp (id) on update cascade on delete cascade,
    prsn_injry_sev_id integer references lookups.injry_sev_lkp (id) on update cascade on delete cascade,
    prsn_last_name text,
    prsn_mid_name text,
    prsn_name_sfx text,
    prsn_nbr integer,
    prsn_occpnt_pos_id integer references lookups.occpnt_pos_lkp (id) on update cascade on delete cascade,
    prsn_rest_id integer references lookups.rest_lkp (id) on update cascade on delete cascade,
    prsn_taken_by text,
    prsn_taken_to text,
    prsn_type_id integer references lookups.prsn_type_lkp (id) on update cascade on delete cascade,
    unit_id integer references public.units_cris (id) on update cascade on delete cascade
);

create table public.people (
    id integer primary key,
    drvr_city_name text,
    drvr_drg_cat_1_id integer references lookups.substnc_cat_lkp (id) on update cascade on delete cascade,
    drvr_zip text,
    ems_id integer references public.ems__incidents (id) on update cascade on delete set null,
    est_comp_cost_crash_based integer generated always as (case when (prsn_injry_sev_id = 1) then 250000 when (prsn_injry_sev_id = 2) then 3000000 when (prsn_injry_sev_id = 3) then 200000 when (prsn_injry_sev_id = 4) then 3500000 else 20000 end) stored,
    is_deleted boolean not null default false,
    is_primary_person boolean,
    prsn_age integer,
    prsn_alc_rslt_id integer references lookups.substnc_tst_result_lkp (id) on update cascade on delete cascade,
    prsn_alc_spec_type_id integer references lookups.specimen_type_lkp (id) on update cascade on delete cascade,
    prsn_bac_test_rslt text,
    prsn_death_timestamp timestamptz,
    prsn_drg_rslt_id integer references lookups.substnc_tst_result_lkp (id) on update cascade on delete cascade,
    prsn_drg_spec_type_id integer references lookups.specimen_type_lkp (id) on update cascade on delete cascade,
    prsn_ethnicity_id integer references lookups.drvr_ethncty_lkp (id) on update cascade on delete cascade,
    prsn_exp_homelessness boolean not null default false,
    prsn_first_name text,
    prsn_gndr_id integer references lookups.gndr_lkp (id) on update cascade on delete cascade,
    prsn_helmet_id integer references lookups.helmet_lkp (id) on update cascade on delete cascade,
    prsn_injry_sev_id integer references lookups.injry_sev_lkp (id) on update cascade on delete cascade,
    prsn_last_name text,
    prsn_mid_name text,
    prsn_name_sfx text,
    prsn_nbr integer,
    prsn_occpnt_pos_id integer references lookups.occpnt_pos_lkp (id) on update cascade on delete cascade,
    prsn_rest_id integer references lookups.rest_lkp (id) on update cascade on delete cascade,
    prsn_taken_by text,
    prsn_taken_to text,
    prsn_type_id integer references lookups.prsn_type_lkp (id) on update cascade on delete cascade,
    unit_id integer not null references public.units (id) on update cascade on delete cascade,
    years_of_life_lost integer generated always as (case when prsn_injry_sev_id = 4 then greatest(75 - prsn_age, 0) else 0 end) stored
);
