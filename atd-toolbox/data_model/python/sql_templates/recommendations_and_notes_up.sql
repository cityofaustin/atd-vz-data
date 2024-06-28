alter table recommendations rename column crash_id to atd_txdot_crashes_crash_id;

alter table recommendations
    add column crash_id integer,
    add constraint recommendations_crashes_id_fkey foreign key (
        crash_id
    ) references crashes (id);

alter table crash_notes rename column crash_id to atd_txdot_crashes_crash_id;

alter table crash_notes
    add column crash_id integer,
    add constraint notes_crashes_id_fkey foreign key (
        crash_id
    ) references crashes (id);
