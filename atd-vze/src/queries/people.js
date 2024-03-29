import { gql } from "apollo-boost";

export const GET_PEOPLE = gql`
  query FindPeople($crashId: Int) {
    atd_txdot_primaryperson(where: { crash_id: { _eq: $crashId } }) {
      prsn_age
      prsn_nbr
      primaryperson_id
      prsn_injry_sev_id
      drvr_zip
      drvr_city_name
      injury_severity {
        injry_sev_desc
        injry_sev_id
      }
      person_type {
        prsn_type_desc
      }
      gender {
        gndr_id
        gndr_desc
      }
      ethnicity {
        ethnicity_id
        ethnicity_desc
      }
      unit_nbr
      peh_fl
    }
    primary_person_years_of_life_lost: atd_txdot_primaryperson_aggregate(
      where: { crash_id: { _eq: $crashId } }
    ) {
      aggregate {
        sum {
          years_of_life_lost
        }
      }
    }
    atd_txdot_person(where: { crash_id: { _eq: $crashId } }) {
      prsn_age
      prsn_nbr
      person_id
      prsn_injry_sev_id
      injury_severity {
        injry_sev_desc
        injry_sev_id
      }
      person_type {
        prsn_type_desc
      }
      gender {
        gndr_id
        gndr_desc
      }
      ethnicity {
        ethnicity_id
        ethnicity_desc
      }
      unit_nbr
      peh_fl
    }
    person_years_of_life_lost: atd_txdot_person_aggregate(
      where: { crash_id: { _eq: $crashId } }
    ) {
      aggregate {
        sum {
          years_of_life_lost
        }
      }
    }
  }
`;

export const GET_PERSON_NAMES = gql`
  query FindNames($crashId: Int, $personId: Int) {
    atd_txdot_primaryperson(
      where: {
        crash_id: { _eq: $crashId }
        _and: { primaryperson_id: { _eq: $personId } }
      }
    ) {
      primaryperson_id
      prsn_first_name
      prsn_mid_name
      prsn_last_name
    }
    atd_txdot_person(
      where: {
        crash_id: { _eq: $crashId }
        _and: { person_id: { _eq: $personId } }
      }
    ) {
      person_id
      prsn_first_name
      prsn_mid_name
      prsn_last_name
    }
  }
`;

export const UPDATE_PRIMARYPERSON = gql`
  mutation UpdatePrimaryPerson(
    $crashId: Int
    $personId: Int
    $changes: atd_txdot_primaryperson_set_input
  ) {
    update_atd_txdot_primaryperson(
      where: {
        crash_id: { _eq: $crashId }
        _and: { primaryperson_id: { _eq: $personId } }
      }
      _set: $changes
    ) {
      affected_rows
      returning {
        primaryperson_id
        crash_id
        unit_nbr
      }
    }
  }
`;

export const UPDATE_PERSON = gql`
  mutation UpdatePerson(
    $crashId: Int
    $personId: Int
    $changes: atd_txdot_person_set_input
  ) {
    update_atd_txdot_person(
      where: {
        crash_id: { _eq: $crashId }
        _and: { person_id: { _eq: $personId } }
      }
      _set: $changes
    ) {
      affected_rows
      returning {
        person_id
        crash_id
        unit_nbr
      }
    }
  }
`;
