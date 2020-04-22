import React from "react";
import styled from "styled-components";
import { GeolocateControl, NavigationControl } from "react-map-gl";
import MapPolygonFilter from "./MapPolygonFilter";

const StyledMapNav = styled.div`
  .nav-buttons {
    position: absolute;
    top: 0px;
    right: 0px;
    padding: 10px;
  }

  .geolocate-button {
    position: absolute;
    top: 68px;
    right: 0px;
    padding: 10px;
  }

  .polygon-button {
    position: relative;
    top: 107px;
  }
`;

const MapControls = ({ setViewport, setMapPolygon }) => {
  const _onViewportGeolocate = (viewport) =>
    setViewport({ ...viewport, zoom: 15 });

  return (
    <StyledMapNav>
      <div className="nav-buttons">
        <NavigationControl showCompass={false} />
      </div>
      <div className="geolocate-button">
        <GeolocateControl onViewportChange={_onViewportGeolocate} />
      </div>
      <div className="polygon-button">
        <MapPolygonFilter setMapPolygon={setMapPolygon} />
      </div>
    </StyledMapNav>
  );
};

export default MapControls;
