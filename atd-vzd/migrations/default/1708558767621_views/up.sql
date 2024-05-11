create or replace view crashes_list as with injury_severities as (
    select
        id,
        unit_id,
        est_comp_cost_crash_based,
        case
            when (prsn_injry_sev_id = 9) then 1
            else 0
        end as unkn_injry,
        case
            when (prsn_injry_sev_id = 1) then 1
            else 0
        end as sus_serious_injry,
        case
            when (prsn_injry_sev_id = 2) then 1
            else 0
        end as nonincap_injry,
        case
            when (prsn_injry_sev_id = 3) then 1
            else 0
        end as poss_injry,
        case
            when (prsn_injry_sev_id = 4) then 1
            else 0
        end as fatal_injury,
        case
            when (prsn_injry_sev_id = 5) then 1
            else 0
        end as non_injry
    from
        public.people
),

cris_fatal_injury_counts as (
    select
        crashes.crash_id,
        count(crashes.crash_id) as cris_fatality_cnt
    from public.crashes_cris as crashes
    left join public.units_cris as units on crashes.crash_id = units.crash_id
    left join public.people_cris as people on units.id = people.unit_id
    where people.prsn_injry_sev_id = 4
    group by crashes.crash_id
),

injury_counts as (
    select
        crashes.crash_id,
        sum(injury_severities.unkn_injry) as unkn_injry_cnt,
        sum(
            injury_severities.nonincap_injry
        ) as nonincap_injry_cnt,
        sum(injury_severities.poss_injry) as poss_injry_cnt,
        sum(injury_severities.non_injry) as non_injry_cnt,
        sum(injury_severities.sus_serious_injry) as sus_serious_injry_cnt,
        sum(injury_severities.fatal_injury) as atd_fatality_cnt,
        sum(est_comp_cost_crash_based) as est_comp_cost_crash_based
    from
        public.crashes as crashes
    left join public.units as units on crashes.crash_id = units.crash_id
    left join injury_severities on units.id = injury_severities.unit_id
    group by
        crashes.crash_id
),

geocode_sources as (
    select
        cris.crash_id,
        coalesce(
            (cris.latitude is null or cris.longitude is null),
            false
        ) as has_no_cris_coordinates,
        case
            when
                (edits.latitude is not null or edits.longitude is not null)
                then 'manual_qa'
            else 'cris'
        end as geocode_source
    from public.crashes_cris as cris
    left join public.crashes_edits as edits on cris.crash_id = edits.crash_id
)

select
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
    injury_counts.nonincap_injry_cnt,
    injury_counts.poss_injry_cnt,
    injury_counts.sus_serious_injry_cnt,
    injury_counts.non_injry_cnt,
    injury_counts.atd_fatality_cnt,
    injury_counts.unkn_injry_cnt,
    injury_counts.est_comp_cost_crash_based,
    lookups.collsn_lkp.label as collsn_desc,
    geocode_sources.geocode_source,
    geocode_sources.has_no_cris_coordinates,
    case
        when (cris_fatal_injury_counts.cris_fatality_cnt is null) then 0
        else cris_fatal_injury_counts.cris_fatality_cnt
    end as cris_fatality_cnt,
    case
        when (law_enforcement_fatality_num is not null)
            then cris_fatality_cnt
        else 0
    end as apd_fatality_cnt,
    upper(
        to_char(public.crashes.crash_date at time zone 'US/Central', 'dy')
    ) as crash_day_of_week
from
    public.crashes
left join
    injury_counts
    on public.crashes.crash_id = injury_counts.crash_id
left join
    cris_fatal_injury_counts
    on public.crashes.crash_id = cris_fatal_injury_counts.crash_id
left join
    geocode_sources
    on public.crashes.crash_id = geocode_sources.crash_id
left join
    lookups.collsn_lkp
    on public.crashes.fhe_collsn_id = lookups.collsn_lkp.id;

