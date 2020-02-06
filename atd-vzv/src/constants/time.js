import moment from "moment";

// Number of past years data to fetch
// 4 full years of data, plus data up to the last complete month of the current year
export const rollingYearsOfData = 4;

// First date of records that should be referenced in VZV (start of first year in rolling window)
export const dataStartDate = moment()
  .subtract(1, "month")
  .subtract(rollingYearsOfData, "year")
  .startOf("year");

// Last date of records that should be referenced in VZV (through last complete month of data)
export const dataEndDate = moment()
  .subtract(1, "month")
  .endOf("month");

// Map time data
export const mapDataMinDate = new Date(dataStartDate.format("MM/DD/YYYY"));
export const mapDataMaxDate = new Date(dataEndDate);

export const mapStartDate = dataStartDate.format("YYYY-MM-DD") + "T00:00:00";
export const mapEndDate = dataEndDate.format("YYYY-MM-DD") + "T23:59:59";
