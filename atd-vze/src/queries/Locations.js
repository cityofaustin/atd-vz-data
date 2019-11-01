import { gql } from "apollo-boost";

export const GET_LOCATION = gql`
  query GetLocation($id: String) {
    atd_txdot_locations(where: { location_id: { _eq: $id } }) {
      location_id
      address
      asmp_street_level
      description
      shape
      latitude
      longitude
      metadata
      last_update
      is_retired
      crashes_by_manner_collision(order_by: { count: desc }, limit: 5) {
        collsn_desc
        count
      }
      crashes_count_cost_summary {
        est_comp_cost
      }
    }
    atd_txdot_crashes_aggregate(
      where: {
        city_id: { _eq: 22 }
        location: { location_id: { _eq: $id } }
        private_dr_fl: { _neq: "Y" }
      }
    ) {
      aggregate {
        count
        sum {
          apd_confirmed_death_count
        }
      }
    }
    atd_txdot_primaryperson_aggregate(
      where: {
        crash: {
          city_id: { _eq: 22 }
          location: { location_id: { _eq: $id } }
          private_dr_fl: { _neq: "Y" }
        }
      }
    ) {
      aggregate {
        count
        sum {
          sus_serious_injry_cnt
          years_of_life_lost
        }
      }
    }
    atd_txdot_person_aggregate(
      where: {
        crash: {
          city_id: { _eq: 22 }
          location: { location_id: { _eq: $id } }
          private_dr_fl: { _neq: "Y" }
        }
      }
    ) {
      aggregate {
        count
        sum {
          sus_serious_injry_cnt
          years_of_life_lost
        }
      }
    }
    atd_txdot_units_aggregate(
      where: {
        crash: {
          city_id: { _eq: 22 }
          location: { location_id: { _eq: $id } }
          private_dr_fl: { _neq: "Y" }
        }
      }
    ) {
      aggregate {
        count
      }
    }
    atd_txdot_locations(where: { location_id: { _eq: $id } }) {
      crashes_by_veh_body_style {
        veh_body_styl_desc
        count
      }
    }
  }
`;

export const UPDATE_LOCATION = gql`
  mutation update_atd_txdot_locations(
    $locationId: Int
    $changes: atd_txdot_locations_set_input
  ) {
    update_atd_txdot_locations(
      where: { location_id: { _eq: $locationId } }
      _set: $changes
    ) {
      affected_rows
    }
  }
`;

export const UPDATE_LOCATION_POLYGON = gql`
  mutation UpdateLocation($locationId: String, $updatedPolygon: geometry!) {
    update_atd_txdot_locations(
      where: { location_id: { _eq: $locationId } }
      _set: { shape: $updatedPolygon }
    ) {
      returning {
        shape
      }
    }
  }
`;

export const locationQueryExportFields = `
location_id
description
crashes_count_cost_summary { total_crashes }
crashes_count_cost_summary { total_deaths }
crashes_count_cost_summary { total_serious_injuries }
crashes_count_cost_summary { est_comp_cost }
`;
