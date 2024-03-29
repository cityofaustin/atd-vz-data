export const fatalityGridTableColumns = {
  year: {
    searchable: false,
    sortable: true,
    label_table: "Year",
    type: "Int",
  },
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
    type: "Int",
  },
  law_enforcement_num: {
    searchable: false,
    sortable: false,
    label_table: "Law Enforcement Number",
    type: "Int",
  },
  ytd_fatal_crash: {
    searchable: false,
    sortable: false,
    label_table: "YTD Fatal Crashes",
    type: "Int",
  },
  ytd_fatality: {
    searchable: false,
    sortable: false,
    label_table: "YTD Fatalities",
    type: "Int",
  },
  crash_date: {
    searchable: false,
    sortable: true,
    label_table: "Crash Date",
    type: "Date",
  },
  location: {
    searchable: true,
    sortable: false,
    label_search: "Search by Location",
    label_table: "Location",
    type: "String",
  },
  victim_name: {
    searchable: true,
    sortable: false,
    label_search: "Search by Victim Name",
    label_table: "Victim Name",
    type: "String",
  },
  "recommendation { atd__recommendation_status_lkp { rec_status_desc } }": {
    searchable: false,
    sortable: false,
    label_table: "Current FRB Status",
    type: "String",
  },
  "recommendation { rec_text }": {
    searchable: false,
    sortable: false,
    label_table: "FRB Recommendation",
    type: "String",
  },
  engineering_area: {
    searchable: true,
    sortable: true,
    label_table: "Current Engineering Area",
    type: "String",
    label_search: "Search by Current Engineering Area",
  },
};

