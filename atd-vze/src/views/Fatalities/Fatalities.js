import React from "react";
import { withApollo } from "react-apollo";

import { subYears } from "date-fns";
import GridTable from "../../Components/GridTable";
import gqlAbstract from "../../queries/gqlAbstract";
import {
  fatalityGridTableColumns,
  fatalityGridTableAdvancedFilters,
  fatalityExportFields,
} from "./fatalityGridTableParameters";

// Our initial query configuration
let queryConf = {
  table: "view_fatalities",
  dateField: "crash_date",
  single_item: "crashes",
  showDateRange: true,
  columns: fatalityGridTableColumns,
  order_by: {},
  where: {},
  limit: 25,
  offset: 0,
  options: {
    useQuery: {
      fetchPolicy: "cache-and-network",
    },
  },
};

const minDate = subYears(new Date(), 10);

const fatalitiesQuery = new gqlAbstract(queryConf);

const Fatalities = () => {
  return (
    <GridTable
      query={fatalitiesQuery}
      title={"Fatalities"}
      minDate={minDate}
      filters={fatalityGridTableAdvancedFilters}
      columnsToExport={fatalityExportFields}
    />
  );
};

export default withApollo(Fatalities);
