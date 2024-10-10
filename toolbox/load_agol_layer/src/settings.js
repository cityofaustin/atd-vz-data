const { combineDistrictTenFeatures } = require("./utils");

const DEFAULT_ESRI_QUERY_PARAMS = {
  where: "1=1", // return all features
  f: "json", // features as Esri json - we could request geojson but esri botches it
  outFields: "*", // return all fields
  returnGeometry: "true", // include geometry property
  geometryPrecision: "8", // num of lat/lon decimal places
  outSR: "4326", // out spatial reference as WGS1984
};

/**
 * @typedef {Object} Layer
 * @property {string} service_name - The unique name of the service in the City of Austin AGOL org.
 *  This can be found by inspecting the layer's service definition on AGOL.
 * @property {number} layer_id - The AGOL ID of the layer in the service. This can be found by
 *  inspecting the layer's service definition on AGOL.
 * @property {Object} query_params - ArcGIS REST API query parameters to include when querying
 *   the layer data from AGOL. See DEFAULT_ESRI_QUERY_PARAMS.
 * @property {string[]} fields - List of field names which will be translated from feature properties
 *   to database column values. All fieldnames will be converted to lowercase.
 * @property {boolean} shouldTruncateFirst - Whether the target database table should be truncated
 *  before new features are inserted. If true, `truncateMutation` is required.
 * @property {Function} transformer - An optional transform function which should accept a geosjon
 * feature collection as the sole input param and modify the geojson in-place.
 * @property {string} truncateMutation - The GraphQL mutation for truncating the target database table.
 *  Required if shouldTruncateFirst is true and otherwise ignored.
 * @property {string} upsertMutation - The GraphQL mutation used for writing new features to the
 *   database table. The mutation should either insert features (if truncating first) or upsert using
 *   the `on_conflict` clause
 */

const LAYERS = {
  apd_sectors: {
    service_name: "BOUNDARIES_apd_districts",
    layer_id: 0,
    query_params: { ...DEFAULT_ESRI_QUERY_PARAMS },
    fields: [
      "PRIMARY_KEY",
      "DISTRICT_NAME",
      "BATTALION_CODE",
      "SECTOR_NAME",
      "BUREAU_NAME",
      "PATROL_AREA",
    ],
    shouldTruncateFirst: false,
    upsertMutation: `
      mutation UpsertApdSectors($objects: [geo_apd_sectors_insert_input!]!) {
        insert_geo_apd_sectors(
          objects: $objects
          on_conflict: {
            constraint: apd_sectors_pkey
            update_columns: [
              district_name
              battalion_code
              sector_name
              bureau_name
              patrol_area
              geometry
            ]
          }
        ) {
          affected_rows
        }
      }
    `,
  },
  council_districts: {
    service_name: "BOUNDARIES_single_member_districts",
    layer_id: 0,
    query_params: { ...DEFAULT_ESRI_QUERY_PARAMS },
    fields: ["COUNCIL_DISTRICT"],
    shouldTruncateFirst: false,
    transformer: combineDistrictTenFeatures,
    upsertMutation: `
      mutation UpsertCouncilDistricts(
        $objects: [geo_council_districts_insert_input!]!
      ) {
        insert_geo_council_districts(
          objects: $objects
          on_conflict: {
            constraint: council_districts_pkey
            update_columns: [council_district, geometry]
          }
        ) {
          affected_rows
        }
      }
    `,
  },
  engineering_areas: {
    service_name: "TRANSPORTATION_engineering_service_areas",
    layer_id: 0,
    query_params: { ...DEFAULT_ESRI_QUERY_PARAMS },
    fields: ["ENGINEERING_AREA_ID", "ATD_ENGINEER_AREAS"],
    shouldTruncateFirst: false,
    upsertMutation: `
      mutation UpsertEngineeringAreas(
        $objects: [geo_engineering_areas_insert_input!]!
      ) {
        insert_geo_engineering_areas(
          objects: $objects
          on_conflict: {
            constraint: engineering_areas_pkey
            update_columns: [atd_engineer_areas, geometry]
          }
        ) {
          affected_rows
        }
      }
    `,
  },
  non_coa_roadways: {
    service_name: "On_System_Polygon_Feature",
    layer_id: 0,
    query_params: { ...DEFAULT_ESRI_QUERY_PARAMS },
    fields: [],
    shouldTruncateFirst: true,
    truncateMutation: `
      mutation DeleteNonCoaRoadways {
        delete_geo_non_coa_roadways(where: { geometry: { _is_null: false } }) {
          affected_rows
        }
      }
    `,
    upsertMutation: `
      mutation InsertNonCoaRoadways(
        $objects: [geo_non_coa_roadways_insert_input!]!
      ) {
        insert_geo_non_coa_roadways(objects: $objects) {
          affected_rows
        }
      }
    `,
  },
  signal_engineer_areas: {
    service_name: "TRANSPORTATION_signal_engineer_areas",
    layer_id: 0,
    query_params: { ...DEFAULT_ESRI_QUERY_PARAMS },
    fields: ["SIGNAL_ENG_AREA", "SIGNAL_ENGINEER_AREA_ID"],
    shouldTruncateFirst: false,
    upsertMutation: `
      mutation UpsertSignalEngineerAreas(
        $objects: [geo_signal_engineer_areas_insert_input!]!
      ) {
        insert_geo_signal_engineer_areas(
          objects: $objects
          on_conflict: {
            constraint: signal_engineer_areas_signal_engineer_area_id_key
            update_columns: [signal_eng_area, geometry]
          }
        ) {
          affected_rows
        }
      }
    `,
  },
  zipcodes: {
    service_name: "TPW_ZIPCodes_VZ",
    layer_id: 0,
    query_params: { ...DEFAULT_ESRI_QUERY_PARAMS },
    fields: ["ZIPCODE"],
    shouldTruncateFirst: false,
    upsertMutation: `
      mutation UpsertZipCodes(
        $objects: [geo_zip_codes_insert_input!]!
      ) {
        insert_geo_zip_codes(
          objects: $objects
          on_conflict: {
            constraint: zip_codes_pkey
            update_columns: [zipcode, geometry]
          }
        ) {
          affected_rows
        }
      }
    `,
  },
};

module.exports = {
  DEFAULT_ESRI_QUERY_PARAMS,
  LAYERS,
};
