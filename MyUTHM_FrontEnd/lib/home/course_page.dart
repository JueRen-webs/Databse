import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'constants.dart';

// ==========================================
// E. Course Management
// ==========================================

class CoursePage extends StatefulWidget {
  const CoursePage({super.key});
  @override
  State<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  List<Map<String, dynamic>> courses = [
    {"code": "BIC10103", "name": "DISCRETE STRUCTURE", "section": "1", "status": "DT", "credit": 3},
    {"code": "BIC20803", "name": "OPERATING SYSTEM", "section": "1", "status": "DT", "credit": 3},
    {"code": "BIC20904", "name": "OBJECT-ORIENTED PROGRAMMING", "section": "1", "status": "DT", "credit": 4},
    {"code": "BIM30503", "name": "HUMAN COMPUTER INTERACTION", "section": "1", "status": "DT", "credit": 3},
    {"code": "BIS20503", "name": "SOFTWARE SECURITY", "section": "1", "status": "DT", "credit": 3},
    {"code": "UHB23103", "name": "ENGLISH FOR TECHNICAL COMMUNICATION", "section": "27", "status": "DT", "credit": 3},
  ];
  int get totalCredits =>
      courses.fold(0, (sum, item) => sum + (item['credit'] as int));

  void _addCourse() async {
    final result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => const RegisterCoursePage()));
    if (result != null && result is Map<String, dynamic>) {
      setState(() => courses.add(result));
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Course Added Successfully")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: Text("Course Management",
              style: GoogleFonts.inter(
                  color: Colors.black, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0.5,
          iconTheme: const IconThemeData(color: Colors.black)),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                  child: _card("12", "Min Credits", Colors.orange)),
              const SizedBox(width: 10),
              Expanded(
                  child: _card("20", "Max Credits", const Color(0xFFD9534F)))
            ]),
            const SizedBox(height: 10),
            _card(totalCredits.toString(), "Credits Registered",
                const Color(0xFF00AEEF)),
            const SizedBox(height: 24),
            Text("REGISTRATION INFORMATION",
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF333333))),
            const Divider(thickness: 2, color: kPrimaryBlue),
            _regTable(),
            const SizedBox(height: 24),
            Text("COURSES REGISTERED",
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800])),
            const Divider(thickness: 2, color: Colors.green),
            _courseTable(),
            Container(
                padding: const EdgeInsets.all(12),
                alignment: Alignment.centerRight,
                child: Text("TOTAL CREDITS: $totalCredits",
                    style: const TextStyle(fontWeight: FontWeight.bold))),
            const SizedBox(height: 80),
          ])),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: _addCourse,
          backgroundColor: kPrimaryBlue,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text("Register New Course",
              style: TextStyle(color: Colors.white))),
    );
  }

  Widget _card(String n, String l, Color c) => Container(
      padding: const EdgeInsets.all(16),
      decoration:
          BoxDecoration(color: c, borderRadius: BorderRadius.circular(4)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(n,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold)),
        Text(l, style: const TextStyle(color: Colors.white, fontSize: 12))
      ]));

  Widget _regTable() => Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300)),
      child: Column(children: [
        Container(
            color: const Color(0xFF000080),
            padding: const EdgeInsets.all(8),
            child: const Row(children: [
              Expanded(
                  flex: 2,
                  child: Text("SESSION",
                      style: TextStyle(color: Colors.white, fontSize: 10))),
              Expanded(
                  flex: 3,
                  child: Text("DATES (CLOSED)",
                      style: TextStyle(color: Colors.white, fontSize: 10)))
            ])),
        Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: const Row(children: [
              Expanded(flex: 2, child: Text("20252026/1")),
              Expanded(flex: 3, child: Text("10/09/2025 - 12/09/2025"))
            ])),
      ]));

  Widget _courseTable() => Container(
      decoration:
          BoxDecoration(border: Border.all(color: Colors.grey.shade200)),
      child: Column(children: [
        Container(
            color: Colors.green[800],
            padding:
                const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: const Row(children: [
              SizedBox(
                  width: 30,
                  child: Text("NO",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold))),
              SizedBox(
                  width: 70,
                  child: Text("CODE",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold))),
              Expanded(
                  child: Text("NAME",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold))),
              SizedBox(
                  width: 40,
                  child: Text("SECT",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold))),
              SizedBox(
                  width: 50,
                  child: Text("STATUS",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold))),
              SizedBox(
                  width: 30,
                  child: Text("CR",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold)))
            ])),
        ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: courses.length,
            itemBuilder: (ctx, i) {
              final c = courses[i];
              return Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 4),
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(color: Colors.grey.shade200)),
                      color: i % 2 == 0
                          ? Colors.white
                          : Colors.grey.shade50),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                            width: 30,
                            child: Text("${i + 1}",
                                style: const TextStyle(fontSize: 10))),
                        SizedBox(
                            width: 70,
                            child: Text(c['code'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10))),
                        Expanded(
                            child: Text(c['name'],
                                style: const TextStyle(fontSize: 10))),
                        SizedBox(
                            width: 40,
                            child: Text(c['section'],
                                style: const TextStyle(fontSize: 10))),
                        SizedBox(
                            width: 50,
                            child: Text(c['status'],
                                style: const TextStyle(fontSize: 10))),
                        SizedBox(
                            width: 30,
                            child: Text("${c['credit']}",
                                style: const TextStyle(fontSize: 10)))
                      ]));
            })
      ]));
}

