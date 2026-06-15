import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../database_helper.dart';

class StudentAttendanceContent extends StatefulWidget {
  const StudentAttendanceContent({
    super.key,
    this.courseData = const {},
  });

  final Map<String, String> courseData;

  @override
  State<StudentAttendanceContent> createState() =>
      _StudentAttendanceContentState();
}

class _StudentAttendanceContentState extends State<StudentAttendanceContent> {
  static const Color _primaryBlue = Color(0xFF0422A7);
  static const Color _accentBlue = Color(0xFF006BFF);
  static const Color _softBlueGrey = Color(0xFFB8C7DE);
  static const Color _background = Color(0xFFF5F8FE);
  static const Color _textDark = Color(0xFF071A52);
  static const Color _textMuted = Color(0xFF718096);
  static const int _pageSize = 6;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _fromController =
      TextEditingController(text: '0');
  final TextEditingController _toController =
      TextEditingController(text: '100');

  String _selectedMonth = 'May 2025';
  String _searchQuery = '';
  String? _filterErrorText;
  double? _fromPercent = 0;
  double? _toPercent = 100;
  int _currentPage = 0;
  bool _isLoading = true;
  List<Map<String, dynamic>> _allSessions = [];
  List<Map<String, dynamic>> _sessions = [];
  List<Map<String, dynamic>> _schedules = [];
  List<_StudentAttendanceRecord> _students = [];
  String? _selectedSessionId;
  String _typeFilter = 'All';
  String _monthFilter = 'All Months';
  String _recordStatusFilter = 'All';
  String? _loadErrorText;

