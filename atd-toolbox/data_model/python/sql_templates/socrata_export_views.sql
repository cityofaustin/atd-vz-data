create or replace view socrata_export_crashes_view as with
unit_aggregates as (
    select
        crashes.id as id,
        string_agg(distinct mode_categories.label, ' & ') as units_involved,
        array_agg(
            json_build_object(
                'unit_id',
                units.id,
                'mode_id',
                units.vz_mode_category_id,
                'mode_desc',
                mode_categories.label,
                'nonincap_injry_cnt',
                uiv.nonincap_injry_count,
                'sus_serious_injry_cnt',
                uiv.sus_serious_injry_count,
                'vz_fatality_count',
                uiv.vz_fatality_count,
                'poss_injry_cnt',
                poss_injry_count,
                'non_injry_cnt',
                non_injry_count,
                'unkn_injry_cnt',
                unkn_injry_count
            )
        ) as atd_mode_category_metadata
    from crashes
    left join units
        on crashes.id = units.crash_id
    left join
        unit_injury_metrics_view
        as uiv on crashes.id = uiv.crash_id
    left join
        lookups.mode_category_lkp as mode_categories
        on units.vz_mode_category_id = mode_categories.id
    group by crashes.id
)

select
    crashes.crash_id,
    crashes.case_id,
    crashes.address_primary,
    crashes.address_secondary,
    crashes.latitude,
    crashes.longitude,
    crashes.rpt_block_num,
    crashes.rpt_street_name,
    crashes.rpt_street_sfx,
    crashes.crash_speed_limit,
    crashes.road_constr_zone_fl,
    cimv.crash_injry_sev_id as crash_sev_id,
    cimv.sus_serious_injry_count as sus_serious_injry_cnt,
    cimv.nonincap_injry_count as nonincap_injry_cnt,
    cimv.poss_injry_count as poss_injry_cnt,
    cimv.non_injry_count as non_injry_cnt,
    cimv.unkn_injry_count as unkn_injry_cnt,
    cimv.law_enf_fatality_count,
    cimv.fatality_count as death_cnt,
    cimv.vz_fatality_count,
    crashes.onsys_fl,
    -- tot_injry_count, ## not sure this is used anywhere
    -- motor_vehicle_fl, ## i don't like these mode flags and i don't think they're used anywhere
    crashes.private_dr_fl,
    unit_aggregates.units_involved, -- new field / need to address naming inconsistencies wrt to fatality_count, vz_fatality_count, death_count. i think we should use vz_fatality_count in the public dataset
    unit_aggregates.atd_mode_category_metadata,  -- i don't like this! we should use a separate units dataset. note that death_count was renamed to vz_death_count
    cimv.motor_vehicle_fatality_count as motor_vehicle_death_count,
    cimv.motor_vehicle_sus_serious_injry_count as motor_vehicle_serious_injury_count,
    cimv.bicycle_fatality_count as bicycle_death_count,
    cimv.bicycle_sus_serious_injry_count as bicycle_serious_injury_count,
    cimv.pedestrian_fatality_count as pedestrian_death_count,
    cimv.pedestrian_sus_serious_injry_count as pedestrian_serious_injury_count,
    cimv.motorcycle_fatality_count as motorcycle_death_count,
    cimv.motorcycle_sus_serious_count as motorcycle_serious_injury_count,
    cimv.micromobility_fatality_count as micromobility_death_count,
    cimv.micromobility_sus_serious_injry_count as micromobility_serious_injury_count,
    cimv.other_fatality_count as other_death_count,
    cimv.other_sus_serious_injry_count as other_serious_injury_count,
    to_char(
        crashes.crash_timestamp, 'YYYY-MM-DD"T"HH24:MI:SS'
    ) as crash_timestamp,
    to_char(
        crashes.crash_timestamp at time zone 'US/Central',
        'YYYY-MM-DD"T"HH24:MI:SS'
    ) as crash_timestamp_ct,
    case
        when
            crashes.latitude is not null and crashes.longitude is not null
            then
                'POINT ('
                || crashes.longitude::text
                || ' '
                || crashes.latitude::text
                || ')'
    end as point,
    coalesce(cimv.crash_injry_sev_id = 4, false) as crash_fatal_fl
from crashes
left join lateral (
    select *
    from
        public.crash_injury_metrics_view
    where
        crashes.id = id
    limit 1
) as cimv on true
left join lateral (
    select *
    from
        unit_aggregates
    where
        crashes.id = unit_aggregates.id
    limit 1
) as unit_aggregates on true
where
    crashes.in_austin_full_purpose = true and crashes.private_dr_fl = false
    and crashes.crash_timestamp < now() - interval '14 days';


create or replace view socrata_export_people_view as (
    select
        people.id as person_id,
        people.unit_id as unit_id, --new column
        clv.crash_id,
        people.is_primary_person, --new column
        people.prsn_age,
        people.prsn_gndr_id as prsn_sex_id, --rename from prsn_gndr_id
        lookups.gndr_lkp.label as prsn_sex_label, -- new column
        people.prsn_ethnicity_id,
        lookups.drvr_ethncty_lkp.label as prsn_ethnicity_label, --new column
        people.prsn_injry_sev_id,
        units.vz_mode_category_id as mode_id,
        mode_categories.label as mode_desc,
        to_char(
            clv.crash_timestamp, 'YYYY-MM-DD"T"HH24:MI:SS'
        ) as crash_timestamp,
        to_char(
            clv.crash_timestamp at time zone 'US/Central',
            'YYYY-MM-DD"T"HH24:MI:SS'
        ) as crash_timestamp_ct
    from people
    left join public.units as units on people.unit_id = units.id
    left join public.crashes_list_view as clv on units.crash_id = clv.id
    left join
        lookups.mode_category_lkp as mode_categories
        on units.vz_mode_category_id = mode_categories.id
    left join
        lookups.drvr_ethncty_lkp
        on people.prsn_ethnicity_id = lookups.drvr_ethncty_lkp.id
    left join
        lookups.gndr_lkp
        on people.prsn_gndr_id = lookups.gndr_lkp.id
    where
        clv.in_austin_full_purpose = true and clv.private_dr_fl = false
        and clv.crash_timestamp < now() - interval '14 days'
);
