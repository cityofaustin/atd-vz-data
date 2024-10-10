-- delete created_at column
alter table council_districts drop column created_at;
-- revert updated_at data type
alter table council_districts alter column updated_at set data type timestamp using updated_at::timestamp;
-- remove council district foreign key
alter table crashes drop constraint crashes_council_district_fkey;
-- remove council district primary key
alter table council_districts drop constraint council_districts_pkey;
-- add the id serial pk back
alter table council_districts add column id serial;
alter table council_districts
add constraint council_districts_pkey primary key (id);
