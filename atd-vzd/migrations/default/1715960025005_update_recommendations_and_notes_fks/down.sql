alter table recommendations drop column crash_id;
alter table recommendations rename column atd_txdot_crashes_crash_id to crash_id;
alter table recommendations add constraint recommendations_crash_id_key unique (crash_id);
delete from recommendations where crash_id is null;
alter table recommendations alter column crash_id set not null;

alter table crash_notes drop column crash_id;
alter table crash_notes rename column atd_txdot_crashes_crash_id to crash_id;
delete from crash_notes where crash_id is null;
alter table crash_notes alter column crash_id set not null;

alter table location_notes
drop constraint fk_location_note_location,
alter column location_id drop not null;

