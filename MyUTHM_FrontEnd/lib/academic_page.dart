import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'academic_class.dart';
import 'database_helper.dart'; // 引入你的 DatabaseHelper 单例

const Color kPrimaryBlue = Color(0xFF0422A7);
const Color kAccentBlue = Color(0xFF006BFF);
const Color kBackgroundColor = Color(0xFFF5F8FE);
const Color kTextDark = Color(0xFF071A52);

class AcademicPage extends StatefulWidget {
  final String studentId;
  // ✅ 修复 1：完成对 final 变量的初始化赋空初值。不仅消除了编译错误，还能完美兼容你其他页面带参或无参的路由跳转！
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

  // 根据分数百分比判定字母等级
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

  // 根据分数百分比转换单科绩点 (Grade Point) 用作 CPA 计算
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

      // ✅ 修复 2：全面动态获取。优先读取你登录成功后写入单例的全局当前用户 ID
      String currentStudentId = DatabaseHelper.currentUserId.isNotEmpty
          ? DatabaseHelper.currentUserId
          : widget.studentId;

      if (currentStudentId.isEmpty) {
        debugPrint("Error: No user logged in.");
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      // ✅ 身份校验安全线：去 Users 表里检查当前登录账号的角色是不是 Student
      final List<Map<String, dynamic>> userCheck = await db.rawQuery(
          'SELECT Role FROM Users WHERE User_ID = ?',
          [currentStudentId]
      );

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
            c.Course_ID,
            c.Course_Name,
            c.Course_Credits,
            r.Final_Grade,
            u_lec.Name AS Lecturer_Name
        FROM Courses_Enrollments ce
        JOIN Sections s ON ce.Section_ID = s.Section_ID
        JOIN Courses c ON s.Course_ID = c.Course_ID
        LEFT JOIN Users u_lec ON s.Lecturer_ID = u_lec.User_ID
        LEFT JOIN Results r ON ce.Course_Enrollment_ID = r.Course_Enrollment_ID
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
          "name": row['Course_Name']?.toString() ?? "Unknown",
          "lecturer": row['Lecturer_Name']?.toString() ?? "TBA",
          "grade": _convertToLetterGrade(row['Final_Grade']),
          "attendance": "100%",
          "credits": int.tryParse(row['Course_Credits']?.toString() ?? "0") ?? 0,
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
    if (!_semesterController.hasClients || !_semesterController.position.haveDimensions) return;
    if (_semesters.isEmpty) return;

    int maxBound = _semesters.isEmpty ? 0 : _semesters.length - 1;
    final nextIndex = (_semesterController.page ?? _currentSemesterIndex).round().clamp(0, maxBound);

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
    final currentCourses = (_currentSemesterIndex >= 0 && _currentSemesterIndex < _coursesBySemester.length)
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
          // ✅ 动态标语：已经过了的学期自动替换为你指定的赞美文本
          Text(
            isCurrent ? "Keep going, you're doing great!✨ " : "You Have Done Well, Good Job!",
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

  Widget _buildCourseCard(
      Map<String, dynamic> course,
      ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AcademicClassPage(
              courseData: Map<String, String>.from(
                course.map(
                      (key, value) => MapEntry(key, value.toString()),
                ),
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
          crossAxisAlignment: CrossAxisAlignment.center, // 横向所有模块垂直中心线绝对对齐
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
            // ✅ 视觉修复方案：移除高度硬限制，使用统一样式的 Column 容器。
            // 当两边的字号（Header都是11，Value都是15）和结构完全镜像对称时，
            // 它们在 CrossAxisAlignment.center 的拉伸下，天生就会在物理上完美对齐！
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
              height: 38, // 柔和的垂直分割线高度
              margin: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              color: Colors.grey.shade300,
            ),
            // ✅ 镜像对称：Grade 列与 Attendance 列使用 100% 相同的数据布局和尺寸缩放
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