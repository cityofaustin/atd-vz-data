alter table recommendations rename column crash_id to atd_txdot_crashes_crash_id;

alter table recommendations
    add column crash_pk integer,
    add constraint recommendations_crashes_pk_fkey foreign key (
        crash_pk
    ) references crashes (id),
    drop constraint recommendations_crash_id_key,
    add constraint recommendations_crash_id_key unique (crash_pk),
    alter column atd_txdot_crashes_crash_id drop not null;
;

alter table crash_notes rename column crash_id to atd_txdot_crashes_crash_id;

alter table crash_notes
    add column crash_pk integer,
    add constraint notes_crashes_id_fkey foreign key (
        crash_pk
    ) references crashes (id),
    alter column atd_txdot_crashes_crash_id drop not null;

alter table location_notes
add constraint fk_location_note_location foreign key (
    location_id
) references atd_txdot_locations (location_id),
alter column location_id set not null;

-- squeezing this in here
alter table cris_import_log rename to _cris_import_log;
alter table _cris_import_log drop column outcome_status;
alter table _cris_import_log alter column records_processed drop DEFAULT;
