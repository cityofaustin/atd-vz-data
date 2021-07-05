-- Add a new column to the atd_apd_blueform table to hold crash based comprehensive cost
ALTER TABLE atd_apd_blueform ADD COLUMN est_comp_cost_crash_based numeric(10,2) default 10000;

-- Add a new column to the atd_txdot_crashes table to hold crash basaed comprehensive cost
ALTER TABLE atd_txdot_crashes ADD COLUMN est_comp_cost_crash_based numeric(10,2) default 0;

-- Reload Hasura Metadata
-- Grant editor INSERT, SELECT, and UPDATE permissions on the new fields in both tables.
-- Grant readonly SELECT on new fields in both tables.

-- Create a new table to house crash based comprehensive cost values, styled after atd_txdot__est_comp_cost
CREATE TABLE atd_txdot__est_comp_cost_crash_based(
  est_comp_cost_id serial primary key,
  est_comp_cost_desc character varying,
  est_comp_cost_amount numeric(10,2)
  );

-- Track table in Hasura
-- Grant editor and readonly SELECT permissions in hasura

-- Populate new crash based comprehensive cost table
INSERT INTO atd_txdot__est_comp_cost_crash_based (est_comp_cost_id, est_comp_cost_desc, est_comp_cost_amount) values (1, 'Killed (K)', 3000000);
INSERT INTO atd_txdot__est_comp_cost_crash_based (est_comp_cost_id, est_comp_cost_desc, est_comp_cost_amount) values (2, 'Suspected Serious Injury (A)', 2500000);
INSERT INTO atd_txdot__est_comp_cost_crash_based (est_comp_cost_id, est_comp_cost_desc, est_comp_cost_amount) values (3, 'Non-incapacitating Injury (B)', 270000);
INSERT INTO atd_txdot__est_comp_cost_crash_based (est_comp_cost_id, est_comp_cost_desc, est_comp_cost_amount) values (4, 'Possible Injury (C)', 220000);
INSERT INTO atd_txdot__est_comp_cost_crash_based (est_comp_cost_id, est_comp_cost_desc, est_comp_cost_amount) values (5, 'Not Injured', 50000);
INSERT INTO atd_txdot__est_comp_cost_crash_based (est_comp_cost_id, est_comp_cost_desc, est_comp_cost_amount) values (6, 'Unknown Injury (0)', 50000);
INSERT INTO atd_txdot__est_comp_cost_crash_based (est_comp_cost_id, est_comp_cost_desc, est_comp_cost_amount) values (7, 'Non-CR3', 10000);


-- To extend the atd_txdot_crashes_updates_audit_log() function, we must first drop the trigger which invokes it.
drop trigger if exists atd_txdot_crashes_audit_log on atd_txdot_crashes;

-- Augment the atd_txdot_crashes_update_audit_log() function to compute and store the crash based comprehensive cost
-- This updated version of the function is also found in atd-vzd/triggers/atd_txdot_crashes_updates_audit_log.sql
create or replace function atd_txdot_crashes_updates_audit_log() returns trigger
    language plpgsql
as
$$
DECLARE
    estCompCostList decimal(10,2)[];
    estCrashCompCostList decimal(10,2)[];
    estCompEconList decimal(10,2)[];
    speedMgmtList decimal(10,2)[];
