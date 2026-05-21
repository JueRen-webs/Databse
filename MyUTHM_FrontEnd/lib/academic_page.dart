import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'academic_class.dart';

// Color Constants
const Color kPrimaryBlue = Color(0xFF0422A7);
const Color kBackgroundColor = Color(0xFFF4F6FC);
const Color kLightBlueBg = Color(0x1A0422A7);
const Color kShadowColor = Color(0x1A9E9E9E);
const Color kBorderColor = Color(0xFFEEEEEE);

class AcademicPage extends StatefulWidget {
  const AcademicPage({super.key});

  @override
  State<AcademicPage> createState() => _AcademicPageState();
}

class _AcademicPageState extends State<AcademicPage> {
  // Selected State
  String _selectedSession = "2025/2026";
  String _selectedSemester = "1";

  // Options Lists
  final List<String> _sessions = ["2025/2026", "2024/2025", "2023/2024"];
  final List<String> _semesters = ["1", "2", "3"];

  // Mock Data
  final List<Map<String, String>> _allCourses = [
    {
      "code": "BIC10103",
      "name": "STRUKTUR DISKRIT",
      "session": "2025/2026",
      "semester": "1",
      "lecturer": "sofianajwa",
      "section": "S1"
    },
    {
      "code": "BIC20803",
      "name": "SISTEM PENGOPERASIAN",
      "session": "2025/2026",
      "semester": "1",
      "lecturer": "nayef",
      "section": "S1"
    },
    {
      "code": "BIC20904",
      "name": "PENGATURCARAAN BERORIENTASIKAN OBJEK",
      "session": "2025/2026",
      "semester": "1",
      "lecturer": "faradila",
      "section": "S1"
    },
    {
      "code": "BIM30503",
      "name": "INTERAKSI MANUSIA-KOMPUTER",
      "session": "2025/2026",
      "semester": "1",
      "lecturer": "hana",
      "section": "S1"
    },
    {
      "code": "BIC21003",
      "name": "DATA SCIENCE BASICS",
      "session": "2025/2026",
      "semester": "2",
      "lecturer": "dr. lim",
      "section": "S2"
    },
    {
      "code": "UHB10102",
      "name": "ENGLISH FOR ACADEMIC PURPOSES",
      "session": "2024/2025",
      "semester": "1",
      "lecturer": "mr. smith",
      "section": "S5"
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Filter logic
    final filteredCourses = _allCourses.where((course) {
      return course['session'] == _selectedSession &&
          course['semester'] == _selectedSemester;
    }).toList();

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryBlue,
        elevation: 0,
        title: Text(
          "Academic Online Resources",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: _buildCourseListView(filteredCourses),
    );
  }

  Widget _buildCourseListView(List<Map<String, String>> courses) {
    return Column(
      children: [
        // --- Top Filter Area with Material 3 DropdownMenu ---
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: kShadowColor,
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildM3Dropdown(
                  label: "Session",
                  initialValue: _selectedSession,
                  items: _sessions,
                  onSelected: (val) => setState(() => _selectedSession = val!),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildM3Dropdown(
                  label: "Semester",
                  initialValue: _selectedSemester,
                  items: _semesters,
                  onSelected: (val) => setState(() => _selectedSemester = val!),
                ),
              ),
            ],
          ),
        ),

        // Section Title
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          color: kLightBlueBg,
          child: Row(
            children: [
              const Icon(Icons.class_, color: kPrimaryBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                "Select Classroom",
                style: GoogleFonts.poppins(
                  color: kPrimaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),

        // Course List
        Expanded(
          child: courses.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: courses.length,
                  separatorBuilder: (ctx, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _buildCourseCard(courses[index]),
                ),
        ),
      ],
    );
  }

  // --- Material 3 DropdownMenu with LayoutBuilder ---
  Widget _buildM3Dropdown({
    required String label,
    required String initialValue,
    required List<String> items,
    required ValueChanged<String?> onSelected,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return DropdownMenu<String>(
          width: constraints.maxWidth, // Matches the Expanded width
          initialSelection: initialValue,
          label: Text(label),
          requestFocusOnTap: false, // Prevents keyboard on mobile
          onSelected: onSelected,
          dropdownMenuEntries: items.map((String item) {
            return DropdownMenuEntry<String>(
              value: item,
              label: label == "Semester" ? "Semester $item" : item,
            );
          }).toList(),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: kPrimaryBlue),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: kBorderColor),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCourseCard(Map<String, String> course) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AcademicClassPage(courseData: course),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kBorderColor, width: 1.0),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: kLightBlueBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.school, color: kPrimaryBlue, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${course['code']} : ${course['name']}",
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Sem ${course['semester']} / ${course['session']}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 14, color: kPrimaryBlue),
                      const SizedBox(width: 4),
                      Text(
                        "${course['lecturer']} [${course['section']}]",
                        style: GoogleFonts.lato(
                          fontSize: 13,
                          color: kPrimaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 60, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            "No courses found for this criteria.",
            style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}