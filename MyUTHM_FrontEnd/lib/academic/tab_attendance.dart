import 'package:flutter/material.dart';


import 'package:uthm/academic/lecturer_student_attendance_page.dart';
import 'package:uthm/academic/student_course_attendance_page.dart';

class AttendanceTab extends StatelessWidget {
  const AttendanceTab({
    super.key,
    this.isLecturer = true,
    this.courseData = const {},
  });

  final bool isLecturer;
  final Map<String, String> courseData;

  @override
  Widget build(BuildContext context) {
    if (isLecturer) {
      return StudentAttendanceContent(courseData: courseData);
    }

    return StudentCourseAttendancePage(
      showChrome: false,
      courseData: courseData,
    );
  }
}