BEGIN
    ------------------------------------------------------------------------------------------
    -- CHANGE-LOG OPERATIONS
    ------------------------------------------------------------------------------------------
    -- Stores a copy of the current record into the change log
    IF  (TG_OP = 'UPDATE') then
        INSERT INTO atd_txdot_change_log (record_id, record_crash_id, record_type, record_json, updated_by)
        VALUES (old.crash_id, old.crash_id, 'crashes', row_to_json(old), NEW.updated_by);
    END IF;

    -- COPIES THE CITY_ID INTO ORIGINAL_CITY_ID FOR BACKUP
    IF (TG_OP = 'INSERT') THEN
            NEW.original_city_id = NEW.city_id;
    END IF;

    ------------------------------------------------------------------------------------------
    -- LATITUDE / LONGITUDE OPERATIONS
    ------------------------------------------------------------------------------------------

    -- When CRIS is present, populate values to Primary column
    -- NOTE: It will update primary only if there is no lat/long data in the geo-coded or primary columns.
    -- If there is data in primary coordinates, then it will not do anything.
    -- If the there is geocoded data, it will not do anything.
    IF (
        (NEW.latitude is not null AND NEW.longitude is not null)
        AND (NEW.latitude_geocoded is null AND NEW.longitude_geocoded is null)
        AND (NEW.latitude_primary is null AND NEW.longitude_primary is null)
    ) THEN
        NEW.latitude_primary = NEW.latitude;
        NEW.longitude_primary = NEW.longitude;
    END IF;

    -- When GeoCoded lat/longs are present, populate value to Primary
    -- NOTE: It will only update if there are geocoded lat/longs and there are no primary lat/longs
    IF (
        (NEW.latitude_geocoded is not null AND NEW.longitude_geocoded is not null)
        AND (NEW.latitude_primary is null AND NEW.longitude_primary is null)
    ) THEN
        NEW.latitude_primary = NEW.latitude_geocoded;
        NEW.longitude_primary = NEW.longitude_geocoded;
    END IF;
    -- Finally we update the position field
    NEW.position = ST_SetSRID(ST_MakePoint(NEW.longitude_primary, NEW.latitude_primary), 4326);
    --- END OF LAT/LONG OPERATIONS ---


  ------------------------------------------------------------------------------------------
    -- CONFIRMED ADDRESSES
    ------------------------------------------------------------------------------------------

    -- If there is no confirmed primary address provided, then generate it:
    IF (NEW.address_confirmed_primary IS NULL) THEN
      NEW.address_confirmed_primary   = TRIM(CONCAT(NEW.rpt_street_pfx, ' ', NEW.rpt_block_num, ' ', NEW.rpt_street_name, ' ', NEW.rpt_street_sfx));
    END IF;
    -- If there is no confirmed secondary address provided, then generate it:
    IF (NEW.address_confirmed_secondary IS NULL) THEN
    NEW.address_confirmed_secondary = TRIM(CONCAT(NEW.rpt_sec_street_pfx, ' ', NEW.rpt_sec_block_num, ' ', NEW.rpt_sec_street_name, ' ', NEW.rpt_sec_street_sfx));
    END IF;
    --- END OF ADDRESS OPERATIONS ---

    ------------------------------------------------------------------------------------------
    -- APD's Death Count
    ------------------------------------------------------------------------------------------
    -- If our apd death count is null, then assume death_cnt's value
    IF (NEW.atd_fatality_count IS NULL) THEN
        NEW.atd_fatality_count = NEW.death_cnt;
  END IF;

    IF (NEW.apd_confirmed_death_count IS NULL) THEN
        NEW.apd_confirmed_death_count = NEW.death_cnt;
    -- Otherwise, the value has been entered manually, signal change with confirmed as 'Y'
    ELSE
        IF (NEW.apd_confirmed_death_count > 0) THEN
            NEW.apd_confirmed_fatality = 'Y';
        ELSE
            NEW.apd_confirmed_fatality = 'N';
        END IF;
    END IF;
    -- If the death count is any different from the original, then it is human-manipulated.
    IF (NEW.apd_confirmed_death_count = NEW.death_cnt) THEN
        NEW.apd_human_update = 'N';
    ELSE
        NEW.apd_human_update = 'Y';
    END IF;
    -- END OF APD's DEATH COUNT

    ------------------------------------------------------------------------------------------
    -- ESTIMATED COSTS
    ------------------------------------------------------------------------------------------

    -- First we need to gather a list of all of our costs, comprehensive and economic.
    estCompCostList = ARRAY(SELECT est_comp_cost_amount FROM atd_txdot__est_comp_cost ORDER BY est_comp_cost_id ASC);
    estCompCostListCrashBased = ARRAY(SELECT est_comp_cost_amount FROM atd_txdot__est_comp_cost_crash_based ORDER BY est_comp_cost_id ASC);
    estCompEconList = ARRAY(SELECT est_econ_cost_amount FROM atd_txdot__est_econ_cost ORDER BY est_econ_cost_id ASC);

    NEW.est_comp_cost = (0
       + (NEW.unkn_injry_cnt * (estCompCostList[1]))
       + (NEW.atd_fatality_count * (estCompCostList[2]))
       + (NEW.sus_serious_injry_cnt * (estCompCostList[3]))
       + (NEW.nonincap_injry_cnt * (estCompCostList[4]))
       + (NEW.poss_injry_cnt * (estCompCostList[5]))
       + (NEW.non_injry_cnt * (estCompCostList[6]))
   )::decimal(10,2);

    IF (NEW.atd_fatality_count > 0) THEN NEW.est_comp_cost_crash_based = estCompCostListCrashBased[1];
    ELSIF (NEW.sus_serious_injry_cnt > 0) THEN NEW.est_comp_cost_crash_based = estCompCostListCrashBased[2];
    ELSIF (NEW.nonincap_injry_cnt > 0) THEN NEW.est_comp_cost_crash_based = estCompCostListCrashBased[3];
    ELSIF (NEW.poss_injry_cnt > 0) THEN NEW.est_comp_cost_crash_based = estCompCostListCrashBased[4];
    ELSIF (NEW.non_injry_cnt > 0) THEN NEW.est_comp_cost_crash_based = estCompCostListCrashBased[5];
    ELSIF (NEW.unkn_injry_cnt > 0) THEN NEW.est_comp_cost_crash_based = estCompCostListCrashBased[6];
    ELSE NEW.est_comp_cost_crash_based = 0;
    END IF;

    NEW.est_econ_cost = (0
       + (NEW.unkn_injry_cnt * (estCompEconList[1]))
       + (NEW.atd_fatality_count * (estCompEconList[2]))
       + (NEW.sus_serious_injry_cnt * (estCompEconList[3]))
       + (NEW.nonincap_injry_cnt * (estCompEconList[4]))
       + (NEW.poss_injry_cnt * (estCompEconList[5]))
       + (NEW.non_injry_cnt * (estCompEconList[6]))
   )::decimal(10,2);

    --- END OF COST OPERATIONS ---

    ------------------------------------------------------------------------------------------
    -- SPEED MGMT POINTS
    ------------------------------------------------------------------------------------------
    speedMgmtList = ARRAY (SELECT speed_mgmt_points FROM atd_txdot__speed_mgmt_lkp ORDER BY speed_mgmt_id ASC);

  NEW.speed_mgmt_points = (0
    + (NEW.unkn_injry_cnt * (speedMgmtList [1]))
        + (NEW.atd_fatality_count * (speedMgmtList [2]))
        + (NEW.sus_serious_injry_cnt * (speedMgmtList [3]))
        + (NEW.nonincap_injry_cnt * (speedMgmtList [4]))
        + (NEW.poss_injry_cnt * (speedMgmtList [5]))
        + (NEW.non_injry_cnt * (speedMgmtList [6]))
    )::decimal (10,2);
    --- END OF SPEED MGMT POINTS ---

    ------------------------------------------------------------------------------------------
    -- MODE CATEGORY DATA
    ------------------------------------------------------------------------------------------
    NEW.atd_mode_category_metadata = get_crash_modes(NEW.crash_id);
    --- END OF MODE CATEGORY DATA ---

    -- Record the current timestamp
    NEW.last_update = current_timestamp;
    RETURN NEW;
