export const unitDataMap = [
  {
    mutationVariableKey: "unitId",

    fields: {
      unit_nbr: {
        label: "Unit",
        editable: false,
      },
      unit_desc_lkp: {
        edit_field_name: "unit_desc_id",
        label: "Type",
        editable: true,
        format: "select",
        lookup_desc: "label",
        lookupOptions: "lookups_unit_desc_lkp",
        updateFieldKey: "unit_desc_id",
        mutationVariableKey: "unitId",
      },
      veh_body_styl_lkp: {
        edit_field_name: "veh_body_styl_id",
        label: "Body Style",
        editable: true,
        format: "select",
        lookup_desc: "label",
        lookupOptions: "lookups_veh_body_styl_lkp",
        updateFieldKey: "veh_body_styl_id",
        mutationVariableKey: "unitId",
      },
      veh_mod_year: {
        label: "Year",
        editable: false,
      },
      veh_make_lkp: {
        label: "Make",
        editable: false,
        lookup_desc: "label",
      },
      veh_mod_lkp: {
        label: "Model",
        editable: false,
        lookup_desc: "label",
      },
      trvl_dir_lkp: {
        edit_field_name: "veh_trvl_dir_id",
        label: "Direction",
        editable: true,
        format: "select",
        lookup_desc: "label",
        lookupOptions: "lookups_trvl_dir_lkp",
        updateFieldKey: "veh_trvl_dir_id",
        mutationVariableKey: "unitId",
      },
      movt_lkp: {
        edit_field_name: "movement_id",
        label: "Movement",
        editable: true,
        format: "select",
        lookup_desc: "label",
        lookupOptions: "lookups_movt_lkp",
        updateFieldKey: "movement_id",
        mutationVariableKey: "unitId",
      },
      vz_fatality_count: {
        relationshipName: "unit_injury_metrics_view",
        label: "Fatalities",
        editable: false,
      },
      sus_serious_injry_count: {
        relationshipName: "unit_injury_metrics_view",
        label: "Suspected Serious Injuries",
        editable: false,
      },
      contrib_factr_lkp: {
        label: "Primary Contributing Factor",
        editable: false,
        lookup_desc: "label",
      },
    },
  },
];
