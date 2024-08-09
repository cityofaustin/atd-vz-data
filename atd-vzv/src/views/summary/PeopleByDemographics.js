import React, { useEffect, useState, useReducer } from "react";
import axios from "axios";
import { HorizontalBar } from "react-chartjs-2";
import "chartjs-plugin-stacked100";
import ChartTypeSelector from "./Components/ChartTypeSelector";
import { Container, Row, Col } from "reactstrap";
import { format } from "date-fns";

import CrashTypeSelector from "./Components/CrashTypeSelector";
import { colors } from "../../constants/colors";
import { dataEndDate, yearsArray, dataStartDate } from "../../constants/time";
import { personEndpointUrl } from "./queries/socrataQueries";
import InfoPopover from "../../Components/Popover/InfoPopover";
import { popoverConfig } from "../../Components/Popover/popoverConfig";
import ColorSpinner from "../../Components/Spinner/ColorSpinner";

const url = `${personEndpointUrl}?$query=`;

const dateCondition = `crash_timestamp_ct BETWEEN '${format(
  dataStartDate,
  "yyyy-MM-dd"
)}T00:00:00' and '${format(dataEndDate, "yyyy-MM-dd")}T23:59:59'`;

const chartColors = [
  colors.viridis1Of6Highest,
  colors.viridis2Of6,
  colors.viridis3Of6,
  colors.viridis4Of6,
  colors.viridis5Of6,
  colors.viridis6Of6Lowest,
];

const chartConfigs = {
  raceData: {
    label: "Race/Ethnicity",
    categoryKey: "prsn_ethnicity_id", // Field used to filter data
    categoryType: "target", // Filter response data by target value or ranges of values
    socrataCategories: ["1", "2", "3", "4", "5", "6"], // Use array so we can control order in chart and legend
    labelCategories: [
      "White",
      "Hispanic",
      "Black",
      "Asian",
      "Other or unknown",
      "American Indian or Alaska Native",
    ],
    exceptionCategory: "Other or unknown", // Category for missing or unknown data
    query: `SELECT date_extract_y(crash_timestamp_ct) as year, COUNT(*) as total, prsn_ethnicity_id, prsn_injry_sev_id
              WHERE ${dateCondition}
              GROUP BY year, prsn_ethnicity_id, prsn_injry_sev_id
              ORDER BY year`,
    colors: chartColors,
  },
  ageData: {
    label: "Age",
    categoryKey: "prsn_age",
    categoryType: "range",
    socrataCategories: [
      [0, 15],
      [16, 25],
      [26, 35],
      [36, 45],
      [46, 55],
      [56, 64],
      [65, Number.POSITIVE_INFINITY],
      [null, null],
    ],
    labelCategories: [
      "0 to 15",
      "16 to 25",
      "26 to 35",
      "36 to 45",
      "46 to 55",
      "56 to 64",
      "65 or greater",
      "Unknown",
    ],
    exceptionCategory: "Unknown",
    query: `SELECT date_extract_y(crash_timestamp_ct) as year, COUNT(*) as total, prsn_age, prsn_injry_sev_id
              WHERE ${dateCondition}
              GROUP BY year, prsn_age, prsn_injry_sev_id
              ORDER BY year`,
    colors: [
      colors.demoAge1of8,
      colors.demoAge2of8,
      colors.demoAge3of8,
      colors.demoAge4of8,
      colors.demoAge5of8,
      colors.demoAge6of8,
      colors.demoAge7of8,
      colors.demoAge8of8,
    ],
  },
  sexData: {
    label: "Sex",
    categoryKey: "prsn_sex_id",
    categoryType: "target",
    socrataCategories: ["1", "2", "0"],
    labelCategories: ["Male", "Female", "Unknown"],
    exceptionCategory: "Unknown",
    query: `SELECT date_extract_y(crash_timestamp_ct) as year, COUNT(*) as total, prsn_sex_id, prsn_injry_sev_id
              WHERE ${dateCondition}
              GROUP BY year, prsn_sex_id, prsn_injry_sev_id
              ORDER BY year`,
    colors: chartColors,
  },
};

