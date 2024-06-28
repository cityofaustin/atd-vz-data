import { gql } from "apollo-boost";

export const GET_RECOMMENDATION_LOOKUPS = gql`
  query FindRecommendationLookups {
    atd__coordination_partners_lkp(order_by: { coord_partner_desc: asc }) {
      id
      coord_partner_desc
    }
    atd__recommendation_status_lkp {
      id
      rec_status_desc
    }
  }
`;

export const INSERT_RECOMMENDATION = gql`
  mutation InsertRecommendation(
    $text: String
    $update: String
    $crashPk: Int
    $userEmail: String
    $recommendation_status_id: Int
    $partner_id: Int
  ) {
    insert_recommendations(
      objects: {
        rec_text: $text
        rec_update: $update
        crash_id: $crashPk
        created_by: $userEmail
        recommendation_status_id: $recommendation_status_id
        recommendations_partners: { data: { partner_id: $partner_id } }
      }
    ) {
      returning {
        crash_id
        rec_update
        rec_text
        created_at
        created_by
      }
    }
  }
`;

export const UPDATE_RECOMMENDATION = gql`
  mutation UpdateRecommendations(
    $id: Int!
    $changes: recommendations_set_input
  ) {
    update_recommendations_by_pk(pk_columns: { id: $id }, _set: $changes) {
      crash_id
      rec_text
      rec_update
    }
  }
`;

export const INSERT_RECOMMENDATION_PARTNER = gql`
  mutation InsertRecommendationPartner(
    $recommendationRecordId: Int!
    $partner_id: Int!
  ) {
    insert_recommendations_partners(
      objects: {
        recommendation_id: $recommendationRecordId
        partner_id: $partner_id
      }
    ) {
      returning {
        id
        partner_id
        recommendation_id
      }
    }
  }
`;

export const REMOVE_RECOMMENDATION_PARTNER = gql`
  mutation DeleteRecommendationPartner(
    $partner_id: Int!
    $recommendationRecordId: Int!
  ) {
    delete_recommendations_partners(
      where: {
        _and: [
          { partner_id: { _eq: $partner_id } }
          { recommendation_id: { _eq: $recommendationRecordId } }
        ]
      }
    ) {
      returning {
        id
        partner_id
        recommendation_id
      }
    }
  }
`;
