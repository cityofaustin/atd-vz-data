import { isAdmin, isItSupervisor } from "./auth/authContext";

// Accept roles arg to restrict nav links by role
export const navigation = roles => {
  // Default sidebar nav items
  const nav = {
    items: [
      {
        title: true,
        name: "Data",
        wrapper: {
          // optional wrapper object
          element: "", // required valid HTML5 element tag
          attributes: {}, // optional valid JS object with JS API naming ex: { className: "my-class", style: { fontFamily: "Verdana" }, id: "my-id"}
        },
        class: "", // optional class names space delimited list for title item ex: "text-center"
      },
      {
        name: "Dashboard",
        url: "/dashboard",
        icon: "icon-speedometer",
      },
      {
        name: "Crashes",
        url: "/crashes",
        icon: "icon-shield",
      },
      {
        name: "Locations",
        url: "/locations",
        icon: "icon-map",
      },
      {
        divider: true,
      },
    ],
  };

  // Admin nav items
  const adminNavItems = [
    {
      title: true,
      name: "Admin",
    },
    {
      name: "Fatalities",
      url: "/fatalities",
      icon: "fa fa-heart-o",
    },
    {
      name: "Tools",
      url: "#",
      icon: "icon-wrench",
      children: [
        {
          name: "Upload Non-CR3",
          url: "/tools/upload_non_cr3",
          icon: "icon-cloud-upload",
        },
        {
          name: "Create Crash Record",
          url: "/tools/create_crash_record",
          icon: "icon-shield",
        },
      ],
    },
    {
      name: "Users",
      url: "/users",
      icon: "icon-people",
    },
  ];

  if (isAdmin(roles) || isItSupervisor(roles)) {
    adminNavItems.forEach(item => nav.items.splice(-1, 0, item));
  }

  return nav;
};
