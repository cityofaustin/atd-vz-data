-- ---
-- --- copy locations table and restablish index
-- ---
-- create table public.locations as select * from public.atd_txdot_locations;
-- alter table public.locations add primary key (location_id);
-- create index locations_geometry_index on public.locations using gist (geometry);


---
--- copy crash notes, which can't be done until after the data migration bc of foreign key constraint
---
create table public.crash_notes as select * from public.crash_notes;
alter table public.crash_notes add primary key (id);
create sequence public.crash_notes_id_seq;
alter table public.crash_notes alter column id set default nextval('public.crash_notes_id_seq');
select setval('public.crash_notes_id_seq', (select max(id) from public.crash_notes));
alter table public.crash_notes add constraint fk_crash_notes_crash_id foreign key (crash_id) references public.crashes (crash_id);
create index crash_notes_crash_id_idx on public.crash_notes (crash_id);
