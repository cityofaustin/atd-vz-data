import React from "react";
import { RenderStates } from "react-map-gl-draw";
import { Source, Layer } from "react-map-gl";
import { colors } from "../../constants/colors";

// Empty source and layer placeholder to place other layers beneath road labels
export const baseSourceAndLayer = (
  <>
    <Source
      id="base-source"
      type="geojson"
      data={{ type: "FeatureCollection", features: [] }}
    >
      <Layer
        beforeId="road-label-sm"
        id="base-layer"
        {...{ type: "symbol", source: "base-source" }}
      />
    </Source>
  </>
);

// For more information on data-driven styles, see https://www.mapbox.com/help/gl-dds-ref/
// To create white border, add second layer with larger white radius behind primary circles
const crashPointRadius = {
  stops: [
    [8, 2],
    [12, 4],
    [14, 8],
    [16, 10],
  ],
};

const crashPointOutlineRadius = {
  stops: crashPointRadius.stops.map((stop) => [stop[0], stop[1] + 1]),
};

export const fatalitiesDataLayer = {
  id: "fatalities",
  type: "circle",
  paint: {
    "circle-radius": crashPointRadius,
    "circle-color": colors.fatalities,
  },
};

export const fatalitiesOutlineDataLayer = {
  ...fatalitiesDataLayer,
  id: "fatalitiesOutline",
  paint: {
    ...fatalitiesDataLayer.paint,
    "circle-radius": crashPointOutlineRadius,
    "circle-color": colors.white,
  },
};

export const seriousInjuriesDataLayer = {
  id: "seriousInjuries",
  type: "circle",
  paint: {
    "circle-radius": crashPointRadius,
    "circle-color": colors.seriousInjuries,
  },
};

export const seriousInjuriesOutlineDataLayer = {
  ...seriousInjuriesDataLayer,
  id: "seriousInjuriesOutline",
  paint: {
    ...seriousInjuriesDataLayer.paint,
    "circle-radius": crashPointOutlineRadius,
    "circle-color": colors.white,
  },
};

// Config ASMP Street Level layers
export const asmpConfig = {
  asmp_1: {
    filter: 0,
    color: colors.mapAsmp1,
  },
  asmp_2: {
    filter: 1,
    color: colors.mapAsmp2,
  },
  asmp_3: {
    filter: 2,
    color: colors.mapAsmp3,
  },
  asmp_4: {
    filter: 3,
    color: colors.mapAsmp4,
  },
  asmp_5: {
    filter: 4,
    color: colors.mapAsmp5,
  },
};

// Map Overlay configuration
// Hide/show based on overlay state, add layers only once and let state determine visibility
// Using state in any other config parameters will cause layer to add again and break map layer

// Build Mapbox GL layers for each ASMP Street Level in config
export const buildAsmpLayers = (config, overlay) =>
  Object.entries(config).map(([level, parameters], i) => {
    const asmpLevel = level.split("").pop();

    // Set config for each ASMP level layer based on ArcGIS VectorTileServer styles
    // https://tiles.arcgis.com/tiles/0L95CJ0VTaxqcmED/arcgis/rest/services/ASMP_Streets_VectorTile/VectorTileServer/resources/styles/root.json?f=pjson
    const asmpLayerConfig = {
      id: level,
      beforeId: "base-layer",
      type: "line",
      source: {
        type: "vector",
        tiles: [
          "https://tiles.arcgis.com/tiles/0L95CJ0VTaxqcmED/arcgis/rest/services/ASMP_Streets_VectorTile/VectorTileServer/tile/{z}/{y}/{x}.pbf",
        ],
      },
      "source-layer": "asmp_street_network",
      filter: ["==", "_symbol", parameters.filter],
      layout: {
        "line-cap": "round",
        "line-join": "round",
        visibility: `${
          overlay.options && overlay.options.includes(asmpLevel)
            ? "visible"
            : "none"
        }`,
      },
      paint: {
        "line-color": parameters.color,
        "line-width": 2,
      },
    };

    // Return a Layer component with config prop passed for each level
    return <Layer key={i} {...asmpLayerConfig} />;
  });

