import React from "react";
import MapGL, {
  NavigationControl,
  FullscreenControl,
  Source,
  Layer,
} from "react-map-gl";
import { WebMercatorViewport } from "@math.gl/web-mercator";
import "mapbox-gl/dist/mapbox-gl.css";
import axios from "axios";
import { format, parse } from "date-fns";
import bbox from "@turf/bbox";

import { colors } from "../../styles/colors";
import {
  isDev,
  defaultInitialState,
  LabeledAerialSourceAndLayer,
  mapParameters,
} from "../../helpers/map";

// const TimestampDisplay = styled.div`
//   top: 24px;
//   right: 24px;
//   position: absolute;
//   #timestamp-display:hover {
//     cursor: grab;
//   }
// `;

// export default class LocationMap extends Component {
//   constructor(props) {
//     super(props);
// this.polygon = this.props.data.atd_txdot_locations[0];

// this.state = {
//   viewport: {
//     latitude: this.polygon?.latitude || 30.2672,
//     longitude: this.polygon?.longitude || -97.7431,
//     zoom: 17,
//     bearing: 0,
// pitch: 0,
// },
// popupInfo: null,
// aerialTimestamp: "",
// };

// Create GeoJSON object from location polygon record for Source component
// this.locationPolygonGeoJson = this.polygon?.shape
//   ? {
//       type: "Feature",
//       properties: {
//         renderType: this.polygon.shape.type,
//         id: this.polygon.location_id,
//       },
//       geometry: {
//         coordinates: this.polygon.shape.coordinates,
//         type: this.polygon.shape.type,
//       },
//     }
//   : null;
// }

// _updateViewport = viewport => {
//   this.setState({ viewport });
// };

// getLatestAerialTimestamp = timestampArray => timestampArray.slice(-1)[0];

// convertNearMapTimeFormat = date => {
//   format(parse(date, "'/Date('T')/'", new Date()), "MM/dd/yyyy");
// };

// getAerialTimestamps = () => {
//   // Get all available aerial capture dates and set and format latest to state
//   // Tiles from API default to latest capture
//   // The following link contains helpful information about the API and its responses such as the date format:
//   // https://docs.nearmap.com/display/ND/Nearmap+TMS+Integration#NearmapTMSIntegration-Attributes
//   const { latitude, longitude, zoom } = this.state.viewport;
//   axios
//     .get(
//       `https://us0.nearmap.com/maps?ll=${latitude},${longitude}&nmq=INFO&nmf=json&zoom=${zoom}&httpauth=false&apikey=${NEARMAP_KEY}`
//     )
//     .then(res => {
//       const aerialTimestamp = this.convertNearMapTimeFormat(
//         this.getLatestAerialTimestamp(res.data.layers.Vert)
//       );
//       this.setState({ aerialTimestamp });
//     });
// };

// @see https://github.com/visgl/react-map-gl/blob/5.3-release/docs/advanced/viewport-transition.md#example-transition-viewport-to-a-bounding-box
// fitBoundsToLocationPolygon = () => {
//   const polygonBbox = bbox(this.locationPolygonGeoJson);

//   // We use WebMercatorViewport to calculate the new viewport
//   const { longitude, latitude, zoom } = new WebMercatorViewport({
//     ...this.state.viewport,
//     height: 500, // WebmercatorViewport requires height and width that are not in %
//     width: 500, // WebmercatorViewport requires height and width that are not in %
//   }).fitBounds(
//     // The bounding box of the polygon must be in the form [[minX, minY], [maxX, maxY]]
//     // @see https://docs.mapbox.com/mapbox-gl-js/api/geography/#lnglatboundslike
//     [[polygonBbox[0], polygonBbox[1]], [polygonBbox[2], polygonBbox[3]]],
//     {
//       padding: 100,
//     }
//   );

//   this.setState({
//     viewport: {
//       ...this.state.viewport,
//       longitude,
//       latitude,
//       zoom,
//       transitionDuration: 0,
//       width: "100%", // Now, we can set a % for width since react-map-gl accepts them
//     },
//   });
// };

// componentDidMount() {
//   this.getAerialTimestamps();

// Zoom to the location polygon if there is one
// this.polygon?.shape && this.fitBoundsToLocationPolygon();
// }

// render() {
//   const { viewport } = this.state;
//   const isDev = window.location.hostname === "localhost";

//   return (
//     <MapGL
//       {...viewport}
//       width="100%"
//       height="500px"
//       mapStyle={
//         isDev
//           ? "mapbox://styles/mapbox/satellite-streets-v9"
//           : LOCATION_MAP_CONFIG.mapStyle
//       }
//       onViewportChange={this._updateViewport}
//       mapboxApiAccessToken={TOKEN}
//     >
// {
//   /* add nearmap raster source and style */
// }
// {
//   /* {!isDev && <LabeledAerialSourceAndLayer />} */
// }

// {
//   /* Show polygon on map */
// }
// {
//   /* <Source type="geojson" data={this.locationPolygonGeoJson}>
//           <Layer {...polygonDataLayer} />
//         </Source> */
// }
// {
//   /* <div className="fullscreen" style={fullscreenControlStyle}>
//           <FullscreenControl />
//         </div>
//         <div className="nav" style={navStyle}>
//           <NavigationControl showCompass={false} />
//         </div> */
// }
// {
/* <TimestampDisplay>
          {this.state.aerialTimestamp && (
            <Button
              id="timestamp-display"
              block
              active
              color="ghost-light"
              aria-pressed="true"
            >
              Captured on {this.state.aerialTimestamp}
            </Button>
          )}
//         </TimestampDisplay> */
// }
//       </MapGL>
//     );
//   }
// }

// Styles for location polygon overlay
const polygonDataLayer = {
  id: "data",
  type: "line",
  paint: {
    "line-color": colors.warning,
    "line-width": 3,
  },
};

const LocationMap = ({ data }) => {
  const polygon = data.atd_txdot_locations?.[0] || null;
  const locationGeoJson = polygon
    ? {
        type: "Feature",
        properties: {
          renderType: polygon.shape.type,
          id: polygon.location_id,
        },
        geometry: {
          coordinates: polygon.shape.coordinates,
          type: polygon.shape.type,
        },
      }
    : null;

  // TODO: Fit bounds to location GeoJSON

  return (
    <MapGL
      initialViewState={{
        latitude: polygon?.latitude || 30.2672 || defaultInitialState.latitude,
        longitude: polygon?.longitude || defaultInitialState.longitude,
        zoom: defaultInitialState.zoom,
      }}
      style={{ width: "100%", height: "500px" }}
      {...mapParameters}
      cooperativeGestures={true}
    >
      <FullscreenControl position="top-left" />
      <NavigationControl position="top-left" showCompass={false} />
      {/* add nearmap raster source and style */}
      {!isDev && <LabeledAerialSourceAndLayer />}
      <Source type="geojson" data={locationGeoJson}>
        <Layer {...polygonDataLayer} />
      </Source>
    </MapGL>
  );
};

export default LocationMap;
