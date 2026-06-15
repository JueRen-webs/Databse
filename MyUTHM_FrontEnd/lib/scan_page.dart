import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

import 'academic/academic_class_page.dart';
import 'database_helper.dart';
import 'main.dart';


const Color kPrimaryBlue = Color(0xFF0422A7);
const Color kBackgroundColor = Color(0xFFF4F6FC);
const Color kBorderColor = Color(0xFFEEEEEE);
const Color kHeaderColor = Color(0xFF001C55);

class ScanPage extends StatefulWidget {
  const ScanPage({super.key, this.onClose});

  final VoidCallback? onClose;

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final TextEditingController _codeController = TextEditingController();
  final int _bottomNavIndex = 2;

  bool _isSubmitted = false;

  final List<Map<String, String>> _attendanceData = [
    {
      "no": "1",
      "date": "TUESDAY 07/10/2025",
      "type": "Lecture",
      "start": "11.00 am",
      "end": "01.00 pm",
      "status": "ATTEND"
    },
    {
      "no": "2",
      "date": "TUESDAY 14/10/2025",
      "type": "Lecture",
      "start": "11.00 am",
      "end": "01.00 pm",
      "status": "ATTEND"
    },
    {
      "no": "3",
      "date": "TUESDAY 21/10/2025",
      "type": "Lecture",
      "start": "11.00 am",
      "end": "01.00 pm",
      "status": "ATTEND"
    },
    {
      "no": "4",
      "date": "TUESDAY 28/10/2025",
      "type": "Lecture",
      "start": "11.00 am",
      "end": "01.00 pm",
      "status": "ATTEND"
    },
    {
      "no": "5",
      "date": "TUESDAY 04/11/2025",
      "type": "Lecture",
      "start": "11.00 am",
      "end": "01.00 pm",
      "status": "ATTEND"
    },
    {
      "no": "6",
      "date": "TUESDAY 18/11/2025",
      "type": "Lecture",
      "start": "11.00 am",
      "end": "01.00 pm",
      "status": "ATTEND"
    },
    {
      "no": "7",
      "date": "MONDAY 24/11/2025",
      "type": "Tutorial",
      "start": "08.00 am",
      "end": "10.00 am",
      "status": "ATTEND"
    },
    {
      "no": "8",
      "date": "TUESDAY 25/11/2025",
      "type": "Lecture",
      "start": "11.00 am",
      "end": "01.00 pm",
      "status": "ATTEND"
    },
    {
      "no": "9",
      "date": "TUESDAY 02/12/2025",
      "type": "Lecture",
      "start": "11.00 am",
      "end": "01.00 pm",
      "status": "ATTEND"
    },
  ];

