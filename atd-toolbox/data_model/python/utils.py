import json
from os import listdir, makedirs
from os.path import isfile, join
import shutil

from settings import MIGRATIONS_PATH, BASE_MIGRATION_ID


def save_file(fname, data):
    with open(fname, "w") as fout:
        fout.write(data)
        fout.write("\n")


def get_next_migration_id(interval=1000):
    migration_dirs = [
        f for f in listdir(MIGRATIONS_PATH) if not isfile(join(MIGRATIONS_PATH, f))
    ]
    migration_ids = [int(d.split("_")[0]) for d in migration_dirs]
    return max(migration_ids) + interval


def make_migration_dir(migration_name):
    migration_id = get_next_migration_id()
    migration_path = join(MIGRATIONS_PATH, f"{migration_id}_{migration_name}")
    makedirs(migration_path)
    return migration_path


def delete_all_migrations():
    for f in listdir(MIGRATIONS_PATH):
        f_path = join(MIGRATIONS_PATH, f)
        if not isfile(f_path):
            migration_id = int(f.split("_")[0])
            if migration_id > BASE_MIGRATION_ID:
                print(f"Deleting migration: {f_path}")
                shutil.rmtree(f_path)


def save_empty_down_migration(migration_path):
    save_file(f"{migration_path}/down.sql", "select 0;")


def load_column_metadata(path="column_metadata.json"):
    with open(path, "r") as fin:
        return json.load(fin)


def load_lookups_metadata(path="lookup_table_metadata.json"):
    with open(path, "r") as fin:
        return json.load(fin)
