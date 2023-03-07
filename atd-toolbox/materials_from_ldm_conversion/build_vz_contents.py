#!/usr/bin/env python3

import re
import os
import json
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
    # compute_for_crashes() # this works - save the 80 missing crashes..
    # compute_for_units() # this works - save for the 164 missing units and the one special case
    # compute_for_person() # this works - save for the 85 missing persons
    compute_for_primaryperson() # this works - save for the 151 missing primary persons

def values_for_sql(values):
    strings = []
    for value in values:
        # print(value, type(value))
        # print(value, isinstance(value, datetime.datetime))
        if isinstance(value, str):
            value = re.sub("'", "''", value)
            strings.append(f"'{value}'")
        elif isinstance(value, list):
            strings.append(f"'{json.dumps(value)}'")
        elif isinstance(value, dict):
            strings.append(f"'{json.dumps(value)}'")
        elif isinstance(value, datetime.date):
            strings.append(f"'{str(value)}'")
        elif isinstance(value, datetime.datetime):
            strings.append(f"'{str(value)}'")
        elif isinstance(value, datetime.time):
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

        # where crash_id > 18793000
        # where crash_id = 16558169
    sql = """
        select * from cris.atd_txdot_crashes 
        order by crash_id asc
        """
    cris_cursor.execute(sql)
    for cris in cris_cursor:
        # This is for focusing in on a single record (debugging)
        #if cris["crash_id"] != 16558169:
            #continue

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
            # if k == 'position':
                # print ("cris position:   ", v)
                # print ("public position: ", public[k])

            if v != public[k]:
                # print("Δ ", k, ": ", public[k], " → ", v)
                keys.append(k)
                values.append(public[k])
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
        print("Inserted: ", cris["crash_id"])
        # input("Press Enter to continue...")


def compute_for_units():
    pg = get_pg_connection()
    cris_cursor = pg.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    public_cursor = pg.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    vz_cursor = pg.cursor(cursor_factory=psycopg2.extras.RealDictCursor)

    vz_cursor.execute('truncate vz.atd_txdot_units')
    pg.commit()

        # where cris.atd_txdot_units.crash_id > 19102309
    sql = """
        select * 
        from cris.atd_txdot_units 
        order by crash_id asc, unit_nbr asc
        """
    cris_cursor.execute(sql)
    for cris in cris_cursor:
        if cris["unit_id"] in [
550786, 606478, 550789, 606911, 570287, 571706, 571472, 604059, 573408, 555937,
550808, 550809, 571838, 550812, 550813, 559891, 608136, 571792, 559892, 550815,
555958, 555959, 555946, 555945, 571374, 571891, 571937, 606100, 571913, 571938,
555904, 571856, 571942, 608388, 571941, 547006, 547007, 570431, 571949, 571951,
571950, 555963, 555962, 555967, 609681, 571957, 571947, 610638, 550823, 604886,
550829, 559599, 571980, 555867, 555511, 550822, 571982, 571981, 571983, 546984,
571984, 571985, 560992, 573628, 571990, 571991, 571971, 571993, 571996, 571997,
571995, 571998, 561112, 561117, 561113, 561118, 561119, 572003, 572005, 572009,
572006, 572010, 572014, 555971, 572018, 572019, 572021, 572020, 572022, 572023,
572024, 572025, 547016, 606913, 572028, 550825, 555964, 561068, 555973, 555974,
572008, 609061, 572034, 569859, 571463, 570545, 570865, 572037, 572038, 547012,
572011, 572040, 555943, 550835, 550838, 572002, 550843, 550842, 550847, 550846,
572030, 550849, 550848, 550851, 555519, 550850, 607526, 550853, 572045, 572046,
550824, 555977, 555982, 555987, 604061, 573740, 572053, 572054, 568470, 550856,
572056, 572057, 572059, 555979, 546991, 572060, 572066, 572065, 572068, 555988,
572069, 608477, 603256, 572072, 605480, 572074, 606369, 610945, 572075, 605808,
572012, 572076, 550864, 572051]:
            continue

        # if cris["crash_id"] != 18793787:
            # continue

        # This is a special case where CRIS reports a third unit where there is none.
        # It needs to be handled here because we have manually removed that crash from the VZDB.
        if cris["crash_id"] == 15359065 and cris["unit_nbr"] == 3:
            continue

        print()
        print("Crash ID: ", cris["crash_id"], "; Unit Number: ", cris["unit_nbr"])
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
                values.append(public[k])
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
        print("Inserted: crash_id: ", cris["crash_id"], "; unit_nbr: ", cris["unit_nbr"])
        # input("Press Enter to continue...")


