
--Ayush Srivastava
--Employee Chek IN and check out Calculation
--To meet the company's requirements, need to calculate the total work hours of employees in a day based on their check-in and check-out times.


IF OBJECT_ID('Input', 'U') IS NOT NULL
    DROP TABLE Input;
CREATE TABLE Input (
    EmpID INT,
    Name VARCHAR(50),
    CheckInCheckOutTime DATETIME,
    Attendance VARCHAR(3)
);


INSERT INTO Input (EmpID, Name, CheckInCheckOutTime, Attendance) VALUES
(1, 'Him', '2024-03-01 10:08', 'IN'),
(2, 'Raj', '2024-03-01 10:10', 'IN'),
(3, 'Anu', '2024-03-01 10:12', 'IN'),
(1, 'Him', '2024-03-01 11:11', 'OUT'),
(2, 'Raj', '2024-03-01 12:12', 'OUT'),
(3, 'Anu', '2024-03-01 12:35', 'OUT'),
(1, 'Him', '2024-03-01 12:08', 'IN'),
(2, 'Raj', '2024-03-01 12:25', 'IN'),
(3, 'Anu', '2024-03-01 12:40', 'IN'),
(1, 'Him', '2024-03-01 14:12', 'OUT'),
(2, 'Raj', '2024-03-01 15:12', 'OUT'),
(3, 'Anu', '2024-03-01 18:35', 'OUT'),
(1, 'Him', '2024-03-01 15:08', 'IN'),
(1, 'Him', '2024-03-01 18:08', 'OUT');


WITH CheckInOut AS (
    SELECT
        EmpID,
        Name,
        CheckInCheckOutTime,
        Attendance,
        LEAD(CheckInCheckOutTime) OVER (PARTITION BY EmpID ORDER BY CheckInCheckOutTime) AS NextCheckInCheckOutTime,
        LEAD(Attendance) OVER (PARTITION BY EmpID ORDER BY CheckInCheckOutTime) AS NextAttendance
    FROM Input
),
WorkHours AS (
    SELECT
        EmpID,
        Name,
        MIN(CheckInCheckOutTime) AS FirstCheckInTime,
        MAX(CheckInCheckOutTime) AS LastCheckOutTime,
        SUM(CASE WHEN Attendance = 'OUT' THEN 1 ELSE 0 END) AS TotalOutCount,
        SUM(CASE WHEN Attendance = 'IN' AND NextAttendance = 'OUT' THEN DATEDIFF(MINUTE, CheckInCheckOutTime, NextCheckInCheckOutTime) ELSE 0 END) AS TotalWorkMinutes
    FROM CheckInOut
    GROUP BY EmpID, Name
)
SELECT
    EmpID,
    Name,
    FirstCheckInTime,
    LastCheckOutTime,
    TotalOutCount,
    CONCAT(FLOOR(TotalWorkMinutes / 60), ':', RIGHT('0' + CAST(TotalWorkMinutes % 60 AS VARCHAR), 2)) AS TotalWorkHours
FROM WorkHours
ORDER BY EmpID;
