import React from "react";
import { withApollo } from "react-apollo";
import { useAuth0, isAdmin, isItSupervisor } from "../../auth/authContext";

import { subYears } from "date-fns";
import GridTable from "../../Components/GridTable";
import gqlAbstract from "../../queries/gqlAbstract";
import { crashQueryExportFields } from "../../queries/crashes";
import {
  crashGridTableColumns,
  crashGridTableAdvancedFilters,
} from "./crashGridTableParameters";

// Our initial query configuration
let queryConf = {
  table: "crashes_list_view",
  dateField: "crash_date_ct",
  single_item: "crashes",
  showDateRange: true,
  columns: crashGridTableColumns,
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

let crashesQuery = new gqlAbstract(queryConf);

let customFilters = crashGridTableAdvancedFilters;

const minDate = subYears(new Date(), 10);

const adminColumns = [
  "recommendation { rec_text }",
  "recommendation { rec_update }",
  "recommendation { atd__recommendation_status_lkp { rec_status_desc } }",
  "recommendation { recommendations_partners { atd__coordination_partners_lkp { coord_partner_desc }} }",
];

const Crashes = () => {
  const { getRoles } = useAuth0();
  const roles = getRoles();
  const isAdminOrItSupervisor = isAdmin(roles) || isItSupervisor(roles);
  return (
    <GridTable
      query={crashesQuery}
      title={"Crashes"}
      filters={customFilters}
      columnsToExport={crashQueryExportFields}
      minDate={minDate}
      roleSpecificColumns={adminColumns}
      hasSpecificRole={isAdminOrItSupervisor}
      defaultSearchField="record_locator"
    />
  );
};

export default withApollo(Crashes);
