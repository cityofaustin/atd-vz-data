# Open Data Portal (Socrata) Export

This ETL downloads crash and people records from the VZ database and publishes them to the Open Data Portal, formerly known as Socrata.

Records are pushed to two datasets, a crash-level dataset and a person-level dataset:

| name    | dataset staging                                                                                                                         | dataset prod                                                                                                                                    |
| ------- | --------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| crashes | [`3aut-fhzp`](https://datahub.austintexas.gov/Transportation-and-Mobility/Test-Crash-Report-Data/3aut-fhzp/about_data)                  | [`y2wy-tgr5`](https://datahub.austintexas.gov/Transportation-and-Mobility/Austin-Crash-Report-Data-Crash-Level-Records/y2wy-tgr5/about_data)    |
| people  | [`v3x4-fjgm`](https://datahub.austintexas.gov/Transportation-and-Mobility/Test-Austin-Crash-Demographic-Statistics-incomplet/v3x4-fjgm) | [`xecs-rpy9`](https://data.austintexas.gov/Transportation-and-Mobility/Austin-Crash-Report-Data-Crash-Victim-Demographic-/xecs-rpy9/about_data) |

## Quick start

1. Save a copy of the `env_template` file as `.env`, and fill in the details.

2. Build and run the docker image. This will drop you into the docker image's shell:

```shell
$ docker compose run socrata_export
```

3. Run the export import script. This will download and publish crashes records, then people records.

```shell
# from the socrata_export container's shell
$ ./socrata_export.py --crashes --people
```

## CLI

The CLI args `--crashes` and `--people` control which dataset(s) will be processed. At least one must be specified.

```shell
$ ./socrata_export.py --people
```

## Column metadata helper

The script `_compare_column_metadata.py` can be used to compare the column definitions between two Open Data Portal datasets. It can be useful when you need to replicate changes between the staging and production datasets:

```shell
$ _compare_column_metadata.py
```
