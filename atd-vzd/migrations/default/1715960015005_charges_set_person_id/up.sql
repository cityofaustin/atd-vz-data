--
-- handle a charges record insert by setting the person_id column
-- and crash_id column based on the cris_crash_id and unit_nbr
-- and prsn_nbr
--
create or replace function public.charges_cris_set_person_id_and_crash_id()
returns trigger
language plpgsql
as $$
DECLARE
   person_record record;
begin
    select into person_record people_cris.id as person_id, units.crash_id as crash_id
        from public.people_cris
        left join public.units on public.units.id = people_cris.unit_id
        where
            people_cris.cris_crash_id = new.cris_crash_id
            and people_cris.unit_nbr = new.unit_nbr
            and people_cris.prsn_nbr = new.prsn_nbr;
    new.person_id = person_record.person_id;
    new.crash_id = person_record.crash_id;
    RETURN new;
END;
$$;

create trigger set_charges_cris_person_id_and_crash_id
before insert on public.charges_cris
for each row
execute procedure public.charges_cris_set_person_id_and_crash_id();

