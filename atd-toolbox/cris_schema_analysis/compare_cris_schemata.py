import csv
import argparse
from collections import defaultdict

def read_csv(file_path):
    groups = defaultdict(list)
    with open(file_path, newline='') as csvfile:
        reader = csv.reader(csvfile)
        next(reader)  # Skipping the header
        for row in reader:
            column_name, record_id, description = row
            groups[column_name].append((record_id, description))
    return groups

def compare_schemas(first_schema, second_schema):
    additions = defaultdict(list)
    removals = defaultdict(list)
    all_column_names = set(first_schema.keys()) | set(second_schema.keys())
    for column_name in all_column_names:
        first_records = set(record[0] for record in first_schema.get(column_name, []))
        second_records = set(record[0] for record in second_schema.get(column_name, []))
        for added_id in second_records - first_records:
            added_record = next((record for record in second_schema[column_name] if record[0] == added_id), None)
            if added_record:
                additions[column_name].append(added_record)
        for removed_id in first_records - second_records:
            removed_record = next((record for record in first_schema[column_name] if record[0] == removed_id), None)
            if removed_record:
                removals[column_name].append(removed_record)
    return additions, removals

def print_report(additions, removals):
    print("Report:")
    print("=======\n")
    print("Additions:")
    for column_name, records in additions.items():
        if records:
            print(f"- {column_name}:")
            for record in records:
                print(f"  ID: {record[0]}, Description: {record[1]}")
        else:
            print(f"- {column_name}: None")
    print()
    print("Removals:")
    for column_name, records in removals.items():
        if records:
            print(f"- {column_name}:")
            for record in records:
                print(f"  ID: {record[0]}, Description: {record[1]}")
        else:
            print(f"- {column_name}: None")
    print()

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--first-schema', required=True, help='Path to the first schema file')
    parser.add_argument('--second-schema', required=True, help='Path to the second schema file')
    args = parser.parse_args()

    first_schema = read_csv(args.first_schema)
    second_schema = read_csv(args.second_schema)

    additions, removals = compare_schemas(first_schema, second_schema)
    print_report(additions, removals)

if __name__ == "__main__":
    main()
