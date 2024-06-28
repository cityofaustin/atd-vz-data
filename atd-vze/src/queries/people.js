import { gql } from "apollo-boost";

export const UPDATE_PERSON = gql`
  mutation UpdatePerson($personId: Int!, $changes: people_edits_set_input) {
    update_people_edits_by_pk(pk_columns: { id: $personId }, _set: $changes) {
      id
    }
  }
`;
