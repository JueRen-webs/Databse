import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'constants.dart';
import '../theme/app_colors.dart';

// ==========================================================
// Course 数据模型
// ==========================================================

class Course {
  final String code;
  final String name;
  final String location;
  final int startHour;
  final int duration;
  final Color backgroundColor;
  final String mapUrl;

  Course({
    required this.code,
    required this.name,
    required this.location,
    required this.startHour,
    required this.duration,
    required this.backgroundColor,
    required this.mapUrl,
  });
}

// ==========================================================
// 完整的周课表页面 (TimetablePage)
// ==========================================================

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  // ignore: unused_field
  bool _canPop = true;

  @override
  Widget build(BuildContext context) {
    final Map<String, List<Course>> weeklySchedule = {
      'Monday': [
        Course(
          code: 'BIC1013',
          name: 'STRUKTUR DISKRIT',
          location: 'I-FSKTM-BS1',
          startHour: 8,
          duration: 2,
          backgroundColor: Colors.white,
          mapUrl: kMapLinkA,
        ),
        Course(
          code: 'BIM30503',
          name: 'INTERAKSI MANUSIA KOMPUTER',
          location: 'I-PERP-BT9-GS',
          startHour: 14,
          duration: 2,
          backgroundColor: Colors.white,
          mapUrl: kMapLinkA,
        ),
        Course(
          code: 'BIC20803',
          name: 'SISTEM PENGOPERASIAN',
          location: 'I-FSKTM-BS1',
          startHour: 16,
          duration: 2,
          backgroundColor: Colors.white,
          mapUrl: kMapLinkA,
        ),
      ],
      'Tuesday': [
        Course(
          code: 'BIC20904',
          name: 'PENGATURCARAAN BERORIENTASIKAN OBJEK',
          location: 'I-ISYS-ARAS 1',
          startHour: 9,
          duration: 2,
          backgroundColor: Colors.white,
          mapUrl: kMapLinkA,
        ),
        Course(
          code: 'BIC1013',
          name: 'STRUKTUR DISKRIT',
          location: 'I-PERP-BT10-GS',
          startHour: 11,
          duration: 2,
          backgroundColor: Colors.white,
          mapUrl: kMapLinkC,
        ),
        Course(
          code: 'UHB 23103',
          name: 'ENGLISH FOR TECHNICAL COMMUNICATION',
          location: 'PERP-BT1',
          startHour: 14,
          duration: 3,
          backgroundColor: Colors.white,
          mapUrl: kMapLinkC,
        ),
      ],
      'Wednesday': [
        Course(
          code: 'BIS20503',
          name: 'KESELAMATAN PERISIAN',
          location: 'I-MKK-ARAS 2',
          startHour: 14,
          duration: 2,
          backgroundColor: Colors.white,
          mapUrl: kMapLinkA,
        ),
        Course(
          code: 'BIC20803',
          name: 'SISTEM PENGOPERASIAN',
          location: 'I-MSK-ARAS 3',
          startHour: 16,
          duration: 2,
          backgroundColor: Colors.white,
          mapUrl: kMapLinkA,
        ),
      ],
      'Thursday': [
        Course(
          code: 'BIC20904',
          name: 'PENGATURCARAAN BERORIENTASIKAN OBJEK',
          location: 'I-B8-T1-GS',
          startHour: 8,
          duration: 3,
          backgroundColor: Colors.white,
          mapUrl: kMapLinkB,
        ),
        Course(
          code: 'BIS20503',
          name: 'KESELAMATAN PERISIAN',
          location: 'I-PERP-BT10-GS',
          startHour: 14,
          duration: 2,
          backgroundColor: Colors.white,
          mapUrl: kMapLinkC,
        ),
      ],
      'Friday': [
        Course(
          code: 'BIM30503',
          name: 'INTERAKSI MANUSIA KOMPUTER',
          location: 'I-MGA-ARAS 0',
          startHour: 8,
          duration: 2,
          backgroundColor: Colors.white,
          mapUrl: kMapLinkA,
        ),
      ],
    };

    return PopScope(
      canPop: _canPop,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            "Class Timetable",
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
            onPressed: () {
              setState(() {
                _canPop = true;
              });
              Future.delayed(Duration.zero, () {
                if (context.mounted) Navigator.pop(context);
              });
            },
          ),
        ),
        body: StudentTimetableGrid(schedule: weeklySchedule),
      ),
    );
  }
}

