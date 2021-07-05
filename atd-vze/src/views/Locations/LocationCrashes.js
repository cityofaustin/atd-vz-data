import React from "react";
import { withApollo } from "react-apollo";

import GridTable from "../../Components/GridTable";
import gqlAbstract from "../../queries/gqlAbstract";
import { crashQueryExportFields } from "../../queries/crashes";

import {
  crashGridTableColumns,
  crashGridTableAdvancedFilters,
} from "../Crashes/crashGridTableParameters";
import { colors } from "../../styles/colors";

function LocationCrashes(props) {
  // Our initial query configuration
  let queryConf = {
    table: "atd_txdot_crashes",
    single_item: "crashes",
    showDateRange: true,
    columns: crashGridTableColumns,
    order_by: {
      est_comp_cost_crash_based: "desc"
    },
    where: {
      location_id: `_eq: "${props.locationId}"`,
    },
    limit: 25,
    offset: 0,
  };

  let crashesQuery = new gqlAbstract(queryConf);

  let customFilters = crashGridTableAdvancedFilters;

  // Configuration for aggregate queries that drive <GridTableWidgets />
  const aggregateQueryConfig = [
    {
      table: "atd_txdot_crashes_aggregate",
      columns: [
        `count`,
        `sum { apd_confirmed_death_count
               est_comp_cost_crash_based }`,
      ],
    },
    {
      table: "atd_txdot_primaryperson_aggregate",
      columns: [
        `count`,
        `sum { sus_serious_injry_cnt
               years_of_life_lost }`,
      ],
      key: "crash",
    },
    {
      table: "atd_txdot_person_aggregate",
      columns: [
        `count`,
        `sum { sus_serious_injry_cnt
               years_of_life_lost }`,
      ],
      key: "crash",
    },
    {
      table: "atd_txdot_units_aggregate",
      columns: [`count`],
      key: "crash",
    },
  ];

  // Configuration for widget styles and data that populates them
  // Using lodash.get() here to expose nested data which requires
  // each node in object to be passed as an array of strings
  // Ex. reference for `test` in {a: {b: `test`}} is ["a", "b"]
  const widgetsConfig = [
    {
      mainText: "Fatalities",
      icon: "fa fa-heartbeat",
      color: "danger",
      dataPath: [
        "atd_txdot_crashes_aggregate",
        "aggregate",
        "sum",
        "apd_confirmed_death_count",
      ],
      sum: false, // Is the data a sum of multiple aggregates
    },
    {
      mainText: "Suspected Serious Injuries",
      icon: "fa fa-medkit",
      color: "warning",
      dataPath: [
        [
          "atd_txdot_primaryperson_aggregate",
          "aggregate",
          "sum",
          "sus_serious_injry_cnt",
        ],
        [
          "atd_txdot_person_aggregate",
          "aggregate",
          "sum",
          "sus_serious_injry_cnt",
        ],
      ],
      sum: true,
    },
    {
      mainText: "Years of Life Lost",
      icon: "fa fa-hourglass-end",
      color: "info",
      dataPath: [
        [
          "atd_txdot_primaryperson_aggregate",
          "aggregate",
          "sum",
          "years_of_life_lost",
        ],
        [
          "atd_txdot_person_aggregate",
          "aggregate",
          "sum",
          "years_of_life_lost",
        ],
      ],
      sum: true,
    },
    {
      mainText: "CR3 Crashes",
      icon: "fa fa-cab",
      color: "primary",
      dataPath: ["atd_txdot_crashes_aggregate", "aggregate", "count"],
      sum: false,
    },
    {
      mainText: "Total People (Primary + Non-Primary)",
      icon: "fa fa-user",
      color: "success",
      dataPath: [
        ["atd_txdot_primaryperson_aggregate", "aggregate", "count"],
        ["atd_txdot_person_aggregate", "aggregate", "count"],
      ],
      sum: true,
    },
    {
      mainText: "Total Comprehensive Cost",
      icon: "fa fa-usd",
      color: "dark",
      dataPath: [
        "atd_txdot_crashes_aggregate",
        "aggregate",
        "sum",
        "est_comp_cost_crash_based",
      ],
      sum: false,
      format: "dollars",
    },
  ];

  const chartConfig = [
    {
      type: "horizontal",
      totalRecordsPath: ["atd_txdot_crashes_aggregate", "aggregate", "count"],
      alert: "No crashes at this particular location",
      labels: [
        "ONE MOTOR VEHICLE - GOING STRAIGHT",
        "ONE MOTOR VEHICLE - TURNING RIGHT",
        "ONE MOTOR VEHICLE - TURNING LEFT",
        "ONE MOTOR VEHICLE - BACKING",
        "ONE MOTOR VEHICLE - OTHER",
        "ANGLE - BOTH GOING STRAIGHT",
        "ANGLE - ONE STRAIGHT-ONE BACKING",
        "ANGLE - ONE STRAIGHT-ONE STOPPED",
        "ANGLE - ONE STRAIGHT-ONE RIGHT TURN",
        "ANGLE - ONE STRAIGHT-ONE LEFT TURN",
        "ANGLE - BOTH RIGHT TURN",
        "ANGLE - ONE RIGHT TURN-ONE LEFT TURN",
        "ANGLE - ONE RIGHT TURN-ONE STOPPED",
        "ANGLE - BOTH LEFT TURN",
        "ANGLE - ONE LEFT TURN-ONE STOPPED",
        "SAME DIRECTION - BOTH GOING STRAIGHT-REAR END",
        "SAME DIRECTION - BOTH GOING STRAIGHT-SIDESWIPE",
        "SAME DIRECTION - ONE STRAIGHT-ONE STOPPED",
        "SAME DIRECTION - ONE STRAIGHT-ONE RIGHT TURN",
        "SAME DIRECTION - ONE STRAIGHT-ONE LEFT TURN",
        "SAME DIRECTION - BOTH RIGHT TURN",
        "SAME DIRECTION - ONE RIGHT TURN-ONE LEFT TURN",
        "SAME DIRECTION - ONE RIGHT TURN-ONE STOPPED",
        "SAME DIRECTION - BOTH LEFT TURN",
        "SAME DIRECTION - ONE LEFT TURN-ONE STOPPED",
        "OPPOSITE DIRECTION - BOTH GOING STRAIGHT",
        "OPPOSITE DIRECTION - ONE STRAIGHT-ONE BACKING",
        "OPPOSITE DIRECTION - ONE STRAIGHT-ONE STOPPED",
        "OPPOSITE DIRECTION - ONE STRAIGHT-ONE RIGHT TURN",
        "OPPOSITE DIRECTION - ONE STRAIGHT-ONE LEFT TURN",
        "OPPOSITE DIRECTION - ONE BACKING-ONE STOPPED",
        "OPPOSITE DIRECTION - ONE RIGHT TURN-ONE LEFT TURN",
        "OPPOSITE DIRECTION - ONE RIGHT TURN-ONE STOPPED",
        "OPPOSITE DIRECTION - BOTH LEFT TURNS",
        "OPPOSITE DIRECTION - ONE LEFT TURN-ONE STOPPED",
        "OTHER - ONE STRAIGHT-ONE ENTERING OR LEAVING PARKI",
        "OTHER - ONE RIGHT TURN-ONE ENTERING OR LEAVING PAR",
        "OTHER - ONE LEFT TURN-ONE ENTERING OR LEAVING PARK",
        "OTHER - ONE ENTERING OR LEAVING PARKING SPACE-ONE",
        "OTHER - BOTH ENTERING OR LEAVING A PARKING SPACE",
        "OTHER - BOTH BACKING",
        "OTHER",
      ],
      title: "Number of Collisions",
      header: "Manner of Collisions - Most Frequent",
      table: "atd_txdot_crashes",
      nestedKey: "collision",
      // Using lodash.get(), array is arg that translates to collision.collsn_desc
      nestedPath: ["collsn_desc"],
      // Is value of table.nestedKey.nestedPath a single record or array of objects
      isSingleRecord: true,
      // Top n types
      limit: 4,
      color: colors.success,
      hoverColor: colors.successDark,
    },
    {
      type: "horizontal",
      totalRecordsPath: ["atd_txdot_crashes_aggregate", "aggregate", "count"],
      alert: "No crashes at this particular location",
      labels: [
        "MOTOR VEHICLE",
        "TRAIN",
        "PEDALCYCLIST",
        "PEDESTRIAN",
        "MOTORIZED CONVEYANCE",
        "TOWED/PUSHED/TRAILER",
        "NON-CONTACT",
        "OTHER",
      ],
      title: "Types of Vehicles - Count Distribution",
      header: "Types of Vehicles - Count Distribution",
      table: "atd_txdot_crashes",
      nestedKey: "units",
      // Using lodash.get(), array is arg that translates to unit.unit_description.veh_unit_desc_desc
      nestedPath: ["unit_description", "veh_unit_desc_desc"],
      // Is value of table.nestedKey.nestedPath a single record or array of objects
      isSingleRecord: false,
      // Top n types
      limit: 4,
      color: colors.danger,
      hoverColor: colors.dangerDark,
    },
  ];

  return (
    <GridTable
      query={crashesQuery}
      title={"CR3 Crashes"}
      filters={customFilters}
      columnsToExport={crashQueryExportFields}
      aggregateQueryConfig={aggregateQueryConfig}
      widgetsConfig={widgetsConfig}
      chartConfig={chartConfig}
    />
  );
}

export default withApollo(LocationCrashes);