  _MonthlyAttendance get _currentMonthData {
    if (_selectedSessionId == null) {
      var present = 0;
      var totalAttendances = 0;
      var totalStudents = 0;

      for (final session in _sessions) {
        final sessionPresent = _toInt(session['Present_Count']);
        final sessionTotal = _toInt(session['Total_Count']);
        present += sessionPresent;
        totalAttendances += sessionTotal;
        if (sessionTotal > totalStudents) totalStudents = sessionTotal;
      }

      final absent = (totalAttendances - present).clamp(0, totalAttendances);
      final percent =
          totalAttendances == 0 ? 0.0 : (present / totalAttendances) * 100;
      final absentPercent =
          totalAttendances == 0 ? 0.0 : (absent / totalAttendances) * 100;

      return _MonthlyAttendance(
        month: _monthFilter,
        averagePercent: percent,
        presentPercent: percent,
        absentPercent: absentPercent,
        presentCount: present,
        absentCount: absent,
        totalStudents: totalStudents,
      );
    }

    final total = _students.length;
    final present = _students.where((s) => s.attendancePercent == 100).length;
    final absent = total - present;
    final percent = total == 0 ? 0.0 : (present / total) * 100;
    return _MonthlyAttendance(
      month: _selectedMonth,
      averagePercent: percent,
      presentPercent: percent,
      absentPercent: total == 0 ? 0 : (absent / total) * 100,
      presentCount: present,
      absentCount: absent,
      totalStudents: total,
    );
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  List<_StudentAttendanceRecord> get _filteredStudents {
    final query = _searchQuery.trim().toLowerCase();

    return _students.where((student) {
      final matchesSearch = query.isEmpty ||
          student.name.toLowerCase().contains(query) ||
          student.matricNo.toLowerCase().contains(query);
      final matchesFrom = _fromPercent == null ||
          student.attendancePercent >= _fromPercent!.clamp(0, 100);
      final matchesTo = _toPercent == null ||
          student.attendancePercent <= _toPercent!.clamp(0, 100);

      final matchesStatus = _recordStatusFilter == 'All' ||
          (_recordStatusFilter == 'Attend' &&
              student.attendancePercent == 100) ||
          (_recordStatusFilter == 'Absent' && student.attendancePercent == 0);

      return matchesSearch && matchesFrom && matchesTo && matchesStatus;
    }).toList();
  }

  List<_StudentAttendanceRecord> get _visibleStudents {
    final filtered = _filteredStudents;
    final start = (_currentPage * _pageSize).clamp(0, filtered.length);
    final end = (start + _pageSize).clamp(0, filtered.length);
    return filtered.sublist(start, end);
  }

  int get _totalPages {
    final filteredCount = _filteredStudents.length;
    if (filteredCount == 0) return 1;
    return (filteredCount / _pageSize).ceil();
  }

  @override
  void initState() {
    super.initState();
    _loadAttendanceData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  Future<void> _loadAttendanceData() async {
    final sectionId = widget.courseData['section_id'] ?? '';
    if (sectionId.isEmpty) {
      setState(() {
        _loadErrorText = 'Section not found.';
        _isLoading = false;
      });
      return;
    }
    try {
      final schedules =
          await DatabaseHelper.instance.getAttendanceSchedules(sectionId);
      final allSessions =
          await DatabaseHelper.instance.getAttendanceSessions(sectionId);
      final filteredSessions = allSessions.where((session) {
        if (_monthFilter != 'All Months') {
          final date = session['Session_Date']?.toString() ?? '';
          try {
            final label = DateFormat('MMMM yyyy').format(DateTime.parse(date));
            if (label != _monthFilter) return false;
          } catch (_) {}
        }
        if (_typeFilter == 'All') return true;
        final type = session['Class_Type']?.toString().toUpperCase() ?? '';
        if (_typeFilter == 'Lecture') {
          return type == 'LECTURE' || type == 'LECTURER';
        }
        return type == 'TUTORIAL';
      }).toList();

      var selectedId = _selectedSessionId;
      if (selectedId != null &&
          !filteredSessions
              .any((s) => s['Session_ID'].toString() == selectedId)) {
        selectedId = null;
      }

      var students = <_StudentAttendanceRecord>[];
      if (selectedId != null) {
        final records =
            await DatabaseHelper.instance.getAttendanceRecords(selectedId);
        students = records.map((row) {
          final isPresent = row['Attendance_Status']?.toString() == 'Present';
          return _StudentAttendanceRecord(
            name: row['Student_Name']?.toString() ?? '',
            matricNo: row['Student_ID']?.toString() ?? '',
            attendancePercent: isPresent ? 100 : 0,
          );
        }).toList();
      }

      if (!mounted) return;
      setState(() {
        _allSessions = allSessions;
        _schedules = schedules;
        _sessions = filteredSessions;
        _selectedSessionId = selectedId;
        _students = students;
        _selectedMonth = _monthFilter;
        _loadErrorText = null;
        _isLoading = false;
        _currentPage = 0;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadErrorText = 'Attendance data could not be loaded: $e';
        _isLoading = false;
      });
    }
  }

  String get _selectedSessionTitle {
    final selected = _sessions.where(
      (s) => s['Session_ID'].toString() == _selectedSessionId,
    );
    if (selected.isEmpty) return 'Attendance Details';
    final row = selected.first;
    final type = row['Class_Type']?.toString() ?? '';
    return '${_formatDate(row['Session_Date']?.toString() ?? '')} $type';
  }

  List<String> get _monthOptions {
    final months = <String>{'All Months'};
    for (final session in _allSessions) {
      final rawDate = session['Session_Date']?.toString() ?? '';
      try {
        months.add(DateFormat('MMMM yyyy').format(DateTime.parse(rawDate)));
      } catch (_) {}
    }
    return months.toList();
  }

  void _applyFilter() {
    final fromText = _fromController.text.trim();
    final toText = _toController.text.trim();
    final fromValue = double.tryParse(fromText);
    final toValue = double.tryParse(toText);

    String? errorText;
    if (fromText.isEmpty || toText.isEmpty) {
      errorText = 'Min and Max attendance are required.';
    } else if (fromValue == null || toValue == null) {
      errorText = 'Attendance filter must be numeric.';
    } else if (fromValue < 0 || fromValue > 100) {
      errorText = 'Min attendance must be between 0 and 100.';
    } else if (toValue < 0 || toValue > 100) {
      errorText = 'Max attendance must be between 0 and 100.';
    } else if (fromValue >= toValue) {
      errorText = 'Min attendance must be smaller than Max attendance.';
    }

    if (errorText != null) {
      setState(() => _filterErrorText = errorText);
      return;
    }

    setState(() {
      _searchQuery = _searchController.text;
      _fromPercent = fromValue;
      _toPercent = toValue;
      _filterErrorText = null;
      _currentPage = 0;
    });
  }

  void _goToPreviousPage() {
    if (_currentPage == 0) return;
    setState(() => _currentPage--);
  }

  void _goToNextPage() {
    if (_currentPage >= _totalPages - 1) return;
    setState(() => _currentPage++);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadErrorText != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _loadErrorText!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: _textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  setState(() => _isLoading = true);
                  _loadAttendanceData();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 116),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 18),
              _buildOverviewCard(),
              const SizedBox(height: 18),
              _buildSummaryCards(),
              const SizedBox(height: 18),
              _buildRecordsCard(),
            ],
          ),
        ),
        Positioned(
          right: 20,
          bottom: 24,
          child: FloatingActionButton(
            heroTag: 'add-attendance-session',
            onPressed: () => _showSessionDialog(),
            backgroundColor: _primaryBlue,
            foregroundColor: Colors.white,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (_selectedSessionId != null) ...[
          IconButton(
            onPressed: () {
              setState(() {
                _selectedSessionId = null;
                _students = [];
                _currentPage = 0;
              });
            },
            icon: const Icon(Icons.arrow_back),
            color: _textDark,
          ),
          const SizedBox(width: 4),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _selectedSessionId == null
                    ? 'Student Attendance'
                    : _selectedSessionTitle,
                style: GoogleFonts.poppins(
                  color: _textDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 25,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _selectedSessionId == null
                    ? 'Track and analyze attendance for this class.'
                    : 'Attendance details for selected session.',
                style: GoogleFonts.poppins(
                  color: _textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(String value) {
    try {
      return DateFormat('d MMM yyyy').format(DateTime.parse(value));
    } catch (_) {
      return value;
    }
  }

  String _formatTime(String value) {
    try {
      return DateFormat('h:mm a').format(DateFormat('HH:mm').parse(value));
    } catch (_) {
      return value;
    }
  }

  TimeOfDay _parseTimeOfDay(String value) {
    final parts = value.split(':');
    if (parts.length >= 2) {
      return TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 8,
        minute: int.tryParse(parts[1]) ?? 0,
      );
    }
    return const TimeOfDay(hour: 8, minute: 0);
  }

  String _formatTimeOfDay(TimeOfDay value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _selectSession(Map<String, dynamic> session) async {
    setState(() {
      _selectedSessionId = session['Session_ID'].toString();
      _isLoading = true;
      _currentPage = 0;
    });
    await _loadAttendanceData();
  }

  Future<void> _deleteSession(Map<String, dynamic> session) async {
    await DatabaseHelper.instance
        .deleteAttendanceSession(session['Session_ID'].toString());
    if (!mounted) return;
    setState(() {
      if (_selectedSessionId == session['Session_ID'].toString()) {
        _selectedSessionId = null;
        _students = [];
      }
      _isLoading = true;
    });
    await _loadAttendanceData();
  }

  Future<void> _toggleSessionStatus(Map<String, dynamic> session) async {
    final current = session['Status']?.toString() ?? 'Open';
    final next = current == 'Open' ? 'Closed' : 'Open';
    await DatabaseHelper.instance.updateAttendanceSessionStatus(
      sessionId: session['Session_ID'].toString(),
      status: next,
    );
    if (!mounted) return;
    setState(() => _isLoading = true);
    await _loadAttendanceData();
  }

  void _showCodeDialog(Map<String, dynamic> session) {
    showDialog<void>(
      context: context,
      builder: (context) {
        final code = session['Attendance_Code']?.toString() ?? '';
        final status = session['Status']?.toString() ?? 'Open';
        return AlertDialog(
          title: Text(
            'Attendance Code',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _QrCodePreview(code: code),
              const SizedBox(height: 16),
              SelectableText(
                code,
                style: GoogleFonts.poppins(
                  color: _textDark,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Status: $status',
                style: GoogleFonts.poppins(
                  color: _textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _toggleSessionStatus(session);
              },
              child: Text(
                  status == 'Open' ? 'Close Attendance' : 'Open Attendance'),
            ),
          ],
        );
      },
    );
  }

  void _showFloatingSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 112),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _showSessionDialog({Map<String, dynamic>? session}) async {
    if (_schedules.isEmpty) {
      _showFloatingSnack('No lecture or tutorial schedule found.');
      return;
    }
    var selectedSchedule = session == null
        ? _schedules.first
        : _schedules.firstWhere(
            (s) =>
                s['Schedule_ID'].toString() ==
                session['Schedule_ID'].toString(),
            orElse: () => _schedules.first,
          );
    var selectedDate = session == null
        ? DateTime.now()
        : DateTime.tryParse(session['Session_Date']?.toString() ?? '') ??
            DateTime.now();
    var startTime = _parseTimeOfDay(
      session?['Start_Time']?.toString() ??
          selectedSchedule['Start_Time']?.toString() ??
          '08:00',
    );
    var endTime = _parseTimeOfDay(
      session?['End_Time']?.toString() ??
          selectedSchedule['End_Time']?.toString() ??
          '10:00',
    );

    final created = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                session == null ? 'Add Attendance' : 'Edit Attendance',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selectedSchedule['Schedule_ID'].toString(),
                    items: _schedules.map((schedule) {
                      final type = schedule['Class_Type']?.toString() ?? '';
                      return DropdownMenuItem(
                        value: schedule['Schedule_ID'].toString(),
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      final next = _schedules.firstWhere(
                        (s) => s['Schedule_ID'].toString() == value,
                      );
                      setDialogState(() {
                        selectedSchedule = next;
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Class Type'),
                  ),
                  const SizedBox(height: 14),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.event),
                    title: Text(
                        DateFormat('EEEE, d MMM yyyy').format(selectedDate)),
                    subtitle: const Text('Session date'),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setDialogState(() => selectedDate = picked);
                      }
                    },
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.schedule),
                          title: Text(startTime.format(context)),
                          subtitle: const Text('Start time'),
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: startTime,
                            );
                            if (picked != null) {
                              setDialogState(() => startTime = picked);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.schedule),
                          title: Text(endTime.format(context)),
                          subtitle: const Text('End time'),
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: endTime,
                            );
                            if (picked != null) {
                              setDialogState(() => endTime = picked);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final start = _formatTimeOfDay(startTime);
                    final end = _formatTimeOfDay(endTime);
                    String? newCode;
                    if (session == null) {
                      final result =
                          await DatabaseHelper.instance.createAttendanceSession(
                        scheduleId: selectedSchedule['Schedule_ID'].toString(),
                        sessionDate:
                            DateFormat('yyyy-MM-dd').format(selectedDate),
                        startTime: start,
                        endTime: end,
                      );
                      newCode = result['Attendance_Code']?.toString();
                    } else {
                      await DatabaseHelper.instance.updateAttendanceSession(
                        sessionId: session['Session_ID'].toString(),
                        scheduleId: selectedSchedule['Schedule_ID'].toString(),
                        sessionDate:
                            DateFormat('yyyy-MM-dd').format(selectedDate),
                        startTime: start,
                        endTime: end,
                      );
                    }
                    if (context.mounted) {
                      _showFloatingSnack(
                        session == null
                            ? 'Attendance code: $newCode'
                            : 'Attendance updated',
                      );
                    }
                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext, true);
                    }
                  },
                  child: Text(session == null ? 'Create' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (created == true) {
      await _loadAttendanceData();
    }
  }

  Widget _buildOverviewCard() {
    final data = _currentMonthData;

    return _SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Monthly Attendance Overview',
                  style: GoogleFonts.poppins(
                    color: _textDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _MonthDropdown(
                selectedMonth: _monthFilter,
                months: _monthOptions,
                onChanged: (month) {
                  if (month == null) return;
                  setState(() {
                    _monthFilter = month;
                    _selectedSessionId = null;
                    _students = [];
                    _isLoading = true;
                  });
                  _loadAttendanceData();
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 680;

              final chart = _AttendanceDoughnutChart(
                averagePercent: data.averagePercent,
                presentPercent: data.presentPercent,
                absentPercent: data.absentPercent,
              );
              final legend = _AttendanceLegend(data: data);

              if (isCompact) {
                return Column(
                  children: [
                    chart,
                    const SizedBox(height: 22),
                    legend,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(flex: 3, child: chart),
                  const SizedBox(width: 28),
                  Expanded(flex: 2, child: legend),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    final data = _currentMonthData;
    final cards = [
      _SummaryItem(
        title: 'Average Attendance',
        value: '${data.averagePercent.toStringAsFixed(1)}%',
        icon: Icons.analytics_outlined,
        tint: _primaryBlue,
      ),
      _SummaryItem(
        title: 'Present',
        value: data.presentCount.toString(),
        icon: Icons.check_circle_outline,
        tint: _accentBlue,
      ),
      _SummaryItem(
        title: 'Absent',
        value: data.absentCount.toString(),
        icon: Icons.cancel_outlined,
        tint: _softBlueGrey,
      ),
      _SummaryItem(
        title: 'Total Students',
        value: data.totalStudents.toString(),
        icon: Icons.groups_outlined,
        tint: const Color(0xFF4D5E80),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 520 ? 2 : 4;
        const spacing = 12.0;
        final itemWidth =
            (constraints.maxWidth - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: cards
              .map(
                (item) => SizedBox(
                  width: itemWidth,
                  child: _SummaryCard(item: item),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildRecordsCard() {
    if (_selectedSessionId == null) {
      return _buildHistoryCard();
    }

    return _SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Student Attendance Records',
            style: GoogleFonts.poppins(
              color: _textDark,
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerLeft,
            child: DropdownButton<String>(
              value: _recordStatusFilter,
              items: const [
                DropdownMenuItem(value: 'All', child: Text('All')),
                DropdownMenuItem(value: 'Attend', child: Text('Attend')),
                DropdownMenuItem(value: 'Absent', child: Text('Absent')),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _recordStatusFilter = value;
                  _currentPage = 0;
                });
              },
            ),
          ),
          const SizedBox(height: 8),
          _FilterRow(
            searchController: _searchController,
            fromController: _fromController,
            toController: _toController,
            errorText: _filterErrorText,
            onApply: _applyFilter,
          ),
          const SizedBox(height: 18),
          _AttendanceTable(
            students: _visibleStudents,
            absoluteStartIndex: _currentPage * _pageSize,
          ),
          const SizedBox(height: 18),
          _PaginationFooter(
            currentPage: _currentPage,
            totalPages: _totalPages,
            filteredCount: _filteredStudents.length,
            visibleCount: _visibleStudents.length,
            pageSize: _pageSize,
            onPrevious: _goToPreviousPage,
            onNext: _goToNextPage,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard() {
    return _SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Attendance History',
            style: GoogleFonts.poppins(
              color: _textDark,
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              SizedBox(
                width: 132,
                child: DropdownButton<String>(
                  value: _typeFilter,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All')),
                    DropdownMenuItem(value: 'Lecture', child: Text('Lecture')),
                    DropdownMenuItem(
                        value: 'Tutorial', child: Text('Tutorial')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _typeFilter = value;
                      _isLoading = true;
                    });
                    _loadAttendanceData();
                  },
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 42,
                height: 42,
                child: IconButton(
                  onPressed: () {
                    if (_sessions.isEmpty) {
                      _showFloatingSnack('No attendance has been created yet.');
                      return;
                    }
                    _showCodeDialog(_sessions.first);
                  },
                  icon: const Icon(Icons.qr_code_2),
                  tooltip: 'Show code',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_sessions.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 34),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE8EEF8)),
              ),
              child: Center(
                child: Text(
                  'No attendance history',
                  style: GoogleFonts.poppins(
                    color: _textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          else
            Column(
              children: _sessions.map((session) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _AttendanceHistoryTile(
                    session: session,
                    dateLabel:
                        _formatDate(session['Session_Date']?.toString() ?? ''),
                    startTime:
                        _formatTime(session['Start_Time']?.toString() ?? ''),
                    endTime: _formatTime(session['End_Time']?.toString() ?? ''),
                    onTap: () => _selectSession(session),
                    onCode: () => _showCodeDialog(session),
                    onEdit: () => _showSessionDialog(session: session),
                    onDelete: () => _deleteSession(session),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _MonthlyAttendance {
  final String month;
  final double averagePercent;
  final double presentPercent;
  final double absentPercent;
  final int presentCount;
  final int absentCount;
  final int totalStudents;

  const _MonthlyAttendance({
    required this.month,
    required this.averagePercent,
    required this.presentPercent,
    required this.absentPercent,
    required this.presentCount,
    required this.absentCount,
    required this.totalStudents,
  });
}

class _AttendanceHistoryTile extends StatelessWidget {
  final Map<String, dynamic> session;
  final String dateLabel;
  final String startTime;
  final String endTime;
  final VoidCallback onTap;
  final VoidCallback onCode;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AttendanceHistoryTile({
    required this.session,
    required this.dateLabel,
    required this.startTime,
    required this.endTime,
    required this.onTap,
    required this.onCode,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final type = session['Class_Type']?.toString() ?? 'Attendance';
    final status = session['Status']?.toString() ?? 'Open';
    final present =
        int.tryParse(session['Present_Count']?.toString() ?? '0') ?? 0;
    final total = int.tryParse(session['Total_Count']?.toString() ?? '0') ?? 0;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 14, 32, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE8EEF8)),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _StudentAttendanceContentState._primaryBlue
                          .withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.fact_check_outlined,
                      color: _StudentAttendanceContentState._primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$dateLabel $type',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: _StudentAttendanceContentState._textDark,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _HistoryMetaChip(
                          icon: Icons.schedule,
                          label: '$startTime - $endTime',
                        ),
                        const SizedBox(height: 4),
                        _HistoryMetaChip(
                          icon: Icons.groups_outlined,
                          label: '$present/$total attend',
                        ),
                        const SizedBox(height: 9),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: status == 'Open'
                                  ? const Color(0xFFE8F5E9)
                                  : const Color(0xFFFFEBEE),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              status,
                              style: GoogleFonts.poppins(
                                color: status == 'Open'
                                    ? const Color(0xFF2E7D32)
                                    : const Color(0xFFC62828),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                right: -10,
                top: -12,
                child: PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'code') onCode();
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'code', child: Text('Code / QR')),
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
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

class _HistoryMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HistoryMetaChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: _StudentAttendanceContentState._textMuted,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: _StudentAttendanceContentState._textMuted,
              fontWeight: FontWeight.w600,
              fontSize: 11.5,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _QrCodePreview extends StatelessWidget {
  final String code;

  const _QrCodePreview({required this.code});

  @override
  Widget build(BuildContext context) {
    const size = 9;
    final seed = code.codeUnits.fold<int>(0, (sum, value) => sum + value);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EEF8)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(size, (row) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(size, (col) {
              final finder = (row < 3 && col < 3) ||
                  (row < 3 && col > 5) ||
                  (row > 5 && col < 3);
              final filled = finder || ((row * 7 + col * 11 + seed) % 3 == 0);
              return Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.all(1),
                color: filled
                    ? _StudentAttendanceContentState._textDark
                    : Colors.white,
              );
            }),
          );
        }),
      ),
    );
  }
}

class _StudentAttendanceRecord {
  final String name;
  final String matricNo;
  final int attendancePercent;

  const _StudentAttendanceRecord({
    required this.name,
    required this.matricNo,
    required this.attendancePercent,
  });
}

class _SummaryItem {
  final String title;
  final String value;
  final IconData icon;
  final Color tint;

  const _SummaryItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.tint,
  });
}

class _SoftCard extends StatelessWidget {
  final Widget child;

  const _SoftCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8EEF8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _MonthDropdown extends StatelessWidget {
  final String selectedMonth;
  final List<String> months;
  final ValueChanged<String?> onChanged;

  const _MonthDropdown({
    required this.selectedMonth,
    required this.months,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: _StudentAttendanceContentState._background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDDE6F6)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedMonth,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: _StudentAttendanceContentState._primaryBlue,
          ),
          items: months
              .map(
                (month) => DropdownMenuItem<String>(
                  value: month,
                  child: Text(
                    month,
                    style: GoogleFonts.poppins(
                      color: _StudentAttendanceContentState._textDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _AttendanceDoughnutChart extends StatelessWidget {
  final double averagePercent;
  final double presentPercent;
  final double absentPercent;

  const _AttendanceDoughnutChart({
    required this.averagePercent,
    required this.presentPercent,
    required this.absentPercent,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: Center(
        child: SizedBox(
          width: 230,
          height: 230,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size.square(230),
                painter: _DoughnutPainter(
                  presentPercent: presentPercent,
                  absentPercent: absentPercent,
                  presentColor: _StudentAttendanceContentState._primaryBlue,
                  absentColor: _StudentAttendanceContentState._softBlueGrey,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${averagePercent.toStringAsFixed(1)}%',
                    style: GoogleFonts.poppins(
                      color: _StudentAttendanceContentState._textDark,
                      fontSize: 27,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Average Attendance',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: _StudentAttendanceContentState._textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DoughnutPainter extends CustomPainter {
  final double presentPercent;
  final double absentPercent;
  final Color presentColor;
  final Color absentColor;

  const _DoughnutPainter({
    required this.presentPercent,
    required this.absentPercent,
    required this.presentColor,
    required this.absentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2;
    final strokeWidth = radius * 0.24;
    final rect = Rect.fromCircle(
      center: center,
      radius: radius - (strokeWidth / 2),
    );

    final backgroundPaint = Paint()
      ..color = const Color(0xFFEAF0FA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final presentPaint = Paint()
      ..color = presentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final absentPaint = Paint()
      ..color = absentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0, math.pi * 2, false, backgroundPaint);

    final total = math.max(1, presentPercent + absentPercent);
    const gap = 0.06;
    final presentSweep = (presentPercent / total) * math.pi * 2;
    final absentSweep = (absentPercent / total) * math.pi * 2;
    const startAngle = -math.pi / 2;

    canvas.drawArc(
      rect,
      startAngle,
      math.max(0, presentSweep - gap),
      false,
      presentPaint,
    );
    canvas.drawArc(
      rect,
      startAngle + presentSweep,
      math.max(0, absentSweep - gap),
      false,
      absentPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _DoughnutPainter oldDelegate) {
    return oldDelegate.presentPercent != presentPercent ||
        oldDelegate.absentPercent != absentPercent ||
        oldDelegate.presentColor != presentColor ||
        oldDelegate.absentColor != absentColor;
  }
}

class _AttendanceLegend extends StatelessWidget {
  final _MonthlyAttendance data;

  const _AttendanceLegend({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EEF8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LegendRow(
            color: _StudentAttendanceContentState._primaryBlue,
            label: 'Present',
            value:
                '${data.presentPercent.toStringAsFixed(1)}% (${data.presentCount})',
          ),
          const SizedBox(height: 14),
          _LegendRow(
            color: _StudentAttendanceContentState._softBlueGrey,
            label: 'Absent',
            value:
                '${data.absentPercent.toStringAsFixed(1)}% (${data.absentCount})',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Color(0xFFE0E8F5), height: 1),
          ),
          Row(
            children: [
              const Icon(
                Icons.groups_outlined,
                color: _StudentAttendanceContentState._primaryBlue,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Total Students',
                  style: GoogleFonts.poppins(
                    color: _StudentAttendanceContentState._textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                data.totalStudents.toString(),
                style: GoogleFonts.poppins(
                  color: _StudentAttendanceContentState._textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _LegendRow({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: _StudentAttendanceContentState._textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: _StudentAttendanceContentState._textDark,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final _SummaryItem item;

  const _SummaryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 118),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8EEF8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: item.tint.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: item.tint, size: 21),
          ),
          const SizedBox(height: 14),
          Text(
            item.value,
            style: GoogleFonts.poppins(
              color: _StudentAttendanceContentState._textDark,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            item.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: _StudentAttendanceContentState._textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  final TextEditingController searchController;
  final TextEditingController fromController;
  final TextEditingController toController;
  final String? errorText;
  final VoidCallback onApply;

  const _FilterRow({
    required this.searchController,
    required this.fromController,
    required this.toController,
    required this.errorText,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 760;
        final search = _SearchField(controller: searchController);
        final range = Row(
          children: [
            Expanded(
              child: _PercentField(
                label: 'Min',
                controller: fromController,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _PercentField(
                label: 'Max',
                controller: toController,
              ),
            ),
          ],
        );

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFF),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE4EBF8)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: _StudentAttendanceContentState._primaryBlue
                          .withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.filter_alt_outlined,
                      color: _StudentAttendanceContentState._primaryBlue,
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Filter Students',
                      style: GoogleFonts.poppins(
                        color: _StudentAttendanceContentState._textDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (!isCompact) _ApplyButton(onPressed: onApply),
                ],
              ),
              const SizedBox(height: 12),
              if (isCompact) ...[
                search,
                const SizedBox(height: 10),
                range,
                const SizedBox(height: 10),
                _ApplyButton(onPressed: onApply),
              ] else
                Row(
                  children: [
                    Expanded(flex: 3, child: search),
                    const SizedBox(width: 12),
                    Expanded(flex: 2, child: range),
                  ],
                ),
              if (errorText != null) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Color(0xFFE53935),
                      size: 17,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        errorText!,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFE53935),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;

  const _SearchField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _InputFrame(
      child: TextField(
        controller: controller,
        style: GoogleFonts.poppins(fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Search student',
          hintStyle: GoogleFonts.poppins(
            color: _StudentAttendanceContentState._textMuted,
            fontSize: 13,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: _StudentAttendanceContentState._textMuted,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
        ),
        onSubmitted: (_) => FocusScope.of(context).unfocus(),
      ),
    );
  }
}

class _PercentField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _PercentField({
    required this.label,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return _InputFrame(
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: GoogleFonts.poppins(fontSize: 13),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            color: _StudentAttendanceContentState._textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          hintText: '0',
          hintStyle: GoogleFonts.poppins(
            color: _StudentAttendanceContentState._textMuted,
            fontSize: 13,
          ),
          suffixText: '%',
          suffixStyle: GoogleFonts.poppins(
            color: _StudentAttendanceContentState._textMuted,
            fontWeight: FontWeight.w600,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        ),
        onSubmitted: (_) => FocusScope.of(context).unfocus(),
      ),
    );
  }
}

class _InputFrame extends StatelessWidget {
  final Widget child;

  const _InputFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDDE6F6)),
      ),
      child: child,
    );
  }
}

class _ApplyButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _ApplyButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.tune, size: 18),
        label: Text(
          'Apply Filter',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 12),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _StudentAttendanceContentState._primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

class _AttendanceTable extends StatelessWidget {
  final List<_StudentAttendanceRecord> students;
  final int absoluteStartIndex;

  const _AttendanceTable({
    required this.students,
    required this.absoluteStartIndex,
  });

  @override
  Widget build(BuildContext context) {
    if (students.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 34),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8EEF8)),
        ),
        child: Column(
          children: [
            Icon(Icons.search_off, color: Colors.grey.shade400, size: 34),
            const SizedBox(height: 10),
            Text(
              'No students found',
              style: GoogleFonts.poppins(
                color: _StudentAttendanceContentState._textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 620) {
          return Column(
            children: students.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _AttendanceStudentCard(
                  index: absoluteStartIndex + entry.key + 1,
                  student: entry.value,
                ),
              );
            }).toList(),
          );
        }

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE8EEF8)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: math.max(620, constraints.maxWidth),
                child: Column(
                  children: [
                    const _TableHeader(),
                    ...students.asMap().entries.map(
                          (entry) => _AttendanceTableRow(
                            index: absoluteStartIndex + entry.key + 1,
                            student: entry.value,
                            isEven: entry.key.isEven,
                          ),
                        ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AttendanceStudentCard extends StatelessWidget {
  final int index;
  final _StudentAttendanceRecord student;

  const _AttendanceStudentCard({
    required this.index,
    required this.student,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EEF8)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F5FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              index.toString(),
              style: GoogleFonts.poppins(
                color: _StudentAttendanceContentState._primaryBlue,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: _StudentAttendanceContentState._textDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  student.matricNo,
                  style: GoogleFonts.poppins(
                    color: _StudentAttendanceContentState._textMuted,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _AttendancePercentBadge(percent: student.attendancePercent),
        ],
      ),
    );
  }
}

class _AttendancePercentBadge extends StatelessWidget {
  final int percent;

  const _AttendancePercentBadge({required this.percent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color:
            _StudentAttendanceContentState._primaryBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$percent%',
        style: GoogleFonts.poppins(
          color: _StudentAttendanceContentState._primaryBlue,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF0F5FF),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: const Row(
        children: [
          _HeaderCell('#', width: 56),
          _HeaderCell('Student Name', flex: 3),
          _HeaderCell('Matric No.', flex: 2),
          _HeaderCell('Attendance %', flex: 2, alignRight: true),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  final int flex;
  final double? width;
  final bool alignRight;

  const _HeaderCell(
    this.text, {
    this.flex = 1,
    this.width,
    this.alignRight = false,
  });

  @override
  Widget build(BuildContext context) {
    final label = Text(
      text,
      textAlign: alignRight ? TextAlign.right : TextAlign.left,
      style: GoogleFonts.poppins(
        color: _StudentAttendanceContentState._textDark,
        fontWeight: FontWeight.w700,
        fontSize: 12.5,
      ),
    );

    if (width != null) {
      return SizedBox(width: width, child: label);
    }
    return Expanded(flex: flex, child: label);
  }
}

class _AttendanceTableRow extends StatelessWidget {
  final int index;
  final _StudentAttendanceRecord student;
  final bool isEven;

  const _AttendanceTableRow({
    required this.index,
    required this.student,
    required this.isEven,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isEven ? Colors.white : const Color(0xFFF9FBFF),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Text(
              index.toString(),
              style: _rowStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              student.name,
              style: _rowStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              student.matricNo,
              style:
                  _rowStyle(color: _StudentAttendanceContentState._textMuted),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child:
                  _AttendancePercentBadge(percent: student.attendancePercent),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _rowStyle({
    Color color = _StudentAttendanceContentState._textDark,
    FontWeight fontWeight = FontWeight.w500,
  }) {
    return GoogleFonts.poppins(
      color: color,
      fontWeight: fontWeight,
      fontSize: 13,
    );
  }
}

class _PaginationFooter extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int filteredCount;
  final int visibleCount;
  final int pageSize;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _PaginationFooter({
    required this.currentPage,
    required this.totalPages,
    required this.filteredCount,
    required this.visibleCount,
    required this.pageSize,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final start = filteredCount == 0 ? 0 : (currentPage * pageSize) + 1;
    final end = filteredCount == 0 ? 0 : start + visibleCount - 1;

    return LayoutBuilder(
      builder: (context, constraints) {
        final text = Text(
          'Showing $start to $end of $filteredCount students',
          style: GoogleFonts.poppins(
            color: _StudentAttendanceContentState._textMuted,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        );
        final controls = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PageButton(
              icon: Icons.chevron_left,
              enabled: currentPage > 0,
              onTap: onPrevious,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                '${currentPage + 1} / $totalPages',
                style: GoogleFonts.poppins(
                  color: _StudentAttendanceContentState._textDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
            ),
            _PageButton(
              icon: Icons.chevron_right,
              enabled: currentPage < totalPages - 1,
              onTap: onNext,
            ),
          ],
        );

        if (constraints.maxWidth < 520) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              text,
              const SizedBox(height: 12),
              controls,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: text),
            controls,
          ],
        );
      },
    );
  }
}

class _PageButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _PageButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: enabled
              ? _StudentAttendanceContentState._primaryBlue
              : const Color(0xFFE9EEF8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: enabled ? Colors.white : const Color(0xFF9AA8BE),
          size: 22,
        ),
      ),
    );
  }
}
