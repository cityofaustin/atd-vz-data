import React from "react";
import MapGL, {
  Marker,
  NavigationControl,
  FullscreenControl,
} from "react-map-gl";
import Pin from "./Pin";
import {
  defaultInitialState,
  LabeledAerialSourceAndLayer,
  mapParameters,
} from "../../../helpers/map";
import "mapbox-gl/dist/mapbox-gl.css";

const CrashMap = ({ latitude, longitude }) => {
  return (
    <MapGL
      initialViewState={{
        latitude: latitude || defaultInitialState.latitude,
        longitude: longitude || defaultInitialState.longitude,
        zoom: defaultInitialState.zoom,
      }}
      {...mapParameters}
      cooperativeGestures={true}
      // Resize the map canvas when parent row expands to fit crash diagram
      onLoad={e => e.target.resize()}
    >
      <FullscreenControl position="top-left" />
      <NavigationControl position="top-left" showCompass={false} />
      <Marker latitude={latitude} longitude={longitude}>
        <Pin size={40} color={"warning"} />
      </Marker>
      {/* add nearmap raster source and style */}
      <LabeledAerialSourceAndLayer />
    </MapGL>
  );
};

export default CrashMap;
