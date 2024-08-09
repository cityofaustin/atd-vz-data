import { gql } from "apollo-boost";

export const GET_TEMP_RECORDS = gql`
  query getTempRecords {
    crashes(
      where: {
        is_temp_record: { _eq: true }
        _and: { is_deleted: { _eq: false } }
      }
    ) {
      id
      record_locator
      case_id
      crash_timestamp
      updated_by
      updated_at
      units {
        id
      }
    }
  }
`;

export const SOFT_DELETE_TEMP_RECORDS = gql`
  mutation softDeleteTempRecords($recordId: Int!, $updatedBy: String!) {
    update_crashes_cris_by_pk(
      pk_columns: { id: $recordId }
      _set: { is_deleted: true, updated_by: $updatedBy }
    ) {
      id
    }
    update_units_cris(
      where: { crash_id: { _eq: $recordId } }
      _set: { is_deleted: true, updated_by: $updatedBy }
    ) {
      returning {
        id
        crash_id
      }
    }
    update_people_cris(
      where: { units_cri: { crash_id: { _eq: $recordId } } }
      _set: { is_deleted: true, updated_by: $updatedBy }
    ) {
      returning {
        id
        unit_id
      }
    }
  }
`;
