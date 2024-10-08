select
    DISTINCT ON (atp.crash_id, atp.unit_nbr, atp.prsn_nbr)
    atp.crash_id as "Crash_ID",
    TO_CHAR(prsn_death_date, 'MM/DD/YYYY') as prsn_death_date,
    TO_CHAR(prsn_death_time, 'HH24:MI:SS') as prsn_death_time,
    prsn_age,
    prsn_alc_rslt_id,
    prsn_alc_spec_type_id,
    prsn_bac_test_rslt,
    prsn_drg_rslt_id,
    prsn_drg_spec_type_id,
    prsn_ethnicity_id,
    prsn_first_name,
    prsn_gndr_id,
    prsn_helmet_id,
    prsn_injry_sev_id,
    prsn_last_name,
    prsn_mid_name,
    prsn_nbr,
    prsn_occpnt_pos_id,
    prsn_rest_id,
    prsn_taken_by,
    prsn_taken_to,
    prsn_type_id,
    unit_nbr
from atd_txdot_person as atp
left join atd_txdot_crashes as atc on atp.crash_id = atc.crash_id
where crash_date < '2014-01-01';