class RegisterCoursePage extends StatefulWidget {
  const RegisterCoursePage({super.key});
  @override
  State<RegisterCoursePage> createState() => _RegisterCoursePageState();
}

class _RegisterCoursePageState extends State<RegisterCoursePage> {
  final _search = TextEditingController();
  List<Map<String, dynamic>> results = [];
  final List<Map<String, dynamic>> db = [
    {
      "code": "BIT20203",
      "name": "DATA VISUALIZATION",
      "credit": 3,
      "sections": [
        {"no": "1", "time": "Mon 08:00 - 10:00", "location": "BS1", "capacity": "25/30"},
        {"no": "2", "time": "Tue 14:00 - 16:00", "location": "BK2", "capacity": "10/30"},
        {"no": "3", "time": "Wed 10:00 - 12:00", "location": "Lab 4", "capacity": "FULL"}
      ]
    },
    {
      "code": "BIM10103",
      "name": "PROGRAMMING I",
      "credit": 3,
      "sections": [
        {"no": "1", "time": "Thu 08:00 - 11:00", "location": "Lab 1", "capacity": "12/30"}
      ]
    },
    {
      "code": "UHB10102",
      "name": "ENGLISH FOR ACADEMIC",
      "credit": 2,
      "sections": [
        {"no": "10", "time": "Mon 14:00 - 16:00", "location": "G3-102", "capacity": "20/30"}
      ]
    },
  ];

  void _doSearch(String q) {
    if (q.isEmpty) {
      setState(() => results = []);
      return;
    }
    setState(() => results = db
        .where((c) =>
            c['code'].toString().toLowerCase().contains(q.toLowerCase()) ||
            c['name'].toString().toLowerCase().contains(q.toLowerCase()))
        .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FC),
      appBar: AppBar(
          title: const Text("Register Course",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0.5,
          iconTheme: const IconThemeData(color: Colors.black)),
      body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8)),
                child: TextField(
                    controller: _search,
                    onChanged: _doSearch,
                    decoration: const InputDecoration(
                        hintText: "Search Course Code (e.g. BIT20203)",
                        prefixIcon: Icon(Icons.search),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(14)))),
            const SizedBox(height: 20),
            Expanded(
                child: results.isEmpty
                    ? const Center(child: Text("Enter code to search"))
                    : ListView.builder(
                        itemCount: results.length,
                        itemBuilder: (ctx, i) {
                          final c = results[i];
                          return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: ExpansionTile(
                                title: Text("${c['code']} - ${c['name']}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                subtitle: Text("${c['credit']} Credits"),
                                children: [
                                  Container(
                                      padding: const EdgeInsets.all(16),
                                      color: Colors.grey.shade50,
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text("Select a Section:",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            const SizedBox(height: 10),
                                            ...(c['sections'] as List)
                                                .map((s) {
                                              bool full =
                                                  s['capacity'] == "FULL";
                                              return Container(
                                                  margin: const EdgeInsets
                                                      .only(bottom: 8),
                                                  padding:
                                                      const EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      border: Border.all(
                                                          color: Colors
                                                              .grey.shade300),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8)),
                                                  child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                  "Section ${s['no']}",
                                                                  style: const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color:
                                                                          kPrimaryBlue)),
                                                              Text(s['time']),
                                                              Text(s[
                                                                  'location'])
                                                            ]),
                                                        Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .end,
                                                            children: [
                                                              Text(
                                                                  s['capacity'],
                                                                  style: TextStyle(
                                                                      color: full
                                                                          ? Colors
                                                                              .red
                                                                          : Colors
                                                                              .green)),
                                                              const SizedBox(
                                                                  height: 8),
                                                              ElevatedButton(
                                                                  onPressed: full
                                                                      ? null
                                                                      : () => Navigator.pop(
                                                                          context,
                                                                          {
                                                                            "code":
                                                                                c['code'],
                                                                            "name":
                                                                                c['name'],
                                                                            "section":
                                                                                s['no'],
                                                                            "status":
                                                                                "DT",
                                                                            "credit":
                                                                                c['credit']
                                                                          }),
                                                                  style: ElevatedButton.styleFrom(
                                                                      backgroundColor:
                                                                          kPrimaryBlue,
                                                                      minimumSize:
                                                                          const Size(
                                                                              60,
                                                                              30)),
                                                                  child: const Text(
                                                                      "Add",
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.white)))
                                                            ])
                                                      ]));
                                            }),
                                          ]))
                                ],
                              ));
                        }))
          ])),
    );
  }
}
