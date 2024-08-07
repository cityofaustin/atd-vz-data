-- all fatal crashes in the old schema that are missing in the new, based purely on the `atd_fatality_count` column
with newdm as (
    select
        id,
        cris_crash_id,
        vz_fatality_count
    from
        crashes_list_view
    where
        vz_fatality_count > 0
        and private_dr_fl = FALSE
        and in_austin_full_purpose = TRUE
),

joined_crashes as (
    select
        old.crash_id,
        newdm.cris_crash_id as new_crash_id
    from atd_txdot_crashes as old
    left join newdm on old.crash_id = newdm.cris_crash_id
    where
        old.crash_date >= '2014-01-01'
        and old.crash_date < '2024-01-01'
        and old.atd_fatality_count > 0
        and old.private_dr_fl = 'N'
        and old.in_austin_full_purpose = 'Y'
)

select * from joined_crashes where new_crash_id is NULL;


-- sus serious injuries
with newdm as (
    select
        id,
        crash_id,
        crash_injry_sev_id
    from
        crashes_list_view
    where
        sus_serious_injry_count > 0
        and private_dr_fl = FALSE
        and in_austin_full_purpose = TRUE
),

joined_crashes as (
    select
        old.crash_id,
        newdm.crash_id as new_crash_id,
        newdm.crash_injry_sev_id as new_crash_injry_sev_id
    from atd_txdot_crashes as old
    left join newdm on old.crash_id = newdm.crash_id
    where
        old.crash_date >= '2014-01-01'
        and old.crash_date < '2024-01-01'
        and old.crash_sev_id = 1
        and old.private_dr_fl = 'N'
        and old.in_austin_full_purpose = 'Y'
)

select * from joined_crashes where new_crash_id is NULL;
