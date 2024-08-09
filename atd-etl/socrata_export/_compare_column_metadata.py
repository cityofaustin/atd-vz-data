#!/usr/bin/env python
"""helper to compare socrata dataset metadata between staging and prod"""
from utils.queries import QUERIES
from utils.socrata import get_socrata_client

datasets = [
    {"name": "crashes", "staging": "3aut-fhzp", "prod": "y2wy-tgr5"},
    {"name": "people", "staging": "v3x4-fjgm", "prod": "xecs-rpy9"},
]


def compare_column_lists(source_columns, target_columns, target_dataset_name="prod"):
    """Compare lists of Socrata column metadata and print the changes that need to be
    made to the **target** columns to make the dataset match the **source** columns

    Args:
        source_columns (list): list of columns from the source dataset, usually the staging
            dataset
        target_columns (list): lst of columns from the dataset that is desired to be modified
            to look match teh source dataset, usually prod
        target_dataset_name (str, optional): the name of the dataset you are targeting,
            this is only used in the `print` statements. Defaults to 'prod'.

    Returns:
        list: of plain text "todos" that can be printed as instructions that describe
            what edits need to be made to the target dataset.
    """
    todos = []

    for col in source_columns:
        key = col["fieldName"]
        matching_col = None
        try:
            matching_col = next(
                col_to_match
                for col_to_match in target_columns
                if col_to_match["fieldName"] == key
            )
        except StopIteration:
            todo = f"- create column `{key}` type `{col['dataTypeName']}` in the {target_dataset_name} dataset"
            todos.append(todo)
            continue
        # see if the column type is the same
        a_col_type = col["dataTypeName"]
        b_col_type = matching_col["dataTypeName"]
        if a_col_type != b_col_type:
            todo = f"- change `{key}` from type `{b_col_type}` to `{a_col_type}` in the {target_dataset_name} dataset"
            todos.append(todo)

    ## identify any columns in the target that don't exist in the source
    for col in target_columns:
        key = col["fieldName"]
        matching_col = None
        try:
            matching_col = next(
                col_to_match
                for col_to_match in source_columns
                if col_to_match["fieldName"] == key
            )
        except StopIteration:
            todo = f"- delete column `{key}` from the {target_dataset_name} dataset"
            todos.append(todo)
            continue

    return todos


def main():
    socrata_client = get_socrata_client()
    for dataset in datasets:
        print(f"\n**** {dataset['name']} dataset changes ****\n")
        cols_staging = socrata_client.get_metadata(dataset["staging"])["columns"]
        cols_prod = socrata_client.get_metadata(dataset["prod"])["columns"]
        todos = compare_column_lists(cols_staging, cols_prod)
        todos.sort()
        print("\n".join(todos))


if __name__ == "__main__":
    main()
