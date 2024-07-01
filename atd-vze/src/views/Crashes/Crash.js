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
import {
  useAuth0,
  isAdmin,
  isItSupervisor,
  isReadOnly,
} from "../../auth/authContext";

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
import UnitDetailsCard from "./UnitDetailsCard";
import PeopleDetailsCard from "./PeopleDetailsCard";
import ChargesDetailsCard from "./ChargesDetailsCard";

import "./crash.scss";

import { GET_CRASH_OLD, UPDATE_CRASH, GET_CRASH } from "../../queries/crashes";
import {
  GET_NOTES,
  INSERT_NOTE,
  UPDATE_NOTE,
  DELETE_NOTE,
} from "../../queries/crashNotes";

function Crash(props) {
  const crashId = props.match.params.id;
  const { loading, error, data, refetch } = useQuery(GET_CRASH_OLD, {
    variables: { crashId },
  });
  const {
    loading: crashLoading,
    error: crashError,
    data: crashData,
    refetch: crashRefetch,
  } = useQuery(GET_CRASH, {
    variables: { crashId },
  });

  const [editField, setEditField] = useState("");
  const [formData, setFormData] = useState({});
  const [isEditingCoords, setIsEditingCoords] = useState(false);

  const { getRoles } = useAuth0();
  const roles = getRoles();

  if (loading || crashLoading) return "Loading...";
  if (crashError) return `Error! ${crashError.message}`;
  if (error) return `Error! ${error.message}`;

  const isCrashFatal =
    data?.atd_txdot_crashes?.[0]?.atd_fatality_count > 0 ? true : false;
  const shouldShowFatalityRecommendations =
    (isAdmin(roles) || isItSupervisor(roles)) && isCrashFatal;

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
      [editField]: e.target.value,
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
          id: crashPk,
          changes: { ...formData, ...secondaryFormData },
        },
      })
      .then(res => crashRefetch());

    setEditField("");
  };

  const {
    latitude_primary: latitude,
    longitude_primary: longitude,
    temp_record: tempRecord,
    geocode_method: geocodeMethod,
  } = !!data?.atd_txdot_crashes[0] ? data?.atd_txdot_crashes[0] : {};

  const crashRecord = {
    crash: crashData?.crashes?.[0] || { crash_injury_metrics_view: {} },
  };
  const crashPk = crashRecord?.crash?.id;

  const {
    crash_injury_metrics_view: { vz_fatality_count: deathCount },
    crash_injury_metrics_view: { sus_serious_injry_count: seriousInjuryCount },
    address_primary: primaryAddress,
    address_secondary: secondaryAddress,
    crash_injury_metrics_view: { years_of_life_lost: yearsOfLifeLost },
    investigator_narrative: investigatorNarrative,
    cr3_stored_fl: cr3StoredFlag,
  } = crashRecord.crash;

  const mapGeocoderAddress = createGeocoderAddressString(data);

  const hasLocation =
    data &&
    data?.atd_txdot_crashes.length > 0 &&
    data?.atd_txdot_crashes[0]["location_id"];
  const hasCoordinates = !!latitude && !!longitude;

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
            header={`${yearsOfLifeLost || 0}`}
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
                  {hasCoordinates
                    ? geocodeMethod.name
                    : "No Primary Coordinates"}
                </Col>
                <Col>
                  {!isEditingCoords && !isReadOnly(roles) && (
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
            <CardBody
              className="d-flex flex-column"
              style={{ minHeight: "400px" }}
            >
              {!hasCoordinates && (
                <Alert color="danger">
                  Crash record is missing latitude and longitude values required
                  for map display.
                </Alert>
              )}
              {!isEditingCoords ? (
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
            isCr3Stored={cr3StoredFlag}
            isTempRecord={tempRecord}
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
          <UnitDetailsCard
            data={crashRecord.crash.units}
            refetch={crashRefetch}
            {...props}
          />
          <PeopleDetailsCard
            data={crashRecord.crash.people_list_view}
            refetch={crashRefetch}
            {...props}
          />
          <ChargesDetailsCard data={crashRecord.crash.charges_cris} />
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
          dataTable="crash"
          formData={formData}
          setEditField={setEditField}
          editField={editField}
          handleInputChange={handleInputChange}
          handleFieldUpdate={handleFieldUpdate}
          data={crashRecord}
        />
        <Col md="12">
          <CrashChangeLog data={crashRecord?.crash?.change_logs} />
        </Col>
      </Row>
    </div>
  );
}

export default withApollo(Crash);
