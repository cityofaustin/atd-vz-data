-- This is a one time script to populate the fatalities table with historical data

INSERT INTO fatalities (crash_id, primaryperson_id)
SELECT crash_id, primaryperson_id
FROM atd_txdot_primaryperson
WHERE prsn_injry_sev_id = 4;

INSERT INTO fatalities (crash_id, person_id)
SELECT crash_id, person_id
FROM atd_txdot_person
WHERE prsn_injry_sev_id = 4;
