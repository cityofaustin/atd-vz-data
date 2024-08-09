// Return true if person record is a fatality
const shouldRenderVictimName = data => {
  return data.some(person => person.injry_sev.id === 4);
};

const getInjurySeverityColor = personRecord => {
  switch (personRecord.injry_sev.id) {
    case 0: // UNKNOWN: no color
      return "muted";
    case 1: // SUSPECTED INCAPACITATING INJURY: yellow
      return "warning";
    case 2: // SUSPECTED MINOR INJURY: yellow
      return "warning";
    case 3: // POSSIBLE INJURY: blue
      return "primary";
    case 4: // FATAL INJURY: red
      return "danger";
    case 99: // KILLED: red
      return "secondary";
    default:
      // Other cases: Not reported, Reported invalid, Not injured
      return "secondary";
  }
};

export const primaryPersonDataMap = [
  {
    title: "Drivers/Primary People",
    mutationVariableKey: "personId",

    fields: {
      unit_nbr: {
        label: "Unit",
        editable: false,
      },
      injry_sev: {
        label: "Injury Severity",
        editable: true,
        format: "select",
        lookup_desc: "label",
        lookupOptions: "lookups_injry_sev",
        updateFieldKey: "prsn_injry_sev_id",
        mutationVariableKey: "personId",
        badge: true,
        badgeColor: getInjurySeverityColor,
      },
      victim_name: {
        label: "Victim Name",
        editable: true,
        format: "text",
        mutationVariableKey: "personId",
        shouldRender: shouldRenderVictimName,
        subfields: {
          prsn_first_name: {
            label: "First",
          },
          prsn_mid_name: {
            label: "Middle",
          },
          prsn_last_name: {
            label: "Last",
          },
        },
      },
      prsn_type: {
        label: "Type",
        editable: false,
        lookup_desc: "label",
      },
      prsn_age: {
        label: "Age",
        editable: true,
        format: "text",
        mutationVariableKey: "personId",
      },
      gndr: {
        label: "Sex",
        editable: true,
        lookup_desc: "label",
        format: "select",
        lookupOptions: "lookups_gndr",
        updateFieldKey: "prsn_gndr_id",
        mutationVariableKey: "personId",
      },
      drvr_ethncty: {
        label: "Race/Ethnicity",
        editable: true,
        lookup_desc: "label",
        format: "select",
        lookupOptions: "lookups_drvr_ethncty",
        updateFieldKey: "prsn_ethnicity_id",
        mutationVariableKey: "personId",
      },
      drvr_city_name: {
        label: "City",
        editable: false,
      },
      drvr_zip: {
        label: "ZIP",
        editable: false,
      },
      prsn_exp_homelessness: {
        label: "Suspected Unhoused",
        editable: true,
        format: "boolean",
        mutationVariableKey: "personId",
      },
    },
  },
];

export const personDataMap = [
  {
    title: "Other People",
    mutationVariableKey: "personId",

    fields: {
      unit_nbr: {
        label: "Unit",
        editable: false,
      },
      injry_sev: {
        label: "Injury Severity",
        editable: true,
        format: "select",
        lookup_desc: "label",
        lookupOptions: "lookups_injry_sev",
        updateFieldKey: "prsn_injry_sev_id",
        mutationVariableKey: "personId",
        badge: true,
        badgeColor: getInjurySeverityColor,
      },
      victim_name: {
        label: "Victim Name",
        editable: true,
        format: "text",
        mutationVariableKey: "personId",
        shouldRender: shouldRenderVictimName,
        subfields: {
          prsn_first_name: {
            label: "First",
          },
          prsn_mid_name: {
            label: "Middle",
          },
          prsn_last_name: {
            label: "Last",
          },
        },
      },
      prsn_type: {
        label: "Type",
        editable: false,
        lookup_desc: "label",
      },
      prsn_age: {
        label: "Age",
        editable: true,
        format: "text",
        mutationVariableKey: "personId",
      },
      gndr: {
        label: "Sex",
        editable: true,
        lookup_desc: "label",
        format: "select",
        lookupOptions: "lookups_gndr",
        updateFieldKey: "prsn_gndr_id",
        mutationVariableKey: "personId",
      },
      drvr_ethncty: {
        label: "Race/Ethnicity",
        editable: true,
        lookup_desc: "label",
        format: "select",
        lookupOptions: "lookups_drvr_ethncty",
        updateFieldKey: "prsn_ethnicity_id",
        mutationVariableKey: "personId",
      },
      prsn_exp_homelessness: {
        label: "Suspected Unhoused",
        editable: true,
        format: "boolean",
        mutationVariableKey: "personId",
      },
    },
  },
];
