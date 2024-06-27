import React, { useEffect } from "react";
import { StoreContext } from "../../utils/store";

import SideMapControlDateRange from "./SideMapControlDateRange";
import SideMapTimeOfDayChart from "./SideMapTimeOfDayChart";
import SideMapControlOverlays from "./SideMapControlOverlays";
import SideMapFooter from "./SideMapFooter";
import { trackPageEvent } from "../../constants/nav";
import InfoPopover from "../../Components/Popover/InfoPopover";
import { popoverConfig } from "../../Components/Popover/popoverConfig";
import { colors } from "../../constants/colors";
import { Button, Card, Label, Row, Col } from "reactstrap";
import styled from "styled-components";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faWalking,
  faBiking,
  faCar,
  faMotorcycle,
  faHeartbeat,
  faMedkit,
  faMobileAlt,
  faEllipsisH,
  faCheckSquare,
} from "@fortawesome/free-solid-svg-icons";
import { faSquare } from "@fortawesome/free-regular-svg-icons";

// Keep type buttons from wrapping on Windows (scroll bar takes extra width)
const typeFilterTextSize = navigator.appVersion.indexOf("Win") !== -1 ? 12 : 14;

const StyledCard = styled.div`
  font-size: 1rem;

  .card-title {
    font-weight: bold;
    color: ${colors.white};
  }

  .section-title {
    font-size: 1em;
    color: ${colors.dark};
  }

  .card-body {
    background: ${colors.white};
  }

  .filter-button {
    min-width: 38px;
  }

  .type-button {
    font-size: ${typeFilterTextSize}px;
    color: ${colors.dark};
    background: ${colors.buttonBackground};
    border-style: none;
    border-radius: 18px;
    opacity: 1;
    margin-right: 2px;
    padding-right: 6px !important;
    height: 33px;
  }
  [class^="DateInput_"] {
    text-align: center;
  }

  .outlined {
    border: 1px solid ${colors.dark};
    border-radius: 4px;
  }

  .dark-checkbox {
    cursor: pointer;
    box-shadow: none !important;

    .active,
    .inactive {
      color: ${colors.dark} !important;
    }
  }

  .dark-checkbox:hover {
    .active,
    .inactive {
      color: ${colors.secondary} !important;
    }
  }
`;

// Build query string for crash type filter
const createModeFilterString = (isMapTypeSet, config) => {
  if (isMapTypeSet.fatal && isMapTypeSet.injury) {
    return `${config.fatalSyntax} ${config.operator} ${config.injurySyntax}`;
  } else if (isMapTypeSet.fatal) {
    return `${config.fatalSyntax}`;
  } else if (isMapTypeSet.injury) {
    return `${config.injurySyntax}`;
  }
};

export const mapFilterReducer = (mapFilters, action) => {
  const { type, payload } = action;

  switch (type) {
    case "setInitialModeFilters":
      const initialFiltersArray = payload;
      return initialFiltersArray;
    case "updateModeSyntax":
      const isMapTypeSet = payload;

      const updatedModeFilters = mapFilters.map((filter) => ({
        ...filter,
        syntax: createModeFilterString(isMapTypeSet, filter),
      }));
      return updatedModeFilters;
    case "updateModeFilters":
      const updatedFiltersArray = payload;
      return updatedFiltersArray;
    default:
      return null;
  }
};