// ==========================================================
// StudentTimetableGrid (styled, themed)
// ==========================================================

class StudentTimetableGrid extends StatelessWidget {
  const StudentTimetableGrid({super.key, required this.schedule});

  final Map<String, List<Course>> schedule;
  final int startHour = 8;
  final int endHour = 18;
  final double cellHeight = 104;
  final double timeSlotWidth = 112;
  final double dayHeaderWidth = 82;
  final List<String> days = const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
  ];

  Future<void> _launchMap(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        debugPrint('Could not launch $url');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final totalGridWidth = timeSlotWidth * (endHour - startHour);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 28),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Container(
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border.all(color: colors.borderColor),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    _StudentGridHeaderCell(width: dayHeaderWidth, text: 'Day'),
                    ...days.map(
                      (day) => _StudentGridDayCell(
                        width: dayHeaderWidth,
                        height: cellHeight,
                        text: day,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: List.generate(endHour - startHour, (index) {
                            final hour = startHour + index;
                            final label =
                                '${hour.toString().padLeft(2, '0')}:00 - ${(hour + 1).toString().padLeft(2, '0')}:00';
                            return _StudentGridHeaderCell(
                              width: timeSlotWidth,
                              text: label,
                            );
                          }),
                        ),
                        SizedBox(
                          height: cellHeight * days.length,
                          width: totalGridWidth,
                          child: Stack(
                            children: [
                              ...List.generate(days.length, (dayIndex) {
                                return Positioned(
                                  top: dayIndex * cellHeight,
                                  left: 0,
                                  right: 0,
                                  height: cellHeight,
                                  child: Row(
                                    children: List.generate(
                                      endHour - startHour,
                                      (_) => Container(
                                        width: timeSlotWidth,
                                        decoration: BoxDecoration(
                                          color: colors.surface,
                                          border: Border.all(
                                            color: colors.borderColor,
                                            width: 0.55,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                              ...days.asMap().entries.expand((entry) {
                                final dayIndex = entry.key;
                                final dayName = entry.value;
                                final courses = schedule[dayName] ?? [];

                                return courses.map((course) {
                                  final left = (course.startHour - startHour) *
                                      timeSlotWidth;
                                  final top = dayIndex * cellHeight;
                                  final width = course.duration * timeSlotWidth;

                                  return Positioned(
                                    left: left,
                                    top: top,
                                    width: width,
                                    height: cellHeight,
                                    child: _StudentTimetableSlotCard(
                                      course: course,
                                      onLocationTap: () =>
                                          _launchMap(course.mapUrl),
                                    ),
                                  );
                                });
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StudentGridHeaderCell extends StatelessWidget {
  const _StudentGridHeaderCell({required this.width, required this.text});

  final double width;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: width,
      height: 50,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: colors.brandPrimary.withValues(alpha: 0.10),
        border: Border.all(color: colors.borderColor, width: 0.7),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          color: colors.primaryText,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _StudentGridDayCell extends StatelessWidget {
  const _StudentGridDayCell({
    required this.width,
    required this.height,
    required this.text,
  });

  final double width;
  final double height;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: colors.cardAlt,
        border: Border.all(color: colors.borderColor, width: 0.7),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          color: colors.primaryText,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _StudentTimetableSlotCard extends StatelessWidget {
  const _StudentTimetableSlotCard({
    required this.course,
    required this.onLocationTap,
  });

  final Course course;
  final VoidCallback onLocationTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.brandPrimary.withValues(alpha: 0.20)),
        boxShadow: [
          BoxShadow(
            color: colors.primaryText.withValues(alpha: 0.055),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            course.code,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: colors.brandPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            course.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: colors.primaryText,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 5),
          InkWell(
            onTap: onLocationTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: colors.brandPrimary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                course.location,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: colors.primaryText,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// TimetableGrid (legacy / alternate grid style)
// ==========================================================

class TimetableGrid extends StatelessWidget {
  final Map<String, List<Course>> schedule;

  final int startHour = 8;
  final int endHour = 18;
  final double cellHeight = 100.0;
  final double timeSlotWidth = 110.0;
  final double dayHeaderWidth = 80.0;

  final List<String> days = const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday'
  ];

  const TimetableGrid({super.key, required this.schedule});

  Future<void> _launchMap(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        debugPrint('Could not launch $url');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalGridWidth = timeSlotWidth * (endHour - startHour);

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 左侧固定列 (Header: Day)
          Column(
            children: [
              Container(
                height: 50,
                width: dayHeaderWidth,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: kTimetableHeaderColor,
                  border: Border.all(color: kBorderColor, width: 1.5),
                ),
                child: Text(
                  "Day",
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
              ),
              ...days.map((day) => Container(
                    height: cellHeight,
                    width: dayHeaderWidth,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: kTimetableCellColor,
                      border: Border.all(color: kBorderColor, width: 1.5),
                    ),
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  )),
            ],
          ),

          // 右侧可滚动区域
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 顶部时间轴
                  Row(
                    children: List.generate(endHour - startHour, (index) {
                      int h = startHour + index;
                      String timeStr =
                          "${h.toString().padLeft(2, '0')}:00 - ${(h + 1).toString().padLeft(2, '0')}:00";

                      return Container(
                        width: timeSlotWidth,
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: kTimetableCellColor,
                          border: Border.all(color: kBorderColor, width: 1.5),
                        ),
                        child: Text(
                          timeStr,
                          style: GoogleFonts.inter(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      );
                    }),
                  ),

                  // 课程网格
                  SizedBox(
                    height: cellHeight * days.length,
                    width: totalGridWidth,
                    child: Stack(
                      children: [
                        // 背景空网格
                        ...List.generate(days.length, (dayIndex) {
                          return Positioned(
                            top: dayIndex * cellHeight,
                            left: 0,
                            right: 0,
                            height: cellHeight,
                            child: Row(
                              children: List.generate(endHour - startHour,
                                  (timeIndex) {
                                return Container(
                                  width: timeSlotWidth,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: kBorderColor, width: 0.5),
                                  ),
                                );
                              }),
                            ),
                          );
                        }),

                        // 课程卡片
                        ...days.asMap().entries.map((entry) {
                          int dayIndex = entry.key;
                          String dayName = entry.value;
                          List<Course> courses = schedule[dayName] ?? [];

                          return Stack(
                            children: courses.map((course) {
                              double left = (course.startHour - startHour) *
                                  timeSlotWidth;
                              double top = dayIndex * cellHeight;
                              double width = course.duration * timeSlotWidth;

                              return Positioned(
                                left: left,
                                top: top,
                                width: width,
                                height: cellHeight,
                                child: Container(
                                  margin: const EdgeInsets.all(0.5),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: course.backgroundColor,
                                    border: Border.all(
                                        color: kBorderColor, width: 0.5),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "${course.code}\n${course.name}",
                                        textAlign: TextAlign.center,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      GestureDetector(
                                        onTap: () {
                                          _launchMap(course.mapUrl);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.black54),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            color: Colors.transparent,
                                          ),
                                          child: Text(
                                            "[${course.location}]",
                                            style: GoogleFonts.inter(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 10,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        }).toList(),
                      ].expand((i) => i is Stack ? [i] : [i]).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
