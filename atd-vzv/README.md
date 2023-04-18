# Vision Zero Viewer (VZV)

This project is for a public-facing interactive web app showing crash data related to Vision Zero. Users can view crash data by different categories, including transportation mode, demographic groups impacted, time of day, and location.

Crash data is sourced from TxDOT's Crash Records Information System (CRIS) database. [Vision Zero Editor](https://github.com/cityofaustin/atd-vz-data/tree/production/atd-vze) provides tools for City of Austin Transportation Department staff to enrich crash data with additional attributes, as well as correct any erroneous or missing data.

For resources and updates, see the [Vision Zero Crash Data System](https://github.com/cityofaustin/atd-data-tech/issues/255) project index.

See our Socrata open datasets for [crash](https://data.austintexas.gov/Transportation-and-Mobility/Vision-Zero-Crash-Report-Data/y2wy-tgr5/data) and [demographics](https://data.austintexas.gov/Transportation-and-Mobility/Vision-Zero-Demographic-Statistics/xecs-rpy9) data.

## Getting started

We use [Node Version Manager](https://github.com/nvm-sh/nvm) (nvm) to keep our `node` versions in sync with our environments. With `nvm` installed, run `nvm use` from this directory to activate the current `node` and `npm` version required for this project. If you don't want to use `nvm`, refer to the `.nvmrc` file for the `node` version you should install.

Install dependencies

`npm install`

Run development server

`npm start`

In development, this project uses [Prettier](https://prettier.io/) for code formatting which is set in .prettierrc. Visit link for installation or install the [extension for VSCode](https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode).
