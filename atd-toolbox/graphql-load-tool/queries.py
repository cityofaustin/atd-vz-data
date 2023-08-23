crash_listing_query = """
{
  records: atd_txdot_crashes(
    limit: {{ limit }},
    offset: {{ offset }},
    order_by: { {{ order_by }} },
    where: {
      crash_date: { {{ crash_date }} },
      in_austin_full_purpose: { _eq: true },
      private_dr_fl: { _neq: "Y" },
      _or: [
        {
          _and: [
            { units: { unit_desc_id: { _eq: 1 } } },
            {
              _and: [
                { units: { veh_body_styl_id: { _neq: 71 } } },
                { units: { veh_body_styl_id: { _neq: 90 } } }
              ]
            }
          ]
        },
        {
          _and: [
            { units: { unit_desc_id: { _eq: 1 } } },
            {
              _or: [
                { units: { veh_body_styl_id: { _eq: 71 } } },
                { units: { veh_body_styl_id: { _eq: 90 } } }
              ]
            }
          ]
        },
        { units: { unit_desc_id: { _eq: 3 } } },
        { units: { unit_desc_id: { _eq: 4 } } },
        {
          _and: [
            { units: { unit_desc_id: { _eq: 177 } } },
            { units: { veh_body_styl_id: { _eq: 177 } } }
          ]
        }
      ]
    }
  ) {
    crash_id
    case_id
    crash_date
    address_confirmed_primary
    address_confirmed_secondary
    sus_serious_injry_cnt
    atd_fatality_count
    est_comp_cost_crash_based
    collision {
      collsn_desc
      __typename
    }
    units {
      unit_description {
        veh_unit_desc_desc
        __typename
      }
      __typename
    }
    geocode_method {
      name
      __typename
    }
    __typename
  }
  atd_txdot_crashes_aggregate(
    where: {
      crash_date: { {{ crash_date }} },
      in_austin_full_purpose: { _eq: true },
      private_dr_fl: { _neq: "Y" },
      _or: [
        {
          _and: [
            { units: { unit_desc_id: { _eq: 1 } } },
            {
              _and: [
                { units: { veh_body_styl_id: { _neq: 71 } } },
                { units: { veh_body_styl_id: { _neq: 90 } } }
              ]
            }
          ]
        },
        {
          _and: [
            { units: { unit_desc_id: { _eq: 1 } } },
            {
              _or: [
                { units: { veh_body_styl_id: { _eq: 71 } } },
                { units: { veh_body_styl_id: { _eq: 90 } } }
              ]
            }
          ]
        },
        { units: { unit_desc_id: { _eq: 3 } } },
        { units: { unit_desc_id: { _eq: 4 } } },
        {
          _and: [
            { units: { unit_desc_id: { _eq: 177 } } },
            { units: { veh_body_styl_id: { _eq: 177 } } }
          ]
        }
      ]
    }
  ) {
    aggregate {
      count
      __typename
    }
    __typename
  }
}
"""



locations_listing_query = """
{
  records: locations_with_crash_injury_counts(
    limit: {{ limit }},
    offset: {{ offset }}, 
    order_by: {total_est_comp_cost: desc_nulls_last}, 
    where: {}) {
    location_id description crash_count fatalities_count serious_injury_count total_est_comp_cost __typename
  }
  locations_with_crash_injury_counts_aggregate(where: {}) {
    aggregate { count __typename } __typename
  }
}



"""


fatalities_listing_query = """

{
  records: view_fatalities(
    limit: {{ limit }},
    offset: {{ offset }}, 
    order_by: {},
    where: {
      crash_date: { {{ crash_date }} },
      }
  ) {
    year
    crash_id
    case_id
    law_enforcement_num
    ytd_fatal_crash
    ytd_fatality
    crash_date
    location
    victim_name
    recommendation {
      atd__recommendation_status_lkp {
        rec_status_desc
        __typename
      }
      __typename
    }
    recommendation {
      rec_text
      __typename
    }
    engineering_area
    __typename
  }
  view_fatalities_aggregate(
    where: {
      crash_date: { {{ crash_date }} },
      }
  ) {
    aggregate {
      count
      __typename
    }
    __typename
  }
}

"""