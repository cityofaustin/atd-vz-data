import { gql } from "apollo-boost";

// This query is derived from the view that populates our Socrata dataset
// so that the VZV and VZE widget totals match up
export const GET_CRASHES_YTD = gql`
  query GetCrashesYTD($yearStart: String!) {
    socrata_export_crashes_view_aggregate(
      where: { crash_timestamp: { _gte: $yearStart } }
    ) {
      aggregate {
        sum {
          death_cnt
        }
      }
      aggregate {
        sum {
          sus_serious_injry_cnt
        }
      }
      aggregate {
        sum {
          years_of_life_lost
        }
      }
    }
  }
`;
