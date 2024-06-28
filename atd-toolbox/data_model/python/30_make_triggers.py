from utils import (
    save_file,
    make_migration_dir,
    save_empty_down_migration,
    load_column_metadata,
)


def load_sql_template(name):
    with open(name, "r") as fin:
        return fin.read()


def patch_template(template, table_name, pk_column_name, columns_unified):
    affected_columns_with_new_prefix = [f"new.{col}" for col in columns_unified]

    return (
        template.replace("$tableName$", table_name)
        .replace("$pkColumnName$", pk_column_name)
        .replace("$affectedColumns$", ", ".join(columns_unified))
        .replace(
            "$affectedColumnsWithNewPrefix$",
            ", ".join(affected_columns_with_new_prefix),
        )
    )


def main():
    all_columns = load_column_metadata()

    # create audit field columns and triggers
    audit_field_sql = load_sql_template("sql_templates/audit_fields.sql")
    migration_path = make_migration_dir("audit_fields")
    save_file(f"{migration_path}/up.sql", audit_field_sql)
    save_empty_down_migration(migration_path)

    # triggers that fire on CRIS insert
    insert_template = load_sql_template(
        "sql_templates/cris_insert_trigger_template.sql"
    )

    stmts = []
    for table_name in ["crashes", "units", "people"]:
        columns_unified = [
            col["column_name"]
            for col in all_columns
            if col["is_cris_column"]
            and col["is_unified_column"]
            and col["record_type"] == table_name
        ]
        # remove dupes, which is a concern for persons tables
        columns_unified = list(set(columns_unified))
        # sort columns to keep diffs consistent
        columns_unified.sort()
        # add audit fields
        columns_unified.extend(["created_by", "updated_by"])
        pk_column = "id"
        sql = patch_template(insert_template, table_name, pk_column, columns_unified)
        stmts.append(sql)

    migration_path = make_migration_dir("cris_insert_triggers")
    save_file(f"{migration_path}/up.sql", "\n\n".join(stmts))
    save_empty_down_migration(migration_path)

    # triggers that fire on CRIS update
    update_template = load_sql_template(
        "sql_templates/cris_update_trigger_template.sql"
    )

    stmts = []
    for table_name in ["crashes", "units", "people"]:
        pk_column = "id"
        sql = patch_template(update_template, table_name, pk_column, [])
        stmts.append(sql)

    migration_path = make_migration_dir("cris_update_triggers")
    save_file(f"{migration_path}/up.sql", "\n\n".join(stmts))
    save_empty_down_migration(migration_path)

    # triggers that fire on _edits update
    update_template = load_sql_template(
        "sql_templates/edits_update_trigger_template.sql"
    )

    stmts = []
    for table_name in ["crashes", "units", "people"]:
        pk_column = "id"
        sql = patch_template(update_template, table_name, pk_column, [])
        stmts.append(sql)

    migration_path = make_migration_dir("edits_update_triggers")
    save_file(f"{migration_path}/up.sql", "\n\n".join(stmts))
    save_empty_down_migration(migration_path)

    # trigger that assigns crash ID to unit records
    units_set_crash_id_sql = load_sql_template("sql_templates/unit_set_crash_id.sql")
    migration_path = make_migration_dir("units_set_crash_id")
    save_file(f"{migration_path}/up.sql", units_set_crash_id_sql)
    save_empty_down_migration(migration_path)

    # trigger that assigns unit ID to person records
    people_set_unit_id_sql = load_sql_template("sql_templates/people_set_unit_id.sql")
    migration_path = make_migration_dir("people_set_unit_id")
    save_file(f"{migration_path}/up.sql", people_set_unit_id_sql)
    save_empty_down_migration(migration_path)

    # trigger that assigns person ID to charges records
    people_set_unit_id_sql = load_sql_template(
        "sql_templates/charges_set_person_id.sql"
    )
    migration_path = make_migration_dir("charges_set_person_id")
    save_file(f"{migration_path}/up.sql", people_set_unit_id_sql)
    save_empty_down_migration(migration_path)

    # trigger that assigns location ID to unified crashes
    location_trigger_sql = load_sql_template(
        "sql_templates/crash_reference_layer_triggers.sql"
    )
    migration_path = make_migration_dir("crash_reference_layer_triggers")
    save_file(f"{migration_path}/up.sql", location_trigger_sql)
    save_empty_down_migration(migration_path)


main()
