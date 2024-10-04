//  node --env-file=local.env src/process_features.js -l signal_engineer_areas
const fs = require("fs");
const { program, Option } = require("commander");
const { arcgisToGeoJSON } = require("@terraformer/arcgis");
const {
  getEsriToken,
  getEsriLayerUrl,
  getEsriJson,
  handleFields,
  makeUniformMultiPoly,
  makeHasuraRequest,
  reduceGeomPrecision,
} = require("./utils");
const { LAYERS } = require("./settings");

/**
 * CLI
 */
program.addOption(
  new Option("-l, --layer <name>", "layer name")
    .choices(Object.keys(LAYERS))
    .makeOptionMandatory()
);
program.parse();
const args = program.opts();

/**
 * Main function upsert an AGOL layer into the DB
 */
const main = async ({ layer: layerName }) => {
  console.log(`Processing ${layerName}`);
  const layerConfig = LAYERS[layerName];
  const { token } = await getEsriToken();
  layerConfig.query_params.token = token;
  const layerUrl = getEsriLayerUrl(layerConfig);
  const esriJson = await getEsriJson(layerUrl);
  let geojson = arcgisToGeoJSON(esriJson);

  if (esriJson.geometryType.toLowerCase().includes("polygon")) {
    makeUniformMultiPoly(geojson.features);
  }

  handleFields(geojson.features, layerConfig.fields);

  reduceGeomPrecision(geojson.features);

  if (layerConfig.shouldTruncateFirst) {
    await makeHasuraRequest({ query: layerConfig.truncateMutation });
  }

  const objects = geojson.features.map(({ properties, geometry }) => ({
    ...properties,
    geometry,
  }));
  const result = await makeHasuraRequest({
    query: layerConfig.upsertMutation,
    variables: { objects },
  });
  console.log(result);
};

main(args);
