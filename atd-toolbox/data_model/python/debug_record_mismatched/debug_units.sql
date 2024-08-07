-- identifies unit records missing from the new schema, but not necessarily if the unit
-- involves a serious or fatal injury. this is helpful to see how some CRIS data has changed
-- over time but it's not actionable
WITH joined_units AS (
    SELECT
        old_u.crash_id,
        old_u.unit_nbr,
        atc.crash_sev_id,
        new_u.id AS new_id
    FROM
        atd_txdot_units old_u
    LEFT JOIN atd_txdot_crashes atc ON old_u.crash_id = atc.crash_id
    LEFT JOIN units new_u ON old_u.unit_nbr = new_u.unit_nbr
        AND old_u.crash_id = new_u.cris_crash_id
WHERE
    atc.crash_date >= '2018-01-01'
    AND atc.crash_date < '2024-01-01'
    and crash_sev_id in (1,4)
    and atc.in_austin_full_purpose = 'Y'
    and atc.private_dr_fl = 'N'
)
SELECT
    *
FROM
    joined_units
WHERE
    new_id IS NULL;