END;
$$;

-- set ownership if needed
alter function atd_txdot_crashes_updates_audit_log() owner to atd_vz_data;

-- replace the trigger to invoke the function on upsert
create trigger atd_txdot_crashes_audit_log before insert or update on
    public.atd_txdot_crashes for each row execute function atd_txdot_crashes_updates_audit_log();

-- cause the function to be run for every row in the database
-- this takes ~5m on my dev database
update atd_txdot_crashes set est_comp_cost_crash_based = 1;


-- update view to use the crash based comprehensive cost values
-- This view is also found in atd-vzd/views/view_location_injry_count_cost_summary-schema.sql
CREATE or replace VIEW public.view_location_injry_count_cost_summary AS
SELECT
  atcloc.location_id::character varying (32) AS location_id,
  COALESCE(ccs.total_crashes, 0) + COALESCE(blueform_ccs.total_crashes, 0) AS total_crashes,
  COALESCE(ccs.total_deaths, 0::bigint) AS total_deaths,
  COALESCE(ccs.total_serious_injuries, 0::bigint) AS total_serious_injuries,
  (COALESCE(ccs.est_comp_cost, 0) + COALESCE(blueform_ccs.est_comp_cost, 0))::numeric AS est_comp_cost
FROM atd_txdot_locations atcloc
  LEFT JOIN (
    SELECT
      atc.location_id,
      count(1) AS total_crashes,
      sum(atc.death_cnt) AS total_deaths,
      sum(atc.sus_serious_injry_cnt) AS total_serious_injuries,
      sum(atc.est_comp_cost_crash_based) AS est_comp_cost
    FROM
      atd_txdot_crashes AS atc
  WHERE (1 = 1
    AND atc.crash_date > now() - '5 years'::interval
    AND(atc.location_id IS NOT NULL)
    AND((atc.location_id)::text <> 'None'::text))
  GROUP BY
    atc.location_id) ccs ON ccs.location_id::text = atcloc.location_id::text
  LEFT JOIN(
    SELECT
      aab.location_id,
      sum(aab.est_comp_cost_crash_based) AS est_comp_cost,
      count(1) AS total_crashes
    FROM
      atd_apd_blueform AS aab
    WHERE (1 = 1
      AND aab.date > now() - '5 years'::interval
      AND(aab.location_id IS NOT NULL)
      AND(aab.location_id::text <> 'None'::text))
    GROUP BY
      aab.location_id) blueform_ccs ON (blueform_ccs.location_id = atcloc.location_id)

