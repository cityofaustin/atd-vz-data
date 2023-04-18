import React from "react";
import { NavLink } from "react-router-dom";
import { useAuth0 } from "../../auth/authContext";
import Can from "../../auth/Can";
import {
  UncontrolledDropdown,
  DropdownItem,
  DropdownMenu,
  DropdownToggle,
  Nav,
  NavItem,
} from "reactstrap";
import PropTypes from "prop-types";

import { AppNavbarBrand, AppSidebarToggler } from "@coreui/react";
import logo from "../../assets/img/brand/visionzerotext.png";

const propTypes = {
  children: PropTypes.node,
};

const defaultProps = {};

const DefaultHeader = props => {
  const { logout, getRoles } = useAuth0();
  // eslint-disable-next-line
  const { children, ...attributes } = props;

  return (
    <React.Fragment>
      <AppSidebarToggler className="d-lg-none" display="md" mobile />
      <AppNavbarBrand
        full={{
          src: logo,
          width: 140,
          height: 25,
          alt: "Vision Zero Austin",
        }}
      />
      <AppSidebarToggler className="d-md-down-none" display="lg" />

      <Nav className="d-md-down-none" navbar>
        <NavItem className="px-3">
          <NavLink to="/dashboard" className="nav-link">
            Dashboard
          </NavLink>
        </NavItem>
        <Can
          roles={getRoles()}
          perform="users:visit"
          yes={() => (
            <NavItem className="px-3">
              <NavLink to="/users" className="nav-link">
                Users
              </NavLink>
            </NavItem>
          )}
        />
      </Nav>
      <Nav className="ml-auto" navbar>
        <UncontrolledDropdown nav direction="down">
          <DropdownToggle nav>
            <img
              src={"./assets/img/avatars/1.png"}
              className="img-avatar"
              alt="admin@bootstrapmaster.com"
            />
          </DropdownToggle>
          <DropdownMenu right>
            <DropdownItem header tag="div" className="text-center">
              <strong>Account</strong>
            </DropdownItem>
            <DropdownItem href="#/profile">
              <i className="fa fa-user" /> Profile
            </DropdownItem>
            <DropdownItem onClick={logout}>
              <i className="fa fa-lock" /> Log Out
            </DropdownItem>
          </DropdownMenu>
        </UncontrolledDropdown>
        <UncontrolledDropdown nav direction="down">
            <DropdownToggle nav>
              <i className="fa fa-question-circle fa-2x" />
            </DropdownToggle>
            <DropdownMenu right>
              <DropdownItem header tag="div" className="text-center">
                <strong>Support</strong>
              </DropdownItem>
              <DropdownItem
                href="https://atd.knack.com/dts#new-service-request/?view_249_vars=%7B%22field_398%22%3A%22Bug%20Report%20%E2%80%94%20Something%20is%20not%20working%22%2C%22field_399%22%3A%22Vision%20Zero%20(Editor)%22%7D"
                target="_blank"
                rel="noreferrer"
              >
                <i className="fa fa-bug" /> Report a bug&nbsp;&nbsp; <i className="fa fa-external-link" />
              </DropdownItem>
              <DropdownItem
                href="https://atd.knack.com/dts#new-service-request/?view_249_vars=%7B%22field_398%22%3A%22Feature%20or%20Enhancement%20%E2%80%94%20An%20application%20I%20use%20could%20be%20improved%22%2C%22field_399%22%3A%22Vision%20Zero%20(Editor)%22%7D"
                target="_blank"
                rel="noreferrer"
              >
                <i className="fa fa-wrench" /> Request an enhancement&nbsp;&nbsp; <i className="fa fa-external-link" />
              </DropdownItem>
              <DropdownItem
                href="https://ftp.dot.state.tx.us/pub/txdot-info/trf/crash_notifications/2023/code-sheet.pdf"
                target="_blank"
                rel="noreferrer"
              >
                <i class="fa fa-briefcase" /> CR3 code sheet&nbsp;&nbsp; <i className="fa fa-external-link" />
              </DropdownItem>
            </DropdownMenu>
        </UncontrolledDropdown>
      </Nav>
    </React.Fragment>
  );
};

DefaultHeader.propTypes = propTypes;
DefaultHeader.defaultProps = defaultProps;

export default DefaultHeader;
