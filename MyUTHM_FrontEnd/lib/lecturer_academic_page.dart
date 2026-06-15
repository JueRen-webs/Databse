import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'academic/academic_class_page.dart';
import 'database_helper.dart';

const Color kPrimaryBlue = Color(0xFF0422A7);
const Color kAccentBlue = Color(0xFF006BFF);
const Color kBackgroundColor = Color(0xFFF5F8FE);
const Color kTextDark = Color(0xFF071A52);

class LecturerAcademicPage extends StatefulWidget {
  const LecturerAcademicPage({super.key});

  @override
  State<LecturerAcademicPage> createState() => _LecturerAcademicPageState();
}

class _LecturerAcademicPageState extends State<LecturerAcademicPage> {
  PageController? _semesterController;
  int _currentSemesterIndex = 0;
  bool _isLoading = true;


  List<Map<String, String>> _lecturerSemesters = [];
  List<List<Map<String, dynamic>>> _lecturerCoursesBySemester = [];

  @override
  void initState() {
    super.initState();
    _loadLecturerData();
  }

  Future<void> _loadLecturerData() async {
    final db = DatabaseHelper.instance;
    final userId = DatabaseHelper.currentUserId;


    final semestersData = await db.getLecturerSemesters(userId);

    List<Map<String, String>> tempSemesters = [];
    List<List<Map<String, dynamic>>> tempCourses = [];

    for (var sem in semestersData) {
      String session = sem['Academic_Session'].toString();
      int semesterNum = int.parse(sem['Semester'].toString());
      int courses = int.parse(sem['Total_Courses'].toString());
      int students = int.parse(sem['Total_Students'].toString());


      String status = "Past Semester";
      if (session == "2025/2026" && semesterNum == 2) {
        status = "Current Semester";
      } else if (session.compareTo("2025/2026") > 0 ||
          (session == "2025/2026" && semesterNum > 2)) {
        status = "Next Semester";
      }

      String title = "$session Sem $semesterNum";

      tempSemesters.add({
        "title": title,
        "status": status,
        "courses": courses.toString(),
        "students": students.toString(),
        "materials": sem['Total_Materials'].toString(),
      });


      final coursesData =
          await db.getLecturerCoursesBySemester(userId, session, semesterNum);

      List<Map<String, dynamic>> formattedCourses = coursesData.map((c) {
        return {
          "code": c['code'].toString(),
          "section_id": c['section_id'].toString(),
          "name": c['name'].toString(),
          "lecturer": "",
          "section": c['section'].toString(),
          "students": c['students'].toString(),
        };
      }).toList();

      tempCourses.add(formattedCourses);
    }


    if (mounted) {
      setState(() {
        _lecturerSemesters = tempSemesters;
        _lecturerCoursesBySemester = tempCourses;


        _currentSemesterIndex = _lecturerSemesters
            .indexWhere((s) => s['status'] == "Current Semester");
        if (_currentSemesterIndex == -1) {

          _currentSemesterIndex =
              _lecturerSemesters.isNotEmpty ? _lecturerSemesters.length - 1 : 0;
        }

        if (_lecturerSemesters.isNotEmpty) {
          _semesterController = PageController(
            viewportFraction: 0.78,
            initialPage: _currentSemesterIndex,
          );
          _semesterController!.addListener(_handleSemesterScroll);
        }

        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    if (_semesterController != null) {
      _semesterController!.removeListener(_handleSemesterScroll);
      _semesterController!.dispose();
    }
    super.dispose();
  }

  void _handleSemesterScroll() {
    if (_semesterController == null ||
        !_semesterController!.hasClients ||
        !_semesterController!.position.haveDimensions) {
      return;
    }

    final nextIndex =
        (_semesterController!.page ?? _currentSemesterIndex.toDouble())
            .round()
            .clamp(0, _lecturerSemesters.length - 1);

    if (nextIndex != _currentSemesterIndex) {
      setState(() => _currentSemesterIndex = nextIndex);
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
            fontSize: 18,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: kPrimaryBlue))
          : _lecturerSemesters.isEmpty
              ? _buildEmptyState()
              : _buildBody(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_off_outlined,
              size: 60, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            "No academic records found.",
            style: GoogleFonts.poppins(
                color: const Color(0xFF7A859F), fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final currentCourses = _lecturerCoursesBySemester[_currentSemesterIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 18, bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSemesterCarousel(),
          const SizedBox(height: 14),
          _buildDots(),
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              "My Classes",
              style: GoogleFonts.poppins(
                color: kTextDark,
                fontWeight: FontWeight.w700,
                fontSize: 22,
              ),
            ),
          ),
          const SizedBox(height: 18),
          if (currentCourses.isEmpty)
            _buildEmptyClasses()
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 30),
              itemCount: currentCourses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 18),
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
        controller: _semesterController,
        physics: const BouncingScrollPhysics(),
        itemCount: _lecturerSemesters.length,
        onPageChanged: (index) {
          setState(() => _currentSemesterIndex = index);
        },
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _semesterController!,
            builder: (context, child) {
              double scale = 1.0;
              int selectedIndex = _currentSemesterIndex;

              if (_semesterController!.position.haveDimensions) {
                final page = _semesterController!.page ??
                    _currentSemesterIndex.toDouble();
                scale = (1 - ((page - index).abs() * 0.05)).clamp(0.94, 1.0);
                selectedIndex =
                    page.round().clamp(0, _lecturerSemesters.length - 1);
              }

              return Transform.scale(
                scale: scale,
                child: _buildSemesterCard(
                  _lecturerSemesters[index],
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
    final isCurrent = semester["status"] == "Current Semester";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isSelected ? kAccentBlue : const Color(0xFFE8EEF8),
          width: isSelected ? 2.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
              const Icon(Icons.school_outlined, color: kPrimaryBlue, size: 32),
              const SizedBox(width: 12),
              if (isCurrent)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
          const SizedBox(height: 12),
          Text(
            semester["title"]!,
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: kPrimaryBlue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Manage your classes with ease!",
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: const Color(0xFF46537A),
            ),
          ),
          const Spacer(),
          Divider(color: Colors.grey.shade300),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _simpleInfo("Courses", semester["courses"]!),
              _verticalDivider(),
              _simpleInfo("Students", semester["students"]!),
              _verticalDivider(),
              _simpleInfo("Materials", semester["materials"]!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_lecturerSemesters.length, (index) {
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
      margin: const EdgeInsets.symmetric(horizontal: 30),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8EEF8)),
      ),
      child: Column(
        children: [
          Icon(Icons.menu_book_outlined, color: Colors.grey.shade400, size: 36),
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

              isLecturer: true,
              courseData: Map<String, String>.from(
                course.map((key, value) => MapEntry(key, value.toString())),
              ),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
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
          children: [
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course["name"],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: kTextDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course["code"],
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF7A859F),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Text(
                    "Section",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF7A859F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course["section"],
                    style: GoogleFonts.poppins(
                      color: kPrimaryBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              height: 48,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: Colors.grey.shade300,
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    "Students",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF7A859F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course["students"],
                    style: GoogleFonts.poppins(
                      color: kPrimaryBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
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

  Widget _simpleInfo(String title, String value) {
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
    return Container(width: 1, height: 42, color: Colors.grey.shade300);
  }
}
