-- remove serial id col
alter table council_districts drop column id;
-- make council_district col the primary key
alter table council_districts 
add constraint council_districts_pkey primary key (council_district);
-- add foreign key constraint to existing crashes column
alter table crashes add constraint crashes_council_district_fkey
foreign key (council_district) references council_districts (council_district);

-- convert updated_at from timestamp to timestamp with time zone
alter table council_districts alter column updated_at set data type timestamptz using updated_at::timestamptz;

-- add created_at column and copy updated_at into it
alter table council_districts add column created_at timestamptz default now();
update council_districts set created_at = updated_at;

-- set updated_at via trigger
create or replace trigger set_updated_at_council_districts
before update on public.council_districts
for each row execute function set_updated_at_timestamp();
