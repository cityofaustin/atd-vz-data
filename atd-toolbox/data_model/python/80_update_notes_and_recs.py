from utils import save_file, make_migration_dir

def load_sql_template(name):
    with open(name, "r") as fin:
        return fin.read()

def main():
    recommendations_and_notes_sql_up = load_sql_template("sql_templates/recommendations_and_notes_up.sql")
    recommendations_and_notes_sql_down = load_sql_template("sql_templates/recommendations_and_notes_down.sql")
    migration_path = make_migration_dir("update_recommendations_and_notes_fks")
    save_file(f"{migration_path}/up.sql", recommendations_and_notes_sql_up)
    save_file(f"{migration_path}/down.sql", recommendations_and_notes_sql_down)

main()
