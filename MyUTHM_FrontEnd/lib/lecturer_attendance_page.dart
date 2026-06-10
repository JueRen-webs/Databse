import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'theme/app_colors.dart';

class CheckInRecord {
  CheckInRecord({
    required this.date,
    required this.checkIn,
    this.checkOut,
  });

  final DateTime date;
  final DateTime checkIn;
  DateTime? checkOut;

  Duration duration(DateTime now) => (checkOut ?? now).difference(checkIn);
  bool get isOpen => checkOut == null;
  bool get isLate =>
      checkIn.isAfter(DateTime(date.year, date.month, date.day, 8));
}

class EventAttendanceRecord {
  const EventAttendanceRecord({
    required this.eventName,
    required this.organizer,
    required this.date,
    required this.time,
    required this.location,
    required this.type,
    required this.attended,
  });

  final String eventName;
  final String organizer;
  final String date;
  final String time;
  final String location;
  final String type;
  final bool attended;
}

enum AttendanceStatusFilter { all, attend, absent }

class LecturerAttendancePage extends StatefulWidget {
  const LecturerAttendancePage({
    super.key,
    this.initialTabIndex = 0,
    this.initialStatus = AttendanceStatusFilter.all,
    this.initialType = 'All Types',
  });

  final int initialTabIndex;
  final AttendanceStatusFilter initialStatus;
  final String initialType;

  @override
  State<LecturerAttendancePage> createState() => _LecturerAttendancePageState();
}

