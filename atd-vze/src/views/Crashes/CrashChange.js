import React, { useState, useEffect } from "react";
import { Link, Redirect } from "react-router-dom";
import { gql } from "apollo-boost";
import { withApollo } from "react-apollo";
import { useQuery, useMutation } from "@apollo/react-hooks";
import { useAuth0 } from "../../auth/authContext";
import { MiniDiff } from "../../Components/MiniDiff";
import axios from "axios";

import "./crash.scss";

import {
  Card,
  CardBody,
  CardHeader,
  Col,
  Row,
  Button,
  Alert,
  Badge,
  Modal,
  ModalHeader,
  ModalBody,
  ModalFooter,
  Spinner,
} from "reactstrap";

import { AppSwitch } from "@coreui/react";
import {
  GET_CRASH_CHANGE,
  GET_CRASH_SECONDARY_RECORDS,
  CRASH_MUTATION_DISCARD,
  RECORD_MUTATION_UPDATE,
  RECORD_DELETE_CHANGE_RECORDS,
  UPSERT_MUTATION_DUMMY
} from "../../queries/crashes_changes";
import { crashFieldDescription, piiFields } from "./crashFieldDescriptions";
import { crashChangeQuotedFields } from "./crashChangeQuotedFields";
import { redirectUrl } from "../../index";

