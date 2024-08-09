export const createCrashDataMap = isTempRecord => {
  return [
    {
      title: "Details",
      fields: {
        record_locator: {
          label: "Crash ID",
          editable: false,
        },
        updated_at: {
          label: "Last Updated",
          editable: false,
          format: "datetime",
        },
        case_id: {
          label: "Case ID",
          editable: false,
        },
        crash_timestamp: {
          label: "Crash Date",
          editable: false,
          format: "datetime",
        },
        crash_day_of_week: {
          label: "Day of Week",
          relationshipName: "crashes_list_view",
          editable: false,
        },
        est_comp_cost_crash_based: {
          label: "Est. Comprehensive Cost",
          relationshipName: "crash_injury_metrics_view",
          editable: false,
          format: "dollars",
        },
        fhe_collsn_id: {
          label: "Manner of Collision ID",
          editable: isTempRecord,
          uiType: "select",
          lookupOptions: "lookups_collsn",
        },
        rpt_city_id: {
          label: "City",
          editable: true,
          uiType: "select",
          lookupOptions: "lookups_city",
        },
        light_cond_id: {
          label: "Light Condition",
          editable: false,
          uiType: "select",
          lookupOptions: "lookups_light_cond",
        },
        wthr_cond_id: {
          label: "Weather Condition",
          editable: false,
          uiType: "select",
          lookupOptions: "lookups_wthr_cond",
        },
        obj_struck_id: {
          label: "Object Struck",
          editable: false,
          uiType: "select",
          lookupOptions: "lookups_obj_struck",
        },
        crash_speed_limit: {
          label: "Speed Limit",
          editable: true,
          // TODO: Validate for integers
          uiType: "text",
        },
        traffic_cntl_id: {
          label: "Traffic Control",
          editable: true,
          uiType: "select",
          lookupOptions: "lookups_traffic_cntl",
        },
      },
    },
    {
      title: "Injuries",
      fields: {
        crash_injry_sev_id: {
          label: "Crash Severity",
          relationshipName: "crash_injury_metrics_view",
          editable: false,
          lookupOptions: "lookups_injry_sev",
        },
        nonincap_injry_count: {
          label: "Non-incapacitating Injury Count",
          relationshipName: "crash_injury_metrics_view",
          editable: false,
        },
        sus_serious_injry_count: {
          label: "Suspected Serious Injury Count",
          relationshipName: "crash_injury_metrics_view",
          editable: false,
        },
        vz_fatality_count: {
          label: "ATD Fatality Count",
          relationshipName: "crash_injury_metrics_view",
          editable: false,
        },
        cris_fatality_count: {
          label: "CRIS Fatality Count",
          relationshipName: "crash_injury_metrics_view",
          editable: false,
        },
        law_enf_fatality_count: {
          label: "Law Enforcement Fatality Count",
          relationshipName: "crash_injury_metrics_view",
          editable: false,
        },
        law_enforcement_ytd_fatality_num: {
          label: "Law Enforcement YTD Fatal Crash",
          editable: true,
          uiType: "text",
        },
      },
    },
    {
      title: "Primary Street Information",
      fields: {
        address_primary: {
          label: "Primary Address",
          editable: false,
          uiType: "text",
        },
        rpt_block_num: {
          label: "Street Number",
          editable: false,
          uiType: "text",
        },
        rpt_street_name: {
          label: "Street Name",
          editable: false,
          uiType: "text",
        },
        rpt_street_desc: {
          label: "Street Description",
          editable: false,
          uiType: "text",
        },
        rpt_road_part_id: {
          label: "Roadway Part",
          editable: false,
          uiType: "select",
          lookupOptions: "lookups_road_part",
        },
        rpt_rdwy_sys_id: {
          label: "Roadway System",
          editable: false,
          uiType: "select",
          lookupOptions: "lookups_rwy_sys",
        },
        rpt_hwy_num: {
          label: "Highway Number",
          editable: false,
          uiType: "text",
        },
        rpt_street_pfx: {
          label: "Street Prefix",
          editable: false,
          uiType: "text",
        },
        // TODO: We'll probably want to validate that they are using values from the table
        // for the rpt_street_sfx & rpt_sec_street_sfx fields but the values are currently text, not ID lookups so we'll punt
        rpt_street_sfx: {
          label: "Street Suffix",
          editable: false,
          uiType: "text",
        },
      },
    },
    {
      title: "Secondary Street Information",
      fields: {
        address_secondary: {
          label: "Secondary Address",
          editable: false,
          uiType: "text",
        },
        rpt_sec_block_num: {
          label: "Secondary Street Number",
          editable: false,
          uiType: "text",
        },
        rpt_sec_street_name: {
          label: "Secondary Street Name",
          editable: false,
          uiType: "text",
        },
        rpt_sec_street_desc: {
          label: "Secondary Street Description",
          editable: false,
          uiType: "text",
        },
        rpt_sec_road_part_id: {
          label: "Secondary Roadway Part",
          editable: false,
          uiType: "select",
          lookupOptions: "lookups_road_part",
        },
        rpt_sec_rdwy_sys_id: {
          label: "Secondary Roadway System",
          editable: false,
          uiType: "select",
          lookupOptions: "lookups_rwy_sys",
        },
        rpt_sec_hwy_num: {
          label: "Secondary Highway Number",
          editable: false,
          uiType: "text",
        },
        rpt_sec_street_pfx: {
          label: "Secondary Street Prefix",
          editable: false,
          uiType: "text",
        },
        rpt_sec_street_sfx: {
          label: "Secondary Street Suffix",
          editable: false,
          uiType: "text",
        },
      },
    },
    {
      title: "Flags",
      fields: {
        active_school_zone_fl: {
          label: "Active School Zone",
          editable: false,
          uiType: "boolean",
        },
        at_intrsct_fl: {
          label: "Intersection-Relation Flag",
          editable: true,
          uiType: "boolean",
        },
        onsys_fl: {
          label: "On TxDOT Highway System Flag",
          editable: isTempRecord,
          uiType: "boolean",
        },
        private_dr_fl: {
          label: "Private Drive Flag",
          editable: true,
          uiType: "boolean",
        },
        road_constr_zone_fl: {
          label: "Road Construction Zone Flag",
          editable: true,
          uiType: "boolean",
        },
        rr_relat_fl: {
          label: "Railroad Related Flag",
          editable: false,
          uiType: "boolean",
        },
        schl_bus_fl: {
          label: "School Bus Flag",
          editable: false,
          uiType: "boolean",
        },
        toll_road_fl: {
          label: "Toll Road/Lane Flag",
          editable: false,
          uiType: "boolean",
        },
      },
    },
  ];
};
