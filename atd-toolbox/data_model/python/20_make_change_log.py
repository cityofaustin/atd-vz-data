import csv
import io
from pprint import pprint as print

import requests

from utils import make_migration_dir, save_file, save_empty_down_migration
from settings import SCHEMA_NAME


def load_sql_template(name):
    with open(name, "r") as fin:
        return fin.read()


def main():
    sql_template = load_sql_template("./sql_templates/change_log_table.sql")
    sql_strs_up = []
    sql_strs_down = []
    for table_name in ["crashes", "units", "people"]:
        sql_strs_up.append(
            f"""---
--- {table_name} change log tables
---"""
        )
        for table_suffix in ["_cris", "_edits", ""]:
            if table_name == "charges" and table_suffix != "cris":
                # charges is a cris-only table
                continue
            id_col_name = "id"
            table_name_full = f"{table_name}{table_suffix}"
            sql_up = sql_template.replace("$tableName$", table_name_full).replace(
                "$idColName$", id_col_name
            )
            sql_strs_up.append(sql_up)
            sql_down = f"drop table {SCHEMA_NAME}.change_log_{table_name_full} cascade;"
            sql_strs_down.append(sql_down)

    # load the triggers
    sql_template = load_sql_template("./sql_templates/change_log_triggers.sql")
    sql_strs_up.append(sql_template)
    migration_path = make_migration_dir("change_log")
    save_file(f"{migration_path}/up.sql", "\n\n".join(sql_strs_up))
    save_file(f"{migration_path}/down.sql", "\n\n".join(sql_strs_down))


main()
