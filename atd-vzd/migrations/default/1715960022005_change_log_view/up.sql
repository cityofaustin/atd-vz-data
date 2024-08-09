drop view if exists crashes_change_log_view cascade;

create view crashes_change_log_view as (
    select
        concat('crash_', change_log_crashes.id) as id,
        'crash' as record_type,
        record_id as crash_id,
        record_id,
        case
            when (operation_type = 'INSERT') then 'create' else
                lower(operation_type)
        end as operation_type,
        record_json,
        change_log_crashes.created_at,
        change_log_crashes.created_by
    from
        change_log_crashes
    union all
    select
        concat('unit_', change_log_units.id) as id,
        'unit' as record_type,
        units.crash_id,
        record_id,
        case
            when (operation_type = 'INSERT') then 'create' else
                lower(operation_type)
        end as operation_type,
        record_json,
        change_log_units.created_at,
        change_log_units.created_by
    from
        change_log_units
    left join units on change_log_units.record_id = units.id
    union all
    select
        concat('people_', change_log_people.id) as id,
        'person' as record_type,
        crashes.id as crash_id,
        record_id,
        case
            when (operation_type = 'INSERT') then 'create' else
                lower(operation_type)
        end as operation_type,
        record_json,
        change_log_people.created_at,
        change_log_people.created_by
    from
        change_log_people
    left join people on change_log_people.record_id = people.id
    left join units on people.unit_id = units.id
    left join crashes on units.crash_id = crashes.id
);

