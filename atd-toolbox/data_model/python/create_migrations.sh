#!/bin/bash
# ------------
# Helper to run the migration codegen
# 
# Before you run this you should apply all down migrations,
# including and down to the 'create_schema' migration
# this script can be run multiple times without issue.
# ------------
set -e

./05_pre_table_triggers.py
./10_make_core_tables.py
./20_make_change_log.py
./30_make_triggers.py
./40_make_lookup_seeds.py
./45_alter_units_vz_mode_category.py
./50_add_indexes.py
./60_make_views.py
./70_make_column_metadata_table.py
./80_update_notes_and_recs.py
./90_fatalities_view.py
