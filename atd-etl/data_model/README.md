# CRIS Import ETL

This ETL manages the processing and importing of TxDOT CRIS data into the Vision Zero database.

All data processing is managed by a single script, `cris_import.py` which processes both CSV files and CR3 PDF crash reports. The script supports a number of CLI arguments to handle a number of data processing scenarios.

## Quick start

Set your `ENV` to `dev` in order to safely run the S3 operations locally.

1. Start your local Vision Zero cluster (database + Hasura + editor).

2. Save a copy of the `env_template` file as `.env`, and fill in the details.

3. Build and run the docker image. This will drop you into the docker image's shell:

```shell
$ docker compose build # <- only need to do this once
$ docker compose run cris_import
```

4. Run the CRIS import script. This will download any extracts available in S3, load the CSV crash records into the database, crop crash diagrams out of the CR3 PDFs, and upload the CR3 pdfs and crash diagrams to the s3 bucket.

```shell
# from the cris_import container's shell
$ ./cris_import.py --s3-download --s3-upload --csv --pdf
```

## Environment

Create your environment by saving a copy of the `env_template` file as `.env`. The template includes default values for local development. See the password store for more details.

All interactions with AWS S3 occur with against a single bucket which has subdirectores for the `dev` and `prod` environments. If you set your `ENV` to `dev` you can safely run this ETL's S3 operations.

```
ENV=dev
HASURA_GRAPHQL_ENDPOINT="http://localhost:8084/v1/graphql"
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
BUCKET_NAME=
EXTRACT_PASSWORD=
```

## Usage examples

The only script that should be run directly is `cris_import.py`. It supports the following CLI args:

```shell
  --csv              Process CSV files. At least one of --csv or --pdf is required.
  --pdf              Process CR3 pdfs. At least one of --csv or --pdf is required.
  --s3-download      Source zip extracts from S3 bucket
  --s3-upload        Upload cr3 pdfs and digrams to S3 bucket
  --s3-archive       If using --s3-download, move the processed extracts from ./inbox to ./archive when done
  --skip-unzip       Only process files that are already unzipped in the local directory
  --verbose, -v      Sets logging level to DEBUG mode
  --workers <int>    The number of concurrent workers to use when processing PDFs
```

### Production run

This is the expected invocation during a production deployment. It will download any extracts available in S3, load the CSV crash records into the database, crop crash diagrams out of the CR3 PDFs, upload the CR3 pdfs and crash diagrams to the s3 bucket.

This invocation also "archives" the extract zips by moving them from `./inbox` to `./archive` subdirectory of the S3 bucket.

```shell
# from the cris_import container's shell
$ ./cris_import.py --s3-download --s3-upload --s3-archive --csv --pdf
```

### Local import

Process any extract zips in your local `./extracts` directory. CSVs will be loaded ino the db, and crash diagrams will be extracted but not uploaded to S3.

```shell
$ ./cris_import.py --csv --pdf
```

### Un-archive

During local development, you may want to restore the zips to the `./inbox` after archiving them. Use the helper script for that. It will prompt you for confirmation before executing this step, since the production bucket archive may contain hundreds of extracts.

```shell
$ python _restore_zips_from_archive.py
```

### Other flags

```shell
# process any unzipped extract CSVs you have in your `./extracts` directory
$ ./cris_import.py --skip-unzip --csv

# process pdfs with more workers and in debug mode
$ ./cris_import.py --pdf --skip-unzip --s3-upload --workers 8 --verbose
```
