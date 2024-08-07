---
--- crashes change log tables
---

create table public.change_log_crashes_cris (
    id serial primary key,
    record_id integer not null references public.crashes_cris (id) on delete cascade on update cascade,
    operation_type text not null,
    record_json jsonb not null,
    created_at timestamp with time zone default now(),
    created_by text not null
);

create index on public.change_log_crashes_cris (record_id);


create table public.change_log_crashes_edits (
    id serial primary key,
    record_id integer not null references public.crashes_edits (id) on delete cascade on update cascade,
    operation_type text not null,
    record_json jsonb not null,
    created_at timestamp with time zone default now(),
    created_by text not null
);

create index on public.change_log_crashes_edits (record_id);


create table public.change_log_crashes (
    id serial primary key,
    record_id integer not null references public.crashes (id) on delete cascade on update cascade,
    operation_type text not null,
    record_json jsonb not null,
    created_at timestamp with time zone default now(),
    created_by text not null
);

create index on public.change_log_crashes (record_id);


---
--- units change log tables
---

create table public.change_log_units_cris (
    id serial primary key,
    record_id integer not null references public.units_cris (id) on delete cascade on update cascade,
    operation_type text not null,
    record_json jsonb not null,
    created_at timestamp with time zone default now(),
    created_by text not null
);

create index on public.change_log_units_cris (record_id);


create table public.change_log_units_edits (
    id serial primary key,
    record_id integer not null references public.units_edits (id) on delete cascade on update cascade,
    operation_type text not null,
    record_json jsonb not null,
    created_at timestamp with time zone default now(),
    created_by text not null
);

create index on public.change_log_units_edits (record_id);


create table public.change_log_units (
    id serial primary key,
    record_id integer not null references public.units (id) on delete cascade on update cascade,
    operation_type text not null,
    record_json jsonb not null,
    created_at timestamp with time zone default now(),
    created_by text not null
);

create index on public.change_log_units (record_id);


---
--- people change log tables
---

create table public.change_log_people_cris (
    id serial primary key,
    record_id integer not null references public.people_cris (id) on delete cascade on update cascade,
    operation_type text not null,
    record_json jsonb not null,
    created_at timestamp with time zone default now(),
    created_by text not null
);

create index on public.change_log_people_cris (record_id);


create table public.change_log_people_edits (
    id serial primary key,
    record_id integer not null references public.people_edits (id) on delete cascade on update cascade,
    operation_type text not null,
    record_json jsonb not null,
    created_at timestamp with time zone default now(),
    created_by text not null
);

create index on public.change_log_people_edits (record_id);


create table public.change_log_people (
    id serial primary key,
    record_id integer not null references public.people (id) on delete cascade on update cascade,
    operation_type text not null,
    record_json jsonb not null,
    created_at timestamp with time zone default now(),
    created_by text not null
);

create index on public.change_log_people (record_id);


--
-- Insert into change log using a dynamic change log table name
--
create or replace function public.insert_change_log()
returns trigger
language plpgsql
as $$
declare
    update_stmt text := 'insert into public.';
    record_json jsonb;
begin
    record_json = jsonb_build_object('new', to_jsonb(new), 'old', to_jsonb(old));
    update_stmt := format('insert into public.change_log_%I (record_id, operation_type, record_json, created_by) 
        values (%s, %L, %L, $1.%I)', TG_TABLE_NAME, new.id, TG_OP, record_json, 'updated_by');
    execute (update_stmt) using new;
    return null;
END;
$$;


-- crashes triggers
create trigger insert_change_log_crashes_cris
after insert or update on public.crashes_cris
for each row
execute procedure public.insert_change_log();

create trigger insert_change_log_crashes_edits
after insert or update on public.crashes_edits
for each row
execute procedure public.insert_change_log();

create trigger insert_change_log_crashes
after insert or update on public.crashes
for each row
execute procedure public.insert_change_log();

-- units triggers
create trigger insert_change_log_units_cris
after insert or update on public.units_cris
for each row
execute procedure public.insert_change_log();

create trigger insert_change_log_units_edits
after insert or update on public.units_edits
for each row
execute procedure public.insert_change_log();

create trigger insert_change_log_units
after insert or update on public.units
for each row
execute procedure public.insert_change_log();

-- people triggers
create trigger insert_change_log_people_cris
after insert or update on public.people_cris
for each row
execute procedure public.insert_change_log();

create trigger insert_change_log_people_edits
after insert or update on public.people_edits
for each row
execute procedure public.insert_change_log();

create trigger insert_change_log_people
after insert or update on public.people
for each row
execute procedure public.insert_change_log();

