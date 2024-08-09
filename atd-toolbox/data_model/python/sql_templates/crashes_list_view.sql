drop view if exists person_injury_metrics_view cascade;

create or replace view person_injury_metrics_view as (
    select
        people.id,
        units.id as unit_id,
        crashes.id as crash_pk,
        crashes.cris_crash_id,
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
                    and crashes.law_enforcement_ytd_fatality_num is not null
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
        end as non_injry,
        case
            when
                (
                    people.prsn_injry_sev_id = 4
                    and units.vz_mode_category_id in (1, 2, 4)
                )
                then 1
            else 0
        end as motor_vehicle_fatal_injry,
        case
            when
                (
                    people.prsn_injry_sev_id = 1
                    and units.vz_mode_category_id in (1, 2, 4)
                )
                then 1
            else 0
        end as motor_vehicle_sus_serious_injry,
        case
            when
                (
                    people.prsn_injry_sev_id = 4
                    and units.vz_mode_category_id = 3
                )
                then 1
            else 0
        end as motorcycle_fatal_injry,
        case
            when
                (
                    people.prsn_injry_sev_id = 1
                    and units.vz_mode_category_id = 3
                )
                then 1
            else 0
        end as motorycle_sus_serious_injry,
        case
            when
                (
                    people.prsn_injry_sev_id = 4
                    and units.vz_mode_category_id = 5
                )
                then 1
            else 0
        end as bicycle_fatal_injry,
        case
            when
                (
                    people.prsn_injry_sev_id = 1
                    and units.vz_mode_category_id = 5
                )
                then 1
            else 0
        end as bicycle_sus_serious_injry,
        case
            when
                (
                    people.prsn_injry_sev_id = 4
                    and units.vz_mode_category_id = 7
                )
                then 1
            else 0
        end as pedestrian_fatal_injry,
        case
            when
                (
                    people.prsn_injry_sev_id = 1
                    and units.vz_mode_category_id = 7
                )
                then 1
            else 0
        end as pedestrian_sus_serious_injry,
        case
            when
                (
                    people.prsn_injry_sev_id = 4
                    and units.vz_mode_category_id = 11
                )
                then 1
            else 0
        end as micromobility_fatal_injry,
        case
            when
                (
                    people.prsn_injry_sev_id = 1
                    and units.vz_mode_category_id = 11
                )
                then 1
            else 0
        end as micromobility_sus_serious_injry,
        case
            when
                (
                    people.prsn_injry_sev_id = 4
                    and units.vz_mode_category_id in (6, 8, 9)
                )
                then 1
            else 0
        end as other_fatal_injry,
        case
            when
                (
                    people.prsn_injry_sev_id = 1
                    and units.vz_mode_category_id in (6, 8, 9)
                )
                then 1
            else 0
        end as other_sus_serious_injry
    from
        public.people as people
    left join public.units as units on people.unit_id = units.id
    left join public.people_cris as people_cris on people.id = people_cris.id
    left join
        public.crashes as crashes
        on units.crash_pk = crashes.id
    where people.is_deleted = false
);

create or replace view unit_injury_metrics_view as
(
    select
        units.id,
        units.crash_pk,
        coalesce(
            sum(person_injury_metrics_view.unkn_injry), 0
        ) as unkn_injry_count,
        coalesce(sum(
            person_injury_metrics_view.nonincap_injry
        ), 0) as nonincap_injry_count,
        coalesce(
            sum(person_injury_metrics_view.poss_injry), 0
        ) as poss_injry_count,
        coalesce(
            sum(person_injury_metrics_view.non_injry), 0
        ) as non_injry_count,
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
    where units.is_deleted = false
    group by
        units.id
);

