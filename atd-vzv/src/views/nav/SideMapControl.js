import React, { useEffect, useState } from "react";
import { StoreContext } from "../../utils/store";
import "react-infinite-calendar/styles.css";

import SideMapControlDateRange from "./SideMapControlDateRange";
import SideMapTimeOfDayChart from "./SideMapTimeOfDayChart";
import SideMapControlOverlays from "./SideMapControlOverlays";
import { colors } from "../../constants/colors";
import { ButtonGroup, Button, Card, Label } from "reactstrap";
import styled from "styled-components";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faWalking,
  faBiking,
  faCar,
  faMotorcycle
} from "@fortawesome/free-solid-svg-icons";

const StyledCard = styled.div`
  font-size: 1.2em;

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
`;

const SideMapControl = () => {
  const {
    mapFilters: [filters, setFilters]
  } = React.useContext(StoreContext);

  const [filterGroupCounts, setFilterGroupCounts] = useState({});

  // Define groups of map filters
  const mapButtonFilters = {
    // TODO Extract fatal/serious injury logic
    // TODO Use type button choice to insert fatalSyntax/injurySyntax/both
    mode: {
      pedestrian: {
        icon: faWalking, // Font Awesome icon object
        fatalSyntax: `pedestrian_death_count > 0`, // Socrata SoQL query string
        injurySyntax: `pedestrian_serious_injury_count > 0`,
        type: `where`, // Socrata SoQL query type
        operator: `OR`, // Logical operator for joining multiple query strings
        default: true // Apply filter as default on render
      },
      pedalcyclist: {
        icon: faBiking,
        fatalSyntax: `bicycle_death_count > 0`,
        injurySyntax: `bicycle_serious_injury_count > 0`,
        type: `where`,
        operator: `OR`,
        default: true
      },
      motor: {
        icon: faCar,
        fatalSyntax: `motor_vehicle_death_count > 0`,
        injurySyntax: `motor_vehicle_serious_injury_count > 0`,
        type: `where`,
        operator: `OR`,
        default: true
      },
      motorcycle: {
        icon: faMotorcycle,
        fatalSyntax: `motorcycle_death_count > 0`,
        injurySyntax: `motorcycle_serious_injury_count > 0`,
        type: `where`,
        operator: `OR`,
        default: true
      },
      other: {
        text: "Other",
        fatalSyntax: `other_death_count > 0`,
        injurySyntax: `other_serious_injury_count > 0`,
        type: `where`,
        operator: `OR`,
        default: true
      }
    }
  };

  const mapOtherFilters = {
    timeOfDay: {
      // Labels and corresponding time windows considering HH:00 to HH:59 notation
      "12AM–4AM": [0, 3],
      "4AM–8AM": [4, 7],
      "8AM–12PM": [8, 11],
      "12PM–4PM": [12, 15],
      "4PM–8PM": [16, 19],
      "8PM–12AM": [20, 23]
    }
  };

  // Reduce all filters and set defaults as active on render
  useEffect(() => {
    // If no filters are applied (initial render), set all default filters
    if (Object.keys(filters).length === 0) {
      const initialFiltersArray = Object.entries(mapButtonFilters).reduce(
        (allFiltersAccumulator, [type, filtersGroup]) => {
          const groupFilters = Object.entries(filtersGroup).reduce(
            (groupFiltersAccumulator, [name, filterConfig]) => {
              // Apply filter only if set as a default on render
              if (filterConfig.default) {
                filterConfig["name"] = name;
                filterConfig["group"] = type;
                groupFiltersAccumulator.push(filterConfig);
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
      setFilters(initialFiltersArray);
    }
  }, [mapButtonFilters, setFilters, filters]);

  // Set count of filters applied to keep one of each type applied at all times
  useEffect(() => {
    const filtersCount = filters.reduce((accumulator, filter) => {
      if (accumulator[filter.group]) {
        accumulator = {
          ...accumulator,
          [filter.group]: accumulator[filter.group] + 1
        };
      } else {
        accumulator = { ...accumulator, [filter.group]: 1 };
      }
      return accumulator;
    }, {});
    setFilterGroupCounts(filtersCount);
  }, [filters]);

  const isFilterSet = filterName => {
    return !!filters.find(setFilter => setFilter.name === filterName);
  };

  const isOneFilterOfGroupApplied = group => filterGroupCounts[group] > 1;

  // Set filter or remove if already set
  const handleFilterClick = (event, filterGroup) => {
    const filterName = event.currentTarget.id;

    if (isFilterSet(filterName)) {
      // Always leave one filter applied per group
      const updatedFiltersArray = isOneFilterOfGroupApplied(filterGroup)
        ? filters.filter(setFilter => setFilter.name !== filterName)
        : filters;
      setFilters(updatedFiltersArray);
    } else {
      const filter = mapButtonFilters[filterGroup][filterName];
      // Add filterName and group to object for IDing and grouping
      filter["name"] = filterName;
      filter["group"] = filterGroup;
      const filtersArray = [...filters, filter];
      setFilters(filtersArray);
    }
  };

  return (
    <StyledCard>
      <div className="card-title">Traffic Crashes</div>
      <Card className="p-3 card-body">
        <Label className="section-title">Filters</Label>
        {/* Create a button group for each group of mapFilters */}
        {Object.entries(mapButtonFilters).map(([group, groupParameters], i) => (
          <ButtonGroup key={i} className="mb-3 d-flex" id={`${group}-buttons`}>
            {/* Create buttons for each filter within a group of mapFilters */}
            {Object.entries(groupParameters).map(([name, parameter], i) => (
              <Button
                key={i}
                id={name}
                color="info"
                className="w-100 pt-1 pb-1 pl-0 pr-0"
                onClick={event => handleFilterClick(event, group)}
                active={isFilterSet(name)}
                outline={!isFilterSet(name)}
              >
                {parameter.icon && (
                  <FontAwesomeIcon
                    icon={parameter.icon}
                    className="mr-1 ml-1"
                  />
                )}
                {parameter.text}
              </Button>
            ))}
          </ButtonGroup>
        ))}
        <SideMapControlDateRange />
        <SideMapTimeOfDayChart filters={mapOtherFilters.timeOfDay} />
      </Card>
      <SideMapControlOverlays />
    </StyledCard>
  );
};

export default SideMapControl;
