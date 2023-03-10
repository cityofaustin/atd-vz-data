-- view of fatalities in jurisdiction ID 5 (austin full purpose) with crash attributes joined
CREATE OR REPLACE VIEW view_fatalities AS (
    SELECT
        f.id,
        f.crash_id,
        f.victim_name,
        f.ytd_fatal_crash,
        f.ytd_fatality,
        f.person_id,
        f.primaryperson_id,
        TO_CHAR(crashes.crash_date,
            'yyyy') AS year,
        CONCAT_WS(' ',
            crashes.rpt_block_num,
            crashes.rpt_street_pfx,
            crashes.rpt_street_name,
            '(',
            crashes.rpt_sec_block_num,
            crashes.rpt_sec_street_pfx,
            crashes.rpt_sec_street_name,
            ')') AS location,
        crashes.crash_date,
        crashes.case_id,
        crashes.law_enforcement_num
    FROM
        fatalities f
    INNER JOIN atd_txdot_crashes crashes ON f.crash_id = crashes.crash_id
    WHERE
        crashes.austin_full_purpose = 'Y'
    AND 
        f.is_deleted = false
);