def compute_for_person():
    pg = get_pg_connection()
    cris_cursor = pg.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    public_cursor = pg.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    vz_cursor = pg.cursor(cursor_factory=psycopg2.extras.RealDictCursor)

    vz_cursor.execute('truncate vz.atd_txdot_person')
    pg.commit()

    # where crash_id > 15352872
    sql = """
        select * 
        from cris.atd_txdot_person 
        order by 
            crash_id asc, 
            unit_nbr asc, 
            prsn_nbr asc, 
            prsn_type_id asc, 
            prsn_occpnt_pos_id asc
        """
    cris_cursor.execute(sql)
    for cris in cris_cursor:
        # if cris["crash_id"] != 14866997:
            # continue

        if cris["person_id"] in [
                72097, 195570, 197412, 197432, 197528, 197537, 197538, 197539, 197540, 197542,
                197543, 197544, 197563, 197564, 197565, 197566, 197567, 197568, 197569, 197571,
                197572, 197574, 197575, 197576, 197577, 197578, 197579, 197580, 197581, 197601,
                197602, 197603, 197604, 197607, 197608, 197609, 197610, 197611, 197612, 197613,
                197618, 197619, 197622, 197623, 197626, 197627, 197628, 197629, 197630, 197631,
                197633, 197634, 197635, 197636, 197638, 197639, 197640, 197644, 197645, 197646,
                197647, 197648, 197649, 197650, 197652, 197653, 197654, 197655, 197660, 197666,
                197667, 197668, 197669, 197670, 197671, 197672, 197673, 197674, 197675, 197676,
                197677, 197678, 197679, 197680, 215050
                ]:
            continue

        print()
        print("Crash ID: ", cris["crash_id"], "; Unit Number: ", cris["unit_nbr"], "; Person Number: ", cris["prsn_nbr"], "; Person Type ID: ", cris["prsn_type_id"], "; Person Occupant Position ID: ", cris["prsn_occpnt_pos_id"])
        sql = "select * from public.atd_txdot_person where crash_id = %s and unit_nbr = %s and prsn_nbr = %s and prsn_type_id = %s and prsn_occpnt_pos_id = %s"
        print(sql)
        public_cursor.execute(sql, (cris["crash_id"], cris["unit_nbr"], cris["prsn_nbr"], cris["prsn_type_id"], cris["prsn_occpnt_pos_id"]))
        public = public_cursor.fetchone()
        keys =  [ "crash_id", "unit_nbr", "prsn_nbr", "prsn_type_id", "prsn_occpnt_pos_id"]
        values = [cris["crash_id"], cris["unit_nbr"], cris["prsn_nbr"], cris["prsn_type_id"], cris["prsn_occpnt_pos_id"]]
        for k, v in cris.items():
            if (k in ('crash_id', 'unit_nbr', 'prsn_nbr', 'prsn_type_id', 'prsn_occpnt_pos_id', 'years_of_life_lost')): # use to define fields to ignore
                continue
            if v != public[k]:
                # print("Δ ", k, ": ", public[k], " → ", v)
                keys.append(k)
                values.append(public[k])
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
        print("Inserted: crash_id: ", cris["crash_id"], "; Unit Number: ", cris["unit_nbr"], "; Person Number: ", cris["prsn_nbr"], "; Person Type ID: ", cris["prsn_type_id"], "; Person Occupant Position ID: ", cris["prsn_occpnt_pos_id"])
        # input("Press Enter to continue...")

