import React from "react";
import { withApollo } from "react-apollo";
import { format, subYears } from "date-fns";

import GridTable from "../../Components/GridTable";
import gqlAbstract from "../../queries/gqlAbstract";
import { locationQueryExportFields } from "../../queries/locations";

// Our initial query configuration
let queryConf = {
  table: "locations_list_view",
  single_item: "locations",
  showDateRange: false,
  columns: {
    location_id: {
      primary_key: true,
      searchable: true,
      sortable: true,
      label_search: "Search by location id",
      label_table: "Location ID",
      type: "Integer",
    },
    description: {
      searchable: true,
      sortable: true,
      label_search: "Search by intersecting street name",
      label_table: "Location",
      type: "String",
    },
    cr3_crash_count: {
      searchable: false,
      sortable: true,
      label_search: null,
      label_table: "CR3 Crashes",
      default: 0,
      type: "Integer",
    },
    non_cr3_crash_count: {
        searchable: false,
        sortable: true,
        label_search: null,
        label_table: "Non-CR3 Crashes",
        default: 0,
        type: "Integer",
      },
  },
  order_by: {
    cr3_crash_count: "desc_nulls_last",
  },
  where: {},
  limit: 25,
  offset: 0,
  options: {
    useQuery: {
      fetchPolicy: "cache-and-network",
    },
  },
};

const dateRangeStart = format(subYears(new Date(), 5), "MM/dd/yyyy");
const dateRangeEnd = format(new Date(), "MM/dd/yyyy");
const helperText = `Totals calculated using the previous five years of crash data (${dateRangeStart} - ${dateRangeEnd})`;

let locationsQuery = new gqlAbstract(queryConf);

const Locations = () => (
  <GridTable
    query={locationsQuery}
    title={"Locations"}
    columnsToExport={locationQueryExportFields}
    helperText={helperText}
  />
);

export default withApollo(Locations);
