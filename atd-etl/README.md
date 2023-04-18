# ATD - ETL

This is an ETL tool that automates the making of requests, downloads and processing of crash data from the C.R.I.S. website.

It utilizes Docker, Python and the [Splinter](https://splinter.readthedocs.io/en/latest/) framework running on `python:3-alpine3.8` to emulate browser behavior. It requires setting up environment variables on your system to run, please refer to the steps below to get started.

### Why using docker?

This application runs Splinter which is a wrapper for headless browsers (Firefox, Chrome, Selenium, etc). This specific application runs using headless chrome with chromedriver, and using docker we can package all the dependencies needed to run the application without many installation steps.

In short, Docker allows us to have a fully built container with everything already built, installed and ready to run. 

### Getting Started

#### 1. Download the environment variable files.

The ETL container depends on two specific files: `etl.production.env` and `etl.staging.env`.

The files are located in 1Password and you can find the two files if you type `ETL` in the search bar.
 
Once you download the files, put them a safe folder of your choice, example:

1. Create the folder, open and drag-and-drop files:

```bash
$ mkdir -p ~/.ssh/atd-etl
$ open ~/.ssh/atd-etl
```

(Optional) 2. Secure file permissions:

```bash
$ chmod 600 ~/.ssh/atd-etl/*;
$ ls -lha  ~/.ssh/atd-etl/*;
 -rw-------  1 owner  group   713B Nov 12 13:01 ~/.ssh/atd-etl/etl.production.env
 -rw-------  1 owner  group   718B Nov 10 22:05 ~/.ssh/atd-etl/etl.staging.env
```

If the file shows `-rw-------` (read-write access for you only) you did it correctly. 

The .ssh folder happens to be hidden, and it is available in most Mac/Linux machines, but feel free to put those files anywhere you think they will be safe.

#### 2. Run the image:

1. In the terminal, enter `source runetl.sh` to load the function you will need to run the ETL.
2. Run the helper like this: `runetl [CONFIG FILE] [SCRIPT FILE]`

Follow this example:

```bash
$ runetl build
$ runetl ~/.ssh/atd-etl/etl.staging.env app/process_test_run.py
$ runetl ~/.ssh/atd-etl/etl.production.env app/process_test_run.py
```

## Development

You should be able to make changes to the files (without need to re-build the container every time), just save your changes to the python file and then re-run the runetl command as needed.

#### Debugging your ETL script with Web-PDB

Web-PDB is available to your script, to use it just insert the following line into your Python program at the point where you want to start debugging:

```
# First impor the 
import web_pdb

# Then use this line as a breakpoint
web_pdb.set_trace()
``` 
The set_trace() call will suspend your program and open a web-UI at the default port 5555 (port value can be changed). Enter in your browser's address bar: http://localhost:5555, and you should see the web-UI like the one on the preceding screenshot. Now you can use all PDB commands and features. Additional Current file, Globals and Locals information boxes help you better track your program runtime state.

Subsequent set_trace() calls can be used as hardcoded breakpoints.

Web-PDB is compatible with the new breakpoint() function added in Python 3.7. Set environment variable PYTHONBREAKPOINT="web_pdb.set_trace" to launch Web-PDB with breakpoint().

For more details refer to their documentation in their repo: https://github.com/romanvm/python-web-pdb

#### Debugging Container (file system, os, python)
You can access the container's console by using the following command:

```bash
$ runetl ~/.ssh/atd-etl/etl.staging.env bash
```

The command above will output something like this:

```python
Using environment variables in '/Users/user/development/atd-vz-data/atd-etl/etl.staging.env'...

----- ETL RUN ------
Run Environment: 	staging
Run File: 		bash
ATD_CRIS_CONFIG: 	/Users/user/development/atd-vz-data/atd-etl/etl.staging.env
ATD_DOCKER_IMAGE: 	atddocker/atd-vz-etl:local
--------------------

bash-4.4#
```

## ETL Scripts

As of this moment, the ETL container should be able to run these scripts:

- `app/process_cris_cr3.py` - This script will log in to the CRIS website using the splinter python library, it will download N number of pdf files, upload such pdf files to S3, update the records through Hasura, and finally delete the PDF from the container.
- `app/process_cris_request.py` - This script will log in to the CRIS website and request a new extract.
- `app/process_cris_request_download.py` - This script will parse the email, download the ZIP file, and extract its protected contents.
- `app/process_hasura_import.py` - This script will import the already extracted CSV files and insert to the database via Hasura.
- `app/process_hasura_geocode.py` - This script will look for records in the database through Hasura that do not have a Lat/Long, it will try to find the coordinates if enough information is provided.
- `app/process_hasura_locations.py` - This script will find crashes that do not have a location assigned. If no location is found it leaves the record intact, and moves unto the next records.
- `app/process_hasura_cr3heal.py` - This script will make sure the records in Hasura that are marked to have a CR3 actually have a PDF in S3. If the file is not found in S3, then it will unmark the file.
- `app/process_socrata_export.py` - This script will export data unto the Socrata database.
- `app/process_test_run.py` - A dummy script meant to test if the environment is working, it will print two environment variables.

## GeoCoding

We are using a bounding box to limit the geocode searches to a specific area. This area can be changed within the configuration as shown in [the ETL configuration file](https://github.com/cityofaustin/atd-vz-data/blob/master/atd-etl/app/process/config.py).

![Bounding Box](https://images.zenhubusercontent.com/5b7edad7290aac725aec290c/5029f5e9-4f3c-4708-a54c-030c258d7092)

## Creating New Scripts

When creating new scripts, be sure to add some comments at the beginning of the file (as shown in any of the above files).

Make sure you run: `chmod +x app/your_new_python_script.py` before running it the first time, otherwise you might run into permissions errors.

Also make sure the "shebang" is present at the very first line: `#!/usr/bin/env python` to avoid issues. See other files for examples.

As of this 1st iteration, the documentation is not fully fleshed out. This is a living document that needs to be updated as new features are added and implemented. 
