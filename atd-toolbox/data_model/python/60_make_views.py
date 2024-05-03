from utils import save_file, make_migration_dir, save_empty_down_migration


def load_sql_template(name):
    with open(name, "r") as fin:
        return fin.read()


def main():
    # crashes list
    crashes_list_view_sql = load_sql_template("sql_templates/crashes_list_view.sql")
    migration_path = make_migration_dir("views")
    save_file(f"{migration_path}/up.sql", crashes_list_view_sql)
    save_empty_down_migration(migration_path)


main()
