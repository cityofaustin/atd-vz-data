drop table fatalities cascade;

drop view if exists fatalities_view cascade;

create or replace view fatalities_view AS
select 
people.id as person_id,
crashes.id as crash_id,
crashes.crash_id as cris_crash_id,
CONCAT_WS(' ', people.prsn_first_name, people.prsn_mid_name, people.prsn_last_name) as victim_name,
TO_CHAR(crashes.crash_timestamp at time zone 'US/Central', 'yyyy') AS year,
CONCAT_WS(' ',
  crashes.rpt_block_num,
  crashes.rpt_street_pfx,
  crashes.rpt_street_name,
  '(',
  crashes.rpt_sec_block_num,
  crashes.rpt_sec_street_pfx,
  crashes.rpt_sec_street_name,
  ')') AS location,
to_char(
  public.crashes.crash_timestamp at time zone 'US/Central', 'YYYY-MM-DD'
  ) as crash_date_ct,
to_char(
  public.crashes.crash_timestamp at time zone 'US/Central', 'HH24:MI:SS'
  ) as crash_time_ct,
-- get ytd fatality, partition by year and sort by date timestamp
ROW_NUMBER() OVER (
    PARTITION BY EXTRACT(year FROM crashes.crash_timestamp) 
    ORDER BY crashes.crash_timestamp ASC) 
    AS ytd_fatality,
-- get ytd fatal crash, partition by year and sort by date timestamp.
-- records with the same crash_id will get "tie" rankings thus making
-- this column count each crash rather than each fatality
DENSE_RANK() OVER (
    PARTITION BY EXTRACT(year FROM crashes.crash_timestamp) 
    ORDER BY crashes.crash_timestamp ASC, crashes.crash_id) 
    AS ytd_fatal_crash,
crashes.case_id,
crashes.law_enforcement_fatality_num,
engineering_areas.label as engineering_area
  from 
    people 
  left join units on people.unit_id = units.id
  left join crashes on units.crash_id = crashes.id
  left join engineering_areas ON engineering_areas.geometry && crashes.position AND ST_CONTAINS(engineering_areas.geometry, crashes.position)
 where crashes.in_austin_full_purpose = true AND people.prsn_injry_sev_id = 4;
