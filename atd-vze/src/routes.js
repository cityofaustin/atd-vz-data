import React from "react";
import { isAdmin, isItSupervisor } from "./auth/authContext";

const VZDashboard = React.lazy(() => import("./views/VZDashboard"));

const Crashes = React.lazy(() => import("./views/Crashes/Crashes"));
const Crash = React.lazy(() => import("./views/Crashes/Crash"));
const Profile = React.lazy(() => import("./views/Profile/Profile"));
const Locations = React.lazy(() => import("./views/Locations/Locations"));
const Location = React.lazy(() => import("./views/Locations/Location"));
const Fatalities = React.lazy(() => import("./views/Fatalities/Fatalities"));
const Users = React.lazy(() => import("./views/Users/Users"));
const User = React.lazy(() => import("./views/Users/User"));
const AddUser = React.lazy(() => import("./views/Users/AddUser"));
const EditUser = React.lazy(() => import("./views/Users/EditUser"));
const ToolsUploadNonCR3 = React.lazy(() =>
  import("./views/Tools/ToolsUploadNonCR3")
);
const CreateCrashRecord = React.lazy(() =>
  import("./views/Tools/CreateCrashRecord")
);
// https://github.com/ReactTraining/react-router/tree/master/packages/react-router-config
// Accept roles arg for role-based access to routes
const routes = roles => [
  { path: "/", exact: true, name: "Home" },

  { path: "/profile", name: "Profile", component: Profile },
  {
    path: "/dashboard",
    exact: true,
    name: "Dashboard",
    component: VZDashboard,
  },
  { path: "/locations", exact: true, name: "Locations", component: Locations },
  {
    path: "/locations/:id",
    exact: true,
    name: "Location Details",
    component: Location,
  },
  { path: "/crashes", exact: true, name: "Crashes", component: Crashes },
  {
    path: "/crashes/:id",
    exact: true,
    name: "Crash Details",
    component: Crash,
  },
  (isAdmin(roles) || isItSupervisor(roles)) && {
    path: "/fatalities",
    exact: true,
    name: "Fatalities",
    component: Fatalities,
  },
  (isAdmin(roles) || isItSupervisor(roles)) && {
    path: "/tools/upload_non_cr3",
    exact: true,
    name: "Upload Non-CR3 Crashes",
    component: ToolsUploadNonCR3,
  },
  (isAdmin(roles) || isItSupervisor(roles)) && {
    path: "/tools/create_crash_record",
    exact: true,
    name: "Create Crash Record",
    component: CreateCrashRecord,
  },
  (isAdmin(roles) || isItSupervisor(roles)) && {
    path: "/users",
    exact: true,
    name: "Users",
    component: Users,
  },
  (isAdmin(roles) || isItSupervisor(roles)) && {
    path: "/users/add",
    exact: true,
    name: "Add User",
    component: AddUser,
  },
  (isAdmin(roles) || isItSupervisor(roles)) && {
    path: "/users/:id/edit",
    exact: true,
    name: "Edit User",
    component: EditUser,
  },
  (isAdmin(roles) || isItSupervisor(roles)) && {
    path: "/users/:id",
    exact: true,
    name: "User Details",
    component: User,
  },
];

export default routes;
