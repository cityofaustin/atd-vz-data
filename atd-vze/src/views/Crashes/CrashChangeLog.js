import React, { Component } from "react";

import {
  Badge,
  Button,
  Card,
  CardBody,
  CardHeader,
  Col,
  Table,
  Row,
  Modal,
  ModalHeader,
  ModalBody,
  ModalFooter,
} from "reactstrap";
import { formatDateTimeString } from "../../helpers/format";

class CrashChangeLog extends Component {
  constructor(props) {
    super(props);

    this.state = {
      modal: false,
      modalBody: null,
      dataFrom: null,
      dataTo: null,
      data: this.props.data,
    };
  }

  /**
   * Shows the modal box by changing the state, does not alter the body.
   */
  showModal = () => {
    this.setState({
      modal: true,
    });
  };

  /**
   * Closes the modal box by changing the state and emptying the modal body.
   */
  closeModal = () => {
    this.setState({
      modal: false,
      modalBody: null,
    });
  };

  /**
   * Compares the archived json object against the current data object as populated via props.
   * @param {Object} record's json
   */
  compare = record => {
    // Holds only the keys
    let diff = [];

    // Holds the html for our modal box
    let modalBody = null;

    // Iterate through our record's key & values
    for (let [key, value] of Object.entries(
      this.props.data.atd_txdot_crashes[0]
    )) {
      // Let's get rid of typename
      if (key === "__typename") continue;

      try {
        // Gather the archived value for the current field
        let archivedRecordValue = record.record_json[key];

        // If the value is different from the current value, then put it in the diff array.
        if (archivedRecordValue !== value) {
          diff.push({
            original_record_key: key,
            original_record_value: value,
            archived_record_value: archivedRecordValue,
          });
        }
      } catch (error) {
        alert("Error: " + error);
      }
    }

    // Define a function to pass to JSON.stringify which will skip over
    // the __typename key in the JS object being stringified.
    const stringifyReplacer = (key, value) => {
      if (key === "__typename") {
        return undefined;
      }
      return value;
    };

    // For each entry created in the diff array, generate an HTML table row.
    let modalItems = diff.map((item, i) => {
      // The following two conditions check if an the current or archived value to
      // to be shown in the crach's changelog are objects, such as found when a jsonb
      // field is pulled from the database. In this case, they are stringified for
      // human-readble output.
      if (typeof item.original_record_value === "object") {
        item.original_record_value = JSON.stringify(
          item.original_record_value,
          stringifyReplacer
        );
      }

      if (typeof item.archived_record_value === "object") {
        item.archived_record_value = JSON.stringify(
          item.archived_record_value,
          stringifyReplacer
        );
      }

      return (
        <tr key={`recordHistory-${i}`} className="d-flex">
          <td className="col-2 text-break">{item.original_record_key}</td>
          <td className="col-5">
            <Badge color="primary" className="text-wrap text-break">
              {String(item.original_record_value)}
            </Badge>
          </td>
          <td className="col-5">
            <Badge color="danger" className="text-wrap text-break">
              {String(item.archived_record_value)}
            </Badge>
          </td>
        </tr>
      );
    });

    // Generate the body of the modal box
    modalBody = (
      <section>
        <h6>Crash ID: {record.record_crash_id}</h6>
        <h6>Edited Date: {formatDateTimeString(record.update_timestamp)}</h6>
        <h6>Updated by: {record.updated_by || "Unavailable"}</h6>
        &nbsp;
        <Table responsive className="overflow-hidden">
          <thead>
            <tr className="d-flex">
              <td className="col-2">Field</td>
              <td className="col-5">Current Value</td>
              <td className="col-5">Previous Value</td>
              <td></td>
            </tr>
          </thead>
          <tbody>{modalItems}</tbody>
        </Table>
      </section>
    );

    // Set the state of the modal box to contain the body
    this.setState({ modalBody: modalBody });
    // Show the modal
    this.showModal();
  };

  render() {
    let modal = null,
      content = null;
    // If there are no records, let's not render anything...
    if (this.props.data.atd_txdot_change_log.length === 0) {
      modal = null;
      content = <p>No changes found for this record.</p>;
    } else {
      modal = (
        <Modal
          isOpen={this.state.modal}
          toggle={this.closeModal}
          className="mw-100 mx-5"
        >
          <ModalHeader toggle={this.closeModal}>Record Differences</ModalHeader>
          <ModalBody>{this.state.modalBody}</ModalBody>
          <ModalFooter>
            <Button color="secondary" onClick={this.closeModal}>
              Close
            </Button>
          </ModalFooter>
        </Modal>
      );
      content = (
        <>
          <h4>Record History</h4>

          <Table responsive>
            <thead>
              <tr>
                <td>Date Edited</td>
                <td>Updated by</td>
                <td></td>
              </tr>
            </thead>
            <tbody>
              {this.props.data.atd_txdot_change_log.map(record => (
                <tr key={`changelog-${record.change_log_id}`}>
                  <td>
                    <Badge color="warning">
                      {formatDateTimeString(record.update_timestamp)}
                    </Badge>
                  </td>
                  <td>
                    <Badge color="danger">
                      {String(record.updated_by || "Unavailable")}
                    </Badge>
                  </td>
                  <td>
                    <Button
                      color="primary"
                      size="sm"
                      onClick={() => this.compare(record)}
                    >
                      Compare
                    </Button>
                  </td>
                </tr>
              ))}
            </tbody>
          </Table>
        </>
      );
    }

    // Render Box
    return (
      <div className="animated fadeIn">
        {modal}
        <Row>
          <Col>
            <Card>
              <CardHeader>
                <i className="fa fa-history" /> Change Log
              </CardHeader>
              <CardBody>{content}</CardBody>
            </Card>
          </Col>
        </Row>
      </div>
    );
  }
}

export default CrashChangeLog;
