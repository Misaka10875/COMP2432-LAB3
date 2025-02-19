# Attendance Reporting System by Gong Tianyi

This the attendance reporting system by Gong Tianyi, for the Lab3 of COMP2432. The following examples are based on this project's files. If you are testing with some other .dat files that are not given on BlackBoard, please ignore the output given below.

## Example

Use these inputs to test the program:

```
 ./attendance_report.sh hkpolyu* employee 1002 1004 1001
```

This is for searching all files starting with "hkpolyu", employee id={1002,1004,1001}  
Output should be this: (forget the Department COMP, that's for testing)

```
Attendance Report for 1002 Bob
Department COMP: N/A
Department HR: N/A
Department Sales: Present 1

Total Present Days: 1
Total Absent Days: 0
Total Leave Days: 0

Attendance Report for 1004 David
Department COMP: N/A
Department HR: N/A
Department Sales: N/A

Total Present Days: 0
Total Absent Days: 0
Total Leave Days: 0

Attendance Report for 1001 Alice
Department COMP: N/A
Department HR: Present 1
Department Sales: Present 1

Total Present Days: 2
Total Absent Days: 0
Total Leave Days: 0
```

### Example 2:

```
 ./attendance_report.sh hkpolyuHR_January2024.dat employee 1002 1004 1001
```

Expected output:

```
Attendance Report for 1002 Bob
Department HR: N/A

Total Present Days: 0
Total Absent Days: 0
Total Leave Days: 0

Attendance Report for 1004 David
Department HR: N/A

Total Present Days: 0
Total Absent Days: 0
Total Leave Days: 0

Attendance Report for 1001 Alice
Department HR: Present 1

Total Present Days: 1
Total Absent Days: 0
Total Leave Days: 0
```

### Example 3:

```
./attendance_report.sh hkpolyuHR_January2024.dat student 1225 1226
```

Here, we use "student" instead of "employee". The expected output should be:

```
Attendance Report for 1225 stuart
Department HR: N/A

Total Present Days: 0
Total Absent Days: 0
Total Leave Days: 0

Attendance Report for 1226 otto
Department HR: N/A

Total Present Days: 0
Total Absent Days: 0
Total Leave Days: 0
```

### Example 4:

```
./attendance_report.sh hkpolyu* student 1225 1226
```

Expected output:

```
Attendance Report for 1225 stuart
Department COMP: Present 1
Department HR: N/A
Department Sales: N/A

Total Present Days: 1
Total Absent Days: 0
Total Leave Days: 0

Attendance Report for 1226 otto
Department COMP: N/A
Department HR: N/A
Department Sales: N/A

Total Present Days: 0
Total Absent Days: 0
Total Leave Days: 0
```

### Example 5:

If you try to reach any file that doesn't exist in the directory, the program would give a warning:  
Input:

```
./attendance_report.sh hkpolyu* car 1225 1226
```

Since we don't have car.dat, the output will become:

```
Error: File car.dat does not exist.
```
