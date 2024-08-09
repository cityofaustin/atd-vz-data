import React, { useState } from "react";

import {
  Card,
  CardHeader,
  CardBody,
  Table,
  Badge,
  Button,
  Collapse,
} from "reactstrap";

const ChargesDetailsCard = ({ data }) => {
  const [isOpen, setIsOpen] = useState(true);
  return (
    <Card>
      <CardHeader id="headingThree">
        <Button
          block
          color="link"
          className="text-left m-0 p-0"
          onClick={() => setIsOpen(!isOpen)}
        >
          <h5 className="m-0 p-0">
            <i className="fa fa-legal" /> Charges
            <Badge color="secondary float-right">{data.length}</Badge>
          </h5>
        </Button>
      </CardHeader>
      <Collapse isOpen={isOpen}>
        <CardBody>
          <Table responsive>
            <thead>
              <tr>
                <th>Unit</th>
                <th>Person</th>
                <th>Charge</th>
                <th>Citation Number</th>
              </tr>
            </thead>
            <tbody>
              {data.map((charge, i) => (
                <tr key={`charges-${i}`}>
                  <td>{charge.unit_nbr}</td>
                  <td>{charge.prsn_nbr}</td>
                  <td>{charge.charge}</td>
                  <td>{charge.citation_nbr}</td>
                </tr>
              ))}
            </tbody>
          </Table>
        </CardBody>
      </Collapse>
    </Card>
  );
};

export default ChargesDetailsCard;
