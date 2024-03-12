import React, { Component } from "react";
import { withApollo } from "react-apollo";
import { UPDATE_COORDS } from "../../../queries/crashes";

import MapGL, {
  Marker,
  NavigationControl,
  FullscreenControl,
} from "react-map-gl";
import "mapbox-gl/dist/mapbox-gl.css";
// import Geocoder from "react-map-gl-geocoder";
// import { CustomGeocoderMapController } from "./customGeocoderMapController";
import "react-map-gl-geocoder/dist/mapbox-gl-geocoder.css";

import Pin from "./Pin";
import { CrashEditLatLonForm } from "./CrashEditLatLonForm";

import {
  LOCATION_MAP_CONFIG,
  LabeledAerialSourceAndLayer,
} from "../../../helpers/map";

const TOKEN = process.env.REACT_APP_MAPBOX_TOKEN;

const fullscreenControlStyle = {
  position: "absolute",
  top: 0,
  left: 0,
  padding: "10px",
};

const navStyle = {
  position: "absolute",
  top: 36,
  left: 0,
  padding: "10px",
};

// const customGeocoderMapController = new CustomGeocoderMapController();

class CrashEditCoordsMap extends Component {
  constructor(props) {
    super(props);

    // Default map center
    this.initialMapCenter = {
      latitude: this.props.data.latitude_primary || 30.26714,
      longitude: this.props.data.longitude_primary || -97.743192,
    };

    this.state = {
      viewport: {
        latitude: this.initialMapCenter.latitude,
        longitude: this.initialMapCenter.longitude,
        zoom: 17,
        bearing: 0,
        pitch: 0,
      },
      popupInfo: null,
      markerLatitude: 0,
      markerLongitude: 0,
      isDragging: false,
    };
  }

  // Tie map and geocoder control together
  mapRef = React.createRef();

  _handleViewportChange = viewport => {
    this.setState({
      viewport: { ...this.state.viewport, ...viewport },
    });
  };

  _updateViewport = viewport => {
    this.setState({
      viewport,
      markerLatitude: viewport.latitude,
      markerLongitude: viewport.longitude,
    });
  };

  getCursor = ({ isDragging }) => {
    isDragging !== this.state.isDragging && this.setState({ isDragging });
  };

  handleMapFormSubmit = e => {
    e.preventDefault();

    const variables = {
      qaStatus: 3, // Lat/Long entered manually to Primary
      geocodeProvider: 5, // Manual Q/A
      crashId: this.props.crashId,
      latitude: this.state.markerLatitude,
      longitude: this.state.markerLongitude,
      updatedBy: localStorage.getItem("hasura_user_email"),
    };

    this.props.client
      .mutate({
        mutation: UPDATE_COORDS,
        variables: variables,
      })
      .then(res => {
        this.props.refetchCrashData();
        this.props.setIsEditingCoords(false);
      });
  };

  handleMapFormReset = e => {
    e.preventDefault();
    const updatedViewport = {
      ...this.state.viewport,
      latitude: this.initialMapCenter.latitude,
      longitude: this.initialMapCenter.longitude,
    };
    this.setState({
      viewport: updatedViewport,
      markerLatitude: updatedViewport.latitude,
      markerLongitude: updatedViewport.longitude,
    });
  };

  handleMapFormCancel = e => {
    e.preventDefault();
    this.props.setIsEditingCoords(false);
  };

  render() {
    const {
      viewport,
      markerLatitude,
      markerLongitude,
      isDragging,
    } = this.state;
    const geocoderAddress = this.props.mapGeocoderAddress;
    const isDev = window.location.hostname === "localhost";

    return (
      <div>
        <MapGL
          {...viewport}
          ref={this.mapRef}
          width="100%"
          height="350px"
          mapStyle={
            isDev
              ? "mapbox://styles/mapbox/satellite-streets-v11"
              : LOCATION_MAP_CONFIG.mapStyle
          }
          onViewportChange={this._updateViewport}
          getCursor={this.getCursor}
          // controller={customGeocoderMapController}
          mapboxApiAccessToken={TOKEN}
        >
          {/* <Geocoder
            mapRef={this.mapRef}
            onViewportChange={this._handleViewportChange}
            mapboxApiAccessToken={TOKEN}
            inputValue={geocoderAddress}
            options={{ flyTo: false }}
            // Bounding box for auto-populated results in the search bar
            bbox={[-98.22464, 29.959694, -97.226257, 30.687526]}
          /> */}
          <div className="fullscreen" style={fullscreenControlStyle}>
            <FullscreenControl />
          </div>
          <div className="nav" style={navStyle}>
            <NavigationControl showCompass={false} />
          </div>
          {/* add nearmap raster source and style */}
          {!isDev && <LabeledAerialSourceAndLayer />}
          <Marker latitude={markerLatitude} longitude={markerLongitude}>
            <Pin size={40} isDragging={isDragging} animated />
          </Marker>
        </MapGL>
        <CrashEditLatLonForm
          latitude={markerLatitude}
          longitude={markerLongitude}
          handleFormSubmit={this.handleMapFormSubmit}
          handleFormReset={this.handleMapFormReset}
          handleFormCancel={this.handleMapFormCancel}
        />
      </div>
    );
  }
}

export default withApollo(CrashEditCoordsMap);
