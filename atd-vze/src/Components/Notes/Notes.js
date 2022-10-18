import React, { useState } from "react";
import { useQuery, useMutation } from "@apollo/react-hooks";
import {
  Card,
  CardHeader,
  CardBody,
  CardFooter,
  Table,
  Input,
  Button,
} from "reactstrap";
import { format, parseISO } from "date-fns";
import { notesDataMap } from "./notesDataMap.js";
import { useAuth0, isReadOnly } from "../../auth/authContext";

// declare a notes component
const Notes = ({
  recordId,
  tableName,
  GET_NOTES,
  INSERT_NOTE,
  UPDATE_NOTE,
  DELETE_NOTE,
}) => {
  // add a state variable to manage value when new note is entered
  const [newNote, setNewNote] = useState("");
  const [editedNote, setEditedNote] = useState("");
  const [editRow, setEditRow] = useState("");

  // disable edit features if role is "readonly"
  const { getRoles } = useAuth0();
  const roles = getRoles();

  // get current users email
  const userEmail = localStorage.getItem("hasura_user_email");

  // fetch data from database using graphQL query
  const { loading, error, data, refetch } = useQuery(GET_NOTES, {
    variables: { recordId: recordId },
  });

  // declare mutation functions
  const [addNote] = useMutation(INSERT_NOTE);
  const [editNote] = useMutation(UPDATE_NOTE);
  const [deleteNote] = useMutation(DELETE_NOTE);

  if (loading) return "Loading...";
  if (error) return `Error! ${error.message}`;

  const keyField = "id";
  const fieldConfig = notesDataMap[0];

  // function to handle add button click
  const handleAddNoteClick = () => {
    addNote({
      variables: {
        note: newNote,
        recordId: recordId,
        userEmail: userEmail,
      },
    })
      .then(response => {
        setNewNote("");
        refetch();
      })
      .catch(error => console.error(error));
  };

  // function to handle edit button click
  const handleEditClick = row => {
    setEditedNote(row.text);
    setEditRow(row);
  };

  // function to handle save edit button click
  const handleSaveClick = row => {
    const id = row.id;
    editNote({
      variables: {
        note: editedNote,
        id: id,
      },
    })
      .then(response => {
        refetch().then(response => {
          setEditedNote("");
        });
      })
      .catch(error => console.error(error));
  };

  // function to handle cancel button click
  const handleCancelClick = () => {
    setEditRow("");
    setEditedNote("");
  };

  // function to handle delete note button click
  const handleDeleteClick = row => {
    const id = row.id;
    deleteNote({
      variables: {
        id: id,
      },
    })
      .then(response => {
        refetch();
      })
      .catch(error => console.error(error));
  };

  // render notes card and table
  return (
    <Card>
      <CardHeader>{fieldConfig.title}</CardHeader>
      <CardBody style={{ padding: "5px 20px 20px 20px" }}>
        <Table style={{ width: "100%" }}>
          <thead>
            {/* display label for each field in table header*/}
            <tr>
              <th
                style={{
                  width: "10%",
                  borderTop: "0px",
                  borderBottom: "1px",
                }}
              >
                {fieldConfig.fields.date.label}
              </th>
              <th
                style={{
                  width: "24%",
                  borderTop: "0px",
                  borderBottom: "1px",
                }}
              >
                {fieldConfig.fields.user_email.label}
              </th>
              <th
                style={{
                  width: "54%",
                  borderTop: "0px",
                  borderBottom: "1px",
                }}
              >
                {fieldConfig.fields.text.label}
              </th>
              {/* only create extra columns if user has edit permissions */}
              {!isReadOnly(roles) && (
                <th
                  style={{
                    width: "6%",
                    borderTop: "0px",
                    borderBottom: "1px",
                  }}
                ></th>
              )}
              {/* only create extra columns if user has edit permissions */}
              {!isReadOnly(roles) && (
                <th
                  style={{
                    width: "6%",
                    borderTop: "0px",
                    borderBottom: "1px",
                  }}
                ></th>
              )}
            </tr>
          </thead>
          <tbody>
            {/* display user input row for users with edit permissions*/}
            {!isReadOnly(roles) && (
              <tr>
                <td></td>
                <td></td>
                <td>
                  <Input
                    type="textarea"
                    placeholder="Enter new note here..."
                    value={newNote}
                    onChange={e => setNewNote(e.target.value)}
                  />
                </td>
                <td style={{ padding: "12px 4px 12px 12px" }}>
                  <Button
                    type="submit"
                    color="primary"
                    onClick={handleAddNoteClick}
                    className="btn-pill mt-2"
                    size="sm"
                    style={{ width: "50px" }}
                  >
                    Add
                  </Button>
                </td>
                <td></td>
              </tr>
            )}
            {/* iterate through each row in notes table */}
            {data[tableName].map(row => {
              const isEditing = editRow === row;
              const isUser = row.user_email === userEmail;
              return (
                <tr key={`table-${tableName}-${row[keyField]}`}>
                  {/* iterate through each field in the row and render its value */}
                  {Object.keys(fieldConfig.fields).map((field, i) => {
                    return (
                      <td key={i}>
                        {/* if user is editing display editing input text box */}
                        {isEditing && field === "text" ? (
                          <Input
                            type="textarea"
                            defaultValue={row.text}
                            onChange={e => setEditedNote(e.target.value)}
                          />
                        ) : field === "date" ? (
                          format(parseISO(row[field]), "MM/dd/yyyy")
                        ) : (
                          row[field]
                        )}
                      </td>
                    );
                  })}
                  {/* display edit button if row was created by current user,
                  user has edit permissions, and user is not currently editing */}
                  {isUser && !isReadOnly(roles) && !isEditing ? (
                    <td style={{ padding: "12px 4px 12px 12px" }}>
                      <Button
                        type="submit"
                        color="secondary"
                        size="sm"
                        className="btn-pill mt-2"
                        style={{ width: "50px" }}
                        onClick={e => handleEditClick(row)}
                      >
                        <i className="fa fa-pencil edit-toggle" />
                      </Button>
                    </td>
                  ) : (
                    // else if user has edit permissions and is not editing render empty cell
                    !isReadOnly(roles) && !isEditing && <td></td>
                  )}
                  {/* display delete button if row was created by current user,
                  user has edit permissions, and user is not currently editing */}
                  {isUser && !isReadOnly(roles) && !isEditing ? (
                    <td style={{ padding: "12px 4px 12px 4px" }}>
                      <Button
                        type="submit"
                        color="secondary"
                        className="btn-pill mt-2"
                        size="sm"
                        style={{ width: "50px" }}
                        onClick={e => handleDeleteClick(row)}
                      >
                        <i className="fa fa-trash" />
                      </Button>
                    </td>
                  ) : (
                    // else if user has edit permissions and is not editing render empty cell
                    !isReadOnly(roles) && !isEditing && <td></td>
                  )}
                  {/* display save button if user is editing */}
                  {!isReadOnly(roles) && isEditing && (
                    <td style={{ padding: "12px 4px 12px 12px" }}>
                      <Button
                        color="primary"
                        className="btn-pill mt-2"
                        size="sm"
                        style={{ width: "50px" }}
                        onClick={e => handleSaveClick(row)}
                      >
                        <i className="fa fa-check edit-toggle" />
                      </Button>
                    </td>
                  )}
                  {/* display cancel button if user is editing */}
                  {!isReadOnly(roles) && isEditing && (
                    <td style={{ padding: "12px 4px 12px 4px" }}>
                      <Button
                        type="submit"
                        color="danger"
                        className="btn-pill mt-2"
                        size="sm"
                        style={{ width: "50px" }}
                        onClick={e => handleCancelClick(e)}
                      >
                        <i className="fa fa-times edit-toggle" />
                      </Button>
                    </td>
                  )}
                </tr>
              );
            })}
          </tbody>
        </Table>
      </CardBody>
      <CardFooter></CardFooter>
    </Card>
  );
};

export default Notes;
