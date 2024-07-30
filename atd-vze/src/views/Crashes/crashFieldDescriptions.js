/**
 * This is an object containing fields that can be categorized as
 * Personal Identifiable Information and need removal before insertion.
 * @type {object}
 */
export const piiFields = {
  crash: [],
  charges: [],
  unit: [
    "ownr_last_name",
    "ownr_first_name",
    "ownr_street_nbr",
    "ownr_street_pfx",
    "ownr_street_name",
    "ownr_street_sfx",
    "ownr_apt_nbr",
    "trlr_gvwr",
    "trlr_rgvw",
    "trlr_type_id",
    "trlr_disabling_dmag_id",
    "cmv_intermodal_container_permit_fl",
    "cmv_actual_gross_weight",
  ],

  primaryperson: [
    "prsn_last_name",
    "prsn_first_name",
    "prsn_mid_name",
    "prsn_name_sfx",
    "drvr_lic_state_id",
    "drvr_lic_number",
    "drvr_dob",
    "drvr_street_nbr",
    "drvr_street_pfx",
    "drvr_street_name",
    "drvr_street_sfx",
    "drvr_apt_nbr",
  ],

  person: [
    "prsn_last_name",
    "prsn_first_name",
    "prsn_mid_name",
    "prsn_name_sfx",
    "drvr_lic_state_id",
    "drvr_lic_number",
    "drvr_dob",
    "drvr_street_nbr",
    "drvr_street_pfx",
    "drvr_street_name",
    "drvr_street_sfx",
    "drvr_apt_nbr",
  ],
};

/**
 * This is an object containing fields that do not accept null values.
 * @type {object}
 */
export const notNullValues = {
  primaryperson: {
    prsn_death_time: null,
  },
  person: {},
  units: {},
  crash: {}
};

/**
 * The Crash important difference fields is an object that contains the fields (as a key)
 * and its attributes (as a value).
 * @type {object}
 */
export const importantCrashFields = {
  case_id: { type: "string" },
  crash_date: { type: "string" },
  crash_time: { type: "string" },
  crash_fatal_fl: { type: "string" },
  private_dr_fl: { type: "string" },
  rpt_outside_city_limit_fl: { type: "string" },
  rpt_hwy_num: { type: "string" },
  rpt_block_num: { type: "string" },
  rpt_street_name: { type: "string" },
  rpt_sec_hwy_num: { type: "string" },
  rpt_sec_block_num: { type: "string" },
  rpt_sec_street_name: { type: "string" },
  hwy_nbr: { type: "string" },
  hwy_sys: { type: "string" },
  hwy_sys_2: { type: "string" },
  hwy_nbr_2: { type: "string" },
  city_id: { type: "integer" },
  latitude: { type: "double" },
  longitude: { type: "double" },
  street_name: { type: "string" },
  street_nbr: { type: "string" },
  street_name_2: { type: "string" },
  street_nbr_2: { type: "string" },
  sus_serious_injry_cnt: { type: "integer" },
  nonincap_injry_cnt: { type: "integer" },
  poss_injry_cnt: { type: "integer" },
  non_injry_cnt: { type: "integer" },
  unkn_injry_cnt: { type: "integer" },
  tot_injry_cnt: { type: "integer" },
  death_cnt: { type: "integer" },
  onsys_fl: { type: "string" },
  crash_sev_id: { type: "integer" },
};

/**
 * The Crash important difference fields is an object that contains the fields (as a key)
 * and its attributes (as a value).
 * @type {object}
 */
