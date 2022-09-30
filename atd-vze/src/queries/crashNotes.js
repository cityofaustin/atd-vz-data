import { gql } from "apollo-boost";

export const GET_NOTES = gql`
  query FindNotes($recordId: Int) {
    crash_notes(
      where: { crash_id: { _eq: $recordId } }
      order_by: { date: desc }
    ) {
      id
      created_at
      updated_at
      date
      text
      user_email
      crash_id
    }
  }
`;

export const INSERT_NOTE = gql`
  mutation InsertNote($note: String!, $recordId: Int!, $userEmail: String) {
    insert_crash_notes(
      objects: { text: $note, crash_id: $recordId, user_email: $userEmail }
    ) {
      returning {
        crash_id
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
      crash_id
      text
      date
      user_email
    }
  }
`;

export const DELETE_NOTE = gql`
  mutation DeleteNote($id: Int!) {
    delete_crash_notes_by_pk(id: $id) {
      crash_id
      text
      date
      user_email
    }
  }
`;
