create table public.change_log_$tableName$ (
    id serial primary key,
    record_id integer not null references public.$tableName$ ($idColName$) on delete cascade on update cascade,
    operation_type text not null,
    record_json jsonb not null,
    created_at timestamp with time zone default now(),
    created_by text not null
);

create index on public.change_log_$tableName$ (record_id);
