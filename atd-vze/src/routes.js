import React from "react";
import { isAdmin, isItSupervisor, isEditor } from "./auth/authContext";

const Breadcrumbs = React.lazy(() => import("./views/Base/Breadcrumbs"));
const Cards = React.lazy(() => import("./views/Base/Cards"));
const Carousels = React.lazy(() => import("./views/Base/Carousels"));
const Collapses = React.lazy(() => import("./views/Base/Collapses"));
const Dropdowns = React.lazy(() => import("./views/Base/Dropdowns"));
const Forms = React.lazy(() => import("./views/Base/Forms"));
const Jumbotrons = React.lazy(() => import("./views/Base/Jumbotrons"));
const ListGroups = React.lazy(() => import("./views/Base/ListGroups"));
const Navbars = React.lazy(() => import("./views/Base/Navbars"));
const Navs = React.lazy(() => import("./views/Base/Navs"));
const Paginations = React.lazy(() => import("./views/Base/Paginations"));
const Popovers = React.lazy(() => import("./views/Base/Popovers"));
const ProgressBar = React.lazy(() => import("./views/Base/ProgressBar"));
const Switches = React.lazy(() => import("./views/Base/Switches"));
const Tables = React.lazy(() => import("./views/Base/Tables"));
const Tabs = React.lazy(() => import("./views/Base/Tabs"));
const Tooltips = React.lazy(() => import("./views/Base/Tooltips"));
const BrandButtons = React.lazy(() => import("./views/Buttons/BrandButtons"));
const ButtonDropdowns = React.lazy(() =>
  import("./views/Buttons/ButtonDropdowns")
);
const ButtonGroups = React.lazy(() => import("./views/Buttons/ButtonGroups"));
const Buttons = React.lazy(() => import("./views/Buttons/Buttons"));
const Charts = React.lazy(() => import("./views/Charts"));
const Dashboard = React.lazy(() => import("./views/Dashboard"));
const VZDashboard = React.lazy(() => import("./views/VZDashboard"));
const CoreUIIcons = React.lazy(() => import("./views/Icons/CoreUIIcons"));
const Flags = React.lazy(() => import("./views/Icons/Flags"));
const FontAwesome = React.lazy(() => import("./views/Icons/FontAwesome"));
const SimpleLineIcons = React.lazy(() =>
  import("./views/Icons/SimpleLineIcons")
);
const Alerts = React.lazy(() => import("./views/Notifications/Alerts"));
const Badges = React.lazy(() => import("./views/Notifications/Badges"));
const Modals = React.lazy(() => import("./views/Notifications/Modals"));
const Colors = React.lazy(() => import("./views/Theme/Colors"));
const Typography = React.lazy(() => import("./views/Theme/Typography"));
const Widgets = React.lazy(() => import("./views/Widgets/Widgets"));
const Dev = React.lazy(() => import("./views/Dev/Dev"));
const Crashes = React.lazy(() => import("./views/Crashes/Crashes"));
const CrashesChanges = React.lazy(() =>
  import("./views/Crashes/CrashesChanges")
);
const CrashChange = React.lazy(() => import("./views/Crashes/CrashChange"));
const Crash = React.lazy(() => import("./views/Crashes/Crash"));
const Profile = React.lazy(() => import("./views/Profile/Profile"));
const Locations = React.lazy(() => import("./views/Locations/Locations"));
const Location = React.lazy(() => import("./views/Locations/Location"));
const Fatalities = React.lazy(() => import("./views/Fatalities/Fatalities"));
const Users = React.lazy(() => import("./views/Users/Users"));
const User = React.lazy(() => import("./views/Users/User"));
const AddUser = React.lazy(() => import("./views/Users/AddUser"));
const EditUser = React.lazy(() => import("./views/Users/EditUser"));
const ReportsInconsistentKSI = React.lazy(() =>
  import("./views/Reports/ReportsInconsistentKSI")
);
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
  { path: "/dev/dashboard", name: "Dashboard", component: Dashboard },
  { path: "/dev/theme", exact: true, name: "Theme", component: Colors },
  { path: "/dev/theme/colors", name: "Colors", component: Colors },
  { path: "/dev/theme/typography", name: "Typography", component: Typography },
  { path: "/dev/base", exact: true, name: "Base", component: Cards },
  { path: "/dev/base/cards", name: "Cards", component: Cards },
  { path: "/dev/base/forms", name: "Forms", component: Forms },
  { path: "/dev/base/switches", name: "Switches", component: Switches },
  { path: "/dev/base/tables", name: "Tables", component: Tables },
  { path: "/dev/base/tabs", name: "Tabs", component: Tabs },
  {
    path: "/dev/base/breadcrumbs",
    name: "Breadcrumbs",
    component: Breadcrumbs,
  },
  { path: "/dev/base/carousels", name: "Carousel", component: Carousels },
  { path: "/dev/base/collapses", name: "Collapse", component: Collapses },
  { path: "/dev/base/dropdowns", name: "Dropdowns", component: Dropdowns },
  { path: "/dev/base/jumbotrons", name: "Jumbotrons", component: Jumbotrons },
  { path: "/dev/base/list-groups", name: "List Groups", component: ListGroups },
  { path: "/dev/base/navbars", name: "Navbars", component: Navbars },
  { path: "/dev/base/navs", name: "Navs", component: Navs },
  {
    path: "/dev/base/paginations",
    name: "Paginations",
    component: Paginations,
  },
  { path: "/dev/base/popovers", name: "Popovers", component: Popovers },
  {
    path: "/dev/base/progress-bar",
    name: "Progress Bar",
    component: ProgressBar,
  },
  { path: "/dev/base/tooltips", name: "Tooltips", component: Tooltips },
  { path: "/dev/buttons", exact: true, name: "Buttons", component: Buttons },
  { path: "/dev/buttons/buttons", name: "Buttons", component: Buttons },
  {
    path: "/dev/buttons/button-dropdowns",
    name: "Button Dropdowns",
    component: ButtonDropdowns,
  },
  {
    path: "/dev/buttons/button-groups",
    name: "Button Groups",
    component: ButtonGroups,
  },
  {
    path: "/dev/buttons/brand-buttons",
    name: "Brand Buttons",
    component: BrandButtons,
  },
  { path: "/dev/icons", exact: true, name: "Icons", component: CoreUIIcons },
  {
    path: "/dev/icons/coreui-icons",
    name: "CoreUI Icons",
    component: CoreUIIcons,
  },
  { path: "/dev/icons/flags", name: "Flags", component: Flags },
  {
    path: "/dev/icons/font-awesome",
    name: "Font Awesome",
    component: FontAwesome,
  },
  {
    path: "/dev/icons/simple-line-icons",
    name: "Simple Line Icons",
    component: SimpleLineIcons,
  },
  {
    path: "/dev/notifications",
    exact: true,
    name: "Notifications",
    component: Alerts,
  },
  { path: "/dev/notifications/alerts", name: "Alerts", component: Alerts },
  { path: "/dev/notifications/badges", name: "Badges", component: Badges },
  { path: "/dev/notifications/modals", name: "Modals", component: Modals },
  { path: "/dev/widgets", name: "Widgets", component: Widgets },
  { path: "/dev/charts", name: "Charts", component: Charts },
  { path: "/profile", name: "Profile", component: Profile },
  { path: "/dashboard", name: "Dashboard", component: VZDashboard },
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
  {
    path: "/dev",
    exact: true,
    name: "Demo UI Components",
    component: Dev,
  },
  (isEditor(roles) || isAdmin(roles) || isItSupervisor(roles)) && {
    path: "/changes",
    exact: true,
    name: "Crash Changes",
    component: CrashesChanges,
  },
  (isEditor(roles) || isAdmin(roles) || isItSupervisor(roles)) && {
    path: "/changes/:id",
    exact: true,
    name: "Crash Change",
    component: CrashChange,
  },
  (isAdmin(roles) || isItSupervisor(roles)) && {
    path: "/reports/inconsistent_ksi_counts",
    exact: true,
    name: "Crashes with Inconsistent KSI Counts",
    component: ReportsInconsistentKSI,
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
