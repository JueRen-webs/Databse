import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'academic_class.dart';

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
  late final PageController _semesterController;
  late int _currentSemesterIndex;

  final List<Map<String, String>> _lecturerSemesters = const [
    {
      "title": "2024 Sem 1",
      "status": "Past Semester",
      "courses": "3",
      "students": "118",
      "materials": "15",
    },
    {
      "title": "2024 Sem 2",
      "status": "Past Semester",
      "courses": "4",
      "students": "142",
      "materials": "18",
    },
    {
      "title": "2024 Sem 3",
      "status": "Past Semester",
      "courses": "3",
      "students": "96",
      "materials": "12",
    },
    {
      "title": "2025 Sem 1",
      "status": "Current Semester",
      "courses": "4",
      "students": "156",
      "materials": "20",
    },
    {
      "title": "2025 Sem 2",
      "status": "Next Semester",
      "courses": "3",
      "students": "116",
      "materials": "9",
    },
  ];

  final List<List<Map<String, dynamic>>> _lecturerCoursesBySemester = [
    [
      {
        "code": "BIT101",
        "name": "Programming Fundamentals",
        "lecturer": "Dr. Sofia Najwa",
        "section": "1",
        "students": "36",
      },
      {
        "code": "BIT112",
        "name": "Digital Logic",
        "lecturer": "Dr. Sofia Najwa",
        "section": "2",
        "students": "40",
      },
    ],
    [
      {
        "code": "BIT202",
        "name": "Information Systems",
        "lecturer": "Dr. Sofia Najwa",
        "section": "1",
        "students": "34",
      },
      {
        "code": "BIC21003",
        "name": "System Analysis and Design",
        "lecturer": "Dr. Sofia Najwa",
        "section": "2",
        "students": "38",
      },
    ],
    [
      {
        "code": "BIC21303",
        "name": "Computer Networking",
        "lecturer": "Dr. Sofia Najwa",
        "section": "1",
        "students": "32",
      },
      {
        "code": "BIT203",
        "name": "Database Systems",
        "lecturer": "Dr. Sofia Najwa",
        "section": "2",
        "students": "34",
      },
      {
        "code": "BIT221",
        "name": "Web Programming",
        "lecturer": "Dr. Sofia Najwa",
        "section": "3",
        "students": "30",
      },
    ],
    [
      {
        "code": "BIC21303",
        "name": "Computer Networking",
        "lecturer": "Dr. Sofia Najwa",
        "section": "1",
        "students": "38",
      },
      {
        "code": "BIT203",
        "name": "Database Systems",
        "lecturer": "Dr. Sofia Najwa",
        "section": "2",
        "students": "42",
      },
      {
        "code": "BIT221",
        "name": "Web Programming",
        "lecturer": "Dr. Sofia Najwa",
        "section": "3",
        "students": "36",
      },
      {
        "code": "BIT301",
        "name": "Software Engineering",
        "lecturer": "Dr. Sofia Najwa",
        "section": "1",
        "students": "40",
      },
    ],
    [
      {
        "code": "BIT401",
        "name": "Final Year Project",
        "lecturer": "Dr. Sofia Najwa",
        "section": "1",
        "students": "38",
      },
      {
        "code": "BIT322",
        "name": "Software Testing",
        "lecturer": "Dr. Sofia Najwa",
        "section": "2",
        "students": "40",
      },
      {
        "code": "BIT305",
        "name": "Mobile Application Development",
        "lecturer": "Dr. Sofia Najwa",
        "section": "3",
        "students": "38",
      },
    ],
  ];

  List<Map<String, String>> get _semesters => _lecturerSemesters;

  List<List<Map<String, dynamic>>> get _coursesBySemester =>
      _lecturerCoursesBySemester;

  @override
  void initState() {
    super.initState();
    _currentSemesterIndex = 3;
    _semesterController = PageController(
      viewportFraction: 0.78,
      initialPage: _currentSemesterIndex,
    );
    _semesterController.addListener(_handleSemesterScroll);
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

    final nextIndex = (_semesterController.page ?? _currentSemesterIndex)
        .round()
        .clamp(0, _semesters.length - 1);

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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final currentCourses = _coursesBySemester[_currentSemesterIndex];

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
                selectedIndex = page.round().clamp(0, _semesters.length - 1);
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
    final isCurrent = semester["status"] == "Current Semester";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      padding: const EdgeInsets.all(30),
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
          const SizedBox(height: 28),
          Text(
            semester["title"]!,
            style: GoogleFonts.poppins(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: kPrimaryBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Manage your classes with ease!",
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: const Color(0xFF46537A),
            ),
          ),
          const Spacer(),
          Divider(color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _simpleInfo(
                "Courses",
                semester["courses"]!,
              ),
              _verticalDivider(),
              _simpleInfo(
                "Students",
                semester["students"]!,
              ),
              _verticalDivider(),
              _simpleInfo(
                "Materials",
                semester["materials"]!,
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
