--
-- handle a people record insert by setting
-- the  unit_id column based on the crash_id and unit_nbr
--
create or replace function db.people_cris_set_unit_id()
returns trigger
language plpgsql
as $$
DECLARE
   unit_record record;
BEGIN
    SELECT INTO unit_record *
        FROM db.units_cris where crash_id = new.crash_id and unit_nbr = new.unit_nbr;
    new.unit_id = unit_record.id;
    RETURN new;
END;
$$;

create trigger set_person_cris_unit_id
before insert on db.people_cris
for each row
execute procedure db.people_cris_set_unit_id();
