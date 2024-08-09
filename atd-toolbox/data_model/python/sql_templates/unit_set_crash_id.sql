--
-- handle a unit record insert by setting
-- the crash_id column based on the cris_crash_id
--
create or replace function public.units_cris_set_unit_id()
returns trigger
language plpgsql
as $$
DECLARE
   crash_record record;
BEGIN
    if new.crash_id is not null then
        -- a user may manually create a unit record through a
        -- nested Hasura mutation (eg when creating a temp record)
        -- in which case the unit record will already have a crash_id
        return new;
    end if;
    SELECT INTO crash_record *
        FROM public.crashes_cris where crash_id = new.cris_crash_id;
    new.crash_id = crash_record.id;
    RETURN new;
END;
$$;

create trigger set_units_cris_crash_id
before insert on public.units_cris
for each row
execute procedure public.units_cris_set_unit_id();
