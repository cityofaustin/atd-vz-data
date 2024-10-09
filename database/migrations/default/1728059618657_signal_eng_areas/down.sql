drop table public.signal_engineer_areas;

alter table non_coa_roadways add column id serial primary key,
drop column updated_at;
