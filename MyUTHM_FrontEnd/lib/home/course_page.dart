import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../database_helper.dart';
import 'constants.dart';

class CoursePage extends StatefulWidget {
  const CoursePage({super.key});

  @override
  State<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  List<Map<String, dynamic>> courses = [];
  bool _isLoading = true;

  int get totalCredits => courses.fold(
        0,
        (sum, item) =>
            sum + (int.tryParse(item['Course_Credits'].toString()) ?? 0),
      );

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    final studentId = DatabaseHelper.currentUserId;
    if (studentId.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }
    final rows =
        await DatabaseHelper.instance.getCurrentRegisteredCourses(studentId);
    if (!mounted) return;
    setState(() {
      courses = rows;
      _isLoading = false;
    });
  }

  Future<void> _addCourse() async {
    final added = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const RegisterCoursePage()),
    );
    if (added == true) {
      await _loadCourses();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Course Added Successfully")),
      );
    }
  }

  Future<void> _deleteCourse(Map<String, dynamic> course) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Course"),
        content: Text(
          "Remove ${course['Course_ID']} from your registered courses?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await DatabaseHelper.instance.deleteStudentCourseEnrollment(
      studentId: DatabaseHelper.currentUserId,
      enrollmentId: course['Course_Enrollment_ID'].toString(),
    );
    await _loadCourses();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Course Deleted")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final semester = courses.isEmpty
        ? "-"
        : "${courses.first['Academic_Session']} / ${courses.first['Semester']}";
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Course Management",
          style: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(child: _card("12", "Min Credits", Colors.orange)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _card("20", "Max Credits", const Color(0xFFD9534F)),
                    ),
                  ]),
                  const SizedBox(height: 10),
                  _card(
                    totalCredits.toString(),
                    "Credits Registered",
                    const Color(0xFF00AEEF),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "REGISTRATION INFORMATION",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF333333),
                    ),
                  ),
                  const Divider(thickness: 2, color: kPrimaryBlue),
                  _regTable(semester),
                  const SizedBox(height: 24),
                  Text(
                    "COURSES REGISTERED",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                  const Divider(thickness: 2, color: Colors.green),
                  _courseTable(),
                  Container(
                    padding: const EdgeInsets.all(12),
                    alignment: Alignment.centerRight,
                    child: Text(
                      "TOTAL CREDITS: $totalCredits",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCourse,
        backgroundColor: kPrimaryBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Register New Course",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _card(String n, String l, Color c) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(4)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            n,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(l, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ]),
      );

  Widget _regTable(String semester) => Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300)),
        child: Column(children: [
          Container(
            color: const Color(0xFF000080),
            padding: const EdgeInsets.all(8),
            child: const Row(children: [
              Expanded(
                flex: 2,
                child: Text(
                  "SESSION / SEMESTER",
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  "STATUS",
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ]),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Expanded(flex: 2, child: Text(semester)),
              const Expanded(flex: 3, child: Text("Open")),
            ]),
          ),
        ]),
      );

  Widget _courseTable() => Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200)),
        child: Column(children: [
          Container(
            color: Colors.green[800],
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: const Row(children: [
              SizedBox(width: 30, child: Text("NO", style: _headerStyle)),
              SizedBox(width: 70, child: Text("CODE", style: _headerStyle)),
              Expanded(child: Text("NAME", style: _headerStyle)),
              SizedBox(width: 44, child: Text("SECT", style: _headerStyle)),
              SizedBox(width: 30, child: Text("CR", style: _headerStyle)),
              SizedBox(width: 42),
            ]),
          ),
          if (courses.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text("No registered courses")),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: courses.length,
              itemBuilder: (ctx, i) {
                final c = courses[i];
                return Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200),
                    ),
                    color: i % 2 == 0 ? Colors.white : Colors.grey.shade50,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 30,
                        child:
                            Text("${i + 1}", style: const TextStyle(fontSize: 10)),
                      ),
                      SizedBox(
                        width: 70,
                        child: Text(
                          c['Course_ID']?.toString() ?? "-",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          c['Course_Name']?.toString() ?? "-",
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                      SizedBox(
                        width: 44,
                        child: Text(
                          c['Section_Code']?.toString() ?? "-",
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                      SizedBox(
                        width: 30,
                        child: Text(
                          "${c['Course_Credits'] ?? 0}",
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                      SizedBox(
                        width: 42,
                        child: IconButton(
                          tooltip: "Delete",
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => _deleteCourse(c),
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ]),
      );
}

const TextStyle _headerStyle = TextStyle(
  color: Colors.white,
  fontSize: 9,
  fontWeight: FontWeight.bold,
);

class RegisterCoursePage extends StatefulWidget {
  const RegisterCoursePage({super.key});

  @override
  State<RegisterCoursePage> createState() => _RegisterCoursePageState();
}

class _RegisterCoursePageState extends State<RegisterCoursePage> {
  final _search = TextEditingController();
  List<Map<String, dynamic>> results = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _doSearch(String q) async {
    if (q.trim().isEmpty) {
      setState(() => results = []);
      return;
    }
    setState(() => _isSearching = true);
    final rows = await DatabaseHelper.instance.searchCourseSectionsForRegistration(
      studentId: DatabaseHelper.currentUserId,
      query: q,
    );
    if (!mounted) return;
    setState(() {
      results = rows;
      _isSearching = false;
    });
  }

  Future<void> _addSection(Map<String, dynamic> section) async {
    await DatabaseHelper.instance.enrollStudentInSection(
      studentId: DatabaseHelper.currentUserId,
      sectionId: section['Section_ID'].toString(),
    );
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FC),
      appBar: AppBar(
        title: const Text(
          "Register Course",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _search,
              onChanged: _doSearch,
              decoration: const InputDecoration(
                hintText: "Search course code or course name",
                prefixIcon: Icon(Icons.search),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(14),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : results.isEmpty
                    ? const Center(child: Text("Enter course code or name to search"))
                    : ListView.builder(
                        itemCount: results.length,
                        itemBuilder: (ctx, i) {
                          final c = results[i];
                          final isEnrolled = c['Is_Enrolled'].toString() == '1';
                          final count = int.tryParse(
                                c['Enrolled_Count']?.toString() ?? '0',
                              ) ??
                              0;
                          const capacity = 30;
                          final full = count >= capacity;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${c['Course_ID']} - ${c['Course_Name']}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text("${c['Course_Credits']} Credits"),
                                        Text("Section ${c['Section_Code']}"),
                                        Text(c['Schedule_Text']?.toString() ?? "-"),
                                        Text("Lecturer: ${c['Lecturer_Name'] ?? '-'}"),
                                        Text(
                                          "$count/$capacity",
                                          style: TextStyle(
                                            color:
                                                full ? Colors.red : Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: full || isEnrolled
                                        ? null
                                        : () => _addSection(c),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: kPrimaryBlue,
                                      minimumSize: const Size(70, 34),
                                    ),
                                    child: Text(
                                      isEnrolled ? "Added" : "Add",
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ]),
      ),
    );
  }
}
