-- wiggle all crash locations to refresh location ID
-- this is going to take a while...
UPDATE
    atd_txdot_crashes atc
SET
    latitude_primary = latitude_primary +.0000000001
WHERe latitude_primary is not null;

-- join old and new crashes and select all crashes from that set
-- which do not have a matching location ID
-- we want this to return 0 rows
WITH joined_crashes AS (
    SELECT
        id,
        atc.crash_id,
        crash.location_id AS location_id_new,
        atc.location_id AS location_id_old
    FROM
        atd_txdot_crashes atc 
            inner JOIN crashes crash ON atc.crash_id = crash.cris_crash_id
WHERE
    crash.location_id IS NOT NULL
    OR atc.location_id IS NOT NULL
)
select crash_id from joined_crashes where location_id_new != location_id_old;
