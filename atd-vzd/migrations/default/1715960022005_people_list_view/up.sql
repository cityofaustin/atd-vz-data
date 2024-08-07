drop view if exists people_list_view cascade;

create or replace view people_list_view as (
    select
        people.*,
        crashes.id as crash_pk,
        crashes.cris_crash_id,
        crashes.crash_timestamp,
        injry_sev_lkp.label as prsn_injry_sev_desc,
        units.unit_nbr,
        units.unit_desc_id,
        mode_category_lkp.label as mode_desc
    from public.people
    left join public.units as units on people.unit_id = units.id
    left join public.people_cris as people_cris on people.id = people_cris.id
    left join
        public.crashes as crashes
        on units.crash_pk = crashes.id
    left join
        lookups.injry_sev_lkp
        on lookups.injry_sev_lkp.id = people.prsn_injry_sev_id
    left join
        lookups.mode_category_lkp
        on units.vz_mode_category_id = lookups.mode_category_lkp.id
);

