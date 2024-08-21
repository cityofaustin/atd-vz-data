import React from "react";
import { usePath } from "hookrouter";
import SideDrawer from "./views/nav/SideDrawer";
import Content from "./views/content/Content";
import UnderMaintenance from "./views/NotFound/UnderMaintenance";
import "./App.css";

const App = () => {
  const currentPath = usePath();
  const isMeasuresPath = currentPath === "/measures";
  const isUnderMaintenance = process.env.REACT_APP_UNDER_MAINTENANCE === "True";

  console.log(process.env.REACT_APP_UNDER_MAINTENANCE);

  if (isUnderMaintenance) {
    return (
      <div className="App">
        <UnderMaintenance />
      </div>
    );
  }

  return (
    <div className="App">
      {!isMeasuresPath && <SideDrawer />}
      <Content />
    </div>
  );
};

export default App;
