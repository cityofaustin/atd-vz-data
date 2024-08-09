#!/usr/bin/env python
from utils import save_file, make_migration_dir, load_column_metadata


def load_sql_template(name):
    with open(name, "r") as fin:
        return fin.read()


def main():
    # translate our data model migration column metadata into the  db table structure
    columns = load_column_metadata()
    column_inserts = []
    for col in columns:
        is_imported_from_cris = (
            True
            if (col["source"] == "cris" or col["source"] == "etl")
            and col["is_cris_column"]
            else False
        )
        col_insert_sql = f"""insert into _column_metadata (column_name, record_type, is_imported_from_cris)
        values ('{col['column_name']}', '{col['record_type']}', {str(is_imported_from_cris).lower()})"""
        column_inserts.append(col_insert_sql)

    metadata_table_sql = load_sql_template("sql_templates/column_metadata_table.sql")
    col_insert_sql = ";\n".join(column_inserts)
    migration_sql = f"{metadata_table_sql}\n\n{col_insert_sql}"
    migration_path = make_migration_dir("column_metadata_table")
    save_file(f"{migration_path}/up.sql", migration_sql)
    save_file(
        f"{migration_path}/down.sql",
        "drop table if exists public._column_metadata cascade;",
    )


main()
