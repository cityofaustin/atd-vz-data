drop view if exists person_injury_metrics_view cascade;

create or replace view person_injury_metrics_view as (
    select
        people.id,
        units.id as unit_id,
        crashes.crash_id as cris_crash_id,
        people.years_of_life_lost,
        people.est_comp_cost_crash_based,
        case
            when (people.prsn_injry_sev_id = 0) then 1
            else 0
        end as unkn_injry,
        case
            when (people.prsn_injry_sev_id = 1) then 1
            else 0
        end as sus_serious_injry,
        case
            when (people.prsn_injry_sev_id = 2) then 1
            else 0
        end as nonincap_injry,
        case
            when (people.prsn_injry_sev_id = 3) then 1
            else 0
        end as poss_injry,
        case
            when
                (people.prsn_injry_sev_id = 4 or people.prsn_injry_sev_id = 99)
                then 1
            else 0
        end as fatal_injury,
        case
            when
                (
                    people.prsn_injry_sev_id = 4
                )
                then 1
            else 0
        end as vz_fatal_injury,
        case
            when
                (
                    (
                        people.prsn_injry_sev_id = 4
                        or people.prsn_injry_sev_id = 99
                    )
                    and crashes.law_enforcement_fatality_num is not null
                )
                then 1
            else 0
        end as law_enf_fatal_injury,
        case
            when (people_cris.prsn_injry_sev_id = 4) then 1
            else 0
        end as cris_fatal_injury,
        case
            when (people.prsn_injry_sev_id = 5) then 1
            else 0
        end as non_injry
    from
        public.people as people
    left join public.units as units on people.unit_id = units.id
    left join public.people_cris as people_cris on people.id = people_cris.id
    left join
        public.crashes as crashes
        on units.crash_id = crashes.id
);

create or replace view unit_injury_metrics_view as
(
    select
        units.id,
        coalesce(
            sum(person_injury_metrics_view.unkn_injry), 0
        ) as unkn_injry_count,
        coalesce(sum(
            person_injury_metrics_view.nonincap_injry
        ), 0) as nonincap_injry_count,
        coalesce(
            sum(person_injury_metrics_view.poss_injry), 0
        ) as poss_injry_count,
        coalesce(sum(person_injury_metrics_view.non_injry), 0) as non_injry_count,
        coalesce(
            sum(person_injury_metrics_view.sus_serious_injry), 0
        ) as sus_serious_injry_count,
        coalesce(
            sum(person_injury_metrics_view.fatal_injury), 0
        ) as fatality_count,
        coalesce(
            sum(person_injury_metrics_view.vz_fatal_injury), 0
        ) as vz_fatality_count,
        coalesce(sum(
            person_injury_metrics_view.law_enf_fatal_injury
        ), 0) as law_enf_fatality_count,
        coalesce(
            sum(person_injury_metrics_view.cris_fatal_injury), 0
        ) as cris_fatality_count,
        coalesce(
            sum(person_injury_metrics_view.years_of_life_lost), 0
        ) as years_of_life_lost
    from
        public.units
    left join
        person_injury_metrics_view
        on units.id = person_injury_metrics_view.unit_id
    group by
        units.id
);

create or replace view crash_injury_metrics_view as
(
    select
        crashes.crash_id,
        coalesce(
            sum(person_injury_metrics_view.unkn_injry), 0
        ) as unkn_injry_count,
        coalesce(sum(
            person_injury_metrics_view.nonincap_injry
        ), 0) as nonincap_injry_count,
        coalesce(
            sum(person_injury_metrics_view.poss_injry), 0
        ) as poss_injry_count,
        coalesce(sum(person_injury_metrics_view.non_injry), 0) as non_injry_count,
        coalesce(
            sum(person_injury_metrics_view.sus_serious_injry), 0
        ) as sus_serious_injry_count,
        coalesce(
            sum(person_injury_metrics_view.fatal_injury), 0
        ) as fatality_count,
        coalesce(
            sum(person_injury_metrics_view.vz_fatal_injury), 0
        ) as vz_fatality_count,
        coalesce(sum(
            person_injury_metrics_view.law_enf_fatal_injury
        ), 0) as law_enf_fatality_count,
        coalesce(
            sum(person_injury_metrics_view.cris_fatal_injury), 0
        ) as cris_fatality_count,
        case
            when (sum(person_injury_metrics_view.fatal_injury) > 0) then 4
            when (sum(person_injury_metrics_view.nonincap_injry) > 0) then 1
            when (sum(person_injury_metrics_view.sus_serious_injry) > 0) then 2
            when (sum(person_injury_metrics_view.poss_injry) > 0) then 3
            when (sum(person_injury_metrics_view.unkn_injry) > 0) then 0
            when (sum(person_injury_metrics_view.non_injry) > 0) then 5
            else 0
        end as crash_injry_sev_id,
        coalesce(
            sum(person_injury_metrics_view.years_of_life_lost), 0
        ) as years_of_life_lost,
        max(est_comp_cost_crash_based) as est_comp_cost_crash_based
    from
        public.crashes as crashes
    left join
        person_injury_metrics_view
        on crashes.crash_id = person_injury_metrics_view.cris_crash_id
    group by
        crashes.crash_id
);


