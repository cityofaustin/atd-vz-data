import React from "react";

import { Nav, Alert } from "reactstrap";
import CssBaseline from "@material-ui/core/CssBaseline";
import Drawer from "@material-ui/core/Drawer";
import Hidden from "@material-ui/core/Hidden";
import { makeStyles, useTheme } from "@material-ui/core/styles";
import styled from "styled-components";
import { drawer } from "../../constants/drawer";
import { colors } from "../../constants/colors";
import SideMapControl from "./sideMapControl";

const drawerWidth = drawer.width;

// Styles for MUI drawer
const useStyles = makeStyles(theme => ({
  root: {
    display: "flex"
  },
  drawer: {
    [theme.breakpoints.up("sm")]: {
      width: drawerWidth,
      flexShrink: 0
    }
  },
  menuButton: {
    marginRight: theme.spacing(2),
    [theme.breakpoints.up("sm")]: {
      display: "none"
    }
  },
  drawerPaper: {
    width: drawerWidth,
    background: colors.dark,
    color: colors.light,
    border: 0
  },
  content: {
    flexGrow: 1,
    padding: theme.spacing(3)
  }
}));

const StyledDrawerHeader = styled.div`
  background: ${colors.light};
  color: ${colors.dark};
  padding: 20px;
  height: ${drawer.headerHeight}px;
`;

const SideDrawer = ({ toggle, isOpen, updateMapFilters }) => {
  const classes = useStyles();
  const theme = useTheme();

  const drawerContent = (
    <div className="side-menu">
      {/* TODO: Remove disclaimer  */}
      <Nav vertical className="list-unstyled pb-3">
        <StyledDrawerHeader>
          <h3>Vision Zero Viewer</h3>
        </StyledDrawerHeader>

        <Alert color="danger" className="m-2 p-1">
          <strong>This site is a work in progress.</strong>
          <br />
          <span>
            The information displayed may be outdated or incorrect. Check back
            later for live Vision Zero data.
          </span>
        </Alert>
      </Nav>
    </div>
  );

  return (
    <div className={classes.root}>
      <CssBaseline />
      <nav className={classes.drawer} aria-label="sidebar">
        {/* One drawer for desktop, one drawer for mobile */}
        <Hidden smUp implementation="css">
          <Drawer
            variant="temporary"
            anchor={theme.direction === "rtl" ? "right" : "left"}
            open={isOpen}
            onClose={toggle}
            classes={{
              paper: classes.drawerPaper
            }}
            ModalProps={{
              keepMounted: true // Better open performance on mobile.
            }}
          >
            {drawerContent}
            <SideMapControl updateMapFilters={updateMapFilters} />
          </Drawer>
        </Hidden>
        <Hidden xsDown implementation="css">
          <Drawer
            classes={{
              paper: classes.drawerPaper
            }}
            variant="permanent"
            open
          >
            {drawerContent}
            {/* TODO: Dynamic sidebar content based on route */}
            <SideMapControl updateMapFilters={updateMapFilters} />
          </Drawer>
        </Hidden>
      </nav>
    </div>
  );
};

export default SideDrawer;
