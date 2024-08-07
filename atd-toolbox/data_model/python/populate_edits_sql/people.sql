set client_min_messages to warning;

-- remove all names from old people tables for non-fatalities
-- this can take more than a minute per table
update atd_txdot_person set prsn_last_name = null, prsn_first_name = null, prsn_mid_name = null
where prsn_injry_sev_id != 4;
update atd_txdot_primaryperson set prsn_last_name = null, prsn_first_name = null, prsn_mid_name = null
where prsn_injry_sev_id != 4;

-- double check if cris has the right data for this person records
update atd_txdot_primaryperson set prsn_injry_sev_id = 0 where prsn_injry_sev_id = 94;
update atd_txdot_person set prsn_injry_sev_id = 0 where prsn_injry_sev_id = 94;
update atd_txdot_primaryperson set prsn_ethnicity_id = 0 where prsn_ethnicity_id = 94;
update atd_txdot_person set prsn_ethnicity_id = 0 where prsn_ethnicity_id = 94;


-- create view of all people records which have been edited
create materialized view people_diffs as with unioned_people_edits as (
    select
        crash_id as cris_crash_id,
        unit_nbr,
        prsn_nbr,
        prsn_type_id,
        prsn_occpnt_pos_id,
        prsn_injry_sev_id,
        prsn_age,
        prsn_last_name,
        prsn_first_name,
        prsn_mid_name,
        prsn_gndr_id,
        prsn_ethnicity_id,
        peh_fl as prsn_exp_homelessness
    from
        atd_txdot_primaryperson
    union all
    select
        crash_id as cris_crash_id,
        unit_nbr,
        prsn_nbr,
        prsn_type_id,
        prsn_occpnt_pos_id,
        prsn_injry_sev_id,
        prsn_age,
        prsn_last_name,
        prsn_first_name,
        prsn_mid_name,
        prsn_gndr_id,
        prsn_ethnicity_id,
        peh_fl as prsn_exp_homelessness
    from
        atd_txdot_person
),
--
-- join "old" people records to new records from cris, where each record is one row with a column for the old value and cris value
--
joined_people as (
    select
        people_unified.id,
        people_edit.cris_crash_id,
        units.unit_nbr,
        people_unified.prsn_nbr,
        people_edit.prsn_type_id as prsn_type_id_edit,
        people_edit.prsn_occpnt_pos_id as prsn_occpnt_pos_id_edit,
        people_edit.prsn_injry_sev_id as prsn_injry_sev_id_edit,
        people_edit.prsn_age as prsn_age_edit,
        people_edit.prsn_last_name as prsn_last_name_edit,
        people_edit.prsn_first_name as prsn_first_name_edit,
        people_edit.prsn_mid_name as prsn_mid_name_edit,
        people_edit.prsn_gndr_id as prsn_gndr_id_edit,
        people_edit.prsn_ethnicity_id as prsn_ethnicity_id_edit,
        people_edit.prsn_exp_homelessness as prsn_exp_homelessness_edit,
        people_unified.prsn_type_id as prsn_type_id_unified,
        people_unified.prsn_occpnt_pos_id as prsn_occpnt_pos_id_unified,
        people_unified.prsn_injry_sev_id as prsn_injry_sev_id_unified,
        people_unified.prsn_age as prsn_age_unified,
        people_unified.prsn_last_name as prsn_last_name_unified,
        people_unified.prsn_first_name as prsn_first_name_unified,
        people_unified.prsn_mid_name as prsn_mid_name_unified,
        people_unified.prsn_gndr_id as prsn_gndr_id_unified,
        people_unified.prsn_ethnicity_id as prsn_ethnicity_id_unified,
        people_unified.prsn_exp_homelessness as prsn_exp_homelessness_unified
    from
        people as people_unified
    left join units on people_unified.unit_id = units.id
    left join crashes on crashes.id = units.crash_pk
    left join unioned_people_edits as people_edit on crashes.cris_crash_id = people_edit.cris_crash_id
        and units.unit_nbr = people_edit.unit_nbr
        and people_unified.prsn_nbr = people_edit.prsn_nbr
),
--
-- construct a table that looks a lot like people_edits,
-- where there is a value in each column if it's different from the cris value
--
computed_diffs as (
    select
        id,
        cris_crash_id,
        unit_nbr,
        prsn_nbr,
        case when prsn_type_id_edit is not null
            and prsn_type_id_edit is distinct from prsn_type_id_unified then
            prsn_type_id_edit
        end as prsn_type_id,
        case when prsn_occpnt_pos_id_edit is not null
            and prsn_occpnt_pos_id_edit is distinct from prsn_occpnt_pos_id_unified then
            prsn_occpnt_pos_id_edit
        end as prsn_occpnt_pos_id,
        case when prsn_injry_sev_id_edit is not null
            and prsn_injry_sev_id_edit is distinct from prsn_injry_sev_id_unified then
            prsn_injry_sev_id_edit
        end as prsn_injry_sev_id,
        case when prsn_age_edit is not null
            and prsn_age_edit is distinct from prsn_age_unified then
            prsn_age_edit
        end as prsn_age,
        case when prsn_last_name_edit is not null
            and prsn_last_name_edit is distinct from prsn_last_name_unified then
            prsn_last_name_edit
        end as prsn_last_name,
        case when prsn_first_name_edit is not null
            and prsn_first_name_edit is distinct from prsn_first_name_unified then
            prsn_first_name_edit
        end as prsn_first_name,
        case when prsn_mid_name_edit is not null
            and prsn_mid_name_edit is distinct from prsn_mid_name_unified then
            prsn_mid_name_edit
        end as prsn_mid_name,
        case when prsn_gndr_id_edit is not null
            and prsn_gndr_id_edit is distinct from prsn_gndr_id_unified then
            prsn_gndr_id_edit
        end as prsn_gndr_id,
        case when prsn_ethnicity_id_edit is not null
            and prsn_ethnicity_id_edit is distinct from prsn_ethnicity_id_unified then
            prsn_ethnicity_id_edit
        end as prsn_ethnicity_id,
        case when prsn_exp_homelessness_edit is not null
            and prsn_exp_homelessness_edit is distinct from prsn_exp_homelessness_unified then
            prsn_exp_homelessness_edit
        end as prsn_exp_homelessness
    from
        joined_people
)
select
    *
