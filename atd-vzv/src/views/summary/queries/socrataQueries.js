// const crashDatasetID = "y2wy-tgr5";
const crashDatasetID = "3aut-fhzp"; // staging
const personDatasetID = "v3x4-fjgm"; // staging

export const crashEndpointUrl = `https://data.austintexas.gov/resource/${crashDatasetID}.json`;
export const crashGeoJSONEndpointUrl = `https://data.austintexas.gov/resource/${crashDatasetID}.geojson`;
export const personEndpointUrl = `https://data.austintexas.gov/resource/${personDatasetID}.json`;

export const mapRequestFields = [
  "point",
  "death_cnt",
  "sus_serious_injry_cnt",
  "latitude",
  "longitude",
  "crash_id",
  "units_involved",
  "crash_timestamp_ct",
];
