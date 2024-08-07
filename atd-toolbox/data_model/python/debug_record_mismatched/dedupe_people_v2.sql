
-- joins people to people to compare dupe values side by side
-- inclusive of serious and fatal crashes in afp not on private drive only
-- the result of this query shows upe person records that need to be address before
-- we can reliably populate the VZ edits
WITH unioned_people AS (
    SELECT
        crash_id::text
        || '_'
        || unit_nbr::text
        || '_'
        || prsn_nbr::text AS dupe_key,
        primaryperson_id AS record_id,
        crash_id,
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
        peh_fl AS prsn_exp_homelessness,
        updated_by,
        last_update,
        true AS is_primary
    FROM
        atd_txdot_primaryperson
    UNION ALL
    SELECT
        crash_id::text
        || '_'
        || unit_nbr::text
        || '_'
        || prsn_nbr::text AS dupe_key,
        person_id AS record_id,
        crash_id,
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
        peh_fl AS prsn_exp_homelessness,
        updated_by,
        last_update,
        false AS is_primary
    FROM
        atd_txdot_person
),

joined_dupes AS (
    SELECT
        p1.dupe_key,
        p1.crash_id,
        p1.unit_nbr,
        p1.prsn_nbr,
        p1.record_id,
        p2.record_id AS record_id_p2,
        p1.prsn_type_id,
        p2.prsn_type_id AS prsn_type_id_p2,
        p1.prsn_occpnt_pos_id,
        p2.prsn_occpnt_pos_id AS prsn_occpnt_pos_id_p2,
        p1.prsn_injry_sev_id,
        p2.prsn_injry_sev_id AS prsn_injry_sev_id_p2,
        p1.prsn_age,
        p2.prsn_age AS prsn_age_p2,
        p1.prsn_last_name,
        p2.prsn_last_name AS prsn_last_name_p2,
        p1.prsn_first_name,
        p2.prsn_first_name AS prsn_first_name_p2,
        p1.prsn_mid_name,
        p2.prsn_mid_name AS prsn_mid_name_p2,
        p1.prsn_gndr_id,
        p2.prsn_gndr_id AS prsn_gndr_id_p2,
        p1.prsn_ethnicity_id,
        p2.prsn_ethnicity_id AS prsn_ethnicity_id_p2,
        p1.prsn_exp_homelessness,
        p2.prsn_exp_homelessness AS prsn_exp_homelessness_p2,
        p1.updated_by,
        p2.updated_by AS updated_by_p2,
        p1.last_update,
        p2.last_update AS last_update_p2,
        p1.is_primary,
        p2.is_primary AS is_primary_p2,
        atc.in_austin_full_purpose
    FROM
        unioned_people AS p1
    LEFT JOIN unioned_people AS p2
        ON
            p1.dupe_key = p2.dupe_key
            AND p1.record_id < p2.record_id
    left join atd_txdot_crashes atc on p1.crash_id = atc.crash_id
)

SELECT * FROM joined_dupes WHERE
    record_id_p2 IS NOT null
    and in_austin_full_purpose = 'Y'
    and (prsn_injry_sev_id_p2 in (1, 4) or prsn_injry_sev_id in (1, 4))
    -- you can remove this where conditiont to further validate dupes
    -- but these are the only columns that are checked for edits when we populate
    -- the VZ edits
    AND (
        prsn_type_id != prsn_type_id_p2
        OR prsn_occpnt_pos_id != prsn_occpnt_pos_id_p2
        OR prsn_injry_sev_id != prsn_injry_sev_id_p2
        OR prsn_age != prsn_age_p2
        OR prsn_last_name != prsn_last_name_p2
        OR prsn_first_name != prsn_first_name_p2
        OR prsn_mid_name != prsn_mid_name_p2
        OR prsn_gndr_id != prsn_gndr_id_p2
        OR prsn_ethnicity_id != prsn_ethnicity_id_p2
        OR prsn_exp_homelessness != prsn_exp_homelessness_p2
    );
