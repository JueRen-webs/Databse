import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'home_page.dart' show kMapLinkA, kMapLinkB, kMapLinkC;
import 'theme/app_colors.dart';

class LecturerTimetablePage extends StatelessWidget {
  const LecturerTimetablePage({super.key});

  static final Map<String, List<LecturerTimetableSlot>> _schedule = {
    'Monday': const [
      LecturerTimetableSlot(
        code: 'CS 210',
        title: 'Data Structures',
        location: 'Engineering Hall 201',
        startHour: 9,
        duration: 2,
        mapUrl: kMapLinkA,
      ),
      LecturerTimetableSlot(
        code: 'OFFICE',
        title: 'Office Hours',
        location: 'Engineering Hall 201',
        startHour: 11,
        duration: 2,
        mapUrl: kMapLinkA,
      ),
      LecturerTimetableSlot(
        code: 'MEET',
        title: 'Department Meeting',
        location: 'Math Meeting Room',
        startHour: 16,
        duration: 1,
        mapUrl: kMapLinkB,
      ),
    ],
    'Tuesday': const [
      LecturerTimetableSlot(
        code: 'MATH 101',
        title: 'Calculus I',
        location: 'Science Building 105',
        startHour: 10,
        duration: 2,
        mapUrl: kMapLinkB,
      ),
      LecturerTimetableSlot(
        code: 'CS 210',
        title: 'Tutorial',
        location: 'Engineering Lab 2',
        startHour: 14,
        duration: 2,
        mapUrl: kMapLinkA,
      ),
    ],
    'Wednesday': const [
      LecturerTimetableSlot(
        code: 'CS 210',
        title: 'Data Structures',
        location: 'Engineering Hall 201',
        startHour: 9,
        duration: 2,
        mapUrl: kMapLinkA,
      ),
      LecturerTimetableSlot(
        code: 'ADMIN',
        title: 'Faculty Consultation',
        location: 'Faculty Office',
        startHour: 15,
        duration: 1,
        mapUrl: kMapLinkC,
      ),
    ],
    'Thursday': const [
      LecturerTimetableSlot(
        code: 'MATH 101',
        title: 'Calculus I',
        location: 'Science Building 105',
        startHour: 8,
        duration: 2,
        mapUrl: kMapLinkB,
      ),
      LecturerTimetableSlot(
        code: 'TRAIN',
        title: 'Teaching Workshop',
        location: 'Training Room 2',
        startHour: 13,
        duration: 2,
        mapUrl: kMapLinkC,
      ),
    ],
    'Friday': const [
      LecturerTimetableSlot(
        code: 'OFFICE',
        title: 'Office Hours',
        location: 'Engineering Hall 201',
        startHour: 9,
        duration: 2,
        mapUrl: kMapLinkA,
      ),
      LecturerTimetableSlot(
        code: 'REVIEW',
        title: 'Curriculum Review',
        location: 'Meeting Room 3',
        startHour: 14,
        duration: 2,
        mapUrl: kMapLinkC,
      ),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back_ios_new_rounded, color: colors.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Lecturer Timetable',
          style: GoogleFonts.inter(
            color: colors.primaryText,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: LecturerTimetableGrid(schedule: _schedule),
    );
  }
}

class LecturerTimetableGrid extends StatelessWidget {
  const LecturerTimetableGrid({super.key, required this.schedule});

  final Map<String, List<LecturerTimetableSlot>> schedule;
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
                    _HeaderCell(width: dayHeaderWidth, text: 'Day'),
                    ...days.map(
                      (day) => _DayCell(
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
                            return _HeaderCell(
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
                                final slots = schedule[dayName] ?? [];

                                return slots.map((slot) {
                                  final left = (slot.startHour - startHour) *
                                      timeSlotWidth;
                                  final top = dayIndex * cellHeight;
                                  final width = slot.duration * timeSlotWidth;

                                  return Positioned(
                                    left: left,
                                    top: top,
                                    width: width,
                                    height: cellHeight,
                                    child: _TimetableSlotCard(slot: slot),
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

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.width, required this.text});

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

class _DayCell extends StatelessWidget {
  const _DayCell({
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

class _TimetableSlotCard extends StatelessWidget {
  const _TimetableSlotCard({required this.slot});

  final LecturerTimetableSlot slot;

  Future<void> _launchMap() async {
    final url = Uri.parse(slot.mapUrl);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        debugPrint('Could not launch $url');
      }
    } catch (error) {
      debugPrint('Error launching URL: $error');
    }
  }

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
            slot.code,
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
            slot.title,
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
            onTap: _launchMap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: colors.brandPrimary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                slot.location,
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

class LecturerTimetableSlot {
  const LecturerTimetableSlot({
    required this.code,
    required this.title,
    required this.location,
    required this.startHour,
    required this.duration,
    required this.mapUrl,
  });

  final String code;
  final String title;
  final String location;
  final int startHour;
  final int duration;
  final String mapUrl;
}
