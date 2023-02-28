#!/usr/bin/env python3

import os
import psycopg2
import psycopg2.extras
import datetime
from dotenv import load_dotenv

load_dotenv("env")

DB_HOST = os.getenv("DB_HOST")
DB_USER = os.getenv("DB_USER")
DB_PASS = os.getenv("DB_PASS")
DB_NAME = os.getenv("DB_NAME")
DB_SSL_REQUIREMENT = os.getenv("DB_SSL_REQUIREMENT")

def main():
    # compute_for_crashes()
    compute_for_units()

def values_for_sql(values):
    strings = []
    for value in values:
        # print(value, type(value))
        # print(value, isinstance(value, datetime.datetime))
        if isinstance(value, str):
            strings.append(f"'{value}'")
        elif isinstance(value, datetime.date):
            strings.append(f"'{str(value)}'")
        elif isinstance(value, datetime.datetime):
            strings.append(f"'{str(value)}'")
        elif value is None:
            strings.append("null")
        else:
            strings.append(f"{str(value)}")
    return strings

def get_pg_connection():
    """
    Returns a connection to the Postgres database
    """
    return psycopg2.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASS,
        dbname=DB_NAME,
        sslmode=DB_SSL_REQUIREMENT,
        sslrootcert="/root/rds-combined-ca-bundle.pem",
    )


def compute_for_crashes():
    pg = get_pg_connection()
    cris_cursor = pg.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    public_cursor = pg.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    vz_cursor = pg.cursor(cursor_factory=psycopg2.extras.RealDictCursor)

    vz_cursor.execute('truncate vz.atd_txdot_crashes')
    pg.commit()

    sql = "select * from cris.atd_txdot_crashes order by crash_id asc"
    cris_cursor.execute(sql)
    for cris in cris_cursor:
        # This is for focusing in on a single record (debugging)
        # if cris["crash_id"] != 18793962:
            # continue

        # 18793962 This is a real crash in CRIS that is not in the VZDB, see issue #11589

        # this is for skipping a record.
        if cris["crash_id"] in [18793962, 18793971, 18793991, 18794003, 18797160, 18797724, 18797777,
                                18797885, 18798007, 18798181, 18798658, 18798663, 18798665, 18798669,
                                18798674, 18798682, 18798684, 18798686, 18798687, 18798689, 18798722,
                                18799005, 18799077, 18799692, 18799731, 18799736, 18799744, 18799747,
                                18799748, 18799786, 18799788, 18799789, 18799792, 18800047, 18800089,
                                18800099, 18800109, 18800119, 18800163, 18800201, 18800202, 18800203,
                                18800242, 18800280, 18800417, 18800418, 18800419, 18800420, 18800421,
                                18800425, 18800426, 18800427, 18800428, 18800432, 18800434, 18800436,
                                18800438, 18800448, 18800449, 18800452, 18800453, 18800454, 18800457,
                                18800494, 18800506, 18800580, 18800611, 18800681, 18800801, 18800891,
                                18800894, 18800895, 18801054, 18801077, 18801115, 18801120, 18801169,
                                18801170, 18801230, 18801288]:
            continue


        print()
        print("CRIS: ", cris["crash_id"])
        sql = "select * from public.atd_txdot_crashes where crash_id = %s"
        public_cursor.execute(sql, (cris["crash_id"],))
        public = public_cursor.fetchone()
        # print("public: ", public["crash_id"])
        keys = ["crash_id"]
        values = [cris["crash_id"]]
        for k, v in cris.items():
            if (k in ('crash_id')): # use to define fields to ignore
                continue
            if v != public[k]:
                # print("Δ ", k, ": ", public[k], " → ", v)
                keys.append(k)
                values.append(v)
        comma_linefeed = ",\n            "
        sql = f"""
        insert into vz.atd_txdot_crashes (
            {comma_linefeed.join(keys)}
        ) values (
            {comma_linefeed.join(values_for_sql(values))}
        );
        """
        # print(sql)
        try:
            vz_cursor.execute(sql)
            pg.commit()
        except:
            print("keys: ", keys)
            print("values: ", values)
            print("ERROR: ", sql)
            quit()
        print("Inserted: ", cris["crash_id"])
        # input("Press Enter to continue...")


