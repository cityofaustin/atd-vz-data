--
-- Check if a crash is within a jurisdiction
--
CREATE OR REPLACE FUNCTION find_crash_in_jurisdiction(jurisdiction_id integer, given_crash_id integer)
RETURNS SETOF atd_txdot_crashes AS $$
    (
        SELECT atc.* FROM atd_txdot_crashes AS atc
          INNER JOIN atd_jurisdictions aj
            ON ( 1=1
                AND aj.id = jurisdiction_id
                AND (aj.geometry && atc.position)
                AND ST_Contains(aj.geometry, atc.position)
            )
        WHERE 1=1
          AND crash_id = given_crash_id
    )
$$ LANGUAGE sql STABLE;