  Future<void> _handleSubmit() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    final result = await DatabaseHelper.instance.markAttendanceByCode(
      code: code,
      studentId: DatabaseHelper.currentUserId,
    );
    if (!mounted) return;
    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Invalid attendance code.'),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(18, 0, 18, 112),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final courseData = await DatabaseHelper.instance.getCourseDataBySectionId(
      result['Section_ID'].toString(),
    );
    if (!mounted || courseData == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AcademicClassPage(
          courseData: courseData,
          isLecturer: false,
          initialTab: 'Attendance',
        ),
      ),
    );
  }

  void _closeScan() {
    if (widget.onClose != null) {
      widget.onClose!();
      return;
    }
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      mainGlobalKey.currentState?.switchToTab(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: _isSubmitted ? kPrimaryBlue : Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          _isSubmitted ? "Attendance Record" : "Scanning",
          style: GoogleFonts.poppins(
            color: _isSubmitted ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: _isSubmitted ? _buildResultView() : _buildScanView(),
      floatingActionButton: SizedBox(
        width: 75,
        height: 75,
        child: FloatingActionButton(
          onPressed: () {
            _closeScan();
          },
          backgroundColor: kPrimaryBlue,
          shape: const CircleBorder(),
          elevation: 4,
          child: const Icon(Icons.close, color: Colors.white, size: 34),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        height: 70,
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _buildNavItem(Icons.home_outlined, 'Home', 0),
            _buildNavItem(Icons.menu_book_outlined, 'Academic', 1),
            const SizedBox(width: 40),
            _buildNavItem(Icons.notifications_outlined, 'Notification', 3),
            _buildNavItem(Icons.person_outline, 'Profile', 4),
          ],
        ),
      ),
    );
  }


  Widget _buildScanView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, width: 2),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.camera_alt_outlined,
                      size: 64, color: Colors.grey.shade700),
                  Text(
                    "\nCamera Viewfinder",
                    style: GoogleFonts.poppins(color: Colors.grey.shade600),
                  ),
                  Container(
                    margin: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.5), width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    controller: _codeController,
                    keyboardType: TextInputType.text,

                    textInputAction: TextInputAction.done,

                    onSubmitted: (_) => _handleSubmit(),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
                    ],
                    decoration: InputDecoration(
                      hintText: "Attendance Code",
                      hintStyle:
                          GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.only(bottom: 12),
                    ),
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    side: const BorderSide(color: Colors.black87),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                    elevation: 0,
                  ),
                  child: Text(
                    "Submit",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }


  Widget _buildResultView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 80),
      child: Column(
        children: [
          _buildSectionHeader("ATTENDANCE DETAILS"),
          _buildAttendanceTable(),
          const SizedBox(height: 24),
          _buildSectionHeader("WARNING LETTER"),
          _buildWarningLetterTable(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Data as of Monday 8th of December 2025 09:52:41 AM",
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader("REPORT"),
          _buildReportChart(),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Copyright © 2025 UTHM. All rights reserved.",
                    style: GoogleFonts.poppins(fontSize: 10)),
                Text("Developed by Pusat Teknologi Maklumat, UTHM",
                    style: GoogleFonts.poppins(fontSize: 10)),
              ],
            ),
          )
        ],
      ),
    );
  }


  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          const SizedBox(height: 4),
          const Divider(color: kPrimaryBlue, thickness: 2),
        ],
      ),
    );
  }

  Widget _buildAttendanceTable() {
    return Column(
      children: [
        Container(
          color: kHeaderColor,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            children: [
              _buildHeaderCell("NO.", flex: 1),
              _buildHeaderCell("DATE", flex: 3),
              _buildHeaderCell("CLASS TYPE", flex: 2),
              _buildHeaderCell("START", flex: 2),
              _buildHeaderCell("END", flex: 2),
              _buildHeaderCell("STATUS", flex: 2),
            ],
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _attendanceData.length,
          separatorBuilder: (context, index) =>
              const Divider(height: 1, color: Colors.grey),
          itemBuilder: (context, index) {
            final item = _attendanceData[index];
            return Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Row(
                children: [
                  _buildCell(item["no"]!, flex: 1),
                  _buildCell(item["date"]!, flex: 3),
                  _buildCell(item["type"]!, flex: 2),
                  _buildCell(item["start"]!, flex: 2),
                  _buildCell(item["end"]!, flex: 2),
                  _buildCell(item["status"]!, flex: 2),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildWarningLetterTable() {
    return Column(
      children: [
        Container(
          color: kHeaderColor,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              _buildHeaderCell("NO.", flex: 1),
              _buildHeaderCell("WARNING ID", flex: 2),
              _buildHeaderCell("DATE", flex: 2),
              _buildHeaderCell("REFERENCE", flex: 3),
            ],
          ),
        ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          child: Center(
            child: Text("No records",
                style: GoogleFonts.poppins(color: Colors.grey)),
          ),
        ),
      ],
    );
  }

  Widget _buildReportChart() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 30),
      width: double.infinity,
      child: Column(
        children: [
          CustomPaint(
            size: const Size(250, 125),
            painter: GaugePainter(percentage: 1.0),
            child: SizedBox(
              width: 250,
              height: 125,
              child: Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Text(
                    "100%",
                    style: GoogleFonts.poppins(
                        color: kHeaderColor,
                        fontSize: 32,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "ATTENDANCE\nPERCENTAGE",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(text,
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }

  Widget _buildCell(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(text,
          style: GoogleFonts.poppins(color: Colors.black87, fontSize: 11)),
    );
  }


  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _bottomNavIndex == index;
    Color color = isSelected ? kPrimaryBlue : Colors.grey;

    return InkWell(
      onTap: () {

        if (index == 0) {
          mainGlobalKey.currentState?.switchToTab(0);
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else if (index == 1) {
          mainGlobalKey.currentState?.switchToTab(1);
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else if (index == 3) {
          mainGlobalKey.currentState?.switchToTab(3);
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else if (index == 4) {
          mainGlobalKey.currentState?.switchToTab(4);
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GaugePainter extends CustomPainter {
  final double percentage;

  GaugePainter({required this.percentage});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;
    const strokeWidth = 50.0;

    final bgPaint = Paint()
      ..color = const Color(0xFFEEEEEE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      math.pi,
      math.pi,
      false,
      bgPaint,
    );

    final fgPaint = Paint()
      ..color = const Color(0xFF64B5F6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      math.pi,
      math.pi * percentage,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
