alter table public.crashes_cris add column created_at timestamptz not null default now();
alter table public.crashes_cris add column updated_at timestamptz not null default now();
alter table public.crashes_cris add column created_by text not null default 'system';
alter table public.crashes_cris add column updated_by text not null default 'system';
alter table public.units_cris add column created_at timestamptz not null default now();
alter table public.units_cris add column updated_at timestamptz not null default now();
alter table public.units_cris add column created_by text not null default 'system';
alter table public.units_cris add column updated_by text not null default 'system';
alter table public.people_cris add column created_at timestamptz not null default now();
alter table public.people_cris add column updated_at timestamptz not null default now();
alter table public.people_cris add column created_by text not null default 'system';
alter table public.people_cris add column updated_by text not null default 'system';
alter table public.charges_cris add column created_at timestamptz not null default now();
alter table public.charges_cris add column created_by text not null default 'system';
alter table public.crashes_edits add column created_at timestamptz not null default now();
alter table public.crashes_edits add column updated_at timestamptz not null default now();
alter table public.crashes_edits add column created_by text not null default 'system';
alter table public.crashes_edits add column updated_by text not null default 'system';
alter table public.units_edits add column created_at timestamptz not null default now();
alter table public.units_edits add column updated_at timestamptz not null default now();
alter table public.units_edits add column created_by text not null default 'system';
alter table public.units_edits add column updated_by text not null default 'system';
alter table public.people_edits add column created_at timestamptz not null default now();
alter table public.people_edits add column updated_at timestamptz not null default now();
alter table public.people_edits add column created_by text not null default 'system';
alter table public.people_edits add column updated_by text not null default 'system';
alter table public.crashes_unified add column created_at timestamptz not null default now();
alter table public.crashes_unified add column updated_at timestamptz not null default now();
alter table public.crashes_unified add column created_by text not null default 'system';
alter table public.crashes_unified add column updated_by text not null default 'system';
alter table public.units_unified add column created_at timestamptz not null default now();
alter table public.units_unified add column updated_at timestamptz not null default now();
alter table public.units_unified add column created_by text not null default 'system';
alter table public.units_unified add column updated_by text not null default 'system';
alter table public.people_unified add column created_at timestamptz not null default now();
alter table public.people_unified add column updated_at timestamptz not null default now();
alter table public.people_unified add column created_by text not null default 'system';
alter table public.people_unified add column updated_by text not null default 'system';

create or replace function public.set_updated_at_timestamp()
returns trigger
language plpgsql
as $function$
begin
    new.updated_at := now();
    return new;
end;
$function$;

create trigger set_updated_at_timestamp_crashes_cris
before update on public.crashes_cris
for each row
execute procedure public.set_updated_at_timestamp();


create trigger set_updated_at_timestamp_crashes_edits
before update on public.crashes_edits
for each row
execute procedure public.set_updated_at_timestamp();


create trigger set_updated_at_timestamp_crashes_unified
before update on public.crashes_unified
for each row
execute procedure public.set_updated_at_timestamp();


create trigger set_updated_at_timestamp_units_cris
before update on public.units_cris
for each row
execute procedure public.set_updated_at_timestamp();


create trigger set_updated_at_timestamp_units_edits
before update on public.units_edits
for each row
execute procedure public.set_updated_at_timestamp();


create trigger set_updated_at_timestamp_units_unified
before update on public.units_unified
for each row
execute procedure public.set_updated_at_timestamp();


create trigger set_updated_at_timestamp_people_cris
before update on public.people_cris
for each row
execute procedure public.set_updated_at_timestamp();


create trigger set_updated_at_timestamp_people_edits
before update on public.people_edits
for each row
execute procedure public.set_updated_at_timestamp();


create trigger set_updated_at_timestamp_people_unified
before update on public.people_unified
for each row
execute procedure public.set_updated_at_timestamp();

