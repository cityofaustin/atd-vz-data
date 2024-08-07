#!/usr/bin/env python
from utils import save_file, make_migration_dir, save_empty_down_migration, delete_all_migrations


def load_sql_template(name):
    with open(name, "r") as fin:
        return fin.read()


def main():
    delete_all_migrations()
    indexes_sql = load_sql_template("sql_templates/build_address_trigger.sql")
    migration_path = make_migration_dir("address_trigger")
    save_file(f"{migration_path}/up.sql", indexes_sql)
    save_empty_down_migration(migration_path)


main()
