import React from "react";
import { Button, Input, Form, Row, Col, Label } from "reactstrap";

// This component should be role-restricted to users with Admin or IT Supervisor permissions
// Role check currently happens in the shouldRenderVictimName function of personDataMap
const VictimNameField = ({
  tableName,
  nameFieldConfig,
  mutation,
  handleEditClick,
  handleCancelClick,
  handleInputChange,
  handleSubmit,
  editField,
  editRow,
  row,
  field,
  refetch,
  isReadOnly,
  ...props
}) => {
  const personId = row.id;

  // Format name by concatenating first, middle, last or returning NO DATA
  const formatName = () => {
    var concatenatedName = "";
    Object.keys(nameFieldConfig.subfields).forEach(field => {
      if (row?.[field] != null) {
        concatenatedName = concatenatedName.concat(" ", row?.[field]);
      }
    });
    const isNameBlank = concatenatedName === "";
    return isNameBlank ? "NO DATA" : concatenatedName.toUpperCase();
  };

  const mutationVariable = nameFieldConfig.mutationVariableKey;

  const isEditing = editField === field && row === editRow;

  return (
    <td>
      {isEditing && (
        <Form>
          <Row>
            {Object.keys(nameFieldConfig.subfields).map(field => {
              return (
                <Col key={`$field-${field}${personId}`} className={"m-1 p-0"}>
                  <Label className={"text-muted m-0 p-0"}>
                    {nameFieldConfig.subfields[field].label}
                  </Label>
                  <Input
                    defaultValue={row[field]}
                    onChange={e => handleInputChange(e, field)}
                    // Make input render in uppercase
                    style={{ textTransform: "uppercase" }}
                  ></Input>
                </Col>
              );
            })}
          </Row>
          <Row>
            <Col className={"mx-1 p-0"}>
              <Button
                type="submit"
                block
                color="primary"
                size="sm"
                style={{ minWidth: "50px" }}
                className="btn-pill mt-2 mr-1"
                onClick={e =>
                  handleSubmit(e, mutationVariable, mutation, refetch)
                }
              >
                <i className="fa fa-check edit-toggle" />
              </Button>
            </Col>
            <Col className={"m-0 p-0"}>
              <Button
                type="cancel"
                block
                color="danger"
                size="sm"
                className="btn-pill mt-2"
                style={{ minWidth: "50px" }}
                onClick={e => handleCancelClick(e)}
              >
                <i className="fa fa-times edit-toggle"></i>
              </Button>
            </Col>
            <Col />
          </Row>
        </Form>
      )}

      {!isEditing && (
        <span className={formatName() === "NO DATA" ? "text-muted" : ""}>
          {formatName()}
        </span>
      )}

      {!isEditing && !isReadOnly && (
        <Button
          block
          color="secondary"
          size="sm"
          className="btn-pill mt-2"
          style={{ width: "50px" }}
          onClick={e => handleEditClick(field, row)}
        >
          <i className="fa fa-pencil edit-toggle" />
        </Button>
      )}
    </td>
  );
};

export default VictimNameField;