def compute_for_units():
    pg = get_pg_connection()
    cris_cursor = pg.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    public_cursor = pg.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    vz_cursor = pg.cursor(cursor_factory=psycopg2.extras.RealDictCursor)

    vz_cursor.execute('truncate vz.atd_txdot_units')
    pg.commit()

    sql = "select * from cris.atd_txdot_units order by crash_id asc, unit_nbr asc"
    cris_cursor.execute(sql)
    for cris in cris_cursor:
        # if cris["crash_id"] != 15359065:
            # continue

        # This is a special case where CRIS reports a third unit where there is none.
        # It needs to be handled here because we have manually removed that crash from the VZDB.
        if cris["crash_id"] == 15359065 and cris["unit_nbr"] == 3:
            continue

        # print()
        # print("Crash ID: ", cris["crash_id"], "; Unit Number: ", cris["unit_nbr"])
        sql = "select * from public.atd_txdot_units where crash_id = %s and unit_nbr = %s"
        public_cursor.execute(sql, (cris["crash_id"], cris["unit_nbr"]))
        public = public_cursor.fetchone()
        # print("public: ", public)
        keys = ["crash_id", "unit_nbr"]
        values = [cris["crash_id"], cris["unit_nbr"]]
        for k, v in cris.items():
            if (k in ('crash_id', 'unit_nbr')): # use to define fields to ignore
                continue
            # print(k, v, public[k])
            if v != public[k]:
                # print("Δ ", k, ": ", public[k], " → ", v)
                keys.append(k)
                values.append(v)
        comma_linefeed = ",\n            "
        sql = f"""
        insert into vz.atd_txdot_units (
            {comma_linefeed.join(keys)}
        ) values (
            {comma_linefeed.join(values_for_sql(values))}
        );
        """
        # print(sql)
        try:
            vz_cursor.execute(sql)
            pg.commit()
        except:
            print("keys: ", keys)
            print("values: ", values)
            print("ERROR: ", sql)
            quit()
        print("Inserted: crash_id: ", cris["crash_id"], "; unit_nbr: ", cris["unit_nbr"])
        # input("Press Enter to continue...")


def compute_for_person():
    pg = get_pg_connection()
    cris_cursor = pg.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    public_cursor = pg.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    vz_cursor = pg.cursor(cursor_factory=psycopg2.extras.RealDictCursor)

    vz_cursor.execute('truncate vz.atd_txdot_person')
    pg.commit()

    sql = "select * from cris.atd_txdot_person order by crash_id asc, unit_nbr asc, prsn_nbr asc, prsn_type_id asc, prsn_occpnt_pos_id asc"
    cris_cursor.execute(sql)
    for cris in cris_cursor:
        # if cris["crash_id"] != 14866997:
            # continue
        # print()
        # print("Crash ID: ", cris["crash_id"], "; Unit Number: ", cris["unit_nbr"], "; Person Number: ", cris["prsn_nbr"], "; Person Type ID: ", cris["prsn_type_id"], "; Person Occupant Position ID: ", cris["prsn_occpnt_pos_id"])
        sql = "select * from public.atd_txdot_person where crash_id = %s and unit_nbr = %s"
        public_cursor.execute(sql, (cris["crash_id"], cris["unit_nbr"]))
        public = public_cursor.fetchone()
        keys = ["crash_id", "unit_nbr", "prsn_nbr", "prsn_type_id", "prsn_occpnt_pos_id"]
        values = [cris["crash_id"], cris["unit_nbr"], cris["prsn_nbr"], cris["prsn_type_id"], cris["prsn_occpnt_pos_id"]]
        for k, v in cris.items():
            if (k in ('crash_id', 'unit_nbr', 'prsn_nbr', 'prsn_type_id', 'prsn_occpnt_pos_id')): # use to define fields to ignore
                continue
            if v != public[k]:
                # print("Δ ", k, ": ", public[k], " → ", v)
                keys.append(k)
                values.append(v)
        comma_linefeed = ",\n            "
        sql = f"""
        insert into vz.atd_txdot_person (
            {comma_linefeed.join(keys)}
        ) values (
            {comma_linefeed.join(values_for_sql(values))}
        );
        """
        # print(sql)
        try:
            vz_cursor.execute(sql)
            pg.commit()
        except:
            print("keys: ", keys)
            print("values: ", values)
            print("ERROR: ", sql)
            quit()
        print("Inserted: crash_id: ", cris["crash_id"], "; Unit Number: ", cris["unit_nbr"], "; Person Number: ", cris["prsn_nbr"], "; Person Type ID: ", cris["prsn_type_id"], "; Person Occupant Position ID: ", cris["prsn_occpnt_pos_id"])
        # input("Press Enter to continue...")

