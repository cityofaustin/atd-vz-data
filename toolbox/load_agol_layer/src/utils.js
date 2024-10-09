const fs = require("fs");

const AGOL_USERNAME = process.env.AGOL_USERNAME;
const AGOL_PASSWORD = process.env.AGOL_PASSWORD;
const AGOL_ORG_BASE_URL = "https://austin.maps.arcgis.com";

const COORDINATE_DECIMAL_PLACES = 6;
const coordPrecisionMultiplier = Math.pow(10, COORDINATE_DECIMAL_PLACES);

/**
 * Construct a URL to an AGOL service
 */
const getEsriLayerUrl = ({ service_name, layer_id, query_params }) => {
  const queryString = new URLSearchParams(query_params).toString();
  return `https://services.arcgis.com/0L95CJ0VTaxqcmED/arcgis/rest/services/${service_name}/FeatureServer/${layer_id}/query?${queryString}`;
};

/**
 * Convert Polygon features to MultiPolygon. Non-polygon geometry types are ignored.
 * 
 * Whereas AGOL may hold poly and multi poly geometries in the same layer, postGIS
 * does not support this. We can easily convert polygons to multipolygons by
 * wrapping their geometry in an outer array.
 *
 * Alternatively we could use a DB trigger that applies `ST_Multi` to the geometry
 * before inserting it.
 *
 * @param {Object[]} features - Array of GeoJSON features
 *
 * @returns {void} Updates the `geometry` of each feature in-place
 */
const makeUniformMultiPoly = (features) => {
  features.forEach((feature) => {
    /** Ignore geojson geometry types except Polygon  */
    if (feature.geometry.type === "Polygon") {
      feature.geometry.type = "MultiPolygon";
      feature.geometry.coordinates = [feature.geometry.coordinates];
      console.log(`Converted Polygon to MultiPolygon`);
    }
  });
};

/**
 * Processes GeoJSON features by reducing their properties to a specified set of fields
 * and also lowercasing each field name.
 *
 * @param {Object[]} features - Array of GeoJSON features. Each feature should have a `properties` object.
 * @param {string[]} fields - Array of fields names to retain from the feature's properties.
 * The field names are converted to lowercase in the resulting properties.
 *
 * @returns {void} Updates each feature's properties in-place.
 */
const handleFields = (features, fields) => {
  features.forEach((f) => {
    f.properties = fields.reduce((newProperties, field) => {
      newProperties[field.toLowerCase()] = f.properties[field];
      return newProperties;
    }, {});
  });
};

/**
 * Recursively handles GeoJSON coordinates by reducing precision of decimal places.
 *
 * @param {number[] | Array<number[]>} coords - A GeoJSON coordinate array or a number array.
 * If `coords` is an array of numbers, their precision is reduced.
 * If `coords` contains arrays, the function will recurse until it finds the numbers.
 *
 * @returns {void} Coordinates are updated in-place.
 */
function recursiveCoordinateHandler(coords) {
  if (coords.some((value) => typeof value === "number")) {
    // reduce precision of coordinates
    return coords.forEach((value, i) => {
      coords[i] =
        Math.round(value * coordPrecisionMultiplier) / coordPrecisionMultiplier;
    });
  } else if (coords.some((value) => Array.isArray(value))) {
    // keep searching for coordinates
    return coords.forEach((coords) => recursiveCoordinateHandler(coords));
  }
}

/**
 * Given an array of geojson features, reduce the decimal precision of each
 * coordinate to the number of places defined by COORDINATE_DECIMAL_PLACES.
 * @param {Object[]} features - Array of GeoJSON features
 *
 * @returns {void} Updates features in-places
 */
const reduceGeomPrecision = (features) => {
  features.forEach(({ geometry }) => {
    recursiveCoordinateHandler(geometry.coordinates);
  });
};

/**
 * Fetch wrapper that handles error handling and json parsing
 */
const genericJSONFetch = async ({ url, method, ...options }) => {
  try {
    const response = await fetch(url, {
      method,
      ...options,
    });
    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`HTTP error: ${response.status} - ${errorText}`);
    }
    const responseData = await response.json();

    if (responseData?.errors) {
      throw JSON.stringify(responseData.errors);
    }
    return responseData;
  } catch (error) {
    throw error;
  }
};

/**
 * Get a token that can be used to authenticate with the ArcGIS REST API
 * @returns {{ token: string }} An object containing a `token` property with the token string
 */
async function getEsriToken() {
  const url = `${AGOL_ORG_BASE_URL}/sharing/rest/generateToken`;
  const data = {
    username: AGOL_USERNAME,
    password: AGOL_PASSWORD,
    referer: "http://www.arcgis.com",
    f: "pjson",
  };
  const body = new URLSearchParams(data);
  const headers = { "Content-Type": "application/x-www-form-urlencoded" };
  return genericJSONFetch({ url, method: "POST", body, headers });
}

const getEsriJson = async (url) => {
  return genericJSONFetch({ url, method: "GET" });
};

/**
 * Sends a request to the Hasura GraphQL API.
 *
 * @param {Object} params - The request parameters.
 * @param {string} params.query - The GraphQL query string.
 * @param {Object} [params.variables] - The variables for the GraphQL query.
 * @returns {Object} The JSON response from the Hasura API.
 */
const makeHasuraRequest = async ({ query, variables }) => {
  const body = JSON.stringify({
    query,
    variables,
  });
  const url = process.env.HASURA_GRAPHQL_ENDPOINT;
  const headers = {
    "X-Hasura-Admin-Secret": process.env.HASURA_GRAPHQL_ADMIN_SECRET,
    "content-type": "application/json",
  };
  return genericJSONFetch({ url, method: "POST", body, headers });
};

module.exports = {
  getEsriLayerUrl,
  getEsriToken,
  getEsriJson,
  makeUniformMultiPoly,
  handleFields,
  makeHasuraRequest,
  reduceGeomPrecision,
};
