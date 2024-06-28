from pprint import pprint as print

from utils import (
    make_migration_dir,
    save_file,
    save_empty_down_migration,
    load_lookups_metadata,
)


def escape_single_quotes(input_string):
    return input_string.replace("'", "''")


veh_direction_of_force_lkp_values = """insert into lookups.veh_direction_of_force_lkp (id, label)
    select veh_direction_of_force_id, veh_direction_of_force_desc from atd_txdot__veh_direction_of_force_lkp;"""

mode_category_lkp_values = """insert into lookups.mode_category_lkp (id, label)
    select  id, atd_mode_category_mode_name from atd__mode_category_lkp;"""

city_id_patch = """insert into lookups.city_lkp (id, label) values (9999, 'UNKNOWN');"""

injry_sev_lkp_custom_values = """alter table lookups.injry_sev_lkp add constraint injry_sev_owner_check check ((id < 99 and source = 'cris') or (id >= 99 and source = 'vz'));
insert into lookups.injry_sev_lkp (id, label, source) values (99, 'KILLED (NON-ATD)', 'vz');
alter table public.people_cris add constraint people_cris_prsn_injry_sev_id_check check (prsn_injry_sev_id < 99);
"""

unit_desc_lkp_custom_values = """alter table lookups.unit_desc_lkp add constraint unit_desc_owner_check check ((id < 177 and source = 'cris') or (id >= 177 and source = 'vz'));
insert into lookups.unit_desc_lkp (id, label, source) values (177, 'MICROMOBILITY DEVICE', 'vz');
alter table public.units_cris add constraint units_cris_unit_desc_id_check check (unit_desc_id < 177);
"""

veh_body_styl_lkp_custom_values = """alter table lookups.veh_body_styl_lkp add constraint veh_body_styl_lkp_owner_check check ((id < 177 and source = 'cris') or (id >= 177 and source = 'vz'));
insert into lookups.veh_body_styl_lkp (id, label, source) values (177, 'E-SCOOTER', 'vz');
alter table public.units_cris add constraint units_cris_veh_body_styl_id_check check (veh_body_styl_id < 177);
"""

movt_lkp_custom_values = """insert into lookups.movt_lkp (select *, 'vz' as source from atd_txdot__movt_lkp);"""


def main():
    print("downloading metadata from google sheet...")
    schema_name = "lookups"
    data = load_lookups_metadata()
    insert_stmts = []
    for row in data:
        stmt = f"insert into {schema_name}.{row['table_name']} (id, label, source) values ({row['id']}, '{escape_single_quotes(row['label'])}', '{row['source']}');"
        insert_stmts.append(stmt)
    # copy lookup table because it's not in the extract CSV lookup file
    insert_stmts.append(veh_direction_of_force_lkp_values)
    # copy lookup table because it's custom
    insert_stmts.append(mode_category_lkp_values)
    # adds backward compatibility to city ID 9999
    insert_stmts.append(city_id_patch)
    # add custom injry_sev_lkp values and constraint
    insert_stmts.append(injry_sev_lkp_custom_values)
    # add custom unit_desc_lkp values and constraint
    insert_stmts.append(unit_desc_lkp_custom_values)
    # add custom veh_body_styl_lkp values and constraint
    insert_stmts.append(veh_body_styl_lkp_custom_values)
    # add custom movement lookup table values
    insert_stmts.append(movt_lkp_custom_values)
    sql = "\n".join(insert_stmts)
    migration_path = make_migration_dir("lookup_table_seeds")
    save_file(f"{migration_path}/up.sql", sql)
    save_empty_down_migration(migration_path)


main()
