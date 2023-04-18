-- first have to drop view bc it depends on the law_enforcement_num
DROP VIEW view_fatalities;

ALTER TABLE atd_txdot_crashes DROP COLUMN law_enforcement_num;
ALTER TABLE atd_txdot_crashes ADD law_enforcement_num text;

-- recreate view of fatalities in jurisdiction ID 5 (austin full purpose) with crash attributes joined
CREATE OR REPLACE VIEW view_fatalities AS (
    SELECT
        f.id,
        f.crash_id,
        f.victim_name,
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
        crashes.crash_time,
        -- get ytd fatality, partition by year and sort by date/time
        ROW_NUMBER() OVER (
            PARTITION BY EXTRACT(year FROM crashes.crash_date) 
            ORDER BY crashes.crash_date ASC, crashes.crash_time ASC) 
            AS ytd_fatality,
        -- get ytd fatal crash, partition by year and sort by date/time.
        -- records with the same crash_id will get "tie" rankings thus making
        -- this column count each crash rather than each fatality
        DENSE_RANK() OVER (
            PARTITION BY EXTRACT(year FROM crashes.crash_date) 
            ORDER BY crashes.crash_date ASC, crashes.crash_time ASC, crashes.crash_id) 
            AS ytd_fatal_crash,
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
