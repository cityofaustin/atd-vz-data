alter table recommendations rename column crash_id to atd_txdot_crashes_crash_id;

alter table recommendations
    add column crash_id integer,
    add constraint recommendations_crashes_id_fkey foreign key (
        crash_id
    ) references crashes (id),
    drop constraint recommendations_crash_id_key,
    add constraint recommendations_crash_id_key unique (crash_id),
    alter column atd_txdot_crashes_crash_id drop not null;
;

alter table crash_notes rename column crash_id to atd_txdot_crashes_crash_id;

alter table crash_notes
    add column crash_id integer,
    add constraint notes_crashes_id_fkey foreign key (
        crash_id
    ) references crashes (id),
    alter column atd_txdot_crashes_crash_id drop not null;
;
