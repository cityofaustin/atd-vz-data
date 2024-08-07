-- compares crash level injuries to mode cat metadata
with metadata_crashes as (
    select
        crash_id as crash_id_json,
        SUM((item ->> 'mode_id')::int) as mode_id_json,
        STRING_AGG(
            item ->> 'mode_desc',
            ', '
        ) as mode_desc_json,
        SUM((item ->> 'unit_id')::int) as unit_id_json,
        SUM((item ->> 'death_cnt')::int) as atd_fatality_count_json,
        SUM(
            (item ->> 'sus_serious_injry_cnt')::int
        ) as sus_serious_injry_cnt_json,
        SUM((item ->> 'nonincap_injry_cnt')::int) as nonincap_injry_cnt_json,
        SUM((item ->> 'poss_injry_cnt')::int) as poss_injry_cnt_json,
        SUM((item ->> 'non_injry_cnt')::int) as non_injry_cnt_json,
        SUM((item ->> 'unkn_injry_cnt')::int) as unkn_injry_cnt_json,
        SUM((item ->> 'tot_injry_cnt')::int) as tot_injry_cnt_json
    from
        atd_txdot_crashes,
        JSON_ARRAY_ELEMENTS(atd_mode_category_metadata) as item
    group by
        crash_id
),

joined_crashes as (
    select
        crash_id,
        crash_date,
        sus_serious_injry_cnt,
        atd_fatality_count,
        crash_id_json,
        sus_serious_injry_cnt_json,
        atd_fatality_count_json
    from
        atd_txdot_crashes
    left join metadata_crashes on crash_id_json = crash_id
    where
        (atd_fatality_count > 0 or sus_serious_injry_cnt_json > 0)
        and crash_date >= '2014-01-01'
        and in_austin_full_purpose = 'Y'
        and private_dr_fl = 'N'
)

select *
from
    joined_crashes
    where atd_fatality_count != atd_fatality_count_json or sus_serious_injry_cnt != sus_serious_injry_cnt_json;