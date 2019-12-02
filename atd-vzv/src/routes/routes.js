import React from "react";
import Dashboard from "../views/dashboard/dashboard";
import Map from "../views/map/map";

export const routes = {
  "/": () => <Dashboard />,
  "/map": () => <Map />
};
