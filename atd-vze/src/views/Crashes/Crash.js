import React, { useState } from "react";
import { Link } from "react-router-dom";
import {
  Card,
  CardBody,
  CardHeader,
  Col,
  Row,
  Alert,
  Button,
} from "reactstrap";
import { withApollo } from "react-apollo";
import { useQuery } from "@apollo/react-hooks";
import { useAuth0, isAdmin, isItSupervisor } from "../../auth/authContext";

import CrashCollapses from "./CrashCollapses";
import CrashMap from "./Maps/CrashMap";
import CrashEditCoordsMap from "./Maps/CrashEditCoordsMap";
import Widget02 from "../Widgets/Widget02";
import CrashChangeLog from "./CrashChangeLog";
import CrashDiagram from "./CrashDiagram";
import CrashNarrative from "./CrashNarrative";
import DataTable from "../../Components/DataTable";
import Notes from "../../Components/Notes/Notes";
import { createCrashDataMap } from "./crashDataMap";
import Recommendations from "./Recommendations/Recommendations";
import Page404 from "../Pages/Page404/Page404";

import "./crash.scss";

import { GET_CRASH, UPDATE_CRASH } from "../../queries/crashes";
import { GET_PEOPLE } from "../../queries/people";
import {
  GET_NOTES,
  INSERT_NOTE,
  UPDATE_NOTE,
  DELETE_NOTE,
} from "../../queries/crashNotes";

const calculateYearsLifeLost = people => {
  // Assume 75 year life expectancy,
  // Find the difference between person.prsn_age & 75
  // Sum over the list of ppl with .reduce
  return people.reduce((accumulator, person) => {
    let years = 0;
    if (person.injury_severity.injry_sev_desc === "KILLED") {
      let yearsLifeLost = 75 - Number(person.prsn_age);
      // What if the person is older than 75?
      // For now, so we don't have negative numbers,
      // Assume years of life lost is 0
      years = yearsLifeLost < 0 ? 0 : yearsLifeLost;
    }
    return accumulator + years;
  }, 0); // start with a count at 0 years
};

