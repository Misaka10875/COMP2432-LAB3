#!/bin/bash

# check 3 arguments min
if [ "$#" -lt 3 ]; then
    echo "Attendance Reporting System by Gong Tianyi"
    echo "Usage: $0 <department_files...> <special_marker> <employee_ids...>"
    echo "You can type in ||||| ./attendance_report.sh hkpolyu* employee 1002 1004 1001 ||||| for example."
    exit 1
fi

# extract arguments
dept_files=()
emp_ids=()
special_marker=""
emp_section=0

for arg in "$@"; do
    if [ "$emp_section" -eq 1 ]; then
        emp_ids+=("$arg")
    elif [[ "$arg" == *.dat ]]; then
        dept_files+=("$arg")
    elif [ "$emp_section" -eq 0 ]; then
        special_marker="$arg.dat"
        emp_section=1
        if [ "$arg" == "employee" ]; then
            special_marker="employees.dat"
        fi
    fi
done


if [ "${#dept_files[@]}" -eq 0 ] || [ "${#emp_ids[@]}" -eq 0 ] || [ -z "$special_marker" ]; then
    echo "Usage: $0 <department_files...> <special_marker> <employee_ids...>"
    exit 1
fi

# check file existence
if [ ! -f "$special_marker" ]; then
    echo "Error: File $special_marker does not exist."
    exit 1
fi

# read name
declare -A emp_names
while read -r line; do
    emp_id=$(echo "$line" | awk '{print $1}')
    emp_name=$(echo "$line" | awk '{print $2}')
    emp_names["$emp_id"]="$emp_name"
done < "$special_marker"

# generate report
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

for emp_id in "${emp_ids[@]}"; do
    generate_report "$emp_id"
done
