import { gql } from "apollo-boost";

export const GET_LOCATION = gql`
  query GetLocation($id: String!) {
    location: atd_txdot_locations_by_pk(location_id: $id) {
      location_id
      street_level
      description
      geometry
      latitude
      longitude
      last_update
      location_notes {
        id
        created_at
        date
        location_id
        text
        updated_at
        user_email
      }
      crashes_by_manner_collision(order_by: { count: desc }, limit: 5) {
        collsn_desc
        count
      }
      locationTotals: locations_list_view {
        crash_count
        total_est_comp_cost
      }
    }
  }
`;

export const UPDATE_LOCATION = gql`
  mutation update_atd_txdot_locations(
    $locationId: String
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
      _set: { geometry: $updatedPolygon }
    ) {
      returning {
        geometry
      }
    }
  }
`;

export const locationQueryExportFields = `
location_id
description
crash_count
fatalities_count
serious_injury_count
total_est_comp_cost
`;
