#!/usr/bin/env python3

import argparse
import csv
from collections import defaultdict

def read_csv_into_dict(file_path):
    data_dict = defaultdict(list)
    with open(file_path, 'r') as file:
        reader = csv.reader(file)
        next(reader, None)  # Skip the header
        for row in reader:
            data_dict[row[0]].append({'id': row[1], 'description': row[2]})
    return data_dict

def main():
    parser = argparse.ArgumentParser(description="Read CSV file into a dictionary")
    parser.add_argument('-i', '--input', required=True, help='Input CSV file')
    args = parser.parse_args()

    data_dict = read_csv_into_dict(args.input)

    # Print data_dict for verification
    for key in data_dict:
        print(f'{key}: {data_dict[key]}')

if __name__ == '__main__':
    main()
