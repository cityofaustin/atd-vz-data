# Vision Zero Editor (VZE)

This project seeks to centralize and streamline the management of ATD's Vision Zero (VZ) data. As a result of this project, staff will have a standardized interface for reviewing crash data, prioritizing intersection safety improvements, and communicating efforts to the public. Additionally, high quality VZ data will be publicly accessible online.

Data is sourced from TxDOT's Crash Records Information System (CRIS) database. An editing interface provides tools for enriching data with more attributes and correct erronous or missing data.

For resources and updates, see the [Vision Zero Crash Data System](https://github.com/cityofaustin/atd-data-tech/issues/255) project index.

## Getting started

We use [Node Version Manager](https://github.com/nvm-sh/nvm) (nvm) to keep our `node` versions in sync with our environments. With `nvm` installed, run `nvm use` from this directory to activate the current `node` and `npm` version required for this project. If you don't want to use `nvm`, refer to the `.nvmrc` file for the `node` version you should install.

Install dependencies

`npm install`

Run development server

`npm start`

In development, this project uses [Prettier](https://prettier.io/) for code formatting which is set in .prettierrc. Visit link for installation or install the [extension for VSCode](https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode).

## Adding Users

[Here are the docs](https://github.com/cityofaustin/atd-vz-data/blob/master/atd-vze/ADDING_USERS.md) for how to login for the first time and how to set up new users as an admin.

## Nearmap API Keys

For maintenance and troubleshooting of Nearmap API key for the Location aerial map (domains whitelisted, usage, etc.), contact CTM help desk.