// Build Mapbox GL layer of High Injury Network & Roadways (focused segments)
// https://tiles.arcgis.com/tiles/0L95CJ0VTaxqcmED/arcgis/rest/services/High_Injury_Network_Vision_Zero_Viewer/VectorTileServer/resources/styles/root.json?f=pjson
export const buildHighInjuryLayer = (overlay) => {
  // Set config for each ASMP level layer based on ArcGIS VectorTileServer styles
  const overlayId = "highInjury";

  const highInjuryNetworkLayerConfig = {
    id: overlayId + "Network",
    beforeId: "base-layer",
    type: "line",
    source: {
      type: "vector",
      tiles: [
        "https://tiles.arcgis.com/tiles/0L95CJ0VTaxqcmED/arcgis/rest/services/High_Injury_Network_HIR_2022/VectorTileServer/tile/{z}/{y}/{x}.pbf",
      ],
    },
    "source-layer": "Combined_HIN_HIR",
    filter: ["==", "_symbol", 1], // Select line within layer by ID
    layout: {
      "line-join": "round",
      visibility: `${overlay.name === overlayId ? "visible" : "none"}`,
    },
    paint: {
      "line-color": colors.mapHighInjuryNetwork,
      "line-width": 2,
    },
  };

  const highInjuryRoadwaysLayerConfig = {
    id: overlayId + "Roadways",
    beforeId: "base-layer",
    type: "line",
    source: {
      type: "vector",
      tiles: [
        "https://tiles.arcgis.com/tiles/0L95CJ0VTaxqcmED/arcgis/rest/services/High_Injury_Network_HIR_2022/VectorTileServer/tile/{z}/{y}/{x}.pbf",
      ],
    },
    "source-layer": "Combined_HIN_HIR",
    filter: ["==", "_symbol", 0],
    layout: {
      "line-join": "round",
      visibility: `${overlay.name === overlayId ? "visible" : "none"}`,
    },
    paint: {
      "line-color": colors.mapHighInjuryRoadways,
      "line-width": 4,
    },
  };

  return (
    <>
      <Layer
        key={highInjuryNetworkLayerConfig.id}
        {...highInjuryNetworkLayerConfig}
      />
      <Layer
        key={highInjuryRoadwaysLayerConfig.id}
        {...highInjuryRoadwaysLayerConfig}
      />
    </>
  );
};

// Style geojson returned from ArcGIS that populates the Source and Layer in Map component
// https://services.arcgis.com/0L95CJ0VTaxqcmED/ArcGIS/rest/services/BOUNDARIES_single_member_districts/FeatureServer/0/query?where=1%3D1&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&resultType=none&distance=0.0&units=esriSRUnit_Meter&relationParam=&returnGeodetic=false&outFields=COUNCIL_DISTRICT&returnGeometry=true&returnCentroid=false&featureEncoding=esriDefault&multipatchOption=xyFootprint&maxAllowableOffset=&geometryPrecision=6&outSR=4326&defaultSR=&datumTransformation=&applyVCSProjection=false&returnIdsOnly=false&returnUniqueIdsOnly=false&returnCountOnly=false&returnExtentOnly=false&returnQueryGeometry=false&returnDistinctValues=false&cacheHint=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&having=&resultOffset=&resultRecordCount=&returnZ=false&returnM=false&returnExceededLimitFeatures=true&quantizationParameters=&sqlFormat=none&f=pgeojson&token=
export const cityCouncilDataLayer = {
  id: "cityCouncil",
  type: "fill",
  paint: {
    "fill-opacity": 0.25,
    "fill-color": [
      "match",
      ["get", "COUNCIL_DISTRICT"],
      1,
      colors.mapCityCouncil1,
      2,
      colors.mapCityCouncil2,
      3,
      colors.mapCityCouncil3,
      4,
      colors.mapCityCouncil4,
      5,
      colors.mapCityCouncil5,
      6,
      colors.mapCityCouncil6,
      7,
      colors.mapCityCouncil7,
      8,
      colors.mapCityCouncil8,
      9,
      colors.mapCityCouncil9,
      10,
      colors.mapCityCouncil10,
      /* other */ "#ccc",
    ],
  },
};

// Styles for MapPolygonFilter
export function getEditHandleStyle({ feature, state }) {
  switch (state) {
    case RenderStates.UNCOMMITTED:
      return {
        fill: colors.viridis6Of6Lowest,
        fillOpacity: 1,
        stroke: colors.white,
        strokeWidth: 2,
        r: 7,
      };

    default:
      return {
        fill: colors.viridis6Of6Lowest,
        fillOpacity: 1,
        stroke: colors.white,
        strokeWidth: 2,
        r: 5,
      };
  }
}

export function getFeatureStyle({ feature, index, state }) {
  switch (state) {
    case RenderStates.CLOSING:
      return {
        stroke: colors.viridis4Of6,
        strokeWidth: 2,
        fill: colors.viridis4Of6,
        fillOpacity: 0.3,
        strokeDasharray: "4,2",
      };
    case RenderStates.UNCOMMITTED:
      return {
        stroke: colors.viridis6Of6Lowest,
        strokeWidth: 2,
        fill: colors.viridis6Of6Lowest,
        fillOpacity: 0.3,
        strokeDasharray: "4,2",
      };

    default:
      return {
        stroke: colors.info,
        strokeWidth: 2,
        fill: colors.info,
        fillOpacity: 0.1,
      };
  }
}

export const travisCountyDataLayer = {
  id: "travisCounty",
  type: "fill",
  paint: {
    "fill-opacity": 0.15,
    "fill-color": colors.dark,
  },
};
