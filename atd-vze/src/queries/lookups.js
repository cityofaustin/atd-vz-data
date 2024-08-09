import { gql } from "apollo-boost";

export const GET_LOOKUPS = gql`
  {
    lookups_city_lkp {
      id
      label
    }
    lookups_collsn_lkp {
      id
      label
    }
    lookups_light_cond_lkp {
      id
      label
    }
    lookups_injry_sev_lkp {
      id
      label
    }
    lookups_obj_struck_lkp {
      id
      label
    }
    lookups_road_part_lkp {
      id
      label
    }
    lookups_rwy_sys_lkp {
      id
      label
    }
    lookups_traffic_cntl_lkp {
      id
      label
    }
    lookups_wthr_cond_lkp {
      id
      label
    }
  }
`;

export const GET_UNIT_LOOKUPS = gql`
  {
    lookups_trvl_dir_lkp {
      id
      label
    }
    lookups_unit_desc_lkp {
      id
      label
    }
    lookups_veh_body_styl_lkp {
      id
      label
    }
    lookups_movt_lkp {
      id
      label
    }
  }
`;

export const GET_PERSON_LOOKUPS = gql`
  {
    lookups_injry_sev_lkp {
      id
      label
    }
    lookups_drvr_ethncty_lkp {
      id
      label
    }
    lookups_gndr_lkp {
      id
      label
    }
  }
`;
