from openpyxl import load_workbook
import re

def read_xlsx(file_path):
    # Load the workbook
    workbook = load_workbook(filename=file_path)

    for worksheet in workbook.worksheets:
        pass
        if worksheet.title.lower() == "crash file specification":
            print("Title: ", worksheet.title.lower())

            for row in worksheet.iter_rows(values_only=True, min_row=9):
                if 'lookup' in str(row[10]).lower():
                    print("")
                    match = re.search(r"#'(\w+)_LKP'", row[9])
                    lookup_table = match.group(1).lower() if match else None
                    field = (str(row[7]).split('.')[1].lower())
                    table = str(row[10]).lower()

                    print(f"Lookup Table: '{lookup_table}'")
                    print(f"Field: '{field}'")

    for worksheet in workbook.worksheets:
        pass
        if worksheet.title.lower() == "unit file specification":
            print("Title: ", worksheet.title.lower())

            for row in worksheet.iter_rows(values_only=True, min_row=9):
                if 'lookup' in str(row[10]).lower():
                    print("")
                    match = re.search(r"#'(\w+)_LKP'", row[9])
                    lookup_table = match.group(1).lower() if match else None
                    field = (str(row[7]).split('.')[1].lower())
                    table = str(row[10]).lower()

                    print(f"Lookup Table: '{lookup_table}'")
                    print(f"Field: '{field}'")


    for worksheet in workbook.worksheets:
        pass
        if worksheet.title.lower() == "person file specification":
            print("Title: ", worksheet.title.lower())

            for row in worksheet.iter_rows(values_only=True, min_row=9):
                if 'lookup' in str(row[10]).lower():
                    print("")
                    match = re.search(r"#'(\w+)_LKP'", row[9])
                    lookup_table = match.group(1).lower() if match else None
                    field = (str(row[7]).split('.')[1].lower())
                    table = str(row[10]).lower()

                    print(f"Lookup Table: '{lookup_table}'")
                    print(f"Field: '{field}'")



def main():
    read_xlsx("/data/cris_spec.xlsx")

if __name__ == "__main__":
    main()