function CrashChange(props) {
  const crashId = props.match.params.id;
  const [selectedFields, setSelectedFields] = useState([]);
  const [recordData, setRecordData] = useState({});
  const [recordSecondaryData, setRecordSecondaryData] = useState({});
  // Arrays of column names
  const [importantFieldList, setImportantFieldList] = useState([]);
  const [differentFieldsList, setDifferentFieldsList] = useState([]);
  const [selectableList, setSelectableList] = useState([]);
  // Arrays of Components
  const [importantFields, setImportantFields] = useState([]);
  const [differentFields, setDifferentFields] = useState([]);
  const [showFieldsDiffOnly, setShowFieldsDiffOnly] = useState(true);
  // Modals
  const [approveAllChanges, setApproveAllChanges] = useState(false);
  const [discardAllChanges, setDiscardAllChanges] = useState(false);
  const [clearAllSelections, setClearAllSelections] = useState(false);
  const [savingChanges, setSavingChanges] = useState(false);
  const [errorDialog, setErrorDialog] = useState(false);
  const [saveStatus, setSaveStatus] = useState("");
  const [errorMessage, setErrorMessage] = useState("");
  // CR3 Availbable
  const [cr3available, setCR3Available] = useState(false);
  const [upsertRecordQuery, setUpsertRecordQuery] = useState(UPSERT_MUTATION_DUMMY);

  const { loading, user } = useAuth0();

  /**
   * Mutations
   */
  const [deleteFromQueue] = useMutation(
    gql`
      ${RECORD_DELETE_CHANGE_RECORDS}
    `
  );

  const [upsertRecordUpdates] = useMutation(
    gql`
        ${upsertRecordQuery}
    `
  );

  const {
    data: data,
    error: error,
    loading: loadingData,
    refetch: refetch,
  } = useQuery(GET_CRASH_CHANGE, {
    variables: { crashId },
  });

  const {
    data: secondaryData,
    error: secondaryError,
    loading: loadingSecondaryData,
  } = useQuery(GET_CRASH_SECONDARY_RECORDS, {
    variables: { crashId },
  });

  /**
   * Wait for data to be retrieved, then change state.
   */
  useEffect(() => setRecordData(data), [data]);

  /**
   * Returns true if fieldName exists within the selectedFields array.
   * @param {string} fieldName - The name of the field
   * @returns {boolean}
   */
  const isFieldEnabled = fieldName => {
    return selectedFields.includes(fieldName);
  };

  /**
   * Sleeps a for a few milliseconds
   * @param {int} milliseconds - The length of sleep in milliseconds
   * @returns {Promise}
   */
  const sleep = milliseconds => {
    return new Promise(resolve => setTimeout(resolve, milliseconds));
  };

  /**
   * Returns a gql object ready to be executed.
   * @param  {string} template - The GraphQL template we are working with
   * @param {object} values - A key-value object containing the value for variables in the template.
   * @returns {object} - A resulting gql object
   */
  const generateQueryFromTemplate = (template, values) => {};

  /**
   * Adds or removes field name from the selectedFields array.
   * @param {string} fieldName - The name of the field.
   */
  const toggleField = fieldName => {
    let newFieldList = selectedFields;

    // If it is there, remove it.
    if (isFieldEnabled(fieldName)) {
      const index = newFieldList.indexOf(fieldName);
      if (index !== -1) newFieldList.splice(index, 1);

      // If it isn't there, then add it.
    } else {
      newFieldList.push(fieldName);
    }
    const newList = [...newFieldList];
    setSelectedFields(newList);
  };

  /**
   * Toggles the diff only option in state
   */
  const toggleDiffOnly = () => {
    setShowFieldsDiffOnly(!showFieldsDiffOnly);
  };

  /**
   * Returns the existing record in database.
   * @returns {object|null} - The object data from the database
   */
  const getOriginalRecord = () => {
    return recordData["atd_txdot_crashes"][0] || null;
  };

  /**
   * Returns the new record as an object
   * @returns {object|null} - The parsed object
   */
  const getNewRecord = () => {
    try {
      return JSON.parse(recordData["atd_txdot_changes"][0]["record_json"]);
    } catch {
      redirectToQueueIndex();
      return null;
    }
  };

  /**
   * Returns an deconstructable array with two objects containing the old record and the new record.
   * @returns {object[]}
   */
  const getOriginalNewRecords = () => {
    return [getOriginalRecord(), getNewRecord()];
  };

  /**
   * Batch-enables a list of fields
   * @param {int} mode - The mode to operate: 1) Main, 2) All other fields, 3) All fields
   */
  const fieldsBatchEnable = mode => {
    let list = [];

    // Loop through main fields only
    if (mode === 1) {
      list = [...importantFieldList];
    }
    // Loop through all other fields
    else if (mode === 2) {
      list = [...differentFieldsList];
    }
    // Loop through all fields
    else if (mode === 3) {
      list = [...importantFieldList, ...differentFieldsList];
    }

    // If selectable & not already there
    const enabledList = list.filter(field => {
      return selectableList.includes(field) && !selectedFields.includes(field);
    });

    const newList = [...selectedFields, ...enabledList];
    setSelectedFields(newList);
  };

  /**
   * Batch-enables a list of fields
   * @param {int} mode - The mode to operate: 1) Main, 2) All other fields, 3) All fields
   */
  const fieldsBatchClear = mode => {
    let list = [];

    // Loop through main fields only
    if (mode === 1) {
      list = [...importantFieldList];
    }
    // Loop through all other fields
    else if (mode === 2) {
      list = [...differentFieldsList];
    }
    // Loop through all fields
    else if (mode === 3) {
      list = [...importantFieldList, ...differentFieldsList];
    }

    const enabledList = selectedFields.filter(field => {
      return !list.includes(field);
    });

    const newList = [...enabledList];
    setSelectedFields(newList);
  };

  /**
   * Downloads a CR3
   */
  const downloadCR3 = () => {
    const requestUrl = `${process.env.REACT_APP_CR3_API_DOMAIN}/cr3/download/${crashId}`;
    const token = window.localStorage.getItem("id_token");

    axios
      .request(requestUrl, {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      })
      .then(res => {
        const win = window.open(res.data.message, "_blank");
        win.focus();
      });
  };

  /**
   * Returns an array of strings with all the fields that have a different value.
   * @param {object} data
   * @returns {string[]}
   */
  const generate_diff = data => {
    const [originalRecord, newRecord] = getOriginalNewRecords();

    return Object.keys(newRecord)
      .map((currentKey, i) => {
        return String(`${newRecord[currentKey]}`).trim() !==
          String(`${originalRecord[currentKey]}`).trim()
          ? currentKey
          : "/-n/a-/";
      })
      .filter(e => e !== "/-n/a-/")
      .sort();
  };

  /**
   * Returns an array of strings containing the fields that are selectable
   * @returns {string[]}
   */
  const generate_diff_selectable = () => {
    const [originalRecord, newRecord] = getOriginalNewRecords();

    const selectable = Object.keys(newRecord).filter(field => {
      return (
        cleanString(originalRecord[field]) !== cleanString(newRecord[field])
      );
    });
    return selectable;
  };

  /**
   * Generates a mutation to update the original record.
   * @returns {string}
   */
  const generateMutationSave = () => {
    const newRecord =
      JSON.parse(recordData["atd_txdot_changes"][0]["record_json"]) || null;

    let updateFields = [];

    selectedFields.forEach(field => {
      // Generate the value
      let value = String(
        crashChangeQuotedFields.includes(field)
          ? `"${newRecord[field]}"`
          : newRecord[field]
      ).trim();

      if (value && value !== '""' && value.length > 0) {
        // Generate the line
        const currentField = `${field}: ${value}`;

        // Append the field
        updateFields.push(currentField);
      }
    });

    return RECORD_MUTATION_UPDATE.replace(
      "%FUNCTION_NAME%",
      "update_atd_txdot_crashes"
    ).replace("%UPDATE_FIELDS%", updateFields.join("\n"));
  };

  /**
   * Returns a clean string (if null, then assume empty.
   * @param {string} input - The string being cleaned
   * @returns {string}
   */
  const cleanString = input => {
    if (input === null) return "";
    return String(`${input}`).trim();
  };

  /**
   * Generates a JSX Row object, it returns null if there is no difference between the original value
   * and the new value from the new record as provided by the ETL process.
   * @param {string} field - The name of the field in the database (the column)
   * @param {string} label - The name of the label to show (if not the name of the field)
   * @param {string} originalFieldValue - The value of the record as it currently is in the database.
   * @param {string} newFieldValue - The value of the new record as provided by the ETL process.
   * @returns {Row}
   */
  const generateRow = (field, label, originalFieldValue, newFieldValue) => {
    const originalValue = cleanString(originalFieldValue);
    const newValue = cleanString(newFieldValue);

    const change = originalValue !== newValue;
    const selectorEnabled = isFieldEnabled(field);

    // if showFieldsDiffOnly is enabled, do not show if no change...
    if (showFieldsDiffOnly) {
      if (!change) return null;
    }

    return (
      <Row key={field} className={"crash-row"}>
        <Col xs="6" sm="6" md="3">
          <strong>{field}</strong>
        </Col>
        <Col xs="12" sm="12" md="4">
          <span className="minidiff"> {originalValue}</span>
        </Col>
        <Col xs="12" sm="12" md="4">
          <MiniDiff oldText={originalValue} newText={newValue} />
        </Col>
        <Col xs="6" sm="6" md="1">
          {change && (
            <AppSwitch
              className={"mx-1"}
              variant={"pill"}
              color={"primary"}
              outline={"alt"}
              label
              dataOn={"\u2713"}
              dataOff={"\u2715"}
              onClick={() => toggleField(field)}
              checked={selectorEnabled}
            />
          )}
        </Col>
      </Row>
    );
  };

  /**
   * In this useEffect, we listen for any changes to the data or to the
   * selected fields. If they change, so does our two groups of fields.
   */
  useEffect(() => {
    if (Object.keys(recordData).length > 0) {
      if (
        (recordData["atd_txdot_crashes"][0]["cr3_stored_flag"] || null) === "Y"
      ) {
        setCR3Available(true);
      }

      // We need a list of all important fields as defined in crashFieldDescription
      setImportantFieldList(
        Object.keys(crashFieldDescription).filter(field => {
          return field;
        })
      );

      setSelectableList(generate_diff_selectable());
    }
  }, [recordData]);

  /**
   * In this useEffect, we listen for changes to the importantFieldList
   * group, as well as any changes to the showFieldsDiffOnly variable.
   */
  useEffect(() => {
    if (Object.keys(recordData).length === 0) return;

    const [originalRecord, newRecord] = getOriginalNewRecords();

    // Now we need the rest of all other fields
    setDifferentFieldsList(
      generate_diff(recordData).filter(field => {
        return !importantFieldList.includes(field);
      })
    );

    // Now we get to build our component based on our list of important fields
    setImportantFields(
      Object.keys(crashFieldDescription).map(field => {
        return generateRow(
          field,
          field.label,
          originalRecord[field],
          newRecord[field]
        );
      })
    );
  }, [importantFieldList, showFieldsDiffOnly, recordData, selectedFields]);

  /**
   * In this useEffect, we listen for changes to the differentFieldsList
   * group, as well as any changes to the showFieldsDiffOnly variable.
   */
  useEffect(() => {
    if (Object.keys(recordData).length === 0) return;

    const [originalRecord, newRecord] = getOriginalNewRecords();

    setDifferentFields(
      differentFieldsList.map(field => {
        return generateRow(
          field,
          field,
          originalRecord[field],
          newRecord[field]
        );
      })
    );
  }, [differentFieldsList, showFieldsDiffOnly, recordData, selectedFields]);

  /**
   * We need to track whenever selectedFields is updated
   */
  useEffect(() => {
    // Print the current state
    console.log(selectedFields);
  }, [selectedFields]);

  /**
   * Closes all dialogs
   */
  const hideAllDialogs = () => {
    setApproveAllChanges(false);
    setDiscardAllChanges(false);
    setClearAllSelections(false);
    setSavingChanges(false);
  };

  /**
   * Hides the Save Selected Changes Modal
   */
  const hideSaveSelectedChanges = () => {
    setApproveAllChanges(false);
  };

  /**
   * Show the Save Selected Changes Modal
   */
  const showSaveSelectedChanges = () => {
    setApproveAllChanges(true);
  };

  /**
   * Hides the Discard New Record Modal
   */
  const hideDiscardNewRecord = () => {
    setDiscardAllChanges(false);
  };

  /**
   * Shows the Discard New Record Modal
   */
  const showDiscardNewRecord = () => {
    setDiscardAllChanges(true);
  };

  /**
   * Hides the Unselect All Changes Modal
   */
  const hideUnselectAllChanges = () => {
    setClearAllSelections(false);
  };

  /**
   * Shows the Unselect All Changes Modal
   */
  const showUnselectAllChanges = () => {
    setClearAllSelections(true);
  };

  /**
   * Shows the Error dialog
   */
  const showErrorDialog = () => {
    hideAllDialogs();
    setErrorDialog(true);
  };

  /**
   * Hides the Error dialog
   */
  const hideErrorDialog = () => {
    setErrorDialog(false);
  };

  /**
   * Hides the process dialog (when saving or deleting)
   */
  const hideProcessDialog = () => {
    setSavingChanges(false);
  };

  /**
   * Shows the process dialog (when saving or deleting)
   */
  const showProcessDialog = () => {
    setSavingChanges(true);
  };

  /**
   * Operations: Update, Delete, etc.
   */

  /**
   * Redirects to the index page
   */
  const redirectToQueueIndex = () => {
    window.location = "/#/changes";
  };

  /**
   * It is dummy start point for any changes to the database...
   * @returns {Promise<void>}
   */
  const startSaveProcess = async () => {
    showProcessDialog();
    setSaveStatus("beginning update process");
    await sleep(1000);
  };

  /**
   * Executes graphql queries to update the crash record
   * @returns {Promise<void>}
   */
  const executeUpdateCrashRecord = async () => {
    const updateQueries = await generateUpdateQuery();
    console.log("executeUpdateCrashRecord() ");
    console.log(updateQueries);
    setSaveStatus("updating crash record");
    setUpsertRecordQuery(gql`${updateQueries}`);
    await sleep(1000);
    await upsertRecordUpdates();
  };

  /**
   * Executes graphql queries to update secondary records
   * @returns {Promise<void>}
   */
  const executeUpdateQueries = async () => {
    const mutation = generateMutationSave();
    setSaveStatus("updating secondary records");
    await sleep(1000);
  };

  /**
   * Executes the queries to delete the records from queue
   * @returns {Promise<void>}
   */
  const executeDeleteChangesRecords = async () => {
    setSaveStatus("removing records from queue");
    await sleep(1000);
    // await deleteFromQueue({ variables: { crashId: crashId } });
    // await refetch();
  };

  const chainError = (errorMessage) => {
    debugger;
    setErrorMessage(String(error));
    showErrorDialog();
    return Promise.reject(errorMessage);
  }

  /**
   * Saves the selected fields and discards the change
   */
  const saveSelectedFields = () => {

    startSaveProcess()
      .then(executeUpdateCrashRecord, chainError)
      .then(executeUpdateQueries, chainError)
      .then(executeDeleteChangesRecords, chainError)
      .then(() => {
        // If it all goes well then redirect to the index page...
        //redirectToQueueIndex();
        alert("Chain finished running");
      });
  };

  /**
   * Initializes the discard process...
   */
  const discardChange = () => {
    hideDiscardNewRecord();

    startSaveProcess()
      .then(executeDeleteChangesRecords)
      .then(() => {
        setSaveStatus("Redirecting to index page...");
        redirectToQueueIndex();
      })
      .catch(error => {
        setErrorMessage("Error on Delete: " + error);
        showErrorDialog();
      });
  };

  const isFieldQuoted = (recordType, key) => {
    try {
      return crashFieldDescription[recordType][key]["type"] === "string";
    } catch {
      return false;
    }
  }

  /**
   * Wraps a value in quotation marks if not numeric or boolean.
   * @param {*} value - Any given value, of any type.
   * @returns {string} - The value wrapped in quotation marks or as a string.
   */
  const printQuotation = value => {
    const strValue = String(value);
    return isNaN(value) ? `"${value}"` : strValue === "" ? "null" : strValue;
  };

  /**
   * Generates an executable GraphQL query based on a template and update fields.
   * @param {object} record - The record being updated
   * @returns {string} - The executable query.
   */
  const generateUpdateRecordQuery = record => {
    const recordString = record["record_json"] || "{}";
    const recordType = record["record_type"] || null;
    const recordObject =
      JSON.parse(recordString)[0] || JSON.parse(recordString) || {};
    // We need the entire list of objects minus any count fields
    const recordObjectKeys = Object.keys(recordObject)
      .map(key => {
        // Lower-case all keys for this object
        return key.toLowerCase();
      })
      .filter(key => {
        // Removes from list if it string ends with '_cnt'
        return !key.endsWith("_cnt");
      });

    if (recordType === "crash") {
      recordObject["crash_id"] = record["record_id"];
    }

    const constraintsList = {
      charges: "uniq_atd_txdot_charges",
      person: "atd_txdot_person_unique",
      primaryperson: "atd_txdot_primaryperson_unique",
      unit: "atd_txdot_units_unique",
      crash: "atd_txdot_crashes_pkey",
    };

    const functionNameList = {
      charges: "insert_atd_txdot_charges",
      person: "insert_atd_txdot_persons",
      primaryperson: "insert_atd_txdot_primaryperson",
      unit: "insert_atd_txdot_units",
      crash: "insert_atd_txdot_crashes",
    };

    // We must generate the list of fields & values to be updated
    const updateFields = Object.keys(recordObject)
      .map(key => {
        return isFieldQuoted(recordType, key)
          // We have a case_id, we must quote
          ? `${key}: "${recordObject[key]}",`
          // Not a case_id, then quote if not a number
          : String(key).toLowerCase() +
          ": " +
          printQuotation(recordObject[key]) +
          ",";
      })
      .join("\n\t\t\t\t");

    // This variable holds the fields to be updated on_conflict (upsert)
    const onConflictList =
      recordType === "crash"
        ? // If it is a crash, all we need are the selected fields.
          [...selectedFields]
        : // If not a crash, then we need a composite list:
          [
            // We need the list of all original fields of the record in question
            ...recordObjectKeys,
            // And we also need any selected count records
            ...selectedFields.filter(key => {
              if (recordType !== "charges")
                return key.endsWith("_cnt");
            }),
          ];

    // Then, let's get the function name and record type patched
    return RECORD_MUTATION_UPDATE.replace(
      "%FUNCTION_NAME%",
      functionNameList[recordType]
    )
      .replace("%CONSTRAINT_NAME%", constraintsList[recordType])
      .replace("%UPDATE_FIELDS%", updateFields)
      .replace("%CURRENT_USER%", user.email || "DiffView")
      .replace("%SELECTED_COLUMNS%", onConflictList.join("\n\t\t\t\t"));
  };

  /**
   * Generates an update query to update the secondary records
   * @returns {string} - The GraphQL query
   */
  const generateUpdateQuery = () => {
    console.log("Secondary Data:");
    console.log(secondaryData);

    let listOfRecordQueries = [];
    (secondaryData["atd_txdot_changes"] || []).forEach(record => {
      listOfRecordQueries.push(generateUpdateRecordQuery(record));
    });

    const updateSecondaryRecords = `
      mutation updateSecondaryRecords {
        %LIST_OF_RECORD_QUERIES%
      }
    `.replace(
      "%LIST_OF_RECORD_QUERIES%",
      listOfRecordQueries.length == 0
        ? ""
        : listOfRecordQueries.join("\n\t\t\t")
    );
    // First we need the template
    return updateSecondaryRecords;
  };

  /**
   * Render variables
   */
  // List of Selectable Fields
  const mainFieldsSelectable = importantFieldList.filter(field => {
    return selectableList.includes(field);
  });

  // // If selectable & not already there
  const otherFieldsSelectable = differentFieldsList.filter(field => {
    return selectableList.includes(field);
  });

  const noDifferencesMessage = (
    <Alert color="primary">
      There are no differences in the rest of the record.
    </Alert>
  );

  const fieldsHeader = (
    <Row className={"difftable-row__header"}>
      <Col xs="6" sm="6" md="3">
        <b>Crash Table Field</b>
      </Col>
      <Col xs="12" sm="12" md="4">
        <h5>
          <Badge color={"secondary"}>Current</Badge>
        </h5>
      </Col>
      <Col xs="12" sm="12" md="4">
        <h5>
          <Badge color={"danger"}>New</Badge>
        </h5>
      </Col>
      <Col xs="6" sm="6" md="1">
        &nbsp;
      </Col>
    </Row>
  );

  /**
   * Render the view
   */
  return error ? (
    <div>{error}</div>
  ) : (
    <div className="animated fadeIn">
      <Row>
        <CardBody>
          <h1>Crash ID: {crashId}</h1>
        </CardBody>
      </Row>
      <Row>
        <Col xs="12" sm="12" md="12">
          <Card>
            <CardHeader>
              <span>
                <strong>Main Options</strong>
              </span>
              <div className="float-right minidiff--switchrow">
                <AppSwitch
                  className={"mx-1"}
                  color={"primary"}
                  checked={!showFieldsDiffOnly}
                  onClick={() => toggleDiffOnly()}
                />
                <span className="minidiff--switchlabel">Show All Fields</span>
              </div>
            </CardHeader>
            <CardBody>
              <Row className="align-items-center">
                <Col sm xs="12" className="text-center">
                  <Link
                    className="btn btn-primary"
                    color="primary"
                    to={`/crashes/${crashId}`}
                    target="_blank"
                  >
                    <i className="fa fa-address-card-o"></i>&nbsp;Open Existing
                  </Link>
                </Col>
                <Col sm xs="12" className="text-center">
                  <Button
                    disabled={!cr3available}
                    title={
                      cr3available
                        ? "Click to open in new window"
                        : "CR3 NOT Available"
                    }
                    color="secondary"
                    onClick={downloadCR3}
                  >
                    <i className="fa fa-file-pdf-o"></i>&nbsp;Download CR3
                  </Button>
                </Col>
                <Col sm xs="12" className="text-center">
                  <Button
                    color="warning"
                    onClick={() => showUnselectAllChanges()}
                  >
                    <i className="fa fa-window-close"></i>&nbsp;Unselect all
                    changes
                  </Button>
                </Col>
                <Col
                  sm
                  xs="12"
                  className="text-center"
                  onClick={() => showSaveSelectedChanges()}
                >
                  <Button
                    color="success"
                    disabled={selectableList.length === 0}
                  >
                    <i className="fa fa-save"></i>&nbsp;Save Selected Changes
                  </Button>
                </Col>
                <Col
                  sm
                  xs="12"
                  className="text-center"
                  onClick={() => showDiscardNewRecord()}
                >
                  <Button color="danger">
                    <i className="fa fa-trash"></i>&nbsp;Discard New Record
                  </Button>
                </Col>
              </Row>
            </CardBody>
          </Card>
        </Col>
      </Row>

      {/* IMPORTANT FIELDS */}
      <Row>
        <Col xs="12" sm="12" md="12">
          <Card>
            <CardHeader>
              <span>
                <strong>Main Fields: {mainFieldsSelectable.length}</strong>
              </span>
              <Button
                color="ghost-dark"
                className="float-right"
                onClick={() => fieldsBatchEnable(1)}
                disabled={mainFieldsSelectable.length === 0}
              >
                <i className="fa fa-lightbulb-o"></i>&nbsp;Select All
              </Button>
              <Button
                color="ghost-dark"
                className="float-right"
                onClick={() => fieldsBatchClear(1)}
                disabled={mainFieldsSelectable.length === 0}
              >
                <i className="fa fa-lightbulb-o"></i>&nbsp;Clear All
              </Button>
            </CardHeader>
            <CardBody>
              {((mainFieldsSelectable.length > 0 ||
                showFieldsDiffOnly === false) && (
                <>
                  {fieldsHeader}
                  {importantFields}
                </>
              )) || <>{noDifferencesMessage}</>}
            </CardBody>
          </Card>
        </Col>
      </Row>

      {/* OTHER FIELDS */}
      <Row>
        <Col xs="12" sm="12" md="12">
          <Card>
            <CardHeader>
              <span>
                <strong>Other Fields: {otherFieldsSelectable.length}</strong>
              </span>
              <Button
                color="ghost-dark"
                className="float-right"
                onClick={() => fieldsBatchEnable(2)}
                disabled={otherFieldsSelectable.length === 0}
              >
                <i className="fa fa-lightbulb-o"></i>&nbsp;Select All
              </Button>
              <Button
                color="ghost-dark"
                className="float-right"
                onClick={() => fieldsBatchClear(2)}
                disabled={otherFieldsSelectable.length === 0}
              >
                <i className="fa fa-lightbulb-o"></i>&nbsp;Clear All
              </Button>
            </CardHeader>
            <CardBody>
              {((otherFieldsSelectable.length > 0 ||
                showFieldsDiffOnly === false) && (
                <>
                  {fieldsHeader}
                  {differentFields}
                </>
              )) || <>{noDifferencesMessage}</>}
            </CardBody>
          </Card>
        </Col>
      </Row>

      <Modal
        isOpen={approveAllChanges}
        toggle={() => hideSaveSelectedChanges()}
        className={"modal-success"}
      >
        <ModalHeader toggle={() => hideSaveSelectedChanges()}>
          {selectedFields.length > 0 && <>Save selected changes?</>}
          {selectedFields.length === 0 && <>No selected changes</>}
        </ModalHeader>
        <ModalBody>
          {selectedFields.length > 0 && (
            <>
              Click <strong>Save</strong> to save the selected changes into the
              record. Click <strong>Cancel</strong> to stop and close this
              dialog without changes.
            </>
          )}
          {selectedFields.length === 0 && (
            <>
              No changes have been selected. In order to make changes to the
              existing record, you must select at least one change.
            </>
          )}
        </ModalBody>
        <ModalFooter>
          {selectedFields.length > 0 && (
            <Button color="primary" onClick={() => saveSelectedFields()}>
              Save
            </Button>
          )}
          <Button color="secondary" onClick={() => hideSaveSelectedChanges()}>
            {selectedFields.length > 0 ? "Cancel" : "Close"}
          </Button>
        </ModalFooter>
      </Modal>

      <Modal
        isOpen={clearAllSelections}
        toggle={() => hideUnselectAllChanges()}
        className={"modal-warning"}
      >
        <ModalHeader toggle={() => hideUnselectAllChanges()}>
          Unselect all?
        </ModalHeader>
        <ModalBody>
          Click <strong>Unselect All</strong> to turn off every selected item.
          Click <strong>Cancel</strong> to stop and close this dialog without
          changes.
        </ModalBody>
        <ModalFooter>
          <Button
            color="primary"
            onClick={() => {
              fieldsBatchClear(3);
              hideUnselectAllChanges();
            }}
          >
            Unselect All
          </Button>{" "}
          <Button color="secondary" onClick={() => hideUnselectAllChanges()}>
            Cancel
          </Button>
        </ModalFooter>
      </Modal>

      <Modal
        isOpen={discardAllChanges}
        toggle={() => hideDiscardNewRecord()}
        className={"modal-danger"}
      >
        <ModalHeader toggle={() => hideDiscardNewRecord()}>
          Discard incoming record?
        </ModalHeader>
        <ModalBody>
          Click <strong>Discard</strong> to discard the new incoming record, and
          leave the original the way it is without changes. Click{" "}
          <strong>Cancel</strong> to stop and close this dialog without changes.{" "}
          <strong>This cannot be undone.</strong>
        </ModalBody>
        <ModalFooter>
          <Button color="danger" onClick={() => discardChange()}>
            <i className="fa fa-trash-o"></i>&nbsp;I am sure, Discard
          </Button>{" "}
          <Button color="secondary" onClick={() => hideDiscardNewRecord(3)}>
            Cancel
          </Button>
        </ModalFooter>
      </Modal>

      <Modal
        isOpen={savingChanges}
        className={"modal-secondary"}
        keyboard={false}
      >
        <ModalHeader toggle={null}>
          <span className={"crash-process-modal__header"}>
            Commiting Changes to Database
          </span>
        </ModalHeader>
        <ModalBody>
          <Spinner className="mt-2" color="primary" />
          <span className={"crash-process-modal__body"}>
            Saving changes, please wait... {saveStatus}
          </span>
        </ModalBody>
        <ModalFooter>
          <span>You will be redirected back to the queue.</span>
        </ModalFooter>
      </Modal>

      <Modal
        isOpen={errorDialog}
        toggle={() => hideErrorDialog()}
        className={"modal-secondary"}
        keyboard={false}
      >
        <ModalHeader toggle={() => hideErrorDialog()}>
          <span className={"crash-process-modal__header"}>Error</span>
        </ModalHeader>
        <ModalBody>
          <span className={"crash-process-modal__header"}>{errorMessage}</span>
        </ModalBody>
        <ModalFooter>
          <Button color="secondary" onClick={() => hideErrorDialog()}>
            Close
          </Button>
        </ModalFooter>
      </Modal>
    </div>
  );
}

export default withApollo(CrashChange);
