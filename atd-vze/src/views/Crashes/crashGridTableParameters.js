export const crashGridTableColumns = {
  crash_id: {
    primary_key: true,
    searchable: true,
    sortable: true,
    label_search: "Search by Crash ID",
    label_table: "Crash ID",
    type: "Int",
  },
  case_id: {
    searchable: true,
    sortable: true,
    label_search: "Search by Case ID",
    label_table: "Case ID",
    type: "String",
  },
  crash_date: {
    searchable: false,
    sortable: true,
    label_table: "Crash Date",
    type: "Date",
  },
  address_confirmed_primary: {
    searchable: true,
    sortable: true,
    label_search: "Search by Primary Address",
    label_table: "Primary Address",
    type: "String",
  },
  address_confirmed_secondary: {
    searchable: true,
    sortable: true,
    label_search: "Search by Secondary Address",
    label_table: "Secondary Address",
    type: "String",
  },
  sus_serious_injry_cnt: {
    searchable: false,
    sortable: true,
    label_table: "Suspected Serious Injury Count",
    type: "Int",
  },
  atd_fatality_count: {
    searchable: false,
    sortable: true,
    label_table: "ATD Death Count",
    type: "Date",
  },
  est_comp_cost_crash_based: {
    searchable: false,
    sortable: true,
    label_table: "Est Comprehensive Cost",
    type: "Currency",
  },
  "collision { collsn_desc } ": {
    searchable: false,
    sortable: true,
    label_table: "Collision Description",
    type: "String",
  },
  "units { unit_description { veh_unit_desc_desc } }": {
    searchable: false,
    sortable: false,
    label_table: "Unit Description",
    type: "String",
    hidden: true,
  },
  "geocode_method { name }": {
    searchable: false,
    sortable: true,
    label_table: "Geocode Provider",
    type: "String",
  },
};

export const nonCR3CrashGridTableColumns = {
  case_id: {
    primary_key: false, // We say no here bc there is no page to link to
    searchable: true,
    sortable: true,
    label_search: "Search by Case ID",
    label_table: "Case ID",
    type: "Int",
  },
  date: {
    primary_key: false,
    searchable: false,
    sortable: true,
    label_table: "Crash Date",
    type: "Date",
  },
  hour: {
    primary_key: false,
    searchable: false,
    sortable: false,
    label_table: "Hour of Day",
    type: "Int",
  },
  address: {
    primary_key: false,
    searchable: false,
    sortable: true,
    label_search: "Search by Address",
    label_table: "Address",
    type: "String",
  },
  speed_mgmt_points: {
    primary_key: false,
    searchable: false,
    sortable: true,
    label_table: "Speed Management Points",
    type: "Int",
  },
  est_comp_cost_crash_based: {
    primary_key: false,
    searchable: false,
    sortable: true,
    label_table: "Est Comprehensive Cost",
    type: "Currency",
  },
  est_econ_cost: {
    primary_key: false,
    searchable: false,
    sortable: true,
    label_table: "Est Economic Cost",
    type: "Currency",
  },
};

export const crashGridTableAdvancedFilters = {
  groupInjuries: {
    icon: "cab",
    label: "Deaths & Injuries",
    filters: [
      {
        id: "dni_atd_deaths",
        label: "ATD Fatality Crashes",
        filter: {
          where: [
            {
              or: {
                atd_fatality_count: "_gt: 0",
              },
            },
          ],
        },
      },
      {
        id: "dni_cris_deaths",
        label: "CRIS Fatality Crashes",
        filter: {
          where: [
            {
              or: {
                death_cnt: "_gt: 0",
              },
            },
          ],
        },
      },
      {
        id: "dni_apd_deaths",
        label: "APD Confirmed Fatality Crashes",
        filter: {
          where: [
            {
              or: {
                apd_confirmed_death_count: "_gt: 0",
              },
            },
          ],
        },
      },
      {
        id: "dni_serious_injuries",
        label: "Suspected Serious Injury Crashes",
        filter: {
          where: [
            {
              or: {
                sus_serious_injry_cnt: "_gt: 0",
              },
            },
          ],
        },
      },
      {
        id: "dni_non_fatal",
        label: "Non-Incapacitating Injury Crashes",
        filter: {
          where: [
            {
              or: {
                nonincap_injry_cnt: "_gt: 0",
              },
            },
          ],
        },
      },
    ],
  },
  groupGeography: {
    icon: "map-marker",
    label: "Geography",
    filters: [
      {
        id: "geo_no_coordinates",
        label: "No Primary Coordinates",
        filter: {
          where: [
            {
              latitude_primary: "_is_null: true",
            },
            {
              longitude_primary: "_is_null: true",
            },
          ],
        },
      },
      {
        id: "geo_geocoded",
        label: "Has Been Geocoded",
        filter: {
          where: [
            {
              geocoded: '_eq: "Y"',
            },
          ],
        },
      },
      {
        id: "geo_confirmed_coordinates",
        label: "No CRIS Coordinates",
        filter: {
          where: [
            {
              latitude: "_is_null: true",
            },
            {
              longitude: "_is_null: true",
            },
          ],
        },
      },
      {
        id: "geo_afd",
        label: "Include Outside Of Austin Full Purpose",
        invert_toggle_state: true,
        filter: {
          where: [
            {
              austin_full_purpose: '_eq: "Y"',
            },
          ],
        },
      },
    ],
  },
  groupUnitTypes: {
    icon: "bicycle",
    label: "Units Involved",
    filters: [
      {
        id: "pedestrian",
        label: "Pedestrian Involved",
        filter: {
          where: [
            {
              'units: { unit_description: { veh_unit_desc_desc: { _eq: "PEDESTRIAN" } } }': null,
            },
          ],
        },
      },
      {
        id: "pedacyclist",
        label: "Cyclist Involved",
        filter: {
          where: [
            {
              'units: { unit_description: { veh_unit_desc_desc: { _eq: "PEDALCYCLIST" } } }': null,
            },
          ],
        },
      },
      {
        id: "motorized_conveyance",
        label: "Motorized Conveyance Involved",
        filter: {
          where: [
            {
              'units: { unit_description: { veh_unit_desc_desc: { _eq: "MOTORIZED CONVEYANCE" } } }': null,
            },
          ],
        },
      },
    ],
  },
  groupCase: {
    icon: "vcard-o",
    label: "Internal",
    filters: [
      {
        id: "int_nocasenumber",
        label: "No Case Number",
        filter: {
          where: [
            {
              case_id: "_is_null: true",
            },
          ],
        },
      },
      {
        id: "int_excludeprivdrive",
        label: "Include Private Driveway Crashes",
        invert_toggle_state: true,
        filter: {
          where: [
            {
              private_dr_fl: '_neq: "Y"',
            },
          ],
        },
      },
    ],
  },
};
