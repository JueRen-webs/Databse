import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:uthm/database_helper.dart';

import 'package:uthm/home/timetable_page.dart';

class LecturerTimetablePage extends StatefulWidget {
  const LecturerTimetablePage({super.key});

  @override
  State<LecturerTimetablePage> createState() => _LecturerTimetablePageState();
}

class _LecturerTimetablePageState extends State<LecturerTimetablePage> {
  late Future<Map<String, List<Course>>> _timetableFuture;

  @override
  void initState() {
    super.initState();

    _timetableFuture = DatabaseHelper.instance.getLecturerTimetable(DatabaseHelper.currentUserId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Lecturer Timetable",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<Map<String, List<Course>>>(
        future: _timetableFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.blue));
          }

          if (snapshot.hasError) {
            return Center(child: Text("Load error: ${snapshot.error}"));
          }

          final dynamicSchedule = snapshot.data ?? {};


          return StudentTimetableGrid(schedule: dynamicSchedule);
        },
      ),
    );
  }
}