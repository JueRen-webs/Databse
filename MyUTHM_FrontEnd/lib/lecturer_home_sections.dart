import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'home_page.dart' show showCampusMapMenu;
import 'home_page2.dart' show ReservationPage;
import 'lecturer_annual_leave_page.dart';
import 'lecturer_attendance_page.dart';
import 'lecturer_home_models.dart';
import 'lecturer_movement_page.dart';
import 'lecturer_salary_page.dart';
import 'lecturer_timetable_page.dart';
import 'my_health_page.dart';
import 'theme/app_colors.dart';

class LecturerFunctionPanel extends StatelessWidget {
  const LecturerFunctionPanel({super.key});

  static const List<LecturerFeature> _features = [
    LecturerFeature(title: 'Salary', icon: Icons.payments_outlined),
    LecturerFeature(title: 'Annual Leave', icon: Icons.beach_access_outlined),
    LecturerFeature(title: 'Movement', icon: Icons.route_outlined),
    LecturerFeature(title: 'My Health', icon: Icons.health_and_safety_outlined),
    LecturerFeature(title: 'Timetable', icon: Icons.calendar_month_outlined),
    LecturerFeature(title: 'Reservation', icon: Icons.meeting_room_outlined),
    LecturerFeature(title: 'Attendance', icon: Icons.fact_check_outlined),
    LecturerFeature(title: 'Campus map', icon: Icons.map_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return LecturerSectionCard(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _features.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          mainAxisExtent: 72,
        ),
        itemBuilder: (context, index) => _LecturerFeatureTile(
          item: _features[index],
        ),
      ),
    );
  }
}

class _LecturerFeatureTile extends StatelessWidget {
  const _LecturerFeatureTile({required this.item});

  final LecturerFeature item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    VoidCallback? onTap;
    if (item.title == 'Campus map') {
      onTap = () => showCampusMapMenu(context);
    } else if (item.title == 'Reservation') {
      onTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ReservationPage()),
        );
      };
    } else if (item.title == 'Attendance') {
      onTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const LecturerAttendancePage()),
        );
      };
    } else if (item.title == 'My Health') {
      onTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MyHealthPage()),
        );
      };
    } else if (item.title == 'Timetable') {
      onTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const LecturerTimetablePage()),
        );
      };
    } else if (item.title == 'Annual Leave') {
      onTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const LecturerAnnualLeavePage()),
        );
      };
    } else if (item.title == 'Salary') {
      onTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LecturerSalaryPage()),
        );
      };
    } else if (item.title == 'Movement') {
      onTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LecturerMovementPage()),
        );
      };
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: colors.brandPrimary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(item.icon, color: colors.brandPrimary, size: 19),
          ),
          const SizedBox(height: 8),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: colors.primaryText,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class LecturerScheduleCard extends StatelessWidget {
  const LecturerScheduleCard({super.key});

  static const List<LecturerScheduleItem> _items = [
    LecturerScheduleItem(
      start: '9:00 AM',
      end: '10:15 AM',
      title: 'Data Structures (CS 210)',
      location: 'Engineering Hall, Room 201',
    ),
    LecturerScheduleItem(
      start: '11:30 AM',
      end: '12:45 PM',
      title: 'Office Hours',
      location: 'Engineering Hall, Room 201',
    ),
    LecturerScheduleItem(
      start: '2:00 PM',
      end: '3:15 PM',
      title: 'Calculus I (MATH 101)',
      location: 'Science Building, Room 105',
    ),
    LecturerScheduleItem(
      start: '4:00 PM',
      end: '5:00 PM',
      title: 'Department Meeting',
      location: 'Math Department Meeting Room',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LecturerSectionCard(
      child: Column(
        children: [
          const LecturerCardTitleRow(title: 'Daily Timetable'),
          const SizedBox(height: 14),
          ..._items.asMap().entries.map(
                (entry) => _TimelineScheduleRow(
                  item: entry.value,
                  isLast: entry.key == _items.length - 1,
                ),
              ),
        ],
      ),
    );
  }
}

class _TimelineScheduleRow extends StatelessWidget {
  const _TimelineScheduleRow({
    required this.item,
    required this.isLast,
  });

  final LecturerScheduleItem item;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 62,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.start,
                  style: GoogleFonts.inter(
                    color: colors.primaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.end,
                  style: GoogleFonts.inter(
                    color: colors.secondaryText,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: colors.brandPrimary,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: colors.borderColor,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: colors.primaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: colors.secondaryText,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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

class LecturerDueReminderCard extends StatelessWidget {
  const LecturerDueReminderCard({super.key});

  static const List<LecturerDueItem> _items = [
    LecturerDueItem(
      title: 'Grade Lab Report 3',
      course: 'Data Structures',
      date: 'May 20, 2025',
      daysLeft: 2,
    ),
    LecturerDueItem(
      title: 'Problem Set 5',
      course: 'Calculus I',
      date: 'May 22, 2025',
      daysLeft: 4,
    ),
    LecturerDueItem(
      title: 'Essay Draft',
      course: 'English Composition',
      date: 'May 25, 2025',
      daysLeft: 7,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LecturerSectionCard(
      child: Column(
        children: [
          const LecturerCardTitleRow(title: 'Due Date Reminder'),
          const SizedBox(height: 12),
          ..._items.map((item) => _DueReminderRow(item: item)),
        ],
      ),
    );
  }
}

class _DueReminderRow extends StatelessWidget {
  const _DueReminderRow({required this.item});

  final LecturerDueItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final statusColor = _urgencyColor(context, item.daysLeft);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.cardAlt,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.assignment_outlined,
              color: statusColor,
              size: 19,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: colors.primaryText,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.course} • ${item.date} • ${item.daysLeft} days left',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: colors.secondaryText,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Color _urgencyColor(BuildContext context, int daysLeft) {
    final colors = context.colors;
    if (daysLeft <= 2) return colors.error;
    if (daysLeft <= 4) return const Color(0xFFE89522);
    return colors.brandPrimary;
  }
}

class LecturerSectionCard extends StatelessWidget {
  const LecturerSectionCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: colors.primaryText.withValues(alpha: 0.055),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class LecturerCardTitleRow extends StatelessWidget {
  const LecturerCardTitleRow({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.inter(
              color: colors.primaryText,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