def compute_for_primaryperson():
    pg = get_pg_connection()
    cris_cursor = pg.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    public_cursor = pg.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    vz_cursor = pg.cursor(cursor_factory=psycopg2.extras.RealDictCursor)

    vz_cursor.execute('truncate vz.atd_txdot_primaryperson')
    pg.commit()

    sql = "select * from cris.atd_txdot_primaryperson order by crash_id asc, unit_nbr asc, prsn_nbr asc, prsn_type_id asc, prsn_occpnt_pos_id asc"
    cris_cursor.execute(sql)
    for cris in cris_cursor:
        # if cris["crash_id"] != 14866997:
            # continue
        # print()
        # print("Crash ID: ", cris["crash_id"], "; Unit Number: ", cris["unit_nbr"], "; Person Number: ", cris["prsn_nbr"], "; Person Type ID: ", cris["prsn_type_id"], "; Person Occupant Position ID: ", cris["prsn_occpnt_pos_id"])
        sql = "select * from public.atd_txdot_primaryperson where crash_id = %s and unit_nbr = %s and prsn_nbr = %s and prsn_type_id = %s and prsn_occpnt_pos_id = %s"
        public_cursor.execute(sql, (cris["crash_id"], cris["unit_nbr"], cris["prsn_nbr"], cris["prsn_type_id"], cris["prsn_occpnt_pos_id"] ))
        public = public_cursor.fetchone()
        keys = ["crash_id", "unit_nbr", "prsn_nbr", "prsn_type_id", "prsn_occpnt_pos_id"]
        values = [cris["crash_id"], cris["unit_nbr"], cris["prsn_nbr"], cris["prsn_type_id"], cris["prsn_occpnt_pos_id"]]
        for k, v in cris.items():
            if (k in ('crash_id', 'unit_nbr', 'prsn_nbr', 'prsn_type_id', 'prsn_occpnt_pos_id')): # use to define fields to ignore
                continue
            if v != public[k]:
                # print("Δ ", k, ": ", public[k], " → ", v)
                keys.append(k)
                values.append(v)
        comma_linefeed = ",\n            "
        sql = f"""
        insert into vz.atd_txdot_primaryperson (
            {comma_linefeed.join(keys)}
        ) values (
            {comma_linefeed.join(values_for_sql(values))}
        );
        """
        # print(sql)
        try:
            vz_cursor.execute(sql)
            pg.commit()
        except:
            print("keys: ", keys)
            print("values: ", values)
            print("ERROR: ", sql)
            quit()
        print("Inserted: crash_id: ", cris["crash_id"], "; Unit Number: ", cris["unit_nbr"], "; Person Number: ", cris["prsn_nbr"], "; Person Type ID: ", cris["prsn_type_id"], "; Person Occupant Position ID: ", cris["prsn_occpnt_pos_id"])
        # input("Press Enter to continue...")



if __name__ == "__main__":
    main()