const SideMapControl = ({ type }) => {
  const {
    mapFilters: [filters, dispatchFilters],
    mapFilterType: [isMapTypeSet, setIsMapTypeSet],
  } = React.useContext(StoreContext);

  const setTypeFilters = (typeArray) => {
    // Set types in array as true and others as false
    const updatedState = Object.keys(isMapTypeSet).reduce((acc, type) => {
      if (typeArray.includes(type)) {
        acc = { ...acc, [type]: true };
      } else {
        acc = { ...acc, [type]: false };
      }
      return acc;
    }, {});

    setIsMapTypeSet(updatedState);
  };

  // Update mode syntax (fatal, injury, or both) when type filter updates
  useEffect(() => {
    dispatchFilters({ type: "updateModeSyntax", payload: isMapTypeSet });
  }, [isMapTypeSet, dispatchFilters]);

  const handleTypeFilterClick = (filterArr) => {
    setTypeFilters(filterArr);
    // Track single filter clicks with Google Analytics
    filterArr.length === 1 && trackPageEvent(filterArr[0]);
  };

  // Define groups of map button filters
  const mapFiltersConfig = {
    type: {
      shared: {
        eachClass: `type-button`,
        uiType: "button",
      },
      each: {
        all: {
          text: `All`,
          colSize: "auto",
          handler: () => handleTypeFilterClick(["injury", "fatal"]),
          isSelected: isMapTypeSet.injury && isMapTypeSet.fatal,
          default: false,
        },
        fatal: {
          text: `Fatal`,
          colSize: "auto",
          icon: faHeartbeat,
          iconColor: colors.fatalities,
          handler: () => handleTypeFilterClick(["fatal"]),
          isSelected: isMapTypeSet.fatal && !isMapTypeSet.injury,
          default: false,
        },
        seriousInjury: {
          text: `Serious Injuries`,
          colSize: "auto",
          icon: faMedkit,
          iconColor: colors.seriousInjuries,
          handler: () => handleTypeFilterClick(["injury"]),
          isSelected: isMapTypeSet.injury && !isMapTypeSet.fatal,
          default: false,
        },
      },
    },
    mode: {
      shared: {
        uiType: "checkbox",
        allClass: "outlined py-2 px-0",
        eachClass: "dark-checkbox",
      },
      each: {
        pedestrian: {
          icon: faWalking, // Font Awesome icon object
          fatalSyntax: `pedestrian_death_count > 0`, // Fatality query string
          injurySyntax: `pedestrian_serious_injury_count > 0`, // Injury query string
          type: `where`, // Socrata SoQL query type
          operator: `OR`, // Logical operator for joining multiple query strings
          default: true, // Apply filter as default on render
        },
        bicyclist: {
          icon: faBiking,
          fatalSyntax: `bicycle_death_count > 0`,
          injurySyntax: `bicycle_serious_injury_count > 0`,
          type: `where`,
          operator: `OR`,
          default: true,
        },
        motorist: {
          icon: faCar,
          fatalSyntax: `motor_vehicle_death_count > 0`,
          injurySyntax: `motor_vehicle_serious_injury_count > 0`,
          type: `where`,
          operator: `OR`,
          default: true,
        },
        motorcyclist: {
          icon: faMotorcycle,
          fatalSyntax: `motorcycle_death_count > 0`,
          injurySyntax: `motorcycle_serious_injury_count > 0`,
          type: `where`,
          operator: `OR`,
          default: true,
        },
        scooter: {
          text: "E-Scooter Rider",
          icon: faMobileAlt,
          fatalSyntax: `micromobility_death_count > 0`,
          injurySyntax: `micromobility_serious_injury_count > 0`,
          type: `where`,
          operator: `OR`,
          default: true,
        },
        other: {
          icon: faEllipsisH,
          fatalSyntax: `other_death_count > 0`,
          injurySyntax: `other_serious_injury_count > 0`,
          type: `where`,
          operator: `OR`,
          default: true,
        },
      },
    },
  };

  const mapOtherFilters = {
    timeOfDay: {
      // Labels and corresponding time windows considering HH:00 to HH:59 notation
      "12AM–4AM": [0, 3],
      "4AM–8AM": [4, 7],
      "8AM–12PM": [8, 11],
      "12PM–4PM": [12, 15],
      "4PM–8PM": [16, 19],
      "8PM–12AM": [20, 23],
    },
  };

  // Set initial filters
  useEffect(() => {
    if (filters.length !== 0) return;

    const namedAndGroupedFilters = Object.entries(mapFiltersConfig).reduce(
      (allFiltersAccumulator, [type, filtersGroup]) => {
        const groupFilters = Object.entries(filtersGroup.each).reduce(
          (groupFiltersAccumulator, [name, filterConfig]) => {
            // Apply filter only if set as a default on render
            if (filterConfig.default) {
              filterConfig["name"] = name;
              filterConfig["group"] = type;
              groupFiltersAccumulator.push(filterConfig);
            }

            // Set initial query syntax for each mode filter
            if (type === "mode") {
              filterConfig["syntax"] = createModeFilterString(
                isMapTypeSet,
                filterConfig
              );
            }

            return groupFiltersAccumulator;
          },
          []
        );
        allFiltersAccumulator = [...allFiltersAccumulator, ...groupFilters];
        return allFiltersAccumulator;
      },
      []
    );

    dispatchFilters({
      type: "setInitialModeFilters",
      payload: namedAndGroupedFilters,
    });
  }, [mapFiltersConfig, dispatchFilters, filters, isMapTypeSet]);

  const isFilterSet = (filterName) =>
    filters.find((setFilter) => setFilter.name === filterName);

  // Set filter or remove if already set
  const handleFilterClick = (event, filterGroup) => {
    const filterName = event.currentTarget.id;
    let updatedFiltersArray;

    if (isFilterSet(filterName)) {
      // Always leave one filter applied per group
      updatedFiltersArray =
        filters.length > 1
          ? filters.filter((setFilter) => setFilter.name !== filterName)
          : filters;
    } else {
      const filter = mapFiltersConfig[filterGroup].each[filterName];
      // Add filterName and group to object for IDing and grouping and create query syntax
      filter["name"] = filterName;
      filter["group"] = filterGroup;
      filter["syntax"] = createModeFilterString(isMapTypeSet, filter);
      updatedFiltersArray = [...filters, filter];
    }

    dispatchFilters({
      type: "updateModeFilters",
      payload: updatedFiltersArray,
    });
  };

  return (
    <StyledCard>
      <h3 className="h4 card-title">
        Traffic Crashes{" "}
        <InfoPopover config={popoverConfig.map.trafficCrashes} />
      </h3>
      <Card className="p-3 card-body">
        <Label className="section-title">
          <h3 className="h5">Filters</h3>
        </Label>
        {/* Create a button group for each group of mapFilters */}
        {Object.entries(mapFiltersConfig).map(([group, groupParameters], i) => (
          <Row
            className={`mx-0 mb-3 ${groupParameters.shared.allClass || ""}`}
            key={`${group}-buttons`}
          >
            {/* Create buttons for each filter within a group of mapFilters */}
            {Object.entries(groupParameters.each).map(
              ([name, parameter], i) => {
                const eachClassName = groupParameters.shared.eachClass || "";
                const title = name[0].toUpperCase() + name.slice(1);

                switch (groupParameters.shared.uiType) {
                  case "button":
                    return (
                      <Col
                        xs={parameter.colSize && parameter.colSize}
                        className="px-0"
                        key={name}
                      >
                        <Button
                          key={name}
                          id={name}
                          color="dark"
                          className={`p-1 filter-button ${eachClassName}`}
                          onClick={
                            parameter.handler
                              ? parameter.handler
                              : (event) => handleFilterClick(event, group)
                          }
                          active={
                            parameter.isSelected
                              ? parameter.isSelected
                              : isFilterSet(name)
                          }
                          outline={
                            parameter.isSelected
                              ? !parameter.isSelected
                              : !isFilterSet(name)
                          }
                        >
                          {parameter.icon && (
                            <FontAwesomeIcon
                              icon={parameter.icon}
                              className="mr-1 ml-1"
                              color={parameter.iconColor && parameter.iconColor}
                            />
                          )}
                          {parameter.text}
                        </Button>
                      </Col>
                    );
                  case "checkbox":
                    return (
                      <Col xs={12} key={name}>
                        <Button
                          id={name}
                          color="link"
                          className={`text-dark py-1 px-0 ${
                            groupParameters.shared.eachClass || ""
                          }`}
                          onClick={
                            parameter.handler
                              ? parameter.handler
                              : (event) => handleFilterClick(event, group)
                          }
                          title={`${title} filter`}
                        >
                          {parameter.isSelected || isFilterSet(name) ? (
                            <FontAwesomeIcon
                              icon={faCheckSquare}
                              className="mr-1 active far"
                            />
                          ) : (
                            <FontAwesomeIcon
                              icon={faSquare}
                              className="mr-1 inactive far"
                            />
                          )}
                          {parameter.icon && (
                            <FontAwesomeIcon
                              icon={parameter.icon}
                              className="mr-2 ml-2 fa-fw"
                              color={parameter.iconColor && parameter.iconColor}
                            />
                          )}
                          {parameter.text ?? title}
                        </Button>
                      </Col>
                    );
                  default:
                    return null;
                }
              }
            )}
          </Row>
        ))}
        <SideMapControlDateRange type={type} />
        <SideMapTimeOfDayChart timeWindowConfig={mapOtherFilters.timeOfDay} />
      </Card>
      <SideMapControlOverlays />
      <SideMapFooter />
    </StyledCard>
  );
};

export default SideMapControl;
