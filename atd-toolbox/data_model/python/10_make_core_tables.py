#!/usr/bin/env python
from pprint import pprint as print

from settings import SCHEMA_NAME

from utils import (
    make_migration_dir,
    save_file,
    save_empty_down_migration,
    load_column_metadata,
)


def load_sql_template(name):
    with open(name, "r") as fin:
        return fin.read()


def get_lookup_table_names(columns):
    """Extract lookup table names from column data"""
    lookup_table_names = [
        f"{col['foreign_table_schema']}.{col['foreign_table_name']}"
        for col in columns
        if col["foreign_table_name"]
        and not col["foreign_table_name"].endswith("_cris")
        and not col["foreign_table_name"].endswith("_edits")
        and not col["foreign_table_name"] == "crashes"
        and not col["foreign_table_name"] == "units"
        and not col["foreign_table_name"] == "people"
        and not col["is_existing_foreign_table"]
    ]
    return sorted(list(set(lookup_table_names)))


def make_lookup_table_sql(table_names):
    create_table_stmts = []
    for table_name in table_names:
        sql = f"create table {table_name} (\n    id integer primary key,\n    label text not null,\n    source text not null default 'cris'\n);"
        create_table_stmts.append(sql)
    return "\n\n".join(create_table_stmts)


def make_column_sql(columns, full_table_name):
    sql_parts = []
    for col in columns:
        column_name = col["column_name"]
        data_type = col["data_type"]
        constraint = col["data_type_constraint"]
        fk_table_name = col["foreign_table_name"]
        fk_cascade = col["foreign_column_cascade"]
        fk_column_name = col["foreign_column_name"]
        fk_schema_name = col["foreign_table_schema"] or "public"
        if constraint == "primary key" and not full_table_name.endswith("_cris"):
            # hacky logic to manage id sequences and pks on the _edits and unified tables
            if data_type == "serial":
                data_type = "integer"
            if full_table_name.endswith("_edits"):
                fk_table_name = full_table_name.replace("_edits", "_cris")
            elif full_table_name == "crashes":
                fk_table_name = "crashes_cris"
            # column name is always the same as the column name
            fk_column_name = column_name
            fk_cascade = "on update cascade on delete cascade"
        elif column_name == "crash_pk":
            if full_table_name == "units_edits":
                # make nullable
                constraint = ""
                # reference units_cris
                fk_table_name = "crashes_cris"
            elif full_table_name == "units":
                fk_table_name = "crashes"
        elif column_name == "cris_crash_id":
            if full_table_name == "units":
                fk_table_name = "crashes"
        elif column_name == "unit_id":
            if full_table_name == "people_edits":
                # make nullable
                constraint = ""
                # reference units_cris
                fk_table_name = "units_cris"
            elif full_table_name == "people":
                fk_table_name = "units"
            fk_cascade = "on update cascade on delete cascade"
        elif column_name == "people_id":
            if full_table_name == "charges_edits":
                # reference units_cris
                # make nullable
                constraint = ""
                fk_table_name = "charges_cris"
            elif full_table_name == "charges":
                fk_table_name = "people"
            fk_cascade = "on update cascade on delete cascade"
        elif constraint and "not null default false" in constraint and "_edits" in full_table_name:
            constraint = ""

        sql = f"{column_name} {data_type} {constraint}".strip()
        if fk_table_name:
            sql = f"{sql} references {fk_schema_name}.{fk_table_name} ({fk_column_name}) {fk_cascade}"
        sql_parts.append(sql)
    return ",\n    ".join(sql_parts)


def main():
    all_columns = load_column_metadata()
    # init the schema
    migration_path = make_migration_dir("create_schema")
    save_file(
        f"{migration_path}/up.sql",
        f"create schema if not exists lookups;",
    )
    save_file(
        f"{migration_path}/down.sql",
        f"drop schema if exists lookups cascade;",
    )
    # lookup tables
    lookup_table_names = get_lookup_table_names(all_columns)
    lookup_tables_sql = make_lookup_table_sql(lookup_table_names)
    migration_path = make_migration_dir("lookups")
    save_file(f"{migration_path}/up.sql", lookup_tables_sql)
    # we don't write down migrations for each lookup table—we drop the whole lookups schema
    save_empty_down_migration(migration_path)
    for table_name in ["crashes", "units", "people", "charges"]:
        tables_sql_stmts = []
        table_sql_down_stmts = []
        for table_suffix in ["_cris", "_edits", ""]:
            if table_name == "charges" and table_suffix != "_cris":
                # charges is a cris-only table
                continue
            column_table_key = f"is{table_suffix or '_unified'}_column"
            full_table_name = f"{table_name}{table_suffix}"
            this_table_columns = [
                col
                for col in all_columns
                if col[column_table_key] and col["record_type"] == table_name
            ]
            # sort primary key first, then by column name
            this_table_columns = sorted(
                this_table_columns,
                key=lambda col: (
                    "a" if col["is_primary_key"] else "b",
                    col["column_name"],
                ),
            )
            unique_cols = set()
            # dedupe columns, which is only needed for primary/person tables
            this_table_columns = [
                c
                for c in this_table_columns
                if not (
                    c["column_name"] in unique_cols or unique_cols.add(c["column_name"])
                )
            ]
            column_sql_str = make_column_sql(this_table_columns, full_table_name)
            table_sql_str = f"create table {SCHEMA_NAME}.{full_table_name} (\n    {column_sql_str}\n);"
            tables_sql_stmts.append(table_sql_str)
            table_sql_down_stmts.append(
                f"drop table {SCHEMA_NAME}.{full_table_name} cascade;"
            )
        tables_sql_str = "\n\n".join(tables_sql_stmts)
        table_sql_down_str = "\n\n".join(table_sql_down_stmts)
        migration_path = make_migration_dir(table_name)
        save_file(f"{migration_path}/up.sql", tables_sql_str)
        save_file(f"{migration_path}/down.sql", table_sql_down_str)

    table_constraints_sql = load_sql_template("./sql_templates/table_constraints.sql")
    migration_path = make_migration_dir("table_constraints")
    save_file(f"{migration_path}/up.sql", table_constraints_sql)
    save_empty_down_migration(migration_path)


main()
