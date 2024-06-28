import { gql } from "apollo-boost";

export const GET_CRASH_OLD = gql`
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
      law_enforcement_num
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

export const GET_CRASH = gql`
  query CrashDetails($crashId: Int!) {
    crashes(where: { crash_id: { _eq: $crashId } }) {
      id
      crash_id
      updated_at
      case_id
      crash_timestamp
      fhe_collsn_id
      rpt_city_id
      light_cond_id
      wthr_cond_id
      obj_struck_id
      crash_speed_limit
      traffic_cntl_id
      address_primary
      rpt_block_num
      rpt_street_name
      rpt_street_desc
      rpt_road_part_id
      rpt_rdwy_sys_id
      rpt_hwy_num
      rpt_street_pfx
      rpt_street_name
      rpt_street_sfx
      address_secondary
      rpt_sec_block_num
      rpt_sec_street_name
      rpt_sec_street_desc
      rpt_sec_road_part_id
      rpt_sec_rdwy_sys_id
      rpt_sec_hwy_num
      rpt_sec_street_pfx
      rpt_sec_street_sfx
      active_school_zone_fl
      at_intrsct_fl
      onsys_fl
      private_dr_fl
      road_constr_zone_fl
      rr_relat_fl
      schl_bus_fl
      toll_road_fl
      law_enforcement_fatality_num
      investigator_narrative
      cr3_stored_flag
      cr3_file_metadata
      latitude
      longitude
      location_id
      crash_injury_metrics_view {
        vz_fatality_count
        sus_serious_injry_count
        years_of_life_lost
        est_comp_cost_crash_based
        crash_injry_sev_id
        nonincap_injry_count
        sus_serious_injry_count
        cris_fatality_count
        law_enf_fatality_count
      }
      units {
        id
        unit_nbr
        veh_mod_year
        unit_desc_lkp {
          id
          label
        }
        veh_body_styl_lkp {
          id
          label
        }
        veh_make_lkp {
          id
          label
        }
        veh_mod_lkp {
          id
          label
        }
        trvl_dir_lkp {
          id
          label
        }
        movt_lkp {
          id
          label
        }
        contrib_factr_lkp {
          id
          label
        }
        unit_injury_metrics_view {
          vz_fatality_count
          sus_serious_injry_count
        }
      }
      people_list_view {
        crash_id
        id
        unit_nbr
        is_primary_person
        prsn_age
        drvr_city_name
        drvr_zip
        prsn_exp_homelessness
        prsn_first_name
        prsn_mid_name
        prsn_last_name
        injry_sev_lkp {
          id
          label
        }
        prsn_type_lkp {
          id
          label
        }
        gndr_lkp {
          id
          label
        }
        drvr_ethncty_lkp {
          id
          label
        }
      }
      charges_cris {
        unit_nbr
        prsn_nbr
        citation_nbr
        charge_cat_id
        charge
      }
      crashes_list_view {
        crash_day_of_week
        is_manual_geocode
      }
      change_logs(order_by: { created_at: desc }) {
        id
        crash_id
        created_at
        created_by
        operation_type
        record_id
        record_type
        record_json
      }
    }
  }
`;

export const UPDATE_CRASH = gql`
  mutation update_crashes_edits($id: Int!, $changes: crashes_edits_set_input) {
    update_crashes_edits(where: { id: { _eq: $id } }, _set: $changes) {
      affected_rows
      returning {
        crash_id
      }
    }
  }
`;

export const crashQueryExportFields = `
crash_id
case_id
crash_timestamp
crash_day_of_week
rpt_block_num
rpt_street_pfx
rpt_street_name
rpt_sec_block_num
rpt_sec_street_pfx
rpt_sec_street_name
est_comp_cost_crash_based
vz_fatality_count
sus_serious_injry_count
nonincap_injry_count
poss_injry_count
non_injry_count
unkn_injry_count
crash_injry_sev_desc
collsn_desc
units {
  trvl_dir_lkp {
    label
  }
  movt_lkp {
    label
  }
  veh_body_styl_lkp {
    label
  }
  unit_desc_lkp {
    label
  }
}
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
latitude
longitude
crash_speed_limit
cris_fatality_count
recommendation {
  rec_text
}
recommendation {
  rec_update
}
recommendation {
  atd__recommendation_status_lkp {
    rec_status_desc
  }
}
recommendation {
  recommendations_partners {
    atd__coordination_partners_lkp {
      coord_partner_desc
    }
  }
}
council_district
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
