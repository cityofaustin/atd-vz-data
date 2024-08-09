import React from "react";
import { withApollo } from "react-apollo";

import GridTable from "../../Components/GridTable";
import gqlAbstract from "../../queries/gqlAbstract";
import { locationCrashesQueryExportFieldsNonCR3 } from "../../queries/crashes";
import { nonCR3CrashGridTableColumns } from "../Crashes/crashGridTableParameters";

function LocationNonCR3Crashes(props) {
  // Our initial query configuration
  let queryConf = {
    table: "atd_apd_blueform",
    dateField: "date",
    single_item: "crashes",
    showDateRange: true,
    columns: nonCR3CrashGridTableColumns,
    order_by: {},
    where: {
      location_id: `_eq: "${props.locationId}"`,
    },
    limit: 25,
    offset: 0,
  };

  let crashesQuery = new gqlAbstract(queryConf);

  return (
    <GridTable
      query={crashesQuery}
      title={"Non-CR3 Crashes"}
      columnsToExport={locationCrashesQueryExportFieldsNonCR3}
    />
  );
}

export default withApollo(LocationNonCR3Crashes);
