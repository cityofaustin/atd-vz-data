-- compares person level injuries to mode cat metadata
WITH metadata_crashes AS (
    SELECT
        crash_id AS crash_id_json,
        SUM((item ->> 'mode_id')::int) AS mode_id_json,
        STRING_AGG(item ->> 'mode_desc',
            ', ') AS mode_desc_json,
        SUM((item ->> 'unit_id')::int) AS unit_id_json,
        SUM((item ->> 'death_cnt')::int) AS atd_fatality_count_json,
        SUM((item ->> 'sus_serious_injry_cnt')::int) AS sus_serious_injry_cnt_json,
        SUM((item ->> 'nonincap_injry_cnt')::int) AS nonincap_injry_cnt_json,
        SUM((item ->> 'poss_injry_cnt')::int) AS poss_injry_cnt_json,
        SUM((item ->> 'non_injry_cnt')::int) AS non_injry_cnt_json,
        SUM((item ->> 'unkn_injry_cnt')::int) AS unkn_injry_cnt_json,
        SUM((item ->> 'tot_injry_cnt')::int) AS tot_injry_cnt_json
    FROM
        atd_txdot_crashes,
        JSON_ARRAY_ELEMENTS(atd_mode_category_metadata) AS item
    GROUP BY
        crash_id
),
-- get all crashes with at least one serious or fatal person injury
unioned_people AS (
    SELECT
        primaryperson_id AS record_id,
        crash_id,
        unit_nbr,
        prsn_nbr,
        prsn_injry_sev_id,
        CASE WHEN prsn_injry_sev_id = 1 THEN
            1
        ELSE
            0
        END AS sus_serious_injry_cnt,
        CASE WHEN prsn_injry_sev_id = 4 THEN
            1
        ELSE
            0
        END AS atd_fatality_cnt,
        TRUE AS is_primary
    FROM
        atd_txdot_primaryperson
    UNION ALL
    SELECT
        person_id AS record_id,
        crash_id,
        unit_nbr,
        prsn_nbr,
        prsn_injry_sev_id,
        CASE WHEN prsn_injry_sev_id = 1 THEN
            1
        ELSE
            0
        END AS sus_serious_injry_cnt,
        CASE WHEN prsn_injry_sev_id = 4 THEN
            1
        ELSE
            0
        END AS atd_fatality_cnt,
        FALSE AS is_primary
    FROM
        atd_txdot_person
),
person_injuries AS (
    SELECT
        crash_id,
        sum(sus_serious_injry_cnt) AS sus_serious_injry_cnt,
        sum(atd_fatality_cnt) AS atd_fatality_cnt
    FROM
        unioned_people
GROUP BY
    crash_id
)
SELECT
    atc.crash_id,
    p.sus_serious_injry_cnt,
    meta.sus_serious_injry_cnt_json,
    p.atd_fatality_cnt,
    meta.atd_fatality_count_json
FROM
    atd_txdot_crashes atc
    left join person_injuries p on p.crash_id = atc.crash_id
    LEFT JOIN metadata_crashes meta ON meta.crash_id_json = p.crash_id
    where (p.sus_serious_injry_cnt != sus_serious_injry_cnt_json or p.atd_fatality_cnt != atd_fatality_count_json)
    and atc.crash_date >= '2018-01-01'
    and atc.in_austin_full_purpose = 'Y'
    and atc.private_dr_fl = 'N';
