create or replace view locations_with_crash_injury_counts as
  with crashes as (
    with cris_crashes as ( -- think of this as step 1a of the query
      -- build up data about cris crashes, aggregated by location_id, which have a location and are in the date interval.
      -- select a certain form of the results to later union with blueform crashes.
      select
        crashes.location_id,
        count(crashes.crash_id) as crash_count,
        coalesce(sum(crashes.est_comp_cost_crash_based),0) total_est_comp_cost,
        coalesce(sum(crashes.death_cnt),0) as fatality_count,
        coalesce(sum(crashes.sus_serious_injry_cnt),0) as suspected_serious_injury_count 
      from atd_txdot_crashes crashes
      where true
        and location_id is not null
        and crashes.crash_date > (now() - interval '5 year')
      group by crashes.location_id 
      ), 
    apd_crashes as ( -- think of this as step 1b of the query, happening at the same time as step 1a
      -- build up data about blueform crashes, aggregated by location_id, which have a location and are in the date interval.
      -- select a certain form of the results to later union with cris crashes.
      select
        crashes.location_id,
        count(crashes.case_id) as crash_count,
        coalesce(sum(crashes.est_comp_cost),0) as total_est_comp_cost,
        0 as fatality_count,
        0 as suspected_serious_injury_count 
      from atd_apd_blueform crashes
      where true
        and location_id is not null
        and crashes.date > (now() - interval '5 year')
      group by crashes.location_id 
      )
    -- use the two sets of crashes above to build up a set of locations with crash counts and injury counts.
    select  -- think of this as step 2 of the query
      cris_crashes.location_id,
      cris_crashes.crash_count + apd_crashes.crash_count as crash_count,
      cris_crashes.total_est_comp_cost + (10000 * apd_crashes.crash_count) as total_est_comp_cost,
      cris_crashes.fatality_count + apd_crashes.fatality_count as fatalities_count,
      cris_crashes.suspected_serious_injury_count + apd_crashes.suspected_serious_injury_count as serious_injury_count
    from cris_crashes
    -- this unions the sets, over location_id, such that a location is represented if it has either/or/and a cris and blueform crash(s).
    full outer join apd_crashes
      on (cris_crashes.location_id = apd_crashes.location_id)
    )
  -- finally, this is a list of locations after all, so query them and join the crash data we've built up.
  select -- think of this as step 3
    locations.description,
    locations.location_id,
    coalesce(crashes.crash_count, 0) as crash_count, -- graphql abstract makes dealing with nulls difficult, so coalesce to 0.
    coalesce(crashes.total_est_comp_cost, 0) as total_est_comp_cost,
    coalesce(crashes.fatalities_count, 0) as fatalities_count,
    coalesce(crashes.serious_injury_count, 0) as serious_injury_count
  from atd_txdot_locations locations
  left join crashes on (locations.location_id = crashes.location_id)
  where true 
    -- the criteria for being in the list at all, so we limit down the number of locations we're dealing with.
    and locations.council_district > 0
    and location_group = 1