const PeopleByDemographics = () => {
  const [chartType, setChartType] = useState("Race/Ethnicity");
  const [crashType, setCrashType] = useState(null);
  const [chartData, setChartData] = useState({});
  const [demoData, demoDataDispatch] = useReducer(demoDataReducer, {});

  function demoDataReducer(demoData, action) {
    switch (action.type) {
      case "setData":
        return { ...demoData, ...action.payload };
      default:
        return null;
    }
  }

  // Fetch data for each visualization in config
  useEffect(() => {
    if (crashType !== null && Object.keys(demoData).length === 0) {
      const requests = Object.entries(chartConfigs).map(([dataKey, config]) =>
        axios.get(url + encodeURIComponent(config.query), {
          dataKey,
        })
      );

      axios.all(requests).then((resArr) => {
        const responses = resArr.reduce(
          (acc, res) => ({ ...acc, ...{ [res.config.dataKey]: res.data } }),
          {}
        );

        demoDataDispatch({
          type: "setData",
          payload: responses,
        });
      });
    }
  }, [crashType, demoData]);

  // Sort data and filter data after fetch
  useEffect(() => {
    const sortByType = (data) => {
      const typeMap = { injury: "1", fatal: "4" };

      return data.reduce(
        (acc, record) => {
          record.prsn_injry_sev_id === typeMap.fatal &&
            acc.fatalities.push(record);

          record.prsn_injry_sev_id === typeMap.injury &&
            acc.seriousInjuries.push(record);

          acc.fatalitiesAndSeriousInjuries.push(record);

          return acc;
        },
        {
          seriousInjuries: [],
          fatalities: [],
          fatalitiesAndSeriousInjuries: [],
        }
      );
    };

    const formatChartData = (dataKey, data) => {
      const {
        exceptionCategory,
        categoryKey,
        labelCategories,
        socrataCategories,
        categoryType,
      } = chartConfigs[dataKey];
      const isTarget = categoryType === "target";
      const isRange = categoryType === "range";
      const years = yearsArray();
      const currentYear = years[years.length - 1];

      const formattedTypes = {};

      Object.entries(data).forEach(([typeLabel, typeData]) => {
        let formatted = {};

        labelCategories.forEach((category) => {
          const categoryData = [];
          for (let i = 0; i < years.length; i++) {
            categoryData.push(0);
          }

          formatted[category] = categoryData;
        });

        const getYearIndex = (currentYear, recordYear) =>
          years.length - 1 - (currentYear - parseInt(recordYear));

        if (isTarget) {
          typeData.forEach((record) => {
            const categoryValue = record[categoryKey];
            const categoryIndex = socrataCategories.indexOf(categoryValue);
            const labelCategory = labelCategories[categoryIndex];
            const yearIndex = getYearIndex(currentYear, record.year);

            if (categoryIndex < 0 || categoryValue === undefined) {
              formatted[exceptionCategory][yearIndex] += parseInt(record.total);
            } else {
              formatted[labelCategory][yearIndex] += parseInt(record.total);
            }
          });
        }

        if (isRange) {
          typeData.forEach((record) => {
            socrataCategories.forEach((rangeArray, i) => {
              const label = labelCategories[i];
              const floor = rangeArray[0];
              const ceiling = rangeArray[1];
              const age = parseInt(record.prsn_age);
              const total = parseInt(record.total);
              const yearIndex = getYearIndex(currentYear, record.year);
              const isRangeDefined = floor !== null && ceiling !== null;

              if (!isRangeDefined && Number.isNaN(age)) {
                formatted[exceptionCategory][yearIndex] += total;
              } else if (isRangeDefined && age >= floor && age <= ceiling) {
                formatted[label][yearIndex] += total;
              }
            });
          });
        }

        formattedTypes[typeLabel] = formatted;
      });

      return formattedTypes;
    };

    // After data is fetched, sort and format into years/categories
    if (Object.keys(demoData).length !== 0 && demoData.status !== "formatted") {
      Object.entries(demoData).forEach(([dataKey, data]) => {
        const sorted = sortByType(data);
        const formatted = formatChartData(dataKey, sorted);

        demoDataDispatch({
          type: "setData",
          payload: { [dataKey]: formatted, status: "formatted" },
        });
      });
    }
  }, [chartType, demoData, crashType]);

  // On crash or chart type change, replace chart data and colors from config
  useEffect(() => {
    if (demoData.status === "formatted") {
      const [configName, config] = Object.entries(chartConfigs).find(
        ([configName, config]) => config.label === chartType
      );

      const data = {
        labels: yearsArray(),
        datasets: config.labelCategories.map((category, i) => ({
          label: config.labelCategories[i],
          data: demoData[configName][crashType.name][category],
          backgroundColor: config.colors[i],
          borderColor: config.colors[i],
          hoverBackgroundColor: config.colors[i],
          hoverBorderColor: config.colors[i],
        })),
      };

      setChartData(data);
    }
  }, [demoData, chartType, crashType]);

  return (
    <Container className="m-0 p-0">
      <Row>
        <Col>
          <h2 className="text-left font-weight-bold">
            By Demographics{" "}
            <InfoPopover config={popoverConfig.summary.demographics} />
          </h2>
        </Col>
      </Row>
      <Row>
        <Col>
          <CrashTypeSelector
            setCrashType={setCrashType}
            componentName="PeopleByDemographics"
          />
        </Col>
      </Row>
      <Row>
        <Col>
          <hr />
        </Col>
      </Row>
      {!!chartData.datasets ? (
        <div>
          <ChartTypeSelector
            chartTypes={Object.values(chartConfigs).map((value) => value.label)}
            chartType={chartType}
            setChartType={setChartType}
          />
          <Row>
            <Col>
              <HorizontalBar
                redraw
                data={chartData}
                height={null}
                width={null}
                options={{
                  responsive: true,
                  aspectRatio: 1,
                  maintainAspectRatio: false,
                  plugins: {
                    // Imported to display percentages without calculating them from data
                    stacked100: { enable: true, replaceTooltipLabel: false },
                  },
                  tooltips: {
                    callbacks: {
                      label: (tooltipItem, data) => {
                        const datasetIndex = tooltipItem.datasetIndex;
                        const datasetLabel = data.datasets[datasetIndex].label;
                        const originalValue =
                          data.originalData[datasetIndex][tooltipItem.index];
                        const rateValue =
                          data.calculatedData[datasetIndex][tooltipItem.index];
                        return `${datasetLabel}: ${originalValue} (${rateValue}%)`;
                      },
                    },
                  },
                }}
              />
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

export default PeopleByDemographics;
