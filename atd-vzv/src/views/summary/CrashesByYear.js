import React, { useState, useEffect } from "react";
import axios from "axios";
import CrashesByYearCumulative from "./CrashesByYearCumulative";
import CrashesByYearAverage from "./CrashesByYearAverage";
import ChartTypeSelector from "./Components/ChartTypeSelector";
import { Container, Row, Col } from "reactstrap";

import CrashTypeSelector from "./Components/CrashTypeSelector";
import InfoPopover from "../../Components/Popover/InfoPopover";
import { popoverConfig } from "../../Components/Popover/popoverConfig";
import { crashEndpointUrl } from "./queries/socrataQueries";
import {
  fiveYearAvgStartDate,
  fiveYearAvgEndDate,
  summaryCurrentYearEndDate,
  summaryCurrentYearStartDate,
} from "../../constants/time";
import ColorSpinner from "../../Components/Spinner/ColorSpinner";

const CrashesByYear = () => {
  const chartTypes = ["Monthly", "Cumulative"];

  const [crashType, setCrashType] = useState(null);
  const [chartType, setChartType] = useState("Monthly");

  const [avgData, setAvgData] = useState([]);
  const [currentYearData, setCurrentYearData] = useState([]);

  const url = `${crashEndpointUrl}?$query=`;

  // Fetch data for By Month Average and Cumulative visualizations
  useEffect(() => {
    const avgDateCondition = `crash_timestamp_ct BETWEEN '${fiveYearAvgStartDate}T00:00:00' and '${fiveYearAvgEndDate}T23:59:59'`;
    const currentYearDateCondition = `crash_timestamp_ct BETWEEN '${summaryCurrentYearStartDate}T00:00:00' and '${summaryCurrentYearEndDate}T23:59:59'`;
    const queryGroupAndOrder = `GROUP BY month ORDER BY month`;

    const avgQueries = {
      fatalities: `SELECT date_extract_m(crash_timestamp_ct) as month, sum(death_cnt) / 5 as avg 
                   WHERE death_cnt > 0 AND ${avgDateCondition} ${queryGroupAndOrder}`,
      fatalitiesAndSeriousInjuries: `SELECT date_extract_m(crash_timestamp_ct) as month, sum(death_cnt) / 5 + sum(sus_serious_injry_cnt) / 5 as avg 
                                     WHERE (death_cnt > 0 OR sus_serious_injry_cnt > 0) AND ${avgDateCondition} ${queryGroupAndOrder}`,
      seriousInjuries: `SELECT date_extract_m(crash_timestamp_ct) as month, sum(sus_serious_injry_cnt) / 5 as avg 
                        WHERE sus_serious_injry_cnt > 0 AND ${avgDateCondition} ${queryGroupAndOrder}`,
    };

    const currentYearQueries = {
      fatalities: `SELECT date_extract_m(crash_timestamp_ct) as month, sum(death_cnt) as total 
                   WHERE death_cnt > 0 AND ${currentYearDateCondition} ${queryGroupAndOrder}`,
      fatalitiesAndSeriousInjuries: `SELECT date_extract_m(crash_timestamp_ct) as month, sum(death_cnt) + sum(sus_serious_injry_cnt) as total 
                                     WHERE (death_cnt > 0 OR sus_serious_injry_cnt > 0) AND ${currentYearDateCondition} ${queryGroupAndOrder}`,
      seriousInjuries: `SELECT date_extract_m(crash_timestamp_ct) as month, sum(sus_serious_injry_cnt) as total 
                        WHERE sus_serious_injry_cnt > 0 AND ${currentYearDateCondition} ${queryGroupAndOrder}`,
    };

    !!crashType &&
      axios
        .get(url + encodeURIComponent(avgQueries[crashType.name]))
        .then((res) => {
          setAvgData(res.data);
        });

    !!crashType &&
      axios
        .get(url + encodeURIComponent(currentYearQueries[crashType.name]))
        .then((res) => {
          setCurrentYearData(res.data);
        });
  }, [crashType, url]);

  const renderChartByType = (chartType) => {
    switch (chartType) {
      case "Monthly":
        return (
          <CrashesByYearAverage
            crashType={crashType}
            avgData={avgData}
            currentYearData={currentYearData}
          />
        );
      case "Cumulative":
        return (
          <CrashesByYearCumulative
            crashType={crashType}
            avgData={avgData}
            currentYearData={currentYearData}
          />
        );
      default:
        return "No chart selected";
    }
  };

  return (
    <Container className="m-0 p-0">
      <Row>
        <Col>
          <h2 className="text-left font-weight-bold">
            By Year & Month{" "}
            <InfoPopover config={popoverConfig.summary.byYear} />
          </h2>
        </Col>
      </Row>
      <Row>
        <Col>
          <CrashTypeSelector
            setCrashType={setCrashType}
            componentName="CrashesByYear"
          />
        </Col>
      </Row>
      <Row>
        <Col>
          <hr />
        </Col>
      </Row>
      {avgData.length > 0 && currentYearData.length > 0 ? (
        <div>
          <ChartTypeSelector
            chartTypes={chartTypes}
            chartType={chartType}
            setChartType={setChartType}
          />
          <Row className="mt-1">
            <Col>{renderChartByType(chartType)}</Col>
          </Row>
        </div>
      ) : (
        <h1>
          <ColorSpinner />
        </h1>
      )}
    </Container>
  );
};

export default CrashesByYear;
