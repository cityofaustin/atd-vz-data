-- these statements were run against prod to cleanup dupe person records
-- done
delete from atd_txdot_primaryperson
where
    primaryperson_id in (3260011, 3844543, 3955109, 3852906, 3852910, 3938846, 3938845, 3964601, 3964602, 4013933);
-- done
delete from atd_txdot_person where person_id = 1446315;
