import React from "react";

import MapGL, {
  Marker,
  NavigationControl,
  FullscreenControl,
} from "react-map-gl";

import Pin from "./Pin";
import { useMutation } from "react-apollo";
import { UPDATE_CRASH } from "../../../queries/crashes";
import { CrashEditLatLonForm } from "./CrashEditLatLonForm";
import {
  defaultInitialState,
  LabeledAerialSourceAndLayer,
  mapParameters,
} from "../../../helpers/map";

const CrashEditCoordsMap = ({
  latitude,
  longitude,
  crashPk,
  refetchCrashData,
  setIsEditingCoords,
}) => {
  const mapRef = React.useRef();
  const [isDragging, setIsDragging] = React.useState(false);
  const [markerCoordinates, setMarkerCoordinates] = React.useState({
    latitude: latitude,
    longitude: longitude,
  });
  const [isSubmitting, setIsSubmitting] = React.useState(false);

  const [updateCrashCoordinates] = useMutation(UPDATE_CRASH);

  const onDrag = e => {
    const latitude = e.viewState.latitude;
    const longitude = e.viewState.longitude;

    setMarkerCoordinates({ latitude, longitude });
  };

  const handleFormSubmit = e => {
    e.preventDefault();
    setIsSubmitting(true);

    const variables = {
      id: crashPk,
      changes: {
        ...markerCoordinates,
        updated_by: localStorage.getItem("hasura_user_email"),
      },
    };

    updateCrashCoordinates({
      variables: variables,
    }).then(() => {
      // Refetch and then close edit map so CrashMap initializes with updated coordinates
      refetchCrashData().then(() => {
        setIsSubmitting(false);
        setIsEditingCoords(false);
      });
    });
  };

  const handleFormReset = () => {
    // Reset marker to original coordinates or default fallback
    const originalMarkerCoordinates = {
      latitude: latitude || defaultInitialState.latitude,
      longitude: longitude || defaultInitialState.longitude,
    };

    // Move map center and marks to original coordinates or default fallback
    setMarkerCoordinates(originalMarkerCoordinates);
    mapRef.current &&
      mapRef.current.jumpTo({
        center: [
          originalMarkerCoordinates.longitude,
          originalMarkerCoordinates.latitude,
        ],
      });
  };

  const handleFormCancel = () => {
    setIsEditingCoords(false);
  };

  return (
    <>
      <MapGL
        ref={mapRef}
        initialViewState={{
          latitude: latitude || defaultInitialState.latitude,
          longitude: longitude || defaultInitialState.longitude,
          zoom: defaultInitialState.zoom,
        }}
        style={{ width: "100%", height: "50vh" }}
        {...mapParameters}
        draggable
        onDragStart={() => setIsDragging(true)}
        onDrag={onDrag}
        onDragEnd={() => setIsDragging(false)}
      >
        <FullscreenControl position="top-left" />
        <NavigationControl position="top-left" showCompass={false} />
        <Marker
          latitude={markerCoordinates.latitude || defaultInitialState.latitude}
          longitude={
            markerCoordinates.longitude || defaultInitialState.longitude
          }
        >
          <Pin size={40} color={"warning"} isDragging={isDragging} animated />
        </Marker>
        {/* add nearmap raster source and style */}
        <LabeledAerialSourceAndLayer />
      </MapGL>
      <CrashEditLatLonForm
        {...markerCoordinates}
        handleFormSubmit={handleFormSubmit}
        handleFormReset={handleFormReset}
        handleFormCancel={handleFormCancel}
        isSubmitting={isSubmitting}
      />
    </>
  );
};

export default CrashEditCoordsMap;
