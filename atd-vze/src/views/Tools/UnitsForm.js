import React from "react";

import {
  Card,
  CardBody,
  CardHeader,
  Col,
  Input,
  Label,
  FormGroup,
  FormText,
} from "reactstrap";
import { useQuery } from "@apollo/react-hooks";
import { withApollo } from "react-apollo";
import { GET_UNIT_LOOKUPS } from "../../queries/lookups";

const UnitsForm = ({ units, handleUnitFormChange, client }) => {
  const { data: lookupValues, loading } = useQuery(GET_UNIT_LOOKUPS);

  return (
    <>
      {units.map((unit, i) => {
        return (
          <Card key={`unitCard-${i + 1}`}>
            <CardHeader>Unit #{i + 1}</CardHeader>
            <CardBody>
              <FormGroup row>
                <Col md="4">
                  <Label htmlFor="unit-type">Unit Type</Label>
                </Col>
                <Col xs="12" md="8">
                  <Input
                    type="select"
                    id="unit-type"
                    name="unit-type"
                    placeholder="Enter Fatality Count..."
                    value={unit.unit_desc_id}
                    onChange={e =>
                      handleUnitFormChange({
                        type: "unit_desc_id",
                        payload: e.target.value,
                        unitIndex: i,
                      })
                    }
                  >
                    <option value={0}>Select the unit type...</option>
                    {!loading &&
                      lookupValues.lookups_unit_desc.map(item => {
                        return (
                          <option value={item.id} key={`option-${item.id}`}>
                            {item.label}
                          </option>
                        );
                      })}
                  </Input>
                  <FormText className="help-block">
                    Please enter the Fatality Count
                  </FormText>
                </Col>
              </FormGroup>
              <FormGroup row>
                <Col md="4">
                  <Label htmlFor={`fatality-count-${i + 1}`}>
                    Fatality Count
                  </Label>
                </Col>
                <Col xs="12" md="8">
                  <Input
                    type="number"
                    id={`fatality-count-${i + 1}`}
                    name={`fatality-count-${i + 1}`}
                    placeholder="Enter Fatality Count..."
                    value={unit.fatality_count}
                    onChange={e =>
                      handleUnitFormChange({
                        type: "fatality_count",
                        payload: e.target.value,
                        unitIndex: i,
                      })
                    }
                  />
                  <FormText className="help-block">
                    Please enter the Fatality Count
                  </FormText>
                </Col>
              </FormGroup>
              <FormGroup row>
                <Col md="4">
                  <Label htmlFor={`sus-injury-cnt-${i + 1}`}>
                    Suspected Serious Injury Count
                  </Label>
                </Col>
                <Col xs="12" md="8">
                  <Input
                    type="number"
                    id={`sus-injury-cnt-${i + 1}`}
                    name={`sus-injury-cnt-${i + 1}`}
                    placeholder="Enter Suspected Serious Injury Count..."
                    value={unit.sus_serious_injry_cnt}
                    onChange={e =>
                      handleUnitFormChange({
                        type: "sus_serious_injry_cnt",
                        payload: e.target.value,
                        unitIndex: i,
                      })
                    }
                  />
                  <FormText className="help-block">
                    Please enter the Suspected Serious Injury Count
                  </FormText>
                </Col>
              </FormGroup>
            </CardBody>
          </Card>
        );
      })}
    </>
  );
};
export default withApollo(UnitsForm);
