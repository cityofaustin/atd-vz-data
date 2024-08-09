import React from "react";
import { useQuery } from "@apollo/react-hooks";
import { useAuth0, isReadOnly } from "../auth/authContext";
import { formatCostToDollars, formatDateTimeString } from "../helpers/format";

import {
  Button,
  Card,
  CardHeader,
  CardBody,
  CardFooter,
  Col,
  Input,
  Table,
} from "reactstrap";

import { GET_LOOKUPS } from "../queries/lookups";

const DataTable = ({
  dataMap,
  dataTable,
  setEditField,
  editField,
  data,
  handleInputChange,
  handleFieldUpdate,
  downloadGlobal,
}) => {
  // Disable edit features if only role is "readonly"
  const { getRoles } = useAuth0();
  const roles = getRoles();
  const isReadOnlyUser = isReadOnly(roles);

  // Import Lookup tables and aggregate an object of uiType= "select" options
  const { data: lookupSelectOptions } = useQuery(GET_LOOKUPS);

  const handleCancelClick = e => {
    e.preventDefault();

    setEditField("");
  };

  return (
    <>
      {dataMap.map((section, i) => {
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

                      // Set data table (alternate if defined in data map)
                      const fieldDataTable =
                        fieldConfigObject.alternateTable || dataTable;

                      // Handle field value that is nested in relationship if necessary
                      let fieldValue = fieldConfigObject.relationshipName
                        ? data[fieldDataTable][
                            fieldConfigObject.relationshipName
                          ][field]
                        : data[fieldDataTable][field];

                      // Handle formatting the field value
                      if (fieldConfigObject.format === "dollars") {
                        fieldValue = formatCostToDollars(fieldValue);
                      } else if (
                        fieldConfigObject.format === "datetime" &&
                        fieldValue
                      ) {
                        fieldValue = formatDateTimeString(fieldValue);
                      }

                      const fieldUiType = fieldConfigObject.uiType;

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
                          return "";
                        else if (fieldValue === true) {
                          return "YES";
                        } else if (fieldValue === false) {
                          return "NO";
                        }

                        // make sure there is a lookup object in the config
                        if (!selectOptions || !fieldConfigObject.lookupOptions)
                          return fieldValue.toString().toUpperCase();

                        // make sure the config lookup object matches with lookup queries
                        const matchingLookupObject = selectOptions.find(
                          item => item[`id`] === fieldValue
                        );

                        if (!matchingLookupObject) {
                          console.warn(
                            `${field} has a value of ${fieldValue} which has no match in the related lookup table. You should check to make sure the lookup table isn't missing any rows of data.`
                          );
                          return `ID: ${fieldValue}`;
                        } else {
                          return matchingLookupObject[`label`];
                        }
                      };

                      const fieldValueDisplay = renderLookupDescString();
                      const canClickToEdit =
                        !isReadOnlyUser &&
                        fieldConfigObject.editable &&
                        !isEditing;

                      return (
                        <tr
                          key={i}
                          onClick={() => canClickToEdit && setEditField(field)}
                          style={{
                            cursor: canClickToEdit ? "pointer" : "auto",
                          }}
                        >
                          <td className="align-middle">
                            <strong>{fieldLabel}</strong>
                          </td>
                          <td colSpan={isEditing ? 2 : 1}>
                            {isEditing ? (
                              <form
                                onSubmit={e =>
                                  handleFieldUpdate(e, section.fields, field)
                                }
                              >
                                <div className="d-flex">
                                  <div className="flex-grow-1">
                                    {fieldUiType === "select" && (
                                      <Input
                                        autoFocus
                                        name={field}
                                        id={field}
                                        onChange={e => handleInputChange(e)}
                                        defaultValue={fieldValue}
                                        type="select"
                                      >
                                        {selectOptions.map(option => (
                                          <option value={option[`id`]}>
                                            {option[`label`]}
                                          </option>
                                        ))}
                                      </Input>
                                    )}
                                    {fieldUiType === "text" && (
                                      <Input
                                        autoFocus
                                        name={field}
                                        id={field}
                                        type="text"
                                        defaultValue={fieldValue}
                                        onChange={e => handleInputChange(e)}
                                        autoComplete="off"
                                        // disable 1password autofill
                                        data-1p-ignore
                                      />
                                    )}
                                    {fieldUiType === "boolean" && (
                                      <Input
                                        autoFocus
                                        defaultValue={fieldValue}
                                        type="select"
                                        onChange={e => handleInputChange(e)}
                                      >
                                        <option value={true}>YES</option>
                                        <option value={false}>NO</option>
                                      </Input>
                                    )}
                                  </div>
                                  <div className="my-auto pl-2 d-flex">
                                    <Button
                                      type="submit"
                                      color="primary"
                                      size="sm"
                                      className="btn-pill mr-1"
                                    >
                                      <i className="fa fa-check edit-toggle" />
                                    </Button>
                                    <Button
                                      type="cancel"
                                      color="danger"
                                      size="sm"
                                      className="btn-pill"
                                      onClick={e => handleCancelClick(e)}
                                    >
                                      <i className="fa fa-times edit-toggle"></i>
                                    </Button>
                                  </div>
                                </div>
                              </form>
                            ) : (
                              fieldValueDisplay
                            )}
                          </td>
                          {!isEditing && (
                            <td style={{ textAlign: "right" }}>
                              {canClickToEdit && (
                                <i className="fa fa-pencil edit-toggle" />
                              )}
                            </td>
                          )}
                        </tr>
                      );
                    })}
                  </tbody>
                </Table>
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