create or replace view crash_injury_metrics_view as
(
    select
        crashes.id,
        crashes.cris_crash_id,
        coalesce(
            sum(person_injury_metrics_view.unkn_injry), 0
        ) as unkn_injry_count,
        coalesce(sum(
            person_injury_metrics_view.nonincap_injry
        ), 0) as nonincap_injry_count,
        coalesce(
            sum(person_injury_metrics_view.poss_injry), 0
        ) as poss_injry_count,
        coalesce(
            sum(person_injury_metrics_view.non_injry), 0
        ) as non_injry_count,
        coalesce(
            sum(person_injury_metrics_view.sus_serious_injry), 0
        ) as sus_serious_injry_count,
        coalesce(
            sum(person_injury_metrics_view.nonincap_injry), 0
        )
        + coalesce(
            sum(person_injury_metrics_view.poss_injry), 0
        )
        + coalesce(
            sum(person_injury_metrics_view.sus_serious_injry), 0
        )
        as tot_injry_count,
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
        coalesce(sum(
            person_injury_metrics_view.motor_vehicle_fatal_injry
        ), 0) as motor_vehicle_fatality_count,
        coalesce(sum(
            person_injury_metrics_view.motor_vehicle_sus_serious_injry
        ), 0) as motor_vehicle_sus_serious_injry_count,
        coalesce(sum(
            person_injury_metrics_view.motorcycle_fatal_injry
        ), 0) as motorcycle_fatality_count,
        coalesce(sum(
            person_injury_metrics_view.motorycle_sus_serious_injry
        ), 0) as motorcycle_sus_serious_count,
        coalesce(sum(
            person_injury_metrics_view.bicycle_fatal_injry
        ), 0) as bicycle_fatality_count,
        coalesce(sum(
            person_injury_metrics_view.bicycle_sus_serious_injry
        ), 0) as bicycle_sus_serious_injry_count,
        coalesce(sum(
            person_injury_metrics_view.pedestrian_fatal_injry
        ), 0) as pedestrian_fatality_count,
        coalesce(sum(
            person_injury_metrics_view.pedestrian_sus_serious_injry
        ), 0) as pedestrian_sus_serious_injry_count,
        coalesce(sum(
            person_injury_metrics_view.micromobility_fatal_injry
        ), 0) as micromobility_fatality_count,
        coalesce(sum(
            person_injury_metrics_view.micromobility_sus_serious_injry
        ), 0) as micromobility_sus_serious_injry_count,
        coalesce(sum(
            person_injury_metrics_view.other_fatal_injry
        ), 0) as other_fatality_count,
        coalesce(sum(
            person_injury_metrics_view.other_sus_serious_injry
        ), 0) as other_sus_serious_injry_count,
        case
            when (sum(person_injury_metrics_view.fatal_injury) > 0) then 4
            when (sum(person_injury_metrics_view.sus_serious_injry) > 0) then 1
            when (sum(person_injury_metrics_view.nonincap_injry) > 0) then 2
            when (sum(person_injury_metrics_view.poss_injry) > 0) then 3
            when (sum(person_injury_metrics_view.unkn_injry) > 0) then 0
            when (sum(person_injury_metrics_view.non_injry) > 0) then 5
            else 0
        end as crash_injry_sev_id,
        coalesce(
            sum(person_injury_metrics_view.years_of_life_lost), 0
        ) as years_of_life_lost,
        coalesce(
            max(est_comp_cost_crash_based), 0
        ) as est_comp_cost_crash_based,
        coalesce(
            sum(est_comp_cost_crash_based), 0
        ) as est_total_person_comp_cost
    from
        public.crashes as crashes
    left join
        person_injury_metrics_view
        on crashes.id = person_injury_metrics_view.crash_pk
    where crashes.is_deleted = false
    group by
        crashes.id,
        crashes.cris_crash_id
);


create or replace view crashes_list_view as with geocode_status as (
    select
        cris.id,
        cris.latitude is null or cris.longitude is null
        as has_no_cris_coordinates,
        edits.latitude is not null and edits.longitude is not null
        as is_manual_geocode
    from public.crashes_cris as cris
    left join public.crashes_edits as edits on cris.id = edits.id
)

