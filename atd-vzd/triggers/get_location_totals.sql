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