-- set ownership if needed
ALTER TABLE public.view_location_injry_count_cost_summary OWNER TO atd_vz_data;

-- update view to use the crash based comprehensive cost values
-- This view is also found in atd-vzd/views/view_location_injry_count_cost_summary-schema.sql
CREATE OR REPLACE VIEW public.view_location_crashes_global
AS SELECT atc.crash_id,
    'CR3'::text AS type,
    atc.location_id,
    atc.case_id,
    atc.crash_date,
    atc.crash_time,
    atc.day_of_week,
    atc.crash_sev_id,
    atc.longitude_primary,
    atc.latitude_primary,
    atc.address_confirmed_primary,
    atc.address_confirmed_secondary,
    atc.non_injry_cnt,
    atc.nonincap_injry_cnt,
    atc.poss_injry_cnt,
    atc.sus_serious_injry_cnt,
    atc.tot_injry_cnt,
    atc.death_cnt,
    atc.unkn_injry_cnt,
    atc.est_comp_cost_crash_based as est_comp_cost,
    string_agg(atcl.collsn_desc::text, ','::text) AS collsn_desc,
    string_agg(attdl.trvl_dir_desc::text, ','::text) AS travel_direction,
    string_agg(atml.movement_desc::text, ','::text) AS movement_desc,
    string_agg(atvbsl.veh_body_styl_desc::text, ','::text) AS veh_body_styl_desc,
    string_agg(atvudl.veh_unit_desc_desc, ','::text) AS veh_unit_desc_desc
   FROM atd_txdot_crashes atc
     LEFT JOIN atd_txdot__collsn_lkp atcl ON atc.fhe_collsn_id = atcl.collsn_id
     LEFT JOIN atd_txdot_units atu ON atc.crash_id = atu.crash_id
     LEFT JOIN atd_txdot__trvl_dir_lkp attdl ON atu.travel_direction = attdl.trvl_dir_id
     LEFT JOIN atd_txdot__movt_lkp atml ON atu.movement_id = atml.movement_id
     LEFT JOIN atd_txdot__veh_body_styl_lkp atvbsl ON atu.veh_body_styl_id = atvbsl.veh_body_styl_id
     LEFT JOIN atd_txdot__veh_unit_desc_lkp atvudl ON atu.unit_desc_id = atvudl.veh_unit_desc_id
  WHERE atc.crash_date >= (now() - '5 years'::interval)::date
  GROUP BY atc.crash_id, atc.location_id, atc.case_id, atc.crash_date, atc.crash_time, atc.day_of_week, atc.crash_sev_id, atc.longitude_primary, atc.latitude_primary, atc.address_confirmed_primary, atc.address_confirmed_secondary, atc.non_injry_cnt, atc.nonincap_injry_cnt, atc.poss_injry_cnt, atc.sus_serious_injry_cnt, atc.tot_injry_cnt, atc.death_cnt, atc.unkn_injry_cnt, atc.est_comp_cost
