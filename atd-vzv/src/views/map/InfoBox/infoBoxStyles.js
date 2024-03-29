import styled from "styled-components";
import { responsive } from "../../../constants/responsive";

export const popupMarginsWidth = 20;
export const maxInfoBoxWidth = responsive.drawerWidth - popupMarginsWidth;

export const StyledPoylgonInfo = styled.div`
  position: absolute;
  margin: 6px;
  max-width: ${maxInfoBoxWidth}px;
  z-index: 9 !important;
  pointer-events: none;
  /* Combine the height of the geocoder box and 10px Mapbox spacing */
  top: 46px;
  /* Combine the mobile height of the geocoder box and 10px Mapbox spacing */
  @media (max-width: 639px) {
    top: 60px;
  }
`;

export const StyledMobileInfo = styled.div`
  .card {
    background: none;
    border: none;
    max-width: ${maxInfoBoxWidth}px;
  }
`;

export const setPopupPosition = (popupX) => {
  // Use the max width of info box to decide if it can fit centered on map point
  // or if it needs to offset from right or left of viewport
  const halfInfoBoxWidth = maxInfoBoxWidth / 2;
  const canInfoBoxFitCentered =
    popupX - halfInfoBoxWidth > 0 &&
    popupX + halfInfoBoxWidth < window.innerWidth;
  const isInfoBoxTooFarLeft = popupX - halfInfoBoxWidth <= 0;
  const isInfoBoxTooFarRight = popupX + halfInfoBoxWidth >= window.innerWidth;

  switch (!!popupX) {
    case canInfoBoxFitCentered:
      return `left: ${popupX - halfInfoBoxWidth};`;
    case isInfoBoxTooFarLeft:
      return `left: ${halfInfoBoxWidth - popupX}px;`;
    case isInfoBoxTooFarRight:
      return `right: ${popupX + halfInfoBoxWidth - window.innerWidth}px;`;
    default:
      return null;
  }
};
