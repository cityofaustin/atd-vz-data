update public.atd_txdot_crashes set surf_type_id = 99
where surf_type_id = 'null';

alter table lookups.unit_desc_lkp
drop constraint unit_desc_owner_check,
add constraint unit_desc_owner_check check (
    (
        (id < 177 and source = 'cris')
        or (id >= 177 and source = 'vz')
        or (id = 94 and source = 'vz')
    )
);


alter table lookups.injry_sev_lkp
drop constraint injry_sev_owner_check,
add constraint injry_sev_owner_check check (
    (
        (id < 99 and source = 'cris')
        or (id >= 99 and source = 'vz')
        or (id = 94 and source = 'vz')
    )
);


insert into lookups.unit_desc_lkp (id, label, source) values (
    94, 'REPORTED INVALID', 'vz'
);

insert into lookups.injry_sev_lkp (id, label, source) values (
    94, 'REPORTED INVALID', 'vz'
);

-- fix a dangling primary person FK reference
update atd_txdot_primaryperson set prsn_ethnicity_id = 0
where prsn_ethnicity_id = 94;
