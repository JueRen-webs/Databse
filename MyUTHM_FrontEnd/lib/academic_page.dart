import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'academic/academic_class_page.dart';
import 'database_helper.dart';

const Color kPrimaryBlue = Color(0xFF0422A7);
const Color kAccentBlue = Color(0xFF006BFF);
const Color kBackgroundColor = Color(0xFFF5F8FE);
const Color kTextDark = Color(0xFF071A52);

class AcademicPage extends StatefulWidget {
  final String studentId;

  const AcademicPage({super.key, this.studentId = ""});

  @override
  State<AcademicPage> createState() => _AcademicPageState();
}

class _AcademicPageState extends State<AcademicPage> {
  late PageController _semesterController;
  int _currentSemesterIndex = 0;
  bool _isLoading = true;

  List<Map<String, String>> _semesters = [];
  List<List<Map<String, dynamic>>> _coursesBySemester = [];

  @override
  void initState() {
    super.initState();
    _semesterController = PageController(
      viewportFraction: 0.78,
      initialPage: 0,
    );
    _semesterController.addListener(_handleSemesterScroll);
    _loadDataFromDatabase();
  }

  String _convertToLetterGrade(dynamic gradeValue) {
    if (gradeValue == null) return "-";

    double? marks = double.tryParse(gradeValue.toString());
    if (marks == null) return "-";

    if (marks >= 80) return 'A';
    if (marks >= 75) return 'A-';
    if (marks >= 70) return 'B+';
    if (marks >= 65) return 'B';
    if (marks >= 60) return 'B-';
    if (marks >= 55) return 'C+';
    if (marks >= 50) return 'C';
    return 'F';
  }

  double _convertToGradePoint(dynamic gradeValue) {
    if (gradeValue == null) return -1.0;

    double? marks = double.tryParse(gradeValue.toString());
    if (marks == null) return -1.0;

    if (marks >= 80) return 4.00;
    if (marks >= 75) return 3.67;
    if (marks >= 70) return 3.33;
    if (marks >= 65) return 3.00;
    if (marks >= 60) return 2.67;
    if (marks >= 55) return 2.33;
    if (marks >= 50) return 2.00;
    return 0.00;
  }

