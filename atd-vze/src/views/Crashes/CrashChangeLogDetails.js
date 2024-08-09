import React from "react";
import {
  Button,
  Table,
  Modal,
  ModalHeader,
  ModalBody,
  ModalFooter,
} from "reactstrap";
import { formatDateTimeString } from "../../helpers/format";
const isNewRecordEvent = change => change.operation_type === "create";

/**
 * Header component of the change details table
 */
const ChangeSummary = ({ selectedChange }) => {
  return (
    <>
      <small>
        {`${selectedChange.record_type}`} ID{" "}
        <span>{selectedChange.record_id}</span> edited by{" "}
        {selectedChange.created_by}
        {" - "}
        {formatDateTimeString(selectedChange.created_at)}
      </small>
    </>
  );
};

/**
 * Modal which renders change log details when a change log entry is clicked
 */
const ChangeDetailsModal = ({ selectedChange, setSelectedChange }) => {
  return (
    <Modal
      isOpen={!!selectedChange}
      toggle={() => setSelectedChange(null)}
      className="mw-100 mx-5"
      fade={false}
    >
      <ModalHeader toggle={() => setSelectedChange(null)}>
        <ChangeSummary selectedChange={selectedChange} />
      </ModalHeader>
      <ModalBody>
        <Table responsive striped hover>
          <thead>
            <td>Field</td>
            {!isNewRecordEvent(selectedChange) && <td>Previous value</td>}
            <td>New value</td>
          </thead>
          <tbody className="text-monospace">
            {selectedChange.diffs.map(diff => (
              <tr>
                <td>{diff.field}</td>
                {!isNewRecordEvent(selectedChange) && (
                  <td>{String(diff.old)}</td>
                )}
                <td>{String(diff.new)}</td>
              </tr>
            ))}
          </tbody>
        </Table>
      </ModalBody>
      <ModalFooter>
        <Button color="secondary" onClick={() => setSelectedChange(null)}>
          Close
        </Button>
      </ModalFooter>
    </Modal>
  );
};

export default ChangeDetailsModal;