export const crashFieldDescription = {
  crash: {
    case_id: { type: "string" },
    crash_fatal_fl: { type: "string" },
    cmv_involv_fl: { type: "string" },
    schl_bus_fl: { type: "string" },
    rr_relat_fl: { type: "string" },
    medical_advisory_fl: { type: "string" },
    amend_supp_fl: { type: "string" },
    active_school_zone_fl: { type: "string" },
    crash_date: { type: "date" },
    crash_time: { type: "date" },
    local_use: { type: "string" },
    rpt_cris_cnty_id: { type: "integer" },
    rpt_city_id: { type: "integer" },
    rpt_outside_city_limit_fl: { type: "string" },
    thousand_damage_fl: { type: "string" },
    rpt_latitude: { type: "decimal" },
    rpt_longitude: { type: "decimal" },
    rpt_rdwy_sys_id: { type: "integer" },
    rpt_hwy_num: { type: "string" },
    rpt_hwy_sfx: { type: "string" },
    rpt_road_part_id: { type: "integer" },
    rpt_block_num: { type: "string" },
    rpt_street_pfx: { type: "string" },
    rpt_street_name: { type: "string" },
    rpt_street_sfx: { type: "string" },
    private_dr_fl: { type: "string" },
    toll_road_fl: { type: "string" },
    crash_speed_limit: { type: "integer" },
    road_constr_zone_fl: { type: "string" },
    road_constr_zone_wrkr_fl: { type: "string" },
    rpt_street_desc: { type: "string" },
    at_intrsct_fl: { type: "string" },
    rpt_sec_rdwy_sys_id: { type: "integer" },
    rpt_sec_hwy_num: { type: "string" },
    rpt_sec_hwy_sfx: { type: "string" },
    rpt_sec_road_part_id: { type: "integer" },
    rpt_sec_block_num: { type: "string" },
    rpt_sec_street_pfx: { type: "string" },
    rpt_sec_street_name: { type: "string" },
    rpt_sec_street_sfx: { type: "string" },
    rpt_ref_mark_offset_amt: { type: "decimal" },
    rpt_ref_mark_dist_uom: { type: "string" },
    rpt_ref_mark_dir: { type: "string" },
    rpt_ref_mark_nbr: { type: "string" },
    rpt_sec_street_desc: { type: "string" },
    rpt_crossingnumber: { type: "string" },
    wthr_cond_id: { type: "integer" },
    light_cond_id: { type: "integer" },
    entr_road_id: { type: "integer" },
    road_type_id: { type: "integer" },
    road_algn_id: { type: "integer" },
    surf_cond_id: { type: "integer" },
    traffic_cntl_id: { type: "integer" },
    investigat_notify_time: { type: "date" },
    investigat_notify_meth: { type: "string" },
    investigat_arrv_time: { type: "date" },
    report_date: { type: "date" },
    investigat_comp_fl: { type: "string" },
    investigator_name: { type: "string" },
    id_number: { type: "string" },
    ori_number: { type: "string" },
    investigat_agency_id: { type: "integer" },
    investigat_area_id: { type: "integer" },
    investigat_district_id: { type: "integer" },
    investigat_region_id: { type: "integer" },
    bridge_detail_id: { type: "integer" },
    harm_evnt_id: { type: "integer" },
    intrsct_relat_id: { type: "integer" },
    fhe_collsn_id: { type: "integer" },
    obj_struck_id: { type: "integer" },
    othr_factr_id: { type: "integer" },
    road_part_adj_id: { type: "integer" },
    road_cls_id: { type: "integer" },
    road_relat_id: { type: "integer" },
    phys_featr_1_id: { type: "integer" },
    phys_featr_2_id: { type: "integer" },
    cnty_id: { type: "integer" },
    city_id: { type: "integer" },
    latitude: { type: "decimal" },
    longitude: { type: "decimal" },
    hwy_sys: { type: "string" },
    hwy_nbr: { type: "string" },
    hwy_sfx: { type: "string" },
    dfo: { type: "decimal" },
    street_name: { type: "string" },
    street_nbr: { type: "string" },
    control: { type: "integer" },
    section: { type: "integer" },
    milepoint: { type: "decimal" },
    ref_mark_nbr: { type: "integer" },
    ref_mark_displ: { type: "decimal" },
    hwy_sys_2: { type: "string" },
    hwy_nbr_2: { type: "string" },
    hwy_sfx_2: { type: "string" },
    street_name_2: { type: "string" },
    street_nbr_2: { type: "string" },
    control_2: { type: "integer" },
    section_2: { type: "integer" },
    milepoint_2: { type: "decimal" },
    txdot_rptable_fl: { type: "string" },
    onsys_fl: { type: "string" },
    rural_fl: { type: "string" },
    crash_sev_id: { type: "integer" },
    pop_group_id: { type: "integer" },
    located_fl: { type: "string" },
    day_of_week: { type: "string" },
    hwy_dsgn_lane_id: { type: "string" },
    hwy_dsgn_hrt_id: { type: "string" },
    hp_shldr_left: { type: "string" },
    hp_shldr_right: { type: "string" },
    hp_median_width: { type: "string" },
    base_type_id: { type: "string" },
    nbr_of_lane: { type: "string" },
    row_width_usual: { type: "string" },
    roadbed_width: { type: "string" },
    surf_width: { type: "string" },
    surf_type_id: { type: "string" },
    curb_type_left_id: { type: "integer" },
    curb_type_right_id: { type: "integer" },
    shldr_type_left_id: { type: "integer" },
    shldr_width_left: { type: "integer" },
    shldr_use_left_id: { type: "integer" },
    shldr_type_right_id: { type: "integer" },
    shldr_width_right: { type: "integer" },
    shldr_use_right_id: { type: "integer" },
    median_type_id: { type: "integer" },
    median_width: { type: "integer" },
    rural_urban_type_id: { type: "integer" },
    func_sys_id: { type: "integer" },
    adt_curnt_amt: { type: "integer" },
    adt_curnt_year: { type: "integer" },
    adt_adj_curnt_amt: { type: "integer" },
    pct_single_trk_adt: { type: "decimal" },
    pct_combo_trk_adt: { type: "decimal" },
    trk_aadt_pct: { type: "decimal" },
    curve_type_id: { type: "integer" },
    curve_lngth: { type: "integer" },
    cd_degr: { type: "integer" },
    delta_left_right_id: { type: "integer" },
    dd_degr: { type: "integer" },
    feature_crossed: { type: "string" },
    structure_number: { type: "string" },
    i_r_min_vert_clear: { type: "string" },
    approach_width: { type: "string" },
    bridge_median_id: { type: "string" },
    bridge_loading_type_id: { type: "string" },
    bridge_loading_in_1000_lbs: { type: "string" },
    bridge_srvc_type_on_id: { type: "string" },
    bridge_srvc_type_under_id: { type: "string" },
    culvert_type_id: { type: "string" },
    roadway_width: { type: "string" },
    deck_width: { type: "string" },
    bridge_dir_of_traffic_id: { type: "string" },
    bridge_rte_struct_func_id: { type: "string" },
    bridge_ir_struct_func_id: { type: "string" },
    crossingnumber: { type: "string" },
    rrco: { type: "string" },
    poscrossing_id: { type: "string" },
    wdcode_id: { type: "string" },
    standstop: { type: "string" },
    yield: { type: "string" },
    sus_serious_injry_cnt: { type: "integer" },
    nonincap_injry_cnt: { type: "integer" },
    poss_injry_cnt: { type: "integer" },
    non_injry_cnt: { type: "integer" },
    unkn_injry_cnt: { type: "integer" },
    tot_injry_cnt: { type: "integer" },
    death_cnt: { type: "integer" },
    mpo_id: { type: "integer" },
    investigat_service_id: { type: "integer" },
    investigat_da_id: { type: "integer" },
    investigator_narrative: { type: "string" },
  },



  primaryperson: {
    crash_id: { type: "integer" },
    unit_nbr: { type: "integer" },
    prsn_nbr: { type: "integer" },
    prsn_type_id: { type: "integer" },
    prsn_occpnt_pos_id: { type: "integer" },
    prsn_name_honorific: { type: "string" },
    prsn_injry_sev_id: { type: "integer" },
    prsn_age: { type: "integer" },
    prsn_ethnicity_id: { type: "integer" },
    prsn_gndr_id: { type: "integer" },
    prsn_ejct_id: { type: "integer" },
    prsn_rest_id: { type: "integer" },
    prsn_airbag_id: { type: "integer" },
    prsn_helmet_id: { type: "integer" },
    prsn_sol_fl: { type: "string" },
    prsn_alc_spec_type_id: { type: "integer" },
    prsn_alc_rslt_id: { type: "integer" },
    prsn_bac_test_rslt: { type: "string" },
    prsn_drg_spec_type_id: { type: "integer" },
    prsn_drg_rslt_id: { type: "integer" },
    drvr_drg_cat_1_id: { type: "integer" },
    prsn_taken_to: { type: "string" },
    prsn_taken_by: { type: "string" },
    prsn_death_date: { type: "date" },
    prsn_death_time: { type: "date" },
    sus_serious_injry_cnt: { type: "integer" },
    nonincap_injry_cnt: { type: "integer" },
    poss_injry_cnt: { type: "integer" },
    non_injry_cnt: { type: "integer" },
    unkn_injry_cnt: { type: "integer" },
    tot_injry_cnt: { type: "integer" },
    death_cnt: { type: "integer" },
    drvr_lic_type_id: { type: "integer" },
    drvr_lic_cls_id: { type: "integer" },
    drvr_city_name: { type: "string" },
    drvr_state_id: { type: "integer" },
    drvr_zip: { type: "string" },
    last_upstring: { type: "string" },
    upstringd_by: { type: "string" },
    primaryperson_id: { type: "integer" },
    is_retired: { type: "boolean" },
    years_of_life_lost: { type: "integer" },
  },

  person: {
    crash_id: { type: "integer" },
    unit_nbr: { type: "integer" },
    prsn_nbr: { type: "integer" },
    prsn_type_id: { type: "integer" },
    prsn_occpnt_pos_id: { type: "integer" },
    prsn_name_honorific: { type: "string" },
    prsn_last_name: { type: "string" },
    prsn_first_name: { type: "string" },
    prsn_mid_name: { type: "string" },
    prsn_name_sfx: { type: "string" },
    prsn_injry_sev_id: { type: "integer" },
    prsn_age: { type: "integer" },
    prsn_ethnicity_id: { type: "integer" },
    prsn_gndr_id: { type: "integer" },
    prsn_ejct_id: { type: "integer" },
    prsn_rest_id: { type: "integer" },
    prsn_airbag_id: { type: "integer" },
    prsn_helmet_id: { type: "integer" },
    prsn_sol_fl: { type: "string" },
    prsn_alc_spec_type_id: { type: "integer" },
    prsn_alc_rslt_id: { type: "integer" },
    prsn_bac_test_rslt: { type: "string" },
    prsn_drg_spec_type_id: { type: "integer" },
    prsn_drg_rslt_id: { type: "integer" },
    prsn_taken_to: { type: "string" },
    prsn_taken_by: { type: "string" },
    prsn_death_date: { type: "date" },
    prsn_death_time: { type: "date" },
    sus_serious_injry_cnt: { type: "integer" },
    nonincap_injry_cnt: { type: "integer" },
    poss_injry_cnt: { type: "integer" },
    non_injry_cnt: { type: "integer" },
    unkn_injry_cnt: { type: "integer" },
    tot_injry_cnt: { type: "integer" },
    death_cnt: { type: "integer" },
    last_update: { type: "string" },
    updated_by: { type: "string" },
    person_id: { type: "integer" },
    is_retired: { type: "boolean" },
    years_of_life_lost: { type: "integer" },
  },

  unit: {
    crash_id: { type: "integer" },
    unit_nbr: { type: "integer" },
    unit_desc_id: { type: "integer" },
    veh_parked_fl: { type: "string" },
    veh_hnr_fl: { type: "string" },
    veh_lic_state_id: { type: "integer" },
    veh_lic_plate_nbr: { type: "string" },
    vin: { type: "string" },
    veh_mod_year: { type: "integer" },
    veh_color_id: { type: "integer" },
    veh_make_id: { type: "integer" },
    veh_mod_id: { type: "integer" },
    veh_body_styl_id: { type: "integer" },
    emer_respndr_fl: { type: "string" },
    owner_lessee: { type: "string" },
    ownr_mid_name: { type: "string" },
    ownr_name_sfx: { type: "string" },
    ownr_name_honorific: { type: "string" },
    ownr_city_name: { type: "string" },
    ownr_state_id: { type: "integer" },
    ownr_zip: { type: "string" },
    fin_resp_proof_id: { type: "integer" },
    fin_resp_type_id: { type: "integer" },
    fin_resp_name: { type: "string" },
    fin_resp_policy_nbr: { type: "string" },
    fin_resp_phone_nbr: { type: "string" },
    veh_damage_description1_id: { type: "integer" },
    veh_damage_severity1_id: { type: "integer" },
    veh_damage_direction_of_force1_id: { type: "integer" },
    veh_damage_description2_id: { type: "integer" },
    veh_damage_severity2_id: { type: "integer" },
    veh_damage_direction_of_force2_id: { type: "integer" },
    veh_inventoried_fl: { type: "string" },
    veh_transp_name: { type: "string" },
    veh_transp_dest: { type: "string" },
    veh_cmv_fl: { type: "string" },
    cmv_fiveton_fl: { type: "string" },
    cmv_hazmat_fl: { type: "string" },
    cmv_nine_plus_pass_fl: { type: "string" },
    cmv_veh_oper_id: { type: "integer" },
    cmv_carrier_id_type_id: { type: "integer" },
    cmv_carrier_id_nbr: { type: "string" },
    cmv_carrier_corp_name: { type: "string" },
    cmv_carrier_street_pfx: { type: "string" },
    cmv_carrier_street_nbr: { type: "string" },
    cmv_carrier_street_name: { type: "string" },
    cmv_carrier_street_sfx: { type: "string" },
    cmv_carrier_po_box: { type: "string" },
    cmv_carrier_city_name: { type: "string" },
    cmv_carrier_state_id: { type: "integer" },
    cmv_carrier_zip: { type: "string" },
    cmv_road_acc_id: { type: "integer" },
    cmv_veh_type_id: { type: "integer" },
    cmv_gvwr: { type: "string" },
    cmv_rgvw: { type: "string" },
    cmv_hazmat_rel_fl: { type: "string" },
    hazmat_cls_1_id: { type: "integer" },
    hazmat_idnbr_1_id: { type: "integer" },
    hazmat_cls_2_id: { type: "integer" },
    hazmat_idnbr_2_id: { type: "integer" },
    cmv_cargo_body_id: { type: "integer" },
    trlr1_gvwr: { type: "string" },
    trlr1_rgvw: { type: "string" },
    trlr1_type_id: { type: "integer" },
    trlr2_gvwr: { type: "string" },
    trlr2_rgvw: { type: "string" },
    trlr2_type_id: { type: "integer" },
    cmv_evnt1_id: { type: "integer" },
    cmv_evnt2_id: { type: "integer" },
    cmv_evnt3_id: { type: "integer" },
    cmv_evnt4_id: { type: "integer" },
    cmv_tot_axle: { type: "string" },
    cmv_tot_tire: { type: "string" },
    contrib_factr_1_id: { type: "integer" },
    contrib_factr_2_id: { type: "integer" },
    contrib_factr_3_id: { type: "integer" },
    contrib_factr_p1_id: { type: "integer" },
    contrib_factr_p2_id: { type: "integer" },
    veh_dfct_1_id: { type: "integer" },
    veh_dfct_2_id: { type: "integer" },
    veh_dfct_3_id: { type: "integer" },
    veh_dfct_p1_id: { type: "integer" },
    veh_dfct_p2_id: { type: "integer" },
    veh_trvl_dir_id: { type: "integer" },
    first_harm_evt_inv_id: { type: "integer" },
    sus_serious_injry_cnt: { type: "integer" },
    nonincap_injry_cnt: { type: "integer" },
    poss_injry_cnt: { type: "integer" },
    non_injry_cnt: { type: "integer" },
    unkn_injry_cnt: { type: "integer" },
    tot_injry_cnt: { type: "integer" },
    death_cnt: { type: "integer" },
    cmv_disabling_damage_fl: { type: "string" },
    cmv_trlr1_disabling_dmag_id: { type: "integer" },
    cmv_trlr2_disabling_dmag_id: { type: "integer" },
    cmv_bus_type_id: { type: "integer" },
    last_update: { type: "string" },
    updated_by: { type: "string" },
    unit_id: { type: "integer" },
    is_retired: { type: "boolean" },
    atd_mode_category: { type: "integer" },
  },

  charges: {
    charge_id: { type: "integer" },
    crash_id: { type: "integer" },
    unit_nbr: { type: "integer" },
    prsn_nbr: { type: "integer" },
    charge: { type: "string" },
    citation_nbr: { type: "string" },
    last_update: { type: "string" },
    updated_by: { type: "string" },
    is_retired: { type: "boolean" },
  },
};
