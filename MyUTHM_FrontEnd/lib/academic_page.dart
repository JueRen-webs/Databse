import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'academic_class.dart';

const Color kPrimaryBlue = Color(0xFF0422A7);
const Color kAccentBlue = Color(0xFF006BFF);
const Color kBackgroundColor = Color(0xFFF5F8FE);
const Color kTextDark = Color(0xFF071A52);

class AcademicPage extends StatefulWidget {
  const AcademicPage({super.key});

  @override
  State<AcademicPage> createState() => _AcademicPageState();
}

class _AcademicPageState extends State<AcademicPage> {
  late PageController _semesterController;
  int _currentSemesterIndex = 3;

  final List<Map<String, String>> _semesters = [
    {
      "title": "Semester 1",
      "status": "Past Semester",
      "cpa": "3.96",
      "classes": "5",
      "credits": "20",
    },
    {
      "title": "Semester 2",
      "status": "Past Semester",
      "cpa": "3.97",
      "classes": "5",
      "credits": "19",
    },
    {
      "title": "Semester 3",
      "status": "Past Semester",
      "cpa": "3.98",
      "classes": "5",
      "credits": "20",
    },
    {
      "title": "Semester 4",
      "status": "Current Semester",
      "cpa": "3.98",
      "classes": "4",
      "credits": "20",
    },
    {
      "title": "Semester 5",
      "status": "Next Semester",
      "cpa": "-",
      "classes": "-",
      "credits": "-",
    },
  ];

  final List<List<Map<String, dynamic>>> _coursesBySemester = [
    [
      {
        "code": "BIC10204",
        "name": "Algorithm",
        "lecturer": "Malik",
        "grade": "A",
        "attendance": "100%",
      },
      {
        "code": "BIC10503",
        "name": "Computer Architecture",
          "lecturer": "Sapiee",
        "grade": "A",
        "attendance": "99%",
      },
      {
        "code": "BIC21102",
        "name": "Professional Ethics And Occupational",
        "lecturer": "Ezak",
        "grade": "A-",
        "attendance": "97%",
      },
      {
        "code": "UHB13102",
        "name": "English For General Communication",
        "lecturer": "Liza",
        "grade": "A",
        "attendance": "98%",
      },
      {
        "code": "UQB10102",
        "name": "Integrity And Anti-Corruption",
        "lecturer": "Khairol",
        "grade": "A+",
        "attendance": "100%",
      },
    ],
    [
      {
        "code": "BIC10404",
        "name": "Data Structure",
        "lecturer": "Nordiana",
        "grade": "A",
        "attendance": "100%",
      },
      {
        "code": "UQI11202",
        "name": "Philosophy and Current Issues",
        "lecturer": "Kamal",
        "grade": "A+",
        "attendance": "99%",
      },
      {
        "code": "BIC21003",
        "name": "System Analysis and Design",
        "lecturer": "Faradila",
        "grade": "A",
        "attendance": "98%",
      },
      {
        "code": "BIS10103",
        "name": "Information Security Fundamentals",
        "lecturer": "Bakiah",
        "grade": "A-",
        "attendance": "97%",
      },
      {
        "code": "BIC31502",
        "name": "Creativity and Innovation ",
        "lecturer": "Suhaila",
        "grade": "A",
        "attendance": "100%",
      },
    ],
    [
      {
        "code": "BIC20803",
        "name": "Operating System",
        "lecturer": "Nayef",
        "grade": "A+",
        "attendance": "100%",
      },
      {
        "code": "BIC20904",
        "name": "Object-Oriented Programing",
        "lecturer": "Faradila",
        "grade": "A",
        "attendance": "98%",
      },
      {
        "code": "BIM30503",
        "name": "Human Computer Interaction",
        "lecturer": "Hana",
        "grade": "A+",
        "attendance": "100%",
      },
      {
        "code": "BIS20503",
        "name": "Software Security",
        "lecturer": "Hidayah",
        "grade": "A",
        "attendance": "99%",
      },
    ],
    [
      {
        "code": "BIC21303",
        "name": "Computer Networking",
        "lecturer": "Rahmi",
        "grade": "-",
        "attendance": "100%",
      },
      {
        "code": "BIC21404",
        "name": "Database",
        "lecturer": "Zana",
        "grade": "-",
        "attendance": "98%",
      },
      {
        "code": "BIS20404",
        "name": "Cryptography",
        "lecturer": "Ziadah",
        "grade": "-",
        "attendance": "100%",
      },
      {
        "code": "BIS20503",
        "name": "Computer Crime And Digital Forensics",
        "lecturer": "Azma",
        "grade": "-",
        "attendance": "99%",
      },
    ],
    [],
  ];

  @override
  void initState() {
    super.initState();
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
      padding: const EdgeInsets.only(top: 18, bottom: 24),
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
      height: 300,
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
    final bool isCurrent = semester["status"] == "Current Semester";

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 10,
      ),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isSelected ? kAccentBlue : const Color(0xFFE8EEF8),
          width: isSelected ? 2 : 1,
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
          const SizedBox(height: 24),
          Text(
            semester["title"]!,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: kPrimaryBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Keep going, you're doing great!✨ ",
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: const Color(0xFF46537A),
            ),
          ),
          const Spacer(),
          Divider(
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 14),
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
          children: [
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course["name"],
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: kTextDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course["lecturer"],
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
                    "Attendance",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF7A859F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course["attendance"],
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
              margin: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              color: Colors.grey.shade300,
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    "Grade",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF7A859F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course["grade"],
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
