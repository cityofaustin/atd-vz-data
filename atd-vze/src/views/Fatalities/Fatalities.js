import React from "react";
import { withApollo } from "react-apollo";

import GridTable from "../../Components/GridTable";
import gqlAbstract from "../../queries/gqlAbstract";
import { fatalityGridTableColumns } from "./fatalityGridTableParameters";

// Our initial query configuration
let queryConf = {
  options: {
    useQuery: {
      fetchPolicy: "no-cache",
    },
  },
  table: "view_fatalities",
  single_item: "crashes",
  showDateRange: false,
  columns: fatalityGridTableColumns,
  order_by: {},
  where: {},
  limit: 25,
  offset: 0,
};

const fatalitiesQuery = new gqlAbstract(queryConf);

const Fatalities = () => {
  return <GridTable query={fatalitiesQuery} title={"Fatalities"} />;
};

export default withApollo(Fatalities);
