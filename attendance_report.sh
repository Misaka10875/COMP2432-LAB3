#!/bin/bash

# Check if at least 3 arguments are provided
if [ "$#" -lt 3 ]; then
    echo "Usage: $0 <department_files...> employee <employee_ids...>"
    exit 1
fi

# Extract arguments
dept_files=()
emp_ids=()
emp_section=0

for arg in "$@"; do
    if [ "$arg" == "employee" ]; then
        emp_section=1
    elif [ "$emp_section" -eq 0 ]; then
        dept_files+=("$arg")
    else
        emp_ids+=("$arg")
    fi
done

# Check if at least one department file and one employee ID are provided
if [ "${#dept_files[@]}" -eq 0 ] || [ "${#emp_ids[@]}" -eq 0 ]; then
    echo "Usage: $0 <department_files...> employee <employee_ids...>"
    exit 1
fi

# Read employee names from employees.dat
declare -A emp_names
while read -r line; do
    emp_id=$(echo "$line" | awk '{print $1}')
    emp_name=$(echo "$line" | awk '{print $2}')
    emp_names["$emp_id"]="$emp_name"
done < employees.dat

# Function to generate attendance report for a given employee ID
generate_report() {
    emp_id=$1
    emp_name=${emp_names["$emp_id"]}
    
    echo "Attendance Report for $emp_id $emp_name"
    
    total_present=0
    total_absent=0
    total_leave=0
    
    for file in "${dept_files[@]}"; do
        if grep -q "^Department" "$file"; then
            department=$(grep "^Department" "$file" | awk '{print $2}')
            status=$(grep "^$emp_id " "$file" | tail -n1 | awk '{print $2}')
            
            if [ -z "$status" ]; then
                status="N/A"
            else
                case "$status" in
                    Present) total_present=$((total_present + 1)) ;;
                    Absent) total_absent=$((total_absent + 1)) ;;
                    Leave) total_leave=$((total_leave + 1)) ;;
                esac
                status="$status 1"
            fi
            echo "Department $department: $status"
        fi
    done
    
    echo
    echo "Total Present Days: $total_present"
    echo "Total Absent Days: $total_absent"
    echo "Total Leave Days: $total_leave"
    echo
}

# Generate reports for specified employee IDs
for emp_id in "${emp_ids[@]}"; do
    generate_report "$emp_id"
done
