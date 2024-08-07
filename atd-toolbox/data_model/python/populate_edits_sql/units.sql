set client_min_messages to warning;


-- todo: double check if CRIS actually has the right data for this unit
update atd_txdot_units set unit_desc_id = 8 where unit_desc_id = 94;

create materialized view unit_diffs as with joined_units as (
    select
        unit_unified.id,
        unit_unified.unit_nbr as unit_nbr,
        unit_unified.crash_pk as crash_pk,
        unit_unified.cris_crash_id as cris_crash_id,
        unit_edit.travel_direction as veh_trvl_dir_id_edit,
        unit_edit.movement_id as movement_id_edit,
        unit_edit.unit_desc_id as unit_desc_id_edit,
        unit_edit.veh_body_styl_id as veh_body_styl_id_edit,
        unit_unified.veh_trvl_dir_id as veh_trvl_dir_id_unified,
        unit_unified.movement_id as movement_id_unified,
        unit_unified.unit_desc_id as unit_desc_id_unified,
        unit_unified.veh_body_styl_id as veh_body_styl_id_unified
    from
        units as unit_unified
    left join atd_txdot_units as unit_edit on
        unit_unified.cris_crash_id = unit_edit.crash_id
        and unit_unified.unit_nbr = unit_edit.unit_nbr
),

computed_diffs as (
    select
        id,
        unit_nbr,
        cris_crash_id,
        crash_pk,
        case
            when
                veh_trvl_dir_id_edit is distinct from veh_trvl_dir_id_unified
                and veh_trvl_dir_id_edit is not null
                then
                    veh_trvl_dir_id_edit
        end as veh_trvl_dir_id,
        case
            when
                movement_id_edit is distinct from movement_id_unified
                and movement_id_edit is not null
                -- importantly, this ignores where movement_id = 0 (UNKNOWN) in the old schema
                -- since it's a default value we don't intend to carry forward
                and movement_id_edit != 0
                then
                    movement_id_edit
        end as movement_id,
        case
            when
                unit_desc_id_edit is distinct from unit_desc_id_unified
                and unit_desc_id_edit is not null
                then
                    unit_desc_id_edit
        end as unit_desc_id,
        case
            when
                veh_body_styl_id_edit is distinct from veh_body_styl_id_unified
                and veh_body_styl_id_edit is not null
                then
                    veh_body_styl_id_edit
        end as veh_body_styl_id
    from
        joined_units
)

select *
from
    computed_diffs
where
    veh_trvl_dir_id is not null
    or movement_id is not null
    or unit_desc_id is not null
    or veh_body_styl_id is not null
order by
    id asc;



update
units_edits
set
    veh_trvl_dir_id = unit_updates.veh_trvl_dir_id,
    movement_id = unit_updates.movement_id,
    unit_desc_id = unit_updates.unit_desc_id,
    veh_body_styl_id = unit_updates.veh_body_styl_id,
    updated_by = 'legacy-vz-user'
from (
    select *
    from
        unit_diffs
) as unit_updates
where
    units_edits.id = unit_updates.id;

-- validate differences have been resolved
refresh materialized view unit_diffs;

select count(*)
from
    unit_diffs;

-- tear down
drop materialized view unit_diffs;
