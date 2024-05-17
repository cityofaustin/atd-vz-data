import { gql } from "apollo-boost";

export const GET_UNITS = gql`
  query FindUnits($crashId: Int!) {
    units(where: { crash_id: { _eq: $crashId } }) {
      id
      unit_nbr
      veh_mod_year
      unit_desc_lkp {
        label
      }
      veh_body_styl_lkp {
        label
      }
      veh_make_lkp {
        label
      }
      veh_mod_lkp {
        label
      }
      trvl_dir_lkp {
        label
      }
      movt_lkp {
        label
      }
      contrib_factr_lkp {
        label
      }
      unit_injury_metrics_view {
        vz_fatality_count
        sus_serious_injry_count
      }
    }
  }
`;

export const GET_UNITS_OLD = gql`
  query FindUnits($crashId: Int) {
    atd_txdot_units(where: { crash_id: { _eq: $crashId } }) {
      unit_desc_id
      unit_nbr
      contributing_factor_1 {
        contrib_factr_desc
      }
      veh_make_id
      veh_mod_id
      veh_mod_year
      travel_direction_desc {
        trvl_dir_desc
        trvl_dir_id
      }
      movement {
        movement_desc
        movement_id
      }
      unit_description {
        veh_unit_desc_id
        veh_unit_desc_desc
      }
      make {
        veh_make_desc
      }
      model {
        veh_mod_desc
      }
      body_style {
        veh_body_styl_id
        veh_body_styl_desc
      }
      death_cnt
      sus_serious_injry_cnt
    }
  }
`;

export const UPDATE_UNIT_OLD = gql`
  mutation UpdateUnits(
    $crashId: Int
    $unitId: Int
    $changes: atd_txdot_units_set_input
  ) {
    update_atd_txdot_units(
      where: {
        crash_id: { _eq: $crashId }
        _and: { unit_nbr: { _eq: $unitId } }
      }
      _set: $changes
    ) {
      affected_rows
      returning {
        crash_id
        unit_id
        unit_nbr
        movement_id
        death_cnt
        sus_serious_injry_cnt
        travel_direction
      }
    }
  }
`;

export const UPDATE_UNIT = gql`
  mutation UpdateUnits(
    $crashId: Int!
    $unitId: Int!
    $changes: units_edits_set_input
  ) {
    update_units_edits_by_pk(pk_columns: { id: $unitId }, _set: $changes) {
      affected_rows
      returning {
        crash_id
        id
        unit_nbr
        movement_id
        veh_trvl_dir_id
      }
    }
  }
`;
