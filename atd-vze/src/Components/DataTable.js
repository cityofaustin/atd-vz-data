import React, { useState } from "react";
import { useQuery } from "@apollo/react-hooks";
import { useAuth0, isReadOnly } from "../auth/authContext";
import ConfirmModal from "./ConfirmModal";
import get from "lodash.get";
import { formatCostToDollars, formatDateTimeString } from "../helpers/format";

import {
  Card,
  CardHeader,
  CardBody,
  CardFooter,
  Col,
  Input,
  Table,
  Button,
} from "reactstrap";

import { GET_LOOKUPS } from "../queries/lookups";

const DataTable = ({
  dataMap,
  dataTable,
  setEditField,
  editField,
  data,
  formData,
  handleInputChange,
  handleFieldUpdate,
  handleButtonClick,
  downloadGlobal,
}) => {
  // Disable edit features if only role is "readonly"
  const { getRoles } = useAuth0();
  const roles = getRoles();

  const [showModal, setShowModal] = useState(false);

  // Import Lookup tables and aggregate an object of uiType= "select" options
  const { data: lookupSelectOptions } = useQuery(GET_LOOKUPS);

  const handleCancelClick = e => {
    e.preventDefault();

    setEditField("");
  };

  const onButtonClick = (e, section) => {
    handleFieldUpdate && handleFieldUpdate(e, section, "button");
    handleButtonClick &&
      handleButtonClick(e, section.button.buttonFieldUpdate, data);
  };

  const toggleModal = () => {
    setShowModal(!showModal);
  };

  return (
    <>
      {dataMap.map((section, i) => {
        const buttonCondition =
          section.button && section.button.buttonCondition;

        return (
          <Col key={i} md="6">
            <Card key={section.title}>
              <CardHeader>{section.title}</CardHeader>
              <CardBody>
                <Table responsive striped hover>
                  <tbody>
                    {Object.keys(section.fields).map((field, i) => {
                      const isEditing = field === editField;
                      const fieldConfigObject = section.fields[field];

                      const fieldLabel = fieldConfigObject.label;

                      // Disable editing if user is only "readonly"
                      if (fieldConfigObject.editable && isReadOnly(roles)) {
                        fieldConfigObject.editable = false;
                      }

                      // Set data table (alternate if defined in data map)
                      const fieldDataTable =
                        fieldConfigObject.alternateTable || dataTable;

                      // If data is nested in data object, define path in dataMap
                      const nestedData =
                        fieldConfigObject.dataPath &&
                        get(
                          data[fieldDataTable][0],
                          fieldConfigObject.dataPath
                        );

                      const formattedDollarValue =
                        fieldConfigObject.format === "dollars" &&
                        formatCostToDollars(
                          nestedData || data[fieldDataTable][0][field]
                        );

                      const formatDateTimeValue =
                        fieldConfigObject.format === "datetime" &&
                        formatDateTimeString(
                          nestedData || data[fieldDataTable][0][field]
                        );

                      const fieldValue =
                        formattedDollarValue ||
                        formatDateTimeValue ||
                        nestedData ||
                        (formData && formData[field.data]) ||
                        data[fieldDataTable][0][field];

                      const fieldUiType = fieldConfigObject.uiType;

                      const lookupPrefix = fieldConfigObject.lookupPrefix
                        ? fieldConfigObject.lookupPrefix
                        : field.split("_id")[0];

                      // If there is no lookup options, we can assume the field value can be displayed as is.
                      // If there is a lookup option, then the value is an ID to be referenced in a lookup table.
                      const selectOptions =
                        lookupSelectOptions[fieldConfigObject.lookupOptions];

                      const renderLookupDescString = () => {
                        // make sure the value isn't null blank
                        if (
                          fieldValue === null ||
                          typeof fieldValue === "undefined"
                        )
                          return "NO DATA";

                        // make sure there is a lookup object in the config
                        if (!selectOptions || !fieldConfigObject.lookupOptions)
                          return fieldValue;

                        // make sure the config lookup object matches with lookup queries
                        const matchingLookupObject = selectOptions.find(
                          item => item[`${lookupPrefix}_id`] === fieldValue
                        );

                        if (!matchingLookupObject) {
                          console.warn(
                            `${field} has a value of ${fieldValue} which has no match in the related lookup table. You should check to make sure the lookup table isn't missing any rows of data.`
                          );
                          return `ID: ${fieldValue}`;
                        } else {
                          return matchingLookupObject[`${lookupPrefix}_desc`];
                        }
                      };

                      const fieldValueDisplay = renderLookupDescString();

                      return (
                        <tr key={i}>
                          <td>
                            <strong>{fieldLabel}</strong>
                          </td>
                          <td>
                            {isEditing ? (
                              <form
                                onSubmit={e =>
                                  handleFieldUpdate(e, section.fields, field)
                                }
                              >
                                {fieldUiType === "select" && (
                                  <Input
                                    name={field}
                                    id={field}
                                    onChange={e => handleInputChange(e)}
                                    defaultValue={
                                      fieldValue === null ? "" : fieldValue
                                    }
                                    type="select"
                                  >
                                    {selectOptions.map(option => (
                                      <option
                                        value={option[`${lookupPrefix}_id`]}
                                      >
                                        {option[`${lookupPrefix}_desc`]}
                                      </option>
                                    ))}
                                    <option value={""}>NO DATA</option>
                                  </Input>
                                )}
                                {fieldUiType === "text" && (
                                  <input
                                    type="text"
                                    defaultValue={fieldValue}
                                    onChange={e => handleInputChange(e)}
                                  />
                                )}

                                <button type="submit">
                                  <i className="fa fa-check edit-toggle" />
                                </button>
                                <button type="cancel">
                                  <i
                                    className="fa fa-times edit-toggle"
                                    onClick={e => handleCancelClick(e)}
                                  ></i>
                                </button>
                              </form>
                            ) : (
                              <div
                                className={
                                  fieldValueDisplay === "NO DATA"
                                    ? "text-muted"
                                    : ""
                                }
                              >
                                {fieldValueDisplay}
                              </div>
                            )}
                          </td>
                          <td>
                            {fieldConfigObject.editable && !isEditing && (
                              <i
                                className="fa fa-pencil edit-toggle"
                                onClick={() => setEditField(field)}
                              />
                            )}
                          </td>
                        </tr>
                      );
                    })}
                  </tbody>
                </Table>
                {/* If button parameters are set and the defined condition is met, show button */}
                {section.button &&
                  !section.button.buttonConfirm &&
                  data[buttonCondition.dataTableName][0][
                    buttonCondition.dataPath
                  ] === buttonCondition.value && (
                    <Button
                      color="danger"
                      onClick={e => onButtonClick(e, section)}
                    >
                      {section.button.buttonText}
                    </Button>
                  )}
                {/* If button confirm parameters are set, show button and confirm modal */}
                {section.button &&
                  section.button.buttonConfirm &&
                  data[buttonCondition.dataTableName][0][
                    buttonCondition.dataPath
                  ] === buttonCondition.value && (
                    <>
                      <Button color="danger" onClick={toggleModal}>
                        {section.button.buttonText}
                      </Button>
                      {section.button.buttonConfirm && showModal && (
                        <ConfirmModal
                          modalHeader={
                            section.button.buttonConfirm.confirmHeader
                          }
                          modalBody={section.button.buttonConfirm.confirmBody}
                          confirmClick={e => onButtonClick(e, section)}
                          toggleModal={toggleModal}
                          showModal={showModal}
                        />
                      )}
                    </>
                  )}
              </CardBody>
              <CardFooter>{downloadGlobal}</CardFooter>
            </Card>
          </Col>
        );
      })}
    </>
  );
};

export default DataTable;
