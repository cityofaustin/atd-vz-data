# Vision Zero Crash Data System

This repository is home base for a suite of applications that help centralize and streamline the management of ATD's Vision Zero data. As a result of this project, staff will have a standardized interface for reviewing crash data, prioritizing intersection safety improvements, and communicating efforts to the public. Additionally, high quality VZ data will be publicly accessible online.

## atd-cr3-api

This folder hosts our API that securely downloads a private file from S3. It is written in Python & Flask. and it is deployed in a Lambda function with Zappa.

[more info](./atd-cr3-api/README.md)

## atd-etl (Extract-Transform-Load)

Our current method for extracting data from the TxDOT C.R.I.S. data system uses a python library called [Splinter](https://splinter.readthedocs.io/en/latest/) to request, download and process data. It is deployed as a Docker container.

For step-by-step details on how to prepare your environment and how to execute this process, please refer to the documentation in the [atd-etl folder.](https://github.com/cityofaustin/atd-vz-data/tree/master/atd-etl)

[more info](./atd-etl/README.md)

## atd-vzd (Vision Zero Database)

VZD is our name for our Hasura GraphQL API server that connects to our Postgres RDS database instances.

[more info](./atd-vzd/README.md)

Production site: http://vzd.austinmobility.io/
Staging site: https://vzd-staging.austinmobility.io/

## atd-vze (Vision Zero Editor)

VZE is our front end application built in React.js with CoreUI that allows a trusted group of internal users to edit and improve the data quality of our Vision Zero data. It consumes data from Hasura/VZD.

[more info](./atd-vze/README.md)

Production site: https://visionzero.austin.gov/editor/
Staging site: https://visionzero-staging.austinmobility.io/editor/

## atd-vzv (Vision Zero Viewer)

VZV is our public facing home for visualizations, maps, and dashboards that help make sense and aggregate trends in our Vision Zero Database

[more info](./atd-vzv/README.md)

Production site: https://visionzero.austin.gov/viewer/
Staging site: https://visionzero-staging.austinmobility.io/viewer/

## atd-toolbox

Collection of utilities related to maintaining data and other resources related to the Vision Zero Data projects.

## Local Development
The suite has a python script which can be used to run and populate a local development instance of the stack. The script is found in the root of the repository, and is named `vision-zero`. It's recommended to create a virtual environment in the root of the repo, and if you name it `venv`, it will be ignored by the `.gitignore` file in place. VS Code will automatically source the activation script, if you start a terminal from within it to interface with the stack.

The `vision-zero` program is a light wrapper around the functionality provided by `docker compose`. By inspecting the `docker-compose.yml` file, you can find the definitions of the services in the stack, and you can use the `docker compose` command to turn up, stop, and attach terminals to the running containers and execute on-off commands. This can provide you access to containers to install nodejs libraries, use postgres' supporting programs (`psql`, `pg_dump`) and other lower level utilities.

Ideally, you should be able to operate the entire vision zero suite and access all needed supporting tooling from any host that can provide a working docker service & python interpreter for the orchestration script.

### `vision-zero` command auto-completion

The `vision-zero` application is able to generate auto-completion scripts via the `shtab` python library. For example, `zsh` users may use the following to enable this feature. `bash` and `csh` users will have similar steps to follow particular to their shell of choice. 

```
mkdir ~/.zsh_completion_functions;
chmod g-w,o-w ~/.zsh_completion_functions;
cd $WHEREVER_YOU_HAVE_VZ_CHECKED_OUT;
source ./venv/bin/active;
./vision-zero -s zsh | tee ~/.zsh_completion_functions/_vision-zero
```

### Examples of `vision-zero` commands

Note: There is a flag which ends up being observed for any of the following commands which start the postgres database:

`-r / --ram-disk` will cause the database to back its "storage" on a RAM disk instead of non-volatile storage. This has the upside of being much faster as there is essentially no limit to the IOPS available to the database, but the data won't be able to survive a restart and will require being `replicate-db`'d back into place. 

The default is to use the disk in the host to back the database, which is the operation our team is most familiar with, so if you don't need or want the RAM disk configuration, you can ignore this option. 


#### `vision-zero build`
Rebuild the stack's images based on the Dockerfiles found in the repository. They are built with the `--no-cache` flag which will make the build process slower, but avoid any stale image layers that have inadvertently cached out-of-date apt resource lists. 

#### `vision-zero db-up` & `vision-zero db-down`
Start and stop the postgres database

#### `vision-zero graphql-engine-up` & `vision-zero graphql-engine-down`
Start and stop the Hasura graphql-engine software

#### `vision-zero vze-up` & `vision-zero vze-down`
Start and stop the Vision Zero Editor

#### `vision-zero vzv-up` & `vision-zero vzv-down`
Start and stop the Vision Zero Viewer

#### `vision-zero psql`
Start a `psql` postgreSQL client connected to your local database

#### `vision-zero tools-shell`
Start a `bash` shell on a machine with supporting tooling

#### `vision-zero stop`
Stop the stack

#### `vision-zero replicate-db`
* Download a snapshot of the production database
* Store the file in `./atd-vzd/snapshots/visionzero-{date}-{with|without}-change-log.sql
* Drop local `atd_vz_data` database
* Create and repopulate the database from the snapshot

Note: the `-c / --include-change-log-data` flag can be used to opt to include the data of past change log events. The schema is created either way.
Note: the `-f / --filename` flag can be optionally used to point to a specific data dump .sql file to use to restore.

The way the snapshots are dated means that one will only end up downloading
one copy of the data per-day, both in the with and without change log data.

#### `vision-zero dump-local-db`
* pg_dump the current local database
* Stores the file in `./atd-vzd/dumps/visionzero-{date}-{time}.sql

#### `vision-zero remove-snapshots`
Remove snapshot files. This can be done to save space and clean up old snapshots, but it's also useful to cause a new copy of the day's data to be downloaded if an upstream change is made. 

## Technology Stack

Technologies, libraries, and languages used for this project include:

- Docker
- Hasura
- PostgreSQL
- React (Javascript)
- Core UI (HTML & CSS)
- Python

## License

As a work of the City of Austin, this project is in the public domain within the United States.

Additionally, we waive copyright and related rights of the work worldwide through the [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).
