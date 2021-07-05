CREATE OR REPLACE VIEW view_location_crashes_global AS
SELECT atc.crash_id AS crash_id
     , 'CR3'::text AS type
     , atc.location_id
     , atc.case_id
     , atc.crash_date
     , atc.crash_time
     , atc.day_of_week
     , atc.crash_sev_id
     , atc.longitude_primary
     , atc.latitude_primary
     , atc.address_confirmed_primary
     , atc.address_confirmed_secondary
     , atc.non_injry_cnt
     , atc.nonincap_injry_cnt
     , atc.poss_injry_cnt
     , atc.sus_serious_injry_cnt
     , atc.tot_injry_cnt
     , atc.death_cnt
     , atc.unkn_injry_cnt
     , atc.est_comp_cost_crash_based as est_comp_cost
     , string_agg(atcl.collsn_desc::text, ',')          AS collsn_desc
     , string_agg(attdl.trvl_dir_desc::text, ',')       AS travel_direction
     , string_agg(atml.movement_desc::text, ',')        AS movement_desc
     , string_agg(atvbsl.veh_body_styl_desc::text, ',') AS veh_body_styl_desc
     , string_agg(atvudl.veh_unit_desc_desc::text, ',') AS veh_unit_desc_desc

FROM atd_txdot_crashes AS atc
         LEFT JOIN atd_txdot__collsn_lkp AS atcl ON atc.fhe_collsn_id = atcl.collsn_id
         LEFT JOIN atd_txdot_units AS atu ON atc.crash_id = atu.crash_id
         LEFT JOIN atd_txdot__trvl_dir_lkp AS attdl ON atu.travel_direction = attdl.trvl_dir_id
         LEFT JOIN atd_txdot__movt_lkp AS atml ON atu.movement_id = atml.movement_id
         LEFT JOIN atd_txdot__veh_body_styl_lkp AS atvbsl ON atu.veh_body_styl_id = atvbsl.veh_body_styl_id
         LEFT JOIN atd_txdot__veh_unit_desc_lkp AS atvudl on atu.unit_desc_id = atvudl.veh_unit_desc_id
WHERE atc.crash_date >= (NOW() - interval '5 year')::date
GROUP BY atc.crash_id
       , atc.location_id
       , atc.case_id
       , atc.crash_date
       , atc.crash_time
       , atc.day_of_week
       , atc.crash_sev_id
       , atc.longitude_primary
       , atc.latitude_primary
       , atc.address_confirmed_primary
       , atc.address_confirmed_secondary
       , atc.non_injry_cnt
       , atc.nonincap_injry_cnt
       , atc.poss_injry_cnt
       , atc.sus_serious_injry_cnt
       , atc.tot_injry_cnt
       , atc.death_cnt
       , atc.unkn_injry_cnt
       , atc.est_comp_cost

UNION ALL

SELECT
     aab.form_id AS crash_id
     , 'NON-CR3'::text AS type
     , aab.location_id
     , aab.case_id::text
     , aab.date AS crash_date
     , CONCAT(aab.hour,':00:00')::time AS crash_time
     , (SELECT CASE date_part('dow',aab.date)
                  WHEN 0 THEN 'SUN'
                  WHEN 1 THEN 'MON'
                  WHEN 2 THEN 'TUE'
                  WHEN 3 THEN 'WED'
                  WHEN 4 THEN 'THU'
                  WHEN 5 THEN 'FRI'
                  WHEN 6 THEN 'SAT'
                  ELSE 'Unknown' END)::text AS day_of_week
     , 0 AS crash_sev_id
     , longitude AS longitude_primary
     , latitude AS latitude_primary
     , address AS address_confirmed_primary
     , ''::text AS address_confirmed_secondary
     , 0 AS non_injry_cnt
     , 0 AS nonincap_injry_cnt
     , 0 AS poss_injry_cnt
     , 0 AS sus_serious_injry_cnt
     , 0 AS tot_injry_cnt
     , 0 AS death_cnt
     , 0 AS unkn_injry_cnt
     , est_comp_cost_crash_based as est_comp_cost
     , ''::text AS collsn_desc
     , ''::text AS travel_direction
     , ''::text AS movement_desc
     , ''::text AS veh_body_styl_desc
     , ''::text AS veh_unit_desc_desc
FROM atd_apd_blueform AS aab
WHERE aab.date >= (NOW() - interval '5 year')::date;