export const fatalityGridTableAdvancedFilters = {
  groupUnits: {
    icon: "bicycle",
    label: "Unit Type",
    filters: [
      {
        id: "motor_vehicle",
        label: "Motor Vehicle Fatality",
        filter: {
          where: [
            {
              // Wrapped in array brackets so that the template literal can function as an object key
              [`
                person: {
                  unit: {
                    unit_desc_id: {
                      _eq: 1 
                    },
                    veh_body_styl_id: {
                      _nin: [71, 90]
                    },
                  },
                }
              },
              {
                primaryperson: {
                  unit: {
                    unit_desc_id: { 
                      _eq: 1
                    },
                    veh_body_styl_id: {
                      _nin: [71, 90]
                    },
                  },
                },
              `]: null
            },
          ],
        },
      },
      {
        id: "motorcyclist",
        label: "Motorcyclist Fatality",
        filter: {
          where: [
            {
              [`
                person: { 
                  unit: {
                    unit_desc_id: {
                      _eq: 1
                    },
                    veh_body_styl_id: {
                      _in: [71, 90]
                    },
                  },
                },
              },
              {
                primaryperson: {
                  unit: {
                    unit_desc_id: {
                      _eq: 1
                    },
                    veh_body_styl_id: {
                      _in: [71, 90]
                    },
                  },
                },
              `]: null
            },
          ],
        },
      },
      {
        id: "cyclist",
        label: "Cyclist Fatality",
        filter: {
          where: [
            {
              [`
                person: {
                  unit: { 
                    unit_desc_id: {
                      _eq: 3
                    },
                  },
                },
              },
              {
                primaryperson: {
                  unit: { 
                    unit_desc_id: {
                      _eq: 3
                    },
                  },
                },
              `]: null,
            },
          ],
        },
      },
      {
        id: "pedestrian",
        label: "Pedestrian Fatality",
        filter: {
          where: [
            {
              [`
                person: {
                  unit: {
                    unit_desc_id: {
                      _eq: 4 
                    },
                  },
                },
              },
              {
                primaryperson: {
                  unit: {
                    unit_desc_id: {
                      _eq: 4
                    },
                  },
                },
              `]: null,
            },
          ],
        },
      },
      {
        id: "scooter",
        label: "E-Scooter Rider Fatality",
        filter: {
          where: [
            {
              [`
                person: { 
                  unit: {
                    unit_desc_id: {
                      _eq: 177
                    },
                    veh_body_styl_id: {
                      _eq: 177
                    },
                  },
                },
              },
              {
                primaryperson: {
                  unit: {
                    unit_desc_id: {
                      _eq: 177
                    },
                    veh_body_styl_id: {
                      _eq: 177 
                    },
                  },
                },
              `]: null
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
                _or: [
                  {
                    primaryperson: {
                      unit: {
                        unit_desc_id: {_nin: [1, 3, 4]},
                        _not: {
                          unit_desc_id: {_eq: 177},
                          veh_body_styl_id: {_eq: 177}
                        },
                      },
                    },
                  },
                  {
                    person: {
                      unit: {
                        unit_desc_id: {_nin: [1, 3, 4]},
                        _not: {
                          unit_desc_id: {_eq: 177},
                          veh_body_styl_id: {_eq: 177}
                        },
                      },
                    },
                  },
                ]
              `]: null
            },
          ],
        },
      },
    ],
  },
  groupStatus: {
    icon: "clipboard",
    label: "Status",
    filters: [
      {
        id: "status_open_short_term",
        label: "Open - Short Term",
        filter: {
          where: [
            {
              "recommendation: { recommendation_status_id: { _eq: 1 } } ": null,
            },
          ],
        },
      },
      {
        id: "status_open_long_term",
        label: "Open - Long Term",
        filter: {
          where: [
            {
              "recommendation: { recommendation_status_id: { _eq: 2 } } ": null,
            },
          ],
        },
      },
      {
        id: "status_closed_no_action_rec",
        label: "Closed - No Action Recommended",
        filter: {
          where: [
            {
              "recommendation: { recommendation_status_id: { _eq: 3 } } ": null,
            },
          ],
        },
      },
      {
        id: "status_closed_rec_implemented",
        label: "Closed - Recommendation Implemented",
        filter: {
          where: [
            {
              "recommendation: { recommendation_status_id: { _eq: 4 } } ": null,
            },
          ],
        },
      },
      {
        id: "status_closed_no_action_taken",
        label: "Closed - No Action Taken",
        filter: {
          where: [
            {
              "recommendation: { recommendation_status_id: { _eq: 5 } } ": null,
            },
          ],
        },
      },
      {
        id: "status_none",
        label: "None",
        filter: {
          where: [
            {
              "_not: { recommendation: {recommendation_status_id: { _is_null: false } } }": null,
            },
          ],
        },
      },
    ],
  },
  groupRoad: {
    icon: "road",
    label: "Roadway System",
    filters: [
      {
        id: "on_system",
        label: "On-System",
        filter: {
          where: [
            {
              'crash: { onsys_fl: { _eq: "Y" } }': null,
            },
          ],
        },
      },
      {
        id: "off_system",
        label: "Off-System",
        filter: {
          where: [
            {
              'crash: { onsys_fl: { _eq: "N" } }': null,
            },
          ],
        },
      },
      {
        id: "road_system_null",
        label: "Unknown",
        filter: {
          where: [
            {
              "_not: { crash: { onsys_fl: { _is_null: false } } }": null,
            },
          ],
        },
      },
    ],
  },
};

export const fatalityExportFields = `
crash_id
person_id
primaryperson_id
victim_name
year
crash_date
crash_time
location
ytd_fatality
ytd_fatal_crash
law_enforcement_num
case_id
recommendation { rec_text }
recommendation { rec_update }
recommendation { atd__recommendation_status_lkp { rec_status_desc } }
recommendation { recommendations_partners { atd__coordination_partners_lkp { coord_partner_desc } } }
primaryperson { unit { unit_description { veh_unit_desc_desc } } }
person { unit { unit_description { veh_unit_desc_desc } } }
primaryperson { unit { body_style { veh_body_styl_desc } } }
person { unit { body_style { veh_body_styl_desc } } }
crash { onsys_fl }
engineering_area
crash { council_district }
`;
