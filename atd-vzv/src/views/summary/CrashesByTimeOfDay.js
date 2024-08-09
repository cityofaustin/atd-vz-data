import React, { useCallback, useState, useEffect } from "react";
import axios from "axios";
import { format, parseISO, sub } from "date-fns";
import clonedeep from "lodash.clonedeep";

import CrashTypeSelector from "./Components/CrashTypeSelector";
import { Row, Col, Container, Button } from "reactstrap";
import styled from "styled-components";
import classnames from "classnames";
import {
  Heatmap,
  HeatmapSeries,
  HeatmapCell,
  ChartTooltip,
  SequentialLegend,
  LinearXAxis,
  LinearXAxisTickSeries,
  LinearXAxisTickLabel,
} from "reaviz";
import {
  summaryCurrentYearStartDate,
  summaryCurrentYearEndDate,
  yearsArray,
  dataStartDate,
  dataEndDate,
} from "../../constants/time";
import { crashEndpointUrl } from "./queries/socrataQueries";
import { getYearsAgoLabel } from "./helpers/helpers";
import { colors } from "../../constants/colors";
import ColorSpinner from "../../Components/Spinner/ColorSpinner";

const dayOfWeekArray = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

const hourBlockArray = [...Array(24).keys()].map((hour) =>
  format(new Date().setHours(hour), "hha")
);

/**
 * Build an array of objs for each hour window that holds totals of each day of the week
 * @returns {Array} Array of objs for each hour window that holds totals of each day of the week
 */
const buildDataArray = () => {
  // This array holds weekday totals for each hour window within a day
  // Reaviz Heatmap expects array of weekday total objs to be reversed in order
  const hourWindowTotalsByDay = dayOfWeekArray
    .map((day) => ({ key: day, data: null })) // Initialize totals as null to unweight 0 in viz
    .reverse();

  return hourBlockArray.map((hour) => ({
    key: hour,
    data: clonedeep(hourWindowTotalsByDay),
  }));
};

/**
 * Calculate the figures to populate the heatmap cells
 * @param {*} records - Array of crash records returned from the Socrata query
 * @param {Object} crashType - Object containing query and name details (see CrashTypeSelector component)
 * @returns
 */

const calculateHourBlockTotals = (records, crashType) => {
  const dataArray = buildDataArray();

  records.forEach((record) => {
    const recordDateTime = parseISO(record.crash_timestamp_ct);
    const recordHour = format(recordDateTime, "hha");
    const recordDay = format(recordDateTime, "E");

    const hourData = dataArray.find((hour) => hour.key === recordHour).data;
    const dayToIncrement = hourData.find((day) => day.key === recordDay);

    switch (crashType.name) {
      case "fatalities":
        dayToIncrement.data += parseInt(record.death_cnt);
        break;
      case "seriousInjuries":
        dayToIncrement.data += parseInt(record.sus_serious_injry_cnt);
        break;
      default:
        dayToIncrement.data +=
          parseInt(record.death_cnt) + parseInt(record.sus_serious_injry_cnt);
        break;
    }
  });

  return dataArray;
};

/**
 * Generate the query url for the Socrata query based on the active tab and crash type
 * @param {Number} activeTab - The active tab index that corresponds to year option selected
 * @param {Object} crashType - Object containing query and name details (see CrashTypeSelector component)
 * @returns {String} The query url for the Socrata query
 */
const getFatalitiesByYearsAgoUrl = (activeTab, crashType) => {
  const yearsAgoDate = format(sub(new Date(), { years: activeTab }), "yyyy");
  let queryUrl =
    activeTab === 0
      ? `${crashEndpointUrl}?$where=${crashType.queryStringCrash} AND crash_timestamp_ct between '${summaryCurrentYearStartDate}T00:00:00' and '${summaryCurrentYearEndDate}T23:59:59'`
      : `${crashEndpointUrl}?$where=${crashType.queryStringCrash} AND crash_timestamp_ct between '${yearsAgoDate}-01-01T00:00:00' and '${yearsAgoDate}-12-31T23:59:59'`;
  return queryUrl;
};

