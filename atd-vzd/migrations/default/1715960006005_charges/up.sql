create table public.charges_cris (
    id serial primary key,
    charge text,
    charge_cat_id integer references lookups.charge_cat_lkp (id) on update cascade on delete cascade,
    citation_nbr text,
    crash_id integer not null references public.crashes_cris (id) on update cascade on delete cascade,
    cris_crash_id integer not null references public.crashes_cris (crash_id) on update cascade on delete cascade,
    cris_schema_version text not null,
    person_id integer not null references public.people_cris (id) on update cascade on delete cascade,
    prsn_nbr integer not null,
    unit_nbr numeric not null
);
