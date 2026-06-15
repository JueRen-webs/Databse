import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uthm/database_helper.dart';

const Color _kHeaderColor = Color(0xFF001C55);
const Color _kBorderColor = Color(0xFFEEEEEE);
const Color _kPrimaryBlue = Color(0xFF0422A7);
const Color _kTrashRed = Color(0xFFC62828);

class AssessmentTab extends StatefulWidget {
  const AssessmentTab({
    super.key,
    required this.sectionId,
    this.canManage = false,
  });

  final String sectionId;
  final bool canManage;

  @override
  State<AssessmentTab> createState() => _AssessmentTabState();
}

class _AssessmentTabState extends State<AssessmentTab> {
  bool _isLoading = true;
  String? _loadError;
  List<Map<String, dynamic>> _assessments = [];

  @override
  void initState() {
    super.initState();
    _loadAssessments();
  }

  @override
  void didUpdateWidget(covariant AssessmentTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sectionId != widget.sectionId) _loadAssessments();
  }

  Future<void> _loadAssessments() async {
    if (mounted) setState(() => _isLoading = true);
    if (widget.sectionId.isEmpty) {
      if (!mounted) return;
      setState(() {
        _assessments = [];
        _isLoading = false;
      });
      return;
    }
    try {
      final rows = await DatabaseHelper.instance.getAssessmentsForSection(
        widget.sectionId,
        includeHidden: widget.canManage,
      );
      if (!mounted) return;
      setState(() {
        _assessments = rows;
        _loadError = null;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _assessments = [];
        _loadError = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _showAssessmentDialog({Map<String, dynamic>? existing}) async {
    String title = existing?['Quiz_Title']?.toString() ?? '';
    DateTime? selectedDate =
        _parseSqlDate(existing?['Assessment_Date']?.toString());
    TimeOfDay? selectedStart =
        _parseTime(existing?['Start_Time']?.toString());
    String duration = existing?['Duration_Minutes']?.toString() ?? '45';
    String instructions = existing?['Instructions']?.toString() ?? '';

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: Text(
              existing == null ? 'Create Assessment' : 'Edit Assessment',
              style: GoogleFonts.poppins(
                color: _kHeaderColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 360,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextFormField(
                    initialValue: title,
                    onChanged: (value) => title = value,
                    decoration: const InputDecoration(
                      labelText: 'Quiz title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _pickerTile(
                    icon: Icons.calendar_today_outlined,
                    label: 'Date',
                    value: selectedDate == null
                        ? 'Select date'
                        : DateFormat('dd MMM yyyy').format(selectedDate!),
                    onTap: () async {
                      FocusManager.instance.primaryFocus?.unfocus();
                      final picked = await showDatePicker(
                        context: dialogContext,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2035),
                      );
                      if (picked != null) {
                        setDialogState(() => selectedDate = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  _pickerTile(
                    icon: Icons.schedule_outlined,
                    label: 'Start time',
                    value: selectedStart == null
                        ? 'Select start time'
                        : selectedStart!.format(dialogContext),
                    onTap: () async {
                      FocusManager.instance.primaryFocus?.unfocus();
                      final picked = await showTimePicker(
                        context: dialogContext,
                        initialTime:
                            selectedStart ?? const TimeOfDay(hour: 9, minute: 0),
                      );
                      if (picked != null) {
                        setDialogState(() => selectedStart = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: duration,
                    onChanged: (value) => duration = value,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Duration (min)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: instructions,
                    onChanged: (value) => instructions = value,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Instructions',
                      hintText: 'Optional',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ]),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final durationMinutes =
                      int.tryParse(duration.replaceAll(RegExp(r'[^0-9]'), ''));
                  if (title.trim().isEmpty ||
                      selectedDate == null ||
                      selectedStart == null ||
                      durationMinutes == null ||
                      durationMinutes <= 0) {
                    _message('Please fill in all assessment details.');
                    return;
                  }
                  final start = _dateTime(selectedDate!, selectedStart!);
                  if (existing == null && start.isBefore(DateTime.now())) {
                    _message('Start time cannot be in the past.');
                    return;
                  }
                  Navigator.pop(dialogContext, {
                    'title': title.trim(),
                    'date': DateFormat('yyyy-MM-dd').format(selectedDate!),
                    'startTime': _formatTime(selectedStart!),
                    'duration': durationMinutes,
                    'instructions': instructions.trim(),
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimaryBlue,
                  foregroundColor: Colors.white,
                ),
                child: Text(existing == null ? 'Create' : 'Save'),
              ),
            ],
          );
        });
      },
    );

    if (result == null) return;
    try {
      if (existing == null) {
        await DatabaseHelper.instance.insertAssessment(
          sectionId: widget.sectionId,
          title: result['title'],
          date: result['date'],
          startTime: result['startTime'],
          durationMinutes: result['duration'],
          instructions: result['instructions'],
        );
        await DatabaseHelper.instance.insertAutoStream(
          sectionId: widget.sectionId,
          title: 'Assessment',
          action: 'created assessment ${result['title']}',
        );
        _message('Assessment created.');
      } else {
        await DatabaseHelper.instance.updateAssessment(
          assessmentId: existing['Assessment_ID'].toString(),
          title: result['title'],
          date: result['date'],
          startTime: result['startTime'],
          durationMinutes: result['duration'],
          instructions: result['instructions'],
        );
        _message('Assessment updated.');
      }
      await _loadAssessments();
    } catch (error) {
      _message('Assessment save failed: $error');
    }
  }

  Future<void> _deleteAssessment(Map<String, dynamic> item) async {
    await DatabaseHelper.instance.deleteAssessment(
      item['Assessment_ID'].toString(),
    );
    await _loadAssessments();
    _message('Assessment deleted.');
  }

  Future<void> _toggleAssessmentHidden(Map<String, dynamic> item) async {
    final isHidden = _isHidden(item);
    await DatabaseHelper.instance.updateAssessmentHidden(
      assessmentId: item['Assessment_ID'].toString(),
      isHidden: !isHidden,
    );
    await _loadAssessments();
    _message(isHidden ? 'Assessment unhidden.' : 'Assessment hidden.');
  }

  void _openAssessment(Map<String, dynamic> item) {
    final start = _assessmentStart(item);
    if (!widget.canManage && start != null && DateTime.now().isBefore(start)) {
      _message('This quiz is not open yet.');
      return;
    }
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item['Quiz_Title']?.toString() ?? 'Quiz'),
        content: Text(
          'this is a quiz',
          style: GoogleFonts.poppins(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Column(children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
            const Icon(Icons.quiz_outlined, color: Colors.grey, size: 20),
            const SizedBox(width: 8),
            Text(
              'Assessment List',
              style: GoogleFonts.poppins(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ]),
        ),
        Container(
          color: _kHeaderColor,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          child: const Row(children: [
            SizedBox(
              width: 48,
              child: Text('No.',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              flex: 3,
              child: Text('Quiz',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              flex: 3,
              child: Text('Start Time',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            SizedBox(width: 44),
          ]),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _loadError != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Assessment could not be loaded.\n$_loadError',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(color: Colors.grey),
                        ),
                      ),
                    )
              : _assessments.isEmpty
                  ? Center(
                      child: Text('No Assessment',
                          style: GoogleFonts.poppins(color: Colors.grey)),
                    )
                  : ListView.separated(
                      itemCount: _assessments.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: _kBorderColor),
                      itemBuilder: (context, index) {
                        final item = _assessments[index];
                        final isHidden = _isHidden(item);
                        return InkWell(
                          onTap: () => _openAssessment(item),
                          child: Container(
                            color: isHidden
                                ? Colors.grey.shade100
                                : Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 48,
                                  child: Text('${index + 1}.',
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold)),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['Quiz_Title']?.toString() ??
                                            'Quiz',
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFFA93226),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                      if (isHidden) ...[
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade300,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            'Hidden',
                                            style: GoogleFonts.poppins(
                                              color: Colors.grey.shade800,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    _displayStart(item),
                                    style: GoogleFonts.poppins(fontSize: 12),
                                  ),
                                ),
                                SizedBox(
                                  width: 44,
                                  child: widget.canManage
                                      ? PopupMenuButton<String>(
                                          icon: const Icon(Icons.more_vert,
                                              color: Colors.grey),
                                          onSelected: (value) {
                                            if (value == 'edit') {
                                              _showAssessmentDialog(
                                                  existing: item);
                                            }
                                            if (value == 'delete') {
                                              _deleteAssessment(item);
                                            }
                                            if (value == 'hide') {
                                              _toggleAssessmentHidden(item);
                                            }
                                          },
                                          itemBuilder: (_) => [
                                            const PopupMenuItem(
                                              value: 'edit',
                                              child: Row(children: [
                                                Icon(Icons.edit_outlined,
                                                    color: _kPrimaryBlue),
                                                SizedBox(width: 8),
                                                Text('Edit'),
                                              ]),
                                            ),
                                            PopupMenuItem(
                                              value: 'hide',
                                              child: Row(children: [
                                                Icon(
                                                  isHidden
                                                      ? Icons.visibility_outlined
                                                      : Icons.visibility_off_outlined,
                                                  color: _kPrimaryBlue,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(isHidden
                                                    ? 'Unhide'
                                                    : 'Hide'),
                                              ]),
                                            ),
                                            const PopupMenuItem(
                                              value: 'delete',
                                              child: Row(children: [
                                                Icon(Icons.delete_outline,
                                                    color: _kTrashRed),
                                                SizedBox(width: 8),
                                                Text('Delete'),
                                              ]),
                                            ),
                                          ],
                                        )
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ]),
      if (widget.canManage)
        Positioned(
          bottom: 24,
          right: 24,
          child: Material(
            color: _kPrimaryBlue,
            borderRadius: BorderRadius.circular(16),
            elevation: 6,
            child: InkWell(
              onTap: () => _showAssessmentDialog(),
              borderRadius: BorderRadius.circular(16),
              child: const SizedBox(
                width: 56,
                height: 56,
                child: Icon(Icons.add, color: Colors.white, size: 28),
              ),
            ),
          ),
        ),
    ]);
  }

  Widget _pickerTile({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Row(children: [
          Icon(icon, color: _kPrimaryBlue, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
        ]),
      ),
    );
  }

  DateTime? _assessmentStart(Map<String, dynamic> item) {
    final date = _parseSqlDate(item['Assessment_Date']?.toString());
    final time = _parseTime(item['Start_Time']?.toString());
    if (date == null || time == null) return null;
    return _dateTime(date, time);
  }

  bool _isHidden(Map<String, dynamic> item) {
    return item['Is_Hidden']?.toString() == '1';
  }

  String _displayStart(Map<String, dynamic> item) {
    final date = _parseSqlDate(item['Assessment_Date']?.toString());
    final startText = item['Start_Time']?.toString() ?? '';
    final start = _parseTime(startText);
    final duration =
        int.tryParse(item['Duration_Minutes']?.toString() ?? '') ?? 0;
    if (date == null) return '-';
    final formattedDate = DateFormat('dd MMM yyyy').format(date);
    final range = start == null || duration <= 0
        ? startText
        : '$startText - ${_formatTime(TimeOfDay.fromDateTime(_dateTime(date, start).add(Duration(minutes: duration))))}';
    return '$formattedDate\n$range';
  }

  DateTime _dateTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final suffix = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $suffix';
  }

  DateTime? _parseSqlDate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return DateTime.tryParse(value.trim());
  }

  TimeOfDay? _parseTime(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final match = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)$',
            caseSensitive: false)
        .firstMatch(value.trim());
    if (match == null) return null;
    var hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final isPm = match.group(3)!.toUpperCase() == 'PM';
    if (isPm && hour != 12) hour += 12;
    if (!isPm && hour == 12) hour = 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }
}
