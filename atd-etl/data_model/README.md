# CRIS Import ETL

This ETL manages the processing and importing of TxDOT CRIS data into the Vision Zero database.

All data processing is managed by a single script, `cris_import.py` which processes both CSV files and CR3 PDF crash reports. The scripts supports a number of CLI arguments to handle a number of data processing scenarios.

## Quick start

1. Start your local Vision Zero cluster (database + Hasura).

2. Save a copy of the `env_template` file as `.env`, and fill in the details.

3. Build and run the docker image. This will drop you into the docker image's shell:

```shell
$ docker compose build # <- only need to do this once
$ docker compose run cris_import
```

4. Run the CRIS import script. This will download any extracts available in S3, load the CSV crash records into the database, crop crash diagrams out of the CR3 PDFs, and upload the CR3 pdfs and crash diagrams to the s3 bucket.

```shell
# from the cris_import container's shell
$ ./cris_import.py --download-s3 --upload-s3
```

## Getting started

## Environment

Create your environment by saving a copy of the `env_template` file as `.env`. The template includes default values for local development. See the password store for more details.

```
ENV=dev
HASURA_GRAPHQL_ENDPOINT="http://localhost:8084/v1/graphql"
AWS_ACCESS_KEY_ID= 
AWS_SECRET_ACCESS_KEY=
BUCKET_NAME=
EXTRACT_PASSWORD=
```

## Usage

The only script that should be run directly is `cris_import.py`. It supports the following CLI args:

```shell
  --csv              Only process CSV files
  --pdf              Only process CR3 pdfs
  --s3-download      Source zip extracts from S3 bucket
  --s3-upload        Upload cr3 pdfs and digrams to S3 bucket
  --s3-archive       If using --s3-download, move the processed extracts from ./inbox to ./archive when done
  --skip-unzip       Only process files that are already unzipped in the local directory
  --verbose, -v      Sets logging level to DEBUG mode
```
