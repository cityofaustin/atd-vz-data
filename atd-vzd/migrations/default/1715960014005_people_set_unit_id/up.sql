--
-- handle a people record insert by setting
-- the unit_id column based on the crash_id and unit_nbr
--
create or replace function public.people_cris_set_unit_id()
returns trigger
language plpgsql
as $$
DECLARE
   unit_record record;
BEGIN
    SELECT INTO unit_record *
        FROM public.units_cris where cris_crash_id = new.cris_crash_id and unit_nbr = new.unit_nbr;
    new.unit_id = unit_record.id;
    RETURN new;
END;
$$;

create trigger set_person_cris_unit_id
before insert on public.people_cris
for each row
execute procedure public.people_cris_set_unit_id();

