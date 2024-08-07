set client_min_messages to warning;

create materialized view crash_diffs as with joined_crashes as (
    select
        crash_edit.crash_id,
        crash_edit.longitude_primary ::decimal as longitude_edit,
        crash_edit.latitude_primary ::decimal as latitude_edit,
        crash_edit.city_id as rpt_city_id_edit,
        crash_edit.crash_speed_limit as crash_speed_limit_edit,
        crash_edit.traffic_cntl_id as traffic_cntl_id_edit,
        crash_edit.private_dr_fl ::bool as private_dr_fl_edit,
        crash_edit.road_constr_zone_fl ::bool as road_constr_zone_fl_edit,
        crash_edit.case_id as case_id_edit,
        crash_edit.intrsct_relat_id as intrsct_relat_id_edit,
        crash_edit.law_enforcement_num as law_enforcement_ytd_fatality_num_edit,
        crash_unified.longitude as longitude_unified,
        crash_unified.latitude as latitude_unified,
        crash_unified.rpt_city_id as rpt_city_id_unified,
        crash_unified.crash_speed_limit as crash_speed_limit_unified,
        crash_unified.traffic_cntl_id as traffic_cntl_id_unified,
        crash_unified.private_dr_fl as private_dr_fl_unified,
        crash_unified.road_constr_zone_fl as road_constr_zone_fl_unified,
        crash_unified.case_id as case_id_unified,
        crash_unified.intrsct_relat_id as intrsct_relat_id_unified,
        crash_unified.law_enforcement_ytd_fatality_num as law_enforcement_ytd_fatality_num_unified,
        crash_unified.id
    from
        crashes as crash_unified
    left join atd_txdot_crashes as crash_edit on crash_unified.cris_crash_id = crash_edit.crash_id
),
computed_diffs as (
    select
        crash.id,
        crash.crash_id,
        case when crash.longitude_edit is distinct from crash.longitude_unified
            and longitude_edit is not null then
            crash.longitude_edit
        end as longitude,
        case when crash.latitude_edit is distinct from crash.latitude_unified
            and latitude_edit is not null then
            crash.latitude_edit
        end as latitude,
        case when crash.rpt_city_id_edit is distinct from crash.rpt_city_id_unified
            and rpt_city_id_edit is not null then
            crash.rpt_city_id_edit
        end as rpt_city_id,
        case when crash.crash_speed_limit_edit is distinct from crash.crash_speed_limit_unified
            and crash_speed_limit_edit is not null then
            crash.crash_speed_limit_edit
        end as crash_speed_limit,
        case when crash.traffic_cntl_id_edit is distinct from crash.traffic_cntl_id_unified
            and traffic_cntl_id_edit is not null then
            crash.traffic_cntl_id_edit
        end as traffic_cntl_id,
        case when crash.private_dr_fl_edit is distinct from crash.private_dr_fl_unified
            and private_dr_fl_edit is not null then
            crash.private_dr_fl_edit
        end as private_dr_fl,
        case when crash.road_constr_zone_fl_edit is distinct from crash.road_constr_zone_fl_unified
            and road_constr_zone_fl_edit is not null then
            crash.road_constr_zone_fl_edit
        end as road_constr_zone_fl,
        case when crash.case_id_edit is distinct from crash.case_id_unified
            and case_id_edit is not null then
            crash.case_id_edit
        end as case_id,
        case when crash.intrsct_relat_id_edit is distinct from crash.intrsct_relat_id_unified
            and intrsct_relat_id_edit is not null then
            crash.intrsct_relat_id_edit
        end as intrsct_relat_id,
        case when crash.law_enforcement_ytd_fatality_num_edit is distinct from crash.law_enforcement_ytd_fatality_num_unified
            and law_enforcement_ytd_fatality_num_edit is not null then
            crash.law_enforcement_ytd_fatality_num_edit
        end as law_enforcement_ytd_fatality_num
    from
        joined_crashes as crash
)
select
    *
from
    computed_diffs
where
    longitude is not null
    or latitude is not null
    or rpt_city_id is not null
    or crash_speed_limit is not null
    or traffic_cntl_id is not null
    or private_dr_fl is not null
    or road_constr_zone_fl is not null
    or case_id is not null
    or intrsct_relat_id is not null
    or law_enforcement_ytd_fatality_num is not null
order by
    id asc;

update
    crashes_edits
set
    longitude = crash_updates.longitude,
    latitude = crash_updates.latitude,
    rpt_city_id = crash_updates.rpt_city_id,
    crash_speed_limit = crash_updates.crash_speed_limit,
    traffic_cntl_id = crash_updates.traffic_cntl_id,
    private_dr_fl = crash_updates.private_dr_fl,
    road_constr_zone_fl = crash_updates.road_constr_zone_fl,
    case_id = crash_updates.case_id,
    intrsct_relat_id = crash_updates.intrsct_relat_id,
    law_enforcement_ytd_fatality_num = crash_updates.law_enforcement_ytd_fatality_num,
    updated_by = 'legacy-vz-user'
from (
    select
        *
    from
        crash_diffs) crash_updates
where
    crashes_edits.id = crash_updates.id;

-- validate differences have been resolved
refresh materialized view crash_diffs;

select
    count(*)
from
    crash_diffs;

-- tear down
drop materialized view crash_diffs;
