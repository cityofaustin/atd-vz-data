#!/usr/bin/env python
from utils import save_file, make_migration_dir

def load_sql_template(name):
    with open(name, "r") as fin:
        return fin.read()

def main():
    sql_up = load_sql_template("sql_templates/vz_mode_category_generated_up.sql")
    sql_down = load_sql_template("sql_templates/vz_mode_category_generated_down.sql")
    migration_path = make_migration_dir("alter_units_vz_mode_category")
    save_file(f"{migration_path}/up.sql", sql_up)
    save_file(f"{migration_path}/down.sql", sql_down)

main()
