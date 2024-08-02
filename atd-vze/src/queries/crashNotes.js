import { gql } from "apollo-boost";

export const INSERT_NOTE = gql`
  mutation InsertNote($note: String!, $parentRecordId: Int!, $userEmail: String) {
    insert_crash_notes(
      objects: { text: $note, crash_pk: $parentRecordId, user_email: $userEmail }
    ) {
      returning {
        crash_pk
        text
        date
        user_email
      }
    }
  }
`;

export const UPDATE_NOTE = gql`
  mutation UpdateNote($note: String!, $id: Int!) {
    update_crash_notes_by_pk(pk_columns: { id: $id }, _set: { text: $note }) {
      crash_pk
      text
      date
      user_email
    }
  }
`;

export const DELETE_NOTE = gql`
  mutation DeleteNote($id: Int!) {
    delete_crash_notes_by_pk(id: $id) {
      crash_pk
      text
      date
      user_email
    }
  }
`;