select
    public.crashes.id,
    public.crashes.cris_crash_id,
    public.crashes.record_locator,
    public.crashes.case_id,
    public.crashes.crash_timestamp,
    public.crashes.address_primary,
    public.crashes.address_secondary,
    public.crashes.private_dr_fl,
    public.crashes.in_austin_full_purpose,
    public.crashes.location_id,
    public.crashes.rpt_block_num,
    public.crashes.rpt_street_pfx,
    public.crashes.rpt_street_sfx,
    public.crashes.rpt_street_name,
    public.crashes.rpt_sec_block_num,
    public.crashes.rpt_sec_street_pfx,
    public.crashes.rpt_sec_street_sfx,
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
    public.crashes.is_temp_record,
    crash_injury_metrics_view.nonincap_injry_count,
    crash_injury_metrics_view.poss_injry_count,
    crash_injury_metrics_view.sus_serious_injry_count,
    crash_injury_metrics_view.non_injry_count,
    crash_injury_metrics_view.tot_injry_count,
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
    to_char(
        public.crashes.crash_timestamp at time zone 'US/Central', 'YYYY-MM-DD'
    ) as crash_date_ct,
    to_char(
        public.crashes.crash_timestamp at time zone 'US/Central', 'HH24:MI:SS'
    ) as crash_time_ct,
    upper(
        to_char(
            public.crashes.crash_timestamp at time zone 'US/Central', 'dy'
        )
    ) as crash_day_of_week
from
    public.crashes
left join lateral (
    select *
    from
        public.crash_injury_metrics_view
    where
        crashes.id = id
    limit 1
) as crash_injury_metrics_view on true
left join
    geocode_status
    on public.crashes.id = geocode_status.id
left join
    lookups.collsn_lkp
    on public.crashes.fhe_collsn_id = lookups.collsn_lkp.id
left join
    lookups.injry_sev_lkp
    on lookups.injry_sev_lkp.id = crash_injury_metrics_view.crash_injry_sev_id
where crashes.is_deleted = false
order by id asc;

create view locations_list_view as (
    with crash_totals as (
        with unioned_crash_counts as (
            with cr3_crash_counts as (
                select
                    location_id,
                    sus_serious_injry_count,
                    vz_fatality_count,
                    est_comp_cost_crash_based
                from
                    crashes_list_view
                where
                    crashes_list_view.private_dr_fl = false
                    and crashes_list_view.location_id is not null
                    and crashes_list_view.crash_timestamp
                    > (now() - '5 years'::interval)
            ),

            non_cr3_crash_counts as (
                select
                    location_id,
                    0 as vz_fatality_count,
                    0 as sus_serious_injry_count,
                    est_comp_cost as est_comp_cost_crash_based
                from atd_apd_blueform as non_cr3_crash_counts
                where
                    true
                    and non_cr3_crash_counts.location_id is not null
                    and non_cr3_crash_counts.date
                    > (now() - '5 years'::interval)
            )

            select * from cr3_crash_counts
            union all
            select * from non_cr3_crash_counts
        )

        select
            location_id,
            count(unioned_crash_counts.*) as crash_count,
            sum(
                unioned_crash_counts.sus_serious_injry_count
            ) as sus_serious_injry_count,
            sum(unioned_crash_counts.vz_fatality_count) as vz_fatality_count,
            sum(
                unioned_crash_counts.est_comp_cost_crash_based
            ) as total_est_comp_cost
        from
            unioned_crash_counts
        group by location_id
    )

    select
        locations.location_id,
        locations.description,
        coalesce(crash_totals.crash_count, 0) as crash_count,
        coalesce(
            crash_totals.sus_serious_injry_count, 0
        ) as sus_serious_injry_count,
        coalesce(crash_totals.vz_fatality_count, 0) as vz_fatality_count,
        coalesce(crash_totals.total_est_comp_cost, 0) as total_est_comp_cost
    from atd_txdot_locations as locations
    left join crash_totals on locations.location_id = crash_totals.location_id
    where locations.council_district > 0 and locations.location_group = 1
);

