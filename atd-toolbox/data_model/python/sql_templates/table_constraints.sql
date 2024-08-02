alter table public.units_cris add constraint unique_units_cris unique (crash_pk, unit_nbr);
alter table public.units add constraint unique_units unique (crash_pk, unit_nbr);
alter table public.people_cris add constraint unique_people_cris unique (unit_id, prsn_nbr);
alter table public.people_edits add constraint unique_people_edits unique (unit_id, prsn_nbr) deferrable initially deferred;
alter table public.people add constraint unique_people unique (unit_id, prsn_nbr) deferrable initially deferred;