  Future<void> _loadDataFromDatabase() async {
    try {
      final db = await DatabaseHelper.instance.database;

      String currentStudentId = DatabaseHelper.currentUserId.isNotEmpty
          ? DatabaseHelper.currentUserId
          : widget.studentId;

      if (currentStudentId.isEmpty) {
        debugPrint("Error: No user logged in.");
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      await DatabaseHelper.instance.ensureAttendanceTablesForApp();
      await DatabaseHelper.instance.ensureAssessmentTablesForApp();

      final List<Map<String, dynamic>> userCheck = await db.rawQuery(
          'SELECT Role FROM Users WHERE User_ID = ?', [currentStudentId]);

      if (userCheck.isEmpty || userCheck.first['Role'] != 'Student') {
        debugPrint("Access Denied: User role is not Student.");
        if (mounted) {
          setState(() {
            _isLoading = false;
            _semesters = [];
            _coursesBySemester = [];
          });
        }
        return;
      }

      final List<Map<String, dynamic>> result = await db.rawQuery('''
        SELECT
            s.Academic_Session,
            s.Semester,
            s.Section_ID,
            c.Course_ID,
            c.Course_Name,
            c.Course_Credits,
            COALESCE(calc.Calculated_Grade, r.Final_Grade) AS Final_Grade,
            u_lec.Name AS Lecturer_Name,
            CASE
              WHEN COALESCE(att.Total_Sessions, 0) = 0 THEN 0
              ELSE ROUND((att.Present_Count * 100.0) / att.Total_Sessions)
            END AS Attendance_Percent
        FROM Courses_Enrollments ce
        JOIN Sections s ON ce.Section_ID = s.Section_ID
        JOIN Courses c ON s.Course_ID = c.Course_ID
        LEFT JOIN Users u_lec ON s.Lecturer_ID = u_lec.User_ID
        LEFT JOIN Results r ON ce.Course_Enrollment_ID = r.Course_Enrollment_ID
        LEFT JOIN (
          SELECT
            ce2.Student_ID,
            ce2.Section_ID,
            SUM(
              CASE
                WHEN ac.max_marks > 0
                THEN (COALESCE(ae.Marks, 0) * 1.0 / ac.max_marks) * ac.weightage
                ELSE 0
              END
            ) AS Calculated_Grade,
            SUM(COALESCE(ae.Marks, 0)) AS Total_Marks
          FROM Courses_Enrollments ce2
          JOIN Assessments a ON a.Section_ID = ce2.Section_ID
          LEFT JOIN Assessment_Schedules acs ON acs.Assessment_ID = a.Assessment_ID
          JOIN Assessment_Components ac ON ac.component_id = a.Component_ID
          LEFT JOIN Assessment_Enrollments ae
            ON ae.Assessment_ID = a.Assessment_ID
           AND ae.Student_ID = ce2.Student_ID
          WHERE acs.Schedule_ID IS NULL
          GROUP BY ce2.Student_ID, ce2.Section_ID
          HAVING Total_Marks > 0
        ) calc ON calc.Section_ID = s.Section_ID
              AND calc.Student_ID = ce.Student_ID
        LEFT JOIN (
          SELECT
            ss.Section_ID,
            ca.Student_ID,
            COUNT(ca.Attendance_ID) AS Total_Sessions,
            SUM(CASE WHEN ca.Attendance_Status = 'Present' THEN 1 ELSE 0 END) AS Present_Count
          FROM Course_Attendances ca
          JOIN Attendance_Sessions ats ON ca.Session_ID = ats.Session_ID
          JOIN Section_Schedules ss ON ats.Schedule_ID = ss.Schedule_ID
          GROUP BY ss.Section_ID, ca.Student_ID
        ) att ON att.Section_ID = s.Section_ID AND att.Student_ID = ce.Student_ID
        WHERE ce.Student_ID = ?
        ORDER BY s.Academic_Session ASC, s.Semester ASC
      ''', [currentStudentId]);

      Map<String, List<Map<String, dynamic>>> groupedData = {};

      for (var row in result) {
        String groupKey = "${row['Academic_Session']} S${row['Semester']}";

        if (!groupedData.containsKey(groupKey)) {
          groupedData[groupKey] = [];
        }

        groupedData[groupKey]!.add({
          "code": row['Course_ID']?.toString() ?? "N/A",
          "section_id": row['Section_ID']?.toString() ?? "",
          "name": row['Course_Name']?.toString() ?? "Unknown",
          "lecturer": row['Lecturer_Name']?.toString() ?? "TBA",
          "grade": _convertToLetterGrade(row['Final_Grade']),
          "attendance": "${row['Attendance_Percent']?.toString() ?? '0'}%",
          "credits":
              int.tryParse(row['Course_Credits']?.toString() ?? "0") ?? 0,
          "raw_grade": row['Final_Grade'],
        });
      }

      List<Map<String, String>> tempSemesters = [];
      List<List<Map<String, dynamic>>> tempCourses = [];

      int index = 1;
      groupedData.forEach((key, coursesList) {
        bool isCurrent = coursesList.any((c) => c['grade'] == "-");

        int totalCredits = 0;
        int gradedCredits = 0;
        double totalQualityPoints = 0.0;

        for (var course in coursesList) {
          int credits = course['credits'] as int;
          totalCredits += credits;

          double gp = _convertToGradePoint(course['raw_grade']);
          if (gp >= 0) {
            gradedCredits += credits;
            totalQualityPoints += (gp * credits);
          }
        }

        String cpaString = "-";
        if (gradedCredits > 0) {
          cpaString = (totalQualityPoints / gradedCredits).toStringAsFixed(2);
        }

        tempSemesters.add({
          "title": "Semester $index",
          "status": isCurrent ? "Current Semester" : "Past Semester",
          "cpa": cpaString,
          "classes": coursesList.length.toString(),
          "credits": totalCredits.toString(),
        });
        tempCourses.add(coursesList);
        index++;
      });

      if (tempSemesters.isEmpty) {
        tempSemesters.add({
          "title": "Semester 1",
          "status": "Current Semester",
          "cpa": "-",
          "classes": "0",
          "credits": "0",
        });
        tempCourses.add([]);
      }

      if (mounted) {
        setState(() {
          _semesters = tempSemesters;
          _coursesBySemester = tempCourses;
          _currentSemesterIndex = _semesters.length - 1;
          _isLoading = false;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_semesterController.hasClients && _semesters.isNotEmpty) {
            _semesterController.jumpToPage(_currentSemesterIndex);
          }
        });
      }
    } catch (e) {
      debugPrint("Database Load Error: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _semesterController.removeListener(_handleSemesterScroll);
    _semesterController.dispose();
    super.dispose();
  }

  void _handleSemesterScroll() {
    if (!_semesterController.hasClients ||
        !_semesterController.position.haveDimensions) {
      return;
    }
    if (_semesters.isEmpty) {
      return;
    }

    int maxBound = _semesters.isEmpty ? 0 : _semesters.length - 1;
    final nextIndex = (_semesterController.page ?? _currentSemesterIndex)
        .round()
        .clamp(0, maxBound);

    if (nextIndex != _currentSemesterIndex) {
      setState(() {
        _currentSemesterIndex = nextIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          "Academic Online Resources",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kPrimaryBlue))
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    final currentCourses = (_currentSemesterIndex >= 0 &&
            _currentSemesterIndex < _coursesBySemester.length)
        ? _coursesBySemester[_currentSemesterIndex]
        : [];

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 10, bottom: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSemesterCarousel(),
          const SizedBox(height: 14),
          _buildDots(),
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Stack(
              children: [
                Text(
                  "My Classes",
                  style: GoogleFonts.poppins(
                    color: kTextDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (currentCourses.isEmpty)
            _buildEmptyClasses()
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: currentCourses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _buildCourseCard(currentCourses[index]);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSemesterCarousel() {
    return SizedBox(
      height: 310,
      child: PageView.builder(
        clipBehavior: Clip.none,
        controller: _semesterController,
        physics: const BouncingScrollPhysics(),
        itemCount: _semesters.length,
        onPageChanged: (index) {
          setState(() => _currentSemesterIndex = index);
        },
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _semesterController,
            builder: (context, child) {
              double scale = 1.0;
              int selectedIndex = _currentSemesterIndex;

              if (_semesterController.position.haveDimensions) {
                final page = _semesterController.page ?? _currentSemesterIndex;
                scale = (1 - ((page - index).abs() * 0.05)).clamp(0.94, 1.0);

                int maxBound = _semesters.isEmpty ? 0 : _semesters.length - 1;
                selectedIndex = page.round().clamp(0, maxBound);
              }

              return Transform.scale(
                scale: scale,
                child: _buildSemesterCard(
                  _semesters[index],
                  isSelected: index == selectedIndex,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSemesterCard(
    Map<String, String> semester, {
    required bool isSelected,
  }) {
    final bool isCurrent = semester["status"] == "Current Semester";

    return Container(
      margin: const EdgeInsets.only(
        left: 8,
        right: 8,
        top: 10,
        bottom: 24,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isSelected ? kAccentBlue : const Color(0xFFE8EEF8),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.school_outlined,
                color: kPrimaryBlue,
                size: 32,
              ),
              const SizedBox(width: 12),
              if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF3FF),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    "Current",
                    style: GoogleFonts.poppins(
                      color: kPrimaryBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            semester["title"]!,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: kPrimaryBlue,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isCurrent
                ? "Keep going, you're doing great!✨ "
                : "You Have Done Well, Good Job!",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF46537A),
            ),
          ),
          const Spacer(),
          Divider(
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _simpleInfo(
                "Current CPA",
                semester["cpa"]!,
              ),
              _verticalDivider(),
              _simpleInfo(
                "Classes",
                semester["classes"]!,
              ),
              _verticalDivider(),
              _simpleInfo(
                "Credits",
                semester["credits"]!,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_semesters.length, (index) {
        final isActive = index == _currentSemesterIndex;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 7),
          width: isActive ? 9 : 7,
          height: isActive ? 9 : 7,
          decoration: BoxDecoration(
            color: isActive ? kPrimaryBlue : const Color(0xFFC7D8F3),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  Widget _buildEmptyClasses() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8EEF8)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.menu_book_outlined,
            color: Colors.grey.shade400,
            size: 36,
          ),
          const SizedBox(height: 12),
          Text(
            "No classes for this semester",
            style: GoogleFonts.poppins(
              color: const Color(0xFF7A859F),
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AcademicClassPage(
              isLecturer: false,
              courseData: Map<String, String>.from(
                course.map((key, value) => MapEntry(key, value.toString())),
              ),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course["name"],
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: kTextDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course["lecturer"],
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF7A859F),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Attendance",
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      color: const Color(0xFF7A859F),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    course["attendance"],
                    style: GoogleFonts.poppins(
                      color: kPrimaryBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              height: 38,
              margin: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              color: Colors.grey.shade300,
            ),
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Grade",
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      color: const Color(0xFF7A859F),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    course["grade"],
                    style: GoogleFonts.poppins(
                      color: kPrimaryBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _simpleInfo(
    String title,
    String value,
  ) {
    return Column(
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: const Color(0xFF7A859F),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: kPrimaryBlue,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 42,
      color: Colors.grey.shade300,
    );
  }
}
