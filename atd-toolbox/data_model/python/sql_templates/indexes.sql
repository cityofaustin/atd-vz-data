create index on public.people_cris (unit_id);
create index on public.people_cris (prsn_injry_sev_id);
create index on public.people_cris (cris_crash_id);
create index on public.people_cris (cris_crash_id, unit_nbr, prsn_nbr); -- charges -> person trigger
create index on public.units_cris (cris_crash_id, unit_nbr); -- people -> unit_id trigger
create index on public.units (crash_pk);
create index on public.people (unit_id);
create index on public.people (prsn_injry_sev_id);
create index on public.crashes (location_id);
create index on public.crashes (cris_crash_id);
create index on public.crashes (crash_timestamp);
create index on public.crashes (record_locator);
create index on public.atd_txdot_locations (council_district);
-- more todo
-- address fields
