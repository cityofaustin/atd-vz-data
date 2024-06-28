import { gql } from "apollo-boost";

export const UPDATE_UNIT = gql`
  mutation UpdateUnits($unitId: Int!, $changes: units_edits_set_input) {
    update_units_edits_by_pk(pk_columns: { id: $unitId }, _set: $changes) {
      id
    }
  }
`;
