import React from "react";
import { Col, Row } from "reactstrap";
import { withApollo } from "react-apollo";
import { useQuery } from "@apollo/react-hooks";
import Widget02 from "../Widgets/Widget02";
import VZLinksWidget from "../Widgets/VZLinksWidget";
import VZNoticeWidget from "../Widgets/VZNoticeWidget";

import { GET_CRASHES_YTD } from "../../queries/dashboard";

import bi_logo from "../../assets/img/brand/power_bi_icon_white_on_transparent.png";

function VZDashboard() {
  const year = new Date().getFullYear();
  const yearStart = `${year}-01-01`;
  const yearEnd = `${year}-12-31`;
  const { loading, error, data } = useQuery(GET_CRASHES_YTD, {
    variables: { yearStart, yearEnd },
  });

  if (loading) return "Loading...";
  if (error) return `Error! ${error.message}`;

  const {
    years_of_life_lost: yearsOfLifeLostPrimaryPerson,
  } = data.atd_txdot_primaryperson_aggregate.aggregate.sum;
  const {
    years_of_life_lost: yearsOfLifeLostPerson,
  } = data.atd_txdot_person_aggregate.aggregate.sum;
  const {
    sus_serious_injry_cnt: seriousInjuryCount,
  } = data.seriousInjuriesAndTotal.aggregate.sum;
  const {
    apd_confirmed_death_count: deathCount,
  } = data.fatalities.aggregate.sum;

  const yearsOfLifeLostYTD =
    yearsOfLifeLostPrimaryPerson + yearsOfLifeLostPerson;
  const fatalitiesYTD = deathCount;
  const seriousInjuriesYTD = seriousInjuryCount;

  // Widget02 expects a string value, DB returns number or null
  const commaSeparator = number =>
    number === null ? "0" : number.toLocaleString();

  return (
    <div className="animated fadeIn">
      <Row>
        <Col xs="12" sm="12" md="12">
          <VZNoticeWidget
            header={`July 2021: Comprehensive Cost Schedule Updates`}
            mainText={`Vision Zero has implemented a revised comprehensive cost scale for crashes in the VZE crash database and various mapping tools. The revised scale inflates comprehensive costs to 2021 dollars, deemphasizes the relative value of non-injury/property damage only crashes (i.e. non-CR-3 crashes) and now applies cost values based on the highest injury severity of each crash, rather than the sum of all injuries per crash. Questions regarding the revised comprehensive cost scale can be directed to lewis.leff@austintexas.gov.`}
            icon="fa fa-exclamation-triangle"
            color="warning"
          />
        </Col>
      </Row>
      <Row>
        <Col xs="12" sm="6" md="4">
          <Widget02
            header={commaSeparator(yearsOfLifeLostYTD)}
            mainText={`Years of life lost in ${year}`}
            icon="fa fa-hourglass-end"
            color="info"
          />
        </Col>
        <Col xs="12" sm="6" md="4">
          <Widget02
            header={commaSeparator(fatalitiesYTD)}
            mainText={`Fatalities in ${year}`}
            icon="fa fa-heartbeat"
            color="danger"
          />
        </Col>
        <Col xs="12" sm="6" md="4">
          <Widget02
            header={commaSeparator(seriousInjuriesYTD)}
            mainText={`Suspected Serious Injuries in ${year}`}
            icon="fa fa-medkit"
            color="info"
          />
        </Col>
      </Row>
      <Row>
        <Col className="ml-1">
          {
            "*Dashboard data reflects APD confirmed deaths and excludes crashes on private driveways."
          }
        </Col>
      </Row>
      <Row className='mt-3'>
        <Col xs="12" sm="6" md="6">
          <VZLinksWidget
            header={`Arterial Management Division Overview`}
            mainText={`Top location overview, by collision types and modes`}
            icon="fa fa-arrows"
            raster_icon={bi_logo}
            raster_icon_alt="Power BI"
            color="dark"
            link="https://app.powerbigov.us/sharedwithme/reports/42c00944-3a44-4d0a-bdd4-d19d7e3647fe/ReportSection512b18e1068b03c18800?ctid=5c5e19f6-a6ab-4b45-b1d0-be4608a9a67f"
            target='_bi_amd'
          />
          <VZLinksWidget
            header={`High Injury Roadways`}
            mainText={`Each High Injury Roadway by Polygon with various statistics`}
            icon="fa fa-road"
            raster_icon={bi_logo}
            raster_icon_alt="Power BI"
            color="dark"
            link="https://app.powerbigov.us/groups/me/reports/5fd3a24f-839c-4702-870c-c44bf02abbfa/ReportSectiona58ac4e954138e705130?ctid=5c5e19f6-a6ab-4b45-b1d0-be4608a9a67f"
            target='_bi_hir'
          />
          <VZLinksWidget
            header={`Emerging Hotspots and Bond Locations`}
            mainText={`Track crash impact of Vision Zero Bond Projects and changing crash trends`}
            icon="fa fa-exchange"
            raster_icon={bi_logo}
            raster_icon_alt="Power BI"
            color="dark"
            link="https://app.powerbigov.us/groups/me/reports/ec595df7-a0ac-44ad-a973-e389a61bce80/ReportSection7bcb3c8d66b4510de019?ctid=5c5e19f6-a6ab-4b45-b1d0-be4608a9a67f"
            target='_bi_hotspots'
          />
        </Col>
        <Col xs="12" sm="6" md="6">
          <VZLinksWidget
            header={`Comprehensive Costs by Location`}
            mainText={`Based on Vision Zero polygons`}
            icon="fa fa-map"
            color="primary"
            link="https://austin.maps.arcgis.com/apps/instant/interactivelegend/index.html?appid=32b276f4e6cd406aa1c2040d2eb26b37"
            target='_compcostmap'
          />
          <VZLinksWidget
            header={`Vision Zero Viewer`}
            mainText={`Public-facing insight into crash trends`}
            icon="fa fa-map"
            color="primary"
            link="https://visionzero.austin.gov/viewer/"
            target='_vzv'
          />
        </Col>
      </Row>
    </div>
  );
}

export default withApollo(VZDashboard);