class _LecturerAttendancePageState extends State<LecturerAttendancePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  Timer? _ticker;
  DateTime _now = DateTime.now();
  CheckInRecord? _todayRecord;
  late AttendanceStatusFilter _statusFilter;
  late String _typeFilter;

  final List<CheckInRecord> _history = [
    CheckInRecord(
      date: DateTime(2026, 6, 8),
      checkIn: DateTime(2026, 6, 8, 8, 6),
      checkOut: DateTime(2026, 6, 8, 17, 12),
    ),
    CheckInRecord(
      date: DateTime(2026, 6, 5),
      checkIn: DateTime(2026, 6, 5, 7, 56),
      checkOut: DateTime(2026, 6, 5, 17, 3),
    ),
    CheckInRecord(
      date: DateTime(2026, 6, 4),
      checkIn: DateTime(2026, 6, 4, 8, 0),
      checkOut: DateTime(2026, 6, 4, 17, 5),
    ),
    CheckInRecord(
      date: DateTime(2026, 6, 3),
      checkIn: DateTime(2026, 6, 3, 8, 13),
      checkOut: DateTime(2026, 6, 3, 17, 18),
    ),
    CheckInRecord(
      date: DateTime(2026, 6, 2),
      checkIn: DateTime(2026, 6, 2, 7, 52),
      checkOut: DateTime(2026, 6, 2, 17, 0),
    ),
    CheckInRecord(
      date: DateTime(2026, 5, 29),
      checkIn: DateTime(2026, 5, 29, 8, 9),
      checkOut: DateTime(2026, 5, 29, 17, 10),
    ),
    CheckInRecord(
      date: DateTime(2026, 5, 28),
      checkIn: DateTime(2026, 5, 28, 7, 58),
      checkOut: DateTime(2026, 5, 28, 17, 4),
    ),
    CheckInRecord(
      date: DateTime(2026, 5, 27),
      checkIn: DateTime(2026, 5, 27, 8, 11),
      checkOut: DateTime(2026, 5, 27, 17, 12),
    ),
    CheckInRecord(
      date: DateTime(2026, 5, 26),
      checkIn: DateTime(2026, 5, 26, 7, 55),
      checkOut: DateTime(2026, 5, 26, 17, 1),
    ),
    CheckInRecord(
      date: DateTime(2026, 5, 25),
      checkIn: DateTime(2026, 5, 25, 7, 59),
      checkOut: DateTime(2026, 5, 25, 17, 6),
    ),
    CheckInRecord(
      date: DateTime(2026, 5, 21),
      checkIn: DateTime(2026, 5, 21, 7, 57),
      checkOut: DateTime(2026, 5, 21, 17, 0),
    ),
    CheckInRecord(
      date: DateTime(2026, 5, 20),
      checkIn: DateTime(2026, 5, 20, 8, 5),
      checkOut: DateTime(2026, 5, 20, 17, 8),
    ),
    CheckInRecord(
      date: DateTime(2026, 5, 19),
      checkIn: DateTime(2026, 5, 19, 7, 53),
      checkOut: DateTime(2026, 5, 19, 17, 3),
    ),
    CheckInRecord(
      date: DateTime(2026, 5, 18),
      checkIn: DateTime(2026, 5, 18, 7, 59),
      checkOut: DateTime(2026, 5, 18, 17, 1),
    ),
    CheckInRecord(
      date: DateTime(2026, 5, 15),
      checkIn: DateTime(2026, 5, 15, 7, 56),
      checkOut: DateTime(2026, 5, 15, 17, 0),
    ),
    CheckInRecord(
      date: DateTime(2026, 5, 14),
      checkIn: DateTime(2026, 5, 14, 8, 7),
      checkOut: DateTime(2026, 5, 14, 17, 11),
    ),
    CheckInRecord(
      date: DateTime(2026, 5, 13),
      checkIn: DateTime(2026, 5, 13, 7, 54),
      checkOut: DateTime(2026, 5, 13, 17, 2),
    ),
    CheckInRecord(
      date: DateTime(2026, 5, 12),
      checkIn: DateTime(2026, 5, 12, 7, 51),
      checkOut: DateTime(2026, 5, 12, 17, 4),
    ),
    CheckInRecord(
      date: DateTime(2026, 5, 11),
      checkIn: DateTime(2026, 5, 11, 7, 59),
      checkOut: DateTime(2026, 5, 11, 17, 0),
    ),
    CheckInRecord(
      date: DateTime(2026, 5, 8),
      checkIn: DateTime(2026, 5, 8, 7, 57),
      checkOut: DateTime(2026, 5, 8, 17, 5),
    ),
    CheckInRecord(
      date: DateTime(2026, 5, 7),
      checkIn: DateTime(2026, 5, 7, 8, 10),
      checkOut: DateTime(2026, 5, 7, 17, 9),
    ),
    CheckInRecord(
      date: DateTime(2026, 5, 6),
      checkIn: DateTime(2026, 5, 6, 7, 58),
      checkOut: DateTime(2026, 5, 6, 17, 2),
    ),
    CheckInRecord(
      date: DateTime(2026, 5, 5),
      checkIn: DateTime(2026, 5, 5, 7, 52),
      checkOut: DateTime(2026, 5, 5, 17, 1),
    ),
    CheckInRecord(
      date: DateTime(2026, 5, 4),
      checkIn: DateTime(2026, 5, 4, 7, 55),
      checkOut: DateTime(2026, 5, 4, 17, 0),
    ),
    CheckInRecord(
      date: DateTime(2026, 5, 1),
      checkIn: DateTime(2026, 5, 1, 7, 56),
      checkOut: DateTime(2026, 5, 1, 17, 4),
    ),
  ];

  final Map<String, Set<int>> _absentDaysByMonth = const {
    'June 2026': {1, 9},
    'May 2026': {22},
    'April 2026': {24},
  };

  static const List<EventAttendanceRecord> _events = [
    EventAttendanceRecord(
      eventName: 'Programme Kerohanian',
      organizer: 'Student Affairs',
      date: 'May 17 2025',
      time: '9:00 AM-12:00 PM',
      location: 'Dewan Seri Budiman',
      type: 'Religious',
      attended: true,
    ),
    EventAttendanceRecord(
      eventName: 'Faculty Briefing Session',
      organizer: "Dean's Office",
      date: 'May 16 2025',
      time: '2:30 PM-4:30 PM',
      location: 'Lecture Hall 1',
      type: 'Academic',
      attended: true,
    ),
    EventAttendanceRecord(
      eventName: 'Teacher Training Workshop',
      organizer: 'HR Department',
      date: 'May 10 2025',
      time: '9:00 AM-1:00 PM',
      location: 'Training Room 2',
      type: 'Training',
      attended: false,
    ),
    EventAttendanceRecord(
      eventName: 'Health Awareness Talk',
      organizer: 'Wellness Center',
      date: 'May 8 2025',
      time: '10:00 AM-11:30 AM',
      location: 'Seminar Room A',
      type: 'Wellness',
      attended: true,
    ),
    EventAttendanceRecord(
      eventName: 'Staff Town Hall Meeting',
      organizer: 'Administration',
      date: 'May 5 2025',
      time: '10:00 AM-12:00 PM',
      location: 'Main Auditorium',
      type: 'Meeting',
      attended: true,
    ),
    EventAttendanceRecord(
      eventName: 'Curriculum Review Meeting',
      organizer: 'Academic Affairs',
      date: 'May 2 2025',
      time: '2:00 PM-4:00 PM',
      location: 'Meeting Room 3',
      type: 'Academic',
      attended: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _statusFilter = widget.initialStatus;
    _typeFilter = widget.initialType;
    _ticker = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted && _todayRecord?.isOpen == true) {
        setState(() => _now = DateTime.now());
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void _handleAttendanceAction() {
    final current = DateTime.now();
    setState(() {
      _now = current;
      if (_todayRecord == null) {
        _todayRecord = CheckInRecord(
          date: current,
          checkIn: current,
        );
      } else if (_todayRecord!.checkOut == null) {
        _todayRecord!.checkOut = current;
      }
    });
  }

  List<CheckInRecord> get _records {
    final today = _todayRecord;
    final records = [
      if (today != null) today,
      ..._history,
    ];
    records.sort((a, b) => b.date.compareTo(a.date));
    return records;
  }

  List<CheckInRecord> get _summaryRecords => _records
      .where((record) => record.date.year == 2026 && record.date.month == 5)
      .toList();

  Set<int> get _summaryAbsentDays {
    final workedDays = _summaryRecords.map((record) => record.date.day).toSet();
    return (_absentDaysByMonth['May 2026'] ?? {})
        .where((day) => !workedDays.contains(day))
        .toSet();
  }

  int get _summaryDaysAbsent => _summaryAbsentDays.length;
  int get _summaryDaysLate =>
      _summaryRecords.where((record) => record.isLate).length;
  String get _summaryTotalHours => _formatDuration(
        _summaryRecords.fold<Duration>(
          Duration.zero,
          (total, record) => total + record.duration(_now),
        ),
      );

  List<EventAttendanceRecord> get _filteredEvents {
    return _events.where((event) {
      final statusMatches = switch (_statusFilter) {
        AttendanceStatusFilter.all => true,
        AttendanceStatusFilter.attend => event.attended,
        AttendanceStatusFilter.absent => !event.attended,
      };
      final typeMatches =
          _typeFilter == 'All Types' || event.type == _typeFilter;
      return statusMatches && typeMatches;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: const AttendanceModuleAppBar(),
      body: Column(
        children: [
          _AttendanceTabs(controller: _tabController),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMyAttendanceTab(),
                _buildEventAttendanceTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyAttendanceTab() {
    final recent = _records.take(5).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
      child: Column(
        children: [
          AttendanceStatusCard(
            record: _todayRecord,
            now: _now,
            onActionPressed: _handleAttendanceAction,
          ),
          const SizedBox(height: 14),
          WorkHoursCard(record: _todayRecord, now: _now),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SummaryCard(
                  label: 'Days Worked',
                  value: '${_summaryRecords.length}',
                  icon: Icons.event_available_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SummaryCard(
                  label: 'Total Hours',
                  value: _summaryTotalHours,
                  icon: Icons.schedule_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SummaryCard(
                  label: 'Days Absent',
                  value: '$_summaryDaysAbsent',
                  icon: Icons.event_busy_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SummaryCard(
                  label: 'Days Late',
                  value: '$_summaryDaysLate',
                  icon: Icons.alarm_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            child: Column(
              children: [
                SectionTitleRow(
                  title: 'Recent Check-In / Check-Out',
                  actionLabel: 'View all',
                  onActionTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RecentCheckInOutPage(
                          records: _records,
                          absentDaysByMonth: _absentDaysByMonth,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                ...recent
                    .map((record) => RecentCheckRow(record: record, now: _now)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _TipCard(),
        ],
      ),
    );
  }

  Widget _buildEventAttendanceTab() {
    final events = _filteredEvents;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitleRow(title: 'Event Attendance Records'),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: FilterDropdownButton<AttendanceStatusFilter>(
                        value: _statusFilter,
                        labelForValue: _statusLabel,
                        values: AttendanceStatusFilter.values,
                        onChanged: (value) {
                          setState(() => _statusFilter = value);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilterDropdownButton<String>(
                        value: _typeFilter,
                        labelForValue: (value) => value,
                        values: const [
                          'All Types',
                          'Academic',
                          'Training',
                          'Meeting',
                          'Wellness',
                          'Religious',
                          'Administration',
                          'Workshop',
                        ],
                        onChanged: (value) {
                          setState(() => _typeFilter = value);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (events.isEmpty)
            EmptyRecordsState(
              onReset: () {
                setState(() {
                  _statusFilter = AttendanceStatusFilter.all;
                  _typeFilter = 'All Types';
                });
              },
            )
          else
            ...events.map((event) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: EventAttendanceCard(record: event),
                )),
        ],
      ),
    );
  }

  String _statusLabel(AttendanceStatusFilter value) {
    return switch (value) {
      AttendanceStatusFilter.all => 'All Status',
      AttendanceStatusFilter.attend => 'Attend',
      AttendanceStatusFilter.absent => 'Absent',
    };
  }
}

class EventAttendancePage extends StatelessWidget {
  const EventAttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LecturerAttendancePage(initialTabIndex: 1);
  }
}

class EventAttendanceAttendPage extends StatelessWidget {
  const EventAttendanceAttendPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LecturerAttendancePage(
      initialTabIndex: 1,
      initialStatus: AttendanceStatusFilter.attend,
    );
  }
}

class EventAttendanceAbsentPage extends StatelessWidget {
  const EventAttendanceAbsentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LecturerAttendancePage(
      initialTabIndex: 1,
      initialStatus: AttendanceStatusFilter.absent,
    );
  }
}

class EventAttendanceEmptyPage extends StatelessWidget {
  const EventAttendanceEmptyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LecturerAttendancePage(
      initialTabIndex: 1,
      initialStatus: AttendanceStatusFilter.absent,
      initialType: 'Religious',
    );
  }
}

class RecentCheckInOutPage extends StatefulWidget {
  const RecentCheckInOutPage({
    super.key,
    required this.records,
    required this.absentDaysByMonth,
  });

  final List<CheckInRecord> records;
  final Map<String, Set<int>> absentDaysByMonth;

  @override
  State<RecentCheckInOutPage> createState() => _RecentCheckInOutPageState();
}

class _RecentCheckInOutPageState extends State<RecentCheckInOutPage> {
  late String _month;
  DateTime _now = DateTime.now();
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _month = _latestMonthLabel();
    _ticker = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final selectedMonthDate = DateFormat('MMMM yyyy').parse(_month);
    final selectedRecords = _recordsForMonth(_month);
    final selectedWorkedDays =
        selectedRecords.map((record) => record.date.day).toSet();
    final selectedAbsentDays = (widget.absentDaysByMonth[_month] ?? {})
        .where((day) => !selectedWorkedDays.contains(day))
        .toSet();
    final selectedLateCount =
        selectedRecords.where((record) => record.isLate).length;
    final selectedTotalHours = _formatDuration(
      selectedRecords.fold<Duration>(
        Duration.zero,
        (total, record) => total + record.duration(_now),
      ),
    );

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back_ios_new_rounded, color: colors.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Recent Check-In / Check-Out',
          style: GoogleFonts.inter(
            color: colors.primaryText,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
        child: Column(
          children: [
            _SectionCard(
              child: FilterDropdownButton<String>(
                value: _month,
                values: _availableMonths,
                labelForValue: (value) => value,
                onChanged: (value) => setState(() => _month = value),
              ),
            ),
            const SizedBox(height: 14),
            _AttendanceMonthCalendar(
              monthLabel: _month,
              records: widget.records,
              absentDays: selectedAbsentDays,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    label: 'Days Worked',
                    value: '${selectedRecords.length}',
                    icon: Icons.event_available_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SummaryCard(
                    label: 'Total Hours',
                    value: selectedTotalHours,
                    icon: Icons.schedule_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    label: 'Days Absent',
                    value: '${selectedAbsentDays.length}',
                    icon: Icons.event_busy_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SummaryCard(
                    label: 'Days Late',
                    value: '$selectedLateCount',
                    icon: Icons.alarm_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _SectionCard(
              child: Column(
                children: [
                  ...selectedRecords.map(
                    (record) => RecentCheckRow(record: record, now: _now),
                  ),
                  ...selectedAbsentDays.map(
                    (day) => _AbsentCheckRow(
                      date: DateTime(
                        selectedMonthDate.year,
                        selectedMonthDate.month,
                        day,
                      ),
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

  List<CheckInRecord> _recordsForMonth(String monthLabel) {
    final monthDate = DateFormat('MMMM yyyy').parse(monthLabel);
    final records = widget.records
        .where(
          (record) =>
              record.date.year == monthDate.year &&
              record.date.month == monthDate.month,
        )
        .toList();
    records.sort((a, b) => b.date.compareTo(a.date));
    return records;
  }

  List<String> get _availableMonths {
    final monthLabels = <String>{
      ...widget.absentDaysByMonth.keys,
      ...widget.records.map((record) => DateFormat('MMMM yyyy').format(
            DateTime(record.date.year, record.date.month),
          )),
    }.toList();
    monthLabels.sort(
      (a, b) => DateFormat('MMMM yyyy')
          .parse(b)
          .compareTo(DateFormat('MMMM yyyy').parse(a)),
    );
    return monthLabels;
  }

  String _latestMonthLabel() {
    if (widget.records.isEmpty) {
      return _availableMonths.isEmpty
          ? DateFormat('MMMM yyyy').format(DateTime.now())
          : _availableMonths.first;
    }
    final latest = widget.records
        .map((record) => record.date)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    return DateFormat('MMMM yyyy').format(DateTime(latest.year, latest.month));
  }
}

class AttendanceModuleAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const AttendanceModuleAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(92);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppBar(
      backgroundColor: colors.surface,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 8, 14, 10),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: colors.primaryText,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Attendance',
                      style: GoogleFonts.inter(
                        color: colors.primaryText,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Manage your check-in, check-out and event attendance',
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
            ],
          ),
        ),
      ),
    );
  }
}

class _AttendanceMonthCalendar extends StatelessWidget {
  const _AttendanceMonthCalendar({
    required this.monthLabel,
    required this.records,
    required this.absentDays,
  });

  final String monthLabel;
  final List<CheckInRecord> records;
  final Set<int> absentDays;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final monthDate = DateFormat('MMMM yyyy').parse(monthLabel);
    final firstDay = DateTime(monthDate.year, monthDate.month);
    final daysInMonth = DateTime(monthDate.year, monthDate.month + 1, 0).day;
    final leadingBlanks = firstDay.weekday % 7;
    final recordByDay = {
      for (final record in records)
        if (record.date.year == monthDate.year &&
            record.date.month == monthDate.month)
          record.date.day: record,
    };

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitleRow(title: monthLabel),
          const SizedBox(height: 12),
          Row(
            children: const ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map(
                  (day) => Expanded(
                    child: Center(child: _CalendarWeekdayLabel(day)),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: leadingBlanks + daysInMonth,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              if (index < leadingBlanks) return const SizedBox.shrink();
              final day = index - leadingBlanks + 1;
              final record = recordByDay[day];
              Color? fill;
              if (record != null) {
                fill = record.isLate
                    ? const Color(0xFFE89522)
                    : const Color(0xFF1E9E62);
              } else if (absentDays.contains(day)) {
                fill = colors.error;
              }

              return Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: fill?.withValues(alpha: 0.13) ?? colors.cardAlt,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: fill ?? colors.borderColor,
                    width: fill == null ? 1 : 1.2,
                  ),
                ),
                child: Text(
                  '$day',
                  style: GoogleFonts.inter(
                    color: fill ?? colors.secondaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          const Row(
            children: [
              _CalendarLegend(color: Color(0xFF1E9E62), label: 'Worked'),
              SizedBox(width: 12),
              _CalendarLegend(color: Color(0xFFE89522), label: 'Late'),
              SizedBox(width: 12),
              _CalendarLegend(color: Color(0xFFFF3B30), label: 'Absent'),
            ],
          ),
        ],
      ),
    );
  }
}

class _CalendarWeekdayLabel extends StatelessWidget {
  const _CalendarWeekdayLabel(this.day);

  final String day;

  @override
  Widget build(BuildContext context) {
    return Text(
      day,
      style: GoogleFonts.inter(
        color: context.colors.secondaryText,
        fontSize: 11,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _CalendarLegend extends StatelessWidget {
  const _CalendarLegend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: GoogleFonts.inter(
            color: context.colors.secondaryText,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _AttendanceTabs extends StatelessWidget {
  const _AttendanceTabs({required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      color: colors.surface,
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
      child: Container(
        height: 44,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: colors.cardAlt,
          borderRadius: BorderRadius.circular(16),
        ),
        child: TabBar(
          controller: controller,
          indicator: BoxDecoration(
            color: colors.brandPrimary,
            borderRadius: BorderRadius.circular(12),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: colors.secondaryText,
          labelStyle: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
          tabs: const [
            Tab(text: 'My Attendance'),
            Tab(text: 'Event Attendance'),
          ],
        ),
      ),
    );
  }
}

class AttendanceStatusCard extends StatelessWidget {
  const AttendanceStatusCard({
    super.key,
    required this.record,
    required this.now,
    required this.onActionPressed,
  });

  final CheckInRecord? record;
  final DateTime now;
  final VoidCallback onActionPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final checkedIn = record != null;
    final checkedOut = record?.checkOut != null;
    final completed = checkedIn && checkedOut;
    final buttonLabel = !checkedIn
        ? 'Check In'
        : checkedOut
            ? 'Completed'
            : 'Check Out';

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Today's Check-In Status",
                  style: _titleStyle(context),
                ),
              ),
              _StatusBadge(
                text: checkedIn ? 'Checked in' : 'Not checked in',
                active: checkedIn,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _TimeTile(
                  label: 'Check-in',
                  value: record == null
                      ? '--:-- --'
                      : _formatTime(record!.checkIn),
                  icon: Icons.login_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TimeTile(
                  label: 'Check-out',
                  value: record?.checkOut == null
                      ? '--:-- --'
                      : _formatTime(record!.checkOut!),
                  icon: Icons.logout_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: completed ? null : onActionPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.brandPrimary,
                disabledBackgroundColor: colors.borderColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Text(
                buttonLabel,
                style: GoogleFonts.inter(
                  color: completed ? colors.secondaryText : Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WorkHoursCard extends StatelessWidget {
  const WorkHoursCard({
    super.key,
    required this.record,
    required this.now,
  });

  final CheckInRecord? record;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Working Hours Today', style: _titleStyle(context)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MetricLine(
                  label: 'Duration',
                  value:
                      _formatDuration(record?.duration(now) ?? Duration.zero),
                  icon: Icons.timer_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _InfoRow(
            icon: Icons.work_history_outlined,
            label: 'Expected work time',
            value: '8:00 AM - 5:00 PM',
          ),
          const SizedBox(height: 8),
          const _InfoRow(
            icon: Icons.restaurant_outlined,
            label: 'Break time',
            value: '12:00 PM - 1:00 PM',
          ),
        ],
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return _SectionCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: colors.brandPrimary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: colors.brandPrimary, size: 19),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.inter(
              color: colors.primaryText,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              color: colors.secondaryText,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class RecentCheckRow extends StatelessWidget {
  const RecentCheckRow({
    super.key,
    required this.record,
    required this.now,
  });

  final CheckInRecord record;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final duration = record.duration(now);

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
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colors.brandPrimary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              Icons.access_time_rounded,
              color: colors.brandPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        _formatRecordDate(record.date),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: colors.primaryText,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (record.isOpen) ...[
                      const SizedBox(width: 8),
                      const _StatusBadge(text: 'Checked in', active: true),
                    ] else if (record.isLate) ...[
                      const SizedBox(width: 8),
                      const _StatusBadge(
                        text: 'Late',
                        active: true,
                        color: Color(0xFFE89522),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  '${_formatTime(record.checkIn)} - ${record.checkOut == null ? '--:-- --' : _formatTime(record.checkOut!)}',
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
          Text(
            _formatDuration(duration),
            style: GoogleFonts.inter(
              color: colors.brandPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _AbsentCheckRow extends StatelessWidget {
  const _AbsentCheckRow({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

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
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colors.error.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              Icons.event_busy_outlined,
              color: colors.error,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatRecordDate(date),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: colors.primaryText,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'No check-in record',
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
          _StatusBadge(text: 'Absent', active: true, color: colors.error),
        ],
      ),
    );
  }
}

class EventAttendanceCard extends StatelessWidget {
  const EventAttendanceCard({super.key, required this.record});

  final EventAttendanceRecord record;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final statusColor =
        record.attended ? const Color(0xFF1E9E62) : colors.error;

    return _SectionCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.brandPrimary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.event_note_outlined,
              color: colors.brandPrimary,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        record.eventName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: colors.primaryText,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    _Pill(
                      text: record.attended ? 'Attended' : 'Absent',
                      color: statusColor,
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  record.organizer,
                  style: GoogleFonts.inter(
                    color: colors.secondaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                _EventMetaLine(
                    icon: Icons.calendar_today_outlined, text: record.date),
                const SizedBox(height: 5),
                _EventMetaLine(
                    icon: Icons.schedule_outlined, text: record.time),
                const SizedBox(height: 5),
                _EventMetaLine(
                    icon: Icons.place_outlined, text: record.location),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _Pill(text: record.type, color: colors.brandPrimary),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FilterDropdownButton<T> extends StatelessWidget {
  const FilterDropdownButton({
    super.key,
    required this.value,
    required this.values,
    required this.labelForValue,
    required this.onChanged,
  });

  final T value;
  final List<T> values;
  final String Function(T value) labelForValue;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PopupMenuButton<T>(
      onSelected: onChanged,
      color: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (context) => values
          .map(
            (item) => PopupMenuItem<T>(
              value: item,
              child: Text(
                labelForValue(item),
                style: GoogleFonts.inter(
                  color:
                      item == value ? colors.brandPrimary : colors.primaryText,
                  fontWeight: item == value ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
          )
          .toList(),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: colors.cardAlt,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.borderColor),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                labelForValue(value),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: colors.primaryText,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded,
                color: colors.secondaryText),
          ],
        ),
      ),
    );
  }
}

class EmptyRecordsState extends StatelessWidget {
  const EmptyRecordsState({super.key, required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return _SectionCard(
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: colors.brandPrimary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inbox_outlined,
              color: colors.brandPrimary,
              size: 34,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No records found.',
            style: GoogleFonts.inter(
              color: colors.primaryText,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'There are no events for this type based on your selected filters.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: colors.secondaryText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: onReset,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.brandPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'View All Events',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SectionTitleRow extends StatelessWidget {
  const SectionTitleRow({
    super.key,
    required this.title,
    this.actionLabel,
    this.onActionTap,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: _titleStyle(context),
          ),
        ),
        if (actionLabel != null)
          GestureDetector(
            onTap: onActionTap,
            child: Text(
              actionLabel!,
              style: GoogleFonts.inter(
                color: colors.brandPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: padding,
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.text, required this.active, this.color});

  final String text;
  final bool active;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final badgeColor =
        color ?? (active ? const Color(0xFF1E9E62) : colors.secondaryText);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          color: badgeColor,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _TimeTile extends StatelessWidget {
  const _TimeTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.cardAlt,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colors.brandPrimary, size: 19),
          const SizedBox(height: 10),
          Text(
            label,
            style: GoogleFonts.inter(
              color: colors.secondaryText,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: GoogleFonts.inter(
              color: colors.primaryText,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricLine extends StatelessWidget {
  const _MetricLine({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.cardAlt,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: colors.brandPrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: colors.secondaryText,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              color: colors.primaryText,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Icon(icon, color: colors.brandPrimary, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: colors.secondaryText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            color: colors.primaryText,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _EventMetaLine extends StatelessWidget {
  const _EventMetaLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Icon(icon, color: colors.secondaryText, size: 15),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: colors.secondaryText,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.brandPrimary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(Icons.tips_and_updates_outlined, color: colors.brandPrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tip: remember to check out before leaving campus to keep your work attendance complete.',
              style: GoogleFonts.inter(
                color: colors.primaryText,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

TextStyle _titleStyle(BuildContext context) {
  final colors = context.colors;
  return GoogleFonts.inter(
    color: colors.primaryText,
    fontSize: 17,
    fontWeight: FontWeight.w800,
  );
}

String _formatTime(DateTime time) => DateFormat('h:mm a').format(time);

String _formatRecordDate(DateTime date) {
  final now = DateTime.now();
  final isToday =
      date.year == now.year && date.month == now.month && date.day == now.day;
  if (isToday) return 'Today';
  return DateFormat('MMM d, yyyy').format(date);
}

String _formatDuration(Duration duration) {
  if (duration.isNegative) return '0h 0m';
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  return '${hours}h ${minutes}m';
}
