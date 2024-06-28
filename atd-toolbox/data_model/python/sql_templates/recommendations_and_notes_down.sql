alter table recommendations drop column crash_id;
alter table recommendations rename column atd_txdot_crashes_crash_id to crash_id;

alter table crash_notes drop column crash_id;
alter table crash_notes rename column atd_txdot_crashes_crash_id to crash_id;
