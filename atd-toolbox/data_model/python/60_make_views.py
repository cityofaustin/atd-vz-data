from utils import save_file, make_migration_dir
from settings import SCHEMA_NAME


def load_sql_template(name):
    with open(name, "r") as fin:
        return fin.read()


def main():
    # crashes list and injury metrics
    crashes_list_view_sql = load_sql_template("sql_templates/crashes_list_view.sql")
    migration_path = make_migration_dir("crashes_list_and_fatality_metrics_views")
    save_file(f"{migration_path}/up.sql", crashes_list_view_sql)
    save_file(
        f"{migration_path}/down.sql",
        "drop view public.person_injury_metrics_view cascade;",
    )
    # people list
    people_list_view_sql = load_sql_template("sql_templates/people_list_view.sql")
    migration_path = make_migration_dir("people_list_view")
    save_file(f"{migration_path}/up.sql", people_list_view_sql)
    save_file(
        f"{migration_path}/down.sql",
        "drop view public.people_list_view cascade;",
    )

    # crashes unified change log
    crashes_change_log_sql = load_sql_template("sql_templates/crashes_change_log_view.sql")
    migration_path = make_migration_dir("change_log_view")
    save_file(f"{migration_path}/up.sql", crashes_change_log_sql)
    save_file(f"{migration_path}/down.sql", "drop view if exists public.crashes_change_log_view cascade;")

main()
