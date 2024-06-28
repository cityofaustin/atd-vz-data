create table _column_metadata (
    id serial primary key,
    column_name text not null,
    column_label text not null,
    record_type text not null,
    is_imported_from_cris boolean not null default false
);
