import argparse
import csv
import json
from collections import defaultdict

def main():
    parser = argparse.ArgumentParser(description='Compare two database schema CSV files.')
    parser.add_argument('--first-schema', type=str, required=True, help='Path to the first schema CSV file.')
    parser.add_argument('--second-schema', type=str, required=True, help='Path to the second schema CSV file.')

    args = parser.parse_args()

    first_schema = args.first_schema
    second_schema = args.second_schema

    # Read the first schema CSV file
    with open(first_schema, 'r') as f:
        reader = csv.reader(f)
        next(reader)  # Skip the header
        first_schema_data = defaultdict(list)
        for row in reader:
            first_schema_data[row[0]].append({row[1]: row[2]})

    # Read the second schema CSV file
    with open(second_schema, 'r') as f:
        reader = csv.reader(f)
        next(reader)  # Skip the header
        second_schema_data = defaultdict(list)
        for row in reader:
            second_schema_data[row[0]].append({row[1]: row[2]})

    # Compare the two schemas and produce a report
    for column_name in set(first_schema_data.keys()).union(second_schema_data.keys()):
        first_schema_records = first_schema_data[column_name]
        second_schema_records = second_schema_data[column_name]

        removed_records = [record for record in first_schema_records if record not in second_schema_records]
        added_records = [record for record in second_schema_records if record not in first_schema_records]

        print("Removed records:", removed_records)

        if removed_records or added_records:
            print(f"Changes for {column_name}:")

        if added_records:
            print("Additions:")
            for record in added_records:
                for id, description in record.items():
                    print(f"{id}: {description}")

        if removed_records:
            print("Removals:")
            for record in removed_records:
                for id, description in record.items():
                    print(f"{id}: {description}")

        if removed_records or added_records:
            print()

if __name__ == "__main__":
    main()
