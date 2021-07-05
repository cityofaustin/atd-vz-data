import { gql } from "apollo-boost";

export const GET_CRASH = gql`
  query FindCrash($crashId: Int) {
    atd_txdot_crashes(where: { crash_id: { _eq: $crashId } }) {
      active_school_zone_fl
      address_confirmed_primary
      address_confirmed_secondary
      apd_confirmed_fatality
      apd_confirmed_death_count
      apd_human_update
      approval_date
      approved_by
      at_intrsct_fl
      atd_fatality_count
      case_id
      city_id
      cr3_file_metadata
      cr3_stored_flag
      crash_date
      crash_fatal_fl
      crash_id
      crash_sev_id
      crash_speed_limit
      crash_time
      day_of_week
      death_cnt
      est_comp_cost
      est_comp_cost_crash_based
      est_econ_cost
      fhe_collsn_id
      geocode_method {
        name
      }
      geocode_date
      geocode_provider
      geocode_status
      geocoded
      hwy_nbr
      hwy_sfx
      hwy_sys
      hwy_sys_2
      intrsct_relat_id
      investigator_narrative_ocr
      is_retired
      last_update
      latitude
      latitude_primary
      latitude_geocoded
      light_cond_id
      longitude
      longitude_primary
      longitude_geocoded
      micromobility_device_flag
      non_injry_cnt
      nonincap_injry_cnt
      obj_struck_id
      onsys_fl
      poss_injry_cnt
      private_dr_fl
      qa_status
      road_constr_zone_fl
      road_type_id
      rpt_block_num
      rpt_city_id
      rpt_hwy_num
      rpt_latitude
      rpt_longitude
      rpt_outside_city_limit_fl
      rpt_rdwy_sys_id
      rpt_road_part_id
      rpt_sec_block_num
      rpt_sec_hwy_num
      rpt_sec_hwy_sfx
      rpt_sec_rdwy_sys_id
      rpt_sec_road_part_id
      rpt_sec_street_desc
      rpt_sec_street_name
      rpt_sec_street_pfx
      rpt_sec_street_sfx
      rpt_street_name
      rpt_street_pfx
      rpt_street_sfx
      rpt_street_desc
      rr_relat_fl
      schl_bus_fl
      speed_mgmt_points
      street_name
      street_name_2
      street_nbr
      street_nbr_2
      sus_serious_injry_cnt
      toll_road_fl
      tot_injry_cnt
      traffic_cntl_id
      unkn_injry_cnt
      updated_by
      wthr_cond_id
      location_id
      temp_record
    }
    atd_txdot_charges(where: { crash_id: { _eq: $crashId } }) {
      citation_nbr
      charge_cat_id
      charge
    }
    atd_txdot_change_log(
      where: { record_type: { _eq: "crashes" }, record_id: { _eq: $crashId } }
      order_by: { record_type: asc }
    ) {
      change_log_id
      record_id
      record_crash_id
      record_json
      update_timestamp
      updated_by
    }
  }
`;

export const UPDATE_COORDS = gql`
  mutation update_atd_txdot_crashes(
    $crashId: Int
    $qaStatus: Int
    $geocodeProvider: Int
    $latitude: float8
    $longitude: float8
    $updatedBy: String
  ) {
    update_atd_txdot_crashes(
      where: { crash_id: { _eq: $crashId } }
      _set: {
        qa_status: $qaStatus
        geocode_provider: $geocodeProvider
        latitude_primary: $latitude
        longitude_primary: $longitude
        updated_by: $updatedBy
      }
    ) {
      returning {
        crash_id
      }
    }
  }
`;

export const UPDATE_CRASH = gql`
  mutation update_atd_txdot_crashes(
    $crashId: Int
    $changes: atd_txdot_crashes_set_input
  ) {
    update_atd_txdot_crashes(
      where: { crash_id: { _eq: $crashId } }
      _set: $changes
    ) {
      affected_rows
      returning {
        active_school_zone_fl
        approval_date
        approved_by
        apd_confirmed_fatality
        apd_confirmed_death_count
        at_intrsct_fl
        atd_fatality_count
        case_id
        city_id
        crash_date
        crash_fatal_fl
        crash_id
        crash_sev_id
        crash_speed_limit
        crash_time
        day_of_week
        fhe_collsn_id
        geocode_date
        geocode_provider
        geocode_status
        geocoded
        hwy_nbr
        hwy_sfx
        hwy_sys
        hwy_sys_2
        intrsct_relat_id
        investigator_narrative
        is_retired
        last_update
        latitude
        latitude_primary
        latitude_geocoded
        light_cond_id
        longitude
        longitude_primary
        longitude_geocoded
        non_injry_cnt
        nonincap_injry_cnt
        obj_struck_id
        onsys_fl
        poss_injry_cnt
        private_dr_fl
        qa_status
        road_constr_zone_fl
        road_type_id
        rpt_block_num
        rpt_hwy_num
        rpt_latitude
        rpt_longitude
        rpt_outside_city_limit_fl
        rpt_rdwy_sys_id
        rpt_road_part_id
        rpt_sec_block_num
        rpt_sec_hwy_num
        rpt_sec_hwy_sfx
        rpt_sec_rdwy_sys_id
        rpt_sec_road_part_id
        rpt_sec_street_desc
        rpt_sec_street_name
        rpt_sec_street_pfx
        rpt_sec_street_sfx
        rpt_street_desc
        rpt_street_name
        rpt_street_pfx
        rpt_street_sfx
        rr_relat_fl
        schl_bus_fl
        street_name
        street_name_2
        street_nbr
        street_nbr_2
        sus_serious_injry_cnt
        toll_road_fl
        tot_injry_cnt
        traffic_cntl_id
        unkn_injry_cnt
        wthr_cond_id
        updated_by
      }
    }
  }
`;

export const crashQueryExportFields = `
crash_id
case_id
crash_date
crash_time
day_of_week
rpt_block_num
rpt_street_pfx
rpt_street_name
rpt_sec_block_num
rpt_sec_street_pfx
rpt_sec_street_name
est_comp_cost
est_comp_cost_crash_based
atd_fatality_count
sus_serious_injry_cnt
nonincap_injry_cnt
poss_injry_cnt
non_injry_cnt
unkn_injry_cnt
collision { collsn_desc }
units { travel_direction_desc { trvl_dir_desc } }
units { movement { movement_desc } }
units { body_style { veh_body_styl_desc } }
units { unit_description { veh_unit_desc_desc } }
light_cond_id
wthr_cond_id
active_school_zone_fl
schl_bus_fl
at_intrsct_fl
onsys_fl
private_dr_fl
traffic_cntl_id
road_constr_zone_fl
rr_relat_fl
toll_road_fl
intrsct_relat_id
obj_struck_id
latitude_primary
longitude_primary
crash_speed_limit
death_cnt
`;

export const locationCrashesQueryExportFieldsNonCR3 = `
form_id
location_id
case_id
longitude
latitude
date
hour
address
speed_mgmt_points
est_comp_cost
est_comp_cost_crash_based
est_econ_cost
`;
