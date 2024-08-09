import React, { useState } from "react";
import { useQuery } from "@apollo/react-hooks";

import {
  Card,
  CardHeader,
  CardBody,
  Badge,
  Button,
  Collapse,
} from "reactstrap";

import RelatedRecordsTable from "./RelatedRecordsTable";

import { unitDataMap } from "./unitDataMap";
import { GET_UNIT_LOOKUPS } from "../../queries/lookups";
import { UPDATE_UNIT } from "../../queries/units";

const UnitDetailsCard = ({ data, refetch, ...props }) => {
  const [isOpen, setIsOpen] = useState(true);

  const unitMutation = {
    mutation: UPDATE_UNIT,
    variables: {
      unitId: "",
      changes: {},
    },
  };

  const { data: lookupSelectOptions, loading, error } = useQuery(
    GET_UNIT_LOOKUPS
  );

  if (loading) return "Loading...";
  if (error) return `Error! ${error.message}`;

  return (
    <Card className="mb-0">
      <CardHeader id="headingTwo">
        <Button
          block
          color="link"
          className="text-left m-0 p-0"
          onClick={() => setIsOpen(!isOpen)}
        >
          <h5 className="m-0 p-0">
            <i className="fa fa-car" /> Units
            <Badge color="secondary float-right">{data.length}</Badge>
          </h5>
        </Button>
      </CardHeader>
      <Collapse isOpen={isOpen}>
        <CardBody>
          <RelatedRecordsTable
            fieldConfig={unitDataMap[0]}
            data={data}
            sortField={"unit_nbr"}
            tableName={"units"}
            keyField={"id"}
            lookupOptions={lookupSelectOptions}
            mutation={unitMutation}
            refetch={refetch}
            {...props}
          />
        </CardBody>
      </Collapse>
    </Card>
  );
};

export default UnitDetailsCard;