function Crash(props) {
  const crashId = props.match.params.id;
  const { loading, error, data, refetch } = useQuery(GET_CRASH, {
    variables: { crashId },
  });
  const {
    loading: peopleLoading,
    error: peopleError,
    data: peopleData,
  } = useQuery(GET_PEOPLE, {
    variables: { crashId },
  });

  const [editField, setEditField] = useState("");
  const [formData, setFormData] = useState({});
  const [isEditingCoords, setIsEditingCoords] = useState(false);

  const { getRoles } = useAuth0();
  const roles = getRoles();

  const isCrashFatal =
    data?.atd_txdot_crashes?.[0]?.atd_fatality_count > 0 ? true : false;
  const shouldShowFatalityRecommendations =
    (isAdmin(roles) || isItSupervisor(roles)) && isCrashFatal;

  if (loading || peopleLoading) return "Loading...";
  if (error) return `Error! ${error.message}`;
  if (peopleError) return `Error! ${peopleError.message}`;

  const createGeocoderAddressString = data => {
    const geocoderAddressFields = [
      "rpt_block_num",
      "rpt_street_pfx",
      "street_name",
      "rpt_street_pfx",
    ];
    let geocoderAddressString = "";
    geocoderAddressFields.forEach(field => {
      if (data?.atd_txdot_crashes?.[0]?.[field] !== null) {
        geocoderAddressString = geocoderAddressString.concat(
          data?.atd_txdot_crashes?.[0]?.[field] + " "
        );
      }
    });
    return geocoderAddressString;
  };

  const handleInputChange = e => {
    const newFormState = Object.assign(formData, {
      [editField]: e.target.value === "" ? null : e.target.value,
      updated_by: localStorage.getItem("hasura_user_email"),
    });
    setFormData(newFormState);
  };

  const handleFieldUpdate = (e, fields, field) => {
    e.preventDefault();

    // Expose secondary field to update and add to mutation payload below
    let secondaryFormData = {};
    if (fields[field] && fields[field].secondaryFieldUpdate) {
      secondaryFormData = fields[field].secondaryFieldUpdate;
    }

    props.client
      .mutate({
        mutation: UPDATE_CRASH,
        variables: {
          crashId: crashId,
          changes: { ...formData, ...secondaryFormData },
        },
      })
      .then(res => refetch());

    setEditField("");
  };

  const handleButtonClick = (e, buttonParams, data) => {
    e.preventDefault();

    // Expose the field to mutate defined in crashDataMap
    // and the value from data using the dataPath, then mutate
    const fieldToUpdate = buttonParams.field;
    const fieldValue =
      data[buttonParams.dataTableName][0][buttonParams.dataPath];
    const buttonFormData = { [fieldToUpdate]: fieldValue };

    props.client
      .mutate({
        mutation: UPDATE_CRASH,
        variables: {
          crashId: crashId,
          changes: { ...formData, ...buttonFormData },
        },
      })
      .then(res => refetch());
  };

  const {
    atd_fatality_count: deathCount,
    sus_serious_injry_cnt: seriousInjuryCount,
    latitude_primary: latitude,
    longitude_primary: longitude,
    address_confirmed_primary: primaryAddress,
    address_confirmed_secondary: secondaryAddress,
    cr3_stored_flag: cr3StoredFlag,
    temp_record: tempRecord,
    geocode_method: geocodeMethod,
    cr3_file_metadata: cr3FileMetadata,
    investigator_narrative_ocr: investigatorNarrative,
  } = !!data?.atd_txdot_crashes[0] ? data?.atd_txdot_crashes[0] : {};

  const mapGeocoderAddress = createGeocoderAddressString(data);
  const yearsLifeLostCount = calculateYearsLifeLost(
    peopleData.atd_txdot_primaryperson.concat(peopleData.atd_txdot_person)
  );
  const hasLocation =
    data &&
    data?.atd_txdot_crashes.length > 0 &&
    data?.atd_txdot_crashes[0]["location_id"];
  const notEditingCoords = !isEditingCoords && latitude && longitude;

  return !data?.atd_txdot_crashes?.length ? (
    <Page404 />
  ) : (
    <div className="animated fadeIn">
      <Row>
        <Col>
          {primaryAddress && secondaryAddress ? (
            <h2 className="h2 mb-3">{`${primaryAddress} & ${secondaryAddress}`}</h2>
          ) : (
            <h2 className="h2 mb-3">{`${
              primaryAddress ? primaryAddress : "PRIMARY ADDRESS MISSING"
            } & ${
              secondaryAddress ? secondaryAddress : "SECONDARY ADDRESS MISSING"
            }`}</h2>
          )}
        </Col>
      </Row>
      <Row>
        <Col xs="12" sm="6" md="4">
          <Widget02
            header={`${deathCount === null ? "--" : deathCount}`}
            mainText="Fatalities"
            icon="fa fa-heartbeat"
            color="danger"
          />
        </Col>
        <Col xs="12" sm="6" md="4">
          <Widget02
            header={`${
              seriousInjuryCount === null ? "--" : seriousInjuryCount
            }`}
            mainText="Suspected Serious Injuries"
            icon="fa fa-medkit"
            color="warning"
          />
        </Col>
        <Col xs="12" sm="6" md="4">
          <Widget02
            header={`${
              yearsLifeLostCount === null ? "--" : yearsLifeLostCount
            }`}
            mainText="Years of Life Lost"
            icon="fa fa-hourglass-end"
            color="info"
          />
        </Col>
      </Row>
      <Row>
        <Col xs="12" md="6" className="mb-4">
          <Card className="h-100">
            <CardHeader>
              <Row>
                <Col>
                  Crash Location (ID:{" "}
                  {(hasLocation && (
                    <Link
                      to={`/locations/${
                        data.atd_txdot_crashes[0]["location_id"]
                      }`}
                    >
                      {data.atd_txdot_crashes[0]["location_id"]}
                    </Link>
                  )) ||
                    "unassigned"}
                  )
                  <br />
                  Geocode Provider:{" "}
                  {latitude && longitude
                    ? geocodeMethod.name
                    : "No Primary Coordinates"}
                </Col>
                <Col>
                  {!isEditingCoords && (
                    <Button
                      color="primary"
                      style={{ float: "right" }}
                      onClick={e => setIsEditingCoords(!isEditingCoords)}
                    >
                      Edit Coordinates
                    </Button>
                  )}
                </Col>
              </Row>
            </CardHeader>
            <CardBody style={{ minHeight: "350px" }}>
              {(!latitude || !longitude) && (
                <Alert color="danger">
                  Crash record is missing latitude and longitude values required
                  for map display.
                </Alert>
              )}
              {notEditingCoords ? (
                <CrashMap data={data.atd_txdot_crashes[0]} />
              ) : (
                <CrashEditCoordsMap
                  data={data.atd_txdot_crashes[0]}
                  mapGeocoderAddress={mapGeocoderAddress}
                  crashId={crashId}
                  refetchCrashData={refetch}
                  setIsEditingCoords={setIsEditingCoords}
                />
              )}
            </CardBody>
          </Card>
        </Col>
        <Col xs="12" md="6" className="mb-4">
          <CrashDiagram
            crashId={crashId}
            isCr3Stored={cr3StoredFlag === "Y"}
            isTempRecord={tempRecord}
            cr3FileMetadata={cr3FileMetadata}
          />
        </Col>
      </Row>
      {!!investigatorNarrative ? (
        <Row>
          <Col>
            <CrashNarrative investigatorNarrative={investigatorNarrative} />
          </Col>
        </Row>
      ) : (
        <div></div>
      )}
      <Row>
        <Col>
          <CrashCollapses data={data} props={props} />
        </Col>
      </Row>
      {shouldShowFatalityRecommendations && (
        <Row>
          <Col>
            <Recommendations crashId={props.match.params.id} />
          </Col>
        </Row>
      )}
      <Row>
        <Col>
          <Notes
            recordId={props.match.params.id}
            tableName={"crash_notes"}
            GET_NOTES={GET_NOTES}
            INSERT_NOTE={INSERT_NOTE}
            UPDATE_NOTE={UPDATE_NOTE}
            DELETE_NOTE={DELETE_NOTE}
          />
        </Col>
      </Row>
      <Row>
        <DataTable
          dataMap={createCrashDataMap(tempRecord)}
          dataTable={"atd_txdot_crashes"}
          formData={formData}
          setEditField={setEditField}
          editField={editField}
          handleInputChange={handleInputChange}
          handleFieldUpdate={handleFieldUpdate}
          handleButtonClick={handleButtonClick}
          data={data}
        />
        <Col md="6">
          <CrashChangeLog data={data} />
        </Col>
      </Row>
    </div>
  );
}

export default withApollo(Crash);
