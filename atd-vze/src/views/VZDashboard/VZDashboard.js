import React from "react";
import { Col, Row } from "reactstrap";
import { withApollo } from "react-apollo";
import { useQuery } from "@apollo/react-hooks";
import Widget02 from "../Widgets/Widget02";
import VZLinksWidget from "../Widgets/VZLinksWidget";
import VZNoticeWidget from "../Widgets/VZNoticeWidget";
import { format, subDays } from "date-fns";

import { GET_CRASHES_YTD } from "../../queries/dashboard";

import bi_logo from "../../assets/img/brand/power_bi_icon_white_on_transparent.png";

function VZDashboard() {
  const year = new Date().getFullYear();
  const yearStart = `${year}-01-01`;
  // We use the same end date as VZV so VZE widget totals match VZV widgets
  const yearEnd = format(subDays(new Date(), 14), "yyyy-MM-dd");
  const { loading, error, data } = useQuery(GET_CRASHES_YTD, {
    variables: { yearStart, yearEnd },
  });

  if (loading) return "Loading...";
  if (error) return `Error! ${error.message}`;

  const {
    years_of_life_lost: yearsOfLifeLostPrimaryPerson,
  } = data.primaryPersonFatalities.aggregate.sum;

  const {
    years_of_life_lost: yearsOfLifeLostPerson,
  } = data.personFatalities.aggregate.sum;

  const {
    sus_serious_injry_cnt: seriousInjuryCount,
  } = data.seriousInjuriesAndTotal.aggregate.sum;
  const { atd_fatality_count: deathCount } = data.fatalities.aggregate.sum;

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
            header={commaSeparator(fatalitiesYTD)}
            mainText={`Fatalities in ${year}`}
            icon="fa fa-heartbeat"
            color="danger"
          />
        </Col>
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
            header={commaSeparator(seriousInjuriesYTD)}
            mainText={`Suspected Serious Injuries in ${year}`}
            icon="fa fa-medkit"
            color="warning"
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
      <Row className="mt-3">
        <Col xs="12" sm="6" md="6">
          <VZLinksWidget
            header={`Arterial Management Division Overview`}
            mainText={`Top location overview, by collision types and modes`}
            icon="fa fa-arrows"
            raster_icon={bi_logo}
            raster_icon_alt="Power BI"
            color="dark"
            link="https://app.powerbigov.us/links/GACOsce5fi?ctid=5c5e19f6-a6ab-4b45-b1d0-be4608a9a67f&pbi_source=linkShare"
            target="_bi_amd"
          />
          <VZLinksWidget
            header={`High Injury Roadways`}
            mainText={`Each High Injury Roadway by Polygon with various statistics`}
            icon="fa fa-road"
            raster_icon={bi_logo}
            raster_icon_alt="Power BI"
            color="dark"
            link="https://app.powerbigov.us/links/pdguGuhSGE?ctid=5c5e19f6-a6ab-4b45-b1d0-be4608a9a67f&pbi_source=linkShare"
            target="_bi_hir"
          />
          <VZLinksWidget
            header={`Emerging Hotspots and Bond Locations`}
            mainText={`Track crash impact of Vision Zero Bond Projects and changing crash trends`}
            icon="fa fa-exchange"
            raster_icon={bi_logo}
            raster_icon_alt="Power BI"
            color="dark"
            link="https://app.powerbigov.us/links/RmMrnaSMLp?ctid=5c5e19f6-a6ab-4b45-b1d0-be4608a9a67f&pbi_source=linkShare"
            target="_bi_hotspots"
          />
        </Col>
        <Col xs="12" sm="6" md="6">
          <VZLinksWidget
            header={`Comprehensive Costs by Location`}
            mainText={`Based on Vision Zero polygons`}
            icon="fa fa-map"
            color="primary"
            link="https://austin.maps.arcgis.com/apps/instant/interactivelegend/index.html?appid=32b276f4e6cd406aa1c2040d2eb26b37"
            target="_compcostmap"
          />
          <VZLinksWidget
            header={`Vision Zero Viewer`}
            mainText={`Public-facing insight into crash trends`}
            icon="fa fa-map"
            color="primary"
            link="https://visionzero.austin.gov/viewer/"
            target="_vzv"
          />
          <VZLinksWidget
            header={`Access Management Crashes`}
            mainText={`Summary of crashes for individual locations`}
            icon="fa fa-map"
            color="primary"
            link="https://austin.maps.arcgis.com/apps/instant/interactivelegend/index.html?appid=ea84226e6e5a4ecf998082b73b8c6cca"
            target="_arcgis"
          />
        </Col>
      </Row>
    </div>
  );
}

export default withApollo(VZDashboard);
