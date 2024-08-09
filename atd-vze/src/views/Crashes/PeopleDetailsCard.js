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

import { primaryPersonDataMap, personDataMap } from "./peopleDataMap";
import { GET_PERSON_LOOKUPS } from "../../queries/lookups";
import { UPDATE_PERSON } from "../../queries/people";

const PeopleDetailsCard = ({ data, refetch, ...props }) => {
  const [isOpen, setIsOpen] = useState(true);

  const { data: lookupSelectOptions, loading, error } = useQuery(
    GET_PERSON_LOOKUPS
  );

  const primaryPersonData = data.filter(
    person => person.is_primary_person === true
  );

  const personData = data.filter(person => person.is_primary_person === false);

  const personMutation = {
    mutation: UPDATE_PERSON,
    variables: {
      personId: "",
      changes: {},
    },
  };

  if (loading) return "Loading...";
  if (error) return `Error! ${error.message}`;

  return (
    <Card className="mb-0">
      <CardHeader id="headingOne">
        <Button
          block
          color="link"
          className="text-left m-0 p-0"
          onClick={() => setIsOpen(!isOpen)}
        >
          <h5 className="m-0 p-0">
            <i className="fa fa-group" /> People
            <Badge color="secondary float-right">{data.length}</Badge>
          </h5>
        </Button>
      </CardHeader>
      <Collapse isOpen={isOpen}>
        <CardBody>
          <RelatedRecordsTable
            fieldConfig={primaryPersonDataMap[0]}
            data={primaryPersonData}
            sortField={"unit_nbr"}
            secondSortField={"id"}
            tableName={"people_list_view"}
            keyField={"id"}
            lookupOptions={lookupSelectOptions}
            mutation={personMutation}
            refetch={refetch}
            {...props}
          />

          {personData.length > 0 && (
            <RelatedRecordsTable
              fieldConfig={personDataMap[0]}
              data={personData}
              sortField={"unit_nbr"}
              secondSortField={"id"}
              tableName={"people_list_view"}
              keyField={"id"}
              lookupOptions={lookupSelectOptions}
              mutation={personMutation}
              refetch={refetch}
              {...props}
            />
          )}
        </CardBody>
      </Collapse>
    </Card>
  );
};

export default PeopleDetailsCard;
