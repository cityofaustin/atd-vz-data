#!/usr/bin/env python

import csv
import re
import argparse


def read_and_group_csv(file_path):
    """
    Returns a dict where each key is the lookup table name and the value
    is a dict of all the lookup ids/descs for that lookup table
    """
    grouped_data = {}

    with open(file_path, newline="") as csvfile:
        csvreader = csv.reader(csvfile, delimiter=",", quotechar='"')

        # Skip the first row (header)
        next(csvreader)

        for row in csvreader:
            id_name = row[0]
            name = re.search(r"(^.*)_ID$", id_name)
            name_component = name.group(1).lower()
            table_name = name_component + "_lkp"

            if table_name not in grouped_data:
                grouped_data[table_name] = {}

            grouped_data[table_name][int(row[1])] = row[2]

    return grouped_data


# Warn the user if we have any typos in the needed tables list or for some reason tables that aren't in the extract at all
def check_if_needed_tables_in_extract(needed_lkp_tables, extract_data):
    print(
        "Checking if all tables in needed tables list can be found in the extract...\n"
    )
    tables_not_found_in_extract = []
    for table in needed_lkp_tables:
        if table not in list(extract_data.keys()):
            tables_not_found_in_extract.append(table)
    if len(tables_not_found_in_extract) > 0:
        print(
            "WARNING: The following tables were not found in the extract. Double check the list for mistakes or typos.\n"
        )
        print(tables_not_found_in_extract, "\n")
        if (
            input("Do you want to continue and generate migration files? [y/n]\n")
            != "y"
        ):
            quit()


def escape_single_quotes(input_string):
    return input_string.replace("'", "''")


def new_table(name):
    return f"""
    create table db.{name} (
        id integer primary key,
        label text not null
    );
    """


def main(file_path):
    # Group the lkp extract into a dict of dicts
    extract_data = read_and_group_csv(file_path)

    # This is our current list of lkp_tables to add
    needed_lkp_tables = [
        "agency_lkp",
        "autonomous_level_engaged_lkp",
        "autonomous_unit_lkp",
        "city_lkp",
        "cnty_lkp",
        "collsn_lkp",
        "contrib_factr_lkp",
        "drvr_ethncty_lkp",
        "e_scooter_lkp",
        "gndr_lkp",
        "harm_evnt_lkp",
        "helmet_lkp",
        "injry_sev_lkp",
        "intrsct_relat_lkp",
        "light_cond_lkp",
        "movt_lkp",
        "obj_struck_lkp",
        "occpnt_pos_lkp",
        "pbcat_pedalcyclist_lkp",
        "pbcat_pedestrian_lkp",
        "pedalcyclist_action_lkp",
        "pedestrian_action_lkp",
        "prsn_type_lkp",
        "rest_lkp",
        "road_part_lkp",
        "rwy_sys_lkp",
        "specimen_type_lkp",
        "substnc_cat_lkp",
        "substnc_tst_result_lkp",
        "surf_cond_lkp",
        "surf_type_lkp",
        "traffic_cntl_lkp",
        "trvl_dir_lkp",
        "unit_desc_lkp",
        "veh_body_styl_lkp",
        "veh_damage_description_lkp",
        "veh_damage_severity_lkp",
        "veh_direction_of_force_lkp",
        "veh_make_lkp",
        "veh_mod_lkp",
        "wthr_cond_lkp",
    ]

    changes = []
    down_changes = []

    check_if_needed_tables_in_extract(needed_lkp_tables, extract_data)

    for table in extract_data:
        if table in needed_lkp_tables:
            extract_table_dict = extract_data[table]
            changes.append(f"\n-- Adding table {table}")
            changes.append(new_table(table))
            down_changes.append(f"\n-- Dropping table {table}")
            new_table_down = f"drop table if exists db.{table};"
            down_changes.append(new_table_down)
            for key in extract_table_dict:
                insert = f"insert into db.{table} (id, label) values ({str(key)}, '{escape_single_quotes(extract_table_dict[key])}');"
                changes.append(insert)

    outfile = open("up_migration.sql", "w")
    outfile.write("\n".join(changes).strip())
    outfile.close()

    outfile_down = open("down_migration.sql", "w")
    outfile_down.write("\n".join(down_changes).strip())
    outfile_down.close()


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", help="extract file path")
    args = parser.parse_args()
    file_path = args.input

    main(file_path)