create or replace view location_crashes_view as (select
    public.crashes.cris_crash_id,
    'CR3'::text as type,
    public.crashes.location_id,
    public.crashes.case_id,
    to_char(
        public.crashes.crash_timestamp at time zone 'US/Central', 'YYYY-MM-DD'
    ) as crash_date,
    to_char(
        public.crashes.crash_timestamp at time zone 'US/Central', 'HH24:MI:SS'
    ) as crash_time,
    upper(
        to_char(
            public.crashes.crash_timestamp at time zone 'US/Central', 'dy'
        )
    ) as day_of_week,
    crash_injury_metrics_view.crash_injry_sev_id as crash_sev_id,
    public.crashes.latitude,
    public.crashes.longitude,
    public.crashes.address_primary,
    public.crashes.address_secondary,
    crash_injury_metrics_view.non_injry_count,
    crash_injury_metrics_view.nonincap_injry_count,
    crash_injury_metrics_view.poss_injry_count,
    crash_injury_metrics_view.sus_serious_injry_count,
    crash_injury_metrics_view.tot_injry_count,
    crash_injury_metrics_view.unkn_injry_count,
    crash_injury_metrics_view.vz_fatality_count,
    crash_injury_metrics_view.est_comp_cost_crash_based,
    lookups.collsn_lkp.label as collsn_desc,
    crash_units.movement_desc,
    crash_units.travel_direction,
    crash_units.veh_body_styl_desc,
    crash_units.veh_unit_desc
from
    public.crashes
left join lateral
    (
        select
            units.crash_pk,
            string_agg(movt_lkp.label::text, ',') as movement_desc,
            string_agg(trvl_dir_lkp.label::text, ',') as travel_direction,
            string_agg(
                veh_body_styl_lkp.label::text, ','
            ) as veh_body_styl_desc,
            string_agg(unit_desc_lkp.label::text, ',') as veh_unit_desc
        from units
        left join
            lookups.movt_lkp as movt_lkp
            on units.movement_id = movt_lkp.id
        left join
            lookups.trvl_dir_lkp as trvl_dir_lkp
            on units.veh_trvl_dir_id = trvl_dir_lkp.id
        left join
            lookups.veh_body_styl_lkp as veh_body_styl_lkp
            on units.veh_body_styl_id = veh_body_styl_lkp.id
        left join
            lookups.unit_desc_lkp as unit_desc_lkp
            on units.unit_desc_id = unit_desc_lkp.id
        where crashes.id = units.crash_pk
        group by units.crash_pk
    ) as crash_units
    on true
left join lateral (
    select *
    from
        public.crash_injury_metrics_view
    where
        crashes.id = id
    limit 1
) as crash_injury_metrics_view on true
left join
    lookups.collsn_lkp
    on public.crashes.fhe_collsn_id = lookups.collsn_lkp.id
where crashes.is_deleted = false and crashes.crash_timestamp >= (now() - '5 years'::interval)::date
union all
select
    aab.form_id as cris_crash_id,
    'NON-CR3'::text as record_type,
    aab.location_id,
    aab.case_id::text as case_id,
    aab.date::text as crash_date,
    concat(aab.hour, ':00:00') as crash_time,
    (
        select
            case date_part('dow'::text, aab.date)
                when 0 then 'SUN'::text
                when 1 then 'MON'::text
                when 2 then 'TUE'::text
                when 3 then 'WED'::text
                when 4 then 'THU'::text
                when 5 then 'FRI'::text
                when 6 then 'SAT'::text
                else 'Unknown'::text
            end as "case"
    ) as day_of_week,
    0 as crash_sev_id,
    aab.latitude as latitude,
    aab.longitude as longitude,
    aab.address as address_primary,
    ''::text as address_secondary,
    0 as non_injry_count,
    0 as nonincap_injry_count,
    0 as poss_injry_count,
    0 as sus_serious_injry_count,
    0 as tot_injry_count,
    0 as unkn_injry_count,
    0 as vz_fatality_count,
    aab.est_comp_cost_crash_based as est_comp_cost,
    ''::text as collsn_desc,
    ''::text as travel_direction,
    ''::text as movement_desc,
    ''::text as veh_body_styl_desc,
    ''::text as veh_unit_desc
from atd_apd_blueform as aab
where aab.date >= (now() - '5 years'::interval)::date);
