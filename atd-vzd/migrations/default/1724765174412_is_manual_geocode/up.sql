CREATE OR REPLACE VIEW crashes_list_view AS WITH geocode_status AS (
    SELECT
        cris.id,
        (
            edits.latitude IS NOT NULL
            OR edits.longitude IS NOT NULL
        ) AS is_manual_geocode
    FROM crashes_cris AS cris
    LEFT JOIN crashes_edits AS edits ON cris.id = edits.id
)

SELECT
    crashes.id,
    crashes.cris_crash_id,
    crashes.record_locator,
    crashes.case_id,
    crashes.crash_timestamp,
    crashes.address_primary,
    crashes.address_secondary,
    crashes.private_dr_fl,
    crashes.in_austin_full_purpose,
    crashes.location_id,
    crashes.rpt_block_num,
    crashes.rpt_street_pfx,
    crashes.rpt_street_sfx,
    crashes.rpt_street_name,
    crashes.rpt_sec_block_num,
    crashes.rpt_sec_street_pfx,
    crashes.rpt_sec_street_sfx,
    crashes.rpt_sec_street_name,
    crashes.latitude,
    crashes.longitude,
    crashes.light_cond_id,
    crashes.wthr_cond_id,
    crashes.active_school_zone_fl,
    crashes.schl_bus_fl,
    crashes.at_intrsct_fl,
    crashes.onsys_fl,
    crashes.traffic_cntl_id,
    crashes.road_constr_zone_fl,
    crashes.rr_relat_fl,
    crashes.toll_road_fl,
    crashes.intrsct_relat_id,
    crashes.obj_struck_id,
    crashes.crash_speed_limit,
    crashes.council_district,
    crashes.is_temp_record,
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
    injry_sev.label AS crash_injry_sev_desc,
    collsn.label AS collsn_desc,
    geocode_status.is_manual_geocode,
    to_char(
        (crashes.crash_timestamp AT TIME ZONE 'US/Central'::text),
        'YYYY-MM-DD'::text
    ) AS crash_date_ct,
    to_char(
        (crashes.crash_timestamp AT TIME ZONE 'US/Central'::text),
        'HH24:MI:SS'::text
    ) AS crash_time_ct,
    upper(
        to_char(
            (crashes.crash_timestamp AT TIME ZONE 'US/Central'::text),
            'dy'::text
        )
    ) AS crash_day_of_week
FROM crashes
LEFT JOIN LATERAL (SELECT
    crash_injury_metrics_view_1.id,
    crash_injury_metrics_view_1.cris_crash_id,
    crash_injury_metrics_view_1.unkn_injry_count,
    crash_injury_metrics_view_1.nonincap_injry_count,
    crash_injury_metrics_view_1.poss_injry_count,
    crash_injury_metrics_view_1.non_injry_count,
    crash_injury_metrics_view_1.sus_serious_injry_count,
    crash_injury_metrics_view_1.tot_injry_count,
    crash_injury_metrics_view_1.fatality_count,
    crash_injury_metrics_view_1.vz_fatality_count,
    crash_injury_metrics_view_1.law_enf_fatality_count,
    crash_injury_metrics_view_1.cris_fatality_count,
    crash_injury_metrics_view_1.motor_vehicle_fatality_count,
    crash_injury_metrics_view_1.motor_vehicle_sus_serious_injry_count,
    crash_injury_metrics_view_1.motorcycle_fatality_count,
    crash_injury_metrics_view_1.motorcycle_sus_serious_count,
    crash_injury_metrics_view_1.bicycle_fatality_count,
    crash_injury_metrics_view_1.bicycle_sus_serious_injry_count,
    crash_injury_metrics_view_1.pedestrian_fatality_count,
    crash_injury_metrics_view_1.pedestrian_sus_serious_injry_count,
    crash_injury_metrics_view_1.micromobility_fatality_count,
    crash_injury_metrics_view_1.micromobility_sus_serious_injry_count,
    crash_injury_metrics_view_1.other_fatality_count,
    crash_injury_metrics_view_1.other_sus_serious_injry_count,
    crash_injury_metrics_view_1.crash_injry_sev_id,
    crash_injury_metrics_view_1.years_of_life_lost,
    crash_injury_metrics_view_1.est_comp_cost_crash_based,
    crash_injury_metrics_view_1.est_total_person_comp_cost
FROM crash_injury_metrics_view AS crash_injury_metrics_view_1
WHERE crashes.id = crash_injury_metrics_view_1.id
LIMIT 1) AS crash_injury_metrics_view ON TRUE
LEFT JOIN geocode_status ON crashes.id = geocode_status.id
LEFT JOIN lookups.collsn ON crashes.fhe_collsn_id = collsn.id
LEFT JOIN
    lookups.injry_sev
    ON crash_injury_metrics_view.crash_injry_sev_id = injry_sev.id
WHERE crashes.is_deleted = FALSE
ORDER BY crashes.crash_timestamp DESC;
