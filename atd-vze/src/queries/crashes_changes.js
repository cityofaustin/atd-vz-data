import { gql } from "apollo-boost";

export const GET_CRASH_CHANGE = gql`
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
            case_id
            city_id
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
        }
        atd_txdot_changes(where: {record_type: {_eq: "crash"}, record_id: {_eq: $crashId}}) {
            change_id
            record_id
            created_timestamp
            record_type
            status {
                description
            }
            status_id
            record_json
        }
    }
`;
