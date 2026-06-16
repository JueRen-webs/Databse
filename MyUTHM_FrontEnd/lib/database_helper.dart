import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

import 'home/timetable_page.dart';
import 'home/daily_timetable_widget.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static String currentUserId = '';
  static String currentUserRole = '';
  static String currentUserName = '';
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('MyUTHM.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    final exists = await databaseExists(path);

    if (!exists) {
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      ByteData data = await rootBundle.load(join('assets', filePath));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      await File(path).writeAsBytes(bytes, flush: true);
    }

    return await openDatabase(path);
  }

  Future<Map<String, dynamic>?> loginWithExistingAccount(
      String userId, String password) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> results = await db.query(
      'Users',
      where: 'User_ID = ? AND Password_Hash = ?',
      whereArgs: [userId, password],
    );

    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<Map<String, dynamic>?> getStudentProfile(String userId) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT
        u.User_ID,
        u.Name,
        u.Email,
        u.Phone,
        u.Role,
        COALESCE(s.Obtained_Credits, 0) AS Obtained_Credits,
        COALESCE(s.CGPA, 0.00) AS CGPA,
        COALESCE(s.CCPA, 0.00) AS CCPA,
        p.Programme_Name,
        p.Faculty_ID
      FROM Users u
      LEFT JOIN Students s ON u.User_ID = s.Student_ID
      LEFT JOIN Programmes p ON s.Programme_ID = p.Programme_ID
      WHERE u.User_ID = ?
    ''', [userId]);

    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<Map<String, dynamic>?> getLecturerProfile({
    String? lecturerId,
    String? sectionId,
  }) async {
    final db = await instance.database;
    String? resolvedLecturerId = lecturerId;

    if ((resolvedLecturerId == null || resolvedLecturerId.isEmpty) &&
        sectionId != null &&
        sectionId.isNotEmpty) {
      final sectionRows = await db.rawQuery(
        'SELECT Lecturer_ID FROM Sections WHERE Section_ID = ? LIMIT 1',
        [int.tryParse(sectionId) ?? sectionId],
      );
      if (sectionRows.isNotEmpty) {
        resolvedLecturerId = sectionRows.first['Lecturer_ID']?.toString();
      }
    }

    resolvedLecturerId ??= currentUserId;
    if (resolvedLecturerId.isEmpty) return null;

    final lecturerTableRows = await db.rawQuery('''
      SELECT name
      FROM sqlite_master
      WHERE type = 'table' AND name = 'Lecturers'
      LIMIT 1
    ''');
    final hasLecturersTable = lecturerTableRows.isNotEmpty;

    var lecturerFacultySelect = "'-' AS Faculty_ID";
    if (hasLecturersTable) {
      final lecturerColumns = await db.rawQuery('PRAGMA table_info(Lecturers)');
      final lecturerColumnNames = lecturerColumns
          .map((column) => column['name']?.toString().toLowerCase())
          .whereType<String>()
          .toSet();
      if (lecturerColumnNames.contains('faculty_id')) {
        lecturerFacultySelect = 'l.Faculty_ID AS Faculty_ID';
      } else if (lecturerColumnNames.contains('department_id')) {
        lecturerFacultySelect = 'l.Department_ID AS Faculty_ID';
      }
    }

    final rows = await db.rawQuery(
      hasLecturersTable
          ? '''
              SELECT
                u.User_ID,
                u.Name,
                u.Email,
                u.Phone,
                u.Role,
                $lecturerFacultySelect
              FROM Users u
              LEFT JOIN Lecturers l ON l.Lecturer_ID = u.User_ID
              WHERE UPPER(u.User_ID) = UPPER(?)
              LIMIT 1
            '''
          : '''
              SELECT
                u.User_ID,
                u.Name,
                u.Email,
                u.Phone,
                u.Role,
                '-' AS Faculty_ID
              FROM Users u
              WHERE UPPER(u.User_ID) = UPPER(?)
              LIMIT 1
            ''',
      [resolvedLecturerId],
    );

    if (rows.isEmpty) {
      return {
        'User_ID': resolvedLecturerId,
        'Name': '-',
        'Email': '-',
        'Phone': '-',
        'Role': 'Lecturer',
        'Faculty_ID': '-',
      };
    }

    final data = Map<String, dynamic>.from(rows.first);
    for (final key in [
      'User_ID',
      'Name',
      'Email',
      'Phone',
      'Role',
      'Faculty_ID',
    ]) {
      final value = data[key]?.toString().trim();
      data[key] = value == null || value.isEmpty ? '-' : value;
    }
    return data;
  }

  Future<Map<String, dynamic>?> _latestStudentSemester(
    dynamic db,
    String studentId,
  ) async {
    final rows = await db.rawQuery('''
      SELECT s.Academic_Session, s.Semester
      FROM Courses_Enrollments ce
      JOIN Sections s ON s.Section_ID = ce.Section_ID
      WHERE ce.Student_ID = ?
      ORDER BY s.Academic_Session DESC, s.Semester DESC
      LIMIT 1
    ''', [studentId]);
    if (rows.isNotEmpty) return rows.first;

    final fallback = await db.rawQuery('''
      SELECT Academic_Session, Semester
      FROM Sections
      ORDER BY Academic_Session DESC, Semester DESC
      LIMIT 1
    ''');
    return fallback.isEmpty ? null : fallback.first;
  }

  Future<List<Map<String, dynamic>>> getCurrentRegisteredCourses(
    String studentId,
  ) async {
    final db = await instance.database;
    final semester = await _latestStudentSemester(db, studentId);
    if (semester == null) return [];

    return await db.rawQuery('''
      SELECT ce.Course_Enrollment_ID,
             ce.Student_ID,
             s.Section_ID,
             s.Section_Code,
             s.Academic_Session,
             s.Semester,
             c.Course_ID,
             c.Course_Name,
             c.Course_Credits
      FROM Courses_Enrollments ce
      JOIN Sections s ON s.Section_ID = ce.Section_ID
      JOIN Courses c ON c.Course_ID = s.Course_ID
      WHERE ce.Student_ID = ?
        AND s.Academic_Session = ?
        AND s.Semester = ?
      ORDER BY c.Course_ID ASC, s.Section_Code ASC
    ''', [
      studentId,
      semester['Academic_Session'],
      semester['Semester'],
    ]);
  }

  Future<List<Map<String, dynamic>>> searchCourseSectionsForRegistration({
    required String studentId,
    required String query,
  }) async {
    final db = await instance.database;
    final semester = await _latestStudentSemester(db, studentId);
    if (semester == null || query.trim().isEmpty) return [];
    final like = '%${query.trim()}%';

    return await db.rawQuery('''
      SELECT s.Section_ID,
             s.Section_Code,
             s.Academic_Session,
             s.Semester,
             c.Course_ID,
             c.Course_Name,
             c.Course_Credits,
             COALESCE(u.Name, '-') AS Lecturer_Name,
             COALESCE(en.Enrolled_Count, 0) AS Enrolled_Count,
             CASE WHEN mine.Course_Enrollment_ID IS NULL THEN 0 ELSE 1 END AS Is_Enrolled,
             COALESCE(sc.Schedule_Text, '-') AS Schedule_Text
      FROM Sections s
      JOIN Courses c ON c.Course_ID = s.Course_ID
      LEFT JOIN Users u ON u.User_ID = s.Lecturer_ID
      LEFT JOIN (
        SELECT Section_ID, COUNT(*) AS Enrolled_Count
        FROM Courses_Enrollments
        GROUP BY Section_ID
      ) en ON en.Section_ID = s.Section_ID
      LEFT JOIN Courses_Enrollments mine
        ON mine.Section_ID = s.Section_ID AND mine.Student_ID = ?
      LEFT JOIN (
        SELECT Section_ID,
               GROUP_CONCAT(Class_Type || ' ' || Day_Of_Week || ' ' ||
                            Start_Time || '-' || End_Time, ', ') AS Schedule_Text
        FROM Section_Schedules
        GROUP BY Section_ID
      ) sc ON sc.Section_ID = s.Section_ID
      WHERE s.Academic_Session = ?
        AND s.Semester = ?
        AND (c.Course_ID LIKE ? OR c.Course_Name LIKE ?)
      ORDER BY c.Course_ID ASC, s.Section_Code ASC
      LIMIT 50
    ''', [
      studentId,
      semester['Academic_Session'],
      semester['Semester'],
      like,
      like,
    ]);
  }

  Future<int> enrollStudentInSection({
    required String studentId,
    required String sectionId,
  }) async {
    final db = await instance.database;
    final existing = await db.rawQuery('''
      SELECT Course_Enrollment_ID
      FROM Courses_Enrollments
      WHERE Student_ID = ? AND Section_ID = ?
      LIMIT 1
    ''', [studentId, int.tryParse(sectionId) ?? sectionId]);
    if (existing.isNotEmpty) {
      return int.tryParse(existing.first['Course_Enrollment_ID'].toString()) ??
          0;
    }

    return await db.rawInsert('''
      INSERT INTO Courses_Enrollments (Student_ID, Section_ID)
      VALUES (?, ?)
    ''', [studentId, int.tryParse(sectionId) ?? sectionId]);
  }

  Future<int> deleteStudentCourseEnrollment({
    required String studentId,
    required String enrollmentId,
  }) async {
    final db = await instance.database;
    return await db.transaction<int>((txn) async {
      await txn.rawDelete(
        'DELETE FROM Results WHERE Course_Enrollment_ID = ?',
        [int.tryParse(enrollmentId) ?? enrollmentId],
      );
      return await txn.rawDelete('''
        DELETE FROM Courses_Enrollments
        WHERE Student_ID = ? AND Course_Enrollment_ID = ?
      ''', [studentId, int.tryParse(enrollmentId) ?? enrollmentId]);
    });
  }

  Future<void> ensureLecturerStaffTables() async {
    final db = await instance.database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Lecturer_Attendances (
        Attendance_ID INTEGER PRIMARY KEY AUTOINCREMENT,
        Lecturer_ID TEXT NOT NULL,
        Attendance_Date date NOT NULL,
        In_Time time,
        Out_Time time,
        Details TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Leave_Types (
        Leave_Type_ID INTEGER PRIMARY KEY AUTOINCREMENT,
        Leave_Name TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Leaves_Records (
        Record_ID INTEGER PRIMARY KEY AUTOINCREMENT,
        Lecturer_ID TEXT NOT NULL,
        Leave_Type_ID INTEGER NOT NULL,
        Available_Leave INTEGER,
        Leave_Taken INTEGER,
        Start_Date date NOT NULL,
        End_Date date NOT NULL,
        Note TEXT,
        Status TEXT DEFAULT 'Approved'
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Movements (
        Movement_ID INTEGER PRIMARY KEY AUTOINCREMENT,
        Lecturer_ID TEXT NOT NULL,
        Start_Date date NOT NULL,
        End_Date date NOT NULL,
        Location TEXT,
        Purpose TEXT,
        Status TEXT DEFAULT 'Approved'
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Clinic_Type (
        Type_ID INTEGER PRIMARY KEY AUTOINCREMENT,
        Type_Name VARCHAR(50) NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Clinic_List (
        Clinic_ID INTEGER PRIMARY KEY AUTOINCREMENT,
        Clinic_Name VARCHAR(100) NOT NULL,
        Clinic_Address TEXT,
        Clinic_Phone VARCHAR(20),
        Type_ID INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Medical_Records (
        Record_ID TEXT PRIMARY KEY,
        Lecturer_ID TEXT,
        Clinic_ID TEXT,
        Date TEXT,
        Charges REAL
      )
    ''');
    await db.rawInsert('''
      INSERT INTO Leave_Types (Leave_Type_ID, Leave_Name)
      SELECT 1, 'Annual Leave'
      WHERE NOT EXISTS (SELECT 1 FROM Leave_Types WHERE Leave_Type_ID = 1)
    ''');
    await db.rawInsert('''
      INSERT INTO Leave_Types (Leave_Type_ID, Leave_Name)
      SELECT 2, 'Medical Leave'
      WHERE NOT EXISTS (SELECT 1 FROM Leave_Types WHERE Leave_Type_ID = 2)
    ''');
    await db.rawInsert('''
      INSERT INTO Leave_Types (Leave_Type_ID, Leave_Name)
      SELECT 3, 'Emergency Leave'
      WHERE NOT EXISTS (SELECT 1 FROM Leave_Types WHERE Leave_Type_ID = 3)
    ''');
    await db.rawInsert('''
      INSERT INTO Clinic_Type (Type_ID, Type_Name)
      SELECT 1, 'Clinic'
      WHERE NOT EXISTS (SELECT 1 FROM Clinic_Type WHERE Type_ID = 1)
    ''');
    await db.rawInsert('''
      INSERT INTO Clinic_Type (Type_ID, Type_Name)
      SELECT 2, 'Dental'
      WHERE NOT EXISTS (SELECT 1 FROM Clinic_Type WHERE Type_ID = 2)
    ''');
  }

  Future<List<Map<String, dynamic>>> getLecturerAttendanceRecords(
    String lecturerId,
  ) async {
    final db = await instance.database;
    await ensureLecturerStaffTables();
    return db.rawQuery('''
      SELECT *
      FROM Lecturer_Attendances
      WHERE Lecturer_ID = ?
      ORDER BY date(Attendance_Date) DESC
    ''', [lecturerId]);
  }

  Future<int> lecturerCheckInOut(String lecturerId) async {
    final db = await instance.database;
    await ensureLecturerStaffTables();
    final now = DateTime.now();
    final date = DateFormat('yyyy-MM-dd').format(now);
    final time = DateFormat('HH:mm').format(now);
    final rows = await db.rawQuery('''
      SELECT * FROM Lecturer_Attendances
      WHERE Lecturer_ID = ? AND Attendance_Date = ?
      LIMIT 1
    ''', [lecturerId, date]);
    if (rows.isEmpty) {
      final details = now.hour < 8 || (now.hour == 8 && now.minute == 0)
          ? 'ontime'
          : 'late';
      return db.rawInsert('''
        INSERT INTO Lecturer_Attendances
          (Lecturer_ID, Attendance_Date, In_Time, Details)
        VALUES (?, ?, ?, ?)
      ''', [lecturerId, date, time, details]);
    }
    return db.rawUpdate('''
      UPDATE Lecturer_Attendances
      SET Out_Time = ?
      WHERE Attendance_ID = ?
    ''', [time, rows.first['Attendance_ID']]);
  }

  Future<Map<String, dynamic>> getLecturerAttendanceOverview(
    String lecturerId,
  ) async {
    final db = await instance.database;
    await ensureLecturerStaffTables();
    final records = await getLecturerAttendanceRecords(lecturerId);
    final year = DateTime.now().year;
    final month = DateTime.now().month;
    final first = DateTime(year, month, 1);
    final today = DateTime.now();
    int worked = 0;
    int late = 0;
    int absent = 0;

    for (var day = first;
        !day.isAfter(today);
        day = day.add(const Duration(days: 1))) {
      if (day.weekday > DateTime.friday) continue;
      final date = DateFormat('yyyy-MM-dd').format(day);
      final hasAttendance =
          records.any((row) => row['Attendance_Date']?.toString() == date);
      final leaveRows = await db.rawQuery('''
        SELECT 1 FROM Leaves_Records
        WHERE Lecturer_ID = ?
          AND date(?) BETWEEN date(Start_Date) AND date(End_Date)
        LIMIT 1
      ''', [lecturerId, date]);
      final movementRows = await db.rawQuery('''
        SELECT 1 FROM Movements
        WHERE Lecturer_ID = ?
          AND date(?) BETWEEN date(Start_Date) AND date(End_Date)
        LIMIT 1
      ''', [lecturerId, date]);
      if (hasAttendance) {
        worked++;
        final row = records.firstWhere(
          (item) => item['Attendance_Date']?.toString() == date,
        );
        if (row['Details']?.toString().toLowerCase() == 'late') late++;
      } else if (leaveRows.isEmpty && movementRows.isEmpty) {
        absent++;
      }
    }
    return {'worked': worked, 'late': late, 'absent': absent};
  }

  Future<List<Map<String, dynamic>>> getLeaveTypes() async {
    final db = await instance.database;
    await ensureLecturerStaffTables();
    return db.rawQuery('SELECT * FROM Leave_Types ORDER BY Leave_Type_ID');
  }

  Future<List<Map<String, dynamic>>> getLecturerLeaves(
      String lecturerId) async {
    final db = await instance.database;
    await ensureLecturerStaffTables();
    return db.rawQuery('''
      SELECT lr.*, lt.Leave_Name
      FROM Leaves_Records lr
      LEFT JOIN Leave_Types lt ON lt.Leave_Type_ID = lr.Leave_Type_ID
      WHERE lr.Lecturer_ID = ?
      ORDER BY date(lr.Start_Date) DESC
    ''', [lecturerId]);
  }

  int _inclusiveDays(String start, String end) {
    final a = DateTime.tryParse(start);
    final b = DateTime.tryParse(end);
    if (a == null || b == null) return 1;
    return b.difference(a).inDays.abs() + 1;
  }

  Future<int> saveLecturerLeave({
    String? recordId,
    required String lecturerId,
    required int leaveTypeId,
    required String startDate,
    required String endDate,
    required String note,
    String status = 'Approved',
  }) async {
    final db = await instance.database;
    await ensureLecturerStaffTables();
    final taken = _inclusiveDays(startDate, endDate);
    if (recordId == null) {
      return db.rawInsert('''
        INSERT INTO Leaves_Records
          (Lecturer_ID, Leave_Type_ID, Available_Leave, Leave_Taken,
           Start_Date, End_Date, Note, Status)
        VALUES (?, ?, 31, ?, ?, ?, ?, ?)
      ''', [lecturerId, leaveTypeId, taken, startDate, endDate, note, status]);
    }
    return db.rawUpdate('''
      UPDATE Leaves_Records
      SET Leave_Type_ID = ?, Leave_Taken = ?, Start_Date = ?, End_Date = ?,
          Note = ?, Status = ?
      WHERE Record_ID = ? AND Lecturer_ID = ?
    ''', [
      leaveTypeId,
      taken,
      startDate,
      endDate,
      note,
      status,
      int.tryParse(recordId) ?? recordId,
      lecturerId,
    ]);
  }

  Future<int> deleteLecturerLeave(String lecturerId, String recordId) async {
    final db = await instance.database;
    await ensureLecturerStaffTables();
    return db.rawDelete(
      'DELETE FROM Leaves_Records WHERE Lecturer_ID = ? AND Record_ID = ?',
      [lecturerId, int.tryParse(recordId) ?? recordId],
    );
  }

  Future<List<Map<String, dynamic>>> getLecturerMovements(
    String lecturerId,
  ) async {
    final db = await instance.database;
    await ensureLecturerStaffTables();
    return db.rawQuery('''
      SELECT *
      FROM Movements
      WHERE Lecturer_ID = ?
      ORDER BY date(Start_Date) DESC
    ''', [lecturerId]);
  }

  Future<int> saveLecturerMovement({
    String? movementId,
    required String lecturerId,
    required String startDate,
    required String endDate,
    required String location,
    required String purpose,
    String status = 'Approved',
  }) async {
    final db = await instance.database;
    await ensureLecturerStaffTables();
    if (movementId == null) {
      return db.rawInsert('''
        INSERT INTO Movements
          (Lecturer_ID, Start_Date, End_Date, Location, Purpose, Status)
        VALUES (?, ?, ?, ?, ?, ?)
      ''', [lecturerId, startDate, endDate, location, purpose, status]);
    }
    return db.rawUpdate('''
      UPDATE Movements
      SET Start_Date = ?, End_Date = ?, Location = ?, Purpose = ?, Status = ?
      WHERE Movement_ID = ? AND Lecturer_ID = ?
    ''', [
      startDate,
      endDate,
      location,
      purpose,
      status,
      int.tryParse(movementId) ?? movementId,
      lecturerId,
    ]);
  }

  Future<int> deleteLecturerMovement(
    String lecturerId,
    String movementId,
  ) async {
    final db = await instance.database;
    await ensureLecturerStaffTables();
    return db.rawDelete(
      'DELETE FROM Movements WHERE Lecturer_ID = ? AND Movement_ID = ?',
      [lecturerId, int.tryParse(movementId) ?? movementId],
    );
  }

  Future<List<Map<String, dynamic>>> getClinics({String? typeName}) async {
    final db = await instance.database;
    await ensureLecturerStaffTables();
    final normalized = typeName?.trim().toUpperCase();
    int? typeId;
    if (normalized == 'MEDICAL' || normalized == 'CLINIC') {
      typeId = 1;
    } else if (normalized == 'DENTAL') {
      typeId = 2;
    } else if (normalized == 'PKU') {
      typeId = 3;
    }
    if (typeId == null && (normalized == null || normalized.isEmpty)) {
      return db.rawQuery('''
        SELECT cl.*, ct.Type_Name
        FROM Clinic_List cl
        LEFT JOIN Clinic_Type ct ON ct.Type_ID = cl.Type_ID
        ORDER BY cl.Clinic_Name
      ''');
    }
    return db.rawQuery('''
      SELECT cl.*, ct.Type_Name
      FROM Clinic_List cl
      LEFT JOIN Clinic_Type ct ON ct.Type_ID = cl.Type_ID
      WHERE cl.Type_ID = ? OR UPPER(ct.Type_Name) LIKE ?
      ORDER BY cl.Clinic_Name
    ''', [typeId ?? -1, '%${normalized ?? ''}%']);
  }

  Future<List<Map<String, dynamic>>> getMedicalRecords(
    String lecturerId,
  ) async {
    final db = await instance.database;
    await ensureLecturerStaffTables();
    final columns = await db.rawQuery('PRAGMA table_info(Medical_Records)');
    final names = columns.map((c) => c['name']?.toString()).toSet();
    final dateColumn = names.contains('Medical_Date') ? 'Medical_Date' : 'Date';
    final hasClinicId = names.contains('Clinic_ID');
    return db.rawQuery('''
      SELECT mr.Record_ID,
             mr.Lecturer_ID,
             mr.$dateColumn AS Medical_Date,
             mr.Charges,
             ${hasClinicId ? 'mr.Clinic_ID' : 'NULL'} AS Clinic_ID,
             cl.Clinic_Name,
             cl.Clinic_Address,
             cl.Clinic_Phone,
             ct.Type_Name
      FROM Medical_Records mr
      LEFT JOIN Clinic_List cl ON ${hasClinicId ? 'cl.Clinic_ID = CAST(mr.Clinic_ID AS INTEGER)' : '0'}
      LEFT JOIN Clinic_Type ct ON ct.Type_ID = cl.Type_ID
      WHERE mr.Lecturer_ID = ?
      ORDER BY date(mr.$dateColumn) DESC
    ''', [lecturerId]);
  }

  Future<int> saveMedicalRecord({
    String? recordId,
    required String lecturerId,
    required String clinicId,
    required String date,
    required double charges,
  }) async {
    final db = await instance.database;
    await ensureLecturerStaffTables();
    final columns = await db.rawQuery('PRAGMA table_info(Medical_Records)');
    final names = columns.map((c) => c['name']?.toString()).toSet();
    final id = recordId ?? DateTime.now().millisecondsSinceEpoch.toString();
    final dateColumn = names.contains('Medical_Date') ? 'Medical_Date' : 'Date';
    if (names.contains('Clinic_ID')) {
      return db.rawInsert('''
        INSERT OR REPLACE INTO Medical_Records
          (Record_ID, Lecturer_ID, Clinic_ID, $dateColumn, Charges)
        VALUES (?, ?, ?, ?, ?)
      ''', [int.tryParse(id) ?? id, lecturerId, clinicId, date, charges]);
    }
    return db.rawInsert('''
      INSERT OR REPLACE INTO Medical_Records
        (Record_ID, Lecturer_ID, $dateColumn, Charges)
      VALUES (?, ?, ?, ?)
    ''', [int.tryParse(id) ?? id, lecturerId, date, charges]);
  }

  Future<int> deleteMedicalRecord(String lecturerId, String recordId) async {
    final db = await instance.database;
    await ensureLecturerStaffTables();
    return db.rawDelete(
      'DELETE FROM Medical_Records WHERE Lecturer_ID = ? AND Record_ID = ?',
      [lecturerId, recordId],
    );
  }

  Future<Map<String, List<Course>>> getStudentTimetable(String userId) async {
    final db = await instance.database;

    final List<Map<String, dynamic>> results = await db.rawQuery('''
    SELECT
      se.Course_ID,
      c.Course_Name,
      l.Location_Name,
      l.Location_Link,
      ss.Day_Of_Week,
      ss.Start_Time,
      ss.End_Time
    FROM Courses_Enrollments ce
    JOIN Sections se ON ce.Section_ID = se.Section_ID
    JOIN Courses c ON se.Course_ID = c.Course_ID
    JOIN Section_Schedules ss ON se.Section_ID = ss.Section_ID
    JOIN Locations l ON ss.Location_ID = l.Location_ID
    WHERE ce.Student_ID = ?
      AND se.Academic_Session = '2025/2026'  -- 强行锁定学年
      AND se.Semester = 2
  ''', [userId]);

    final Map<String, List<Course>> weeklySchedule = {
      'Monday': [],
      'Tuesday': [],
      'Wednesday': [],
      'Thursday': [],
      'Friday': [],
    };

    for (var row in results) {
      String day = row['Day_Of_Week'] ?? 'Monday';

      String startTimeStr = row['Start_Time'] ?? '08:00';
      String endTimeStr = row['End_Time'] ?? '09:00';

      int startHour = int.parse(startTimeStr.split(':')[0]);
      int endHour = int.parse(endTimeStr.split(':')[0]);
      int duration = endHour - startHour;

      final course = Course(
        code: row['Course_ID'] ?? '',
        name: row['Course_Name'] ?? '',
        location: row['Location_Name'] ?? '',
        startHour: startHour,
        duration: duration > 0 ? duration : 1,
        backgroundColor: Colors.white,
        mapUrl: row['Location_Link'] ?? '',
      );

      if (weeklySchedule.containsKey(day)) {
        weeklySchedule[day]!.add(course);
      }
    }

    return weeklySchedule;
  }

  Future<List<StudentScheduleItem>> getStudentDailyTimetable(
      String userId) async {
    final db = await instance.database;

    String currentDay = DateFormat('EEEE').format(DateTime.now());

    final List<Map<String, dynamic>> results = await db.rawQuery('''
    SELECT
      c.Course_Name,
      l.Location_Name,
      ss.Start_Time,
      ss.End_Time
    FROM Courses_Enrollments ce
    JOIN Sections se ON ce.Section_ID = se.Section_ID
    JOIN Courses c ON se.Course_ID = c.Course_ID
    JOIN Section_Schedules ss ON se.Section_ID = ss.Section_ID
    JOIN Locations l ON ss.Location_ID = l.Location_ID
    WHERE ce.Student_ID = ?
      AND ss.Day_Of_Week = ?
      AND se.Academic_Session = '2025/2026'
      AND se.Semester = 2
    ORDER BY ss.Start_Time ASC
  ''', [userId, currentDay]);

    return results.map((row) {
      String rawStart = row['Start_Time'] ?? '08:00';
      String rawEnd = row['End_Time'] ?? '09:00';

      return StudentScheduleItem(
        start: _convertTo12HourFormat(rawStart),
        end: _convertTo12HourFormat(rawEnd),
        title: row['Course_Name'] ?? '',
        location: row['Location_Name'] ?? '',
      );
    }).toList();
  }

  String _convertTo12HourFormat(String time24) {
    try {
      final DateTime date = DateFormat("HH:mm").parse(time24);
      return DateFormat("h:mm a").format(date);
    } catch (_) {
      return time24;
    }
  }

  Future<Map<String, List<Course>>> getLecturerTimetable(
      String lecturerId) async {
    final db = await instance.database;

    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT
        se.Course_ID,
        c.Course_Name,
        l.Location_Name,
        l.Location_Link,
        ss.Day_Of_Week,
        ss.Start_Time,
        ss.End_Time
      FROM Sections se
      JOIN Courses c ON se.Course_ID = c.Course_ID
      JOIN Section_Schedules ss ON se.Section_ID = ss.Section_ID
      JOIN Locations l ON ss.Location_ID = l.Location_ID
      WHERE se.Lecturer_ID = ?
        AND se.Academic_Session = '2025/2026'
        AND se.Semester = 2
    ''', [lecturerId]);

    final Map<String, List<Course>> weeklySchedule = {
      'Monday': [],
      'Tuesday': [],
      'Wednesday': [],
      'Thursday': [],
      'Friday': [],
    };

    for (var row in results) {
      String day = row['Day_Of_Week'] ?? 'Monday';
      String startTimeStr = row['Start_Time'] ?? '08:00';
      String endTimeStr = row['End_Time'] ?? '09:00';

      int startHour = int.parse(startTimeStr.split(':')[0]);
      int endHour = int.parse(endTimeStr.split(':')[0]);
      int duration = endHour - startHour;

      final course = Course(
        code: row['Course_ID'] ?? '',
        name: row['Course_Name'] ?? '',
        location: row['Location_Name'] ?? '',
        startHour: startHour,
        duration: duration > 0 ? duration : 1,
        backgroundColor: Colors.white,
        mapUrl: row['Location_Link'] ?? '',
      );

      if (weeklySchedule.containsKey(day)) {
        weeklySchedule[day]!.add(course);
      }
    }
    return weeklySchedule;
  }

  Future<List<StudentScheduleItem>> getLecturerDailyTimetable(
      String lecturerId) async {
    final db = await instance.database;
    String currentDay = DateFormat('EEEE').format(DateTime.now());

    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT
        c.Course_Name,
        l.Location_Name,
        ss.Start_Time,
        ss.End_Time
      FROM Sections se
      JOIN Courses c ON se.Course_ID = c.Course_ID
      JOIN Section_Schedules ss ON se.Section_ID = ss.Section_ID
      JOIN Locations l ON ss.Location_ID = l.Location_ID
      WHERE se.Lecturer_ID = ?
        AND ss.Day_Of_Week = ?
        AND se.Academic_Session = '2025/2026'
        AND se.Semester = 2
      ORDER BY ss.Start_Time ASC
    ''', [lecturerId, currentDay]);

    return results.map((row) {
      String rawStart = row['Start_Time'] ?? '08:00';
      String rawEnd = row['End_Time'] ?? '09:00';

      return StudentScheduleItem(
        start: _convertTo12HourFormat(rawStart),
        end: _convertTo12HourFormat(rawEnd),
        title: row['Course_Name'] ?? '',
        location: row['Location_Name'] ?? '',
      );
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getVehiclesByStudent(
      String studentId) async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT v.*, vt.Details AS type
      FROM Vehicles v
      JOIN Vehicle_Types vt ON v.Vehicle_Type_ID = vt.Vehicle_Type_ID
      WHERE v.Student_ID = ?
      ORDER BY v.Vehicle_ID DESC
    ''', [studentId]);
  }

  Future<int> insertVehicle(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('Vehicles', row);
  }

  Future<int> updateStickerToPending(String plateNumber) async {
    final db = await instance.database;
    return await db.update(
      'Vehicles',
      {'Sticker_Status': 'PENDING'},
      where: 'Plate_Number = ?',
      whereArgs: [plateNumber],
    );
  }

  Future<List<Map<String, dynamic>>> getLecturerCoursesBySemester(
      String lecturerId, String session, int semester) async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT
          s.Section_ID AS section_id,
          c.Course_ID AS code,
          c.Course_Name AS name,
          s.Section_Code AS section,
          COUNT(ce.Student_ID) AS students
      FROM Sections s
      JOIN Courses c ON s.Course_ID = c.Course_ID
      LEFT JOIN Courses_Enrollments ce ON s.Section_ID = ce.Section_ID
      WHERE s.Lecturer_ID = ? AND s.Academic_Session = ? AND s.Semester = ?
      GROUP BY s.Section_ID
    ''', [lecturerId, session, semester]);
  }

  Future<int> insertLearningMaterial(String sectionId, String title,
      String size, String uploadedDate, Uint8List fileBytes) async {
    final db = await instance.database;
    return await db.insert('Learning_Materials', {
      'Materials_ID': 'MAT${DateTime.now().millisecondsSinceEpoch}',
      'Section_ID': sectionId,
      'Title': title,
      'Size': size,
      'Uploaded_Date': uploadedDate,
      'URL': fileBytes,
    });
  }

  Future<List<Map<String, dynamic>>> getLecturerSemesters(
      String lecturerId) async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT
          s.Academic_Session,
          s.Semester,
          COUNT(DISTINCT s.Section_ID) AS Total_Courses,
          COUNT(DISTINCT ce.Student_ID) AS Total_Students,

          (SELECT COUNT(*)
           FROM Learning_Materials lm
           JOIN Sections s2 ON lm.Section_ID = s2.Section_ID
           WHERE s2.Lecturer_ID = s.Lecturer_ID
             AND s2.Academic_Session = s.Academic_Session
             AND s2.Semester = s.Semester
          ) AS Total_Materials
      FROM Sections s
      LEFT JOIN Courses_Enrollments ce ON s.Section_ID = ce.Section_ID
      WHERE s.Lecturer_ID = ?
      GROUP BY s.Academic_Session, s.Semester
      ORDER BY s.Academic_Session ASC, s.Semester ASC
    ''', [lecturerId]);
  }

  Future<List<Map<String, dynamic>>> getPastYearQuestions(
      String courseId) async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT Past_Year_ID, Course_ID, Title, Session
      FROM Past_Year_Questions
      WHERE Course_ID = ?
      ORDER BY Past_Year_ID DESC
    ''', [courseId]);
  }

  Future<List<Map<String, dynamic>>> getLearningMaterials(
      String sectionId) async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT Materials_ID, Section_ID, Title, Size, Uploaded_Date
      FROM Learning_Materials
      WHERE Section_ID = ?
      ORDER BY Materials_ID DESC
    ''', [sectionId]);
  }

  Future<int> deleteLearningMaterial(String materialsId) async {
    final db = await instance.database;
    return await db.delete(
      'Learning_Materials',
      where: 'Materials_ID = ?',
      whereArgs: [materialsId],
    );
  }

  Future<String?> downloadStoredFile(
    Map<String, dynamic> row, {
    required String fileNameColumn,
    required String urlColumn,
  }) async {
    final bytes = await _storedFileBytes(row, urlColumn: urlColumn);
    if (bytes == null || bytes.isEmpty) return null;

    final dir = await _downloadDirectory();
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final fileName = _storedFileNameWithExtension(
      row[fileNameColumn]?.toString(),
      bytes,
    );
    final outputPath = join(
      dir.path,
      await _availableFileName(dir, _safeStoredFileName(fileName)),
    );
    await File(outputPath).writeAsBytes(bytes, flush: true);
    return outputPath;
  }

  Future<String?> downloadStoredFileById({
    required String tableName,
    required String idColumn,
    required Object id,
    required String fileName,
    required String blobColumn,
  }) async {
    final row = await _storedFileRowById(
      tableName: tableName,
      idColumn: idColumn,
      id: id,
      blobColumn: blobColumn,
    );
    if (row == null) return null;
    return downloadStoredFile(
      {
        'File_Name': fileName,
        blobColumn: row[blobColumn],
      },
      fileNameColumn: 'File_Name',
      urlColumn: blobColumn,
    );
  }

  Future<String?> downloadStoredFilesAsZip(
    List<Map<String, dynamic>> rows, {
    required String fileNameColumn,
    required String urlColumn,
    required String zipBaseName,
  }) async {
    final files = <_ZipFileEntry>[];
    for (final row in rows) {
      final bytes = await _storedFileBytes(row, urlColumn: urlColumn);
      if (bytes == null || bytes.isEmpty) continue;
      final fileName = _storedFileNameWithExtension(
        row[fileNameColumn]?.toString(),
        bytes,
      );
      files.add(_ZipFileEntry(_safeStoredFileName(fileName), bytes));
    }

    if (files.isEmpty) return null;

    final dir = await _downloadDirectory();
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final zipName = _safeStoredFileName('$zipBaseName.zip');
    final outputPath = join(dir.path, await _availableFileName(dir, zipName));
    await File(outputPath).writeAsBytes(_buildZip(files), flush: true);
    return outputPath;
  }

  Future<String?> downloadStoredFilesAsZipById({
    required String tableName,
    required String idColumn,
    required List<Map<String, dynamic>> items,
    required String itemIdColumn,
    required String itemFileNameColumn,
    required String blobColumn,
    required String zipBaseName,
  }) async {
    final rows = <Map<String, dynamic>>[];
    for (final item in items) {
      final id = item[itemIdColumn];
      if (id == null) continue;
      final row = await _storedFileRowById(
        tableName: tableName,
        idColumn: idColumn,
        id: id,
        blobColumn: blobColumn,
      );
      if (row == null) continue;
      rows.add({
        'File_Name': item[itemFileNameColumn]?.toString() ?? 'file',
        blobColumn: row[blobColumn],
      });
    }

    return downloadStoredFilesAsZip(
      rows,
      fileNameColumn: 'File_Name',
      urlColumn: blobColumn,
      zipBaseName: zipBaseName,
    );
  }

  Future<Map<String, dynamic>?> _storedFileRowById({
    required String tableName,
    required String idColumn,
    required Object id,
    required String blobColumn,
  }) async {
    final db = await instance.database;
    final rows = await db.rawQuery('''
      SELECT $blobColumn
      FROM $tableName
      WHERE $idColumn = ?
      LIMIT 1
    ''', [id]);
    return rows.isEmpty ? null : rows.first;
  }

  Future<List<int>?> _storedFileBytes(
    Map<String, dynamic> row, {
    required String urlColumn,
  }) async {
    final data = row[urlColumn];
    return data is List<int> && data.isNotEmpty ? data : null;
  }

  Future<Directory> _downloadDirectory() async {
    if (Platform.isAndroid) {
      final publicDownloads = Directory('/storage/emulated/0/Download/MyUTHM');
      try {
        if (await publicDownloads.parent.exists()) return publicDownloads;
      } catch (_) {}
    }

    final downloads = await getDownloadsDirectory();
    if (downloads != null) return Directory(join(downloads.path, 'MyUTHM'));

    final documents = await getApplicationDocumentsDirectory();
    return Directory(join(documents.path, 'Downloads', 'MyUTHM'));
  }

  Future<String> _availableFileName(Directory dir, String fileName) async {
    var candidate = fileName;
    final dotIndex = candidate.lastIndexOf('.');
    final base = dotIndex > 0 ? candidate.substring(0, dotIndex) : candidate;
    final extension = dotIndex > 0 ? candidate.substring(dotIndex) : '';
    var counter = 1;

    while (await File(join(dir.path, candidate)).exists()) {
      candidate = '${base}_$counter$extension';
      counter++;
    }
    return candidate;
  }

  String _storedFileNameWithExtension(String? name, List<int> bytes) {
    var value =
        (name == null || name.trim().isEmpty) ? 'myuthm_file' : name.trim();
    final hasExtension = value.split(RegExp(r'[\\/]')).last.contains('.');

    if (!hasExtension) {
      value = '$value${_extensionFromBytes(bytes)}';
    }
    return value;
  }

  String _extensionFromBytes(List<int> bytes) {
    if (bytes.length >= 4 &&
        bytes[0] == 0x25 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x44 &&
        bytes[3] == 0x46) {
      return '.pdf';
    }
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return '.png';
    }
    if (bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF) {
      return '.jpg';
    }
    if (bytes.length >= 2 && bytes[0] == 0x50 && bytes[1] == 0x4B) {
      final sample = latin1.decode(
        bytes.take(bytes.length > 50000 ? 50000 : bytes.length).toList(),
        allowInvalid: true,
      );
      if (sample.contains('word/')) return '.docx';
      if (sample.contains('xl/')) return '.xlsx';
      if (sample.contains('ppt/')) return '.pptx';
      return '.zip';
    }
    return '.bin';
  }

  String _safeStoredFileName(String? name) {
    final value =
        (name == null || name.trim().isEmpty) ? 'myuthm_file' : name.trim();
    return value.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
  }

  List<int> _buildZip(List<_ZipFileEntry> files) {
    final output = BytesBuilder(copy: false);
    final centralDirectory = BytesBuilder(copy: false);
    var offset = 0;

    for (final file in files) {
      final nameBytes = utf8.encode(file.name);
      final crc = _crc32(file.bytes);

      final localHeader = BytesBuilder(copy: false)
        ..add(_u32(0x04034b50))
        ..add(_u16(20))
        ..add(_u16(0))
        ..add(_u16(0))
        ..add(_u16(0))
        ..add(_u16(0))
        ..add(_u32(crc))
        ..add(_u32(file.bytes.length))
        ..add(_u32(file.bytes.length))
        ..add(_u16(nameBytes.length))
        ..add(_u16(0))
        ..add(nameBytes);
      final localHeaderBytes = localHeader.toBytes();
      output
        ..add(localHeaderBytes)
        ..add(file.bytes);

      centralDirectory
        ..add(_u32(0x02014b50))
        ..add(_u16(20))
        ..add(_u16(20))
        ..add(_u16(0))
        ..add(_u16(0))
        ..add(_u16(0))
        ..add(_u16(0))
        ..add(_u32(crc))
        ..add(_u32(file.bytes.length))
        ..add(_u32(file.bytes.length))
        ..add(_u16(nameBytes.length))
        ..add(_u16(0))
        ..add(_u16(0))
        ..add(_u16(0))
        ..add(_u16(0))
        ..add(_u32(0))
        ..add(_u32(offset))
        ..add(nameBytes);

      offset += localHeaderBytes.length + file.bytes.length;
    }

    final centralBytes = centralDirectory.toBytes();
    output
      ..add(centralBytes)
      ..add(_u32(0x06054b50))
      ..add(_u16(0))
      ..add(_u16(0))
      ..add(_u16(files.length))
      ..add(_u16(files.length))
      ..add(_u32(centralBytes.length))
      ..add(_u32(offset))
      ..add(_u16(0));
    return output.toBytes();
  }

  List<int> _u16(int value) {
    final data = ByteData(2)..setUint16(0, value, Endian.little);
    return data.buffer.asUint8List();
  }

  List<int> _u32(int value) {
    final data = ByteData(4)..setUint32(0, value, Endian.little);
    return data.buffer.asUint8List();
  }

  int _crc32(List<int> bytes) {
    var crc = 0xffffffff;
    for (final byte in bytes) {
      crc ^= byte;
      for (var i = 0; i < 8; i++) {
        crc = (crc & 1) == 1 ? (crc >> 1) ^ 0xedb88320 : crc >> 1;
      }
    }
    return (crc ^ 0xffffffff) & 0xffffffff;
  }

  Future<List<Map<String, dynamic>>> getAssignments(
      String sectionId, String assignmentTypeId) async {
    final db = await instance.database;
    await _ensureAssignmentDueTimeColumn(db);
    return await db.rawQuery('''
      SELECT Assignment_ID, Section_ID, Assignment_Type_ID, Assignment_Title,
             Max_Members, Due_Date, Due_Time
      FROM Assignments
      WHERE Section_ID = ? AND Assignment_Type_ID = ?
      ORDER BY Assignment_ID DESC
    ''', [sectionId, assignmentTypeId]);
  }

  Future<String> insertAssignment({
    required String sectionId,
    required String assignmentTypeId,
    required String title,
    required int maxMembers,
    required String dueDate,
    required String dueTime,
  }) async {
    final db = await instance.database;
    await _ensureAssignmentDueTimeColumn(db);

    final newId = await db.rawInsert('''
      INSERT INTO Assignments
        (Section_ID, Assignment_Type_ID, Assignment_Title, Max_Members, Due_Date, Due_Time)
      VALUES (?, ?, ?, ?, ?, ?)
    ''', [
      int.tryParse(sectionId) ?? sectionId,
      int.tryParse(assignmentTypeId) ?? assignmentTypeId,
      title,
      maxMembers,
      dueDate,
      dueTime,
    ]);

    return newId.toString();
  }

  Future<int> updateAssignment({
    required String assignmentId,
    required String title,
    required int maxMembers,
    required String dueDate,
    required String dueTime,
  }) async {
    final db = await instance.database;
    await _ensureAssignmentDueTimeColumn(db);
    return await db.rawUpdate('''
      UPDATE Assignments
      SET Assignment_Title = ?,
          Max_Members = ?,
          Due_Date = ?,
          Due_Time = ?
      WHERE Assignment_ID = ?
    ''', [title, maxMembers, dueDate, dueTime, assignmentId]);
  }

  Future<int> deleteAssignment(String assignmentId) async {
    final db = await instance.database;
    return await db.transaction((txn) async {
      if (await _tableExists(txn, 'Assignment_Attachments')) {
        await txn.rawDelete(
          'DELETE FROM Assignment_Attachments WHERE Assignment_ID = ?',
          [assignmentId],
        );
      }
      if (await _tableExists(txn, 'Group_Members') &&
          await _tableExists(txn, 'Assignment_Groups')) {
        await txn.rawDelete(
          '''
          DELETE FROM Group_Members
          WHERE Group_ID IN (
            SELECT Group_ID FROM Assignment_Groups WHERE Assignment_ID = ?
          )
          ''',
          [assignmentId],
        );
      }
      if (await _tableExists(txn, 'Submissions')) {
        await txn.rawDelete(
          'DELETE FROM Submissions WHERE Assignment_ID = ?',
          [assignmentId],
        );
      }
      if (await _tableExists(txn, 'Assignment_Groups')) {
        await txn.rawDelete(
          'DELETE FROM Assignment_Groups WHERE Assignment_ID = ?',
          [assignmentId],
        );
      }
      return await txn.rawDelete(
        'DELETE FROM Assignments WHERE Assignment_ID = ?',
        [assignmentId],
      );
    });
  }

  Future<bool> _tableExists(dynamic db, String tableName) async {
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
      [tableName],
    );
    return result.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> getAssignmentAttachments(
      String assignmentId) async {
    final db = await instance.database;
    await _ensureAssignmentAttachmentTable(db);
    return await db.rawQuery('''
      SELECT Attachment_ID, Assignment_ID, File_Name, File_Size
      FROM Assignment_Attachments
      WHERE Assignment_ID = ?
      ORDER BY Attachment_ID ASC
    ''', [assignmentId]);
  }

  Future<int> insertAssignmentAttachment({
    required String assignmentId,
    required String fileName,
    required String fileSize,
    required Uint8List fileBytes,
  }) async {
    final db = await instance.database;
    await _ensureAssignmentAttachmentTable(db);

    return await db.rawInsert('''
      INSERT INTO Assignment_Attachments
        (Assignment_ID, File_Name, File_Size, File_URL)
      VALUES (?, ?, ?, ?)
    ''', [
      int.tryParse(assignmentId) ?? assignmentId,
      fileName,
      fileSize,
      fileBytes,
    ]);
  }

  Future<int> deleteAssignmentAttachment(String attachmentId) async {
    final db = await instance.database;
    await _ensureAssignmentAttachmentTable(db);
    return await db.rawDelete(
      'DELETE FROM Assignment_Attachments WHERE Attachment_ID = ?',
      [attachmentId],
    );
  }

  Future<void> _ensureAssignmentAttachmentTable(dynamic db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Assignment_Attachments (
        Attachment_ID INTEGER PRIMARY KEY AUTOINCREMENT,
        Assignment_ID INTEGER NOT NULL,
        File_Name TEXT NOT NULL,
        File_Size TEXT,
        File_URL BLOB,
        FOREIGN KEY (Assignment_ID) REFERENCES Assignments(Assignment_ID)
      )
    ''');
  }

  Future<void> _ensureAssignmentDueTimeColumn(dynamic db) async {
    final columns = await db.rawQuery('PRAGMA table_info(Assignments)');
    final hasDueTime = columns.any(
      (column) => column['name']?.toString().toLowerCase() == 'due_time',
    );
    if (!hasDueTime) {
      await db.execute('ALTER TABLE Assignments ADD COLUMN Due_Time TEXT');
    }
  }

  Future<void> _ensureAssignmentGroupsTables(dynamic db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Assignment_Groups (
        Group_ID INTEGER PRIMARY KEY AUTOINCREMENT,
        Assignment_ID INTEGER NOT NULL,
        Group_Number INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Group_Members (
        Group_Member_ID INTEGER PRIMARY KEY AUTOINCREMENT,
        Group_ID INTEGER NOT NULL,
        Student_ID VARCHAR(50) NOT NULL
      )
    ''');
  }

  Future<void> createAssignmentGroups(
      String assignmentId, int groupCount) async {
    final db = await instance.database;
    await _ensureAssignmentGroupsTables(db);
    final count = groupCount < 1 ? 1 : groupCount;
    for (var i = 1; i <= count; i++) {
      await db.rawInsert('''
        INSERT INTO Assignment_Groups (Assignment_ID, Group_Number)
        VALUES (?, ?)
      ''', [int.tryParse(assignmentId) ?? assignmentId, i]);
    }
  }

  Future<void> syncAssignmentGroups(String assignmentId, int groupCount) async {
    final db = await instance.database;
    await _ensureAssignmentGroupsTables(db);
    await _ensureSubmissionsTable(db);
    final count = groupCount < 1 ? 1 : groupCount;
    final existing = await db.rawQuery('''
      SELECT Group_ID, Group_Number
      FROM Assignment_Groups
      WHERE Assignment_ID = ?
      ORDER BY Group_Number ASC
    ''', [assignmentId]);

    if (existing.length < count) {
      for (var i = existing.length + 1; i <= count; i++) {
        await db.rawInsert('''
          INSERT INTO Assignment_Groups (Assignment_ID, Group_Number)
          VALUES (?, ?)
        ''', [int.tryParse(assignmentId) ?? assignmentId, i]);
      }
      return;
    }

    for (final row in existing) {
      final number = int.tryParse(row['Group_Number'].toString()) ?? 0;
      if (number <= count) continue;
      final groupId = row['Group_ID'].toString();
      await db
          .rawDelete('DELETE FROM Group_Members WHERE Group_ID = ?', [groupId]);
      await db
          .rawDelete('DELETE FROM Submissions WHERE Group_ID = ?', [groupId]);
      await db.rawDelete(
          'DELETE FROM Assignment_Groups WHERE Group_ID = ?', [groupId]);
    }
  }

  Future<List<Map<String, dynamic>>> getAssignmentGroups(
    String assignmentId,
    String studentId,
  ) async {
    final db = await instance.database;
    await _ensureAssignmentGroupsTables(db);
    return await db.rawQuery('''
      SELECT ag.Group_ID, ag.Assignment_ID, ag.Group_Number,
             COUNT(gm.Group_Member_ID) AS Member_Count,
             MAX(CASE WHEN gm.Student_ID = ? THEN 1 ELSE 0 END) AS Is_Joined
      FROM Assignment_Groups ag
      LEFT JOIN Group_Members gm ON ag.Group_ID = gm.Group_ID
      WHERE ag.Assignment_ID = ?
      GROUP BY ag.Group_ID, ag.Assignment_ID, ag.Group_Number
      ORDER BY ag.Group_Number ASC
    ''', [studentId, assignmentId]);
  }

  Future<List<Map<String, dynamic>>> getGroupMembers(String groupId) async {
    final db = await instance.database;
    await _ensureAssignmentGroupsTables(db);
    return await db.rawQuery('''
      SELECT gm.Group_Member_ID,
             gm.Group_ID,
             gm.Student_ID,
             COALESCE(u.Name, gm.Student_ID) AS Student_Name
      FROM Group_Members gm
      LEFT JOIN Users u ON u.User_ID = gm.Student_ID
      WHERE gm.Group_ID = ?
      ORDER BY gm.Group_Member_ID ASC
    ''', [groupId]);
  }

  Future<bool> joinAssignmentGroup({
    required String assignmentId,
    required String groupId,
    required String studentId,
  }) async {
    final db = await instance.database;
    await _ensureAssignmentGroupsTables(db);
    final current = await db.rawQuery('''
      SELECT gm.Group_Member_ID
      FROM Group_Members gm
      JOIN Assignment_Groups ag ON gm.Group_ID = ag.Group_ID
      WHERE ag.Assignment_ID = ? AND gm.Student_ID = ?
      LIMIT 1
    ''', [assignmentId, studentId]);
    if (current.isNotEmpty) return false;
    await db.rawInsert('''
      INSERT INTO Group_Members (Group_ID, Student_ID)
      VALUES (?, ?)
    ''', [int.tryParse(groupId) ?? groupId, studentId]);
    return true;
  }

  Future<int> quitAssignmentGroup({
    required String groupId,
    required String studentId,
  }) async {
    final db = await instance.database;
    await _ensureAssignmentGroupsTables(db);
    return await db.rawDelete('''
      DELETE FROM Group_Members
      WHERE Group_ID = ? AND Student_ID = ?
    ''', [groupId, studentId]);
  }

  Future<void> _ensureSubmissionsTable(dynamic db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Submissions (
        Submission_ID INTEGER PRIMARY KEY AUTOINCREMENT,
        Assignment_ID INTEGER NOT NULL,
        Student_ID VARCHAR(50),
        Group_ID INTEGER,
        Submission_Status_ID INTEGER,
        File_Name TEXT NOT NULL,
        File_URL BLOB NOT NULL,
        Uploaded_Date DATETIME
      )
    ''');
  }

  Future<List<Map<String, dynamic>>> getSubmissions({
    required String assignmentId,
    String? studentId,
    String? groupId,
  }) async {
    final db = await instance.database;
    await _ensureSubmissionsTable(db);
    final where = <String>['Assignment_ID = ?'];
    final args = <Object?>[int.tryParse(assignmentId) ?? assignmentId];
    if (studentId != null) {
      where.add('Student_ID = ?');
      args.add(studentId);
    }
    if (groupId != null) {
      where.add('Group_ID = ?');
      args.add(int.tryParse(groupId) ?? groupId);
    }
    return await db.rawQuery('''
      SELECT Submission_ID, Assignment_ID, Student_ID, Group_ID,
             Submission_Status_ID, File_Name, Uploaded_Date
      FROM Submissions
      WHERE ${where.join(' AND ')}
      ORDER BY Submission_ID DESC
    ''', args);
  }

  Future<int> insertSubmission({
    required String assignmentId,
    required String studentId,
    String? groupId,
    required String fileName,
    required Uint8List fileBytes,
    required String uploadedDate,
  }) async {
    final db = await instance.database;
    await _ensureSubmissionsTable(db);
    return await db.rawInsert('''
      INSERT INTO Submissions
        (Assignment_ID, Student_ID, Group_ID, Submission_Status_ID,
         File_Name, File_URL, Uploaded_Date)
      VALUES (?, ?, ?, ?, ?, ?, ?)
    ''', [
      int.tryParse(assignmentId) ?? assignmentId,
      studentId,
      groupId == null ? null : int.tryParse(groupId) ?? groupId,
      1,
      fileName,
      fileBytes,
      uploadedDate,
    ]);
  }

  Future<int> deleteSubmission(String submissionId) async {
    final db = await instance.database;
    await _ensureSubmissionsTable(db);
    return await db.rawDelete(
      'DELETE FROM Submissions WHERE Submission_ID = ?',
      [submissionId],
    );
  }

  Future<void> _ensureAttendanceTables(dynamic db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Attendance_Sessions (
        Session_ID INTEGER PRIMARY KEY AUTOINCREMENT,
        Schedule_ID INTEGER NOT NULL,
        Session_Date DATE NOT NULL,
        Attendance_Code TEXT NOT NULL,
        Status TEXT DEFAULT 'Open',
        FOREIGN KEY (Schedule_ID) REFERENCES Section_Schedules(Schedule_ID) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Course_Attendances (
        Attendance_ID INTEGER PRIMARY KEY AUTOINCREMENT,
        Session_ID INTEGER NOT NULL,
        Student_ID TEXT NOT NULL,
        Attendance_Status TEXT DEFAULT 'Absent',
        Recorded_At DATETIME,
        FOREIGN KEY (Session_ID) REFERENCES Attendance_Sessions(Session_ID) ON DELETE CASCADE,
        FOREIGN KEY (Student_ID) REFERENCES Students(Student_ID) ON DELETE CASCADE,
        UNIQUE(Session_ID, Student_ID)
      )
    ''');
    final columns = await db.rawQuery('PRAGMA table_info(Attendance_Sessions)');
    final names = columns
        .map((column) => column['name']?.toString().toLowerCase())
        .whereType<String>()
        .toSet();
    if (!names.contains('session_start_time')) {
      await db.execute(
          'ALTER TABLE Attendance_Sessions ADD COLUMN Session_Start_Time TEXT');
    }
    if (!names.contains('session_end_time')) {
      await db.execute(
          'ALTER TABLE Attendance_Sessions ADD COLUMN Session_End_Time TEXT');
    }
    if (!names.contains('created_at')) {
      await db.execute(
          'ALTER TABLE Attendance_Sessions ADD COLUMN Created_At TEXT');
    }
  }

  Future<List<Map<String, dynamic>>> getAttendanceSchedules(
      String sectionId) async {
    final db = await instance.database;
    final columns = await db.rawQuery('PRAGMA table_info(Section_Schedules)');
    final names = columns
        .map((column) => column['name']?.toString().toLowerCase())
        .whereType<String>()
        .toSet();
    final hasClassType = names.contains('class_type');
    final classTypeSelect =
        hasClassType ? 'Class_Type' : "'LECTURE' AS Class_Type";
    final classTypeFilter = hasClassType
        ? "AND UPPER(COALESCE(Class_Type, '')) IN ('LECTURE', 'TUTORIAL')"
        : '';
    final classTypeOrder = hasClassType
        ? '''
        CASE
          WHEN UPPER(Class_Type) = 'LECTURE' THEN 0
          WHEN UPPER(Class_Type) = 'TUTORIAL' THEN 1
          ELSE 2
        END,
        '''
        : '';

    return await db.rawQuery('''
      SELECT Schedule_ID, Section_ID, $classTypeSelect, Day_Of_Week, Start_Time, End_Time
      FROM Section_Schedules
      WHERE Section_ID = ?
        $classTypeFilter
      ORDER BY
        $classTypeOrder
        Start_Time ASC
    ''', [int.tryParse(sectionId) ?? sectionId]);
  }

  Future<void> ensureAttendanceTablesForApp() async {
    final db = await instance.database;
    await _ensureAttendanceTables(db);
  }

  Future<List<Map<String, dynamic>>> getAttendanceSessions(
      String sectionId) async {
    final db = await instance.database;
    await _ensureAttendanceTables(db);
    final columns = await db.rawQuery('PRAGMA table_info(Section_Schedules)');
    final names = columns
        .map((column) => column['name']?.toString().toLowerCase())
        .whereType<String>()
        .toSet();
    final classTypeSelect = names.contains('class_type')
        ? 'ss.Class_Type'
        : "'LECTURE' AS Class_Type";
    return await db.rawQuery('''
      SELECT ats.Session_ID, ats.Schedule_ID, ats.Session_Date,
             ats.Attendance_Code, ats.Status, ats.Created_At,
             $classTypeSelect, ss.Day_Of_Week,
             COALESCE(ats.Session_Start_Time, ss.Start_Time) AS Start_Time,
             COALESCE(ats.Session_End_Time, ss.End_Time) AS End_Time,
             SUM(CASE WHEN ca.Attendance_Status = 'Present' THEN 1 ELSE 0 END) AS Present_Count,
             COUNT(ca.Attendance_ID) AS Total_Count
      FROM Attendance_Sessions ats
      JOIN Section_Schedules ss ON ats.Schedule_ID = ss.Schedule_ID
      LEFT JOIN Course_Attendances ca ON ats.Session_ID = ca.Session_ID
      WHERE ss.Section_ID = ?
      GROUP BY ats.Session_ID
      ORDER BY ats.Session_Date DESC, ss.Start_Time DESC
    ''', [int.tryParse(sectionId) ?? sectionId]);
  }

  Future<List<Map<String, dynamic>>> getAttendanceRecords(
      String sessionId) async {
    final db = await instance.database;
    await _ensureAttendanceTables(db);
    return await db.rawQuery('''
      SELECT ca.Attendance_ID, ca.Session_ID, ca.Student_ID,
             COALESCE(u.Name, ca.Student_ID) AS Student_Name,
             ca.Attendance_Status, ca.Recorded_At
      FROM Course_Attendances ca
      LEFT JOIN Users u ON u.User_ID = ca.Student_ID
      WHERE ca.Session_ID = ?
      ORDER BY u.Name ASC, ca.Student_ID ASC
    ''', [int.tryParse(sessionId) ?? sessionId]);
  }

  Future<String> _generateAttendanceCode(dynamic db) async {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    for (var attempt = 0; attempt < 20; attempt++) {
      final code =
          List.generate(5, (_) => chars[random.nextInt(chars.length)]).join();
      final existing = await db.rawQuery(
        'SELECT Session_ID FROM Attendance_Sessions WHERE UPPER(Attendance_Code) = UPPER(?) LIMIT 1',
        [code],
      );
      if (existing.isEmpty) return code;
    }
    return DateTime.now().millisecondsSinceEpoch.toString().substring(8);
  }

  Future<Map<String, dynamic>> createAttendanceSession({
    required String scheduleId,
    required String sessionDate,
    required String startTime,
    required String endTime,
  }) async {
    final db = await instance.database;
    await _ensureAttendanceTables(db);
    return await db.transaction<Map<String, dynamic>>((txn) async {
      final code = await _generateAttendanceCode(txn);
      final createdAt =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      final sessionId = await txn.rawInsert('''
        INSERT INTO Attendance_Sessions
          (Schedule_ID, Session_Date, Attendance_Code, Status, Session_Start_Time, Session_End_Time, Created_At)
        VALUES (?, ?, ?, 'Open', ?, ?, ?)
      ''', [
        int.tryParse(scheduleId) ?? scheduleId,
        sessionDate,
        code,
        startTime,
        endTime,
        createdAt,
      ]);

      await txn.rawInsert('''
        INSERT OR IGNORE INTO Course_Attendances
          (Session_ID, Student_ID, Attendance_Status)
        SELECT ?, ce.Student_ID, 'Absent'
        FROM Courses_Enrollments ce
        JOIN Section_Schedules ss ON ss.Section_ID = ce.Section_ID
        WHERE ss.Schedule_ID = ?
      ''', [sessionId, int.tryParse(scheduleId) ?? scheduleId]);

      return {
        'Session_ID': sessionId,
        'Attendance_Code': code,
      };
    });
  }

  Future<int> updateAttendanceSession({
    required String sessionId,
    required String scheduleId,
    required String sessionDate,
    required String startTime,
    required String endTime,
  }) async {
    final db = await instance.database;
    await _ensureAttendanceTables(db);
    return await db.rawUpdate('''
      UPDATE Attendance_Sessions
      SET Schedule_ID = ?,
          Session_Date = ?,
          Session_Start_Time = ?,
          Session_End_Time = ?
      WHERE Session_ID = ?
    ''', [
      int.tryParse(scheduleId) ?? scheduleId,
      sessionDate,
      startTime,
      endTime,
      int.tryParse(sessionId) ?? sessionId,
    ]);
  }

  Future<int> updateAttendanceSessionStatus({
    required String sessionId,
    required String status,
  }) async {
    final db = await instance.database;
    await _ensureAttendanceTables(db);
    return await db.rawUpdate(
      'UPDATE Attendance_Sessions SET Status = ? WHERE Session_ID = ?',
      [status, int.tryParse(sessionId) ?? sessionId],
    );
  }

  Future<int> deletePastYearQuestion(String pastYearId) async {
    final db = await instance.database;
    return await db.delete(
      'Past_Year_Questions',
      where: 'Past_Year_ID = ?',
      whereArgs: [pastYearId],
    );
  }

  Future<int> deleteAttendanceSession(String sessionId) async {
    final db = await instance.database;
    await _ensureAttendanceTables(db);
    return await db.rawDelete(
      'DELETE FROM Attendance_Sessions WHERE Session_ID = ?',
      [int.tryParse(sessionId) ?? sessionId],
    );
  }

  Future<List<Map<String, dynamic>>> getStudentAttendanceForSection({
    required String sectionId,
    required String studentId,
  }) async {
    final db = await instance.database;
    await _ensureAttendanceTables(db);
    final columns = await db.rawQuery('PRAGMA table_info(Section_Schedules)');
    final names = columns
        .map((column) => column['name']?.toString().toLowerCase())
        .whereType<String>()
        .toSet();
    final classTypeSelect = names.contains('class_type')
        ? 'ss.Class_Type'
        : "'LECTURE' AS Class_Type";
    return await db.rawQuery('''
      SELECT ats.Session_ID, ats.Session_Date, ats.Attendance_Code, ats.Status,
             $classTypeSelect, ss.Day_Of_Week,
             COALESCE(ats.Session_Start_Time, ss.Start_Time) AS Start_Time,
             COALESCE(ats.Session_End_Time, ss.End_Time) AS End_Time,
             COALESCE(ca.Attendance_Status, 'Absent') AS Attendance_Status,
             ca.Recorded_At
      FROM Attendance_Sessions ats
      JOIN Section_Schedules ss ON ats.Schedule_ID = ss.Schedule_ID
      LEFT JOIN Course_Attendances ca
        ON ca.Session_ID = ats.Session_ID AND ca.Student_ID = ?
      WHERE ss.Section_ID = ?
      ORDER BY ats.Session_Date DESC, ss.Start_Time DESC
    ''', [studentId, int.tryParse(sectionId) ?? sectionId]);
  }

  Future<int> updateAttendanceStatus({
    required String attendanceId,
    required String status,
  }) async {
    final db = await instance.database;
    await _ensureAttendanceTables(db);
    return await db.rawUpdate('''
      UPDATE Course_Attendances
      SET Attendance_Status = ?, Recorded_At = ?
      WHERE Attendance_ID = ?
    ''', [
      status,
      status == 'Present'
          ? DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())
          : null,
      int.tryParse(attendanceId) ?? attendanceId,
    ]);
  }

  Future<Map<String, dynamic>?> markAttendanceByCode({
    required String code,
    required String studentId,
  }) async {
    final db = await instance.database;
    await _ensureAttendanceTables(db);
    final cleanedCode = code.trim().toUpperCase();
    final sessions = await db.rawQuery('''
      SELECT ats.Session_ID, ats.Schedule_ID, ats.Session_Date,
             ats.Attendance_Code, ats.Status,
             ss.Section_ID
      FROM Attendance_Sessions ats
      JOIN Section_Schedules ss ON ats.Schedule_ID = ss.Schedule_ID
      WHERE UPPER(ats.Attendance_Code) = ?
        AND COALESCE(ats.Status, 'Open') = 'Open'
      LIMIT 1
    ''', [cleanedCode]);
    if (sessions.isEmpty) return null;

    final session = sessions.first;
    final sectionId = session['Section_ID'];
    final enrolled = await db.rawQuery('''
      SELECT Course_Enrollment_ID
      FROM Courses_Enrollments
      WHERE Section_ID = ? AND Student_ID = ?
      LIMIT 1
    ''', [sectionId, studentId]);
    if (enrolled.isEmpty) return null;

    final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final updated = await db.rawUpdate('''
      UPDATE Course_Attendances
      SET Attendance_Status = 'Present', Recorded_At = ?
      WHERE Session_ID = ? AND Student_ID = ?
    ''', [now, session['Session_ID'], studentId]);
    if (updated == 0) {
      await db.rawInsert('''
        INSERT OR IGNORE INTO Course_Attendances
          (Session_ID, Student_ID, Attendance_Status, Recorded_At)
        VALUES (?, ?, 'Present', ?)
      ''', [session['Session_ID'], studentId, now]);
    }
    return session;
  }

  Future<Map<String, String>?> getCourseDataBySectionId(
      String sectionId) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT s.Section_ID, c.Course_ID, c.Course_Name, s.Section_Code,
             COALESCE(u.Name, 'Lecturer') AS Lecturer_Name
      FROM Sections s
      JOIN Courses c ON s.Course_ID = c.Course_ID
      LEFT JOIN Users u ON s.Lecturer_ID = u.User_ID
      WHERE s.Section_ID = ?
      LIMIT 1
    ''', [int.tryParse(sectionId) ?? sectionId]);
    if (result.isEmpty) return null;
    final row = result.first;
    return {
      'section_id': row['Section_ID']?.toString() ?? '',
      'code': row['Course_ID']?.toString() ?? '',
      'name': row['Course_Name']?.toString() ?? '',
      'section': row['Section_Code']?.toString() ?? '',
      'lecturer': row['Lecturer_Name']?.toString() ?? 'Lecturer',
      'attendance': '0%',
    };
  }

  Future<String> _currentUserName(dynamic db) async {
    if (currentUserId.isEmpty) return 'Lecturer';
    final rows = await db.rawQuery(
      'SELECT Name FROM Users WHERE User_ID = ? LIMIT 1',
      [currentUserId],
    );
    if (rows.isEmpty) return 'Lecturer';
    return rows.first['Name']?.toString() ?? 'Lecturer';
  }

  Future<void> _ensureStreamsTable(dynamic db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Streams (
        Stream_ID TEXT PRIMARY KEY,
        Section_ID INTEGER,
        Lecturer_ID TEXT,
        Title TEXT,
        Content TEXT,
        Created_At TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    final columns = await db.rawQuery('PRAGMA table_info(Streams)');
    final names = columns
        .map((column) => column['name']?.toString().toLowerCase())
        .whereType<String>()
        .toSet();
    if (!names.contains('section_id')) {
      await db.execute('ALTER TABLE Streams ADD COLUMN Section_ID INTEGER');
    }
  }

  Future<List<Map<String, dynamic>>> getStreams(String sectionId) async {
    final db = await instance.database;
    await _ensureStreamsTable(db);
    return await db.rawQuery('''
      SELECT s.Stream_ID, s.Section_ID, s.Lecturer_ID, s.Title, s.Content,
             s.Created_At, COALESCE(u.Name, s.Lecturer_ID, 'Lecturer') AS Lecturer_Name
      FROM Streams s
      LEFT JOIN Users u ON u.User_ID = s.Lecturer_ID
      WHERE s.Section_ID = ?
      ORDER BY datetime(s.Created_At) DESC, s.Stream_ID DESC
    ''', [int.tryParse(sectionId) ?? sectionId]);
  }

  Future<String> insertStream({
    required String sectionId,
    required String title,
    required String content,
  }) async {
    final db = await instance.database;
    await _ensureStreamsTable(db);
    final columns = await db.rawQuery('PRAGMA table_info(Streams)');
    final streamIdColumn = columns.firstWhere(
      (column) => column['name']?.toString().toLowerCase() == 'stream_id',
      orElse: () => <String, Object?>{},
    );
    final streamIdType = streamIdColumn['type']?.toString().toUpperCase() ?? '';
    final createdAt = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final values = [
      int.tryParse(sectionId) ?? sectionId,
      currentUserId,
      title,
      content,
      createdAt,
    ];

    if (streamIdType.contains('INT')) {
      final id = await db.rawInsert('''
        INSERT INTO Streams
          (Section_ID, Lecturer_ID, Title, Content, Created_At)
        VALUES (?, ?, ?, ?, ?)
      ''', values);
      return id.toString();
    }

    final id = 'STR${DateTime.now().millisecondsSinceEpoch}';
    await db.rawInsert('''
      INSERT INTO Streams
        (Stream_ID, Section_ID, Lecturer_ID, Title, Content, Created_At)
      VALUES (?, ?, ?, ?, ?, ?)
    ''', [id, ...values]);
    return id;
  }

  Future<void> insertAutoStream({
    required String sectionId,
    required String action,
    String title = 'Course Update',
  }) async {
    if (sectionId.isEmpty) return;
    try {
      final db = await instance.database;
      final lecturerName = await _currentUserName(db);
      await insertStream(
        sectionId: sectionId,
        title: title,
        content: '$lecturerName Has $action',
      );
    } catch (_) {}
  }

  Future<int> updateStream({
    required String streamId,
    required String title,
    required String content,
  }) async {
    final db = await instance.database;
    await _ensureStreamsTable(db);
    return await db.rawUpdate('''
      UPDATE Streams
      SET Title = ?, Content = ?
      WHERE Stream_ID = ?
    ''', [title, content, streamId]);
  }

  Future<int> deleteStream(String streamId) async {
    final db = await instance.database;
    await _ensureStreamsTable(db);
    return await db.rawDelete(
      'DELETE FROM Streams WHERE Stream_ID = ?',
      [streamId],
    );
  }

  Future<void> _ensureAssessmentTables(dynamic db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Assessment_Components (
        component_id INTEGER PRIMARY KEY AUTOINCREMENT,
        component_name VARCHAR(100) NOT NULL,
        component_type VARCHAR(100) NOT NULL,
        weightage DECIMAL(5,2) NOT NULL,
        max_marks INT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Assessments (
        Assessment_ID INTEGER PRIMARY KEY AUTOINCREMENT,
        Section_ID INTEGER NOT NULL,
        Component_ID INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Assessment_Enrollments (
        Assessment_Enrollment_ID INTEGER PRIMARY KEY AUTOINCREMENT,
        Assessment_ID INTEGER NOT NULL,
        Student_ID VARCHAR(50) NOT NULL,
        Marks REAL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Assessment_Schedules (
        Schedule_ID INTEGER PRIMARY KEY AUTOINCREMENT,
        Assessment_ID INT,
        Assessment_Date TEXT,
        Start_Time TEXT,
        End_Time TEXT
      )
    ''');
    final columns =
        await db.rawQuery('PRAGMA table_info(Assessment_Schedules)');
    final names = columns
        .map((column) => column['name']?.toString().toLowerCase())
        .whereType<String>()
        .toSet();
    final extras = <String, String>{
      'quiz_title': 'Quiz_Title TEXT',
      'duration_minutes': 'Duration_Minutes INTEGER',
      'instructions': 'Instructions TEXT',
      'is_hidden': 'Is_Hidden INTEGER DEFAULT 0',
    };
    for (final entry in extras.entries) {
      if (!names.contains(entry.key)) {
        await db.execute(
            'ALTER TABLE Assessment_Schedules ADD COLUMN ${entry.value}');
      }
    }
  }

  Future<void> ensureAssessmentTablesForApp() async {
    final db = await instance.database;
    await _ensureAssessmentTables(db);
  }

  Future<List<Map<String, dynamic>>> getAssessmentsForSection(
    String sectionId, {
    bool includeHidden = false,
  }) async {
    final db = await instance.database;
    await _ensureAssessmentTables(db);
    final hiddenFilter =
        includeHidden ? '' : 'AND COALESCE(acs.Is_Hidden, 0) = 0';
    return await db.rawQuery('''
      SELECT a.Assessment_ID, a.Section_ID, a.Component_ID,
             COALESCE(acs.Quiz_Title, ac.component_name, 'Quiz') AS Quiz_Title,
             ac.component_name, ac.component_type, ac.max_marks, ac.weightage,
             acs.Schedule_ID, acs.Assessment_Date, acs.Start_Time, NULL AS End_Time,
             acs.Duration_Minutes, acs.Instructions,
             COALESCE(acs.Is_Hidden, 0) AS Is_Hidden
      FROM Assessments a
      JOIN Assessment_Components ac ON ac.component_id = a.Component_ID
      LEFT JOIN Assessment_Schedules acs ON acs.Assessment_ID = a.Assessment_ID
      WHERE a.Section_ID = ?
        AND acs.Schedule_ID IS NOT NULL
        $hiddenFilter
      ORDER BY date(acs.Assessment_Date) DESC, acs.Start_Time DESC, a.Assessment_ID DESC
    ''', [int.tryParse(sectionId) ?? sectionId]);
  }

  Future<int> _quizComponentId(dynamic db) async {
    final existing = await db.rawQuery('''
      SELECT component_id
      FROM Assessment_Components
      WHERE UPPER(component_name) = 'QUIZ'
      ORDER BY component_id ASC
      LIMIT 1
    ''');
    if (existing.isNotEmpty) {
      return int.tryParse(existing.first['component_id'].toString()) ?? 1;
    }
    return await db.rawInsert('''
      INSERT INTO Assessment_Components
        (component_name, component_type, weightage, max_marks)
      VALUES ('QUIZ', 'QUIZ', ?, ?)
    ''', [0, 0]);
  }

  Future<int> insertAssessment({
    required String sectionId,
    required String title,
    required String date,
    required String startTime,
    required int durationMinutes,
    required String instructions,
  }) async {
    final db = await instance.database;
    await _ensureAssessmentTables(db);
    return await db.transaction<int>((txn) async {
      final componentId = await _quizComponentId(txn);
      final assessmentId = await txn.rawInsert('''
        INSERT INTO Assessments (Section_ID, Component_ID)
        VALUES (?, ?)
      ''', [int.tryParse(sectionId) ?? sectionId, componentId]);
      await txn.rawInsert('''
        INSERT INTO Assessment_Schedules
          (Assessment_ID, Assessment_Date, Start_Time,
           Quiz_Title, Duration_Minutes, Instructions, Is_Hidden)
        VALUES (?, ?, ?, ?, ?, ?, 0)
      ''', [
        assessmentId,
        date,
        startTime,
        title,
        durationMinutes,
        instructions,
      ]);
      await txn.rawInsert('''
        INSERT INTO Assessment_Enrollments
          (Assessment_ID, Student_ID, Marks)
        SELECT ?, ce.Student_ID, 0
        FROM Courses_Enrollments ce
        WHERE ce.Section_ID = ?
      ''', [assessmentId, int.tryParse(sectionId) ?? sectionId]);
      return assessmentId;
    });
  }

  Future<int> updateAssessment({
    required String assessmentId,
    required String title,
    required String date,
    required String startTime,
    required int durationMinutes,
    required String instructions,
  }) async {
    final db = await instance.database;
    await _ensureAssessmentTables(db);
    return await db.rawUpdate('''
      UPDATE Assessment_Schedules
      SET Assessment_Date = ?,
          Start_Time = ?,
          Quiz_Title = ?,
          Duration_Minutes = ?,
          Instructions = ?
      WHERE Assessment_ID = ?
    ''', [
      date,
      startTime,
      title,
      durationMinutes,
      instructions,
      int.tryParse(assessmentId) ?? assessmentId,
    ]);
  }

  Future<int> deleteAssessment(String assessmentId) async {
    final db = await instance.database;
    await _ensureAssessmentTables(db);
    return await db.transaction<int>((txn) async {
      await txn.rawDelete(
        'DELETE FROM Assessment_Schedules WHERE Assessment_ID = ?',
        [int.tryParse(assessmentId) ?? assessmentId],
      );
      await txn.rawDelete(
        'DELETE FROM Assessment_Enrollments WHERE Assessment_ID = ?',
        [int.tryParse(assessmentId) ?? assessmentId],
      );
      return await txn.rawDelete(
        'DELETE FROM Assessments WHERE Assessment_ID = ?',
        [int.tryParse(assessmentId) ?? assessmentId],
      );
    });
  }

  Future<int> updateAssessmentHidden({
    required String assessmentId,
    required bool isHidden,
  }) async {
    final db = await instance.database;
    await _ensureAssessmentTables(db);
    return await db.rawUpdate('''
      UPDATE Assessment_Schedules
      SET Is_Hidden = ?
      WHERE Assessment_ID = ?
    ''', [
      isHidden ? 1 : 0,
      int.tryParse(assessmentId) ?? assessmentId,
    ]);
  }

  Future<List<Map<String, dynamic>>> getMarksForSection(
      String sectionId) async {
    final db = await instance.database;
    await _ensureAssessmentTables(db);
    await db.rawInsert('''
      INSERT INTO Assessments (Section_ID, Component_ID)
      SELECT ?, ac.component_id
      FROM Assessment_Components ac
      WHERE NOT EXISTS (
        SELECT 1
        FROM Assessments a
        LEFT JOIN Assessment_Schedules acs
          ON acs.Assessment_ID = a.Assessment_ID
        WHERE a.Section_ID = ?
          AND a.Component_ID = ac.component_id
          AND acs.Schedule_ID IS NULL
      )
    ''', [
      int.tryParse(sectionId) ?? sectionId,
      int.tryParse(sectionId) ?? sectionId,
    ]);
    final assessments = await db.rawQuery('''
      SELECT a.Assessment_ID
      FROM Assessments a
      LEFT JOIN Assessment_Schedules acs ON acs.Assessment_ID = a.Assessment_ID
      WHERE a.Section_ID = ?
        AND acs.Schedule_ID IS NULL
    ''', [int.tryParse(sectionId) ?? sectionId]);
    for (final assessment in assessments) {
      await db.rawInsert('''
        INSERT INTO Assessment_Enrollments
          (Assessment_ID, Student_ID, Marks)
        SELECT ?, ce.Student_ID, 0
        FROM Courses_Enrollments ce
        WHERE ce.Section_ID = ?
          AND NOT EXISTS (
            SELECT 1
            FROM Assessment_Enrollments ae
            WHERE ae.Assessment_ID = ?
              AND ae.Student_ID = ce.Student_ID
          )
      ''', [
        assessment['Assessment_ID'],
        int.tryParse(sectionId) ?? sectionId,
        assessment['Assessment_ID'],
      ]);
    }
    return await db.rawQuery('''
      SELECT ce.Student_ID, COALESCE(u.Name, ce.Student_ID) AS Student_Name,
             a.Assessment_ID, ac.component_name, ac.max_marks, ac.weightage,
             ac.component_name AS Assessment_Title,
             ae.Assessment_Enrollment_ID, COALESCE(ae.Marks, 0) AS Marks
      FROM Courses_Enrollments ce
      JOIN Assessments a ON a.Section_ID = ce.Section_ID
      LEFT JOIN Assessment_Schedules acs ON acs.Assessment_ID = a.Assessment_ID
      JOIN Assessment_Components ac ON ac.component_id = a.Component_ID
      LEFT JOIN Assessment_Enrollments ae
        ON ae.Assessment_ID = a.Assessment_ID AND ae.Student_ID = ce.Student_ID
      LEFT JOIN Users u ON u.User_ID = ce.Student_ID
      WHERE ce.Section_ID = ?
        AND acs.Schedule_ID IS NULL
      ORDER BY u.Name ASC, ce.Student_ID ASC, a.Assessment_ID ASC
    ''', [int.tryParse(sectionId) ?? sectionId]);
  }

  Future<int> upsertAssessmentMark({
    required String assessmentId,
    required String studentId,
    required double marks,
  }) async {
    final db = await instance.database;
    await _ensureAssessmentTables(db);
    final updated = await db.rawUpdate('''
      UPDATE Assessment_Enrollments
      SET Marks = ?
      WHERE Assessment_ID = ? AND Student_ID = ?
    ''', [marks, int.tryParse(assessmentId) ?? assessmentId, studentId]);
    if (updated > 0) return updated;
    return await db.rawInsert('''
      INSERT INTO Assessment_Enrollments (Assessment_ID, Student_ID, Marks)
      VALUES (?, ?, ?)
    ''', [int.tryParse(assessmentId) ?? assessmentId, studentId, marks]);
  }

  Future<int> insertPastYearQuestion(String courseId, String title,
      String session, Uint8List fileBytes) async {
    final db = await instance.database;
    return await db.insert('Past_Year_Questions', {
      'Course_ID': courseId,
      'Title': title,
      'Session': session,
      'URL': fileBytes,
    });
  }

  Future<void> _ensureReminderTables(dynamic db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Reminder_Statuses (
        Reminder_Status_ID INTEGER PRIMARY KEY,
        Reminder_Status TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Reminders (
        Reminder_ID INTEGER PRIMARY KEY AUTOINCREMENT,
        User_ID TEXT,
        Reminder_Status_ID INTEGER,
        Title TEXT,
        Comment TEXT,
        Due_Date DATETIME
      )
    ''');
    final columns = await db.rawQuery('PRAGMA table_info(Reminders)');
    final names = columns
        .map((column) => column['name']?.toString().toLowerCase())
        .whereType<String>()
        .toSet();
    final extras = <String, String>{
      'source_type': 'Source_Type TEXT',
      'source_id': 'Source_ID TEXT',
      'section_id': 'Section_ID INTEGER',
      'is_system': 'Is_System INTEGER DEFAULT 0',
    };
    for (final entry in extras.entries) {
      if (!names.contains(entry.key)) {
        await db.execute('ALTER TABLE Reminders ADD COLUMN ${entry.value}');
      }
    }
    await db.rawInsert('''
      INSERT OR IGNORE INTO Reminder_Statuses
        (Reminder_Status_ID, Reminder_Status)
      VALUES
        (1, 'In progress'),
        (2, 'Completed'),
        (3, 'Late')
    ''');
  }

  Future<void> syncStudentLinkedReminders(String studentId) async {
    final db = await instance.database;
    await _ensureReminderTables(db);
    await _ensureAssessmentTables(db);
    await db.rawInsert('''
      INSERT INTO Reminders
        (User_ID, Reminder_Status_ID, Title, Comment, Due_Date,
         Source_Type, Source_ID, Section_ID, Is_System)
      SELECT ?, 1, a.Assignment_Title,
             CASE
               WHEN a.Assignment_Type_ID = 1 THEN 'Individual Activity'
               ELSE 'Group Activity'
             END,
             (a.Due_Date || ' ' || COALESCE(a.Due_Time, '11:59 PM')),
             'assignment',
             CAST(a.Assignment_ID AS TEXT),
             a.Section_ID,
             1
      FROM Assignments a
      JOIN Courses_Enrollments ce ON ce.Section_ID = a.Section_ID
      JOIN Sections s ON s.Section_ID = a.Section_ID
      WHERE ce.Student_ID = ?
        AND s.Academic_Session = '2025/2026'
        AND s.Semester = 2
        AND NOT EXISTS (
          SELECT 1
          FROM Reminders r
          WHERE r.User_ID = ?
            AND r.Source_Type = 'assignment'
            AND r.Source_ID = CAST(a.Assignment_ID AS TEXT)
        )
    ''', [studentId, studentId, studentId]);
    await db.rawInsert('''
      INSERT INTO Reminders
        (User_ID, Reminder_Status_ID, Title, Comment, Due_Date,
         Source_Type, Source_ID, Section_ID, Is_System)
      SELECT ?, 1, COALESCE(acs.Quiz_Title, ac.component_name, 'Quiz'),
             'Assessment',
             (acs.Assessment_Date || ' ' || acs.Start_Time),
             'assessment',
             CAST(ass.Assessment_ID AS TEXT),
             ass.Section_ID,
             1
      FROM Assessments ass
      JOIN Assessment_Schedules acs ON acs.Assessment_ID = ass.Assessment_ID
      JOIN Assessment_Components ac ON ac.component_id = ass.Component_ID
      JOIN Courses_Enrollments ce ON ce.Section_ID = ass.Section_ID
      JOIN Sections s ON s.Section_ID = ass.Section_ID
      WHERE ce.Student_ID = ?
        AND COALESCE(acs.Is_Hidden, 0) = 0
        AND s.Academic_Session = '2025/2026'
        AND s.Semester = 2
        AND NOT EXISTS (
          SELECT 1
          FROM Reminders r
          WHERE r.User_ID = ?
            AND r.Source_Type = 'assessment'
            AND r.Source_ID = CAST(ass.Assessment_ID AS TEXT)
        )
    ''', [studentId, studentId, studentId]);
  }

  Future<List<Map<String, dynamic>>> getUserReminders(
    String userId, {
    bool includeStudentLinked = false,
  }) async {
    final db = await instance.database;
    await _ensureReminderTables(db);
    if (includeStudentLinked) {
      await syncStudentLinkedReminders(userId);
    }
    final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    await db.rawUpdate('''
      UPDATE Reminders
      SET Reminder_Status_ID = 3
      WHERE User_ID = ?
        AND Reminder_Status_ID != 2
        AND datetime(Due_Date) < datetime(?)
    ''', [userId, now]);
    return await db.rawQuery('''
      SELECT r.Reminder_ID, r.User_ID, r.Reminder_Status_ID,
             COALESCE(rs.Reminder_Status, 'In progress') AS Reminder_Status,
             r.Title, r.Comment, r.Due_Date,
             COALESCE(r.Source_Type, 'custom') AS Source_Type,
             r.Source_ID,
             r.Section_ID,
             CASE WHEN COALESCE(r.Is_System, 0) = 1 THEN 0 ELSE 1 END AS Is_Custom
      FROM Reminders r
      LEFT JOIN Reminder_Statuses rs
        ON rs.Reminder_Status_ID = r.Reminder_Status_ID
      WHERE r.User_ID = ?
      ORDER BY datetime(r.Due_Date) ASC
    ''', [userId]);
  }

  Future<List<Map<String, dynamic>>> getStudentLinkedDueDates(
      String studentId) async {
    final db = await instance.database;
    await _ensureAssessmentTables(db);
    return await db.rawQuery('''
      SELECT a.Assignment_ID AS Source_ID,
             a.Section_ID,
             a.Assignment_Title AS Title,
             CASE
               WHEN a.Assignment_Type_ID = 1 THEN 'Individual Activity'
               ELSE 'Group Activity'
             END AS Comment,
             (a.Due_Date || ' ' || COALESCE(a.Due_Time, '11:59 PM')) AS Due_Date,
             'assignment' AS Source_Type,
             0 AS Is_Custom
      FROM Assignments a
      JOIN Courses_Enrollments ce ON ce.Section_ID = a.Section_ID
      JOIN Sections s ON s.Section_ID = a.Section_ID
      WHERE ce.Student_ID = ?
        AND s.Academic_Session = '2025/2026'
        AND s.Semester = 2
      UNION ALL
      SELECT ass.Assessment_ID AS Source_ID,
             ass.Section_ID,
             COALESCE(acs.Quiz_Title, ac.component_name, 'Quiz') AS Title,
             'Assessment' AS Comment,
             (acs.Assessment_Date || ' ' || acs.Start_Time) AS Due_Date,
             'assessment' AS Source_Type,
             0 AS Is_Custom
      FROM Assessments ass
      JOIN Assessment_Schedules acs ON acs.Assessment_ID = ass.Assessment_ID
      JOIN Assessment_Components ac ON ac.component_id = ass.Component_ID
      JOIN Courses_Enrollments ce ON ce.Section_ID = ass.Section_ID
      JOIN Sections s ON s.Section_ID = ass.Section_ID
      WHERE ce.Student_ID = ?
        AND COALESCE(acs.Is_Hidden, 0) = 0
        AND s.Academic_Session = '2025/2026'
        AND s.Semester = 2
      ORDER BY datetime(Due_Date) ASC
    ''', [studentId, studentId]);
  }

  Future<int> insertReminder({
    required String userId,
    required String title,
    required String comment,
    required String dueDate,
  }) async {
    final db = await instance.database;
    await _ensureReminderTables(db);
    return await db.rawInsert('''
      INSERT INTO Reminders
        (User_ID, Reminder_Status_ID, Title, Comment, Due_Date)
      VALUES (?, 1, ?, ?, ?)
    ''', [userId, title, comment, dueDate]);
  }

  Future<int> updateReminder({
    required String reminderId,
    required String title,
    required String comment,
    required String dueDate,
  }) async {
    final db = await instance.database;
    await _ensureReminderTables(db);
    final due = DateTime.tryParse(dueDate);
    final status = due != null && due.isBefore(DateTime.now()) ? 3 : 1;
    return await db.rawUpdate('''
      UPDATE Reminders
      SET Title = ?,
          Comment = ?,
          Due_Date = ?,
          Reminder_Status_ID = CASE
            WHEN Reminder_Status_ID = 2 THEN 2
            ELSE ?
          END
      WHERE Reminder_ID = ?
    ''', [
      title,
      comment,
      dueDate,
      status,
      int.tryParse(reminderId) ?? reminderId
    ]);
  }

  Future<int> updateReminderStatus({
    required String reminderId,
    required bool completed,
  }) async {
    final db = await instance.database;
    await _ensureReminderTables(db);
    return await db.rawUpdate('''
      UPDATE Reminders
      SET Reminder_Status_ID = ?
      WHERE Reminder_ID = ?
    ''', [completed ? 2 : 1, int.tryParse(reminderId) ?? reminderId]);
  }

  Future<int> deleteReminder(String reminderId) async {
    final db = await instance.database;
    await _ensureReminderTables(db);
    return await db.rawDelete(
      'DELETE FROM Reminders WHERE Reminder_ID = ?',
      [int.tryParse(reminderId) ?? reminderId],
    );
  }
}

class _ZipFileEntry {
  final String name;
  final List<int> bytes;

  const _ZipFileEntry(this.name, this.bytes);
}
