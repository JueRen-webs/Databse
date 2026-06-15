import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../academic/academic_class_page.dart';
import '../database_helper.dart';
import '../theme/app_colors.dart';




class StudentScheduleItem {
  const StudentScheduleItem({
    required this.start,
    required this.end,
    required this.title,
    required this.location,
  });

  final String start;
  final String end;
  final String title;
  final String location;
}




class DailyTimetableCard extends StatelessWidget {
  const DailyTimetableCard({super.key, required this.items});

  final List<StudentScheduleItem> items;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;


    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Daily Timetable',
                  style: GoogleFonts.inter(
                    color: colors.primaryText,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),



          Column(
            children: List.generate(items.length, (index) {
              return _buildStudentTimelineRow(
                context: context,
                item: items[index],
                isLast: index == items.length - 1,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentTimelineRow({
    required BuildContext context,
    required StudentScheduleItem item,
    required bool isLast,
  }) {
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

                    style: GoogleFonts.inter(
                      color: colors.primaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.location,

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




class DueDateReminderCard extends StatelessWidget {
  const DueDateReminderCard({super.key, required this.reminders});

  final List<Map<String, dynamic>> reminders;

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
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Due Date Reminder',
                  style: GoogleFonts.inter(
                    color: colors.primaryText,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...reminders.map((item) => _buildDueReminderRow(context, item)),
        ],
      ),
    );
  }

  Widget _buildDueReminderRow(BuildContext context, Map<String, dynamic> item) {
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
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: colors.brandPrimary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.assignment_outlined,
              color: colors.brandPrimary,
              size: 19,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w800,
                    color: colors.primaryText,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item['comment']} • ${item['date']} • ${item['daysLeft']} days left',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: colors.secondaryText,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
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
              color: item['color'],
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

class DueDateReminderDbCard extends StatefulWidget {
  const DueDateReminderDbCard({super.key, this.includeStudentLinked = true});

  final bool includeStudentLinked;

  @override
  State<DueDateReminderDbCard> createState() => _DueDateReminderDbCardState();
}

class _DueDateReminderDbCardState extends State<DueDateReminderDbCard> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _reminders = [];

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    final userId = DatabaseHelper.currentUserId;
    if (userId.isEmpty) {
      if (!mounted) return;
      setState(() {
        _reminders = [];
        _isLoading = false;
      });
      return;
    }
    final rows = await DatabaseHelper.instance.getUserReminders(
      userId,
      includeStudentLinked: widget.includeStudentLinked,
    );
    if (!mounted) return;
    setState(() {
      _reminders = rows;
      _isLoading = false;
    });
  }

  Future<void> _showEditor({Map<String, dynamic>? existing}) async {
    String title = existing?['Title']?.toString() ?? '';
    String comment = existing?['Comment']?.toString() ?? '';
    DateTime? dueDate = _parseDueDate(existing?['Due_Date']?.toString());

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(existing == null ? 'Add Reminder' : 'Edit Reminder'),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 340,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextFormField(
                    initialValue: title,
                    onChanged: (value) => title = value,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: comment,
                    onChanged: (value) => comment = value,
                    decoration: const InputDecoration(
                      labelText: 'Comment',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: dialogContext,
                        initialDate: dueDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                      );
                      if (date == null) return;
                      if (!dialogContext.mounted) return;
                      final time = await showTimePicker(
                        context: dialogContext,
                        initialTime: dueDate == null
                            ? const TimeOfDay(hour: 23, minute: 59)
                            : TimeOfDay.fromDateTime(dueDate!),
                      );
                      if (time == null) return;
                      setDialogState(() {
                        dueDate = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Due date',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        dueDate == null
                            ? 'Select due date'
                            : DateFormat('dd MMM yyyy, h:mm a')
                                .format(dueDate!),
                      ),
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
                  if (title.trim().isEmpty || dueDate == null) return;
                  Navigator.pop(dialogContext, {
                    'title': title.trim(),
                    'comment': comment.trim(),
                    'dueDate':
                        DateFormat('yyyy-MM-dd HH:mm:ss').format(dueDate!),
                  });
                },
                child: Text(existing == null ? 'Create' : 'Save'),
              ),
            ],
          );
        });
      },
    );

    if (result == null) return;
    final userId = DatabaseHelper.currentUserId;
    if (existing == null) {
      await DatabaseHelper.instance.insertReminder(
        userId: userId,
        title: result['title'],
        comment: result['comment'],
        dueDate: result['dueDate'],
      );
    } else {
      await DatabaseHelper.instance.updateReminder(
        reminderId: existing['Reminder_ID'].toString(),
        title: result['title'],
        comment: result['comment'],
        dueDate: result['dueDate'],
      );
    }
    await _loadReminders();
  }

  Future<void> _toggleCompleted(Map<String, dynamic> item, bool? value) async {
    await DatabaseHelper.instance.updateReminderStatus(
      reminderId: item['Reminder_ID'].toString(),
      completed: value == true,
    );
    await _loadReminders();
  }

  Future<void> _deleteReminder(Map<String, dynamic> item) async {
    await DatabaseHelper.instance.deleteReminder(item['Reminder_ID'].toString());
    await _loadReminders();
  }

  Future<void> _openLinkedReminder(Map<String, dynamic> item) async {
    final sectionId = item['Section_ID']?.toString() ?? '';
    if (sectionId.isEmpty) return;
    final courseData =
        await DatabaseHelper.instance.getCourseDataBySectionId(sectionId);
    if (!mounted || courseData == null) return;
    final source = item['Source_Type']?.toString() ?? '';
    final comment = item['Comment']?.toString() ?? '';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AcademicClassPage(
          courseData: courseData,
          isLecturer: false,
          initialTab: source == 'assessment'
              ? 'Assessment'
              : source == 'assignment'
                  ? comment.contains('Group')
                      ? 'Group Activities'
                      : 'Individual Activities'
                  : 'Stream',
        ),
      ),
    );
  }

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
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Due Date Reminder',
                  style: GoogleFonts.inter(
                    color: colors.primaryText,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Add reminder',
                onPressed: () => _showEditor(),
                icon: Icon(Icons.add, color: colors.brandPrimary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            )
          else if (_reminders.isEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'No reminders',
                style: GoogleFonts.inter(
                  color: colors.secondaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            ..._reminders.map((item) => _buildDueReminderRow(context, item)),
        ],
      ),
    );
  }

  Widget _buildDueReminderRow(BuildContext context, Map<String, dynamic> item) {
    final colors = context.colors;
    final isCustom = item['Is_Custom']?.toString() == '1';
    final isCompleted = item['Reminder_Status_ID']?.toString() == '2';
    final status = _statusText(item);
    final statusColor = status == 'Completed'
        ? Colors.green
        : status == 'Late'
            ? Colors.red
            : colors.brandPrimary;
    final dueDate = _parseDueDate(item['Due_Date']?.toString());

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.cardAlt,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Checkbox(
            value: isCompleted,
            onChanged: (value) => _toggleCompleted(item, value),
            activeColor: colors.brandPrimary,
          ),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.10),
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
                  item['Title']?.toString() ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w800,
                    color: colors.primaryText,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item['Comment'] ?? ''} • ${dueDate == null ? '-' : DateFormat('dd/MM, h:mm a').format(dueDate)} • $status',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: colors.secondaryText,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (!isCustom)
            IconButton(
              tooltip: 'Open',
              onPressed: () => _openLinkedReminder(item),
              icon: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: colors.brandPrimary,
              ),
            )
          else
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: colors.secondaryText),
              onSelected: (value) {
                if (value == 'edit') _showEditor(existing: item);
                if (value == 'delete') _deleteReminder(item);
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
        ],
      ),
    );
  }

  DateTime? _parseDueDate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return DateTime.tryParse(value.trim()) ??
        DateFormat('d MMM yyyy h:mm a').tryParse(value.trim());
  }

  String _statusText(Map<String, dynamic> item) {
    if (item['Reminder_Status_ID']?.toString() == '2') return 'Completed';
    final dueDate = _parseDueDate(item['Due_Date']?.toString());
    if (dueDate != null && dueDate.isBefore(DateTime.now())) return 'Late';
    return 'In progress';
  }
}
