import { gql } from "apollo-boost";

export const GET_LOOKUPS = gql`
  {
    lookups_city {
      id
      label
    }
    lookups_collsn {
      id
      label
    }
    lookups_light_cond {
      id
      label
    }
    lookups_injry_sev {
      id
      label
    }
    lookups_obj_struck {
      id
      label
    }
    lookups_road_part {
      id
      label
    }
    lookups_rwy_sys {
      id
      label
    }
    lookups_traffic_cntl {
      id
      label
    }
    lookups_wthr_cond {
      id
      label
    }
  }
`;

export const GET_UNIT_LOOKUPS = gql`
  {
    lookups_trvl_dir {
      id
      label
    }
    lookups_unit_desc {
      id
      label
    }
    lookups_veh_body_styl {
      id
      label
    }
    lookups_movt {
      id
      label
    }
  }
`;

export const GET_PERSON_LOOKUPS = gql`
  {
    lookups_injry_sev {
      id
      label
    }
    lookups_drvr_ethncty {
      id
      label
    }
    lookups_gndr {
      id
      label
    }
  }
`;
