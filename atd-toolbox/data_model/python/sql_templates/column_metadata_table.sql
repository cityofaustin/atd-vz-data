create table _column_metadata (
    id serial primary key,
    column_name text not null,
    record_type text not null,
    is_imported_from_cris boolean not null default false,
    UNIQUE (column_name, record_type)
);

comment on table _column_metadata is 'Table which tracks column metadata for crashes, units, people, and charges records. Is the used by CRIS import to determine which fields will be processed/upserted.';
comment on column _column_metadata.column_name is 'The name of the column in the db';
comment on column _column_metadata.record_type is 'The type of record tables associated with this colum: crashes/units/people/charges';
comment on column _column_metadata.is_imported_from_cris is 'If this column is populated via the CRIS import ETL';
