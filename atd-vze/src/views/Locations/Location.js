import React, { useState, useEffect } from "react";
import { format, subYears } from "date-fns";
import DataTable from "../../Components/DataTable";
import LocationMap from "./LocationMap";
import { Card, CardBody, CardHeader, Col, Row } from "reactstrap";

import { withApollo } from "react-apollo";
import { useQuery } from "@apollo/react-hooks";

import locationDataMap from "./locationDataMap";
import LocationCrashes from "./LocationCrashes";
import LocationNonCR3Crashes from "./LocationNonCR3Crashes";
import LocationDownloadGlobal from "./LocationDownloadGlobal";
import Notes from "../../Components/Notes/Notes";

import { GET_LOCATION, UPDATE_LOCATION } from "../../queries/Locations";
import {
  GET_LOCATION_NOTES,
  INSERT_LOCATION_NOTE,
  UPDATE_LOCATION_NOTE,
  DELETE_LOCATION_NOTE,
} from "../../queries/locationNotes";

function Location(props) {
  // Set initial variables for GET_LOCATION query
  const locationId = props.match.params.id;

  const fiveYearsAgo = format(subYears(Date.now(), 5), "yyyy-MM-dd");

  const [variables] = useState({
    id: locationId,
    yearsAgoDate: fiveYearsAgo,
  });

  const { loading, error, data, refetch } = useQuery(GET_LOCATION, {
    variables,
  });

  // On variable change, refetch to get calculated Non-CR3 total_est_comp_cost
  useEffect(() => {
    refetch(variables);
  }, [variables, refetch]);

  const [editField, setEditField] = useState("");
  const [formData, setFormData] = useState({});

  if (loading) return "Loading...";
  if (error) return `Error! ${error.message}`;

  const handleInputChange = e => {
    const newFormState = Object.assign(formData, {
      [editField]: e.target.value,
    });
    setFormData(newFormState);
  };

  const handleFieldUpdate = e => {
    e.preventDefault();

    props.client
      .mutate({
        mutation: UPDATE_LOCATION,
        variables: {
          locationId: locationId,
          changes: formData,
        },
      })
      .then(() => refetch());

    setEditField("");
  };

  const downloadAllData = (
    <div class={"float-right"}>
      <LocationDownloadGlobal locationId={locationId} />
    </div>
  );

  return (
    <div className="animated fadeIn">
      <Row>
        <Col>
          <h2 className="h2 mb-3">{data.atd_txdot_locations[0].description}</h2>
        </Col>
      </Row>
      <Row>
        <Col md="6">
          <Card>
            <CardHeader>
              <i className="fa fa-map fa-lg"></i> Aerial Map
            </CardHeader>
            <CardBody>
              <LocationMap data={data} />
            </CardBody>
          </Card>
        </Col>
        <DataTable
          dataMap={locationDataMap}
          dataTable={"atd_txdot_locations"}
          formData={formData}
          setEditField={setEditField}
          editField={editField}
          handleInputChange={handleInputChange}
          handleFieldUpdate={handleFieldUpdate}
          data={data}
          downloadGlobal={downloadAllData}
        />
      </Row>
      <Row>
        <Col>
          <Notes
            recordId={locationId}
            tableName={"location_notes"}
            GET_NOTES={GET_LOCATION_NOTES}
            INSERT_NOTE={INSERT_LOCATION_NOTE}
            UPDATE_NOTE={UPDATE_LOCATION_NOTE}
            DELETE_NOTE={DELETE_LOCATION_NOTE}
          />
        </Col>
      </Row>
      <Row>
        <Col>
          <LocationCrashes locationId={locationId} />
        </Col>
      </Row>
      <Row>
        <Col>
          <LocationNonCR3Crashes locationId={locationId} />
        </Col>
      </Row>
    </div>
  );
}

export default withApollo(Location);
