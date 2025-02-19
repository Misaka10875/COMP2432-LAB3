#!/bin/bash

# Parse command-line arguments to separate department files, employee file, and employee IDs
employee_marker_found=false
department_files=()
employee_file=""
employee_ids=()

for arg in "$@"; do
    if [[ "$arg" == "employee" ]]; then
        employee_marker_found=true
    elif [[ "$employee_marker_found" == false ]]; then
        department_files+=("$arg")
    else
        if [[ -z "$employee_file" ]]; then
            employee_file="$arg"
        else
            employee_ids+=("$arg")
        fi
    fi
done

# Check if "employee" marker is present, employee file is specified, and there are employee IDs
if [[ "$employee_marker_found" == false || -z "$employee_file" || "${#employee_ids[@]}" -eq 0 ]]; then
    echo "Usage: $0 department_files... employee employee_file employee_ids..." >&2
    exit 1
fi

# Check if the employee file exists
if [[ ! -f "$employee_file" ]]; then
    echo "Error: Employee file $employee_file not found." >&2
    exit 1
fi

# Read employee names from the specified employee file into an associative array
declare -A employee_names
while IFS= read -r line; do
    arr=($line)
    for ((i=0; i<${#arr[@]}; i+=2)); do
        emp_id="${arr[i]}"
        emp_name="${arr[i+1]}"
        employee_names["$emp_id"]="$emp_name"
    done
done < "$employee_file"

# Process department files to collect the latest attendance data
declare -A department_dates  # Key: department name, Value: "year month"
declare -A employee_status   # Key: "department:emp_id", Value: status
declare -a departments_order # Maintain the order of departments as first encountered
declare -A added_departments # Track departments added to departments_order

for dept_file in "${department_files[@]}"; do
    if [[ ! -f "$dept_file" ]]; then
        echo "Warning: Department file $dept_file not found. Skipping." >&2
        continue
    fi

    # Read the header line to extract department name, month, and year
    header_line=$(head -n 1 "$dept_file")
    arr=($header_line)
    if [[ "${arr[0]}" != "Department" ]]; then
        echo "Warning: Invalid department file $dept_file. Skipping." >&2
        continue
    fi

    dept_name="${arr[1]}"
    month_str="${arr[2]}"
    year="${arr[3]}"

    # Convert month string to numeric value (e.g., January -> 1)
    month=$(date -d "${month_str} 1 $year" +%m | sed 's/^0//')

    current_dept_date="$year $month"

    # Track department order (first occurrence)
    if [[ -z "${added_departments[$dept_name]}" ]]; then
        departments_order+=("$dept_name")
        added_departments["$dept_name"]=1
    fi

    # Check if current file's date is the latest for the department
    if [[ -z "${department_dates[$dept_name]}" || "$current_dept_date" > "${department_dates[$dept_name]}" ]]; then
        # Remove all existing entries for this department if the date is newer
        for key in "${!employee_status[@]}"; do
            if [[ "$key" == "$dept_name:"* ]]; then
                unset employee_status["$key"]
            fi
        done
        department_dates["$dept_name"]="$current_dept_date"
    fi

    # If the current file's date is not the latest, skip processing its entries
    if [[ "${department_dates[$dept_name]}" != "$current_dept_date" ]]; then
        continue
    fi

    # Process each entry in the department file (skip header)
    tail -n +2 "$dept_file" | while read -r line; do
        entries=($line)
        for ((i=0; i<${#entries[@]}; i+=2)); do
            emp_id="${entries[i]}"
            status="${entries[i+1]}"
            key="$dept_name:$emp_id"
            employee_status["$key"]="$status"
        done
    done
done

# Generate attendance reports for each specified employee
for emp_id in "${employee_ids[@]}"; do
    emp_name="${employee_names[$emp_id]}"
    if [[ -z "$emp_name" ]]; then
        echo "Error: Employee ID $emp_id not found in $employee_file." >&2
        continue
    fi

    echo "Attendance Report for $emp_id $emp_name"

    total_present=0
    total_absent=0
    total_leave=0

    # Check each department in the order they were first encountered
    for dept in "${departments_order[@]}"; do
        key="$dept:$emp_id"
        status="${employee_status[$key]}"
        if [[ -z "$status" ]]; then
            echo "Department $dept: N/A"
        else
            echo "Department $dept: $status 1"
            case "$status" in
                "Present") ((total_present++));;
                "Absent") ((total_absent++));;
                "Leave") ((total_leave++));;
            esac
        fi
    done

    echo ""
    echo "Total Present Days: $total_present"
    echo "Total Absent Days: $total_absent"
    echo "Total Leave Days: $total_leave"
    echo ""
done
