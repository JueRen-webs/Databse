import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'main.dart';

const Color _kPrimaryBlue = Color(0xFF1238F1);
const Color _kDeepBlue = Color(0xFF07155D);
const Color _kMutedText = Color(0xFF7782A4);
const Color _kDivider = Color(0xFFE0E4EE);
const Color _kAbsentRed = Color(0xFFFF1528);

class StudentCourseAttendanceRecord {
  final String date;
  final String startTime;
  final String endTime;
  final bool isPresent;

  const StudentCourseAttendanceRecord({
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.isPresent,
  });
}

class StudentCourseAttendancePage extends StatelessWidget {
  final String courseName;
  final String lecturerName;
  final List<StudentCourseAttendanceRecord> records;
  final int? attendancePercent;
  final bool showChrome;

  const StudentCourseAttendancePage({
    super.key,
    required this.courseName,
    required this.lecturerName,
    required this.records,
    this.attendancePercent,
    this.showChrome = true,
  });

  int get _presentCount => records.where((record) => record.isPresent).length;

  int get _absentCount => records.length - _presentCount;

  int get _attendancePercent {
    if (attendancePercent != null) return attendancePercent!.clamp(0, 100);
    if (records.isEmpty) return 0;
    return ((_presentCount / records.length) * 100).round();
  }

  bool get _hasWarningLetter => _attendancePercent < 80;

