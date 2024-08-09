export const crashGridTableColumns = {
  record_locator: {
    primary_key: true,
    searchable: true,
    sortable: true,
    label_search: "Search by Crash ID",
    label_table: "Crash ID",
    type: "String",
  },
  case_id: {
    searchable: true,
    sortable: true,
    label_search: "Search by Case ID",
    label_table: "Case ID",
    type: "String",
  },
  crash_timestamp: {
    searchable: false,
    sortable: true,
    label_table: "Crash Date",
    type: "date_iso",
  },
  address_primary: {
    searchable: true,
    sortable: true,
    label_search: "Search by Primary Address",
    label_table: "Primary Address",
    type: "String",
  },
  address_secondary: {
    searchable: true,
    sortable: true,
    label_search: "Search by Secondary Address",
    label_table: "Secondary Address",
    type: "String",
  },
  sus_serious_injry_count: {
    searchable: false,
    sortable: true,
    label_table: "Sus Serious Injuries Count",
    type: "Int",
  },
  vz_fatality_count: {
    searchable: false,
    sortable: true,
    label_table: "Death Count",
    type: "Date",
  },
  est_comp_cost_crash_based: {
    searchable: false,
    sortable: true,
    label_table: "Est Comp Cost",
    type: "Currency",
  },
  collsn_desc: {
    searchable: false,
    sortable: true,
    label_table: "Collision Description",
    type: "String",
  },
};


export const locationCrashGridTableColumns = {
    record_locator: {
      primary_key: true,
      searchable: true,
      sortable: true,
      label_search: "Search by Crash ID",
      label_table: "Crash ID",
      type: "String",
    },
    case_id: {
      searchable: true,
      sortable: true,
      label_search: "Search by Case ID",
      label_table: "Case ID",
      type: "String",
    },
    crash_timestamp: {
      searchable: false,
      sortable: true,
      label_table: "Crash Date",
      type: "date_iso",
    },
    address_primary: {
      searchable: true,
      sortable: true,
      label_search: "Search by Primary Address",
      label_table: "Primary Address",
      type: "String",
    },
    address_secondary: {
      searchable: true,
      sortable: true,
      label_search: "Search by Secondary Address",
      label_table: "Secondary Address",
      type: "String",
    },
    sus_serious_injry_count: {
      searchable: false,
      sortable: true,
      label_table: "Suspected Serious Injury Count",
      type: "Int",
    },
    vz_fatality_count: {
      searchable: false,
      sortable: true,
      label_table: "Death Count",
      type: "Date",
    },
    est_comp_cost_crash_based: {
      searchable: false,
      sortable: true,
      label_table: "Est Comprehensive Cost",
      type: "Currency",
    },
    collsn_desc: {
      searchable: false,
      sortable: true,
      label_table: "Collision Description",
      type: "String",
    },
    "units { unit_desc { label } }": {
      searchable: false,
      sortable: false,
      label_table: "Unit Description",
      type: "String",
      hidden: true,
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
        label: "VZ Fatality Crashes",
        filter: {
          where: [
            {
              or: {
                vz_fatality_count: "_gt: 0",
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
                cris_fatality_count: "_gt: 0",
              },
            },
          ],
        },
      },
      {
        id: "dni_apd_deaths",
        label: "Law Enforcement Fatality Crashes",
        filter: {
          where: [
            {
              or: {
                law_enf_fatality_count: "_gt: 0",
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
                sus_serious_injry_count: "_gt: 0",
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
                nonincap_injry_count: "_gt: 0",
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
        id: "geo_afd",
        label: "Include Outside Of Austin Full Purpose",
        invert_toggle_state: true,
        filter: {
          where: [
            {
              in_austin_full_purpose: "_eq: true",
            },
          ],
        },
      },
    ],
  },
  groupUnitTypes: {
    icon: "bicycle",
    label: "Unit Type",
    filters: [
      {
        id: "motor_vehicle",
        label: "Motor Vehicle",
        filter: {
          where: [
            {
              [`
              units: {
                unit_desc_id: {
                  _eq: 1
                },
                veh_body_styl_id: {
                  _nin: [71, 90]
                },
              },
            `]: null,
            },
          ],
        },
      },
      {
        id: "motorcycle",
        label: "Motorcycle",
        filter: {
          where: [
            {
              [`
                units: {
                  unit_desc_id: {
                    _eq: 1
                  },
                  veh_body_styl_id: {
                    _in: [71, 90]
                  },
                },
              `]: null,
            },
          ],
        },
      },
      {
        id: "cyclist",
        label: "Cyclist",
        filter: {
          where: [
            {
              [`
                units: {
                  unit_desc_id: {
                    _eq: 3 
                  },
                },
              `]: null,
            },
          ],
        },
      },
      {
        id: "pedestrian",
        label: "Pedestrian",
        filter: {
          where: [
            {
              [`
                units: {
                  unit_desc_id: { 
                    _eq: 4 
                  },
                },
              `]: null,
            },
          ],
        },
      },
      {
        id: "scooter_rider",
        label: "E-Scooter Rider",
        filter: {
          where: [
            {
              [`
                units: {
                  unit_desc_id: { 
                    _eq: 177
                  },
                  veh_body_styl_id: {
                    _eq: 177
                  },
                },
              `]: null,
            },
          ],
        },
      },
      {
        id: "other",
        label: "Other",
        filter: {
          where: [
            {
              [`
              units: {
                unit_desc_id: {
                  _nin: [1, 3, 4]
                },
                _not: {
                  unit_desc_id: {
                    _eq: 177
                  },
                  veh_body_styl_id: {
                    _eq: 177
                  },
                },
              },
              `]: null,
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
              private_dr_fl: "_neq: true",
            },
          ],
        },
      },
    ],
  },
};
