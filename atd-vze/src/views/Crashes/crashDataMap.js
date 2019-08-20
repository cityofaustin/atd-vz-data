export const crashDataMap = [
  {
    title: "Details",
    fields: {
      case_id: "Case ID",
      crash_date: "Crash Date",
      crash_id: "Crash ID",
      crash_speed_limit: "Speed Limit",
      crash_time: "Crash Time",
      day_of_week: "Day of Week",
      fhe_collsn_id: "Manner of Collision ID",
      last_update: "Last Updated",
      investigator_narrative: "Investigator Narrative",
      light_cond_id: "Light Condition",
      obj_struck_id: "Object Struck ID",
      road_type_id: "Roadway Type ID",
      traffic_cntl_id: "Traffic Control ID",
      wthr_cond_id: "Weather Condition ID",
    },
  },
  {
    title: "Fatalities/Injuries",
    fields: {
      crash_fatal_fl: "Fatality Flag",
      death_cnt: "Death Count",
      crash_sev_id: "Crash Severity ID",
      non_injry_cnt: "Not Injured Count",
      nonincap_injry_cnt: "Non-incapacitating Injury Count",
      poss_injry_cnt: "Possible Injury Count",
      sus_serious_injry_cnt: "Suspected Serious Injury Count",
      tot_injry_cnt: "Total Injury Count",
      unkn_injry_cnt: "Unknown Injury Count",
    },
  },
  {
    title: "Address/Geo",
    fields: {
      geocode_date: "Geocode Date",
      geocode_provider: "Geocode Provider",
      geocode_status: "Geocode Status",
      geocoded: "Geocoded",
      hwy_nbr: "Highway Number",
      hwy_sfx: "Highway Suffix",
      hwy_sys: "Highway System",
      intrsct_relat_id: "Intersection Related ID",
      latitude: "Latitude",
      latitude_confirmed: "Latitude Confirmed",
      latitude_geocoded: "Latitude Geocode",
      longitude: "Longitude",
      longitude_confirmed: "Longitude Confirmed",
      longitude_geocoded: "Longitude Geocoded",
      position: "Position",
      rpt_rdwy_sys_id: "Roadway System ID",
      rpt_road_part_id: "Roadway Part ID",
      rpt_sec_block_num: "Secondary Block Number",
      rpt_sec_hwy_num: "Secondary Highway Number",
      rpt_sec_hwy_sfx: "Secondary Highway Suffix",
      rpt_sec_rdwy_sys_id: "Secondary Roadway System ID",
      rpt_sec_road_part_id: "Secondary Roadway Part ID",
      rpt_sec_street_desc: "Secondary Street Description",
      rpt_sec_street_name: "Secondary Street Name",
      rpt_sec_street_pfx: "Secondary Street Prefix",
      rpt_sec_street_sfx: "Secondary Street Suffix",
      rpt_street_name: "Reported Street Name",
      rpt_street_pfx: "Reported Street Prefix",
      rpt_street_sfx: "Reported Street Suffix",
      rpt_block_num: "Block Number",
      rpt_city_id: "City ID",
      rpt_hwy_num: "Highway Number",
      rpt_hwy_sfx: "Highway Suffix",
      rpt_latitude: "Reported Latitude",
      rpt_longitude: "Reported Longitude",
      street_name: "Street Name",
      street_name_2: "Street Name 2",
      street_nbr: "Street Number",
      street_nbr_2: "Street Number 2",
    },
  },
  {
    title: "Flags",
    fields: {
      active_school_zone_fl: "Active School Zone",
      at_intrsct_fl: "Intersection-Relation Flag",
      onsys_fl: "On TxDOT Highway System Flag",
      private_dr_fl: "Private Drive Flag",
      road_constr_zone_fl: "Road Construction Zone Flag",
      rpt_outside_city_limit_fl: "Outside City Limit Flag",
      rr_relat_fl: "Railroad Related Flag",
      schl_bus_fl: "School Bus Flag",
      toll_road_fl: "Toll Road/Lane Flag",
    },
  },
  {
    title: "QA",
    fields: {
      approval_date: "Approval Date",
      approved_by: "Approved By",
      qa_status: "QA Status",
    },
  },
];

export const geoFields = {
  title: "Geo Data",
  fields: [
    { label: "City", data: ["city"] },
    { label: "Latitude", data: ["latitude"] },
    { label: "Longitude", data: ["longitude"], editable: true },
  ],
};