const CrashesByTimeOfDay = () => {
  const [activeTab, setActiveTab] = useState(0);
  const [crashType, setCrashType] = useState([]);
  const [heatmapData, setHeatmapData] = useState([]);
  const [heatmapDataWithPlaceholder, setHeatmapDataWithPlaceholder] = useState(
    []
  );
  const [maxForLegend, setMaxForLegend] = useState(null);

  const toggle = (tab) => {
    if (activeTab !== tab) setActiveTab(tab);
  };

  useEffect(() => {
    if (!crashType.queryStringCrash) return;

    axios.get(getFatalitiesByYearsAgoUrl(activeTab, crashType)).then((res) => {
      const formattedData = calculateHourBlockTotals(res.data, crashType);
      setHeatmapData(formattedData);
    });
  }, [activeTab, crashType]);

  // Query to find maximum day total per crash type
  useEffect(() => {
    if (maxForLegend) return;

    const maxQuery = `
    SELECT date_extract_dow(crash_timestamp_ct) as day, date_extract_hh(crash_timestamp_ct) as hour, date_extract_y(crash_timestamp_ct) as year, SUM(death_cnt) as death, SUM(sus_serious_injry_cnt) as serious, serious + death as all 
    WHERE crash_timestamp_ct BETWEEN '${format(
      dataStartDate,
      "yyyy-MM-dd"
    )}' and '${summaryCurrentYearEndDate}' 
    GROUP BY day, hour, year 
    ORDER BY year 
    |> 
    SELECT max(death) as fatalities, max(serious) as seriousInjuries, max(all) as fatalitiesAndSeriousInjuries
    `;

    axios
      .get(crashEndpointUrl + `?$query=` + encodeURIComponent(maxQuery))
      .then((res) => {
        setMaxForLegend(res.data[0]);
      });
  }, [maxForLegend, crashType]);

  // When crashType changes, add a placeholder column containing max values to weight each year consistently
  useEffect(() => {
    const lastRecordInHeatmapData = heatmapData[heatmapData.length - 1];
    const isPlaceholderArraySet =
      lastRecordInHeatmapData && lastRecordInHeatmapData.key === "";

    if (!maxForLegend || heatmapData.length === 0 || isPlaceholderArraySet)
      return;

    const placeholderArray = heatmapData[0].data.map((data, i) => ({
      key: dayOfWeekArray[i],
      data: maxForLegend[crashType.name],
      // Add this metadata to find which cells to hide in the callback ref below
      metadata: { isPlaceholder: true },
    }));

    const placeholderObjForChartWeighting = {
      key: "",
      data: placeholderArray,
    };

    const updatedWeightingData = [
      ...heatmapData,
      placeholderObjForChartWeighting,
    ];

    setHeatmapDataWithPlaceholder(updatedWeightingData);
  }, [maxForLegend, heatmapData, crashType]);

  // Hide placeholder cells with a callback ref
  const heatmapCellRef = useCallback((node) => {
    // Look for the isPlaceholder metadata that we placed there to identify the cells to hide
    if (node?.props?.data?.metadata?.isPlaceholder) {
      // Update the cell's style to hide it and its tooltip
      node.rect.current.style.visibility = "hidden";
    }
  }, []);

  const formatValue = (d) => {
    const value = d.data.value ? d.data.value : 0;
    return value;
  };

  // Set styles to override Bootstrap default styling
  const StyledButton = styled.div`
    .year-selector {
      color: ${colors.dark};
      background: ${colors.buttonBackground} 0% 0% no-repeat padding-box;
      border-style: none;
      opacity: 1;
      margin-left: 5px;
      margin-right: 5px;
    }
  `;

  return (
    <Container className="m-0 p-0">
      <Row>
        <Col>
          <h2 className="text-left, font-weight-bold">By Time of Day</h2>
        </Col>
      </Row>
      <Row>
        <Col>
          <CrashTypeSelector
            setCrashType={setCrashType}
            componentName="CrashesByTimeOfDay"
          />
        </Col>
      </Row>
      <Row>
        <Col>
          <hr />
        </Col>
      </Row>
      {!!heatmapDataWithPlaceholder.length > 0 ? (
        <div>
          <Row className="text-center">
            <Col className="pb-2">
              <StyledButton>
                {yearsArray() // Calculate years ago for each year in data window
                  .map((year) => {
                    const currentYear = parseInt(format(dataEndDate, "yyyy"));
                    return currentYear - year;
                  })
                  .map((yearsAgo) => (
                    <Button
                      key={yearsAgo}
                      className={classnames(
                        { active: activeTab === yearsAgo },
                        "year-selector"
                      )}
                      onClick={() => {
                        toggle(yearsAgo);
                      }}
                    >
                      {getYearsAgoLabel(yearsAgo)}
                    </Button>
                  ))}
              </StyledButton>
            </Col>
          </Row>
          <Row className="h-auto">
            <Col id="demographics-heatmap" className="pl-4">
              <Heatmap
                height={267}
                data={heatmapDataWithPlaceholder}
                series={
                  <HeatmapSeries
                    colorScheme={[
                      colors.intensity2Of5,
                      colors.intensity3Of5,
                      colors.intensity4Of5,
                      colors.viridis1Of6Highest,
                    ]}
                    emptyColor={colors.intensity1Of5Lowest}
                    cell={
                      <HeatmapCell
                        // This ref is needed to hide placeholder cells
                        ref={heatmapCellRef}
                        tooltip={
                          <ChartTooltip
                            content={(d) =>
                              `${d.x} ∙
                          ${formatValue(d)}`
                            }
                          />
                        }
                      />
                    }
                  />
                }
                xAxis={
                  <LinearXAxis
                    type="category"
                    axisLine={null}
                    tickSeries={
                      <LinearXAxisTickSeries
                        line={null}
                        label={
                          <LinearXAxisTickLabel
                            padding={
                              navigator.userAgent.includes("Firefox") ? 15 : 5
                            }
                          />
                        }
                      />
                    }
                  />
                }
              />
            </Col>
          </Row>
          <Row>
            <Col className="py-2">
              {!!maxForLegend && (
                <SequentialLegend
                  data={[
                    { key: "Max", data: maxForLegend[crashType.name] },
                    { key: "Min", data: 0 },
                  ]}
                  orientation="horizontal"
                  colorScheme={[
                    colors.intensity1Of5Lowest,
                    colors.viridis1Of6Highest,
                  ]}
                />
              )}
            </Col>
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

export default CrashesByTimeOfDay;
