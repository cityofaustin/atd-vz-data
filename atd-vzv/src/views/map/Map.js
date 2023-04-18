import React, { useState, useEffect, useRef } from "react";
import { StoreContext } from "../../utils/store";
import ReactMapGL, { Source, Layer } from "react-map-gl";
import MapControls from "./MapControls";
import MapPolygonFilter from "./MapPolygonFilter";
import MapCompassSpinner from "./MapCompassSpinner";
import { createMapDataUrl } from "./helpers";
import { mapInit, travisCountyBboxGeoJSON, mapNavBbox } from "./mapData";
import { crashGeoJSONEndpointUrl } from "../../views/summary/queries/socrataQueries";
import {
  baseSourceAndLayer,
  fatalitiesDataLayer,
  fatalitiesOutlineDataLayer,
  seriousInjuriesDataLayer,
  seriousInjuriesOutlineDataLayer,
  buildAsmpLayers,
  asmpConfig,
  buildHighInjuryLayer,
  cityCouncilDataLayer,
  travisCountyDataLayer,
} from "./map-style";
import axios from "axios";
import { useIsTablet } from "../../constants/responsive";
import AnimatedIcon from "./AnimatedIcon";

import "mapbox-gl/dist/mapbox-gl.css";
import "@mapbox/mapbox-gl-draw/dist/mapbox-gl-draw.css"; // Get out-of-the-box icons
import MapInfoBox from "./InfoBox/MapInfoBox";
import MapPolygonInfoBox from "./InfoBox/MapPolygonInfoBox";

const MAPBOX_TOKEN = `pk.eyJ1Ijoiam9obmNsYXJ5IiwiYSI6ImNrM29wNnB3dDAwcXEzY29zMTU5bWkzOWgifQ.KKvoz6s4NKNHkFVSnGZonw`;

function useMapEventHandler(eventName, callback, mapRef) {
  useEffect(() => {
    const currentMapRef = mapRef.current;
    const mapDataListener = currentMapRef.on(eventName, function () {
      callback();
    });
    return () => {
      currentMapRef.off(eventName, mapDataListener);
    };
  }, [eventName, callback, mapRef]);
}

