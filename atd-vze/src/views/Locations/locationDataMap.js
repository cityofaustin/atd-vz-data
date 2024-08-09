const locationDataMap = [
  {
    title: "Details",
    fields: {
      location_id: {
        label: "Location ID",
        editable: false,
      },
      cr3_crash_count: {
        label: "Total CR3 Crashes (Previous 5 years)",
        relationshipName: "locationTotals",
        editable: false,
      },
      non_cr3_crash_count: {
        label: "Total Non-CR3 Crashes (Previous 5 years)",
        relationshipName: "locationTotals",
        editable: false,
      },
    //   total_est_comp_cost: {
    //     label: "Total Estimated Comprehensive Cost (Previous 5 years)",
    //     relationshipName: "locationTotals",
    //     editable: false,
    //     format: "dollars",
    //   },
      street_level: {
        label: "ASMP Street Level",
        editable: false,
      },
    },
  },
];

export default locationDataMap;
