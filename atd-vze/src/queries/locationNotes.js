import { gql } from "apollo-boost";

export const INSERT_LOCATION_NOTE = gql`
  mutation InsertLocationNote(
    $note: String!
    $parentRecordId: String!
    $userEmail: String
  ) {
    insert_location_notes(
      objects: {
        text: $note
        location_id: $parentRecordId
        user_email: $userEmail
      }
    ) {
      returning {
        location_id
        text
        date
        user_email
      }
    }
  }
`;

export const UPDATE_LOCATION_NOTE = gql`
  mutation UpdateNote($note: String!, $id: Int!) {
    update_location_notes_by_pk(
      pk_columns: { id: $id }
      _set: { text: $note }
    ) {
      location_id
      text
      date
      user_email
    }
  }
`;

export const DELETE_LOCATION_NOTE = gql`
  mutation DeleteNote($id: Int!) {
    delete_location_notes_by_pk(id: $id) {
      location_id
      text
      date
      user_email
    }
  }
`;