const Map = () => {
  // Set initial map config
  const [viewport, setViewport] = useState({
    ...mapInit,
  });

  // Create ref to map to call Mapbox GL functions on instance
  const mapRef = useRef();

  const isTablet = useIsTablet();

  const [mapData, setMapData] = useState("");
  const [interactiveLayerIds, setInteractiveLayerIds] = useState(null);
  const [selectedFeature, setSelectedFeature] = useState(null);
  const [cityCouncilOverlay, setCityCouncilOverlay] = useState(null);
  const [isMapDataLoading, setIsMapDataLoading] = useState(false);
  const [crashCounts, setCrashCounts] = useState(null);
  const [, setPointData] = useState(null);

  const {
    mapFilters: [filters],
    mapFilterType: [isMapTypeSet],
    mapDateRange: dateRange,
    mapOverlay: [overlay],
    mapTimeWindow: [mapTimeWindow],
    mapPolygon: [mapPolygon, setMapPolygon],
  } = React.useContext(StoreContext);

  // Add/remove listeners for spinner logic
  useMapEventHandler("data", () => setIsMapDataLoading(true), mapRef);
  useMapEventHandler("idle", () => setIsMapDataLoading(false), mapRef);

  // Fetch initial crash data and refetch upon filters change
  useEffect(() => {
    // Sort and count crash data into fatality and injury subsets
    const sortAndCountMapData = (data) => {
      const crashCounts = { injury: 0, fatality: 0 };
      const features =
        data.features &&
        data.features.reduce(
          (acc, feature) => {
            crashCounts["injury"] += parseInt(
              feature.properties.sus_serious_injry_cnt
            );
            crashCounts["fatality"] += parseInt(feature.properties.death_cnt);

            if (parseInt(feature.properties.sus_serious_injry_cnt) > 0) {
              acc.injuries.features.push(feature);
            }
            if (parseInt(feature.properties.death_cnt) > 0) {
              acc.fatalities.features.push(feature);
            }
            return acc;
          },
          {
            fatalities: { ...data, features: [] },
            injuries: { ...data, features: [] },
          }
        );

      setCrashCounts(crashCounts);
      return features;
    };

    const apiUrl = createMapDataUrl(
      crashGeoJSONEndpointUrl,
      filters,
      dateRange,
      mapPolygon,
      mapTimeWindow
    );

    setCrashCounts(null); // Clear stale totals before fetch
    !!apiUrl &&
      axios.get(apiUrl).then((res) => {
        const sortedMapData = sortAndCountMapData(res.data);

        setMapData(sortedMapData);
      });
  }, [filters, dateRange, mapTimeWindow, mapPolygon, setMapData]);

  // Fetch City Council Districts geojson
  useEffect(() => {
    const overlayUrl = `https://services.arcgis.com/0L95CJ0VTaxqcmED/ArcGIS/rest/services/BOUNDARIES_single_member_districts/FeatureServer/0/query?where=1%3D1&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&resultType=none&distance=0.0&units=esriSRUnit_Meter&relationParam=&returnGeodetic=false&outFields=COUNCIL_DISTRICT&returnGeometry=true&returnCentroid=false&featureEncoding=esriDefault&multipatchOption=xyFootprint&maxAllowableOffset=&geometryPrecision=6&outSR=4326&defaultSR=&datumTransformation=&applyVCSProjection=false&returnIdsOnly=false&returnUniqueIdsOnly=false&returnCountOnly=false&returnExtentOnly=false&returnQueryGeometry=false&returnDistinctValues=false&cacheHint=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&having=&resultOffset=&resultRecordCount=&returnZ=false&returnM=false&returnExceededLimitFeatures=true&quantizationParameters=&sqlFormat=none&f=pgeojson&token=`;
    axios.get(overlayUrl).then((res) => {
      setCityCouncilOverlay(res.data);
    });
  }, []);

  // Restrict map navigation to Travis County
  const restrictNavAndZoom = (viewport) => {
    if (viewport.longitude < mapNavBbox.longitude.min) {
      viewport.longitude = mapNavBbox.longitude.min;
    }
    if (viewport.longitude > mapNavBbox.longitude.max) {
      viewport.longitude = mapNavBbox.longitude.max;
    }
    if (viewport.latitude < mapNavBbox.latitude.min) {
      viewport.latitude = mapNavBbox.latitude.min;
    }
    if (viewport.latitude > mapNavBbox.latitude.max) {
      viewport.latitude = mapNavBbox.latitude.max;
    }

    // Limit zoom
    if (viewport.zoom < 10) {
      viewport.zoom = 10;
    }

    return viewport;
  };

  const _onViewportChange = (viewport) => {
    viewport = restrictNavAndZoom(viewport);
    setViewport(viewport);
  };

  // Change cursor to grab when dragging map and pointer when hovering an interactive layer
  const _getCursor = ({ isHovering, isDragging }) =>
    isDragging ? "grab" : isHovering ? "pointer" : "default";

  // Set interactive layer IDs to allow cursor to change if isHovering
  useEffect(() => {
    const interactiveLayerIds = [
      isMapTypeSet.fatal && "fatalities",
      isMapTypeSet.injury && "seriousInjuries",
      cityCouncilOverlay && overlay.name === "cityCouncil" && "cityCouncil",
    ];

    const filteredInteractiveIds = interactiveLayerIds.filter((id) => !!id);
    setInteractiveLayerIds(filteredInteractiveIds);
  }, [isMapTypeSet, cityCouncilOverlay, overlay.name]);

  const _onSelectCrashPoint = (event) => {
    // Prevent events from map controls from selecting features below
    // or from creating City Council district pop-up on mobile polygon draw
    if (
      event.srcEvent &&
      event.srcEvent.srcElement &&
      event.srcEvent.srcElement.classList
    ) {
      if (
        event.srcEvent.srcElement.classList.value.includes("mapbox") ||
        event.srcEvent.target.localName === "circle"
      )
        return;
    }
    const { features } = event;
    // Filter feature to set in state and set hierarchy
    let selectedFeature =
      features &&
      features.find(
        (f) =>
          f.layer.id === "fatalities" ||
          f.layer.id === "seriousInjuries" ||
          f.layer.id === "cityCouncil" ||
          null
      );

    let selectedFeatureLayer =
      (!!selectedFeature &&
        selectedFeature.layer &&
        selectedFeature.layer.id) ||
      null;

    // Supplement feature properties with lat/long to set popup coords if not in feature metadata
    if (!!selectedFeature && selectedFeatureLayer === "cityCouncil") {
      selectedFeature = {
        ...selectedFeature,
        properties: {
          ...selectedFeature.properties,
          latitude: event.lngLat[1],
          longitude: event.lngLat[0],
        },
      };
    }

    // Supplement crash feature properties with pixel coords to keep popup in viewport
    if (
      (!!selectedFeature && selectedFeatureLayer === "fatalities") ||
      selectedFeatureLayer === "seriousInjuries"
    ) {
      selectedFeature = {
        ...selectedFeature,
        properties: {
          ...selectedFeature.properties,
          pixelCoordinates: mapRef.current.project([
            parseFloat(selectedFeature.properties.longitude),
            parseFloat(selectedFeature.properties.latitude),
          ]),
        },
      };
    }

    setSelectedFeature(selectedFeature);
  };

  const renderCrashDataLayers = () => {
    // Layer order depends on order set, so set fatalities last to keep on top
    const injuryLayer = (
      <Source id="crashInjuries" type="geojson" data={mapData.injuries}>
        <Layer
          beforeId="place_label_city_small_s"
          {...seriousInjuriesOutlineDataLayer}
        />
        <Layer
          beforeId="place_label_city_small_s"
          {...seriousInjuriesDataLayer}
        />
      </Source>
    );
    const fatalityLayer = (
      <Source id="crashFatalities" type="geojson" data={mapData.fatalities}>
        <Layer
          beforeId="place_label_city_small_s"
          {...fatalitiesOutlineDataLayer}
        />
        <Layer beforeId="place_label_city_small_s" {...fatalitiesDataLayer} />
      </Source>
    );
    const bothLayers = (
      <>
        {injuryLayer}
        {fatalityLayer}
      </>
    );
    return bothLayers;
  };

  useEffect(() => {
    const animation = window.requestAnimationFrame(() => {
      if (selectedFeature) setPointData({});
    });
    return () => window.cancelAnimationFrame(animation);
  });

  const renderSelectedLayer = () => {
    const color = {
      r: selectedFeature.layer.paint[`${selectedFeature.layer.type}-color`].r * 255,
      g: selectedFeature.layer.paint[`${selectedFeature.layer.type}-color`].g * 255,
      b: selectedFeature.layer.paint[`${selectedFeature.layer.type}-color`].b * 255,
      a: selectedFeature.layer.paint[`${selectedFeature.layer.type}-color`].a,
    };

    const selectedLayer = (
      <Source id="selectedCrash" type="geojson" data={selectedFeature}>
        <AnimatedIcon
          location={{
            x: parseFloat(selectedFeature.properties.longitude),
            y: parseFloat(selectedFeature.properties.latitude),
          }}
          paint={color}
        />
      </Source>
    );
    return selectedLayer;
  };

  // Show/hide type layers based on isMapTypeSet state in Context
  useEffect(() => {
    const map = mapRef.current;

    const setLayersVisibility = (idArray, visibilityString) => {
      idArray.forEach((id) =>
        mapRef.current.setLayoutProperty(id, "visibility", visibilityString)
      );
    };

    if (map.getLayer("fatalities") && map.getLayer("fatalitiesOutline")) {
      const fatalityIds = ["fatalities", "fatalitiesOutline"];
      const fatalVisibility = isMapTypeSet.fatal ? "visible" : "none";
      setLayersVisibility(fatalityIds, fatalVisibility);
    }

    if (
      map.getLayer("seriousInjuries") &&
      map.getLayer("seriousInjuriesOutline")
    ) {
      const injuryIds = ["seriousInjuries", "seriousInjuriesOutline"];
      const injuryVisibility = isMapTypeSet.injury ? "visible" : "none";
      setLayersVisibility(injuryIds, injuryVisibility);
    }
  }, [isMapTypeSet]);

  return (
    <ReactMapGL
      {...viewport}
      width="100%"
      height="100%"
      onViewportChange={_onViewportChange}
      mapboxApiAccessToken={MAPBOX_TOKEN}
      getCursor={_getCursor}
      interactiveLayerIds={interactiveLayerIds}
      onClick={_onSelectCrashPoint}
      ref={(ref) => (mapRef.current = ref && ref.getMap())}
    >
      {/* Provide empty source and layer as target for beforeId params to set order of layers */}
      {baseSourceAndLayer}
      {/* Crash Data Points */}
      {!!mapData && renderCrashDataLayers()}
      {selectedFeature && renderSelectedLayer()}
      {/* ASMP Street Level Layers */}
      {buildAsmpLayers(asmpConfig, overlay)}
      {/* High Injury Network Layer */}
      {buildHighInjuryLayer(overlay)}
      {!!cityCouncilOverlay && overlay.name === "cityCouncil" && (
        <Source type="geojson" data={cityCouncilOverlay}>
          {/* Add beforeId to render beneath crash points, road layer, and map labels */}
          <Layer beforeId="road-street" {...cityCouncilDataLayer} />
        </Source>
      )}
      {/* Grey out disabled navigation area */}
      <Source type="geojson" data={travisCountyBboxGeoJSON}>
        <Layer {...travisCountyDataLayer} />
      </Source>
      {/* Render feature info or popup */}
      {selectedFeature && (
        <MapInfoBox
          selectedFeature={selectedFeature}
          setSelectedFeature={setSelectedFeature}
          isTablet={isTablet}
          type={selectedFeature.layer.id}
        />
      )}
      {!!crashCounts && !!mapPolygon && !selectedFeature && (
        <MapPolygonInfoBox
          crashCounts={crashCounts}
          isMapTypeSet={isMapTypeSet}
        />
      )}
      <MapCompassSpinner isSpinning={isMapDataLoading} />
      <MapControls setViewport={setViewport} />
      <MapPolygonFilter setMapPolygon={setMapPolygon} />
    </ReactMapGL>
  );
};

export default Map;