  @override
  Widget build(BuildContext context) {
    if (!showChrome) {
      return _buildContent();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Attendance Details',
          style: GoogleFonts.poppins(
            color: _kDeepBlue,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        width: 75,
        height: 75,
        child: FloatingActionButton(
          onPressed: () {
            mainGlobalKey.currentState?.switchToTab(2);
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          backgroundColor: const Color(0xFF0524B8),
          shape: const CircleBorder(),
          elevation: 4,
          child: const Icon(
            Icons.qr_code_scanner,
            color: Colors.white,
            size: 32,
          ),
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
            _buildNavItem(context, Icons.home, 'Home', 0),
            _buildNavItem(context, Icons.menu_book, 'Academic', 1),
            const SizedBox(width: 40),
            _buildNavItem(
              context,
              Icons.notifications_outlined,
              'Notification',
              3,
            ),
            _buildNavItem(context, Icons.person_outline, 'Profile', 4),
          ],
        ),
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 28),
      children: [
        _buildSummaryCard(),
        const SizedBox(height: 22),
        Text(
          'Attendance Record',
          style: GoogleFonts.poppins(
            color: _kDeepBlue,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 18),
        ...records.map(
          (record) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _AttendanceRecordTile(record: record),
          ),
        ),
        const SizedBox(height: 8),
        _buildWarningLetterSection(),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool compact = constraints.maxWidth < 480;

        return Container(
          padding: EdgeInsets.fromLTRB(
            compact ? 18 : 24,
            compact ? 18 : 24,
            compact ? 18 : 24,
            compact ? 16 : 22,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(compact ? 22 : 28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1238F1).withValues(alpha: 0.06),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          courseName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: _kDeepBlue,
                            fontSize: compact ? 17 : 18,
                            height: 1.08,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          lecturerName,
                          style: GoogleFonts.poppins(
                            color: _kMutedText,
                            fontSize: compact ? 13 : 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: 24,
                          height: 2,
                          color: _kDivider,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: compact ? 10 : 16),
                  _AttendanceProgressRing(
                    percent: _attendancePercent,
                    size: compact ? 92 : 118,
                  ),
                ],
              ),
              SizedBox(height: compact ? 14 : 18),
              Row(
                children: [
                  Expanded(
                    child: _SummaryCount(
                      icon: Icons.check,
                      label: 'Present',
                      count: _presentCount.toString(),
                      color: _kPrimaryBlue,
                      background: const Color(0xFFEAF0FF),
                      compact: compact,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: compact ? 34 : 38,
                    color: _kDivider,
                  ),
                  Expanded(
                    child: _SummaryCount(
                      icon: Icons.close,
                      label: 'Absent',
                      count: _absentCount.toString(),
                      color: _kAbsentRed,
                      background: const Color(0xFFFFE8EA),
                      compact: compact,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWarningLetterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Warning Letter',
          style: GoogleFonts.poppins(
            color: _kDeepBlue,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        _hasWarningLetter
            ? _WarningLetterCard(
                courseName: courseName,
                attendancePercent: _attendancePercent,
              )
            : Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _kDivider),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEAF0FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_outline,
                        color: _kPrimaryBlue,
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'No warning letter issued',
                        style: GoogleFonts.poppins(
                          color: _kMutedText,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ],
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    int index,
  ) {
    final bool isSelected = index == 1;
    final Color color = isSelected ? const Color(0xFF0524B8) : Colors.grey;

    return InkWell(
      onTap: () {
        mainGlobalKey.currentState?.switchToTab(index);
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

class _AttendanceProgressRing extends StatelessWidget {
  final int percent;
  final double size;

  const _AttendanceProgressRing({
    required this.percent,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size - 10,
            height: size - 10,
            child: CircularProgressIndicator(
              value: percent / 100,
              strokeWidth: size < 100 ? 8 : 9,
              strokeCap: StrokeCap.butt,
              backgroundColor: const Color(0xFFE8E8E8),
              valueColor: const AlwaysStoppedAnimation<Color>(_kPrimaryBlue),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$percent%',
                style: GoogleFonts.poppins(
                  color: _kPrimaryBlue,
                  fontSize: size < 100 ? 22 : 25,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Overall',
                style: GoogleFonts.poppins(
                  color: _kMutedText,
                  fontSize: size < 100 ? 10 : 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryCount extends StatelessWidget {
  final IconData icon;
  final String label;
  final String count;
  final Color color;
  final Color background;
  final bool compact;

  const _SummaryCount({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
    required this.background,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: compact ? 34 : 42,
          height: compact ? 34 : 42,
          decoration: BoxDecoration(
            color: background,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: compact ? 20 : 24),
        ),
        SizedBox(width: compact ? 7 : 10),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: _kMutedText,
                fontSize: compact ? 12 : 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              count,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: color,
                fontSize: compact ? 16 : 18,
                height: 1.1,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _WarningLetterCard extends StatelessWidget {
  final String courseName;
  final int attendancePercent;

  const _WarningLetterCard({
    required this.courseName,
    required this.attendancePercent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4F5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFC8CE)),
        boxShadow: [
          BoxShadow(
            color: _kAbsentRed.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFE1E5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: _kAbsentRed,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Attendance Below 80%',
                      style: GoogleFonts.poppins(
                        color: _kAbsentRed,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      courseName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: _kDeepBlue,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Your current attendance is $attendancePercent%. A warning letter has been issued because your attendance is below the minimum requirement.',
            style: GoogleFonts.poppins(
              color: const Color(0xFF7A2530),
              fontSize: 12,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFFC8CE)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.mark_email_unread_outlined,
                  color: _kAbsentRed,
                  size: 16,
                ),
                const SizedBox(width: 7),
                Text(
                  'Warning Letter Issued',
                  style: GoogleFonts.poppins(
                    color: _kAbsentRed,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceRecordTile extends StatelessWidget {
  final StudentCourseAttendanceRecord record;

  const _AttendanceRecordTile({required this.record});

  @override
  Widget build(BuildContext context) {
    final Color statusColor = record.isPresent ? _kPrimaryBlue : _kAbsentRed;
    final Color statusBackground =
        record.isPresent ? const Color(0xFFEAF0FF) : const Color(0xFFFFE8EA);
    final String timeLabel = record.endTime.isEmpty
        ? record.startTime
        : '${record.startTime} - ${record.endTime}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1238F1).withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.date,
                  textAlign: TextAlign.left,
                  style: GoogleFonts.poppins(
                    color: _kDeepBlue,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: _kMutedText,
                      size: 14,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        timeLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: _kMutedText,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: statusBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    record.isPresent ? Icons.check : Icons.close,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  record.isPresent ? 'Present' : 'Absent',
                  style: GoogleFonts.poppins(
                    color: statusColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