create or replace view crashes_list_view as with geocode_status as (
    select
        cris.crash_id,
        coalesce(
            (cris.latitude is null or cris.longitude is null),
            false
        ) as has_no_cris_coordinates,
        coalesce(
            (edits.latitude is not null and edits.longitude is not null),
            false
        ) as is_manual_geocode
    from public.crashes_cris as cris
    left join public.crashes_edits as edits on cris.id = edits.id
)

select
    public.crashes.id,
    public.crashes.crash_id,
    public.crashes.case_id,
    public.crashes.crash_date,
    public.crashes.address_primary,
    public.crashes.address_secondary,
    public.crashes.private_dr_fl,
    public.crashes.in_austin_full_purpose,
    public.crashes.location_id,
    public.crashes.rpt_block_num,
    public.crashes.rpt_street_pfx,
    public.crashes.rpt_street_name,
    public.crashes.rpt_sec_block_num,
    public.crashes.rpt_sec_street_pfx,
    public.crashes.rpt_sec_street_name,
    public.crashes.latitude,
    public.crashes.longitude,
    public.crashes.light_cond_id,
    public.crashes.wthr_cond_id,
    public.crashes.active_school_zone_fl,
    public.crashes.schl_bus_fl,
    public.crashes.at_intrsct_fl,
    public.crashes.onsys_fl,
    public.crashes.traffic_cntl_id,
    public.crashes.road_constr_zone_fl,
    public.crashes.rr_relat_fl,
    public.crashes.toll_road_fl,
    public.crashes.intrsct_relat_id,
    public.crashes.obj_struck_id,
    public.crashes.crash_speed_limit,
    public.crashes.council_district,
    crash_injury_metrics_view.nonincap_injry_count,
    crash_injury_metrics_view.poss_injry_count,
    crash_injury_metrics_view.sus_serious_injry_count,
    crash_injury_metrics_view.non_injry_count,
    crash_injury_metrics_view.vz_fatality_count,
    crash_injury_metrics_view.cris_fatality_count,
    crash_injury_metrics_view.law_enf_fatality_count,
    crash_injury_metrics_view.fatality_count,
    crash_injury_metrics_view.unkn_injry_count,
    crash_injury_metrics_view.est_comp_cost_crash_based,
    crash_injury_metrics_view.crash_injry_sev_id,
    crash_injury_metrics_view.years_of_life_lost,
    lookups.injry_sev_lkp.label as crash_injry_sev_desc,
    lookups.collsn_lkp.label as collsn_desc,
    geocode_status.is_manual_geocode,
    geocode_status.has_no_cris_coordinates,
    upper(
        to_char(
            public.crashes.crash_date at time zone 'US/Central', 'dy'
        )
    ) as crash_day_of_week
from
    public.crashes
left join
    crash_injury_metrics_view
    on public.crashes.crash_id = crash_injury_metrics_view.crash_id
left join
    geocode_status
    on public.crashes.crash_id = geocode_status.crash_id
left join
    lookups.collsn_lkp
    on public.crashes.fhe_collsn_id = lookups.collsn_lkp.id
left join
    lookups.injry_sev_lkp
    on lookups.injry_sev_lkp.id = crash_injury_metrics_view.crash_injry_sev_id;
