alter table units drop column vz_mode_category_id;

alter table units
add column vz_mode_category_id integer not null constraint vz_mode_category_fk references lookups.mode_category (
    id
) on
update
restrict on delete restrict generated always as (
    case
        when unit_desc_id = 3
            then
                5
        when unit_desc_id = 5
            then
                6
        when unit_desc_id = 4
            then
                7
        when unit_desc_id = 2
            then
                8
        when unit_desc_id = 177
            then
                (
                    case
                        when veh_body_styl_id = 177
                            then
                                11
                        else
                            6
                    end
                )
        when unit_desc_id = 1
            then
                (
                    case
                        when veh_body_styl_id in (100, 104)
                            then
                                1
                        when veh_body_styl_id in (30, 69, 103, 106)
                            then
                                2
                        when veh_body_styl_id in (71, 90)
                            then
                                3
                        else
                            4
                    end
                )
        else
            9
    end
) stored;

