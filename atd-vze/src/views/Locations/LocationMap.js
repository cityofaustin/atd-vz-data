import React from "react";
import MapGL, {
  NavigationControl,
  FullscreenControl,
  Source,
  Layer,
} from "react-map-gl";
import bbox from "@turf/bbox";
import {
  defaultInitialState,
  LabeledAerialSourceAndLayer,
  mapParameters,
} from "../../helpers/map";
import { colors } from "../../styles/colors";
import "mapbox-gl/dist/mapbox-gl.css";

// Styles for location polygon overlay
const polygonDataLayer = {
  id: "location-polygon",
  type: "line",
  paint: {
    "line-color": colors.warning,
    "line-width": 3,
  },
};

const LocationMap = ({ location }) => {
  const locationGeoJson = location
    ? {
        type: "Feature",
        properties: {
          renderType: location.geometry.type,
          id: location.location_id,
        },
        geometry: {
          coordinates: location.geometry.coordinates,
          type: location.geometry.type,
        },
      }
    : null;
  const initialBounds = bbox(locationGeoJson);

  return (
    <MapGL
      initialViewState={{
        latitude: location?.latitude || defaultInitialState.latitude,
        longitude: location?.longitude || defaultInitialState.longitude,
        zoom: defaultInitialState.zoom,
        bounds: initialBounds,
        fitBoundsOptions: { duration: 0, padding: 100 },
      }}
      style={{ width: "100%", height: "500px" }}
      {...mapParameters}
      cooperativeGestures={true}
    >
      <FullscreenControl position="top-left" />
      <NavigationControl position="top-left" showCompass={false} />
      <Source type="geojson" data={locationGeoJson}>
        <Layer {...polygonDataLayer} />
      </Source>
      {/* add nearmap raster source and style */}
      <LabeledAerialSourceAndLayer beforeId="location-polygon" />
    </MapGL>
  );
};

export default LocationMap;
