import React, { useState } from "react";
import { Link } from "react-router-dom";

import { withApollo } from "react-apollo";
import { useMutation } from "@apollo/react-hooks";

import {
  Alert,
  Button,
  Card,
  CardBody,
  CardHeader,
  FormGroup,
  Input,
  Label,
  Modal,
  ModalBody,
  ModalFooter,
  ModalHeader,
  Table,
} from "reactstrap";
import { SOFT_DELETE_TEMP_RECORDS } from "../../queries/tempRecords";
import { formatDateTimeString } from "../../helpers/format";

const CreateCrashRecordTable = ({
  crashesData,
  loading,
  error,
  refetch,
  userEmail,
  setSuccessfulNewRecordId,
}) => {
  const [crashSearch, setCrashSearch] = useState("");
  const [modalOpen, setModalOpen] = useState(false);
  const [deleteId, setDeleteId] = useState(null);
  const [feedback, setFeedback] = useState(null);
  const [deleteTempRecords] = useMutation(SOFT_DELETE_TEMP_RECORDS);

  if (loading) return "Loading...";
  if (error) return `Error! ${error.message}`;

  /**
   * Updates the case_id being searched
   * @param {Object} e - The Event being handled
   */
  const onKeyboardTypeHandler = e => {
    setCrashSearch(e.target.value);
  };

  /**
   * Soft deletes the temporary crash and all its associated unit and people records
   */
  const handleDelete = () => {
    deleteTempRecords({
      variables: { recordId: deleteId, updatedBy: userEmail },
    })
      .then(() => {
        setSuccessfulNewRecordId(null);
        setDeleteId(null);
        setFeedback(`Crash ID ${deleteId} has been deleted.`);
        toggleModalDelete();
        refetch();
      })
      .catch(err => {
        setFeedback(String(err));
        setDeleteId(null);
      });
  };

  /**
   * Opens/Closes the delete modal
   */
  const toggleModalDelete = () => {
    setModalOpen(!modalOpen);
  };

  /**
   * Commits the crash record id to be deleted to state, and prompts for deletion.
   * @param {int} recordId - The record id to be deleted.
   */
  const openModalDelete = recordId => {
    setDeleteId(recordId);
    toggleModalDelete();
  };

  return (
    <>
      {error && <>Could not load data</>}
      {loading && <>Loading data, please wait...</>}
      {crashesData && (
        <Card>
          <CardHeader>
            <i className="fa fa-align-justify"></i> Temporary Crashes in
            Database
          </CardHeader>
          <CardBody>
            <Alert
              color="secondary"
              isOpen={!!feedback}
              toggle={() => setFeedback(null)}
            >
              {feedback}
            </Alert>
            <FormGroup>
              <Label htmlFor="company">
                Type to search by case id (exact match)
              </Label>
              <Input
                type="text"
                id="case_id_search"
                placeholder="Enter Case ID"
                onChange={onKeyboardTypeHandler}
              />
            </FormGroup>
            <Table responsive striped>
              <thead>
                <tr>
                  <th>Crash ID</th>
                  <th>Case ID</th>
                  <th>Crash Timestamp</th>
                  <th>Updated By</th>
                  <th>Updated At</th>
                  <th>Action</th>
                </tr>
              </thead>
              <tbody>
                {crashesData &&
                  crashesData.map((item, index) => {
                    if (crashSearch !== "" && item.case_id !== crashSearch)
                      return null;

                    return (
                      <tr key={index}>
                        <td>
                          <Link to={`/crashes/${item.record_locator}`}>
                            {item.record_locator}
                          </Link>
                        </td>
                        <td>{item.case_id}</td>
                        <td>{formatDateTimeString(item.crash_timestamp)}</td>
                        <td>{item.updated_by}</td>
                        <td>{formatDateTimeString(item.updated_at)}</td>
                        <td>
                          <Button
                            color="danger"
                            className="btn-pill"
                            size={"sm"}
                            onClick={() => openModalDelete(item.id)}
                          >
                            <i className="fa fa-remove"></i>&nbsp;Delete
                          </Button>
                        </td>
                      </tr>
                    );
                  })}
              </tbody>
            </Table>
          </CardBody>
        </Card>
      )}
      <Modal
        isOpen={modalOpen}
        className={"modal-danger"}
        toggle={toggleModalDelete}
      >
        <ModalHeader toggle={toggleModalDelete}>
          Delete this record?
        </ModalHeader>
        <ModalBody>
          Are you sure you want to delete crash id <strong>T{deleteId}</strong>?
          This cannot be undone.
        </ModalBody>
        <ModalFooter>
          <Button color="danger" onClick={handleDelete}>
            Ok
          </Button>
          <Button color="secondary" onClick={toggleModalDelete}>
            Cancel
          </Button>
        </ModalFooter>
      </Modal>
    </>
  );
};

export default withApollo(CreateCrashRecordTable);
