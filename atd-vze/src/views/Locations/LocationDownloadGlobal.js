import React from "react";

import GridExportDataButton from "../../Components/GridExportDataButton";
import gqlAbstract from "../../queries/gqlAbstract";
import { useQuery } from "@apollo/react-hooks";
import { gql } from "apollo-boost";

const LocationDownloadGlobal = props => {
  const columnsToExport = `
        address_primary
        address_secondary
        case_id
        collsn_desc
        crash_date
        crash_id
        crash_sev_id
        crash_time
        day_of_week
        est_comp_cost_crash_based
        latitude
        location_id
        longitude
        movement_desc
        non_injry_count
        nonincap_injry_count
        poss_injry_count
        sus_serious_injry_count
        tot_injry_count
        travel_direction
        type
        unkn_injry_count
        veh_body_styl_desc
        veh_unit_desc
        vz_fatality_count
    `;

  const crashesQuery = new gqlAbstract({
    table: "location_crashes_view",
    single_item: "crashes",
    showDateRange: false,
    columns: null,
    order_by: {},
    where: {
      location_id: `_eq: "${props.locationId}"`,
    },
    limit: 25,
    offset: 0,
  });

  const getGlobalCount = gql`
    query getGlobalCount($locationId: String) {
      view_location_crashes_global_aggregate(
        where: { location_id: { _eq: $locationId } }
        order_by: {}
      ) {
        aggregate {
          count
        }
      }
    }
  `;

  const { data } = useQuery(getGlobalCount, {
    variables: { locationId: props.locationId },
  });

  return (
    <>
      {data &&
        Object.keys(data).includes(
          "view_location_crashes_global_aggregate"
        ) && (
          <GridExportDataButton
            query={crashesQuery}
            columnsToExport={columnsToExport}
            totalRecords={
              data.view_location_crashes_global_aggregate.aggregate.count
            }
            label={"Download crashes"}
          />
        )}
    </>
  );
};

export default LocationDownloadGlobal;