def compute_for_primaryperson():
    pg = get_pg_connection()
    cris_cursor = pg.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    public_cursor = pg.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    vz_cursor = pg.cursor(cursor_factory=psycopg2.extras.RealDictCursor)

    vz_cursor.execute('truncate vz.atd_txdot_primaryperson')
    pg.commit()

    # where crash_id = 17998493
    sql = """
    select * 
    from cris.atd_txdot_primaryperson 
    order by crash_id asc, unit_nbr asc, prsn_nbr asc, prsn_type_id asc, prsn_occpnt_pos_id asc
    """
    cris_cursor.execute(sql)
    for cris in cris_cursor:
        # if cris["crash_id"] != 14866997:
            # continue
        
        if cris["primaryperson_id"] in [
                511631, 512326, 512328, 513047, 513303, 513320, 513325, 514207, 514210, 514461,
                515409, 515418, 515642, 515645, 516726, 516840, 516841, 516842, 517488, 518064,
                518067, 518069, 518071, 518072, 518073, 519371, 519372, 519373, 519376, 519558,
                520475, 520767, 520768, 520771, 520773, 520774, 520775, 520776, 520777, 520778,
                520779, 522026, 522035, 522036, 523325, 523326, 523328, 523329, 523334, 524413,
                524415, 525572, 525577, 525578, 526646, 527591, 527778, 529965, 529966, 529967,
                530718, 530719, 530720, 530721, 531986, 531987, 531990, 531991, 531993, 531994,
                531995, 532001, 532002, 532010, 532657, 534170, 534171, 534175, 534176, 537659,
                538573, 538575, 539828, 539829, 539830, 539835, 539836, 539839, 539840, 539841,
                539842, 539843, 539844, 539852, 540630, 540631, 540632, 540633, 540636, 540637,
                540846, 541074, 541202, 541203, 552025, 552044, 552061, 552062, 552247, 552248,
                552249, 552250, 552251, 552261, 552284, 552290, 552291, 552301, 552302, 552303,
                552304, 552305, 552306, 552307, 552311, 552312, 552313, 552314, 552315, 552316,
                552317, 552318, 552323, 552324, 552325, 552326, 552327, 552328, 552329, 552333,
                552335, 552337, 552338, 552339, 552340, 552341, 552342, 552343, 565557, 566525,
                569618
                ]:
            continue

        print()
        print("Crash ID: ", cris["crash_id"], "; Unit Number: ", cris["unit_nbr"], "; Person Number: ", cris["prsn_nbr"], "; Person Type ID: ", cris["prsn_type_id"], "; Person Occupant Position ID: ", cris["prsn_occpnt_pos_id"])
        sql = "select * from public.atd_txdot_primaryperson where crash_id = %s and unit_nbr = %s and prsn_nbr = %s and prsn_type_id = %s and prsn_occpnt_pos_id = %s"
        public_cursor.execute(sql, (cris["crash_id"], cris["unit_nbr"], cris["prsn_nbr"], cris["prsn_type_id"], cris["prsn_occpnt_pos_id"] ))
        public = public_cursor.fetchone()
        keys = ["crash_id", "unit_nbr", "prsn_nbr", "prsn_type_id", "prsn_occpnt_pos_id"]
        values = [cris["crash_id"], cris["unit_nbr"], cris["prsn_nbr"], cris["prsn_type_id"], cris["prsn_occpnt_pos_id"]]
        for k, v in cris.items():
            if (k in ('crash_id', 'unit_nbr', 'prsn_nbr', 'prsn_type_id', 'prsn_occpnt_pos_id', 'years_of_life_lost')): # use to define fields to ignore
                continue
            if v != public[k]:
                # print("Δ ", k, ": ", public[k], " → ", v)
                keys.append(k)
                values.append(public[k])
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
        print("Inserted: crash_id: ", cris["crash_id"], "; Unit Number: ", cris["unit_nbr"], "; Person Number: ", cris["prsn_nbr"], "; Person Type ID: ", cris["prsn_type_id"], "; Person Occupant Position ID: ", cris["prsn_occpnt_pos_id"])
        # input("Press Enter to continue...")



if __name__ == "__main__":
    main()