UNION ALL
 SELECT aab.form_id AS crash_id,
    'NON-CR3'::text AS type,
    aab.location_id,
    aab.case_id::text AS case_id,
    aab.date AS crash_date,
    concat(aab.hour, ':00:00')::time without time zone AS crash_time,
    ( SELECT
                CASE date_part('dow'::text, aab.date)
                    WHEN 0 THEN 'SUN'::text
                    WHEN 1 THEN 'MON'::text
                    WHEN 2 THEN 'TUE'::text
                    WHEN 3 THEN 'WED'::text
                    WHEN 4 THEN 'THU'::text
                    WHEN 5 THEN 'FRI'::text
                    WHEN 6 THEN 'SAT'::text
                    ELSE 'Unknown'::text
                END AS "case") AS day_of_week,
    0 AS crash_sev_id,
    aab.longitude AS longitude_primary,
    aab.latitude AS latitude_primary,
    aab.address AS address_confirmed_primary,
    ''::text AS address_confirmed_secondary,
    0 AS non_injry_cnt,
    0 AS nonincap_injry_cnt,
    0 AS poss_injry_cnt,
    0 AS sus_serious_injry_cnt,
    0 AS tot_injry_cnt,
    0 AS death_cnt,
    0 AS unkn_injry_cnt,
    aab.est_comp_cost_crash_based as est_comp_cost,
    ''::text AS collsn_desc,
    ''::text AS travel_direction,
    ''::text AS movement_desc,
    ''::text AS veh_body_styl_desc,
    ''::text AS veh_unit_desc_desc
   FROM atd_apd_blueform aab
  WHERE aab.date >= (now() - '5 years'::interval)::date;

-- set ownership if needed
ALTER TABLE public.view_location_crashes_global OWNER TO atd_vz_data;

CREATE OR REPLACE FUNCTION public.get_location_totals(
  cr3_crash_date    date,
  noncr3_crash_date date,
  cr3_location      character varying,
  noncr3_location   character varying
  ) RETURNS SETOF atd_location_crash_and_cost_totals
 LANGUAGE sql STABLE
  AS $function$
WITH
  -- This CTE+join mechanism is a way to pack two, simple
  -- queries together into one larger query and compute
  -- derived results from their results.
  --
  -- In our first CTE, we'll count up the number of
  -- non-CR3 crashes and their sum of their comprehensive
  -- cost which are associated to a given location occuring
  -- after a given date.
  --
  -- All non-CR3 crashes are given a standard
  -- comprehensive cost, and this value is provided as
  -- an argument to this query.
  --
  -- An important thing to note is that this CTE query will
  -- only return a single row under any circumstances.
  noncr3 AS (
    SELECT COUNT(aab.case_id) AS total_crashes,
      COUNT(aab.case_id) *
        (select est_comp_cost_amount from atd_txdot__est_comp_cost_crash_based where est_comp_cost_id = 7)
      AS est_comp_cost
    FROM atd_apd_blueform aab
    WHERE aab.location_id = noncr3_location
      AND aab.date >= noncr3_crash_date
  ),
  -- A very similar query, again returning a single row,
  -- to compute the count and aggregate comprehensive cost
  -- for CR3 crashes.
  cr3 AS (
    SELECT COUNT(atc.crash_id) AS total_crashes,
      -- In the case of no CR3 crashes, the SUM() returns null,
      -- which in turn causes 'total_est_comp_cost' to be null
      -- in the main query, as INT + null = null.
      COALESCE(SUM(est_comp_cost_crash_based),0) AS est_comp_cost
    FROM atd_txdot_crashes atc
    WHERE atc.location_id = cr3_location
      AND atc.crash_date >= cr3_crash_date
  )
-- Add the two crash types respective values together to
-- get values for all crashes for the location. Also,
-- pass through the individual crash type values in the final
-- result.
SELECT cr3_location AS location_id,
       cr3.total_crashes + noncr3.total_crashes AS total_crashes,
       cr3.est_comp_cost + noncr3.est_comp_cost AS total_est_comp_cost,
       cr3.total_crashes AS cr3_total_crashes,
       cr3.est_comp_cost AS cr3_est_comp_cost,
       noncr3.total_crashes AS noncr3_total_crashes,
       noncr3.est_comp_cost AS noncr3_est_comp_cost
-- This is an implicit join of the two CTE tables. Because each
-- table is known to have only a single row, the result will also
-- be a single row, 1 * 1 = 1. This is why we have no need for a WHERE
-- clause, as we narroed down to the actual data we need in the CTEs.
-- Joining a table of a single row to another talbe of a single row
-- essentaily performs a concatenation of the two rows.
FROM noncr3, cr3
  $function$;

-- ensure this function is still tracked in Hasura