from
    computed_diffs
where
    prsn_type_id is not null
    or prsn_occpnt_pos_id is not null
    or prsn_injry_sev_id is not null
    or prsn_age is not null
    or prsn_last_name is not null
    or prsn_first_name is not null
    or prsn_mid_name is not null
    or prsn_gndr_id is not null
    or prsn_ethnicity_id is not null
    or prsn_exp_homelessness is not null
order by
    id asc;

-- update records
update
    people_edits pe
set
    prsn_type_id = pd.prsn_type_id,
    prsn_occpnt_pos_id = pd.prsn_occpnt_pos_id,
    prsn_injry_sev_id = pd.prsn_injry_sev_id,
    prsn_age = pd.prsn_age,
    prsn_last_name = pd.prsn_last_name,
    prsn_first_name = pd.prsn_first_name,
    prsn_mid_name = pd.prsn_mid_name,
    prsn_gndr_id = pd.prsn_gndr_id,
    prsn_ethnicity_id = pd.prsn_ethnicity_id,
    prsn_exp_homelessness = pd.prsn_exp_homelessness,
    updated_by = 'legacy-vz-user'
from (
    select
        *
    from
        people_diffs) as pd
where
    pe.id = pd.id;


-- refresh da view
refresh materialized view people_diffs;

-- see if there are remaining diffs, which is the result of dupe person records :/
-- and there's nothing to be done about this :/
select * from people_diffs;

-- tear down
drop materialized view people_diffs;
